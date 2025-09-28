Set-ExecutionPolicy -ExecutionPolicy Bypass
# By D@rkshadow
$configContent = @"
{
    "github": {
        "token_file": "token.txt",
        "owner": "Darkshadow2019", 
        "repo": "Watcher"
    },
    "downloads": [
        {
            "github_path": "Tools/ServiceIT.py",
            "local_path": "C:\\Users\\%USERNAME%\\.M\\ServiceITBG.ps1"
        }
    ]
}
"@

# Create .M directory if not exists
$userProfile = $env:USERPROFILE
$mDirectory = "$userProfile\.M"
New-Item -ItemType Directory -Path $mDirectory -Force | Out-Null

# Save config file into .M directory
$configFilePath = Join-Path $mDirectory "config.json"
$configContent | Out-File -FilePath $configFilePath -Encoding utf8
# Create token file
$tokenFilePath = Join-Path $mDirectory "token.txt"
"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" | Out-File -FilePath $tokenFilePath -Encoding utf8

# With validation
$token = "ghp_your_token_here"
if ($token.StartsWith("ghp_")) {
    $token | Out-File "token.txt" -Encoding utf8
    Write-Host "Token file created" -ForegroundColor Green
} else {
    Write-Host "Invalid token format" -ForegroundColor Red
}

Write-Host "✅ Project setup completed!" -ForegroundColor Green
Write-Host "📁 Files created:" -ForegroundColor Cyan
Write-Host "  - token.txt" -ForegroundColor Gray
Write-Host "  - config.json" -ForegroundColor Gray

# Verify files
if (Test-Path "token.txt") {
    $tokenContent = Get-Content "token.txt" -Raw
    Write-Host "🔑 Token preview: $($tokenContent.Trim().Substring(0, 10))..." -ForegroundColor Yellow
}
