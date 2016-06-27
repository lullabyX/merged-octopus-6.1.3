; #FUNCTION# ====================================================================================================================
; Name ..........: RemainTrainTime
; Description ...: Read the remaining time to complete the train troops & Spells on ArmyOverView Window
; Syntax ........: RemainTrainTime
; Parameters ....: $Troops and $Spells
; Return values .: Most high value from Spells or Troops in minutes
; Author ........: ProMac (04-2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: openArmyOverview
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


Func getRemainingTraining($Troops = True, $Spells = True)

	; Lets open the ArmyOverView Window (this function will check if we are on Main Page and wait for the window open returning True or False)
	If openArmyOverview() Then
	    Local $aGetArmySize[3] = ["", "", ""]
	Local $sArmyInfo = ""
	Local $sInputbox, $iTried, $iHoldCamp
	Local $tmpTotalCamp = 0
	Local $tmpCurCamp = 0



	; Verify troop current and full capacity
	$iTried = 0 ; reset loop safety exit counter
	While $iTried < 100 ; 30 - 40 sec

		$iTried += 1
		If _Sleep($iDelaycheckArmyCamp5) Then Return ; Wait 250ms before reading again
	    ForceCaptureRegion()
		$sArmyInfo = getArmyCampCap(192, 144 + $midOffsetY) ; OCR read army trained and total
		If $debugSetlog = 1 Then Setlog("OCR $sArmyInfo = " & $sArmyInfo, $COLOR_PURPLE)
		If StringInStr($sArmyInfo, "#", 0, 1) < 2 Then ContinueLoop ; In case the CC donations recieved msg are blocking, need to keep checking numbers till valid

		$aGetArmySize = StringSplit($sArmyInfo, "#") ; split the trained troop number from the total troop number

		If IsArray($aGetArmySize) Then
			If $aGetArmySize[0] > 1 Then ; check if the OCR was valid and returned both values
				If Number($aGetArmySize[2]) < 10 Or Mod(Number($aGetArmySize[2]), 5) <> 0 Then ; check to see if camp size is multiple of 5, or try to read again
					If $debugSetlog = 1 Then Setlog(" OCR value is not valid camp size", $COLOR_PURPLE)
					ContinueLoop
				EndIf
				$tmpCurCamp = Number($aGetArmySize[1])
				If $debugSetlog = 1 Then Setlog("$tmpCurCamp = " & $tmpCurCamp, $COLOR_PURPLE)
				$tmpTotalCamp = Number($aGetArmySize[2])
				If $debugSetlog = 1 Then Setlog("$TotalCamp = " & $TotalCamp & ", Camp OCR = " & $tmpTotalCamp, $COLOR_PURPLE)
				If $iHoldCamp = $tmpTotalCamp Then ExitLoop ; check to make sure the OCR read value is same in 2 reads before exit
				$iHoldCamp = $tmpTotalCamp ; Store last OCR read value
			EndIf
		EndIf

	WEnd

	If $iTried <= 99 Then
		$CurCamp = $tmpCurCamp
		If $TotalCamp = 0 Then $TotalCamp = $tmpTotalCamp
		Setlog("$CurCamp = " & $CurCamp & ", $TotalCamp = " & $TotalCamp, $COLOR_BLUE)
	Else
		Setlog("Army size read error, Troop numbers may not train correctly", $COLOR_RED) ; log if there is read error
		$CurCamp = 0
		CheckOverviewFullArmy()
	EndIf

		Local $aRemainTrainTroopTimer = 0
		Local $aRemainTrainSpellsTimer = 0
		Local $ResultTroopsHour, $ResultTroopsMinutes
		Local $ResultSpellsHour, $ResultSpellsMinutes

		Local $ResultTroops = getRemainTrainingTimer(680, 176)
		Local $ResultSpells = getRemainTrainingTimer(360, 423)

		If $Troops = True Then
			SetLog(" Total time train troop(s): " & $ResultTroops)
			If StringInStr($ResultTroops, "h") > 1 Then
				$ResultTroopsHour = StringSplit($ResultTroops, "h", $STR_NOCOUNT)
				; $ResultTroopsHour[0] will be the Hour and the $ResultTroopsHour[1] will be the Minutes with the "m" at end
				$ResultTroopsMinutes = StringTrimRight($ResultTroopsHour[1], 1) ; removing the "m"
				$aRemainTrainTroopTimer = (Number($ResultTroopsHour[0]) * 60) + Number($ResultTroopsMinutes)
			Else
				; Verify if exist "s" for seconds or "m" for minutes
				If StringInStr($ResultTroops, "s") > 1 Then
					$aRemainTrainTroopTimer = 1
				Else
					$aRemainTrainTroopTimer = Number(StringTrimRight($ResultTroops, 1)) ; removing the "m"
				EndIf
			EndIf
			SetLog("Going to visit the Mermaids....", $COLOR_MAROON)
		EndIf

			Return (($aRemainTrainTroopTimer * ( ($TotalCamp * $fulltroop)/100 - $CurCamp)) / ( $TotalCamp  - $CurCamp)) - .8

	Else
		SetLog("Can not read the remaining Troops&Spells time!", $COLOR_RED)
		Return 0
	EndIf

EndFunc   ;==>getRemainingTraining

