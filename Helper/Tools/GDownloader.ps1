# Downloader By D@rkshadow (fixed version)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "info"
    )
    
    # PowerShell-compatible symbols
    $symbols = @{
        success = "✓"
        error   = "✗" 
        warning = "!"
        info    = "ⓘ"
        question = "?"
        download = "↓"
        upload   = "↑"
        folder   = "[ ]"
        key      = "⚿"
        package  = "☐"
    }
    
    $colors = @{
        success = "Green"
        error   = "Red"
        warning = "Yellow" 
        info    = "Cyan"
        question = "Magenta"
        download = "Blue"
        upload   = "Blue"
        folder   = "Cyan"
        key      = "Yellow"
        package  = "Cyan"
    }
    
    $symbol = $symbols[$Type]
    $color = $colors[$Type]
    
    Write-Host "$symbol $Message" -ForegroundColor $color
}


param(
    [string]$ConfigFile = "config.json"
)

# Set TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Load configuration
if (!(Test-Path $ConfigFile)) {
    Write-Host "❌ Config file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

# Get token (from direct value or file)
$token = $config.github.token
if ($config.github.token_file) {
    if (Test-Path $config.github.token_file) {
        $token = (Get-Content $config.github.token_file -Raw).Trim()
    } else {
        Write-Host "❌ Token file not found: $($config.github.token_file)" -ForegroundColor Red
        exit 1
    }
}

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ GitHub token not found in config" -ForegroundColor Red
    exit 1
}

$owner = $config.github.owner
$repo = $config.github.repo

# Validate required fields
if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($repo)) {
    Write-Host "❌ Missing owner or repo in config" -ForegroundColor Red
    exit 1
}

# Then use emoji
# Write-Host "🔑Authenticating as: $owner" -ForegroundColor Cyan
Write-ColorOutput "Authentication required" "key" -NoNewLine; Write-Host "$owner" -ForegroundColor Cyan
Write-Host "📦Repository: $repo" -ForegroundColor Cyan
Write-Host "📁Files to download: $($config.downloads.Count)" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    Authorization = "token $token"
    Accept        = "application/vnd.github.v3.raw"
}

$successCount = 0
$failCount = 0

foreach ($download in $config.downloads) {
    try {
        $githubPath = $download.github_path
        $localPath = $download.local_path
        
        # Expand environment variables
        $localPath = [System.Environment]::ExpandEnvironmentVariables($localPath)
        
        Write-Host "📥 Downloading: $githubPath" -ForegroundColor Yellow
        Write-Host "   From: $owner/$repo" -ForegroundColor Gray
        
        # Construct URL
        $url = "https://api.github.com/repos/$owner/$repo/contents/$githubPath"
        Write-Host "   URL: $url" -ForegroundColor DarkGray
        
        # Download content: Accept header will yield RAW content directly
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        
        # If response is a string (raw), else use content (base64)
        if ($response -is [string]) {
            $content = $response
        } elseif ($response.content) {
            $content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($response.content))
        } else {
            throw "No content received from GitHub"
        }
        
        # Create directory if not exists
        $directory = [System.IO.Path]::GetDirectoryName($localPath)
        if (![string]::IsNullOrEmpty($directory) -and !(Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
            Write-Host "   📁 Created directory: $directory" -ForegroundColor Gray
        }
        
        # Save file
        $content | Out-File -FilePath $localPath -Encoding utf8 -Force
        
        # Verify file was created
        if (Test-Path $localPath) {
            $fileSize = (Get-Item $localPath).Length
            Write-Host "   ✅ Saved to: $localPath ($fileSize bytes)" -ForegroundColor Green
            $successCount++
        } else {
            throw "File was not created successfully"
        }
        
    } catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "   HTTP Status: $($_.Exception.Response.StatusCode)" -ForegroundColor DarkRed
        }
        $failCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "====== Download Summary ======" -ForegroundColor Cyan
Write-Host "✅ Successful: $successCount" -ForegroundColor Green
Write-Host "❌ Failed: $failCount" -ForegroundColor Red
Write-Host "📊 Total: $($config.downloads.Count)" -ForegroundColor Yellow

if ($failCount -eq 0) {
    Write-Host "🎉 All downloads completed successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some downloads failed. Check the errors above." -ForegroundColor Yellow
}

exit $failCount
