# By D@rkshadow
function DLoad {
	param(
    [string]$FileName
	)
	
	try {
		$url = "https://raw.githubusercontent.com/Darkshadow2019/Uapplist/main/Helper/Tools/$FileName"
		$output = "C:\Users\$env:USERNAME\.M\$FileName"
		
		# Create directory if not exists
		$dir = Split-Path $output -Parent
		if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
		
		Invoke-WebRequest -Uri $url -OutFile $output
		Write-Host "✅ Download completed!" -ForegroundColor Green
	} catch {
		Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
	}
}
