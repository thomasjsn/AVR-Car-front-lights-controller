'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.io
'--------------------------------------------------------------
'  file: Car_lights_controller v2.0
'  date: 17/08/2008
'--------------------------------------------------------------

$regfile = "attiny2313.dat"
$crystal = 8000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024
Dim L_timer As Byte , B_active As Byte , B_timer As Byte , Wait_arm As Bit
Dim Wait_timer As Integer , Start_timer As Byte , Al_timer As Byte
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up

'init port and i/o's
Portb = 0
Ddrb.3 = 1
Ddrb.4 = 1
Pwm1a = 255
Pwm1b = 255

'init variables
L_timer = 0
B_active = 0
B_timer = 0
Wait_timer = 0
Al_timer = 0
Wait_arm = 0
Start_timer = 0

If Pind.2 = 0 Then B_active = 2                             'set strobe var

Waitms 1000
If Pind.2 = 1 And Pind.3 = 1 And B_active = 2 Then          'init strobe sequence
   B_active = 1
Else
   B_active = 0
End If

Start Watchdog

Main:
'low beam timer
If Pind.1 = 1 And L_timer < 14 Then Incr L_timer            'low beam off
If Pind.1 = 0 Then L_timer = 0                              'low beam on

'start timer
If Pind.0 = 0 And Start_timer < 120 Then Incr Start_timer   'park on
If Pind.0 = 1 Then Start_timer = 0                          'park off

'high beam
If Pind.2 = 0 Then
   Portb.7 = 1                                              'high beam on
   B_active = 0
End If
If Pind.2 = 1 And B_active = 0 Then Portb.7 = 0             'high beam off

'driving lights
If Pind.3 = 0 And B_active = 0 Then                         'switch off
   If L_timer = 14 And Start_timer = 120 And Pind.2 = 1 Then
      Portb.6 = 1                                           'only park active'
      Pwm1a = 0                                             'set green LED high
   End If
   If L_timer = 0 Or Pind.2 = 0 Then
      Portb.6 = 0
      Pwm1a = 255
   End If
End If

'fog lights
If Pind.3 = 1 And B_active = 0 Then                         'switch on
   If Start_timer = 120 And Pind.2 = 1 Then
      Portb.6 = 1                                           'park active/high beam off
      Pwm1a = 235                                           'set green LED low
   End If
   If Pind.2 = 0 Then
      Portb.6 = 0
      Pwm1a = 255
   End If
End If

'signal
If B_active = 1 And B_timer = 0 Then
   B_timer = 60
   Portb.5 = 1
   End If
If B_active = 0 Then
   B_timer = 0
   Portb.5 = 0
   End If
If B_timer = 60 Then Portb.7 = 1
If B_timer = 30 Then Portb.7 = 0
If B_timer = 22 Then
   Portb.6 = 1
   Pwm1b = 0
   End If
If B_timer = 8 Then
   Portb.6 = 0
   Pwm1b = 255
   End If
Decr B_timer

'follow me home lights
If Pind.0 = 1 And Wait_timer = 0 And B_active = 0 And Wait_arm = 1 Then
   Wait_timer = 2400
   Portb.6 = 1
   Pwm1a = 0
   End If
If Wait_timer > 1 Then Decr Wait_timer
If Wait_timer = 1 Then
   Portb.6 = 0
   Pwm1a = 255
   End If
If Pind.0 = 0 Then
   Wait_timer = 0
   Wait_arm = 1
   End If

'alarm led
If Pind.0 = 1 And Al_timer = 0 And B_active = 0 Then Al_timer = 40
If Al_timer = 35 Then Pwm1b = 0
If Al_timer = 25 Then Pwm1b = 255
If Al_timer > 0 Then Decr Al_timer

Reset Watchdog                                              'loop cycle
Waitms 25
Goto Main
End