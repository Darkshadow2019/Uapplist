Set-ExecutionPolicy Bypass -Scope Process -Force;
Clear-Host;
Write-Host; Write-Host

# Test 1: Basic dots
function Show-Preparing {
	Write-Host "`n[ ~~~~~~~~~~~~~~~~~~~~Preparing~~~~~~~~~~~~~~~~~~~~ ]" -ForegroundColor Yellow
	Write-Host "`n[ Loading" -NoNewline	-ForegroundColor Green
	for ($i = 0; $i -lt 20; $i++) {
    	 Write-Host "." -NoNewline
    	Start-Sleep -Milliseconds 500
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
	$total = 15
	for ($i = 0; $i -le $total; $i++) {
	    $percent = [math]::Round(($i / $total) * 100)
	    Write-Host "`rProgress: [$('#' * $i)$(' ' * ($total - $i))] $percent%" -NoNewline -ForegroundColor Yellow
	    Start-Sleep -Milliseconds 50
	}
	Write-Host "`rProgress: [###############] 100%   " -ForegroundColor Green
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

    Write-Host "`nFetching application list By D@rkshadow Myanmar" -ForegroundColor Cyan
	

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
Show-ProgressBar
if ($null -ne $appsToProcess) {
	[string]$AppName
	foreach ($appName in $appsToProcess) {
 		Show-Searching
        Write-Host "`nApplication : $appName" -ForegroundColor Yellow
		$searchResult = Search-App -appName $appName
		if ($searchResult) {
			$searchResult | Format-Table DisplayName, DisplayVersion, Publisher
		} else {
			Write-Host "$AppName not found !!!" -ForegroundColor Red
		}
    }
}

Write-Host "`nScript execution complete." -ForegroundColor Green
Write-Host;
Write-Host "`n[ ~~~~~~~~~~~~~~~~~~~~Done~~~~~~~~~~~~~~~~~~~~ ]" -ForegroundColor Yellow
 #wait press any key to continue
 Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
