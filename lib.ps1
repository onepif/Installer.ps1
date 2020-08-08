
Function Out-Logging( [Switch]$empty, [Switch]$ok, [Switch]$er, [Switch]$dn, [Switch]$cr, [Switch]$sk ){
<#
.SYNOPSIS
	The initial configuration script windows.
	For the correct operation of the script must be run with administrator privileges
.DESCRIPTION
	Использование: Out-Logging [args]
	[args] могут принимать следующие значения:
.PARAMETER	-D [1^|..] : включить отладочный режим. Будет производится вывод дополнительной информации;
#>
	if( $LVL )	{ Remove-Item Variable:LVL }
	if( $TYPE )	{ Remove-Item Variable:TYPE }
	if( $SRC )	{ Remove-Item Variable:SRC }
	if( $MSG )	{ Remove-Item Variable:MSG }
	if( $FILE )	{ Remove-Item Variable:FILE }

	for( $ix=0; $ix -lt $Args.Count; $ix++ ){
		if( $Args[$ix] -eq $null ){ Continue }
		Switch ( ($Args[ $ix ]) ){
			"-t"	{ if( $Args[$ix+1] ){
						Switch ( ($Args[ ++$ix ])[0] ){
							"i" { $TYPE	= "INFO" }
							"w" { $TYPE	= "WARNING" }
							"e" { $TYPE	= "ERROR" }
							"d" { $LVL	= $Args[ $ix ][1]; if( $LVL -eq $null ){ $LVL = 1 }; $TYPE = "DEBUG LVL $LVL" }
						}
						Break
					}
			}
			"-src"	{ if( $Args[$ix+1] ){ if($Args[$ix+1][0] -ne "-") { $SRC	= $Args[ ++$ix ] } }; Break }
			"-m"	{ if( $Args[$ix+1] ){ if($Args[$ix+1][0] -ne "-") { $MSG	= $Args[ ++$ix ] } }; Break }
			"-out"	{ if( $Args[$ix+1] ){ if($Args[$ix+1][0] -ne "-") { $FILE	= $Args[ ++$ix ] } }; Break }
			$null	{ Break }
			Default { "$((get-date -UFormat "%Y.%m.%d - %H:%M:%S.")+(get-date).Millisecond) [ WARNING ] - < Out-Logging > : '$($Args[$ix])' - not correct parametrs" }
		}
	}

	if( !($TYPE) ){ $TYPE = "INFO" }
	if( !($SRC) ){ $SRC = "Out-Logging" }

	if( $empty ){
		Function CMD_Out-Logging{ Write-Host }
		Function CMD_Out-LogFile{ ''|Out-File -Append $FILE}
	} elseif( $ok ){
		if( $cr ){
			Function CMD_Out-Logging{
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor Green -noNewLine 'OK'; Write-Host ' ]'
			}
			Function CMD_Out-LogFile{ '[ OK ]'|Out-File -Append $FILE }
		} else {
			Function CMD_Out-Logging{
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor Green -noNewLine 'OK'; Write-Host -noNewLine ' ]'
			}
			Function CMD_Out-LogFile{ '[ OK ]'|Out-File -noNewLine -Append $FILE }
		}
	} elseif( $er ){
		if( $cr ){
			Function CMD_Out-Logging{
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor Red -noNewLine 'ERROR'; Write-Host ' ]'
			}
			Function CMD_Out-LogFile{ '[ ERROR ]'|Out-File -Append $FILE }
		} else {
			Function CMD_Out-Logging{
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor Red -noNewLine 'ERROR'; Write-Host -noNewLine ' ]'
			}
			Function CMD_Out-LogFile{ '[ ERROR ]'|Out-File -noNewLine -Append $FILE }
		}
	} elseif( $dn ){
		if( $cr ){
			Function CMD_Out-Logging {
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor White -noNewLine 'DONE'; Write-Host ' ]'
			}
			Function CMD_Out-LogFile{ '[ DONE ]'|Out-File -Append $FILE }
		} else {
			Function CMD_Out-Logging {
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor White -noNewLine 'DONE'; Write-Host -noNewLine ' ]'
			}
			Function CMD_Out-LogFile{ '[ DONE ]'|Out-File -noNewLine -Append $FILE }
		}
	} elseif( $sk ){
		if( $cr ){
			Function CMD_Out-Logging{
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor Yellow -noNewLine '.'; Write-Host ' ]'
			}
			Function CMD_Out-LogFile{ '[ . ]'|Out-File -Append $FILE }
		} else {
			Function CMD_Out-Logging{
				Write-Host -noNewLine '[ '; Write-Host -ForegroundColor Yellow -noNewLine '.'; Write-Host -noNewLine ' ]'
			}
			Function CMD_Out-LogFile{ '[ . ]'|Out-File -noNewLine -Append $FILE }
		}
	} else {
		$dt = (get-date -UFormat "%Y.%m.%d - %H:%M:%S.")+(get-date).Millisecond
		if( $cr ){
			Function CMD_Out-Logging{
				Write-Host -noNewLine "$dt [ "
				Switch( $TYPE.Remove(3) ){
					"WAR"	{ Write-Host -noNewLine -ForegroundColor Yellow "$TYPE"; Break }
					"ERR"	{ Write-Host -noNewLine -ForegroundColor RED "$TYPE"; Break }
					"DEB"	{ Write-Host -noNewLine -ForegroundColor Magenta "$TYPE"; Break }
					Default	{ Write-Host -noNewLine -ForegroundColor Cyan "$TYPE" }
				}
				Write-Host " ] - < $SRC > : $MSG"
			}
			Function CMD_Out-LogFile{ "$dt [ $TYPE ] - < $SRC > : $MSG"|Out-File -Append $FILE }
		} else {
			Function CMD_Out-Logging{
				Write-Host -noNewLine "$dt [ "
				Switch( $TYPE.Remove(3) ){
					"WAR"	{ Write-Host -noNewLine -ForegroundColor Yellow "$TYPE"; Break }
					"ERR"	{ Write-Host -noNewLine -ForegroundColor RED "$TYPE"; Break }
					"DEB"	{ Write-Host -noNewLine -ForegroundColor Magenta "$TYPE"; Break }
					Default	{ Write-Host -noNewLine -ForegroundColor Cyan "$TYPE" }
				}
				Write-Host -noNewLine " ] - < $SRC > : $MSG"
			}
			Function CMD_Out-LogFile{ "$dt [ $TYPE ] - < $SRC > : $MSG"|Out-File -noNewLine -Append $FILE }
		}
	}

	if( $FILE ){ CMD_Out-LogFile }
	if( $FLAG_CONS ){ CMD_Out-Logging }
}

<#
Function Remove-Var(){
	CMD_DBG 1 $MyInvocation.MyCommand.Name "========= started ========="
	if( $ID )			{ Remove-Item Variable:ID *>$null }
	if( $BLOCK )		{ Remove-Item Variable:BLOCK *>$null }
	CMD_DBG 1 $MyInvocation.MyCommand.Name "======== completed ========"
}
#>

Function Work-Int(){
	Remove-Var
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t w -m "Work interrupted by the user" -cr
#	$PID = (Get-Process powershell).Id
	Start-Process 'powershell' -Verb RunAs
	Stop-Process $PID
}

# Настройка правил Брандмауэра Windows
Function Set-Rules(){
	CMD_DBG 1 $MyInvocation.MyCommand.Name "========= started ========="

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Configuring Windows Firewall rules for ports: $Args... "
	foreach( $port in $Args ){
		foreach( $protokol in "TCP","UDP" ){
			if( $WINVER -eq 6 ){
				foreach( $direct in "In","Out" ){
					if( !(netsh advfirewall firewall show rule name=all|where {$_ -match "port $port $protokol $direct is enable"}) ){
						netsh advfirewall firewall add rule name="port $port $protokol $direct is enable" dir=$direct action=allow protocol=$protokol localport=$port *>$null
						if( $? ){ CMD_Ok } else { CMD_Err }
					} else { CMD_Skip }
				}
			} else {
				foreach( $direct in "Inbound","Outbound" ){
					if( (Get-NetFirewallRule -DisplayName "port $port $protokol $direct is enable*").Enabled -ne $true ){
						New-NetFirewallRule -Action allow -DisplayName "port $port $protokol $direct is enable" -Direction $direct -LocalPort $port -Protocol $protokol *>$null
						if( (Get-NetFirewallRule -DisplayName "port $port $protokol $direct is enable").Enabled -eq $true ){ CMD_Ok } else { CMD_Err }
					} else { CMD_Skip }
				}
			}
		}
	}
	CMD_Empty

	CMD_DBG 1 $MyInvocation.MyCommand.Name "======== completed ========"
}

Function Rename-Lan_Old(){
	CMD_DBG 1 $MyInvocation.MyCommand.Name "========= started ========="

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Rename network connections and sets the IP address... "
	$ALL_IF=netsh interface show interface
	$CNT_IF = ($ALL_IF.Count)-4

	if( $Args ){ $IP_WS = $Args[0] } else { $IP_WS = $BLOCK }
	for( $iy=0; $iy -lt $CNT_IF; $iy++ ){
		$Name = $ALL_IF[($ALL_IF.Count)-$CNT_IF-1+$iy]
		$CNT=0; $FLAG=$true
		for( $ix=0; $ix -lt $Name.Length; $ix++ ){
			if( $Name[$ix] -eq " " ){
				if( $FLAG ){ $CNT++; $FLAG=$false }
			} else {
				$FLAG=$true
				if($CNT -eq 3){
					$var = $Name.Substring($ix)
					if( $var.Substring(0,3) -eq "LAN" ){ CMD_Skip } else {
						netsh interface set interface name="$var" newname="LAN$($iy+1)" *>$null
						if($?){
							CMD_Ok
							netsh interface ipv4 set address "LAN$($iy+1)" static "$($jsonCFG.subNET).$($($jsonCFG.stepNET)*($iy+1)).$IP_WS" 255.255.255.0 "$($jsonCFG.subNET).$($($jsonCFG.stepNET)*($iy+1)).2" 1 *>$null
							if( $? ){ CMD_Ok } else { CMD_Err }
						} else { CMD_Err }
					}
					break
				}
			}
		}
	}
	CMD_Empty
	CMD_DBG 1 $MyInvocation.MyCommand.Name "======== completed ========"
}


Function Rename-Lan(){
	CMD_DBG 1 $MyInvocation.MyCommand.Name "========= started ========="

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Rename network connections and sets the IP address... "
	if( (Get-NetAdapter).Count -ge 2){
		if( !((Get-NetAdapter).Name[0]).Contains("LAN") ){
			if( $Args ){ $IP_WS = $Args[0] } else { $IP_WS = $BLOCK }
			for( $ix=0; $ix -lt (Get-NetAdapter).Count; $ix++ ){
				Rename-NetAdapter -Name "$((Get-NetAdapter).Name[$ix])" -NewName "LAN$($ix+1)"
				if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
			}
			for( $ix=0; $ix -lt (Get-NetAdapter).Count; $ix++ ){
				New-NetIPAddress -InterfaceAlias "LAN$($ix+1)" -IPAddress ($jsonCFG.subNET).($jsonCFG.stepNET)*($ix+1).$IP_WS -PrefixLength 24 -DefaultGateway ($jsonCFG.subNET).($jsonCFG.stepNET)*($ix+1).2
				if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
			}
			CMD_Empty
		} else { CMD_SkipCr }
	} else {
		if( !((Get-NetAdapter).Name).Contains("LAN") ){
			if( $Args ){ $IP_WS = $Args[0] } else { $IP_WS = $BLOCK }
			Rename-NetAdapter -Name "$((Get-NetAdapter).Name)" -NewName "LAN1"
			if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }

			New-NetIPAddress -InterfaceAlias "LAN1" -IPAddress ($jsonCFG.subNET).($jsonCFG.stepNET).$IP_WS -PrefixLength 24 -DefaultGateway ($jsonCFG.subNET).($jsonCFG.stepNET).2
			if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { CMD_Err }
			CMD_Empty
		} else { CMD_SkipCr }
	}

	CMD_DBG 1 $MyInvocation.MyCommand.Name "======== completed ========"
}

Function Rename-PC(){
	CMD_DBG 1 $MyInvocation.MyCommand.Name "========= started ========="
	Rename-Computer -NewName "$($Args)" *>$null
	Set-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$strSID\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Name "(Default)" -Value "$($Args)"
	CMD_DBG 1 $MyInvocation.MyCommand.Name "======== completed ========"
}

Function Set-AsRun(){
	if( $Args ){ $var = $Args } else {
		Write-Host
		"How to run software:";"  as Shell   - 1";"  as Program - 2"
		choice /c 123q /n /m "?: "
		$var = $LASTEXITCODE
	}

    $BRANCH_WINLOGON = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $BRANCH_RUN = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $VALUE = "cmd.exe /u /c powershell.exe rc.SS.ps1"
	Switch( $var ){
		1 {
			CMD_DBG 2 $MyInvocation.MyCommand.Name "Selected run as shell"
			Set-ItemProperty -Path $BRANCH_WINLOGON -Name "Shell" -Value $VALUE
			Remove-ItemProperty -Path $BRANCH_RUN -Name "SS" *>$null
			Break
		}
		2 {
			CMD_DBG 2 $MyInvocation.MyCommand.Name "Selected run as programm"
			Set-ItemProperty -Path $BRANCH_WINLOGON -Name "Shell" -Value explorer.exe
			Set-ItemProperty -Path $BRANCH_RUN -Name "SS" -Value $VALUE
			Break
		}
		3 {
			if( (Get-ItemProperty $BRANCH_WINLOGON -Name Shell).Shell -eq "explorer.exe" ){
				CMD_DBG 2 $MyInvocation.MyCommand.Name "Selected run as shell"
				Set-ItemProperty -Path $BRANCH_WINLOGON -Name "Shell" -Value $VALUE
				Remove-ItemProperty -Path $BRANCH_RUN -Name "SS" *>$null
			} else {
				CMD_DBG 2 $MyInvocation.MyCommand.Name "Selected run as programm"
				Set-ItemProperty -Path $BRANCH_WINLOGON -Name "Shell" -Value explorer.exe
				Set-ItemProperty -Path $BRANCH_RUN -Name "SS" -Value $VALUE
			}
			Break
		}
		Default { Work-Int }
	}
}

Function Set-TimeClt(){
<#
SpecialPollInterval:
	0x003c - 60 сек;
	0x0258 - 600 сек;
	0x0e10 - 3600 сек;

LargePhaseOffset	Specifies the time offset, in tenths of a microsecond (A tenth of a microsecond is equal to 10 to the power of -7). Times that are larger than or equal to this value are considered suspicious and possibly incorrect.
SpikeWatchPeriod	Specifies how long, in seconds, that a suspicious time offset must persist before it is accepted as correct.
EventLogFlags   Stores configuration data for the policy setting, Configure Windows NTP Client.
Enabled Indicates whether the NtpServer provider is enabled in the current Time Service.

После настройки необходимо обновить конфигурацию сервиса. Сделать это можно командой w32tm /config /update.
И еще несколько команд для настройки, мониторинга и диагностики службы времени:
w32tm /monitor – при помощи этой опции можно узнать, насколько системное время данного компьютера отличается от времени на контроллере домена или других компьютерах. Например: w32tm /monitor /computers:time.nist.gov
w32tm /resync – при помощи этой команды можно заставить компьютер синхронизироваться с используемым им сервером времени.
w32tm /stripchart –  показывает разницу во времени между текущим и удаленным компьютером. Команда w32tm /stripchart /computer:time.nist.gov /samples:5 /dataonly произведет 5 сравнений с указанным источником и выдаст результат в текстовом виде.
w32tm /config – это основная команда, используемая для настройки службы NTP. С ее помощью можно задать список используемых серверов времени, тип синхронизации и многое другое. Например, переопределить значения по умолчанию и настроить синхронизацию времени с внешним источником, можно командой w32tm /config /syncfromflags:manual /manualpeerlist:time.nist.gov /update
w32tm /query — показывает текущие настройки службы. Например команда w32tm /query /source  покажет текущий источник времени, а w32tm /query /configuration  выведет все параметры службы.

net stop w32time - останавливает службу времени, если запущена.
w32tm /unregister — удаляет службу времени с компьютера.
w32tm /register – регистрирует службу времени на компьютере.  При этом создается заново вся ветка параметров в реестре.
net start w32time - запускает службу.

MaxAllowedPhaseOffset - максимально допустипое расхождение:
	0x012c - 5 мин
	0x0e10 - 1 час
#>

	if( $Args[0] -eq "" ) {
		$s1 = "192.168.10.2"
		$s2 = "192.168.10.3"
	} else {
		$s1 = $Args[0]
		if( $Args[1] -eq "" ) { $s2 = "192.168.10.2" } else { $s2 = $Args[1] }
	}

	$Branch = "KKLM:\SYSTEM\CurrentControlSet\Services\W32Time"
	Set-ItemProperty -Path "$Branch\Config" -Name "MaxAllowedPhaseOffset" -Value 1 *>$null
	Set-ItemProperty -Path "$Branch\Config" -Name "MaxPosPhaseCorrection" -Value 0xFFFFFFFF *>$null
	Set-ItemProperty -Path "$Branch\Config" -Name "MaxNegPhaseCorrection" -Value 0xFFFFFFFF *>$null
	Set-ItemProperty -Path "$Branch\Config" -Name "SpikeWatchPeriod" -Value 1 *>$null

	Set-ItemProperty -Path "$Branch\Parameters" -Name "NtpServer" -Value "$s1,0x1 $s2,0x1" *>$null
	Set-ItemProperty -Path "$Branch\Parameters" -Name "Type" -Value "NTP" *>$null

	Set-ItemProperty -Path "$Branch\TimeProviders\NtpClient" -Name "Enabled" -Value 1 *>$null
	Set-ItemProperty -Path "$Branch\TimeProviders\NtpClient" -Name "SpecialPollInterval" -Value 0x0e10 *>$null
	Set-ItemProperty -Path "$Branch\TimeProviders\NtpServer" -Name "Enabled" -Value 0 *>$null

	$Branch = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"
	Set-ItemProperty -Path "$Branch\Config" -Name "(Default)" -Value "6" *>$null
	Set-ItemProperty -Path "$Branch\Config" -Name "6" -Value "$s1" *>$null
}

<#
Function Set-Pass(){
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t w -m "User ${pUser} already exists" -cr
	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Setting password for users ${pUser}: ${pPass}... "
	net user ${pUser} ${pPass} *>$null
	if( $LASTEXITCODE -eq 0 ){ CMD_OkCr } else { CMD_ErrCr }
}

Function Set-User(){
	CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="
	if( $env:USERNAME -ne ${pUser} ){
		if( "$(Get-Content .\PelengClass.ps1)" -match "USER_PELENG" ){ 
			Set-Content -Path .\PelengClass.ps1 -Value ((Get-Content .\PelengClass.ps1) -Replace "(.*USER_PELENG=).*", "`$1`"${pUser}`"")
		} else { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Problem with PelengClass.ps1" -cr }
		if( !(wmic useraccount list full|where { $_ -eq "Name=${pUser}" }) ){
			Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Create user's ${pUser}... "
			net user ${pUser} ${pPass} /add /expires:never *>$null
			if( $LASTEXITCODE -eq 0 ){ CMD_Ok } else { if( $LASTEXITCODE -eq 2 ){ CMD_Skip } else { CMD_Err } }
			if( $LOCALE -eq 00000419 ){ net localgroup "Администраторы" ${pUser} /add *>$null } else { net localgroup "Administrators" ${pUser} /add *>$null }
			if( $LASTEXITCODE -eq 0 ){ CMD_OkCr } else { CMD_ErrCr }
		} else { Set-Pass }

		choice /c rlq /d l /t 7 /n /m "Press 'R' for reboot or 'L' for logoff [R/L]: "
		if( $LASTEXITCODE -eq 3 ){ Work-Int } elseif( $LASTEXITCODE -eq 2 ) { logoff } else { shutdown.exe /r /t 1 }
	} else { Set-Pass }
	CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
}
#>

Function Set-Shared( [string]$s, [string]$d, [string]$u="User" ){
	CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="
	CMD_Dbg 2 $MyInvocation.MyCommand.Name "Share: ${s}, Path: ${d}, User: ${u}"

	Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -m "Create share: ${s}... "

	net share $s=$d /grant:$u,full *>$null
	if( $? ){ CMD_OkCr } else { CMD_ErrCr }

	CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
}

Function Run-W32Time(){
	if( (Get-Service w32time).Status -eq 'Running' ) { Set-Service -InputObject w32time -Status Stopped; Sleep 4 }
	Set-Service -InputObject w32time -Status Running
}

Function Set-PathPeleng([string]$dev, [string]$def){
	CMD_Dbg 1 $MyInvocation.MyCommand.Name "========= started ========="
	if( !$dev ){ if( !$Data.DEVICE ){ Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "DEVICE not defined!" -cr; Work-Int } }

	if( !$Force ){
		Write-Host
		$var = Read-Host "Specify the folder name for install $dev [ $def ]"
		if( $var ){ if( $var -eq "Q" ){ Work-Int } else { $Data.PATH_PELENG = $var } } else { $Data.PATH_PELENG = $def }
	}

	if( [Environment]::Is64BitOperatingSystem -and !(($Data.PATH_PELENG).Contains("(x86)")) -and ($dev -ne "RTS") ){
		$Data.PATH_PELENG = ($Data.PATH_PELENG).ToLower().Replace("program files", "Program Files (x86)")
	}
	CMD_Dbg 2 $MyInvocation.MyCommand.Name "PATH_PELENG=$($Data.PATH_PELENG)"

	if( "$(Get-Content .\PelengClass.ps1)" -match "PATH_PELENG" ){ 
#		Set-Content -Path .\PelengClass.ps1 -Value ((Get-Content .\PelengClass.ps1) -Replace "(.*PATH_PELENG=).*", "`$1 `"$($Data.PATH_PELENG)`"")
		Set-Content -Path .\PelengData.json -Value "$($Data|ConvertTo-JSON)"
	} else { Out-Logging -out $FileLog -src $MyInvocation.MyCommand.Name -t e -m "Problem with PelengClass.ps1" -cr }
	CMD_Dbg 1 $MyInvocation.MyCommand.Name "======== completed ========"
}

Function Get-ComFolderItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] $Path
    )

    $ShellApp = New-Object -ComObject 'Shell.Application'

    $Item = Get-Item $Path -ErrorAction Stop

    if ($Item -is [System.IO.FileInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Directory.FullName).ParseName($Item.Name)
    } elseif ($Item -is [System.IO.DirectoryInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Parent.FullName).ParseName($Item.Name)
    } else {
        throw "Path is not a file nor a directory"
    }

    return $ComFolderItem
}

Function Install-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarpin')
}

Function Uninstall-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarunpin')
}

function Get-NetworkConfig {
  Get-WmiObject Win32_NetworkAdapter -Filter 'NetConnectionStatus=2' |
    ForEach-Object {
      $result = 1 | Select-Object Name, IP, MAC
      $result.Name = $_.Name
      $result.MAC = $_.MacAddress
      $config = $_.GetRelated('Win32_NetworkAdapterConfiguration') 
      $result.IP = $config | Select-Object -expand IPAddress
      $result
    }
 
}

function Get-FolderSize($Path=$home) {
  $code = { ('{0:0.0} MB' -f ($this/1MB)) }
  Get-ChildItem -Path $Path |
    Where-Object { $_.Length -eq $null } |
    ForEach-Object {
      Write-Progress -Activity 'Calculating Total Size for:' -Status $_.FullName
      $sum = Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue
      $bytes = $sum.Sum
      if ($bytes -eq $null) { $bytes = 0   }
      $result = 1 | Select-Object -Property Path, TotalSize
      $result.Path = $_.FullName
      $result.TotalSize = $bytes | 
        Add-Member -MemberType ScriptMethod -Name toString -Value $code -Force -PassThru    
      $result
    }
}

Function CMD_Empty(){ Out-Logging -out $FileLog -empty }
Function CMD_Dn(){ Out-Logging -out $FileLog -dn }
Function CMD_DnCr(){ Out-Logging -out $FileLog -dn -cr }
Function CMD_Ok(){ Out-Logging -out $FileLog -ok }
Function CMD_OkCr(){ Out-Logging -out $FileLog -ok -cr }
Function CMD_Err(){ Out-Logging -out $FileLog -er }
Function CMD_ErrCr(){ Out-Logging -out $FileLog -er -cr }
Function CMD_Skip(){ Out-Logging -out $FileLog -sk }
Function CMD_SkipCr(){ Out-Logging -out $FileLog -sk -cr }
Function CMD_DBG( $dbg_lvl=1, $name="CMD_Dbg" ){
	if( ($Dbg -band $dbg_lvl) -eq $dbg_lvl ){
		Out-Logging -out $FileLog -src $name -t d$dbg_lvl -m ([string]$Args+";") -cr
	}
}
