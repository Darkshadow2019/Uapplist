# Downloader By D@rkshadow
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
        $token = Get-Content $config.github.token_file -Raw
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

Write-Host "🔑 Authenticating as: $owner" -ForegroundColor Cyan
Write-Host "📦 Repository: $repo" -ForegroundColor Cyan
Write-Host "📁 Files to download: $($config.downloads.Count)" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    'Authorization' = 'token $token',
    'Accept' = 'application/vnd.github.v3.raw'
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
        
        # Construct URL
        $url = "https://api.github.com/repos/$owner/$repo/contents/$githubPath"
        
        # Download content
        $content = Invoke-RestMethod -Uri $url -Headers $headers
        
        # Create directory if not exists
        $directory = [System.IO.Path]::GetDirectoryName($localPath)
        if (![string]::IsNullOrEmpty($directory) -and !(Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
            Write-Host "   📁 Created directory: $directory" -ForegroundColor Gray
        }
        
        # Save file
        $content | Out-File -FilePath $localPath -Encoding utf8
        
        Write-Host "   ✅ Saved to: $localPath" -ForegroundColor Green
        $successCount++
        
    } catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
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
