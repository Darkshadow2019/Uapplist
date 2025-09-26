# Gni Version 
function Gni-Version {
    # Use Write-Host only to display clear text on the console.
    Write-Host
    Write-Host " ~~~~~~~~~ Gni Tool ~~~~~~~~~" -ForegroundColor White
    Write-Host " Uninstaller Tool for windows"-ForegroundColor Yellow
    Write-Host "    Version    :   1.0.0.2" -ForegroundColor Cyan
    Write-Host "    developer  :   D@rkshadow Myanmar" -ForegroundColor Cyan
    Write-Host "    release    :   16.9.2025" -ForegroundColor Cyan
}

# =========================================================
# === Function to get application list from GitHub ===
# =========================================================
function Get-AppListFromGitHub {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    Write-Host "Fetching application list from GitHub..." -ForegroundColor Cyan

    try {
        # Fetch content from the provided raw URL.
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
# =========================================================
# === Task Kill Process ===
# =========================================================
function gni-KillTask {
	$ProcessName = "chrome"
	$DirectoryPath = "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data"
	Write-Host "Searching for application '$ProcessName'..." -ForegroundColor Cyan
	
	try{
		$Process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
		if ($Process) {
			Write-Host "$ProcessName process found ..... " -ForegroundColor Green
			Stop-Process -Name $ProcessName -Force 
			if (-not (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue)) {
				Write-Host "$ProcessName process stopped." -ForegroundColor Yellow			
			} else {
				Write-Host "$ProcessName process failed!" -ForegroundColor Red
			}
		} else {
			Write-Host "$ProcessName Task List Not Found!" -ForegroundColor Cyan
		}
	}
	catch {
		Write-Host "An error occurred during Taskkill : $($_.Exception.Message)" -ForegroundColor Red
	}

	# Delete Directory 
	if (Test-Path -Path $DirectoryPath -PathType Container) {
    	Write-Host "Directory : $DirectoryPath" -ForegroundColor Yellow
		Remove-Item -Path $DirectoryPath -Recurse -Force
		if (-not (Test-Path -Path $DirectoryPath)) {
			Write-Host "Directory Clean Successful!" -ForegroundColor Green
		} else {
			Write-Host "Directory Clean Failed!" -ForegroundColor Red
		}
	} else {
		Write-Host "Directory not Found ! : $DirectoryPath" -ForegroundColor Cyan
	}
}

# =========================================================
# === Uninstall Application ===
# =========================================================
function Uninstall-App {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    Write-Host "Searching for application '$Name'..." -ForegroundColor Cyan

    try {
        # Check if the app exists using Get-Package
        $app = Get-Package -Name "*$Name*" -ErrorAction SilentlyContinue

        if ($null -ne $app) {
            Write-Host "Found application: $($app.Name)" -ForegroundColor Green
            Write-Host "Starting uninstallation process..." -ForegroundColor Yellow
            
            # Use Uninstall-Package for a clean uninstall
            Uninstall-Package -Name $app.Name -Force -Verbose | Out-Null
            
            Write-Host "Uninstallation for '$($app.Name)' initiated." -ForegroundColor Green
            Write-Host "Please wait for any pop-up windows from the installer to finish." -ForegroundColor Yellow
        } else {
            Write-Host "Application '$Name' was not found. Skipping uninstallation." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "An error occurred during uninstallation: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =========================================================
# === Main Script Execution ===
# =========================================================

function gni-start{
	gni-KillTask
	# Check for administrator privileges
	<#if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Write-Host "This script must be run with administrator privileges. Exiting..." -ForegroundColor Red
		exit
	}#>
    $githubUrl = "https://raw.githubusercontent.com/Darkshadow2019/Uapplist/refs/heads/main/applist.txt"

	# Fetch the list of applications from the GitHub URL.
	$appsToProcess = Get-AppListFromGitHub -Url $githubUrl

	if ($null -ne $appsToProcess) {
		# Loop through each application name and run the uninstall and block functions.
		foreach ($appName in $appsToProcess) {
			Write-Host "`nProcessing application: $appName" -ForegroundColor Yellow
			Uninstall-App -Name $appName
		}
	}

	Write-Host "`nScript execution complete." -ForegroundColor Green
}


