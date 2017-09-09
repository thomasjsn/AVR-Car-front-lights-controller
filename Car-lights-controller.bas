'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.io
'--------------------------------------------------------------
'  file: Car_lights_controller v1.2
'  date: 17/08/2008
'--------------------------------------------------------------

$regfile = "attiny2313.dat"
$crystal = 8000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024
Dim L_timer As Byte
Dim B_active As Byte
Dim B_timer As Byte
Dim H_timer As Byte

Portb = 0
L_timer = 0
B_active = 0
B_timer = 0

If Pind.2 = 0 Then B_active = 2                             'set strobe var

Waitms 1000
If Pind.2 = 1 And Pind.3 = 1 And B_active = 2 Then          'init strobe sequence
   B_active = 1
Else
   B_active = 0
End If

If Pind.2 = 1 And B_active = 0 Then Waitms 1650             'high beam off

Start Watchdog

Main:
'low beam timer
If Pind.1 = 1 And L_timer < 14 Then Incr L_timer            'low beam off
If Pind.1 = 0 Then L_timer = 0                              'low beam on

'high beam
If Pind.2 = 0 Then
   Portb.7 = 1                                              'high beam on
   B_active = 0
End If
If Pind.2 = 1 And B_active = 0 And H_timer = 0 Then Portb.7 = 0       'high beam off

'driving lights
If Pind.3 = 0 And B_active = 0 Then                         'switch off
   If L_timer = 14 And Pind.2 = 1 Then Portb.6 = 1          'only park active'
   If L_timer = 0 Or Pind.2 = 0 Then Portb.6 = 0
End If

'fog lights
If Pind.3 = 1 And B_active = 0 Then                         'switch on
   If Pind.2 = 1 Then Portb.6 = 1                           'park active/high beam off
   If Pind.2 = 0 Then Portb.6 = 0
End If

'strobe
If B_active = 1 And B_timer = 0 Then B_timer = 80
If B_active = 0 Then B_timer = 0
'if B_timer = 124 Then Portb.7 = 1
'if B_timer = 110 Then Portb.7 = 0
'If B_timer = 96 Then Portb.7 = 1
'If B_timer = 82 Then Portb.7 = 0
'If B_timer = 62 Then Portb.6 = 1
'If B_timer = 48 Then Portb.6 = 0
'If B_timer = 34 Then Portb.6 = 1
'If B_timer = 20 Then Portb.6 = 0
If B_timer = 80 Then Portb.7 = 1
If B_timer = 40 Then Portb.7 = 0
If B_timer = 27 Then Portb.6 = 1
If B_timer = 13 Then Portb.6 = 0
Decr B_timer

Reset Watchdog                                              'loop cycle
Waitms 25
Goto Main
End