# PSReadLine is built into PowerShell 7; no Gallery modules required.
if ($Host.Name -eq 'ConsoleHost' -and -not [Console]::IsInputRedirected) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    if (Get-Module PSReadLine) {
        Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -PredictionSource History
        Set-PSReadLineOption -Colors @{
            Command = '#89b4fa'; Parameter = '#f5c2e7'; String = '#a6e3a1'
            Number = '#fab387'; Operator = '#94e2d5'; Variable = '#cba6f7'
            Comment = '#6c7086'; InlinePrediction = '#6c7086'
        }
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        if (Get-Command fzf -CommandType Application -ErrorAction Ignore) {
            Set-PSReadLineKeyHandler -Chord Ctrl+r -BriefDescription FuzzyHistory -ScriptBlock {
                $historyPath = (Get-PSReadLineOption).HistorySavePath
                if (Test-Path -LiteralPath $historyPath) {
                    $lines = [IO.File]::ReadAllLines($historyPath)
                    [Array]::Reverse($lines)
                    $selected = $lines | Select-Object -Unique | fzf --no-multi --scheme=history '--prompt=History> '
                    if ($selected) {
                        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
                    }
                }
            }
            Set-PSReadLineKeyHandler -Chord Ctrl+t,Ctrl+Alt+f -BriefDescription FuzzyFile -ScriptBlock {
                $selected = ff --no-multi
                if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert("'" + $selected.Replace("'", "''") + "' ") }
            }
            Set-PSReadLineKeyHandler -Chord Ctrl+Alt+l -BriefDescription FuzzyCommit -ScriptBlock {
                git rev-parse --git-dir 2>$null | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $selected = git log --no-show-signature '--format=%h %s' | fzf --no-multi '--prompt=Git log> ' --preview 'git show --color=always {1}'
                    if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($selected -split ' ', 2)[0] + ' ') }
                }
            }
            Set-PSReadLineKeyHandler -Chord Ctrl+Alt+v -BriefDescription FuzzyVariable -ScriptBlock {
                $selected = Get-Variable | Select-Object -ExpandProperty Name | fzf --no-multi '--prompt=Variables> '
                if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert('${' + $selected + '}') }
            }
            Set-PSReadLineKeyHandler -Chord Alt+c -BriefDescription FuzzyDirectory -ScriptBlock {
                if (Get-Command fd -ErrorAction Ignore) {
                    $selected = fd --type d --hidden --strip-cwd-prefix | fzf --no-multi '--prompt=Directories> '
                    if ($selected) { Set-Location -LiteralPath $selected; [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt() }
                }
            }
        }
    }
}
