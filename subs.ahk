#SingleInstance force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;MsgBox %1%
;ExitApp

Hotkey, §, goex
Hotkey, 1, syncplus
Hotkey, 2, syncminus

Hotkey, 3, ssminus
Hotkey, 4, ssplus

Hotkey, q, fontminus
Hotkey, w, fontplus

Hotkey, a, tup
Hotkey, s, tdown

SysGet,s_width, 16
SysGet,s_widthv, 78

s_xx:=(s_widthv-s_width)
s_width:=s_widthv
s_xx:=s_xx/2

SysGet,s_height, 79
s_fontsize:=50
s_yy=100

IniRead, s_fontsize, settings.ini,sub,fontsize,50
IniRead, s_yy, settings.ini,sub,from_bottom,100
IniRead, s_sub_second, settings.ini,sub,sub_second,965

start:=A_TickCount

Loop %1%, 1
	fn = %A_LoopFileLongPath%

f_srt:=RegExMatch(fn,"i)[.]srt$")
f_sub:=RegExMatch(fn,"i)[.]sub$")

Loop, read, %fn%
{
	if (f_sub>0)	
	{
		if (A_Index = 1)
		{
			; get frame time
			RegExMatch(A_LoopReadLine, "[}]([^}]+)$",ar)
			ftime:=1/Round(ar1)*s_sub_second
		}
		if (A_Index > 1)
		{
			now:=A_TickCount
			RegExMatch(A_LoopReadLine, "{(.*?)}{(.*?)}([^§]+)$",ar)
			ta:=ar1*ftime
			tb:=ar2*ftime
			l:=tb-ta
			sub:=RegExReplace(ar3,"[|]","`n")
			w:=ta-(now-start)
			Sleep w
			subtitle(sub,l)			
		}
	}
	
	if (f_srt>0)
	{
		f := RegExMatch(A_LoopReadLine, "^\d+$")
		if (f>0)
		{
			nexti:=0
			sub := RegExReplace(sub, "^`n", "")
			sub := RegExReplace(sub, "`n$", "")
			subtitle(sub,l)
			continue
		}
		
		if (nexti = 2)
		{
			sub:=sub "`n" A_LoopReadLine
		}
		; matching : 00:01:06,367 --> 00:01:08,801
		f := RegExMatch(A_LoopReadLine, "^(\d\d):(\d\d):(\d\d),(\d\d\d) --[>] (\d\d):(\d\d):(\d\d),(\d\d\d)$",ar)
		if (f>0)
		{
			now:=A_TickCount
			ta:= Round(ar1)*3600000 + Round(ar2)*60000 + Round(ar3)*1000 + Round(ar4)
			tb:= Round(ar5)*3600000 + Round(ar6)*60000 + Round(ar7)*1000 + Round(ar8)
			l:=tb-ta
			nexti:=2
			w:=ta-(now-start)
			Sleep w
			sub:=""
		}
	}
}

subtitle(sub,millisecs)
{
	global s_width,s_height,s_fontsize,s_yy,s_xx
	h:=0
	Loop, parse, sub, `n
	{
		h:=h + s_fontsize +s_fontsize*0.6
	}
	y:=s_height-h-s_yy
	Progress,W%s_width% X%s_xx% Y%y% B H%h% ZH0 ZW0 FS%s_fontsize% CTffffff CW000000
	;Progress,W1000 H B ZX0 ZY0 ZH0 FS50 CTffffff CW000000
	;WinSet, TransColor, fefefe, %A_ScriptName%
	WinSet,Transparent,150, %A_ScriptName%
	Progress,,%sub%
	Sleep %millisecs%
	Progress, Off
}

show_info(){
	global s_width,s_height,s_fontsize,s_yy,s_xx,s_sub_second,start
	Traytip,,fs=%s_fontsize% yy=%s_yy% sub=%s_sub_second% start=%start%
}

tup:
s_yy:=s_yy+10
show_info()
return

tdown:
s_yy:=s_yy-10
show_info()
return

fontplus:
s_fontsize:=s_fontsize+1
show_info()
return

fontminus:
s_fontsize:=s_fontsize-1
show_info()
return

ssplus:
s_sub_second:=s_sub_second+2
show_info()
Sleep -1
return

ssminus:
s_sub_second:=s_sub_second-2
show_info()
Sleep -1
return

syncplus:
start:=start+250
show_info()
Sleep -1
return

syncminus:
start:=start-250
show_info()
Sleep -1
return

goex:
ExitApp
return