<#
=============================================================================
	./install_armv.ps1
=============================================================================
.Description
	The install script for soft @SMAR-T [ARMv].
	For the correct operation of the script must be run with administrator privileges

	Developer Dmitriy L. Ivanov aka onepif
	JSC PELENG 2020
	All rights reserved
#>

CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="

$Version = $jsonCFG.SMART.Player3.version
if( !$Force ){
	Write-Host
	$var = Read-Host "Specify the build number of software for installation, setup_armv_[ $Version ]"
	if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Version = $var } }
}
CMD_Dbg 2 $MyInvocation.MyCommand.Name "Version=$Version"

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install ARMv... "
if( Test-Path -Path $SOFT_INST\smar-t\setup_armv_$Version.zip ) {
	Expand-Archive -LiteralPath $SOFT_INST\smar-t\setup_armv_$Version.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){ CMD_OkCr } else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} elseif( Test-Path -Path $SOFT_INST\smar-t\setup_armv_$Version.exe ) {
	& "$SOFT_INST\smar-t\setup_armv_$Version.exe"
	Wait-Process setup_armv_$Version
	CMD_DnCr
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\smar-t\setup_armv_$Version.zip[exe] not found" -cr
}

<#		set /a var1=%ip_base%+1
		set /a var2=%ip_base%+2

		if exist "%PATH_PELENG%"/config.ini (
			sed -i /"size=0"/d "%PATH_PELENG%"/config.ini
			sed -i s/"\[paths\]"/"[paths]\nsize=2\n1\\path=\/\/%subNET%.%stepNET%.!var1!\/Signals\n1\\islast=false\n2\\path=\/\/%subNET%.%stepNET%.!var2!\/Signals\n2\\islast=false\n"/ "%PATH_PELENG%"/config.ini
		) else (
			echo [paths]>"%PATH_PELENG%"/config.ini
			echo size=^2>>"%PATH_PELENG%"/config.ini
			echo 1\path=//%subNET%.%stepNET%.!var1!/Signals>>"%PATH_PELENG%"/config.ini
			echo 1\islast=false>>"%PATH_PELENG%"/config.ini
			echo 2\path=//%subNET%.%stepNET%.!var2!/Signals>>"%PATH_PELENG%"/config.ini
			echo 2\islast=false>>"%PATH_PELENG%"/config.ini
		)
#>

CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
