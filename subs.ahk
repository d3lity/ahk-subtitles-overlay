#SingleInstance force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Hotkey, 1, syncplus
Hotkey, 2, syncminus
Hotkey, 3, ssplus
Hotkey, 4, ssminus
Hotkey, 5, toggle_frametime
t_framerate:=0

Hotkey, q, fontminus
Hotkey, w, fontplus
Hotkey, r, oup
Hotkey, e, odown
;Hotkey, t, toggle_transparency

Hotkey, p, toggle_pause

Hotkey, a, tup
Hotkey, s, tdown
Hotkey, d, change_alignment
Hotkey, f, toggle_fade

Hotkey, z, do_nothing
Hotkey, x, goex
Hotkey, c, monitorCoords

pause_start:=0

s_fontsize:=50
s_yy=100

; Read default settings from settings.ini

IniRead, s_fontsize, settings.ini,sub,fontsize,50
IniRead, s_yy, settings.ini,sub,from_bottom,100
IniRead, s_sub_second, settings.ini,sub,sub_second,1000
IniRead, s_opacity, settings.ini,sub,opacity,190
IniRead, s_font, settings.ini,sub,font,Verdana
opacity_factor:=s_opacity/11
IniRead, s_valign, settings.ini,sub,valign,bottom
IniRead, s_outline, settings.ini,sub,ouline,3
IniRead, s_fading, settings.ini,sub,fading,1
;s_fading:=0

;IniRead, s_transparency, settings.ini,sub,box_transparency,0

IniRead, monitor, settings.ini,sub,monitor,1
monitor:=monitor-1			; substract one because monitorCoords is toggling code
GoSub monitorCoords
;Gosub create_gui ; this is being done already while checking coordinates

;#Bookmark#
Gui 2:Add,Edit,r1 vSubSearch W360 section,
Gui 2:Add,Button,Default ys gSearch,>
Gui 2:Add,ListBox,W400 H300 vSubSelect AltSubmit gSubSelected xs,

;Gui 2:Add,Button,xs gtoggle_frametime,Toggle frametimes
Gui 2:Add,Button,xs Section gfontminus,FontSize-
Gui 2:Add,Button,ys gfontplus,FontSize+
Gui 2:Add,Button,ys goup,Opacity+
Gui 2:Add,Button,ys godown,Opacity-
;Hotkey, p, toggle_pause
Gui 2:Add,Button,ys gtup,up
Gui 2:Add,Button,ys gtdown,down
Gui 2:Add,Button,ys gchange_alignment,VAlign

Gui 2:Add,Button,xs Section gtoggle_fade, Fading?
Gui 2:Add,Button,ys gmonitorCoords, Monitor

Gui 2:Add,Button,ys ggoex,Quit


running:=1
framesPerSecond:=24

last_time:=A_TickCount
wait_till:=0
breaked_down:=0

Loop %1%, 1
	fn = %A_LoopFileLongPath%

f_srt:=RegExMatch(fn,"i)[.]srt$")
f_sub:=RegExMatch(fn,"i)[.]sub$")

break_out:=0

sub_number:=1
sub:=""
Loop, read, %fn%
{
	if (f_sub>0)	
	{
		if (A_Index = 1)
		{
			; get frame time
			RegExMatch(A_LoopReadLine, "[}]([^}]+)$",ar)
			framesPerSecond:=ar1
			ftime:=1/Round(framesPerSecond)*s_sub_second
		}
	
		if (A_Index > 1)
		{		
			subs%sub_number%:=A_LoopReadLine
			GuiControl,2:,SubSelect,%sub_number%`t%A_LoopReadLine%
			sub_number++
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
			if (sub!="")
			{				
				subs%sub_number%:=subs%sub_number% sub
				GuiControl,2:,SubSelect,%sub_number%`t%sub%
				sub_number++
			}
			continue
		}
		;#Bookmark#
		if (nexti = 2)
		{
			sub:=sub "`n" A_LoopReadLine
		}
		; matching : 00:01:06,367 --> 00:01:08,801
		f := RegExMatch(A_LoopReadLine, "^(\d\d):(\d\d):(\d\d),(\d\d\d) --[>] (\d\d):(\d\d):(\d\d),(\d\d\d)$",ar)
		if (f>0)
		{
			subs%sub_number%:=A_LoopReadLine
			nexti:=2
			sub:=""
		}
	}
}
Gui 2:-SysMenu
Gui 2:Show,,Gui for subtitles
;gui, 2:+owner1

;subtitle("Pausing for you to find play button",500)
;subtitle("In 5",1000)
;subtitle("In 4",1000)
;subtitle("In 3",1000)
;subtitle("In 2",1000)
;subtitle("In 1",1000)
subtitle("Push 'Play' Now!",1000)

on_line:=1
last_time:=A_TickCount
break_me:=0

While (on_line<sub_number)
{
	if (break_me>0)
		on_line:=break_me
		
	line:=subs%on_line%
	
	if (f_sub>0)
	{
			now:=A_TickCount
			RegExMatch(line, "{(.*?)}{(.*?)}([^§]+)$",ar)
			ta:=ar1*ftime
			tb:=ar2*ftime
			l:=tb-ta
			sub:=RegExReplace(ar3,"[|]","`n")
			;wait_till:=ta+start
			wait_till:=A_TickCount + ta-last_time
			bm:=break_me
			;if (wait_interruptable(wait_till)==1 AND bm==1)
			bm:=break_me
			wait_interruptable(wait_till)
			if (break_me==on_line AND bm>0)
			{
				break_me:=0
				last_time:=A_TickCount
			}
			center_online()
			last_time:=tb
			subtitle(sub,l)
	}
	
	if (f_srt>0)
	{
		; matching : 00:01:06,367 --> 00:01:08,801
		f := RegExMatch(line, "^(\d\d):(\d\d):(\d\d),(\d\d\d) --[>] (\d\d):(\d\d):(\d\d),(\d\d\d)([^§]+)$",ar)
		if (f>0)
		{
			now:=A_TickCount
			ta:= Round(ar1)*3600000 + Round(ar2)*60000 + Round(ar3)*1000 + Round(ar4)
			tb:= Round(ar5)*3600000 + Round(ar6)*60000 + Round(ar7)*1000 + Round(ar8)
			l:=tb-ta
			nexti:=2
			;wait_till:=start+ta
			wait_till:=A_TickCount + ta-last_time
			last_time:=tb
			bm:=break_me
			wait_interruptable(wait_till)
			if (break_me==on_line AND bm>0)
			{
				break_me:=0
				last_time:=A_TickCount
			}
			center_online()	
			subtitle(ar9,l)
		}
	}
	if (break_me==0)
		on_line++
}


subtitle("*** End of subtitles ***",2000)
Gui, Destroy
ExitApp

wait_interruptable(wait_till)
{
	global start,breaked_down,break_me
	while now<wait_till
	{
		Sleep 10
		now:=A_TickCount
		GetKeyState, z_key,z,P
		if (z_key="D")
		{			
			; Jump forward in time, so to speak
			start:=start-(wait_till-now)
			return 1
		}
		else
		{
			breaked_down:=0
		}
		if (break_me) {
			return 1
		}
	}
	return 0
}

subtitle(sub,millisecs)
{
	global s_width,s_height,s_fontsize,s_yy,s_xx,opacity_factor,s_opacity,breaked_down,s_valign,last_sub,s_transparency,s_fading,break_me
	
	if (break_me)
		return

	last_sub:=sub
	h:=s_fontsize*0.65
	Loop, parse, sub, `n
	{
		h:=h +s_fontsize*1.48
	}
	;h:=h+s_fontsize*0.8
	Loop,9
	{
		GuiControl,, St%a_Index%, %sub%
	}
	
	if (s_valign="top")
		y:=s_height-s_yy
	else
		y:=s_height-h-s_yy
	

	;Progress,W%s_width% X%s_xx% Y%y% B H%h% ZH0 ZW0 FS%s_fontsize% CTffffff CW000000
	GetKeyState, z_key,z,P
	if (z_key = "D" and breaked_down>1)
	{
		millisecs:=100
	}
	if (millisecs>500 and s_fading)
	{
		;WinSet,Transparent,0, %A_ScriptName%
		;WinSet, TransColor, 111111 0, %A_ScriptName%
		
		Gui 1: Show,Y%y% H%h% X%s_xx% NA,zsubtitles

		Loop 5{
			tp:=A_Index*opacity_factor
			;WinSet,Transparent,%tp%, %A_ScriptName%
			WinSet TransColor, 111111 %tp%, zsubtitles
			;%A_ScriptName%
			Sleep 25
		}
		;WinSet,Transparent,%s_opacity%, %A_ScriptName%
		WinSet, TransColor, 111111 %s_opacity%, zsubtitles
		;%A_ScriptName%
		now:=A_TickCount
		millisecs:=millisecs-250
		wait_till:=now+millisecs
		sleep_broken:=wait_interruptable(wait_till)
		Loop 5{
			tp:=(6-A_Index)*opacity_factor
			;WinSet,Transparent,%tp%, %A_ScriptName%
			WinSet, TransColor, 111111 %tp%, zsubtitles
			;%A_ScriptName%
			Sleep 25
		}
		if (sleep_broken)
		{
			breaked_down++
		}
		else
		{
			breaked_down:=0
		}
	}
	else
	{
		Gui 1: Show,Y%y% H%h% X%s_xx% NA,zsubtitles
		WinSet, TransColor, 111111 %s_opacity%,zsubtitles
		;Sleep %millisecs%
		wait_till:=A_TickCount+millisecs
		wait_interruptable(wait_till)
		GetKeyState, z_key,z,P
		if (z_key <> "D")
			breaked_down:=0
	}
	Gui 1:Hide

}

show_info(){
	global s_width,s_height,s_fontsize,s_yy,s_xx,s_sub_second,start
	Traytip,,fs=%s_fontsize% yy=%s_yy% sub=%s_sub_second% start=%start%
}

center_online()
{
	global on_line,sub_number
	
	o:=on_line-10
	if (o>1) 
		GuiControl 2:Choose, SubSelect, %o%
	o:=on_line+11
	if (o<sub_number) 
		GuiControl 2:Choose, SubSelect, %o%
	GuiControl 2:Choose, SubSelect, %on_line%
}
do_nothing:
Return


monitorCoords:														; --- changes current showing monitor ---

SysGet, mc, MonitorCount
monitor:=monitor+1
If (monitor>mc)
	monitor:=1
SysGet, Mon, Monitor, %monitor% 
s_width:=MonRight-MonLeft
s_xx:=MonLeft
s_height:=MonBottom
Gosub create_gui			; refresh gui, because different width maybe on other monitor
if (running)
	subtitle("Changed monitor ( " monitor " )",500)
Return

create_gui:
	Gui 1: Destroy
	Gui 1: +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui 1:Margin,0,0
	Gui 1: Color, 111111
	Gui 1: Font, s%s_fontsize% q2, %s_font%
	sub:="Example`nsubtitle"
	
	o1:=s_outline
	o2:=s_outline*2
	op:=o1+Round(s_outline/2)
	om:=o1-Round(s_outline/2)
	Gui 1: Add, Text, BackgroundTrans vSt1 x%o2% y%o1% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt2 x%o1% y0    Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt3 x0    y%o1% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt4 x%o1% y%o2% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt5 x%om% y%om% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt6 x%op% y%om% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt7 x%op% y%op% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt8 x%om% y%op% Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans vSt9 x%o1% y%o1% Center W%s_width% cFFFFFF, %sub%
Return

change_alignment:
if (s_valign="top")
{
	s_valign:="bottom"
	s_yy:=s_yy-(s_fontsize*3.7)
	subtitle("Alignment bottom",200)
}
else
{
	s_valign:="top"
	s_yy:=s_yy+(s_fontsize*3.7)
	subtitle("Alignment top",200)
}
return

toggle_fade:
s_fading:=Mod(s_fading+1,2)
;subtitle(last_sub,200)
Return

toggle_pause:
if (pause_start>0)
{
	pause_len:=A_tickcount-pause_start
	start:=start+pause_len
	pause_start:=0
	Pause, Off,1
	return
}
pause_start:=A_tickcount
Pause, On,1
return

tup:
s_yy:=s_yy+10
subtitle("* * * * * * * / \ * * * * * * *`n* * * * * * *  ||  * * * * * * *",50)
show_info()
return

tdown:
s_yy:=s_yy-10
subtitle("* * * * * * *  ||  * * * * * * *`n* * * * * * * \ / * * * * * * *",50)
show_info()
return

oup:
s_opacity+=10
if (s_opacity>=255)
	s_opacity:=255
opacity_factor:=s_opacity/11
subtitle(last_sub,150)
Return

odown:
s_opacity-=10
if (s_opacity<=0)
	s_opacity:=0
opacity_factor:=s_opacity/11
subtitle(last_sub,150)
Return

fontplus:
s_fontsize:=s_fontsize+1
Gui 1:Destroy
Gosub create_gui
subtitle("Bigger font-size",50)
show_info()
return

fontminus:
s_fontsize:=s_fontsize-1
Gui 1:Destroy
Gosub create_gui
subtitle("Smaller font-size",50)
show_info()
return

ssplus:
s_sub_second:=s_sub_second+2
ftime:=1/framesPerSecond*s_sub_second
show_info()
Sleep -1
return

ssminus:
s_sub_second:=s_sub_second-2
ftime:=1/framesPerSecond*s_sub_second
show_info()
Sleep -1
return

toggle_frametime:
t_framerate:=Mod(t_framerate+1,3)
if (t_framerate==0) 
	frames:=23.976
if (t_framerate==1) 
	frames:=24
if (t_framerate==2) 
	frames:=25
if (t_framerate==3) 
	frames:=30
ftime:=1/frames*s_sub_second
subtitle("Frames Per Second " frames,500)
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


SubSelected:
;#Bookmark#
;Gui 2:Submit,NoHide
GuiControlGet sel,,SubSelect
;s:=subs%sel%
;MsgBox %s%
on_line:=sel
break_me:=sel
return

Search:
GuiControlGet sel,,SubSearch
GuiControlGet seli,,SubSelect
;MsgBox %sel%
if (seli<sub_number)
	i:=seli+1
While i<sub_number
{
	t:=subs%i%
	if (InStr(t,sel))
	{
		GuiControl, Choose, SubSelect, |%i%
		return
	}
	i++
}
GuiControl, Choose, SubSelect,1
return

GuiClose:

goex:
ExitApp
return