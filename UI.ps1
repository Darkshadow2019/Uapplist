Set-ExecutionPolicy Bypass -Scope Process -Force;

function Show-CompleteMenuSystem {
    param(
        [string]$UserName = $env:USERNAME
    )
    
    do {
        Clear-Host
        $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Header with user info
        Write-Host "`n"
        Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Blue
        Write-Host "║                                                  ║" -ForegroundColor Blue
        Write-Host "║           POWER SHELL MANAGEMENT SUITE           ║" -ForegroundColor Yellow
        Write-Host "║                                                  ║" -ForegroundColor Blue
        Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Blue
        Write-Host "║ User: $($UserName.PadRight(25)) Time: $currentTime ║" -ForegroundColor White
        Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Blue
        
        # Menu Options
        $menuOptions = @(
            "📊 System Information",
            "🔧 System Utilities",
            "🌐 Network Tools",
            "📁 File Management",
            "🛡️  Security Center",
            "⚙️  Settings",
            "❌ Exit"
        )
        
        for ($i = 0; $i -lt $menuOptions.Count; $i++) {
            $option = $menuOptions[$i]
            Write-Host ("║ {0}. {1}" -f ($i + 1), $option.PadRight(45)) -ForegroundColor Green -NoNewline
            Write-Host " ║" -ForegroundColor Blue
        }
        
        Write-Host "║                                                  ║" -ForegroundColor Blue
        Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Blue
        
        # User input
        Write-Host "`n"
        $choice = Read-Host "ကျေးဇူးပြု၍ ရွေးချယ်ပါ (1-$($menuOptions.Count)) "
        
        # Process selection
        switch ($choice) {
            '1' { Write-Host "System Information selected" -ForegroundColor Cyan }
            '2' { Write-Host "System Utilities selected" -ForegroundColor Cyan }
            '3' { Write-Host "Network Tools selected" -ForegroundColor Cyan }
            '4' { Write-Host "File Management selected" -ForegroundColor Cyan }
            '5' { Write-Host "Security Center selected" -ForegroundColor Cyan }
            '6' { Write-Host "Settings selected" -ForegroundColor Cyan }
            '7' { 
                Write-Host "ကျေးဇူးတင်ပါသည်! ထွက်မည်..." -ForegroundColor Red
                Start-Sleep -Seconds 2
                break 
            }
            default { 
                Write-Host "မှားယွင်းသောရွေးချယ်မှု! ကျေးဇူးပြု၍ ထပ်ကြိုးစားပါ။" -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
        
        if ($choice -ne '7') {
            Write-Host "`nEnter နှိပ်ပါ ဆက်လက်ရန်..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
    } while ($choice -ne '7')
}
Show-CompleteMenuSystem -UserName "YourName"
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
