/* Written by: Dave Horner
   Date: 1/1/2013
   http://dave.thehorners.com/tech-talk/projects-research/455-horners-hidhelve
*/

#SingleInstance force
#NoEnv
DetectHiddenWindows, On
OnMessage(0x112, "WM_SYSCOMMAND")
AppTitle=AHKHIDMapper
mySlotHandle=-1


VarSetCapacity(si,44)
DllCall("GetNativeSystemInfo", "uint", &si)
if ErrorLevel {
    MsgBox Windows XP or later required.
    ExitApp
}
arc := NumGet(si,0,"ushort")
if arc {
    HIDHELVEPATH=x64\HIDHelve
} else {
    HIDHELVEPATH=x86\HIDHelve
}
MsgBox %HIDHELVEPATH%
	
Gui, Font, s8 c000000, Consolas
Gui, Color,, 3F3F3F

Gui, Add, Tab2, x-4 y-0 w750 h850 -Wrap vTabs gTabs, Watch|Quick Editor
Gui, Font, s10 cEDEDCD, Consolas
Gui, Color,, 3F3F3F
Gui, Tab, Quick Editor
FileRead, TCode, %A_ScriptFullPath%
Gui, Add, Edit, vTCode x10 y30 h250 w300 gTCode -Wrap +WantTab
+VScroll +HScroll t14 BackgroundTrans hwndTCodeHwnd, % TCode
Gui, Font
Gui, Add, Button, w100 h20 yp+255 vRTCode, Run
Gui, Add, Button, w100 h20 yp xp+100 vGTCode, Gist
Gui, Add, Button, w100 h20 yp xp+100 vPTCode, Paste

Gui, +Resize +HwndMainHwnd ;+ToolWindow +E0x40000

Gui, Tab, Watch
Gui, Font, s10 cEDEDCD, Consolas
Gui, Color,, 3F3F3F
Gui, Add, Edit, VScroll HScroll w400 h300 x10 y30 vInfoOut -Wrap HwndInfoHwnd
GUI, Add, Button, gClearOutput x+0 y30, Clear Output
GUI, Add, Button, gStart x+0 y30, Start HIDHelve
GUI, Add, Button, gKill x+0 y75, Kill HIDHelve
GUI, Add, Button, gExit x+0 y75, Exit %AppTitle%
Gui, Show, , %AppTitle%

HIDHelveCreatePublishingSlot()
SetTitleMatchMode 2
loop
{
	HIDHelveReadPublishedData(eventData,cs, ps)
	if(eventData) {
		InfoOutput(eventData)
		if(cs=4 && ps=4) {
			if(GetKeyState("LWin", "P")) {				
				Hotkey, LWin, Blank, On
				IfWinActive, %AppTitle%
				{
					WinMinimize, %AppTitle%
					Gui, Hide
				} else {
					WinActivate, %AppTitle%
					Gui, Show
					WinRestore, %AppTitle%
				}
			}
		} else if(cs=2 && ps=2) {
			IfWinActive , Microsoft Visual Studio
			{
				SendInput +^{b}
				continue
			}
			if GetKeyState("Ctrl", "P")
				SoundPlay *-1
		} else if(cs=0) {
			
		} else if(cs=1 && ps=1) {
			Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
		}	
	}
}
HIDHelveClosePublishingSlot()
exitapp


HIDHelveSendControl(message)
{
	hidSlotName = \\.\mailslot\hornersHidHelveControlSlot
	hidSlotHandle := DllCall("CreateFile",Str,hidSlotName,UInt,0x40000000,UInt,3,UInt,0,UInt,3,UInt,0,UInt,0)
	If( hidSlotHandle> 0) {
		DllCall("WriteFile", uint, hidSlotHandle, str, message, uint, StrLen(message)+1, uintp,0, uint,0)
		DllCall("CloseHandle", "Ptr", hidSlotHandle)
	} else {
		MsgBox controlling HIDHelve failed. (%message%)
	}
}

HIDHelveReadPublishedData(ByRef dstCurrentWholeEvent, ByRef dstCurrentState, ByRef dstPriorState)
{
	global mySlotHandle
    if(mySlotHandle>0) {
        BytesToRead := 512
        VarSetCapacity(ReadBuffer, BytesToRead, 0)
        DLLCall("ReadFile",UInt,mySlotHandle,str,ReadBuffer,UInt,BytesToRead-1,UIntP,BytesActuallyRead,UInt,0)
        if(!errorlevel) {
            if(BytesActuallyRead>0) {
                StringSplit, S,ReadBuffer, `, ,`n, `r
                tmpOut=%S0% | %S1% | %S2% | %S3% | %S4%
                dstCurrentWholeEvent=%tmpOut%
                dstCurrentState=%S1%
                dstPriorState=%S3%
                return
            }
        } else {
            mySlotHandle=-1;
        }
    } else {
    }
	dstCurrentWholeEvent=0
}

HIDHelveCreatePublishingSlot()
{
	global mySlotHandle,HIDHELVEPATH
	SlotTimeout=50 ;0=no wait, -1=forever, else milliseconds.
    if(mySlotHandle=-1) {
        mySlotName = \\.\mailslot\hornersHidHelvePublishSlot
        mySlotHandle:=DLLCall("CreateMailslot",str,mySlotName,UInt,0,UInt,SlotTimeout,UInt,0)
        if (errorlevel) {
            clipboard = http://msdn.microsoft.com/en-us/library/ms681381(v=VS.85).aspx	
            MsgBox CreateMailSlot function returned an error.`nSystem Error Code: %a_lasterror%`n`nLink to error codes is on clipboard.`n`nExiting
            ;exitapp
        }
    }
	Run %HIDHELVEPATH% -pFoot,,Hide|UseErrorLevel
	if A_ErrorLevel
		MsgBox HIDHelve could not be launched %A_ErrorLevel%.

}

HIDHelveClosePublishingSlot()
{
	global mySlotHandle
	;signal to hidmapper we are quiting!.
	HIDHelveSendControl(quit!)
	DllCall("CloseHandle", "Ptr", mySlotHandle)
    mySlotHandle=-1
}

InfoOutput(Text)
{
   global InfoHwnd
   GuiControlGet, InfoOut
   NewText := InfoOut . Text
   GuiControl, , InfoOut, %NewText% `r`n
   SendMessage, 0x115, 0x0000007, 0, , ahk_id %InfoHwnd%
   return
}
CodeOutput(Text)
{
   GuiControlGet, CodeOut
   IfNotInString, CodeOut, %Text%
   {
      NewText := CodeOut . Text
      GuiControl, , CodeOut, %NewText%
   }
   return
}

AppendOutput(Text)
{
   global EditHwnd
   GuiControlGet, EditOut
   NewText := EditOut . Text
   GuiControl, , EditOut, %NewText%
   ; WM_VSCROLL (0x115), SB_BOTTOM (7)
   ;MsgBox, %EditHwnd%
   SendMessage, 0x115, 0x0000007, 0, , ahk_id %EditHwnd%
   return
}

Start:
	HIDHelveCreatePublishingSlot()
	GuiControlGet, InfoOut
	GuiControl, , InfoOut 
	SendMessage, 0x115, 0x0000007, 0, , ahk_id %InfoHwnd%
	GuiControlGet, InfoOut
Return

Kill:
	HIDHelveClosePublishingSlot()
	GuiControlGet, InfoOut
	GuiControl, , InfoOut 
	SendMessage, 0x115, 0x0000007, 0, , ahk_id %InfoHwnd%
	GuiControlGet, InfoOut
Return

ClearOutput:
   GuiControlGet, InfoOut
   GuiControl, , InfoOut 
   SendMessage, 0x115, 0x0000007, 0, , ahk_id %InfoHwnd%
Return

F10::Reload

Tabs:
;Gui, Submit, NoHide
;Gui, +OwnDialogs
Return
 
GuiSize:
if !(A_GuiWidth || A_GuiHeight)
	return
TCW := A_GuiWidth - 30
BSize := (A_GuiWidth - 30) / 3
BY := A_GuiHeight - 40
TCH := BY - 10
BX1 := 5
BX2 := BX1 + BSize
BX3 := BX2 + BSize
 
;gosub, TCode
GuiControl, Move, Tabs, w%TCW% h%TCH% 
GuiControl, Move, TCode, w%TCW% h%TCH% 
GuiControl, Move, RTCode, w%BSize% y%BY% x%BX1%
GuiControl, Move, GTCode, w%BSize% y%BY% x%BX2%
GuiControl, Move, PTCode, w%BSize% y%BY% x%BX3%
return
 
TCode:
GuiControlGet, TCode
Size := GetSize(TCode)
if (Size.W > TCW)
	SB_Show(TCodeHwnd, "H")
else
	SB_Hide(TCodeHwnd, "H")
if (Size.H > TCH)
	SB_Show(TCodeHwnd, "V")
else
	SB_Hide(TCodeHwnd, "V")
return
 
 
ClearTip:
ToolTip
return
 
ButtonRun:
return
 
RTCode:
Gui, Submit, NoHide
FileDelete, Test.ahk
FileAppend, %TCode%, Test.ahk, UTF-8 ; Make sure unicode
Run, Test.ahk
WinWait, %TestTitle%,, 1
GuiControl, Text, RTCode, Kill
while(WinExist(TestTitle))
	Sleep, 500
GuiControl, Text, RTCode, Run
return
 
 
 
ButtonSave: ; Need to clean this up
Gui, Submit, NoHide
InputBox, Name, Script Name, Choose a name for your script (No trailing ".ahk")
if Name =
	return
FileAppend, %TCode%, %Name%.ahk, UTF-8
return
 
 
 
ButtonGist:
Gui, Submit, NoHide
 
Gui, Gist:New, +Owner1 +ToolWindow
Gui, Add, Text, Section ym+2 w50 +Center, Username
Gui, Add, Text, w50 +Center, Password
Gui, Add, Text, w50 +Center, Gist Title
Gui, Add, CheckBox, yp+28 w50 +Center checked vPublic, Public
Gui, Add, Edit, ys-2 xs+58 w100 vUser, %DefaultUser%
Gui, Add, Edit, w100 +Password vPass, %DefaultPass%
Gui, Add, Edit, w100 vTitle, %DefaultTitle%
Gui, Add, Button, w100 h20 gGistButtonGist, Paste Gist
Gui, Show,, %Title% - Gist
return
 
GistButtonGist:
Gui, Submit
Gui, Destroy
 
DefaultUser := User
DefaultPass := Pass
 
Link := Gist(TCode, User, Pass, Title, Public)
MsgBox, 292, %Title%, Link aquired:`n%Link%`n`nCopy to clipboard?
IfMsgBox, Yes
	Clipboard := Link
return
 
 
 
ButtonPaste:
Gui, Submit, NoHide
 
Gui, Paste:New, +Owner1 +ToolWindow
Gui, Add, Edit, w100 vDesc, %DefaultDesc%
Gui, Add, Edit, w100 vAuthor, %DefaultAuthor%
Gui, Add, Checkbox, y+9 w50 vPublic, Public
Gui, Add, Button, Default yp-5 xp+50 w50, Paste
Gui, Show,, %Title% - Paste
return
 
PasteButtonPaste:
Gui, Submit
Gui, Destroy
return
 
GetSize(Text, DefaultGUI = 1, Font="Consolas", Size="10")
{
	static
	if (SubStr(Text, -0, 1) = "`n")
		Text .= "F" ; "F" for "Windows FAILS"
	Gui, New
	Gui, Font, s%Size%, %Font%
	Gui, Add, Edit, vCntrl +VScroll +HScroll, %Text%
	GuiControlGet, Cntrl, Pos
	Gui, Destroy
	Gui, %DefaultGUI%:Default
	return {"X":CntrlX, "Y":CntrlY, "W":CntrlW+1, "H":CntrlH-2} ;CntrlW
}
 
Gist(Code, NewUser="", NewPass="", Title="AutoHotkey", Public="1")
{
	static Basic, User, Pass
	
	if (User != NewUser || Pass != NewPass) ; If new credentials
	{
		User := NewUser
		Pass := NewPass
		if (User && Pass) ; If not blank
			Basic := Base64(User ":" Pass) ; Create new basic auth code
		else
			Basic := ; Don't auth (anonymous)
	}
	
	Public := Public ? "true" : "false"
	Code := SanitizeJSON(Code)
	
	JSON = {"public":"%Public%","files":{"%Title%":{"content":"%Code%"}}}
	
	Github := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Github.Open("POST", "https://api.github.com/gists")
	if (Basic)
		Github.SetRequestHeader("authorization", "basic " Basic)
	Github.Send(JSON)
	
	If !RegExMatch(Github.ResponseText, """html_url""\:""(.*?)""", Out)
		throw Github.ResponseText
	return Out1
}
 
Base64(string)
{ ; http://www.autohotkey.com/forum/viewtopic.php?t=5896
   Loop Parse, string
   {
      If Mod(A_Index,3) = 1
         buffer := Asc(A_LoopField) << 16
      Else If Mod(A_Index,3) = 2
         buffer += Asc(A_LoopField) << 8
      Else {
         buffer += Asc(A_LoopField)
         out := out . Code(buffer>>18) . Code(buffer>>12) . Code(buffer>>6) . Code(buffer)
      }
   }
   If Mod(StrLen(string),3) = 0
      Return out
   If Mod(StrLen(string),3) = 1
      Return out . Code(buffer>>18) . Code(buffer>>12) "=="
   Return out . Code(buffer>>18) . Code(buffer>>12) . Code(buffer>>6) "="
}
 
Code(i)     ; <== Chars[i & 63], 0-base index
{
   static Chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   StringMid i, Chars, (i&63)+1, 1
   Return i
}
 
SanitizeJSON(J)
{
	StringReplace, J, J, \, \\, All
	StringReplace, J, J, `b, \b, All
	StringReplace, J, J, `f, \f, All
	StringReplace, J, J, `n, \n, All
	StringReplace, J, J, `r, \r, All
	StringReplace, J, J, `t, \t, All
	StringReplace, J, J, `", \`", All
	return J
}
  
; http://www.autohotkey.com/board/topic/29912-sb-functions-for-scrollbar/
SB_Show(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Return DllCall("ShowScrollBar", "uInt", Hwnd, "Int", Which, "Int", 1)
}
 
SB_Hide(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Return DllCall("ShowScrollBar", "uInt", Hwnd, "Int", Which, "Int", 0)
}

DisableCloseButton(HWND = "", A = True) {
   HWND := ((HWND + 0) ? HWND : WinExist("A"))
   HMNU := DllCall("GetSystemMenu", "UInt", HWND, "UInt", A ? False : True)
   DllCall("EnableMenuItem", "UInt", HMNU, "UInt", 0xF060, "UInt", A ? 0x3 : 0x0)
   Return DllCall("DrawMenuBar", "UInt", HWND)
}

WM_SYSCOMMAND(wParam)
{
	If (wParam = 61472) ; minimize
		SetTimer, Minimize, -1
	Else If (wParam = 61728) ; restore
		SetTimer, Restore, -1
	if (A_Gui = 1 && wParam = 0xF060) ; SC_CLOSE
    {
		WinMinimize
	return 0
    }
}


Blank:
	WinGet, maximized, MinMax, %AppTitle%
	if(maximized=-1) {
		Msgbox released
		Hotkey, LWin, Blank, Off
		Hotkey, ~LWin, Blank, Off
	} else {
	}
Return

Minimize:
	Critical
	Gui, Hide
	Menu, Tray, Icon
Return
   
Restore:
	Gui, Show
	Critical
	Menu, Tray, NoIcon
	Gui, Show
Return

Exit:
GuiEscape:
GuiClose:
	Menu, Tray, NoIcon
    HIDHelveClosePublishingSlot()
	Gui, Submit
	ExitApp