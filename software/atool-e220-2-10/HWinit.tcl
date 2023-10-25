set gaSet(javaLocation) C:\\Program\ Files\\Java\\jre1.8.0_191\\bin\\
#set gaSet(javaLocation) C:\\Program\ Files\ (x86)\\Java\\jre6\\bin
set gaSet(pioType) "Ex"
switch -exact -- $gaSet(pair) {
  1 {
      set gaSet(comDut)    1
#       console eval {wm geometry . +150+1}
      console eval {wm title . "Con 1"}   
      set gaSet(pioPwr1)     4
      set gaSet(pioPwr2)     4; #3
        }
  2 {
      set gaSet(comDut)    4
#       console eval {wm geometry . +150+200}
      console eval {wm title . "Con 2"}          
      set gaSet(pioPwr1)     3; #2
      set gaSet(pioPwr2)     3; #1      
  }
  3 {
      set gaSet(comDut)    7
#       console eval {wm geometry . +150+400}
      console eval {wm title . "Con 3"}   
      set gaSet(pioPwr1)     2; #8
      set gaSet(pioPwr2)     2; #7
  }
  4 {
      set gaSet(comDut)    5
#       console eval {wm geometry . +150+600}
      console eval {wm title . "Con 4"}          
      set gaSet(pioPwr1)     1; #6
      set gaSet(pioPwr2)     1; #5      
  }
  5 {
      set gaSet(comDut)    11
#       console eval {wm geometry . +150+1}
      console eval {wm title . "Con 5"}   
      set gaSet(pioPwr1)     8
      set gaSet(pioPwr2)     8; #3
  }
  6 {
      set gaSet(comDut)    9
#       console eval {wm geometry . +150+200}
      console eval {wm title . "Con 6"}          
      set gaSet(pioPwr1)     7; #2
      set gaSet(pioPwr2)     7; #1      
  }
  7 {
      set gaSet(comDut)    10
#       console eval {wm geometry . +150+400}
      console eval {wm title . "Con 7"}   
      set gaSet(pioPwr1)     6; #8
      set gaSet(pioPwr2)     6; #7
        }
  8 {
      set gaSet(comDut)    6
#       console eval {wm geometry . +150+600}
      console eval {wm title . "Con 8"}          
      set gaSet(pioPwr1)     5; #6
      set gaSet(pioPwr2)     5; #5      
  }
} 
source lib_PackSour_E220Dnl.tcl
