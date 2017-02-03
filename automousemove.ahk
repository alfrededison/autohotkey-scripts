#Persistent
SetTimer, WatchActiveWindow, 100
return  ; End of auto-execute section

WatchActiveWindow:
WinGet, active_id, ID, A
if active_id = %last_active_id%  ; Same window as before, so do nothing.
    return
; Otherwise, the active window has changed.
last_active_id = %active_id%

; Ignore mouse click
if (GetKeyState("LButton") or GetKeyState("RButton"))
	return

WinGetActiveTitle, title
if !title
	return

moveMouseCenter:
	; move cursor to center:
	WinGetPos, , , center_x, center_y, A  ; Get size of the active window.
	center_x /= 2  ; Divide each by 2
	center_y /= 2
	MouseMove, %center_x%, %center_y%
return