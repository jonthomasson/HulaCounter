'' 4DirectionalTiltSensor_Simple.spin for P8X32A
'' Displays output states of both phototransistors

  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

OBJ

  pst : "Parallax Serial Terminal.spin"
  disp: "sevensegmentcharlieplex.spin"
  
CON
  Out1   = 0                 { out1 pin of tilt sensor }
  Delay = 10_000_000          { On/Off Delay, in clock cycles}
  LowDisplayPin = 2

VAR 
  word counter
  word state_changed
  
PUB Main

  dira[Out1]~                'Set Out1 pin to input direction
  
  counter := 0      
  state_changed := 0         
  disp.Start(LowDisplayPin, 2, 1) '2 digits, common cathode. 
  pst.Start(115_200)            ' Set Parallax Serial Terminal to 115,200 baud
  disp.Dec(counter)
  repeat
    
    if ina[Out1] == 1 and state_changed == 0
        state_changed := 1
        
    if ina[Out1] == 0 and state_changed == 1
        state_changed := 0
        counter++
        
        pst.Home
        pst.Dec (counter)
        disp.Dec(counter)
        pst.NewLine
        
    'pst.Home
    'pst.str(string("Phototransistor 1: "))
    'pst.bin(ina[0], 1)
    'pst.NewLine
    'pst.str(string("Phototransistor 2: "))
    'pst.bin(ina[1], 1)
    waitcnt(clkfreq/10 + cnt)
