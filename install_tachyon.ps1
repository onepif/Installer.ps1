<#
=============================================================================
	./install_tachyon.ps1
=============================================================================
.Description
	The install script for soft @Tachyon.
	For the correct operation of the script must be run with administrator privileges

	Developer Dmitriy L. Ivanov aka onepif
	JSC PELENG 2020
	All rights reserved
#>

CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="

# Настройка правил Брандмауэра Windows для работы с табло...
Set-Rules 5520 5522

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install soft environment" -cr

#if( [Environment]::Is64BitOperatingSystem ){ $fNAME="vcredist_x64_2015sp3.exe" } else { $fNAME="vcredist_x86_2015sp3.exe" }
$fNAME="vcredist_x86_2015sp3.exe"
if( Test-Path -Path $SOFT_ENV\$fNAME ){ & $SOFT_ENV\$fNAME /q *>$null } else {
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "$SOFT_ENV\$fNAME not found!" -cr
}

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install Tachyon base pack... "

if( Test-Path -Path $SOFT_INST\tachyon\Base.zip ) {
	if( !(Test-Path -Path $Data.PATH_PELENG) ) { New-Item -type Directory -Path $Data.PATH_PELENG -Force *>$null }
	Expand-Archive -LiteralPath $SOFT_INST\tachyon\base.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){
		CMD_Ok

		if( [Environment]::Is64BitOperatingSystem ){ $Dest = "$env:WINDIR\sysWOW64" } else { $Dest = "$env:WINDIR\system32" }
		Move-Item -Path "$($Data.PATH_PELENG)\*.dll" -Destination $Dest -Force *>$null
		if( $? ){ CMD_OkCr } else { CMD_ErrCr }
	} else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\tachyon\Base.zip not found" -cr
}

$Version = $jsonCFG.TACHYON.version
if( !$Force ){
	Write-Host
	$var = Read-Host "Specify the build number of software for installation, Release.[ $Version ]"
	if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Version = $var } }
}
CMD_Dbg 2 $MyInvocation.MyCommand.Name "Version=$Version"

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install Tachyon Release pack... "
if( Test-Path -Path $SOFT_INST\tachyon\Release.$Version.zip ) {
	Expand-Archive -LiteralPath $SOFT_INST\tachyon\Release.$Version.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){ CMD_OkCr } else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\tachyon\Release.$Version.zip not found" -cr
}

$Version = $jsonCFG.TACHYON.version_snd
if( !$Force ){
	Write-Host
	$var = Read-Host "Specify the build number of sound for installation, Sound.[ $Version ]"
	if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Version = $var } }
}
CMD_Dbg 2 $MyInvocation.MyCommand.Name "Version=$Version"

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install Tachyon Sound pack... "
if( Test-Path -Path $SOFT_INST\tachyon\Sound.$Version.zip ) {
	Expand-Archive -LiteralPath $SOFT_INST\tachyon\Sound.$Version.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){ CMD_OkCr } else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\tachyon\Sound.$Version.zip not found" -cr
}

if( !$Force ){
	Write-Host
	choice /c ynq /n /m "Install VGrabber? [y/n]: "
	if( $LASTEXITCODE -eq 3 ){ Work-Int } elseif( $LASTEXITCODE -eq 1 ) { .\install_vg.ps1 }
} elseif( $FLAG_VG -eq $true ){ .\install_vg.ps1 }

CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
