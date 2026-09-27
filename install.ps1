#requires -Version 7.0
<#
.SYNOPSIS
Install the native Windows CLI environment. Use install.sh on Linux/macOS.
.DESCRIPTION
Copies configs without requiring symlink privileges. Changed files receive
unique adjacent backups. -SkipPackages -SkipRuntimes is an offline config install.
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$SkipRuntimes,
    [string]$TargetHome = $HOME,
    [string]$ConfigHome = $(if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $TargetHome '.config' }),
    [string]$ProfilePath = $PROFILE.CurrentUserAllHosts,
    [string]$LocalAppData = $env:LOCALAPPDATA,
    [string]$RoamingAppData = $env:APPDATA
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot

function Backup-Dotfile {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        $backup = "$Path.bak.$([DateTime]::UtcNow.ToString('yyyyMMddHHmmssfffffff'))"
        # Only individual files are replaced; directory contents are merged.
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Host "Backed up $Path -> $backup"
    }
}

function Write-Dotfile {
    param([string]$Destination, [byte[]]$Bytes)
    if (Test-Path -LiteralPath $Destination -PathType Container) { throw "Expected a file, found a directory: $Destination" }
    if (Test-Path -LiteralPath $Destination -PathType Leaf) {
        if ([Convert]::ToBase64String([IO.File]::ReadAllBytes($Destination)) -eq [Convert]::ToBase64String($Bytes)) { return }
    }
    New-Item -ItemType Directory -Path (Split-Path $Destination) -Force | Out-Null
    Backup-Dotfile $Destination
    [IO.File]::WriteAllBytes($Destination, $Bytes)
    Write-Host "Configured $Destination"
}

function Copy-Dotfile {
    param([string]$Source, [string]$Destination)
    Write-Dotfile $Destination ([IO.File]::ReadAllBytes($Source))
}

function Copy-DotDirectory {
    param([string]$Source, [string]$Destination)
    foreach ($file in Get-ChildItem -LiteralPath $Source -File -Recurse -Force) {
        if ($file.Name -like '*.bak.*' -or $file.Name -eq 'profile.local.ps1') { continue }
        Copy-Dotfile $file.FullName (Join-Path $Destination ([IO.Path]::GetRelativePath($Source, $file.FullName)))
    }
}

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed with exit code $LASTEXITCODE" }
}

function Install-Packages {
    if (-not (Get-Command winget -ErrorAction Ignore)) {
        throw 'WinGet is required. Install App Installer, or use -SkipPackages for an existing tool installation.'
    }
    foreach ($id in Get-Content "$repo/windows/packages.json" -Raw | ConvertFrom-Json) {
        & winget list --id $id --exact --source winget --accept-source-agreements --disable-interactivity *> $null
        if ($LASTEXITCODE -eq 0) { Write-Host "Already installed: $id"; continue }
        Write-Host "Installing $id"
        # Prefer per-user portable installers; some packages (e.g. Neovim's MSI)
        # only publish a machine installer and may show Windows' UAC prompt.
        & winget show --id $id --exact --source winget --scope user --disable-interactivity *> $null
        $scope = if ($LASTEXITCODE -eq 0) { @('--scope', 'user') } else { @() }
        Invoke-Checked winget (@('install', '--id', $id, '--exact', '--source', 'winget', '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity') + $scope)
    }
    # Pick up MSI-installed tools and portable WinGet links in this process too.
    $env:PATH = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::GetEnvironmentVariable('Path', 'User')
        (Join-Path $LocalAppData 'Microsoft/WinGet/Links')
        $env:PATH
    ) -join [IO.Path]::PathSeparator
}

function Install-GitConfig {
    $local = Join-Path $TargetHome '.gitconfig.local'
    if (-not (Test-Path -LiteralPath $local)) { Copy-Dotfile "$repo/.gitconfig.local.example" $local }
    $config = Join-Path $TargetHome '.gitconfig'
    $portable = (Join-Path $ConfigHome 'git/dotfiles').Replace('\', '/')
    # The deployed include uses an absolute local path, also making isolated installs testable.
    $shared = [IO.File]::ReadAllText("$repo/.gitconfig").Replace('~/.gitconfig.local', $local.Replace('\', '/'))
    Write-Dotfile $portable ([Text.Encoding]::UTF8.GetBytes($shared))
    $existing = if (Test-Path -LiteralPath $config) { [IO.File]::ReadAllText($config) } else { '' }
    $includes = @(& git config --file $config --get-all include.path 2>$null)
    if ($portable -notin $includes) {
        # Use git to quote the include correctly, then deploy without modifying a symlink target.
        $temp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
        try {
            [IO.File]::WriteAllText($temp, $existing)
            Invoke-Checked git @('config', '--file', $temp, '--add', 'include.path', $portable)
            Copy-Dotfile $temp $config
        } finally { Remove-Item -LiteralPath $temp -ErrorAction Ignore }
    }
}

function Install-Configs {
    foreach ($name in @('bat', 'eza', 'fd', 'mise', 'nvim')) {
        Copy-DotDirectory "$repo/.config/$name" (Join-Path $ConfigHome $name)
    }
    Copy-Dotfile "$repo/.config/starship.toml" (Join-Path $ConfigHome 'starship.toml')
    # Native defaults also work outside a PowerShell session (GUI/editor launches).
    Copy-DotDirectory "$repo/.config/nvim" (Join-Path $LocalAppData 'nvim')
    Copy-DotDirectory "$repo/.config/bat" (Join-Path $RoamingAppData 'bat')
    Copy-DotDirectory "$repo/.config/fd" (Join-Path $RoamingAppData 'fd')
    Copy-Dotfile "$repo/.config/wezterm/.wezterm.lua" (Join-Path $TargetHome '.wezterm.lua')
    Install-GitConfig
    # Reference the checkout so profile edits take effect immediately; handles spaces/apostrophes.
    $profileSource = (Join-Path $repo '.config/powershell/profile.ps1').Replace("'", "''")
    $loader = "# Managed by dotfiles. Machine overrides: profile.local.ps1 beside this file.`n. '$profileSource'`n"
    Write-Dotfile $ProfilePath ([Text.Encoding]::UTF8.GetBytes($loader))
}

function Install-Runtimes {
    foreach ($tool in @('mise', 'uv')) {
        if (-not (Get-Command $tool -CommandType Application -ErrorAction Ignore)) { throw "$tool is missing. Install packages first, or use -SkipRuntimes." }
    }
    $previousConfigDir = $env:MISE_CONFIG_DIR
    try {
        $env:MISE_CONFIG_DIR = Join-Path $ConfigHome 'mise'
        Invoke-Checked mise @('trust', (Join-Path $env:MISE_CONFIG_DIR 'config.toml'))
        Invoke-Checked mise @('--cd', $TargetHome, 'install')
        Invoke-Checked mise @('--cd', $TargetHome, 'exec', '--', 'uv', 'tool', 'install', '--python', '3.14', 'pgcli')
    } finally { $env:MISE_CONFIG_DIR = $previousConfigDir }
}

if ($MyInvocation.InvocationName -ne '.') {
    if (-not $IsWindows) { throw 'Run bash install.sh on Linux/macOS; it also configures PowerShell 7.' }
    if (-not $SkipPackages) { Install-Packages }
    if (-not (Get-Command git -CommandType Application -ErrorAction Ignore)) { throw 'Git is required to configure portable Git includes.' }
    Install-Configs
    if (-not $SkipRuntimes) { Install-Runtimes }
    Write-Host 'Done. Open a new PowerShell 7 terminal. Machine-specific Git values belong in ~/.gitconfig.local.'
}
