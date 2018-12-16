{{┌────────────────────────────────────────────┐
  │ Seven-segment Charlieplexed display driver │
  │ Author: Chris Gadd                         │
  │ Copyright (c) 2014 Chris Gadd              │
  │ See end of file for terms of use.          │
  └────────────────────────────────────────────┘

  PUB methods
    Start(low_display_pin, digits, display_type)
                        : The display pins must be in a contiguous block, wired according to the schematic below
                           This driver supports as many digits as there are pins available.  
                           Minimum 9 pins required, which can drive up to nine displays.  Each display over nine requires an additional pin.
                           Display type is common anode (0), or common cathode (1)                                                                         1 1 1 1 1 2 2 2 2   
    Stop                : Stops the driver                                                                                                  G F c A B      F G A B c c F A B   
    Display(StringPtr)  : Address of a string to display, valid characters are "0" through "9", decimal ".", minus "-", and space " "     ┌─┴─┴─┴─┴─┴─┐  ┌─┴─┴─┴─┴─┴─┴─┴─┴─┴─┐ 
                           any other characters will result in unexpected operation - does not perform range checking                     │ ──A──     │  │ ──A──      ──A──  │ 
                          Display(string("123.456"))                                                                                      ││     │    │  ││     │    │     │ │ 
    Display_off         : Turns the display off but keeps the settings                                                                    │F     B    │  │F     B    F     B │ 
    Justify(left/right) : Display digits from the left or the right edge of the display, does not drop high digits                        ││     │    │  ││     │    │     │ │ 
                           "123" right justified on a 6-digit display shows "___123" / "123456789" shows "123456"                         │ ──G──     │  │ ──G──      ──G──  │ 
    Blink(true/false)   : Blinks the entire display at a 2Hz rate - uses ctra to set the blink rate                                       ││     │    │  ││     │    │     │ │ 
    Strobe(true/false)  : Strobes the segments in each digit, reduces power requirement but also results in a dimmer display              │E     C ┌─┐│  │E     C    E     C │ 
                           Connected directly, the prop pin might have to source/sink current for eight segments                          ││     │ dp││  ││     │    │     │ │ 
                           With strobe, only ever has to source/sink a single segment at a time                                           │ ──D──  └─┘│  │ ──D── d    ──D── d│ 
    Dec(value)          : Converts a number to a string and displays it                                                                   └─┬─┬─┬─┬─┬─┘  └─┬─┬─┬─┬─┬─┬─┬─┬─┬─┘ 
    DecF(value,divider,places) : Displays a divided value to the specified number of places                                                 E D c C dp     E D C d E D G C d   
                                  DecF(12345,100,2) displays 123.45                                                                                        1 1 1 1 2 2 2 2 2   
                                  
    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────        
    │                ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        
    │ 9 pins are     │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │  │  ──A──  │        
    │ required for   │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │        
    │ seven segments │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │  │ F     B │        
    │ plus decimal   │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │        
    │                │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │  │  ──G──  │        
    │ 9 pins can     │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │        
    │ drive nine     │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │  │ E     C │        
    │ displays       │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │  │ │     │ │        
    │                │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│  │  ──D── d│        
    │ additional     │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│  │ABCDEFGdc│        
    │ displays       └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘  └┬┬┬┬┬┬┬┬┬┘        
    │ wired as shown  │    │    │    │    │    │    │    │    │    │    │    │         
    │  disp 12 ──────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┘        
    │  disp 11 ──────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┘    ││││││││          
    │  disp 10 ──────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┘    ││││││││     ││││││││          
    │ high-pin ──────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┻┼┼┼┼┼┼┼┼────┼┼┼┼┼┼┼┼┘    ││││││││     ││││││││     ││││││││          
    │          ───────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┼┼┼┼┼┼┼┻────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼─────┻┼┼┼┼┼┼┼──        
    │          ────────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┼┼┼┼┼┼┻─────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──────┻┼┼┼┼┼┼──        
    │          ─────────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┼┼┼┼┼┻──────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼───────┻┼┼┼┼┼──        
    │          ──────────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼────────┼┼┼┼┻───────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼────────┻┼┼┼┼──        
    │          ───────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼─────────┼┼┼┻────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼─────────┻┼┼┼──        
    │          ────────────┻┼┼──────────┻┼┼──────────┼┼┻─────────┻┼┼──────────┻┼┼──────────┻┼┼──────────┻┼┼──────────┻┼┼──────────┻┼┼──────────┻┼┼──────────┻┼┼──────────┻┼┼──        
    │          ─────────────┻┼───────────┼┻──────────┻┼───────────┻┼───────────┻┼───────────┻┼───────────┻┼───────────┻┼───────────┻┼───────────┻┼───────────┻┼───────────┻┼──        
    │  low-pin ──────────────┻───────────┻────────────┻────────────┻────────────┻────────────┻────────────┻────────────┻────────────┻────────────┻────────────┻────────────┻──        
    └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────        
                      
}}                                                                                   
CON                                                   
  _clkmode = xtal1 + pll16x                                                   
  _xinfreq = 5_000_000

CON
  LEFT = 0
  RIGHT = 1
  CA = 0
  CC = 1

  DISPLAY_FLAG = %1000_0000   ' sets display on or off
  COMMON_FLAG  = %0100_0000   ' sets common cathode or common anode
  STROBE_FLAG  = %0000_0100   ' sets strobing segments on or off
  BLINK_FLAG   = %0000_0010   ' sets blinking display on or off
  JUSTIFY_FLAG = %0000_0001   ' sets display from right or left
  
VAR

  word  StrAdd
  word  TabAdd
  byte  _display_digits
  byte  _display_offset                                  
  byte  _flags                                           
  byte  local_string[32]                                
  byte  idx
  byte  cog

PUB Demo

  Start(16,8,CA)                                        ' Digits starting on pin 16                                              
                                                        ' 8 digits                                                               
                                                        ' common-anode
  strobe(false)                                         ' lights each segment individually, reduces power but also dims display  

  repeat 
    justify(right)
    blink(false)
    Display(string("123"))                              ' display 123 right-justified
    waitcnt(cnt + clkfreq * 4)
    justify(left)
    blink(true)
    Display(string("9.8.7.6"))                          ' display "9.8.7." left-justified and blinking
    waitcnt(cnt + clkfreq * 4)
    blink(false)
    justify(right)
    Dec(-2468)                                          ' display the number -2468
    waitcnt(cnt + clkfreq * 4)
    Decf(12345,100,2)                                   ' display 12345 divided by 100 to two decimal places
    waitcnt(cnt + clkfreq * 4)

PUB Start(low_pin,_digits,display_type) : okay                                      

  stop
  TabAdd := @Lookup_Table
  _display_digits := _digits
  _display_offset := low_pin
  _flags := (display_type & 1) << 6
  
  okay := cog := cognew(@entry,@StrAdd) + 1

PUB stop
  if cog
    cogstop(cog~ - 1)

PUB Display(stringAdd)
  
  StrAdd := stringAdd
  _flags |= %1000_0000

PUB Display_off
{
  Blanks the display, keeps the other parameters (justify, blink, strobe) intact
}
  _flags := _flags & !%1000_0000

PUB Justify(dir)
{
  Display digits from the left or right edge of the display, does not drop high digits
  "123" right justified on a 6-digit display shows "___123" / "123456789" shows "123456"
}
  _flags := _flags & !1 | dir & 1

PUB Blink(state)
{
  Blinks the display at a 2Hz rate
}
  _flags := _flags & !%10 | state & 1 << 1

PUB Strobe(state)
{
  Strobes the segments in each digit, reduces power requirement but also results in a dimmer display
}
  _flags := _flags & !%100 | state & 1 << 2

PUB Dec(value) | i, x

  idx := 0
                                                                                
  x := value == NEGX                                                            ' Check for max negative
  if value < 0                                                                  
    value := ||(value+x)                                                        ' If negative, make positive; adjust for max negative
    Append("-")                                                                 '  and output sign

  i := 1_000_000_000                                                            ' Initialize divisor

  repeat 10                                                                     ' Loop for 10 digits
    if value => i                                                               
      Append(value / i + "0" + x*(i == 1))                                      ' If non-zero digit, output digit; adjust for max negative
      value //= i                                                               '  and digit from value
      result~~                                                                  '  flag non-zero found                                               
    elseif result or i == 1                                                                                                  
      Append("0")                                                               ' If zero digit (or only digit) output it                            
    i /= 10                                                                     ' Update divisor

  append($00)                                                                   ' Append null-termination
    
  Display(@local_string)                         

PUB DecF(value,divider,places) | i, x
{
  DecF(1234,100,3) displays "12.340"
}

  idx := 0

  if value < 0
    || value                                            ' If negative, make positive
    append("-")                                         ' and output sign
  
  i := 1_000_000_000                                    ' Initialize divisor
  x := value / divider

  repeat 10                                             ' Loop for 10 digits
    if x => i                                                                   
      append(x / i + "0")                               ' If non-zero digit, output digit
      x //= i                                           ' and remove digit from value
      result~~                                          ' flag non-zero found
    elseif result or i == 1
      append("0")                                       ' If zero digit (or only digit) output it
    i /= 10                                             ' Update divisor

  append(".")

  i := 1
  repeat places
    i *= 10
    
  x := value * i / divider                             
  x //= i                                               ' limit maximum value
  i /= 10
    
  repeat places
    append(x / i + "0")
    x //= i
    i /= 10

  append($00)                                           ' Append null-termination 
    
  Display(@local_string)

PRI Append(char)

  Local_string[idx++] := char
  
DAT                     org       
Lookup_Table                      'ABCD_EFGd  
:Zero                   byte      %1111_1100                                    
:One                    byte      %0110_0000                                    
:Two                    byte      %1101_1010                                    
:Three                  byte      %1111_0010                                                                           
:Four                   byte      %0110_0110                                                                           
:Five                   byte      %1011_0110                                                                           
:Six                    byte      %1011_1110                                                                                                                    
:Seven                  byte      %1110_0000                                    
:Eight                  byte      %1111_1110           
:Nine                   byte      %1111_0110  
:blank                  byte      %0000_0000                                   
:dot                    byte      %0000_0001
:minus                  byte      %0000_0010
'custom characters can be added here
':b                     byte      %0011_1110
':A                     byte      %1110_1110
':P                     byte      %1100_1110
':U                     byte      %0111_1100

DAT                     org   
entry
                        mov       t1,par
                        mov       string_address,t1
                        add       t1,#2
                        rdword    table_address,t1
                        add       t1,#2
                        rdbyte    digits,t1                                     ' Read the number of digits
                        add       t1,#1
                        rdbyte    offset,t1
                        add       t1,#1
                        mov       flags_address,t1
                        mov       pattern_address,table_address                 ' Lookup the :dot pattern to use as a 
                        add       pattern_address,#11                           '  mask for the decimal point
                        rdbyte    dp_mask,pattern_address
                        movi      ctra,#%0_11111_000                            ' Uses the counter to blink the display    
                        mov       frqa,_2Hz                                     '  on demand at a 2Hz rate
'......................................................................................................................
wait_for_command
                        rdbyte    flags,flags_address
                        test      flags,#DISPLAY_FLAG         wc                ' test display flag
          if_nc         mov       dira,#0                                       ' blank display 
          if_nc         jmp       #wait_for_command
                        test      flags,#BLINK_FLAG           wc                ' test blink flag
          if_nc         jmp       #:initialize_display
                        mov       phsa,phsa
                        rcl       phsa,#1                     wc,nr             ' test the msb of phsa
          if_c          mov       dira,#0                                       ' blank display
          if_c          jmp       #wait_for_command
:initialize_display
                        mov       common_mask,#$01                              ' common and pattern masks shift left each iteration
                        neg       pattern_mask,#1                               '  starts at $FFFF_FFFF, 0's shifted into lsb
                        test      flags,#JUSTIFY_FLAG         wc                ' test justify flag
          if_nc         jmp       #:left_justify
:right_justify                                                                  
                        rdword    t2,string_address
                        mov       digit_counter,#0
                        shl       common_mask,digits
                        shl       pattern_mask,digits
                        mov       t1,digits
:loop                                                                           
                        rdbyte    t3,t2                       wz                ' determine the string length by looping
          if_z          jmp       #display_string                               '  until the null-termination is found
                        add       t2,#1                                         ' address the next byte in the string
                        cmp       t3,#"."                     wz                ' ignore decimal points
          if_e          jmp       #:loop
                        add       digit_counter,#1                              ' increment a counter for each byte in the string
                        shr       common_mask,#1
                        shr       pattern_mask,#1
                        djnz      t1,#:loop
                        jmp       #display_string
:left_justify
                        mov       digit_counter,digits                          ' for left justify, start at the highest digit  
display_string
                        max       digit_counter,digits                          ' in case right_justify counts more bytes than there are digits 
                        rdword    t2,string_address
                        test      flags,#STROBE_FLAG          wc                ' Test strobe flag
          if_c          mov       cnt,delay_10us
          if_nc         mov       cnt,delay_80us
                        add       cnt,cnt
:digit_loop
                        rdbyte    t3,t2                       wz                ' read a byte from the string
          if_z          jmp       #wait_for_command                             '  end if null-terminator reached
                        sub       t3,#"0"                                       ' subtract the ASCII offset "0"
                        cmp       t3,_blank                   wz                ' Determine if byte is a blank,
          if_e          mov       t3,#10                                        '  a decimal point, a dash,
                        cmp       t3,_dot                     wz                '  or a digit     
          if_e          mov       t3,#11
                        cmp       t3,_minus                   wz
          if_e          mov       t3,#12
                        mov       pattern_address,table_address                 ' read the pattern from the lookup table
                        add       pattern_address,t3
                        rdbyte    pattern,pattern_address
                        add       t2,#1                                         ' determine if next byte is a decimal point
                        rdbyte    t3,t2                                         '  or with current digit if so
                        cmp       t3,#"."                     wz
          if_e          add       t2,#1
          if_e          or        pattern,dp_mask
                        test      flags,#STROBE_FLAG          wc                ' Test strobe flag
          if_c          jmp       #:strobe_segments
                        call      #display_digit
                        waitcnt   cnt,delay_80us                                ' persistence delay
                        jmp       #:next_digit
:strobe_segments
                        mov       segment_counter,#8                            
                        neg       segment_mask,#$02                             ' segment mask = $FFFE
:segments_loop
                        mov       t3,pattern                                    ' copy the segments pattern
                        andn      t3,segment_mask                               ' mask all but one segment
                        call      #display_digit
                        waitcnt   cnt,delay_10us                                ' persistence delay 
                        rol       segment_mask,#1
                        djnz      segment_counter,#:segments_loop
:next_digit
                        shl       common_mask,#1
                        shl       pattern_mask,#1
                        djnz      digit_counter,#:digit_loop
                        jmp       #wait_for_command
'----------------------------------------------------------------------------------------------------------------------
display_digit                       
                        mov       t3,pattern                                    ' make a copy of the pattern                          
                        and       pattern,pattern_mask                          ' clear the non-shifting bits                                                        
                        andn      t3,pattern_mask                               ' clear the shifting bits                                                                  
                        shl       pattern,#1                                    ' shift the shifting bits                               
                        or        pattern,t3                                    ' combine the shifted bits with the non-shifted bits
                        mov       t3,pattern                                    ' make a copy of the prepared pattern                     
                        test      flags,#COMMON_FLAG          wc                ' determine if common-anode or common-cathode (C = cathode)
          if_nc         xor       t3,_neg1                                      '  invert the copy if common-anode (low turns segments on)
                        shl       t3,offset                                     ' shift to the offset
                        or        pattern,common_mask                           ' combine the common_mask with the pattern
                        shl       pattern,offset                                ' shift to the offset
                        mov       dira,pattern                                  ' apply pattern to dira
                        mov       outa,t3                                       ' apply t3 to outa
display_digit_ret       ret
'======================================================================================================================
_blank                  long      " " - "0"                                     ' constants for comparing bytes in the string
_dot                    long      "." - "0"
_minus                  long      "-" - "0"
delay_80us              long      _xinfreq * 16 / 12_500 
delay_10us              long      _xinfreq * 16 / 100_000
_2Hz                    long      107                                           ' 2^32 x 12.5ns x rate
_neg1                   long      -1
common_mask             res       1
pattern_mask            res       1
flags                   res       1
offset                  res       1
levels                  res       1                                             ' b1 = digits hi/low, b0 = segments hi/low
string_address          res       1
table_address           res       1                                             ' address of lookup_table
pattern_address         res       1                                             ' address of a specific pattern in the lookup table
segment_mask            res       1                                             ' mask for a single segment - used for strobing segments
dp_mask                 res       1                                             ' bit mask for the decimal point
flags_address           res       1                                             
digits                  res       1                                             ' contains the number of digits in the display
pattern                 res       1                                             ' contains a pattern from the lookup table
digit_counter           res       1                                             ' contains number of digits to display
segment_counter         res       1
t1                      res       1
t2                      res       1
t3                      res       1

                        fit

DAT                     
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}               