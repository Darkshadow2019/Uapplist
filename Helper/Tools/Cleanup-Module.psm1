# Complete module cleanup
function Clear-AllModules {
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$KeepPowerShellCore
    )
    
    Write-Host "Cleaning up loaded modules..." -ForegroundColor Yellow
    
    # Get all currently loaded modules
    $loadedModules = Get-Module
    
    Write-Host "Found $($loadedModules.Count) loaded modules" -ForegroundColor Gray
    
    # Define modules to keep
    $modulesToKeep = @()
    
    if ($KeepPowerShellCore) {
        $modulesToKeep += "Microsoft.PowerShell.*"
        $modulesToKeep += "PSReadLine*"
        $modulesToKeep += "PackageManagement*"
        $modulesToKeep += "PowerShellGet*"
    }
    
    # Remove modules
    $removedCount = 0
    foreach ($module in $loadedModules) {
        $shouldRemove = $true
        
        # Check if module should be kept
        foreach ($pattern in $modulesToKeep) {
            if ($module.Name -like $pattern) {
                $shouldRemove = $false
                break
            }
        }
        
        if ($shouldRemove) {
            try {
                Remove-Module -Name $module.Name -Force -ErrorAction Stop
                Write-Host "Removed: $($module.Name)" -ForegroundColor Green
                $removedCount++
            } catch {
                Write-Host "Failed to remove: $($module.Name) - $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "Kept: $($module.Name)" -ForegroundColor Gray
        }
    }
    
    Write-Host "Removed $removedCount modules" -ForegroundColor Cyan
    
    # Force garbage collection
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    Write-Host "Memory cleanup completed" -ForegroundColor Green
}

# Usage
# Clear-AllModules
