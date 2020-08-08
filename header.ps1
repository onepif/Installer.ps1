<#
  ./header.cmd

  The header configuration script.

  Developer Dmitriy L. Ivanov aka onepif
  CJSC PELENG 2020
  All rights reserved
#>

$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

$GLOBAL:SOFT_ENV	= "$(Split-Path -Path $(Split-Path -Path $MyInvocation.MyCommand.Path))\soft_environment"
$GLOBAL:SOFT_INST	= "$(Split-Path -Path $(Split-Path -Path $MyInvocation.MyCommand.Path))\soft_install"
$GLOBAL:WINVER = [Environment]::OSVersion.Version.Major

#$GLOBAL:Data = [PelengData]::new()

$var = "$(Split-Path -Path $MyInvocation.MyCommand.Path)\PelengData.json"
if (Test-Path $var)
{
	$GLOBAL:Data = Get-Content -Path $var -Raw | ConvertFrom-Json
}
else
{
	$GLOBAL:Data = '{
		"SMART"			: 1,
		"MASTER"		: 2,
		"RTS"			: 3,
		"TACHYON"		: 4,
		"IS"			: 5,
		"PS"			: 6,
		"TRS"			: 7,

		"DEVICE"		:
		[
			"SMART", "MASTER", "RTS", "TACHYON", "SERVER", "AVIA", "TRS"
		],
		"DEV_SMART"		: [ "Recorder", "Recorder", "Recorder", "Recorder", "Player3", "Player3", "Player3", "Player3", "VGrabber" ],

		"USER_PELENG"	: "User",

		"PATH_PELENG"	: "",
		"TMP"			: "C:\\Tmp",
		"pRUN"			: "$env:PROGRAMDATA\\Peleng\\run",
		"pLOG"			: "$env:PROGRAMDATA\\Peleng\\logfiles",

		"rsyncCFG": "/cygdrive/C/Windows"
	}' | ConvertFrom-Json

	Set-Content -Path $var -Value "$($Data|ConvertTo-Json)"
}
