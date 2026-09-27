# Called in a separate STA process by clipimg; never reads the clipboard at startup.
#requires -Version 7.0
param([string]$OutputPath)
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Use wsl-clip-img under WSL; this helper needs native Windows.' }
Add-Type -AssemblyName System.Windows.Forms
$clipboardImage = [Windows.Forms.Clipboard]::GetImage()
if (-not $clipboardImage) { throw 'The clipboard does not contain an image.' }
try {
    if (-not $OutputPath) {
        $cacheRoot = if ($env:XDG_CACHE_HOME) { $env:XDG_CACHE_HOME } else { Join-Path $HOME '.cache' }
        $OutputPath = Join-Path $cacheRoot "clipboard/clip-$([DateTime]::Now.ToString('yyyyMMdd-HHmmss-fffffff')).png"
    }
    $OutputPath = [IO.Path]::GetFullPath($OutputPath)
    if (Test-Path -LiteralPath $OutputPath) { throw "File already exists: $OutputPath" }
    New-Item -ItemType Directory -Path (Split-Path $OutputPath) -Force | Out-Null
    $clipboardImage.Save($OutputPath, [Drawing.Imaging.ImageFormat]::Png)
    Write-Output $OutputPath
} finally { $clipboardImage.Dispose() }
