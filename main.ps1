<#
.Synopsis
	Скрипт предназначен для настройки рабочей станции (ПК) с предустанвленной OS Windows 7[10] и инсталяции СПО ЗАО "ПЕЛЕНГ".
.Link
	http://www.outsidethebox.ms/18237/
	https://poshgui.com/Editor
	https://remontka.pro/disable-updates-windows-10/
.Description
	В процессе работы скрипта производится конфигурирование OS Windows и установка дополнительного
	програмного обеспечения, необходимого для работы СПО производства ЗАО "ПЕЛЕНГ".
	Предусмотрена интерактивная работа и "тихая" - без запросов, в этом случае используются настройки из файла конфигурации.
.Parameter	Dbg
	<1,2...>
	включить отладочный режим. Будет производится вывод дополнительной информации.
.PARAMETER	FileConfig
	<path\to\file.ext>
	использовать file.ext для конфигурирования процесса установки, если не задан, то ищется файл с именем main.xml.
.PARAMETER	FileLog
	<path\to\file.ext>
	включить режим вывода информации в файл [по умолчанию - $env:PROGRAMDATA\logfiles\install.log].
.PARAMETER	Verbose
	если задан, то включает вывод информации в консоль;
	если не задан, то вывод в консоль будет отключён, при параметрах -Dbg или -GUI не имеет значения. По умолчанию выключен.
.PARAMETER	Id
	<n> установить номер изделия, где n:
		1 - СМАР-Т
		2 - Мастер
		3 - АСК
		4 - Тахион
		5 - Информационный сервер
		6 - Плановый сервер
		7 - ТДК [Блок Связи]
.PARAMETER	Block
	<n> установить номер блока n=1,2...
.PARAMETER	GUI
	разрешить графический интерфейс [GUI]. По умолчанию выбран режим командной строки [CLI].
.PARAMETER	Clear
	сбросить все заданные ранее настройки [флаги] и выполнить скрипт с запросом всех параметров.
.PARAMETER	Force
	подавить все запросы ("тихий" режим).
.Role
	Администратор
.EXAMPLE
	.\main.ps1 -i 2 -b 1 -Force
	будет выполнена "тихая" установка СПО "Мастер" на ПК с назначением ему имени "BOI-1"
.NOTES
	Copyright (C) 2020 Dmitriy L. Ivanov aka onepif
	CJSC PELENG 2020

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#>

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$false)]
	[ValidatePattern("[0-9]")]
	[int]$Dbg,

	[Alias('f')]
	[string]$FileConfig,

	[Parameter(Mandatory=$false)]
	[Alias('o')]
	[string]$FileLog,

	[Parameter(Mandatory=$false)]
	[ValidatePattern("[1-7]")]
	[Alias('i')]
	[Int]$GLOBAL:Id=0,

	[Parameter(Mandatory=$false)]
	[Alias('b')]
	[int]$GLOBAL:Block=0,

	[Parameter(Mandatory=$false)]
	[Switch]$GUI,

	[Parameter(Mandatory=$false)]
	[Alias('cl')]
	[Switch]$Clear,

	[Parameter(Mandatory=$false)]
	[Switch]$Force
)

Set-Location (Split-Path -Path $MyInvocation.MyCommand.Path)

try {
	. .\lib.ps1
	. .\header.ps1
}
catch [system.exception]{ Write-Host "Error while loading supporting PowerShell Scripts"; return -1 }

if( !$FileConfig -or !(Test-Path $FileConfig) ){ $FileConfig = "$(Split-Path -Path $MyInvocation.MyCommand.Path)\$(($MyInvocation.MyCommand.Name).Split(".")[0]).json" }
if( Test-Path $FileConfig ){
	$jsonCFG = (Get-Content $FileConfig -Encoding UTF8|ConvertFrom-JSON)
} else {
	Out-Logging -t e -src Main -m "Not found configuration file!" -cr
	Work-Int
}

Function Check(){
	net user $env:USERNAME /time:all *>$null
	if( $LASTEXITCODE -ne 0 ){
		if( $Args ){ Start-Process .\main.ps1 -Verb RunAs -ArgumentList @Args } else { Start-Process main.ps1 -Verb RunAs }
		Stop-Process $PID
	}

	if( !(Test-Path -Path $Data.TMP) ) { New-Item -type Directory -Path $Data.TMP -Force *>$null }
	if( !(Test-Path -Path (Split-Path $PROFILE)) ) { New-Item -type Directory -Path (Split-Path $PROFILE) -Force *>$null }
}

Function Main(){
	$console = $host.UI.RawUI
	$buffer	= $console.BufferSize;	$buffer.Width	= 140;	$buffer.Height	= 500;	$console.BufferSize = $buffer
	$size	= $console.WindowSize;	$size.Width		= 140;	$size.Height	= 50;	$console.WindowSize = $size

	if( $Clear ){ Remove-Var }

	if( $Dbg -or $GUI ){ $FLAG_CONS = $true } else { $FLAG_CONS = $PSBoundParameters.Verbose }

<#	if( $FileConfig ) {
		if( Test-Path ($FileConfig) ){
			$jsonCFG = (Get-Content $FileConfig -Encoding UTF8|ConvertFrom-JSON)
		}
	} else {
		Out-Logging -t e -src Main -m "Not found configuration file!" -cr
		Work-Int
	}
#>
	if( ! $FileLog ) { $FileLog = $jsonCFG.file_log }
	if( ! (Test-Path -Path (Split-Path -Path $FileLog)) ) { New-Item -type Directory -Path (Split-Path -Path $FileLog) *>$null }
	if( ! $Dbg ) { $Dbg = $jsonCFG.debug }

	.\add_user.ps1
	.\install_tools.ps1

	CMD_DBG 2 $MyInvocation.MyCommand.Name "Force=$Force, Verbose=$Verbose, GUI=$GUI, DEBUG=$Dbg"
	CMD_DBG 2 $MyInvocation.MyCommand.Name "FileConfig=$FileConfig"
	CMD_DBG 2 $MyInvocation.MyCommand.Name "FileLog=$FileLog"

	if( !(Test-Path $PROFILE) ){ 
		Out-Logging -out $FileLog -src Main -m "Copy Microsoft PowerShell profile... "
		try{ Copy-Item ".\Microsoft.PowerShell_profile.ps1" (Split-Path -Path $PROFILE); CMD_OkCr }
		catch{ CMD_ErrCR }
	} else { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t w -m "file '$PROFILE' already exist" -cr }

#	.\add_user.ps1

	$console.WindowTitle = "The initial configuration script Windows and special soft"

	CMD_EMPTY
	Out-Logging -out $FileLog -src Main -m "=============================================================================" -cr
	Out-Logging -out $FileLog -src Main -m "=                            NEW SESSION STARTED                            =" -cr
	Out-Logging -out $FileLog -src Main -m "=============================================================================" -cr

	$LOCALE = (Get-ItemProperty -Path "HKCU:\Control Panel\International" -Name Locale).Locale

	CMD_DBG 2 $MyInvocation.MyCommand.Name "You Locale: $LOCALE"

	if( $ID -and $BLOCK ){ CMD_DBG 2 $MyInvocation.MyCommand.Name "Skip question" } else { .\question.ps1 }
	CMD_DBG 2 $MyInvocation.MyCommand.Name "ID=$ID, BLOCK=$BLOCK, DEVICE=$($Data.DEVICE[$ID-1])"

# запуск суматры для ручного конфигурирования
	if( !($Force) ){ & "$env:PROGRAMFILES\SumatraPDF.exe" }

	$strSID = $(([Security.Principal.WindowsIdentity]::GetCurrent()).User).Value

# del pinned
	Out-Logging -out $FileLog -src Main -m "Removing stitched shortcuts" -cr
	Uninstall-TaskBarPinnedItem -Item "$env:PROGRAMFILES\Internet Explorer\iexplore.exe"
	Uninstall-TaskBarPinnedItem -Item "$env:PROGRAMFILES\Windows Media Player\wmplayer.exe"

	Install-TaskBarPinnedItem -Item "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"

# Настройка правил Брандмауэра Windows для SS и OpenSSH...
	Set-Rules 4086 22

	$subNET = $jsonCFG.subnet
	if( !$Force ){
		Write-Host
		$var = Read-Host "Specify the subNET [ $subNET ]"
		if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $subNET = $var } }
	}

	$stepNET = $jsonCFG.stepnet
	if( !$Force ){
		Write-Host
		$var = Read-Host "Specify the stepNET [ $stepNET ]"
		if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $stepNET = $var } }
	}
	CMD_DBG 2 $MyInvocation.MyCommand.Name "subNet=$subNet, stepNET=$stepNET"

	if( $BLOCK ){
		$ip_base = $jsonCFG.($Data.DEVICE[$ID-1]).ip_base
		if( !$Force ){
			Write-Host
			$var = Read-Host "Specify base IP addresses [ $ip_base ]"
			if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $ip_base = $var } }
		}
		CMD_DBG 2 $MyInvocation.MyCommand.Name "base IP address selected: $ip_base"
	} else { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Variable 'BLOCK' not defined" -cr }

	if( $ID -eq $Data.SMART ){
		if( $BLOCK -ge 11 ){
			Set-PathPeleng -dev $Data.DEV_SMART[8] -def $jsonCFG.SMART.$($Data.DEV_SMART[8]).path_to_install
		} else {
			Set-PathPeleng -dev $Data.DEV_SMART[$BLOCK-1] -def $jsonCFG.SMART.$($Data.DEV_SMART[$BLOCK-1]).path_to_install
		}
	} else {
		Set-PathPeleng -dev $Data.DEVICE[$ID-1] -def $jsonCFG.$($Data.DEVICE[$ID-1]).path_to_install
	}

	if( $ID -ne $Data.TRS ) { if( $WINVER -eq 6 ){ Rename-Lan_Old ($ip_base + $BLOCK) } else { Rename-Lan ($ip_base + $BLOCK) } }

	if( !$Force ){ Set-AsRun } else { Set-AsRun 2 }

	Switch( $ID ){
		 $Data.SMART {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section SMART started"
			Switch( $BLOCK ){
				{ $PSitem -ge 10 }	{ .\install_vg.ps1; Rename-PC "BVZ-$($BLOCK-10)"; Break }
				{ $PSitem -ge 5 }	{ .\install_armv.ps1; Rename-PC "BVI-$($BLOCK-4)"; Break }
				Default				{ .\install_armz.ps1; Rename-PC "BRI-$BLOCK" }
			}
			Break
		}
		$Data.MASTER {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section MASTER started"
		 	Set-Rules 1521 # - Настройка правил Брандмауэра Windows для ORACLE
		 	.\install_master.ps1
		 	Rename-PC "BOI-$BLOCK"
		 	Break
		}
		$Data.RTS {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section RTS started"
			.\install_rts.ps1
			if( $BLOCK -eq 1 ) { Rename-PC BKDI } else { Rename-PC "BKDI-$BLOCK" }
		 	Break
		}
		$Data.TACHYON {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section TACHYON started"
			.\install_tachyon.ps1
		 	Rename-PC "BHS-$BLOCK"
		 	Break
		}
		$Data.IS {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section Server's Information started"
		 	.\install_is.ps1
		 	Rename-PC "BOI-$BLOCK"
		 	Break
		}
		$Data.PS {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section Server's Plane started"
		 	.\install_ps.ps1
		 	Rename-PC "BOI-$BLOCK"
		 	Break
		}
		$Data.TRS {
		 	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section TRS started"
			.\install_trs.ps1
			.\configure_trs.ps1 $BLOCK
		 	Break
		}
		Default { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "No item selected!" -cr; exit -5 }
	}

	CMD_DBG 1 $MyInvocation.MyCommand.Name "Section COMMON started"
 
# активировать учетку гостя. зачем???
#	if( $WINVER -eq 7 ){
#		if( $LOCALE -eq "00000419" ){ net user Гость /active:yes >nul } else { net user Guest /active:yes >nul }
#	}

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Copy SupervisorServer... "
	if( [Environment]::Is64BitOperatingSystem ){ $Dest = "$env:WINDIR\sysWOW64" } else { $Dest = "$env:WINDIR\system32" }
	try{ Copy-Item $SOFT_INST\Supervisor\lib\*.dll $Dest; CMD_Ok }
	catch{ CMD_Err }

	$var =	"$SOFT_INST\Supervisor\bin\Supervisor*.exe",
			"$SOFT_INST\Supervisor\bin\rc.SS.ps1",
			"lib.ps1", "PelengData.json"

	foreach( $ix in $var ){
		try{ Copy-Item $ix $env:WINDIR; CMD_Ok }
		catch{ CMD_Err }
	}
	CMD_Empty

	if( $ID -eq $Data.TRS ){
		$xmlSS = [xml](Get-Content "$($Data.PATH_PELENG)\etc\SS_trs.xml" -Encoding UTF8)
<#
			-Replace "Блок связи,.*, конф.", "Блок связи, $NAME_WS $NUMB_WS, конф."
		foreach( $ix in $xmlSS.root.processes.ChildNodes.Id ){
			if( $ix ){
				$xmlSS.Root.processes.$ix.description = "$($Data.PATH_PELENG)\$($Data.DEVICE[$ID-1]).exe"
				$xmlSS.Root.processes.$ix.visualName = "$($Data.PATH_PELENG)\$($Data.DEVICE[$ID-1]).exe"
			}
		}
#>
		foreach( $ix in $xmlSS.root.processes.ChildNodes.Id ){
			if( $ix ){ $xmlSS.Root.processes.$ix.Path = "$($Data.PATH_PELENG)\$($Data.DEVICE[$ID-1]).exe" }
		}
	} elseif( $ID -eq $Data.SMART ){
		$xmlSS = [xml](Get-Content $SOFT_INST\Supervisor\etc\SupervisorServer.xml -Encoding UTF8)
		if( $BLOCK -lt 10 ){
			$xmlSS.Root.processes.($Data.DEV_SMART[$BLOCK-1]).Path = "$($Data.PATH_PELENG)" + "\" + "$($Data.DEV_SMART[$BLOCK-1])" + ".exe"
		} else {
			$xmlSS.Root.processes.($Data.DEV_SMART[6]).Path = "$($Data.PATH_PELENG)" + "\" + "$($Data.DEV_SMART[6])" + ".exe"
		}
	} else {
		$xmlSS = [xml](Get-Content $SOFT_INST\Supervisor\etc\SupervisorServer.xml -Encoding UTF8)
		$xmlSS.Root.processes.($Data.DEVICE[$ID-1]).Path = "$($Data.PATH_PELENG)" + "\" + "$($Data.DEVICE[$ID-1]).exe"
	}

    Switch( $ID ){
        { ($_ -eq $Data.MASTER) -and $FLAG_HOTR }	{ $xmlSS.Root.Active_Group = "$($Data.DEVICE[$ID-1])HR";	 Break }
        {  $_ -eq $Data.SMART }						{ $xmlSS.Root.Active_Group = "$($Data.DEV_SMART[$BLOCK-1])"; Break }
        Default										{ $xmlSS.Root.Active_Group = "$($Data.DEVICE[$ID-1])" }
    }

	if( $pVG ) { $xmlSS.Root.processes.VGrabber.Path = "$pVG\vgrabber.exe" }

	if( $pDBS ){ $xmlSS.Root.processes.BaseSync.Path = "$pDBS\DBSync.exe" }

	if( $ID -eq $Data.SMART ){
		CMD_DBG 2 $MyInvocation.MyCommand.Name "$($Data.DEV_SMART[$BLOCK-1]) Path: $($xmlSS.Root.processes.($Data.DEV_SMART[$BLOCK-1]).Path)"
	} else {
		CMD_DBG 2 $MyInvocation.MyCommand.Name "$($Data.DEVICE[$ID-1]) Path: $($xmlSS.Root.processes.($Data.DEVICE[$ID-1]).Path)"
	}
	CMD_DBG 2 $MyInvocation.MyCommand.Name "Active_Group: $($xmlSS.Root.Active_Group)"
	CMD_DBG 2 $MyInvocation.MyCommand.Name "VGrabber Path: $($xmlSS.Root.processes.VGrabber.Path)"
	CMD_DBG 2 $MyInvocation.MyCommand.Name "DBSync Path: $($xmlSS.Root.processes.BaseSync.Path)"

	$xmlSS.Save("$env:WINDIR\SupervisorServer.xml")

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Power Setup... "
	if( $WINVER -eq 6){
		powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
	} else { powercfg -setactive $((powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61).Split(" ")[3]) }
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change monitor-timeout-ac 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change monitor-timeout-dc 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change disk-timeout-ac 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change disk-timeout-dc 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change standby-timeout-ac 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change standby-timeout-dc 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change hibernate-timeout-ac 0
	if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
	powercfg -change hibernate-timeout-dc 0
	if( $LASTEXITCODE -eq 0 ){ CMD_OkCr } else { CMD_ErrCr }

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Setting timeout OS to 3 sec... "
	bcdedit /timeout 3 >$null
	if( $? ){ CMD_OkCr } else { CMD_ErrCr }

	if( ($ID -eq $Data.TACHYON) -or (($ID -eq $Data.SMART) -and ($BLOCK -eq 1)) ){
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Time server activating... "
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name "AnnounceFlags" -Value 5
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" -Name "Enabled" -Value 1
		CMD_DnCr
	} else {
		$ip_tm_srv = $jsonCFG.time_servers_ip
		if( !$Force ){
			Write-Host
			$var = Read-Host "Specify the fourth group ip address of the time server [ $ip_tm_srv ]"
			if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $ip_tm_srv = $var } }
		}
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Time synchronization... "
		Set-TimeClt $subNET.$stepNET.$ip_tm_srv $subNET.($stepNET*2).$ip_tm_srv
		CMD_DnCr
	}

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Disable autorun... "
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Cdrom" -Name "AutoRun" -Value 0
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" *>$null
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping" -Name "Autorun.inf" -Value "@SYS:DoesNotExist"
	CMD_DnCr

<#	Узел универсальных PNP-устройств [upnphost]
	Обнаружение SSDP [SSDPSRV]
	Определение оборудования оболочки [ShellHWDetection]
	Доступ к HID-устройствам [hidserv] #>
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Services stop... "
	foreach( $ix in "upnphost", "SSDPSRV", "ShellHWDetection", "hidserv" ){
		if( (Get-Service $ix).Status -eq "Running" ) {
			Set-Service -InputObject $ix -Status Stopped -StartupType Disabled *>$null
			if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
		}
	}
	CMD_Empty

<#	Службы, которые должны работать:
	Центр обеспечения безопасности [wscsvc]
	Брандмауэр Windows [MpsSvc]
	Вторичный вход в систем [seclogon]
	Windows Audio [MMCSS AudioEndpointBuilder Audiosrv] #>
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Services start... "
	foreach( $ix in "wscsvc", "MpsSvc", "seclogon" ){
		if( (Get-Service $ix).Status -eq "Stopped" ) {
			Set-Service -InputObject $ix -Status Running -StartupType Automatic *>$null
			if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
		}
	}
	CMD_Empty

# Настройка правил Брандмауэра Windows для NTP
	Set-Rules 123

# Сетевое обнаружение и RDP
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Setting LAN and RDP... "

<#	"Общий доступ к файлам и принтерам",
	"Обнаружение сети",
	"Дистанционное управление рабочим столом"
	файл с именами служб должен быть в кодировке 1251
#>
	if( $WINVER -eq 6 ){
		foreach( $ix in $(cat service.list) ){ netsh advfirewall firewall set rule group="$ix" new enable=yes *>$null }
	} else {
		foreach	( $ix in @("FPS-*", "NETDIS-*", "RemoteDesktop-*") ){ Set-NetFirewallRule -Name "$ix" -Enabled True -Profile Any }
	}

	Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0
	CMD_DnCr

# Завершение -> Перезагрузка
	Set-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_PowerButtonAction" -Value 4

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Sound off... "
	Set-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\AppEvents\Schemes" -Name "(Default)" -Value ".None"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Value 1
	CMD_DnCr

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Disable auto reboot at crash... "
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\CrashControl" -Name "AutoReboot" -Value 0
	CMD_DnCr

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "UTC setting... "
	tzutil /s UTC
	if( $LASTEXITCODE -eq 0 ){ CMD_OkCr } else { CMD_ErrCr }

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Icons on Desktop... "
	$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
	New-Item -Path $Branch\ClassicStartMenu -Force >$null
	New-ItemProperty -Path "$Branch\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force >$null
	New-ItemProperty -Path "$Branch\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Force >$null
	New-ItemProperty -Path "$Branch\ClassicStartMenu" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 0 -Force >$null
	New-Item -Path $Branch\NewStartPanel -Force >$null
	New-ItemProperty -Path "$Branch\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force >$null
	New-ItemProperty -Path "$Branch\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Force >$null
	New-ItemProperty -Path "$Branch\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 0 -Force >$null
	CMD_DnCr

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Icons in Taskbar and StartMenu... "
	$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	Set-ItemProperty -Path "$Branch" -Name "TaskbarSmallIcons" -Value 1
	Set-ItemProperty -Path "$Branch" -Name "Start_ShowControlPanel" -Value 2
	Set-ItemProperty -Path "$Branch" -Name "Start_NotifyNewApps" -Value 0
	Set-ItemProperty -Path "$Branch" -Name "Start_ShowMyDocs" -Value 0
	Set-ItemProperty -Path "$Branch" -Name "Start_ShowMyGames" -Value 0
	Set-ItemProperty -Path "$Branch" -Name "Start_ShowMyPics" -Value 0
	Set-ItemProperty -Path "$Branch" -Name "Start_ShowRun" -Value 1
	Set-ItemProperty -Path "$Branch" -Name "Start_LargeMFUIcons" -Value 0
	Set-ItemProperty -Path "$Branch" -Name "Start_ShowMyMusic" -Value 0
	CMD_DnCr

	if( $WINVER -eq 10 ){
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Icons in Taskbar and StartMenu in Windows 10... "
		$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
		New-Item -Path $Branch -Force >$null
		New-ItemProperty -Path "$Branch" -Name "ShowTaskViewButton" -Value 0 >$null
		New-ItemProperty -Path "$Branch" -Name "Start_SearchFiles" -Value 0 >$null
		New-Item -Path $Branch\People -Force >$null
		New-ItemProperty -Path "$Branch\People" -Name "PeopleBand" -Value 0 >$null

		$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Policies\Microsoft\WindowsStore"
		New-Item -Path $Branch -Force >$null
		New-ItemProperty -Path $Branch -Name "RemoveWindowsStore" -Value 1 >$null

		$Branch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
		New-Item -Path $Branch -Force >$null
		New-ItemProperty -Path $Branch -Name "DisableFileSyncNGSC" -Value 1 >$null
		CMD_DnCr
	}

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Layout... "
	$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Keyboard Layout\Preload"
	Set-ItemProperty -Path "$Branch" -Name "2" -Value "00000419"
	Set-ItemProperty -Path "$Branch" -Name "1" -Value "00000409"
	CMD_DnCr

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "EnableAutoTray... "
	Set-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 0
	CMD_DnCr

	if( $ID -eq $Data.MASTER ){
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "OFF Visual effects... "
		$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Control Panel\Desktop"
		Set-ItemProperty -Path "$Branch" -Name "DragFullWindows" -Value 0
		Set-ItemProperty -Path "$Branch\WindowMetrics" -Name "MinAnimate" -Value 0
		$Branch = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer"
		Set-ItemProperty -Path "$Branch\Advanced" -Name "TaskbarAnimations" -Value 0
		Set-ItemProperty -Path "$Branch\VisualEffects" -Name "VisualFXSetting" -Value 3
		if( ($BLOCK -ge 5) -and ($BLOCK -lt 8) ){ Set-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "CurrentTheme" -Value "C:\Windows\resources\Ease of Access Themes\basic.theme" }
		CMD_DnCr
	}

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "ScheduledDefrag off... "
	Schtasks.exe /change /TN \Microsoft\Windows\Defrag\ScheduledDefrag /disable *>$null
	if( $LASTEXITCODE -eq 0 ){ CMD_OkCr } else { CMD_ErrCr }

	if( $WINVER -eq 7 ){
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "MP Scheduled Scan off... "
		Schtasks.exe /change /TN "\Microsoft\Windows Defender\MP Scheduled Scan" /disable >nul
		if( $LASTEXITCODE -eq 0 ){ CMD_OkCr } else { CMD_ErrCr }
	}

	if( $WINVER -eq 7 ){
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Uninstall: InboxGames, MediaCenter, OpticalMediaDisc, WindowsGadgetPlatform, TabletPCOC... "
		foreach( $ix in InboxGames MediaCenter OpticalMediaDisc WindowsGadgetPlatform TabletPCOC ){
			<nul set /p var=.
			start /w ocsetup $ix /uninstall /passive /norestart
		}
	} elseif( $WINVER -eq 10 ){
		$list = @(	"BingWeather"
					"Messaging"
					"MixedReality.Portal"
					"Microsoft3DViewer"
					"MicrosoftOfficeHub"
					"MicrosoftSolitaireCollection"
					"MicrosoftStickyNotes"
					"Office.OneNote"
					"People"
					"Print3D"
					"ScreenSketch"
					"SkypeApp"
					"WindowsFeedbackHub"
					"WindowsSoundRecorder"
					"Xbox.TCUI"
					"XboxApp"
					"XboxGameOverlay"
					"XboxGamingOverlay"
					"XboxIdentityProvider"
					"XboxSpeechToTextOverlay"
					"YandexMusic"
					"YourPhone"
					"ZuneMusic"
					"ZuneVideo" )
		Get-AppxPackage -allusers "Microsoft.$list*" | Remove-AppxPackage
	}

	if( !$Force ){
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Run control panel to disable Security center messages" -cr
		if( $WINVER -eq 6 ){
			control /name Microsoft.ActionCenter
		} else { Show-ControlPanelItem -CanonicalName Microsoft.ActionCenter }
		Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Run Group politics to disable access to mass storage devices" -cr
		& "$($env:ProgramFiles)\Notepad++\notepad++.exe" .\gpedit.txt
		gpedit.msc
	}

# Удаляем сообщение вида ***Log.iniis lost
#	Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\ASUS' -Force *>$null

	if( $ID -eq $Data.MASTER ){
		$pid_setup = (Get-Process -Name Setup.exe).Id 2>$null
		if( $pid_setup ){
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Please wait, installation of OracleXE database"
			Wait-Process -Timeout 1800 -Id $pid_setup *>$null
		}

		if( Test-Path -Path "$($Data.TMP)\DISK1\setup.log" ){
			$Result = (Get-Content "$($Data.TMP)\DISK1\setup.log")[1].Split("=")[1]
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "OracleXE database installation completion code: $Result " -cr
			if( $Result -eq 0 ){
				Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Install Oracle XE database successful!" -cr
				$pORACLE = "C:\oraclexe\app\oracle\product\11.2.0\server\network\ADMIN"
				Set-Content -Path $pORACLE\listener.ora -Value ((Get-Content $pORACLE\listener.ora) -Replace "HOST.*", "HOST = BOI-$BLOCK)(PORT = 1521))")
				Set-Content -Path $pORACLE\tnsnames.ora -Value ((Get-Content $pORACLE\tnsnames.ora) -Replace "HOST.*", "HOST = BOI-$BLOCK)(PORT = 1521))")

				Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "configDB unpacking... "
				Expand-Archive -LiteralPath $SOFT_INST\master\configDB.zip -Destination "$($Data.PATH_PELENG)" -Force
				if( $? ){
					CMD_OkCr

					$sectors = $jsonCFG.MASTER.sectors
					if( !$Force ){
						Write-Host
						$var = Read-Host "Enter sectors with space delims [ $sectors ]"
						if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $sectors = $var } }
					}

					$runways = $jsonCFG.MASTER.runways
					if( !$Force ){
						Write-Host
						$var = Read-Host "Enter runways with space delims [ $runways ]"
						if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $runways = $var } }
					}

					Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Session configDB started... "
					Push-Location
					Set-Location "$($Data.PATH_PELENG)\configDB"
					.\config_bd.ps1 $sectors $runways
					Pop-Location
					Remove-Item -Recurse -Path "$($Data.PATH_PELENG)\confDB" -Force *>$null
					CMD_DnCr
				} else {
					CMD_ErrCr
					Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Unpacking error" -cr
				}

			} else { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Install Oracle XE database unsuccessful!" -cr }
		} else { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t w -m "file setup.log not found!" -cr }
	}

	if( $FileLog -and !$Force ){
		choice /c yn /n /t 15 /d n /m "Open LOG file? [Y/n]: "
		if( $LASTEXITCODE -eq 1 ){ & "$env:PROGRAMFILES\Notepad++\notepad++.exe" $FileLog }
	}

	.\make_scripts.ps1

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "=============================================================================" -cr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "=                              SESSION FINISHED                             =" -cr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "=============================================================================" -cr

    systeminfo >logfiles\"$env:COMPUTERNAME.sysinfo.log"

	$fNAME = "install_"+(Get-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Name '(Default)').'(default)'

	Copy-Item $FileLog -Destination .\logfiles\$fNAME.log

	"press 'E/Q' to exit or 'R' to restart immediately "
	for ($i = 30; $i -ge 0; $i-- ){
		Write-Progress -Activity "Time to reboot..." -Status "$($i)s left" -PercentComplete ($i*3.3)
		choice.exe /c neqr /n /d n /t 1 >$null
		if( $LASTEXITCODE -ne 1 ) { if( $LASTEXITCODE -eq 4 ) { reboot } else { return 0 } }
	}
	reboot
}
# ==============================================================================
# ==============================================================================
Check @Args
Main
# ==============================================================================
# ==============================================================================
<#
	IS		- 1,2
	TACHYON	- 10,11,12
	A/V		- 101,102,111..., 121...
	SMAR-T	- 131,132,133[134], 141...159
	MASTER	- 171,172,173
	RTS		- 191
	BS      - 200
#>

#Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -Value C:\Pictures\cats.jpg
