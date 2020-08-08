Class PelengData{
	[Int]$SMART			= 1
	[Int]$MASTER		= 2
	[Int]$RTS			= 3
	[Int]$TACHYON		= 4
	[Int]$IS			= 5
	[Int]$PS			= 6
	[Int]$TRS			= 7

	$DEVICE				= @('SMART', 'MASTER', 'RTS', 'TACHYON', 'SERVER', 'AVIA', 'TRS')
	$DEV_SMART			= @('Recorder', 'Recorder', 'Recorder', 'Recorder', 'Player3', 'Player3', 'VGrabber')

	[string]$USER_PELENG= "User"

	[string]$PATH_PELENG= ""
	[string]$TMP		= "C:\Tmp"
	[string]$pRUN		= "$env:PROGRAMDATA\Peleng\run"
	[string]$pLOG		= "$env:PROGRAMDATA\Peleng\logfiles"
}
