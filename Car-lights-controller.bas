'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.io
'--------------------------------------------------------------
'  file: Car_lights_controller v2.5
'  date: 17/08/2008
'--------------------------------------------------------------

$regfile = "attiny2313.dat"
$crystal = 8000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024
Dim L_timer As Byte , B_active As Bit , B_cache As Bit
Dim Wait_timer As Integer , Start_timer As Byte , Al_timer As Byte , Al_active As Byte
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up

Const Pwm_off = 255                                         '255
Const Pwm_low = 235                                         '235
Const Pwm_high = 0                                          '0

'init port and i/o's
Portb = 0
Ddrb.3 = 1
Ddrb.4 = 1
Pwm1a = Pwm_off
Pwm1b = Pwm_off

'init variables
L_timer = 20
B_active = 0
Wait_timer = 0
Al_timer = Pwm1b
Start_timer = 0

B_cache = Not Pind.3                                        'set strobe var

Pwm1a = Pwm_high
Waitms 1000
If Pind.3 = B_cache Then                                    'init strobe sequence
   B_active = 1
Else
   B_active = 0
End If
Pwm1a = Pwm_off

Start Watchdog

Main:
'low beam timer
If Pind.1 = 1 And L_timer < 20 Then Incr L_timer            'low beam off
If Pind.1 = 0 Then L_timer = 0                              'low beam on

'start timer
If Pind.0 = 0 And Start_timer < 120 Then Incr Start_timer   'park on
If Pind.0 = 1 Then Start_timer = 0                          'park off

'high beam
If Pind.2 = 0 Then Portb.7 = 1                              'high beam on
If Pind.2 = 1 Then Portb.7 = 0                              'high beam off

'driving lights
If Pind.3 = 0 Then                                          'switch off
   If L_timer = 20 And Start_timer = 120 And Pind.2 = 1 Then
      Portb.6 = 1                                           'only park active'
      Pwm1a = Pwm_high                                      'set green LED high
   End If
   If L_timer = 0 Or Pind.2 = 0 Then
      Portb.6 = 0
      Pwm1a = Pwm_off
   End If
End If

'fog lights
If Pind.3 = 1 Then                                          'switch on
   If Start_timer = 120 And Pind.2 = 1 Then
      Portb.6 = 1                                           'park active/high beam off
      Pwm1a = Pwm_low                                       'set green LED low
   End If
   If Pind.2 = 0 Then
      Portb.6 = 0
      Pwm1a = Pwm_off
   End If
End If

'signal
If B_active = 1 Then                                        'strobe active
   Portb.5 = 1                                              'set strobe output
   Pwm1b = Pwm_low                                          'set blue LED
End If

'follow me home lights
If Pind.0 = 1 And L_timer < 20 Then                         'if low beam was on
   Wait_timer = 3600
   Portb.6 = 1
   End If
If Wait_timer > 0 Then
   Decr Wait_timer
   If B_active = 0 Then Pwm1a = 255 - Pwm1b
   If B_active = 1 Then Pwm1a = Pwm_high
   End If
If Pind.0 = 1 And Wait_timer = 0 Then                       'turn off after X sec
   Portb.6 = 0
   Pwm1a = Pwm_off
   End If
If Pind.0 = 0 And Wait_timer > 0 Then                       'turn off when park on
   Wait_timer = 0
   Portb.6 = 0
   Pwm1a = Pwm_off
   End If

'alarm led
If Pind.0 = 1 And B_active = 0 Then                         'if park off, strobe off
   If Al_timer = 0 Then Al_active = 1                       'count up
   If Al_timer = 255 Then Al_active = 2                     'count down
   End If
If Pind.0 = 0 And B_active = 0 Then                         'off when park on, strobe off
   Pwm1b = Pwm_off
   Al_timer = Pwm1b
   Al_active = 0
   End If

If Al_active = 1 Then                                       'set alarm LED PWM up
   Al_timer = Al_timer + 5
   Pwm1b = Al_timer
   If Al_timer = 255 Then Al_active = 0
End If

If Al_active = 2 Then                                       'set alarm LED PWM down
   Al_timer = Al_timer - 5
   Pwm1b = Al_timer
   If Al_timer = 0 Then Al_active = 0
End If

Reset Watchdog                                              'loop cycle
Waitms 25
Goto Main
End