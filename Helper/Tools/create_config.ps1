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

Write-Host "✅ config.json file created successfully!" -ForegroundColor Green
Write-Host ("📁 Location: " + $configFilePath) -ForegroundColor Yellow
