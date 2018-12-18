
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
  BTN_MODE = 25
  LEDS = 15                                                     ' LED signal pin
  
CON
  STRIP_LEN = 8                                                
  PIX_BITS  = 24                                                ' 24-bit (RGB) pixels

CON { hulacounter modes }
  MODE_DEMO = 0
  MODE_RAINBOW = 1
  MODE_PIXEL_COUNT1 = 2
  MODE_PIXEL_COUNT2 = 3
  MODE_COLOR_CHASE = 4
  MODE_COLOR_WIPE = 5

VAR 
  word hula_count
  word tilt_detected
  long current_mode
  long cog_sensor
  long cog_button
  long sensor_stack[20]
  long button_stack[20]
  long  pixbuf1[STRIP_LEN]                                      ' pixel buffers
  long  pixbuf2[STRIP_LEN]
  long  pixbuf3[STRIP_LEN]
  
PUB Main | p_pixels, pos, ch  

  setup

   
  'beginning of our state machine
  repeat
    case current_mode
        MODE_DEMO :
            color_wipe($20_00_00_00, 500/STRIP_LEN)
            color_wipe($00_20_00_00, 500/STRIP_LEN)      
            color_wipe($00_00_20_00, 500/STRIP_LEN) 
        MODE_RAINBOW :
            rainbow(4)
                                           ' 
  'waitcnt(clkfreq/10 + cnt)

pri setup                                                        
                                                                 
'' Setup IO and objects for application         
  dira[OUT1]~                'Set Out1 pin to input direction
  dira[OUT2]~                'Set Out2 pin to input direction
  
  hula_count := 0      
  tilt_detected := 0         
  current_mode := 0
  disp.Start(LOW_DISPLAY_PIN, 2, 1) '2 digits, common cathode. 
  pst.Start(115_200)            ' Set Parallax Serial Terminal to 115,200 baud
  disp.Dec(hula_count)           
  
  longfill(@pixbuf1, $20_00_00_00, STRIP_LEN)                   ' prefill buffers
  longfill(@pixbuf2, $00_20_00_00, STRIP_LEN)
  longfill(@pixbuf3, $00_00_20_00, STRIP_LEN)      
                                                                 
  time.start                                                    ' setup timing & delays
                                                                 
  'io.start(0, 0)                                                ' clear all pins (master cog)

  strip.start_2812b(@pixbuf1, STRIP_LEN, LEDS, 1_0)             ' start pixel driver for WS2812b 
                                                                
  cog_sensor := cognew(process_tilt_sensor, @sensor_stack)       ' start cog that will monitor tilt sensor
  cog_button := cognew(process_mode_button, @button_stack)       ' start cog that will monitor mode button click
 
pri process_mode_button
  repeat
    'Returns true only if button pressed, held for at least 80ms and released.
    if button.ChkBtnPulse(BTN_MODE, 1, 80)
        'change state
        if current_mode == 5
            current_mode := 0
        else
            current_mode++
    
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

pri color_wipe(rgb, ms) | ch

'' Sequentially fills strip with color rgb
'' -- ms is delay between pixels, in milliseconds

  repeat ch from 0 to strip.num_pixels-1 
    strip.set(ch, rgb)
    time.pause(ms)

pub rainbow(ms) | pos, ch

  repeat pos from 0 to 255
    repeat ch from 0 to STRIP_LEN-1
        strip.set(ch, strip.wheelx(256 / STRIP_LEN * ch + pos, $20))   
    time.pause(ms)