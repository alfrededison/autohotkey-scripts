#SingleInstance OFF
OnMessage(0x0200,"OnMouseMove")

; ------------------------- Menu Tray Icon ----------------------------

Menu, Tray, NoStandard
Menu, Tray, add, Exit, gtfo
Menu, Tray, Default, Exit
; Menu, Tray, Icon, %A_WorkingDir%\hourglass.ico

; ------------------------- Variables ----------------------------

c_up := Chr(0x25B3)
c_down := Chr(0x25BD)
c_working := Chr(0x25CF)
c_fullcircle := Chr(0x25C9)
c_emptycircle := Chr(0x25CE)
c_leftright := Chr(0x21C4)

guiid := 0
timer := 300
preset := 300
started := false
stoptime := A_NOW
half := false
updating := false
loopmode := false
sleepmode := false
mousex := 0
mouseover := false
c_transp_over := 250
c_transp_out := 80
col_working = CC0000
col_timer = DDDDDD
col_window = 1A1A1A
col_updown = 444444
col_preset = 444444

; ------------------------- GUI ----------------------------

Gui, Color, %col_window%
Gui, +Toolwindow -Resize +SysMenu -Border +Caption +AlwaysOnTop +LastFound
WinGet, guiid, ID
WinSet, Transparent, %c_transp_out%

; red blinking dot while running
Gui,Font,c%col_working% s20, Lucida Sans Unicode
Gui, Add, Text, x20 y33 h65 +Center vWorking, 

; timer time
Gui, Font,c%col_timer% s42,Consolas
GUI, Add, Text, x45 y20 w147 h52 +Center vTimerText gStartStop, 05:00

; up/down symbols for adjusting the time
Gui, Font,c%col_updown% s12,Lucida Sans Unicode
Gui, Add, Text, x50 y5 w20 h15 Center gUp4, %c_up%
Gui, Add, Text, x78	yp w20 h15 Center gUp3, %c_up%
Gui, Add, Text, x132 yp w20 h15 Center gUp2, %c_up%
Gui, Add, Text, x160 yp w20 h15 Center gUp1, %c_up%
Gui, Add, Text, x50 y75 w20 h15 +Center gDown4, %c_down%
Gui, Add, Text, x78	yp w20 h15 +Center gDown3, %c_down%
Gui, Add, Text, x132 yp w20 h15 +Center gDown2, %c_down%
Gui, Add, Text, x160 yp w20 h15 +Center gDown1, %c_down%

; preset number for 5-60 minutes
Gui, Font,c%col_preset% s10,Consolas
Gui, Add, Text, x195 y5 w20 h15 Center gSet5, 5
Gui, Add, Text, xp yp+15 w20 h15 Center gSet10, 10
Gui, Add, Text, xp yp+15 w20 h15 Center gSet15, 15
Gui, Add, Text, xp yp+15 w20 h15 Center gSet20, 20
Gui, Add, Text, xp yp+15 w20 h15 Center gSet25, 25
Gui, Add, Text, xp yp+15 w20 h15 Center gSet30, 30
Gui, Add, Text, x215 y5 w20 h15 Center gSet35, 35
Gui, Add, Text, xp yp+15 w20 h15 Center gSet40, 40
Gui, Add, Text, xp yp+15 w20 h15 Center gSet45, 45
Gui, Add, Text, xp yp+15 w20 h15 Center gSet50, 50
Gui, Add, Text, xp yp+15 w20 h15 Center gSet55, 55
Gui, Add, Text, xp yp+15 w20 h15 Center gSet60, 60

; Text toggle for sleep mode
Gui, Font,s20,Lucida Sans Unicode
Gui, Add, Text, x105 y70 vSleepModeText gSleepModeToggle, %c_emptycircle%

; Text toggle for loop mode
Gui, Add, Text, x105 y-5 vLoopMode gLoopModeDown, %c_leftright%

; hidden defailt button for closing on ENTER
; ESC is already caught by GUI window
Gui, Add, Button, x-10 y-10 w1 h1 +default hidden Ggtfo , Exit

; ------------------------- SHOW TIMER --------------------------------------

SysGet, MonArea, MonitorWorkArea
showx := MonAreaRight-245
showy := MonAreaBottom-100

if (%0%) {
	command = %1%
	if (command = "CENTER") {
		command = Center
	} else if (command ="TOPLEFT") {
		command = X0 Y0
	} else if (command="TOPRIGHT") {
		command = X%showx% Y0
	} else if (command="BOTTOMLEFT") {
		command = X0 Y%showy%
	} else if (command="BOTTOMRIGHT") {
		command = X%showx% Y%showy%
	} else {	
		command = Center
	}
} else {
	command = Center
}
Gui, Show, W245 H100 %command%
Return

;-------------------- OnMouseOver --------------------

OnMouseMove(wParam, lParam, msg, hwnd)
{
	global mouseover, c_transp_over, c_transp_out, guiid

	if (mouseover) {
		sleep, 500
		return
	}
	mouseover := true
	steps := (c_transp_over - c_transp_out) // 20
	trans := c_transp_out
	loop, %steps%
	{
		trans += 20
		WinSet, Transparent, %trans%, ahk_id %guiid%
		sleep, 10
	}
	WinSet, Transparent, %c_transp_over%, ahk_id %guiid%
	settimer,ismouseover,600
}

ismouseover:
	Coordmode, Mouse, Screen
	MouseGetPos, mx, my 
	WinGetPos, x, y, w, h, ahk_id %guiid%
	if ((mx<x ) OR (mx>(mx+w)) OR (my<y) OR (my>(y+h))) {
		settimer, ismouseover, OFF
		steps := (c_transp_over - c_transp_out) // 20
		trans := c_transp_over
		loop, %steps%
		{
			trans -= 20
			WinSet, Transparent, %trans%, ahk_id %guiid%
			sleep, 10
		}
		WinSet, Transparent, %c_transp_out%, ahk_id %guiid%
		mouseover := false
	} 
Return

;--------------------------- Start and Stop Timer ----------------------------

StartStop:
	half := false
	updating := false
	GuiControl, Text, Working, 
	if (started) {
		started := false
		SetTimer, cycledown, OFF
	} else {
		started := true
		stoptime := A_NOW
		envAdd, stoptime, %timer%, S
		SetTimer, cycledown, 500
		goto cycledown
	}
Return

;----------------------------- Up/Down Buttons -------------------------------

Up1:
	if (timer<5999)
		changeTimer(1)
Return

Up2:
	if (timer<5989)
		changeTimer(10)
Return

Up3:
	if (timer<5939)
		changeTimer(60)
Return

Up4:
	if (timer<5399)
		changeTimer(600)
Return

Down1:
	if (timer>1)
		changeTimer(-1)
Return

Down2:
	if (timer>10)
		changeTimer(-10)
Return

Down3:
	if (timer>60)
		changeTimer(-60)
Return

Down4:
	if (timer>600)
		changeTimer(-600)
Return

changeTimer(seconds) {
	global timer, stoptime, started, updating
	timer += seconds
	updating := true
	GoSub UpdateTimerLabel
	if (started) {
		stoptime := A_Now
		EnvAdd, stoptime, timer, S
	}
	updating := false
}

;----------------------- Timer Presets ---------------------------------

Set5:
	PresetTimerMinutes(5)
Return

Set10:
	PresetTimerMinutes(10)
Return

Set15:
	PresetTimerMinutes(15)
Return

Set20:
	PresetTimerMinutes(20)
Return

Set25:
	PresetTimerMinutes(25)
Return

Set30:
	PresetTimerMinutes(30)
Return

Set35:
	PresetTimerMinutes(35)
Return
Set40:
	PresetTimerMinutes(40)
Return

Set45:
	PresetTimerMinutes(45)
Return

Set50:
	PresetTimerMinutes(50)
Return

Set55:
	PresetTimerMinutes(55)
Return

Set60:
	PresetTimerMinutes(60)
Return

PresetTimerMinutes(minutes) {
	global preset, timer, stoptime, started, updating
	preset := minutes
	timer := (minutes * 60)
	updating := true
	GoSub UpdateTimerLabel
	if (started) {
		stoptime := A_Now
		EnvAdd, stoptime, timer, S
	}
	updating := false
}

; -------------------- Sleep Mode Toggle ----------------------------

SleepModeToggle:
	if (sleepmode) {
		sleepmode := false
		GuiControl, Text, SleepModeText, %c_emptycircle%
	} else {
		sleepmode := true
		GuiControl, Text, SleepModeText, %c_fullcircle%
	}
Return

; ----------------- Loop Mode Adjust ---------------

LoopModeDown:
	if (loopmode) {
		loopmode := false
		Gui, Font, c%col_updown% normal bold s20, Lucida Sans Unicode
		GuiControl, Font, LoopMode
	} else {
		loopmode := true
		Gui, Font, cFFFFFF normal bold s20, Lucida Sans Unicode
		GuiControl, Font, LoopMode
	}
Return

; ----------------- Update Timer Time -----------------------------

UpdateTimerLabel:
	tmp1 := timer // 60
	tmp2 := timer - (tmp1 * 60)
	tmpstr  := ""
	if (tmp1 < 10)
		tmpstr := "0"
	tmpstr := tmpstr . tmp1 . ":"
	if (tmp2 < 10) 
		tmpstr := tmpstr . "0"
	tmpstr := tmpstr . tmp2
	GuiControl, Text, TimerText, %tmpstr%
Return

; ----------------- Actual Work / Cycles -----------------------------

cycledown:
	if (half) {
		half := false
		GuiControl, Text, Working, 
	} else {
		half := true
		GuiControl, Text, Working, %c_working%
	}
	if (updating)
		Return
	timer := stoptime
	; 'timer' is only a helper variable for setting the time.
	; Actual timer uses the system clock to calculate the stop time
	EnvSub timer, A_Now, S
	GoSub UpdateTimerLabel
	If (A_Now >= stoptime) {
		mouseover := true
		WinSet, Transparent, %c_transp_over%, ahk_id %guiid%
		GuiControl, Text, Working, %c_working%
		SoundBeep, 4800, 20
		GuiControl, Text, Working, 
		Sleep, 120
		GuiControl, Text, Working, %c_working%
		SoundBeep, 4800, 20
		GuiControl, Text, Working, 
		Sleep, 120
		GuiControl, Text, Working, %c_working%
		SoundBeep, 4800, 20
		settimer, ismouseover, 3000

		GoSub StartStop

		MsgBox, 0, Time's up, Please check you work!, %Secs%

		PresetTimerMinutes(preset)

		If (sleepmode) {
			; turn off sleep mode to avoid accidential 
			; sleep mode once the computer comes back on
			GoSub SleepModeToggle
			DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
		} else if (loopmode) {
			GoSub StartStop
		}
	}
Return

;---------------------- Clean-Up -------------------------

gtfo:
ExitApp

GuiEscape: 
GuiClose:
ExitApp