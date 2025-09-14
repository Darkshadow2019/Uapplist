Set-ExecutionPolicy Bypass -Scope Process -Force; 
<# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser #>
$githubUrl = "https://raw.githubusercontent.com/Darkshadow2019/Uapplist/refs/heads/main/applist.txt"

function Get-AppListFromGitHub {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    Write-Host "Fetching application list By D@rkshadow" -ForegroundColor Cyan

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

#main
$appsToProcess = Get-AppListFromGitHub -Url $githubUrl
if ($null -ne $appsToProcess) {
	[string]$AppName
	foreach ($appName in $appsToProcess) {
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
 #wait press any key to continue
 Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
