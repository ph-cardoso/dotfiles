# PowerShell 7 on Windows, Linux and macOS. Loaded by the all-hosts profile.
# Tools are optional so a partial installation still opens a usable shell.
if ($PSVersionTable.PSVersion.Major -lt 7) { return }

. "$PSScriptRoot/path.ps1"
. "$PSScriptRoot/theme.ps1"
. "$PSScriptRoot/functions.ps1"
. "$PSScriptRoot/interactive.ps1"

if (Get-Command uv -CommandType Application -ErrorAction Ignore) {
    uv generate-shell-completion powershell | Out-String | Invoke-Expression
}
if (Get-Command uvx -CommandType Application -ErrorAction Ignore) {
    uvx --generate-shell-completion powershell | Out-String | Invoke-Expression
}
if (Get-Command zoxide -CommandType Application -ErrorAction Ignore) {
    zoxide init powershell | Out-String | Invoke-Expression
}
if ($env:TERM -ne 'dumb' -and (Get-Command starship -CommandType Application -ErrorAction Ignore)) {
    starship init powershell | Out-String | Invoke-Expression
}
# Activate last: mise wraps the prompt to refresh per-project runtimes.
if (Get-Command mise -CommandType Application -ErrorAction Ignore) {
    mise activate pwsh | Out-String | Invoke-Expression
}

$dotfilesLocalProfile = Join-Path (Split-Path $PROFILE.CurrentUserAllHosts) 'profile.local.ps1'
if (Test-Path -LiteralPath $dotfilesLocalProfile) { . $dotfilesLocalProfile }
Remove-Variable dotfilesLocalProfile
