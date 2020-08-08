<#
=============================================================================
	./install_master.ps1
=============================================================================
.Description
	The install script for soft @Master.
	For the correct operation of the script must be run with administrator privileges

	Developer Dmitriy L. Ivanov aka onepif
	JSC PELENG 2020
	All rights reserved
#>

CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="
if( !$xmlCFG ) { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "not found XML files: CFG!" -cr; Work-Int }

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install soft environment" -cr

$fNAME="vcredist_x86_2008sp1.exe"

if( Test-Path -Path $SOFT_ENV\$fNAME ){ & $SOFT_ENV\$fNAME /q *>$null } else {
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "$SOFT_ENV\$fNAME not found!" -cr
}

#& sc query OracleXETNSListener *>$null
#if( $LASTEXITCODE -eq 1060 ){
if( !(Get-Service |Where-Object {$_.Name -eq "OracleXETNSListener"}) ){
	$fNAME = "OracleXE112_Win_x86"
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Unpacking $fNAME... "
	if( Test-Path -Path $SOFT_ENV\$fNAME.zip ){
		Expand-Archive -LiteralPath $SOFT_ENV\$fNAME.zip -Destination "$($Data.TMP)" -Force
		if( $? ){
			CMD_OkCr
			if( Test-Path -Path C:\oraclexe ) { Remove-Item -Recurse -Path C:\oraclexe }
			Set-Content -Path "$($Data.TMP)\DISK1\response\OracleXE-install.iss" -Value ((Get-Content "$($Data.TMP)\DISK1\response\OracleXE-install.iss") -Replace "SYSPassword=.*", "SYSPassword=password")
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Run install OracleXE Database in parallel process" -cr
			Remove-Item -Path "$($Data.TMP)\DISK1\setup.log" *>$null
#			Start-Process PowerShell { mode con:cols=30 lines=2; "Install OracleXE dyatabase..."; & $($Data.TMP)\DISK1\setup.exe /S -f1"$($Data.TMP)\DISK1\response\OracleXE-install.iss" }
			& $Data.TMP\DISK1\setup.exe /S -f1"$($Data.TMP)\DISK1\response\OracleXE-install.iss"
		} else {
			CMD_ErrCr
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
		}
	} else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Not found file $fNAME.zip" -cr
	}
} else {
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t w -m "OracleXE database allready installed" -cr
	$FLAG_INST_ORACLE = $true
}

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install Master base pack... "

if( Test-Path -Path $SOFT_INST\master\Base.zip ) {
	if( !(Test-Path -Path $Data.PATH_PELENG) ) { New-Item -type Directory -Path $Data.PATH_PELENG -Force *>$null }
	Expand-Archive -LiteralPath $SOFT_INST\master\base.zip -Destination "$($Data.PATH_PELENG)" -Force
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
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\master\Base.zip not found" -cr
}

$Version = $jsonCFG.MASTER.version
if( !$Force ){
	Write-Host
	$var = Read-Host "Specify the build number of software for installation, Release.[ $Version ]"
	if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Version = $var } }
}
CMD_Dbg 2 $MyInvocation.MyCommand.Name "Version=$Version"

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install Master Release pack... "
if( Test-Path -Path $SOFT_INST\master\Release.$Version.zip ) {
	Expand-Archive -LiteralPath $SOFT_INST\master\Release.$Version.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){ CMD_OkCr } else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\master\Release.$Version.zip not found" -cr
}

$Sound = $jsonCFG.MASTER.sound
if( !$Force ){
	Write-Host
	"Specify the sound scheme:"; "  Notify - 1"; "  Ivona  - 2"; "  Valera - 3"
	choice /c 123q /n /m "?: "
	$Sound = $LASTEXITCODE
	if( $Sound -eq 4 ){ Work-Int }
}

Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Sound scheme unpacking... "

if( Test-Path -Path $SOFT_INST\master\Sound.zip ) {
	Expand-Archive -LiteralPath $SOFT_INST\master\Sound.zip -Destination "$($Data.PATH_PELENG)" -Force
	if( $? ){
		CMD_OkCr
		Switch( $Sound ){
			"1" { $name_sheme = "Notify"; Break }
			"2" { $name_sheme = "Ivona"; Break }
			Default { $name_sheme = "Valera" }
		}
		CMD_Dbg 2 $MyInvocation.MyCommand.Name "Choice sheme $name_sheme"
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Sound sheme '$name_sheme' [code: $Sound] copy... "
		Move-Item -Path "$($Data.PATH_PELENG)\wav\wav_${name_sheme}\*.wav" -Destination "$($Data.PATH_PELENG)" -Force *>$null
		if( $? ){ CMD_Ok } else { CMD_Err }
		Remove-Item -Recurse -Path "$($Data.PATH_PELENG)\wav" -Force *>$null
		if( $? ){ CMD_OkCr } else { CMD_ErrCr }
	} else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
	}
} else {
	$CMD_ErrCr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\master\Sound.zip not found" -cr
}

$GLOBAL:FLAG_HOTR = $jsonCFG.MASTER.hot_reserv
if( !$Force ){
	Write-Host
	choice /c ynq /n /m "Install 'Hot Reserv'? [y/n]: "
	if( $LASTEXITCODE -eq 3 ){ Work-Int } elseif( $LASTEXITCODE -eq 2 ) { $GLOBAL:FLAG_HOTR = $false } else { $GLOBAL:FLAG_HOTR = $true }
}
CMD_Dbg 2 $MyInvocation.MyCommand.Name "FLAG_HOTR=$FLAG_HOTR"

if( $FLAG_HOTR -eq $true ) {
	$IP_DBL_BLOCK = $($([int]$ip_base+1) + $($($BLOCK+2)%2))
	CMD_Dbg 2 $MyInvocation.MyCommand.Name "ip_base=$ip_base; BLOCK=$BLOCK; IP_DBL_BLOCK=$IP_DBL_BLOCK"

	$GLOBAL:pDBS = $jsonCFG.DBSYNC.path_to_install
	if( !$Force ){
		Write-Host
		$var = Read-Host "Specify the folder name for install DBsync [ $pDBS ]"
		if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $GLOBAL:pDBS = $var } }
	}
	CMD_Dbg 2 $MyInvocation.MyCommand.Name "pDBS=$pDBS"

	$Version = $jsonCFG.DBSYNC.version
	if( !$Force ){
		Write-Host
		$var = Read-Host "Specify the build number of DBsync.[ $Version ]"
		if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Version = $var } }
	}
	CMD_Dbg 2 $MyInvocation.MyCommand.Name "Version=$Version"

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "DBsync copy... "
	if( Test-Path -Path $SOFT_INST\master\DBsync.$version.zip ) {
		if( !(Test-Path -Path $pDBS) ) { New-Item -type Directory -Path $pDBS -Force }
		Expand-Archive -LiteralPath $SOFT_INST\master\DBsync.$Version.zip -Destination "$pDBS" -Force
		if( $? ){
			CMD_OkCr
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Run command sed for editing config.xml... "
			$xmlDBS = (Get-Content $pDBS\config.xml -Encoding UTF8) -Replace "<Connect2>.*", "<Connect2>DRIVER=Microsoft ODBC for Oracle;DSN=;UID=aero;PWD=aero;Server=$subNET.$stepNET.$IP_DBL_BLOCK/xe</Connect2>"
			Set-Content -Path $pDBS\config.xml -Value $xmlDBS
			if( $? ){ CMD_OkCr } else { CMD_ErrCr }
		} else {
			CMD_ErrCr
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
		}
	} else {
		CMD_ErrCr
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "File $SOFT_INST\master\DBsync.$version.zip not found" -cr
	}
} else { Remove-Variable FLAG_HOTR -Force }

if( !$Force ){
	Write-Host
	choice /c ynq /n /m "Install VGrabber? [y/n]: "
	if( $LASTEXITCODE -eq 3 ){ Work-Int } elseif( $LASTEXITCODE -eq 1 ) { .\install_vg.ps1 }
} elseif( $jsonCFG.MASTER.install_vg -eq $true ){ .\install_vg.ps1 }

CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
