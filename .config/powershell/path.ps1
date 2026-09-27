function Add-DotfilesPath {
    param([string]$Directory)
    if ((Test-Path -LiteralPath $Directory -PathType Container) -and
        $Directory -notin ($env:PATH -split [IO.Path]::PathSeparator)) {
        $env:PATH = $Directory + [IO.Path]::PathSeparator + $env:PATH
    }
}

if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = Join-Path $HOME '.config' }
Add-DotfilesPath (Join-Path $HOME '.local/bin')
Add-DotfilesPath (Join-Path $HOME '.opencode/bin')
if ($IsWindows) {
    Add-DotfilesPath (Join-Path $env:LOCALAPPDATA 'Microsoft/WinGet/Links')
    if (-not $env:PNPM_HOME) { $env:PNPM_HOME = Join-Path $env:LOCALAPPDATA 'pnpm' }
} else {
    foreach ($brewPrefix in @('/home/linuxbrew/.linuxbrew', '/usr/local', '/opt/homebrew')) {
        if (Test-Path "$brewPrefix/bin/brew") {
            Add-DotfilesPath "$brewPrefix/sbin"
            Add-DotfilesPath "$brewPrefix/bin"
        }
    }
    if (-not $env:PNPM_HOME) {
        $env:PNPM_HOME = if ($IsMacOS) { "$HOME/Library/pnpm" } else { "$HOME/.local/share/pnpm" }
    }
}
Add-DotfilesPath $env:PNPM_HOME

$env:STARSHIP_CONFIG = Join-Path $env:XDG_CONFIG_HOME 'starship.toml'
$env:BAT_CONFIG_PATH = Join-Path $env:XDG_CONFIG_HOME 'bat/config'
$env:EZA_CONFIG_DIR = Join-Path $env:XDG_CONFIG_HOME 'eza'
if (Get-Command nvim -CommandType Application -ErrorAction Ignore) {
    $env:EDITOR = 'nvim'
    $env:VISUAL = 'nvim'
}
Remove-Item Function:/Add-DotfilesPath
