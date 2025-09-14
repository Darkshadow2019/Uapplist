Set-ExecutionPolicy Bypass -Scope Process -Force;
Clear-Host;
Write-Host; Write-Host

function Show-ProgressAnimation {
    $total = 30
    for ($i = 0; $i -le $total; $i++) {
        $percent = ($i / $total) * 100
        $progressBar = "[" + ("#" * $i) + (" " * ($total - $i)) + "]"
        
        Write-Host "`r$progressBar $percent% Complete" -NoNewline -ForegroundColor Yellow
        Start-Sleep -Milliseconds 100
    }
    Write-Host "`r" + (" " * 50) -NoNewline
    Write-Host "`r✅ Process Completed!" -ForegroundColor Green
}

Show-ProgressAnimation

function Show-SimpleAnimation {
    $dots = 10
    for ($i = 1; $i -le $dots; $i++) {
        # Use carriage return for same-line updates
        Write-Host "`rLoading: $("." * $i)$(" " * ($dots - $i))" -NoNewline -ForegroundColor Yellow
        Start-Sleep -Milliseconds 200
    }
    Write-Host "`rLoading : Complete!   " -ForegroundColor Green
}

Show-SimpleAnimation
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
