$SOFT_ENV = "$(Split-Path -Path $(Split-Path -Path $MyInvocation.MyCommand.Path))\soft_environment"

if( (Get-Host).Version.Major -eq 2 ){
# Install .NET 4.5.2
	$Name = "NDP452-KB2901907-x86-x64-AllOS-ENU"
	& $SOFT_ENV\sys\$Name.exe /q /norestart
	"Install .NET: "
	while(Get-Process |where {$_.ProcessName -eq $Name} ){ Write-Host -ForegroundColor Green -noNewLine "."; Start-Sleep 1 }

	$Name = "wusa"
# Install WMF-4.0
	if( [Environment]::Is64BitOperatingSystem ){
		& $SOFT_ENV\sys\pwsh\Windows6.1-KB2819745-x86-MultiPkg.msu /quiet /norestart
	} else {
		& $SOFT_ENV\sys\pwsh\Windows6.1-KB2819745-x64-MultiPkg.msu /quiet /norestart
	}
	"Install WMF-4.0: "
	while(Get-Process |where {$_.ProcessName -eq $Name} ){ Write-Host -ForegroundColor Green -noNewLine "."; Start-Sleep 1 }

# Install WMF-5.1
	& $SOFT_ENV\sys\pwsh\Install-WMF5.1.ps1 -AcceptEULA /norestart
	"Install WMF-5.1: "
	while(Get-Process |where {$_.ProcessName -eq $Name} ){ Write-Host -ForegroundColor Green -noNewLine "."; Start-Sleep 1 }

	shutdown.exe /r /t 1
}
