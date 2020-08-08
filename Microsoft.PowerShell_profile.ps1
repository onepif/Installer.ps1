function Set-Color {
	(Get-Host).PrivateData.ErrorForegroundColor		= "Red"
	(Get-Host).PrivateData.ErrorBackgroundColor		= "Black"
	(Get-Host).PrivateData.WarningForegroundColor	= "Yellow"
	(Get-Host).PrivateData.WarningBackgroundColor	= "Black"
	(Get-Host).PrivateData.DebugForegroundColor		= "Magenta"
	(Get-Host).PrivateData.DebugBackgroundColor		= "Black"
	(Get-Host).PrivateData.VerboseForegroundColor	= "Yellow"
	(Get-Host).PrivateData.VerboseBackgroundColor	= "Black"
	(Get-Host).PrivateData.ProgressForegroundColor	= "Yellow"
	(Get-Host).PrivateData.ProgressBackgroundColor	= "DarkGray"

	(Get-Host).UI.RawUI.ForegroundColor				= "DarkGray"
	(Get-Host).UI.RawUI.BackgroundColor				= "Black"
	(Get-Host).UI.RawUI.CursorSize					= 15
}

function prompt {
	Set-Color

	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = [Security.Principal.WindowsPrincipal] $identity

	"pwsh-$($Host.Version.Major).$($Host.Version.Minor)" +
	$( if($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{ "# " } else { "$ " } )
}

$Data = Get-Content $env:WINDIR\PelengData.json|ConvertFrom-JSON
. $env:WINDIR\lib.ps1
