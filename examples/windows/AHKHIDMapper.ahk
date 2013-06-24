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
DEFAULT_ARGUMENTS=-pFoot

VarSetCapacity(si,44)
DllCall("GetNativeSystemInfo", "uint", &si)
if ErrorLevel {
    MsgBox Windows XP or later required.
    ExitApp
}
arc := NumGet(si,0,"ushort")

if arc {
    HIDHELVEPATH=%A_ScriptDir%\x64\HIDHelve.exe
} else {
    HIDHELVEPATH=%A_ScriptDir%\x86\HIDHelve.exe
}
	
Gui, Font, s8 c000000, Consolas
Gui, Color,, 3F3F3F

Gui, Add, Tab2, x-4 y-0 w750 w400 -Wrap vTabs gTabs, Watch HidHelve|Quick View
Gui, Tab, Quick View                     
FileRead, TCode, %A_ScriptFullPath%
Gui, Font, s10 cFFFFFF, Consolas                                                                        
Gui, Color,, 3F3F3F
Gui, Add, Edit, vTCode x10 y30 h250 w300 gTCode -Wrap +WantTab
+VScroll +HScroll t14 BackgroundTrans hwndTCodeHwnd, % TCode
Gui, Font, s10 cEDEDCD, Consolas

Gui, +Resize +HwndMainHwnd ;+ToolWindow +E0x40000

Gui, Tab, Watch
Gui, Color,, 3F3F3F
Gui, Font, s10 cFFFFFF, Consolas
Gui, Add, Edit, VScroll HScroll w400 h300 x10 y30 vInfoOut -Wrap HwndInfoHwnd
Gui, Font, s10 c3F3F3F, Consolas
GUI, Add, Button, vClearOutput x410 y30 gClearOutput, Clear Output
Gui, Add, Checkbox, vShowHidHelve, Show HidHelve?
Gui, Font, s10 cFFFFFF, Consolas
Gui, Add, Edit, R1 vHidHelveArguments, %DEFAULT_ARGUMENTS%
Gui, Font, s10 c3F3F3F, Consolas
GUI, Add, Button, vStart x410 y120 gStart, Start HIDHelve
GUI, Add, Button, vKill x410 y150 gKill, Kill HIDHelve
GUI, Add, Button, vListDevices x410 y180 gListDevices, List Devices
GUI, Add, Button, vExit x410 y210 gExit, Exit %AppTitle%
Gui, Font, s10 cFFFFFF, Consolas
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
			/*
			http://www.autohotkey.com/docs/commands/Send.htm
			http://www.autohotkey.com/board/topic/41510-is-there-any-way-to-get-shift-to-toggle-like-caps-lock/
			*/
			Send {Blind}{LShift Down}
			if GetKeyState("Ctrl", "P")
				SoundPlay *-1
		} else if(cs=0) {
		        Send {Blind}{Ctrl Up}
			Send {Blind}{LShift Up}			
		} else if(cs=1 && ps=1) {
			IfWinActive , Microsoft Visual Studio
			{
				Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
			}
		        Send {Blind}{Ctrl Down}
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
		MsgBox CreateFile function returned an error.`nSystem Error Code: %a_lasterror%`n`n controlling HIDHelve failed. (%message%)`n`nExiting
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
	runOpts=UseErrorLevel
	SetWorkingDir %A_ScriptDir%
	GuiControlGet, ShowHidHelve,, ShowHidHelve
	if ShowHidHelve=1
		runOpts=%runOpts%
	else
		runOpts=%runOpts%|Hide
        GuiControlGet, HidHelveArguments
	Run "%HIDHELVEPATH%" "%HidHelveArguments%",,%runOpts% 
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

ClearOutput:
   GuiControlGet, InfoOut
   GuiControl, , InfoOut 
   SendMessage, 0x115, 0x0000007, 0, , ahk_id %InfoHwnd%
Return

Start:        
	HIDHelveCreatePublishingSlot()
	goto ClearOutput
Return

Kill:
	HIDHelveClosePublishingSlot()
	goto ClearOutput
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
BY := A_GuiHeight - 40
TCH := BY - 50
InfoW := A_GuiWidth - 160
InfoC := A_GuiWidth - 145
 
GuiControl, Move, Tabs, w%A_GuiWidth% h%A_GuiHeight% 
GuiControl, Move, InfoOut, w%InfoW% h%BY% 
GuiControl, Move, TCode, w%TCW% h%BY% 

GuiControl, Move, TCode, w%TCW% h%BY% 
GuiControl, Move, ClearOutput, x%InfoC%
GuiControl, Move, ShowHidHelve, x%InfoC%
GuiControl, Move, HidHelveArguments, x%InfoC%
GuiControl, Move, Start, x%InfoC%
GuiControl, Move, Kill, x%InfoC%
GuiControl, Move, ListDevices, x%InfoC%
GuiControl, Move, Exit, x%InfoC%
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

ListDevices:
objShell := ComObjCreate("WScript.Shell")
LISTDEVICES=%HIDHELVEPATH% -l
objExec := objShell.Exec(LISTDEVICES)
strStdOut := ""
while, !objExec.StdOut.AtEndOfStream
    strStdOut := objExec.StdOut.ReadAll()
InfoOutput(strStdOut)
Return


Exit:
GuiEscape:
GuiClose:
	Menu, Tray, NoIcon
	HIDHelveClosePublishingSlot()
	Gui, Submit
	ExitApp