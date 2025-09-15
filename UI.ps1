Set-ExecutionPolicy Bypass -Scope Process -Force;
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# UAC Accept ---------------------------------------------------------------------
# Admin check လုပ်ပြီး auto-elevate လုပ်ခြင်း
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return ([Security.Principal.WindowsPrincipal]::new($currentUser)).IsInRole($adminRole)
}

if (-not (Test-Admin)) {
    Write-Host "🔄 Admin rights required. Elevating..." -ForegroundColor Yellow
    
    # Relaunch as admin
    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
    exit
}

# Admin rights ရပြီးရင် ဒီအောက်က code တွေ run မယ်
Write-Host "✅ Running with administrator privileges!" -ForegroundColor Green
Get-Date
# End About module add------------------------------------------------------------
function Get-GitHubRawContent {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Path,
        [string]$Branch = "main"
    )
    
    $apiUrl = "https://api.github.com/repos/${Owner}/${Repo}/contents/${Path}?ref=${Branch}"
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers @{
            'Accept' = 'application/vnd.github.v3.raw'
            'User-Agent' = 'PowerShell'
        }
        
        return $response
    } catch {
        Write-Error "GitHub API error: $($_.Exception.Message)"
        return $null
    }
}

function Import-GitHubModuleAdvanced {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Path,
        [string]$Branch = "main"
    )
    
    $content = Get-GitHubRawContent -Owner $Owner -Repo $Repo -Path $Path -Branch $Branch
    
    if ($content) {
        try {
            # Create temporary file
            $tempFile = [System.IO.Path]::GetTempFileName() + ".psm1"
            $content | Out-File -FilePath $tempFile -Encoding UTF8
            
            # Import module
            Import-Module -Name $tempFile -Force
            
            Write-Host "✅ GitHub module imported successfully!" -ForegroundColor Green
            
            # Clean up
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
            
            return $true
        } catch {
            Write-Error "Import failed: $($_.Exception.Message)"
        }
    }
    
    return $false
}

# End Module Adding ----------------------------------------------------------------------------------------------------------
Clear-Host;
Write-Host; Write-Host
#Title+++++++++++++++++++++++++++++++++++
Write-Host "[+]+++++++++++++++++++++++++++++++++++++++++++++++++++++++[+]" -ForegroundColor Yellow -BackgroundColor red;
Write-Host "[+]                                                       [+]" -ForegroundColor Yellow -BackgroundColor red;
Write-Host "[+]   " -ForegroundColor Yellow -BackgroundColor Red -NoNewline; Write-Host “       Windows Temporary Cleanner Script     ” -ForegroundColor Cyan -NoNewline; Write-Host "       [+]" -ForegroundColor Yellow -BackgroundColor red;
Write-Host "[+]   " -ForegroundColor Yellow -BackgroundColor Red -NoNewline; Write-Host “                 Version 1.0.0.0             ” -ForegroundColor Cyan -NoNewline; Write-Host "       [+]" -ForegroundColor Yellow -BackgroundColor red;
Write-Host "[+]   " -ForegroundColor Yellow -BackgroundColor Red -NoNewline; Write-Host “               Date : 15.Sep.2025            ” -ForegroundColor Cyan -NoNewline; Write-Host "       [+]" -ForegroundColor Yellow -BackgroundColor red;
Write-Host "[+]   " -ForegroundColor Yellow -BackgroundColor Red -NoNewline; Write-Host “             By D@rkshadow Myanmar           ” -ForegroundColor White -NoNewline; Write-Host "       [+]" -ForegroundColor Yellow -BackgroundColor red;
Write-Host "[+]                                                       [+]" -ForegroundColor Yellow -BackgroundColor red
Write-Host "[+]+++++++++++++++++++++++++++++++++++++++++++++++++++++++[+]" -ForegroundColor Yellow -BackgroundColor red
Write-Host 
# Test 1: Basic dots
function Show-Preparing {
	Write-Host "`n[ ~~~~~~~~~~~~~~~~~~~~Preparing~~~~~~~~~~~~~~~~~~~~ ]" -ForegroundColor Yellow
	Write-Host "`n[ Loading" -NoNewline	-ForegroundColor Green
	for ($i = 0; $i -lt 10; $i++) {
    	 Write-Host "." -NoNewline
    	Start-Sleep -Milliseconds 400
	}
	Write-Host " ]" -ForegroundColor Green
}

 # Test 2: Spinner
function Show-Searching {
	Write-Host "`nSearching ..." -ForegroundColor Yellow
	$spinner = @('|', '/', '-', '\')
	for ($i = 0; $i -lt 12; $i++) {
    	Write-Host "`rProcessing $($spinner[$i % 4])" -NoNewline -ForegroundColor Cyan
    	Start-Sleep -Milliseconds 100
	}
	Write-Host "`rProcessing complete!   " -ForegroundColor Green
}

# Test 3: Progress bar
function Show-ProgressBar {
	Write-Host "`nProcessing..." -ForegroundColor Yellow
	# $total = 15
 	$total = 35
	for ($i = 0; $i -le $total; $i++) {
	    $percent = [math]::Round(($i / $total) * 100)
	    Write-Host "`rProgress: [$('#' * $i)$(' ' * ($total - $i))] $percent%" -NoNewline -ForegroundColor Yellow
	    Start-Sleep -Milliseconds 50
	}
	Write-Host "`rProgress: [###################################] 100%   " -ForegroundColor Green
}
# End Animations----------------------------------------------------------------------------------------------
# Start Fatch and process 
<# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser #>
$githubUrl = "https://raw.githubusercontent.com/Darkshadow2019/Uapplist/refs/heads/main/applist.txt"
function Get-AppListFromGitHub {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    Write-Host "`n~~~Fetching application list~~~" -ForegroundColor Cyan
	

    try {
        <# # Fetch content from the provided raw URL. #>
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
        $appList = $response.Content.Split("`n") | Where-Object { $_ -ne "" }
        
        Write-Host "Found $($appList.Count) applications in the list." -ForegroundColor Green
        return $appList
    }
    catch {
        Write-Host "An error occurred while fetching the list: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}
# Find installed applications using Registry  
function Search-App {
    param([string]$appName)
    
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $foundApps = @()
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $apps = Get-ItemProperty $path | 
                   Where-Object { $_.DisplayName -like "*$appName*" } |
                   Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation
            $foundApps += $apps
        }
    }
    
    return $foundApps
}

# Main -----------------------------------------------------------------------------------
Show-Preparing
$appsToProcess = Get-AppListFromGitHub -Url $githubUrl
if ($null -ne $appsToProcess) {
	[string]$AppName
	foreach ($appName in $appsToProcess) {
   		# Write-Host "`n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" -ForegroundColor Yellow
	 	Show-Searching
        Write-Host "`n[ Application Name : $appName ]" -ForegroundColor Yellow
		$searchResult = Search-App -appName $appName
		if ($searchResult) {
			$searchResult | Format-Table DisplayName, DisplayVersion, Publisher
	 		Show-ProgressBar
			# [SilentAppRemover]::RemoveApplication("ApplicationName")
	 		$uni=Import-GitHubModuleAdvanced -Owner "Darkshadow2019" -Repo "Uapplist" -Path "Helper/Tools/uin.psm1" -Branch "main"
	 		$uni.[SilentAppRemover]::RemoveApplication($appName)
		} else {
			Write-Host "[ $AppName not found !!! ]" -ForegroundColor Red
		}
  		Write-Host "`n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" -ForegroundColor Yellow
    }
}

Write-Host "`nScript execution complete." -ForegroundColor Green
Write-Host "`n[ ~~~~~~~~~~~~~~~~~~~~~~~~~~Done~~~~~~~~~~~~~~~~~~~~~~~~~~ ]" -ForegroundColor Yellow

# Show About
Import-GitHubModuleAdvanced -Owner "Darkshadow2019" -Repo "Uapplist" -Path "Helper/Menu/about.psm1" -Branch "main"
#wait press any key to continue
 # Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
 
