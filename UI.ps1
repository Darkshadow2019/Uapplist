Set-ExecutionPolicy Bypass -Scope Process -Force;
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# UAC Accept ---------------------------------------------------------------------
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

# After rights 
Write-Host "✅ Running with administrator privileges!" -ForegroundColor Green

# Adding Tools -------------------------------------------------------------------
function Get-Version {
    # Use Write-Host only to display clear text on the console.
    Write-Host
    Write-Host "  ~~~~~ GithubModuleAPI ~~~~~" -ForegroundColor White
    Write-Host "    Version    :   1.0.0.1" -ForegroundColor Cyan
    Write-Host "    developer  :   D@rkshadow" -ForegroundColor Cyan
    Write-Host "    release    :   16.9.2025" -ForegroundColor Cyan
}

function Import-GitModule {
    # Use CmdletBinding() and Mandatory parameters to make the script more robust.
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Owner,
        [Parameter(Mandatory=$true)]
        [string]$Repo,
        [Parameter(Mandatory=$true)]
        [string]$FolderPath
    )

    # Define the necessary headers for the API request.
    $headers = @{
        'Accept' = 'application/vnd.github.v3+json'
        'User-Agent' = 'PowerShell Script'
    }

    # Build the API URL without the branch.
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/contents/$FolderPath"
    
    # Create a temporary directory to download modules.
    $tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP -ChildPath "GitHubModules-$(Get-Random)") -Force -ErrorAction Stop

    try {
        Write-Host "🔍 Searching modules for import..." -ForegroundColor Yellow
        # Write-Host "API URL being used: $apiUrl" -ForegroundColor Gray
        
        # Get the folder contents from the GitHub API.
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ErrorAction Stop
        
        # Filter for .psm1 files.
        $moduleFiles = $response | Where-Object { $_.name -like "*.psm1" }
        
        if (-not $moduleFiles) {
            # Write-Host "❌ No .psm1 files found, cannot proceed." -ForegroundColor Red
            return $false
        }
        
        # Write-Host "✅ Found $($moduleFiles.Count) module files:" -ForegroundColor Green
        $moduleFiles | ForEach-Object { Write-Host "• $($_.name)" -ForegroundColor Cyan }
        
        # Download and import each module.
        foreach ($moduleFile in $moduleFiles) {
            $downloadUrl = $moduleFile.download_url
            $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($moduleFile.name)
            
            try {
                # Write-Host "📥 Downloading $($moduleFile.name)..." -ForegroundColor Yellow
                
                # Download module content and save it as a temporary file.
                $moduleContent = Invoke-RestMethod -Uri $downloadUrl -ErrorAction Stop
                $tempFile = Join-Path $tempDir "$($moduleFile.name)"
                $moduleContent | Out-File -FilePath $tempFile -Encoding UTF8 -ErrorAction Stop
                
                # Import the module.
                Import-Module -Name $tempFile -Force -ErrorAction Stop
                # Write-Host "✅ Successfully imported: $moduleName" -ForegroundColor Green
				 Write-Host "✅ Successfully module imported" -ForegroundColor Green
            } catch {
                # This will catch errors during the download or saving of the file.
                # Write-Host "⚠️ Warning: Could not download or import $moduleName." -ForegroundColor Yellow
                # Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
				Write-Host "⚠️ Warning: Could not import module" -ForegroundColor Yellow
            }
        }
        # The typo has been correctly fixed.
        return $true
    } catch {
        # This will catch errors from the initial API call.
        # Write-Host "❌ Initial GitHub API error: $($_.Exception.Message)" -ForegroundColor Red
		Write-Host "❌ Initial API error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        # The temporary directory will always be cleaned up whether the script finishes or an error occurs.
        if (Test-Path $tempDir) {
            # Write-Host "Cleaning up temporary directory..."
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

# The following code is an example of how to call the function correctly.
# Remove the <# #> comments to run this code directly.

# Call the function to import modules.
Import-GitModule -Owner "Darkshadow2019" -Repo "Uapplist" -FolderPath "Helper/Tools"
# End About module add------------------------------------------------------------

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
Get-Date
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
   			#gni-start
	  		Show-ProgressBar
	  		Remove-Application($appName)

	  		
		} else {
			Write-Host "[ $AppName not found !!! ]" -ForegroundColor Red
		}
  		Write-Host "`n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" -ForegroundColor Yellow
    }
}

Write-Host "`nScript execution complete." -ForegroundColor Green
Write-Host "`n[ ~~~~~~~~~~~~~~~~~~~~~~~~~~Done~~~~~~~~~~~~~~~~~~~~~~~~~~ ]" -ForegroundColor Yellow

# Object Get-Version call method 
Import-GitModule -Owner "Darkshadow2019" -Repo "Uapplist" -FolderPath "Helper/Menu/about.psm1"
#wait press any key to continue
# Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
 
