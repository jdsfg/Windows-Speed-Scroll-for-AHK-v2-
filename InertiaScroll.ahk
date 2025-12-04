/*
 * Inertia Scroll for AHK v2
 * A smooth, inertia-based scrolling script for Windows.
 * * Author: [Your Name/GitHub ID]
 * Date: 2025-12-04
 * Version: 2.0
 * Environment: AutoHotkey v2.0+
 */

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"

;======== ⚙️ Configuration / 参数调节 ========
; 1. Friction (0.1~0.99): Lower stops faster, Higher slides longer.
;    阻尼系数：越小停得越快，越大滑得越远
friction  := 0.91  

; 2. Acceleration (1~5): Higher reaches max speed faster.
;    加速度：数值越大，起步和提速越快
accel     := 2     

; 3. Max Burst (10~50): Max scrolling speed limit.
;    极速上限：限制滚轮最快能滚多快
maxBurst  := 30    

; 4. Time Gap (ms): Interval to reset acceleration (for precision).
;    精准判定时间：超过此时间间隔则重置速度（防误触加速）
timeGap   := 210   

; 5. Poll Interval (ms): 8ms approx 120FPS.
;    刷新率
pollMS    := 8    
;===========================================

burst := 0
lastDir := 0
lastTick := 0

SetTimer InertiaLoop, pollMS

WheelUp::
WheelDown::
{
    global burst, lastDir, lastTick
    
    currTick := A_TickCount
    dt := currTick - lastTick
    lastTick := currTick
    
    dir := (A_ThisHotkey = "WheelUp") ? 1 : -1
    
    ; Precision Mode Logic
    if (dir != lastDir or dt > timeGap) {
        burst := 1 
    } else {
        burst := Min(burst + accel, maxBurst)
    }
    
    lastDir := dir
    SendBurst(Round(burst), dir)
}

InertiaLoop()
{
    global burst, lastDir
    if (burst > 1.5) { 
        burst *= friction
        val := Round(burst)
        if (val > 0)
            SendBurst(val, lastDir)
    } else {
        burst := 0
    }
}

SendBurst(n, dir){
    Loop n
        Send(dir = 1 ? "{WheelUp}" : "{WheelDown}")
}

; Optional: Disable script when Alt is held down (for Maps/3D Apps)
#HotIf GetKeyState("Alt", "P")
WheelUp::Send "{WheelUp}"
WheelDown::Send "{WheelDown}"
#HotIf