
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

OBJ
  time  : "jm_time_80"                                          '   timing and delays
  'io    : "jm_io_basic"     
  pst : "Parallax Serial Terminal.spin"
  disp: "sevensegmentcharlieplex.spin"
  strip : "jm_rgbx_pixel" 'ws2812b driver
  button: "Button"
  
CON { io pins }
  OUT1   = 0                 { out1 pin of tilt sensor }
  OUT2   = 1                 { out2 pin of tilt sensor }
  LOW_DISPLAY_PIN = 2

CON { hulacounter modes }
  DEMO = 0
  RAINBOW = 1
  PIXEL_COUNT1 = 2
  PIXEL_COUNT2 = 3
  COLOR_CHASE = 4
  COLOR_WIPE = 5

VAR 
  word hula_count
  word tilt_detected
  long state
  long cog_sensor
  long cog_button
  long sensor_stack[20]
  long button_stack[20]
  
PUB Main

  setup
  dira[OUT1]~                'Set Out1 pin to input direction
  dira[OUT2]~                'Set Out2 pin to input direction
  
  hula_count := 0      
  tilt_detected := 0         
  disp.Start(LOW_DISPLAY_PIN, 2, 1) '2 digits, common cathode. 
  pst.Start(115_200)            ' Set Parallax Serial Terminal to 115,200 baud
  disp.Dec(hula_count)

        
  'waitcnt(clkfreq/10 + cnt)

pri setup                                                        
                                                                 
'' Setup IO and objects for application                          
                                                                 
  time.start                                                    ' setup timing & delays
                                                                 
  'io.start(0, 0)                                                ' clear all pins (master cog)

  'strip.start_2812b(@pixbuf1, STRIP_LEN, LEDS, 1_0)             ' start pixel driver for WS2812b 
                                                                
  cog_sensor := cognew(process_tilt_sensor, @sensor_stack)       ' start cog that will monitor tilt sensor
 
  
pri process_tilt_sensor
  repeat
    if ina[OUT1] == 1 and tilt_detected == 0
        tilt_detected := 1
        
    if ina[OUT1] == 0 and tilt_detected == 1
        tilt_detected := 0
        hula_count++
        
        pst.Home
        pst.Dec (hula_count)
        disp.Dec(hula_count)
        pst.NewLine

