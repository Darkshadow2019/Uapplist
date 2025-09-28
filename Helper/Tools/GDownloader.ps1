<#
    GDownloader.ps1
    -------------------------
    GitHub File Downloader Script (Header Version)
    Author      : D@rkshadow
    Description : Download files from public/private GitHub repositories using config.json and token.txt.
    Usage       : 
        - Place GDownloader.ps1, config.json, and token.txt in the same folder.
        - Run in PowerShell: .\GDownloader.ps1
#>
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Ignore encoding errors
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "info"
    )
    
    # # PowerShell-compatible symbols
    # $symbols = @{
    #     success = "✓"
    #     error   = "x"
    #     warning = "[❕]"
    #     info    = "ℹ"
    #     question = "?"
    #     download = "↓"
    #     upload   = "↑"
    #     folder   = "[ ]"
    #     key      = "⚿"
    #     repo  = "☐"
    # }

    # Use ASCII characters only (guaranteed to work)
    $symbols = @{
        success = "[OK]"
        error   = "[✖]" 
        warning = "[!]"
        info    = "[i]"
        question = "[?]"
        download = "[DL]"
        upload   = "[UL]"
        folder   = "[DIR]"
        key      = "[KEY]"
        repo     = "[REPO]"
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
        repo  = "Cyan"
    }
    
    $symbol = $symbols[$Type]
    $color = $colors[$Type]
    
    Write-Host "$symbol $Message" -ForegroundColor $color -NoNewline
}


# Set TLS version for secure requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Load configuration
$DefaultConfigPath = Join-Path $ScriptDir "config.json"
if (!(Test-Path $ConfigFile)) {
    if (Test-Path $DefaultConfigPath) {
        $ConfigFile = $DefaultConfigPath
    } else {
        Write-ColorOutput "Token file not found:" "error"; Write-Host "$ConfigFile"
        exit 1
    }
}

$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

# Get token (from direct value or file)
$token = $config.github.token
if ($config.github.token_file) {
    # If token_file is absolute, use as is. If relative, use script directory.
    if ([IO.Path]::IsPathRooted($config.github.token_file)) {
        $tokenFilePath = $config.github.token_file
    } else {
        $tokenFilePath = Join-Path $ScriptDir $config.github.token_file
    }
    if (Test-Path $tokenFilePath) {
        $token = (Get-Content $tokenFilePath -Raw).Trim()
    } else {
        Write-ColorOutput "Token file not found" "error"
        exit 1
    }
}

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-ColorOutput "token not found in config" "error"
    exit 1
}

$owner = $config.github.owner
$repo = $config.github.repo

# Validate required fields
if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($repo)) {
    Write-ColorOutput "Missing owner or repo in config" "error"
    exit 1
}

Write-ColorOutput "Authenticating as :" "key"; Write-Host "$owner" -ForegroundColor Cyan
Write-ColorOutput "Repository :" "repo"; Write-Host "$repo" -ForegroundColor Cyan
Write-ColorOutput "Files to download:" "folder"; Write-Host "$($config.downloads.Count)" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    Authorization = "token $token"
    Accept        = "application/vnd.github.v3.raw"
    "User-Agent"  = "GDownloader-Script"
}

$successCount = 0
$failCount = 0

foreach ($download in $config.downloads) {
    try {
        $githubPath = $download.github_path
        $localPath = $download.local_path
        
        # Expand environment variables
        $localPath = [System.Environment]::ExpandEnvironmentVariables($localPath)
        
        Write-Host "📥Downloading: $githubPath" -ForegroundColor Yellow
        Write-Host "From: $owner/$repo" -ForegroundColor Gray
        
        # Construct URL
        $url = "https://api.github.com/repos/$owner/$repo/contents/$githubPath"
        Write-Host "URL: $url" -ForegroundColor DarkGray
        
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
			Write-ColorOutput "Created directory:" "folder"; Write-Host "$directory" -ForegroundColor Gray
        }
        
        # Save file
        $content | Out-File -FilePath $localPath -Encoding utf8 -Force
        
        # Verify file was created
        if (Test-Path $localPath) {
            $fileSize = (Get-Item $localPath).Length
            Write-Host "✅Saved to: $localPath ($fileSize bytes)" -ForegroundColor Green
            $successCount++
        } else {
            throw "File was not created successfully"
        }
        
    } catch {
        Write-Host "❌Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "HTTP Status: $($_.Exception.Response.StatusCode)" -ForegroundColor DarkRed
        }
        $failCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "====== Download Summary ======" -ForegroundColor Cyan
Write-Host "✅Successful: $successCount" -ForegroundColor Green
Write-Host "❌Failed: $failCount" -ForegroundColor Red
Write-Host "📊Total: $($config.downloads.Count)" -ForegroundColor Yellow

if ($failCount -eq 0) {
    Write-Host "🎉All downloads completed successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️Some downloads failed. Check the errors above." -ForegroundColor Yellow
}

exit $failCount
