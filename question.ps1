<#
	./question.cmd

	Initial configuration script.
	For the correct operation of the script must be run with administrator privileges

	Developer Dmitriy L. Ivanov aka onepif
	JSC PELENG 2020
	All rights reserved
#>

$lastBl = 32

CMD_DBG 1 $MyInvocation.MyCommand.Name "========= started ========="

if( !($ID) ){
	Write-Host
	"Select a product:"; "  SMAR-T   - 1"; "  Master   - 2"; "  ACK      - 3"; "  Tachyon  - 4"; "  IS       - 5"; "  PS       - 6"; "  TDK [BS] - 7"
	choice /c 123456789q /n /m "?: "
	$ID = $LASTEXITCODE
	if( $ID -eq 10 ){ Work-Int }
}

if( !($BLOCK) ){
	Switch ($ID){
		1 { $listBl = "  ARMZ    [BRI-1] - 1", "          [BRI-2] - 2", "          [BRI-3] - 3", "          [BRI-4] - 4", "  ARMV    [BVI]   - 5", "          [BVI-2] - 6", "          [BVI-3] - 7", "          [BVI-4] - 8", "  BVZ     [BVZ]  -> 9"; Break }
		2 { $listBl = "  Master  [BOI-1] - 1", "          [BOI-2] - 2", "          [BOI-3] - 3"; Break }
		3 { $listBl = "  RTS    [BKDI-1] - 1", "         [BKDI-2] - 2", "         [BKDI-3] - 3"; Break }
		4 { $listBl = "  Tachyon [BHS-1] - 1", "          [BHS-2] - 2", "          [BHS-3] - 3", "            [RMK] - 4"; Break }
		5 { $listBl = "  IS      [BOI-1] - 1", "          [BOI-2] - 2", "          [BOI-3] - 3"; Break }
		6 { $listBl = "  PS      [BOI-1] - 1", "          [BOI-2] - 2", "          [BOI-3] - 3", "         [ARMO-1] - 4"; Break }
		7 { $listBl = "  TDK        [RU] - 1", "             [PO] - 2", "             [DL] - 3", "             [DP] - 4", "             [TS] - 5", "            [ZIP] - 6"; Break }
	}
	Write-Host
	"Select a block:"
	for( $ix=0; $ix -lt $listBl.Count; $ix++){ $listBl[$ix] }
	choice /c 123456789q /n /m "?: "
	$BLOCK = $LASTEXITCODE
	if( $BLOCK -eq 10 ){ Work-Int }
	if( ($ID -eq 1) -and ($BLOCK -eq 9) ){ [int]$BLOCK = 10+(Read-Host "specify BVZ block number [1..$lastBl]") }
	if( $ID -eq 7 ){
		$LIST = @( "ru","po", "dl", "dp", "ts", "zi" )
		choice /c 1234567q /n /m "Specify the number WS [1..5]: "; $BLOCK = $LIST[$BLOCK-1]+$LASTEXITCODE }
}

$GLOBAL:ID=$ID
if( $ID -eq 7 ){ [string]$GLOBAL:BLOCK=$BLOCK } else { $GLOBAL:BLOCK=$BLOCK }

CMD_DBG 2 $MyInvocation.MyCommand.Name "ID=$ID, BLOCK=$BLOCK, DEVICE=$($Data.DEVICE[$ID-1])"

CMD_DBG 1 $MyInvocation.MyCommand.Name "======== completed ========"
