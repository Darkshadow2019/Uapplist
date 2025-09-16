function Version {
        # Use Write-Host only to display clear text on the console.
        Write-Host
        Write-Host "~~~~~ SilentAppRemover ~~~~~" -ForegroundColor Cyan
        Write-Host "    Version    :   1.0.0.1" -ForegroundColor Cyan
        Write-Host "    developer  :   D@rkshadow Myanmar" -ForegroundColor Cyan
        Write-Host "    release    :   16.9.2025" -ForegroundColor Cyan
    }

# Complete silent application remover
class SilentAppRemover {
    static [void] RemoveApplication([string]$AppName) {
        Write-Host "Starting silent removal of $AppName..." -ForegroundColor Cyan   
        # Method 1: Try MSI uninstall
        try {
            $products = Get-WmiObject -Class Win32_Product | 
                       Where-Object { $_.Name -like "*$AppName*" }
            
            foreach ($product in $products) {
                Write-Host "Uninstalling via MSI: $($product.Name)" -ForegroundColor Yellow
                $process = Start-Process -FilePath "msiexec.exe" `
                    -ArgumentList "/x `"$($product.IdentifyingNumber)`" /qn /norestart" `
                    -Wait -PassThru -WindowStyle Hidden
            }
        } catch { /* Continue to next method */ }
        
        # Method 2: Try registry uninstall
        try {
            $uninstallPaths = @(
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            
            foreach ($path in $uninstallPaths) {
                $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | 
                       Where-Object { $_.DisplayName -like "*$AppName*" }
                
                foreach ($app in $apps) {
                    if ($app.UninstallString) {
                        Write-Host "Uninstalling via registry: $($app.DisplayName)" -ForegroundColor Yellow
                        
                        $uninstallCmd = $app.UninstallString
                        if ($uninstallCmd -like "msiexec*") {
                            $uninstallCmd = $uninstallCmd -replace "/I", "/x" -replace "/i", "/x"
                            $uninstallCmd += " /qn /norestart"
                        } else {
                            $uninstallCmd += " /S /quiet /silent /norestart"
                        }
                        
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCmd" `
                            -Wait -WindowStyle Hidden
                    }
                }
            }
        } catch { /* Continue to next method */ }
        
        # Method 3: Remove files and folders
        try {
            $pathsToRemove = @(
                "${env:ProgramFiles}\$AppName*",
                "${env:ProgramFiles(x86)}\$AppName*",
                "${env:LocalAppData}\Programs\$AppName*",
                "${env:AppData}\$AppName*",
                "${env:LocalAppData}\$AppName*"
            )
            
            foreach ($path in $pathsToRemove) {
                Get-Item $path -ErrorAction SilentlyContinue | ForEach-Object {
                    Write-Host "Removing files: $($_.FullName)" -ForegroundColor Yellow
                    Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        } catch { /* Continue */ }
        
        Write-Host "✅ Silent removal process completed for $AppName" -ForegroundColor Green
    }
}




