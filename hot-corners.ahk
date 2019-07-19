
#NoEnv
#SingleInstance, Force
#MaxThreadsPerHotkey, 1
#KeyHistory, 0
#Persistent
ListLines, Off
SetBatchLines -1
SetWinDelay, -1
SetMouseDelay, -1
SetKeyDelay, -1, -1
SetTitleMatchMode, 3
DetectHiddenWindows, On
SetWorkingDir, %A_ScriptDir%
SendMode, Input
CoordMode, Mouse, Screen

CornerList :=
(LTrim Join
	{
		"TopLeft":		"TopLeft",
		"TopRight":		"TopRight",
		"BottomRight":	"BottomRight",
		"BottomLeft":	"BottomLeft"
	}
)
SetTimer, HotCorners, 10
Return

HotCorners:
	For Each, Item in CornerList
		CheckCorner(Each, Item)
	Return

TopLeft:
	Send, {LWin down}
	Send, {Tab}
	Send, {LWin up}
	Return
TopRight:
BottomLeft:
BottomRight:
	Return

IsCorner(CornerID) {
	Static T := 10, IsMouse := {}
	Mouse := MouseGetPos()
	IsMouse.TopLeft			:= (Mouse.Y < T) && (Mouse.X < T)
	IsMouse.TopRight		:= (Mouse.Y < T) && (Mouse.X > (A_ScreenWidth - T))
	IsMouse.BottomLeft		:= (Mouse.Y > (A_ScreenHeight - T)) && (Mouse.X < T)
	IsMouse.BottomRight		:= (Mouse.Y > (A_ScreenHeight - T)) && (Mouse.X > (A_ScreenWidth - T))

	Return, IsMouse[CornerID]
}

CheckCorner(Name, LabelOrFunc) {
	If (IsCorner(Name)) {
		If (IsLabel(LabelOrFunc))
			GoSub, % LabelOrFunc
		Else If (IsFunc(LabelOrFunc))
			%LabelOrList%(Name)
		Else
			Throw Exception("This is not a function!")
		Loop {
			If (!IsCorner(Name))
				Break
		}
	}
	Return
}

MouseGetPos(Options := 3) {
	MouseGetPos, X, Y, Win, Ctrl, % Options
	Return, {X: X, Y: Y, Win: Win, Ctrl: Ctrl}
}