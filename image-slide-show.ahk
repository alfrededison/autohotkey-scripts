#SingleInstance, Off

; Pre-load and reuse some images.

Pics := []

SelectFolder:
; Find some pictures to display.
FileSelectFolder, OutputVar, , 3
if OutputVar =
{
    MsgBox, You didn't select a folder.
    ExitApp
}

Loop, Files, %OutputVar%\*.jpg
{
    ; Load each picture and add it to the array.
    Pics.Push(LoadPicture(A_LoopFileFullPath))
}
if !Pics.Length()
{
    ; If this happens, edit the path on the Loop line above.
    MsgBox, No pictures found!  Try a different directory.
    Goto, SelectFolder
}

Gui, -Caption +ToolWindow +0x400000
Gui, Margin, 0, 0
Gui, +AlwaysOnTop
; Add the picture control, preserving the aspect ratio of the first picture.
Gui, Add, Pic, w-1 h200 vPic Border Center GuiMove, % "HBITMAP:*" Pics.1
Gui, Show
Loop 
{
    ; Switch pictures!
    GuiControl, , Pic, % "HBITMAP:*" Pics[Mod(A_Index, Pics.Length())+1]
    Sleep 30000
}
Return

uiMove:
PostMessage, 0xA1, 2,,, A 
Return

GuiClose:
ExitApp