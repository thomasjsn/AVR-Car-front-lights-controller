'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.io
'--------------------------------------------------------------
'  file: Car_lights_controller v1.0
'  date: 04/03/2008
'--------------------------------------------------------------

$regfile = "attiny2313.dat"
$crystal = 8000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024

Portb = 0

Start Watchdog

Main:
'high beam
If Pind.2 = 0 Then Portb.7 = 1
If Pind.2 = 1 Then Portb.7 = 0

'driving lights
If Pind.3 = 0 Then
If Pind.0 = 0 And Pind.1 = 1 And Pind.2 = 1 Then Portb.6 = 1
If Pind.0 = 1 Or Pind.1 = 0 Or Pind.2 = 0 Then Portb.6 = 0
End If

'fog lights
If Pind.3 = 1 Then
If Pind.0 = 0 And Pind.2 = 1 Then Portb.6 = 1
If Pind.0 = 1 Or Pind.2 = 0 Then Portb.6 = 0
End If


'loop cycle
Reset Watchdog
Waitms 1
Goto Main
End