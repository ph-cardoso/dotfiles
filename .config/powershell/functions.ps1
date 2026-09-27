# Keep PowerShell's object-producing ls/cat/cd aliases; native tools get shortcuts.
function ll { if (Get-Command eza -ErrorAction Ignore) { eza -lh --group-directories-first --icons=auto @args } else { Get-ChildItem @args } }
function la { if (Get-Command eza -ErrorAction Ignore) { eza -lha --group-directories-first --icons=auto @args } else { Get-ChildItem -Force @args } }
function lt { eza --tree --level=2 --long --icons=auto --git @args }
function lta { lt -a @args }
function g { git @args }
function gcm { git commit -m @args }
function gcam { git commit -a -m @args }
function gcad { git commit -a --amend @args }
function n { if ($args.Count) { nvim @args } else { nvim . } }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function path { $env:PATH -split [IO.Path]::PathSeparator }
function c { Clear-Host }
function rpwsh { . $PROFILE.CurrentUserAllHosts }
function epwsh { & $env:EDITOR $PROFILE.CurrentUserAllHosts }

function zd {
    if (-not $args.Count) { Set-Location $HOME }
    elseif (($args.Count -eq 1) -and (Test-Path -LiteralPath $args[0] -PathType Container)) {
        Set-Location -LiteralPath $args[0]
    } elseif (Get-Command z -ErrorAction Ignore) { z @args }
    else { Set-Location @args }
}

function open {
    param([string]$Path = '.')
    if ($IsWindows) { Start-Process -FilePath $Path }
    elseif ($IsMacOS) { & /usr/bin/open $Path }
    else { & xdg-open $Path }
}
function ff {
    $options = @('--prompt=Files> ')
    if (Get-Command bat -CommandType Application -ErrorAction Ignore) {
        $options += @('--preview', 'bat --color=always --style=numbers --line-range :500 {}')
    }
    & fzf @options @args
}
function eff {
    $selected = ff --no-multi
    if ($selected) { & $env:EDITOR $selected }
}
function upd {
    if ($IsWindows) { winget upgrade --all }
    elseif (Get-Command brew -ErrorAction Ignore) { brew update; if ($LASTEXITCODE -eq 0) { brew upgrade } }
}

# gcm is normally Get-Command; match the existing zsh shortcut.
Remove-Alias -Name gcm -Scope Global -Force -ErrorAction Ignore
if ($IsWindows) {
    function pbcopy { $input | Set-Clipboard }
    function pbpaste { Get-Clipboard -Raw }
    $global:DotfilesClipImageScript = Join-Path $PSScriptRoot 'clipimg.ps1'
    function clipimg { pwsh -NoLogo -NoProfile -STA -File $global:DotfilesClipImageScript @args }
}
