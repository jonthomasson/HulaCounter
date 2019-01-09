
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

OBJ
  time  : "jm_time_80"                                          '   timing and delays
  'io    : "jm_io_basic"     
  pst : "Parallax Serial Terminal.spin"
  disp: "sevensegmentcharlieplex.spin"
  strip : "jm_rgbx_pixel" 'ws2812b driver
  button: "Button"
  rr: "RealRandom"
  
CON { io pins }
  OUT1   = 0                 { out1 pin of tilt sensor }
  OUT2   = 1                 { out2 pin of tilt sensor }
  LOW_DISPLAY_PIN = 2
  BTN_MODE = 16
  LEDS = 15                                                     ' LED signal pin
  
CON
  STRIP_LEN =25                                              
  PIX_BITS  = 24                                                ' 24-bit (RGB) pixels

CON { hulacounter modes }
  MODE_WIPE = 0
  MODE_RAINBOW = 1
  MODE_PIXEL_COUNT1 = 2
  'MODE_PIXEL_COUNT2 = 3
  MODE_COLOR_CHASE1 = 3
  MODE_COLOR_CHASE2 = 4
  MODE_FIREWORKS = 5
  'MODE_COLOR_WIPE = 6
  MODE_PIXEL_OFF = 6

VAR 
  word hula_count
  word old_hula_count
  word tilt_detected
  long current_mode
  long cog_sensor
  long cog_button
  long sensor_stack[20]
  long button_stack[20]
  long  pixbuf1[STRIP_LEN]                                      ' pixel buffers
  long  pixbuf2[STRIP_LEN]
  long  pixbuf3[STRIP_LEN]
  
dat

  Marquee       long    $10_10_10_00
                long    $00_00_00_00
                long    $00_00_00_00

  Chakras       long    strip#RED
                long    strip#ORANGE
                long    strip#YELLOW 
                long    strip#GREEN
                long    strip#BLUE
                long    strip#INDIGO
                
  Colors        long    strip#RED
                long    strip#GREEN
                long    strip#BLUE
                long    strip#WHITE
                long    strip#CYAN
                long    strip#MAGENTA
                long    strip#YELLOW
                long    strip#CHARTREUSE
                long    strip#ORANGE
                long    strip#AQUAMARINE
                long    strip#PINK
                long    strip#TURQUOISE
                long    strip#INDIGO
                long    strip#VIOLET    
                long    strip#MAROON
                long    strip#CRIMSON
                long    strip#PURPLE

  
PUB Main | p_pixels, pos, ch, pix_count, idx

  setup
  
  idx := 0

   
  'beginning of our state machine
  pix_count := 0
  repeat
    if(hula_count == 0)
        disp.Dec(current_mode)
        
    case current_mode
        MODE_WIPE :
            color_wipe2(@Colors[idx] , 400/STRIP_LEN)
            if (++idx == 17)    ' past end of list?
                idx := 0  
            'color_wipe($20_00_00_00, 500/STRIP_LEN)
            'color_wipe($00_20_00_00, 500/STRIP_LEN)      
            'color_wipe($00_00_20_00, 500/STRIP_LEN) 
        MODE_RAINBOW :
            rainbow(4)
        MODE_FIREWORKS :
            fireworks(2)
        MODE_PIXEL_OFF :
            repeat ch from 0 to STRIP_LEN-1
                strip.set(ch, strip.colorx(0,0,0,0,0)) 
                time.pause(100)
            strip.clear
        MODE_COLOR_CHASE1 :  
            color_chase(@Chakras, 6, 100) 
        MODE_COLOR_CHASE2 :  
            color_chase(@Marquee, 6, 100) 
        MODE_PIXEL_COUNT1 :
            if(old_hula_count < hula_count)
                if(pix_count > STRIP_LEN - 1)
                    pix_count := 0
                
                repeat ch from 0 to STRIP_LEN - 1
                    if(ch < pix_count + 1)
                        strip.set(ch, strip.colorx(255,0,0,0,20)) 
                    else
                        strip.set(ch, strip.colorx(0,255,0,0,20)) 
                pix_count++
                old_hula_count := hula_count                 
  'waitcnt(clkfreq/10 + cnt)

pri setup                                                        
                                                                 
'' Setup IO and objects for application         
  dira[OUT1]~                'Set Out1 pin to input direction
  dira[OUT2]~                'Set Out2 pin to input direction
  
  hula_count := 0      
  old_hula_count := 0
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
        if current_mode == 6
            current_mode := 0
        else
            current_mode++
            
        hula_count := 0 'reset count
        old_hula_count := 0
            
    
pri process_tilt_sensor
  repeat
    if ina[OUT1] == 1 and tilt_detected == 0
        tilt_detected := 1
        
    if ina[OUT1] == 0 and tilt_detected == 1
        tilt_detected := 0
        hula_count++
        
        'pst.Home
        'pst.Dec (hula_count)
        disp.Dec(hula_count)
        'pst.NewLine

pri color_wipe(rgb, ms) | ch

'' Sequentially fills strip with color rgb
'' -- ms is delay between pixels, in milliseconds

  repeat ch from 0 to strip.num_pixels-1 
    strip.set(ch, rgb)
    time.pause(ms)

pri color_wipe2(p_color, ms) | ch

'' Sequentially fills strip with color rgb
'' -- ms is delay between pixels, in milliseconds

  repeat ch from 0 to strip.num_pixels-1 
    strip.setx(ch, long [p_color], $20)
    time.pause(ms)

pri rainbow(ms) | pos, ch

  repeat pos from 0 to 255
    repeat ch from 0 to STRIP_LEN-1
        strip.set(ch, strip.wheelx(256 / STRIP_LEN * ch + pos, $20))   
    time.pause(ms)

''trying to mimic fireworks both in spontaneity and color
pri fireworks(ms) | ch, color, size, base, rand, idx
    'pick a random led to start point of ignition
    'start RealRandom
    strip.clear
    rand := 0
    rr.start 
    ch := (rr.random >> 1)//(STRIP_LEN) 'shifting bits over one to ensure non signed
                                           'generate a random number between 0 and STRIP_LEN
    
    'pick a random color
    color := (rr.random >> 1)//(255) '255 total colors to choose from
    
    'pick a random burst size
    'j := (rand.random >> 1) // (RANGE - i + 1) + i
    size := (rr.random >> 1)// (10 - 4 + 1) + 4 'give me a random number between 4 and 10
    rr.stop
    
    'start from area of impact, send leds in opposite direction with gradually decreasing
    'momentum
    idx := 0
    repeat base from ch to ch + size-1
        if(base > STRIP_LEN-1)
            strip.set(base - STRIP_LEN, strip.wheelx(color, $100)) 
        else
            strip.set(base, strip.wheelx(color, $100)) 
            
        if(ch - idx < 0)
            strip.set((ch - idx) + STRIP_LEN, strip.wheelx(color, $100)) 
        else
            strip.set(ch - idx, strip.wheelx(color, $100)) 
        time.pause(ms + (50*idx))
        idx++

pub color_chase(p_colors, len, ms) | base, idx, ch

'' Performs color chase
'' -- p_colors is pointer to table of colors
'' -- len is number of colors in table
'' -- ms is step duration in chase 

  repeat base from 0 to len-1                                   ' do all colors in table
    idx := base                                                 ' start at base
    repeat ch from 0 to strip.num_pixels-1                      ' loop through connected leds
      strip.setx(ch, long[p_colors][idx], $20)                        ' update channel color 
      if (++idx == len)                                         ' past end of list?
        idx := 0                                                ' yes, reset
   
    time.pause(ms)                                              ' set movement speed