<#
=============================================================================
	./install_is.ps1
=============================================================================
.Description
	The install script for soft @RTS.
	For the correct operation of the script must be run with administrator privileges

	Developer Dmitriy L. Ivanov aka onepif
	JSC PELENG 2020
	All rights reserved
#>

CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install soft environment" -cr

if( [Environment]::Is64BitOperatingSystem ){ $fNAME="vcredist_x64_2008sp1.exe" } else { $fNAME="vcredist_x86_2008sp1.exe" }

if( Test-Path -Path $SOFT_ENV\$fNAME ){ & $SOFT_ENV\$fNAME /q *>$null } else {
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "$SOFT_ENV\$fNAME not found!" -cr
}

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install IS base pack... "

if( Test-Path -Path $SOFT_INST\is\base.zip ) {
	if( !(Test-Path -Path $Data.PATH_PELENG) ) { New-Item -type Directory -Path $Data.PATH_PELENG -Force *>$null }
	Expand-Archive -LiteralPath $SOFT_INST\rts\base.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){
		CMD_Ok

		if( [Environment]::Is64BitOperatingSystem ){ $Dest = "$env:WINDIR\system32" } else { $Dest = "$env:WINDIR\sysWOW64" }
		Move-Item -Path "$($Data.PATH_PELENG)\*.dll" -Destination $Dest -Force *>$null
		if( $? ){ CMD_OkCr } else { CMD_ErrCr }
	} else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\is\base.zip not found" -cr
}

$Version = $jsonCFG.Server.Version
if( !$Force ){
	Write-Host
	$var = Read-Host "Specify the build number of software for installation, Release.[ $Version ]"
	if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Version = $var } }
}
CMD_Dbg 2 $MyInvocation.MyCommand.Name "Version=$Version"

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install IS Release pack... "
if( Test-Path -Path $SOFT_INST\is\Release.$Version.zip ) {
	Expand-Archive -LiteralPath $SOFT_INST\is\Release.$Version.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){ CMD_OkCr } else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\rts\Release.$Version.zip not found" -cr
}

CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
