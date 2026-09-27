# Dependency-free integration tests. All writes stay in a unique temp directory.
# Run: pwsh -NoProfile -File tests/install.Tests.ps1
#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("dotfiles-test-" + [guid]::NewGuid())
$target = Join-Path $fixture "home with space and 'quote"
$config = Join-Path $target '.config'
$profileFile = Join-Path $target 'Documents/PowerShell/profile.ps1'
$options = @{
    SkipPackages = $true; SkipRuntimes = $true
    TargetHome = $target; ConfigHome = $config; ProfilePath = $profileFile
    LocalAppData = (Join-Path $target 'AppData/Local')
    RoamingAppData = (Join-Path $target 'AppData/Roaming')
}
function Assert($Condition, $Message) { if (-not $Condition) { throw $Message } }
New-Item -ItemType Directory -Path (Split-Path $profileFile) -Force | Out-Null
Set-Content -LiteralPath $profileFile -Value '# old custom profile'
Set-Content -LiteralPath (Join-Path $target '.gitconfig') -Value "[user]`n`tname = Existing User`n[core]`n`tsshCommand = custom-ssh"
try {
    & "$repo/install.ps1" @options
    Assert (Test-Path "$config/mise/config.toml") 'Missing shared mise config'
    Assert (Test-Path "$target/AppData/Local/nvim/init.lua") 'Missing native Neovim config'
    Assert (Test-Path "$target/AppData/Roaming/fd/ignore") 'Missing native fd config'
    Assert ((git config --file "$target/.gitconfig" --includes --get user.name) -eq 'Existing User') 'Lost Git identity'
    Assert ((git config --file "$target/.gitconfig" --includes --get core.sshCommand) -eq 'custom-ssh') 'Lost SSH transport'
    Assert ((git config --file "$target/.gitconfig" --includes --get pull.rebase) -eq 'true') 'Portable Git include not loaded'
    $signing = git config --file "$target/.gitconfig" --includes --get commit.gpgsign
    Assert (-not $signing) 'Enabled placeholder commit signing'
    $backups = @(Get-ChildItem -LiteralPath $target -Recurse -Force -Filter '*.bak.*').Count
    & "$repo/install.ps1" @options
    Assert (@(Get-ChildItem -LiteralPath $target -Recurse -Force -Filter '*.bak.*').Count -eq $backups) 'Second installation was not idempotent'
    Set-Content -LiteralPath "$config/bat/config" -Value '# newly edited config'
    & "$repo/install.ps1" @options
    $saved = Get-ChildItem -LiteralPath "$config/bat" -Filter '*.bak.*'
    Assert ((Get-Content -LiteralPath $saved.FullName -Raw) -match 'newly edited') 'A changed config was not backed up'
    $tokens = $null; $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($profileFile, [ref]$tokens, [ref]$parseErrors) > $null
    Assert (-not $parseErrors) 'Generated profile has invalid quoting'
    . "$repo/.config/powershell/profile.ps1"
    Assert ((Get-Command gcm).CommandType -eq 'Function') 'gcm alias masks Git shortcut'
    Assert ((Get-Command cd).Definition -eq 'Set-Location') 'PowerShell cd was replaced'
    Push-Location $target
    try { zd $config; Assert ((Get-Location).Path -eq $config) 'zd cannot navigate literal paths' } finally { Pop-Location }
    Write-Host 'PASS: backups, idempotence, local Git settings, native config paths and profile startup'
} finally {
    # Verify the exact recursive deletion target is the unique fixture under temp.
    $resolved = [IO.Path]::GetFullPath($fixture)
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if (-not $resolved.StartsWith($tempRoot) -or (Split-Path $resolved -Leaf) -notlike 'dotfiles-test-*') { throw 'Unsafe fixture cleanup path' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
