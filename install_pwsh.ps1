$SOFT_ENV = "$(Split-Path -Path $(Split-Path -Path $MyInvocation.MyCommand.Path))\soft_environment"

# Install Powershell
#	Expand-Archive -LiteralPath $SOFT_ENV\sys\pwsh\WindowsUCRT.zip -Destination "$jsonCFG.Tmp" -Force
if( [Environment]::Is64BitOperatingSystem ){
#	& $jsonCFG.Tmp\Windows6.1-KB3118401-x64.msu /quiet /norestart	# Install WindowsUCRT
	& $SOFT_ENV\sys\pwsh\PowerShell-7.0.3-win-x64.msi /q
} else {
#	& $jsonCFG.Tmp\Windows6.1-KB3118401-x86.msu /quiet /norestart	# Install WindowsUCRT
	& $SOFT_ENV\sys\pwsh\PowerShell-7.0.3-win-x86.msi /q
}
