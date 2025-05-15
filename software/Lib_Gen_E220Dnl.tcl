
##***************************************************************************
##** OpenRL
##***************************************************************************
proc OpenRL {} {
  global gaSet
  if [info exists gaSet(curTest)] {
    set curTest $gaSet(curTest)
  } else {
    set curTest "1..ID"
  }
  CloseRL
  catch {RLEH::Close}
  
  RLEH::Open
  
  puts "Open PIO [MyTime]"
  set ret [OpenPio]
  set ret1 [OpenComUut]
  set ret2 0   
  
  set gaSet(curTest) $curTest
  puts "[MyTime] ret:$ret ret1:$ret1 ret2:$ret2 " ; update
  if {$ret1!=0 || $ret2!=0} {
    return -1
  }
  return 0
}

# ***************************************************************************
# OpenComUut
# ***************************************************************************
proc OpenComUut {} {
  global gaSet
  set ret [RLSerial::Open $gaSet(comDut) 9600 n 8 1]
  if {$ret!=0} {
    set gaSet(fail) "Open COM $gaSet(comDut) fail"
  }
  return $ret
}
proc ocu {} {OpenComUut}
proc ouc {} {OpenComUut}
proc ccu {} {CloseComUut}
proc cuc {} {CloseComUut}

# ***************************************************************************
# CloseComUut
# ***************************************************************************
proc CloseComUut {} {
  global gaSet
  catch {RLSerial::Close $gaSet(comDut)}
  return {}
}

#***************************************************************************
#** CloseRL
#***************************************************************************
proc CloseRL {} {
  global gaSet
  set gaSet(serial) ""
  ClosePio
  puts "CloseRL ClosePio" ; update
  CloseComUut
  puts "CloseRL CloseComUut" ; update 
  catch {RLEH::Close}
}

# ***************************************************************************
# RetriveUsbChannel
# ***************************************************************************
proc RetriveUsbChannel {} {
  global gaSet
  # parray ::RLUsbPio::description *Ser*
  if {$gaSet(pioType)=="Ex"} {
    return 1
  }
  set boxL [lsort -dict [array names ::RLUsbPio::description]]
  if {[llength $boxL]!=28} {
    set gaSet(fail) "Not all USB ports are open. Please close and open the GUIs again"
    return -1
  }
  foreach nam $boxL {
    if [string match *Ser*Num* $nam] {
      foreach {usbChan serNum} [split $nam ,] {}
      set serNum $::RLUsbPio::description($nam)
      puts "usbChan:$usbChan serNum: $serNum"      
      if {$serNum==$gaSet(pioBoxSerNum)} {
        set channel $usbChan
        break
      }
    }  
  }
  puts "serNum:$serNum channel:$channel"
  return $channel
}
# ***************************************************************************
# OpenPio
# ***************************************************************************
proc OpenPio {} {
  global gaSet
  set channel [RetriveUsbChannel]
  if {$channel=="-1"} {
    return -1
  }
  foreach rb {1} {
    set gaSet(idPwr$rb)  [RL[set gaSet(pioType)]Pio::Open $gaSet(pioPwr$rb) RBA $channel]
  }
  return 0
}

# ***************************************************************************
# ClosePio
# ***************************************************************************
proc ClosePio {} {
  global gaSet gaFS
  set ret 0
  foreach rb "1" {
	  catch {RL[set gaSet(pioType)]Pio::Close $gaSet(idPwr$rb)}
  }
  return $ret
}
# ***************************************************************************
# SaveUutInit
# ***************************************************************************
proc SaveUutInit {fil} {
  global gaSet
  puts "SaveUutInit $fil"
  set id [open $fil w]
  puts $id "set gaSet(sw)          \"$gaSet(sw)\""
  puts $id "set gaSet(dbrSW)       \"$gaSet(dbrSW)\""
  puts $id "set gaSet(swPack)      \"$gaSet(swPack)\""
  
  puts $id "set gaSet(dbrBVerSw)   \"$gaSet(dbrBVerSw)\""
  puts $id "set gaSet(dbrBVer)     \"$gaSet(dbrBVer)\""
  if ![info exists gaSet(cpld)] {
    set gaSet(cpld) ???
  }
  puts $id "set gaSet(cpld)        \"$gaSet(cpld)\""
  
  if [info exists gaSet(DutFullName)] {
    puts $id "set gaSet(DutFullName) \"$gaSet(DutFullName)\""
  }
  if [info exists gaSet(DutInitName)] {
    puts $id "set gaSet(DutInitName) \"$gaSet(DutInitName)\""
  }
  foreach indx {Boot SW 19 Half19  DGasp ExtClk 19SyncE Half19SyncE Aux1 Aux2 Default Conf} {
    if ![info exists gaSet([set indx]CF)] {
      set gaSet([set indx]CF) ??
    }
    puts $id "set gaSet([set indx]CF) \"$gaSet([set indx]CF)\""
  }
  foreach indx {licDir} {
    if ![info exists gaSet($indx)] {
      puts "SaveUutInit fil:$SaveUutInit gaSet($indx) doesn't exist!"
      set gaSet($indx) ???
    }
    puts $id "set gaSet($indx) \"$gaSet($indx)\""
  }
  
  
  
  #puts $id "set gaSet(macIC)      \"$gaSet(macIC)\""
  close $id
}  
# ***************************************************************************
# SaveInit
# ***************************************************************************
proc SaveInit {} {
  global gaSet gaGui 
  set id [open [info host]/init$gaSet(pair).tcl w]
  puts $id "set gaGui(xy) +[winfo x .]+[winfo y .]"
  if [info exists gaSet(DutFullName)] {
    puts $id "set gaSet(entDUT) \"$gaSet(DutFullName)\""
  }
  if [info exists gaSet(DutInitName)] {
    puts $id "set gaSet(DutInitName) \"$gaSet(DutInitName)\""
  }
    
  puts $id "set gaSet(performShortTest) \"$gaSet(performShortTest)\""  
  
  if {![info exists gaSet(eraseTitle)]} {
    set gaSet(eraseTitle) 1
  }
  puts $id "set gaSet(eraseTitle) \"$gaSet(eraseTitle)\""
  
  if {![info exists gaSet(ddrMultyQty)]} {
    set gaSet(ddrMultyQty) 5
  }
  puts $id "set gaSet(ddrMultyQty) \"$gaSet(ddrMultyQty)\""
  
  if ![info exists gaSet(readTrace)] {
    set gaSet(readTrace) 1
  }
  puts $id "set gaSet(readTrace) \"$gaSet(readTrace)\""
  
  
  close $id
   
}

#***************************************************************************
#** MyTime
#***************************************************************************
proc MyTime {} {
  return [clock format [clock seconds] -format "%T   %d/%m/%Y"]
}

#***************************************************************************
#** Send
#** #set ret [RLCom::SendSlow $com $toCom 150 buffer $fromCom $timeOut]
#** #set ret [Send$com $toCom buffer $fromCom $timeOut]
#** 
#***************************************************************************
proc Send {com sent {expected stamm} {timeOut 8}} {
  global buffer gaSet
  if {$gaSet(act)==0} {return -2}

  #puts "sent:<$sent>"
  regsub -all {[ ]+} $sent " " sent
  #puts "sent:<[string trimleft $sent]>"
  ##set cmd [list RLSerial::SendSlow $com $sent 50 buffer $expected $timeOut]
  if {$expected=="stamm"} {
    set cmd [list RLSerial::Send $com $sent]
    set tt "[expr {[lindex [time {set ret [eval $cmd]}] 0]/1000000.0}]sec"
    puts "\nsend: ---------- [MyTime] ---------------------------"
    puts "send: com:$com, ret:$ret tt:$tt, sent=$sent"
    puts "send: ----------------------------------------\n"
    update
    return $ret
    
  } 
  set cmd [list RLSerial::Send $com $sent buffer $expected $timeOut]
  #set cmd [list RLCom::Send $com $sent buffer $expected $timeOut]
  if {$gaSet(act)==0} {return -2}
  set tt "[expr {[lindex [time {set ret [eval $cmd]}] 0]/1000000.0}]sec"
  #puts buffer:<$buffer> ; update
  regsub -all -- {\x1B\x5B..\;..H} $buffer " " b1
  regsub -all -- {\x1B\x5B.\;..H}  $b1 " " b1
  regsub -all -- {\x1B\x5B..\;.H}  $b1 " " b1
  regsub -all -- {\x1B\x5B.\;.H}   $b1 " " b1
  regsub -all -- {\x1B\x5B..\;..r} $b1 " " b1
  regsub -all -- {\x1B\x5B.J}      $b1 " " b1
  regsub -all -- {\x1B\x5BK}       $b1 " " b1
  regsub -all -- {\x1B\x5B\x38\x30\x44}     $b1 " " b1
  regsub -all -- {\x1B\x5B\x31\x42}      $b1 " " b1
  regsub -all -- {\x1B\x5B.\x6D}      $b1 " " b1
  regsub -all -- \\\[m $b1 " " b1
  set re \[\x1B\x0D\]
  regsub -all -- $re $b1 " " b2
  #regsub -all -- ..\;..H $b1 " " b2
  regsub -all {\s+} $b2 " " b3
  regsub -all {\-+} $b3 "-" b3
  regsub -all -- {\[0\;30\;47m} $b3 " " b3
  regsub -all -- {\[1\;30\;47m} $b3 " " b3
  regsub -all -- {\[0\;34\;47m} $b3 " " b3
  regsub -all -- {\[74G}        $b3 " " b3
  set buffer $b3
  #puts "sent:<$sent>"
  if $gaSet(puts) {
    #puts "\nsend: ---------- [clock format [clock seconds] -format %T] ---------------------------"
    puts "\nsend: ---------- [MyTime] ---------------------------"
    puts "send: com:$com, ret:$ret tt:$tt, sent=$sent,  expected=$expected, buffer=$buffer"
    puts "send: ----------------------------------------\n"
    update
  }
  
  #RLTime::Delayms 50
  return $ret
}

#***************************************************************************
#** Status
#***************************************************************************
proc Status {txt {color white}} {
  global gaSet gaGui
  #set gaSet(status) $txt
  #$gaGui(labStatus) configure -bg $color
  $gaSet(sstatus) configure -bg $color  -text $txt
  if {$txt!=""} {
    puts "\n ..... $txt ..... /* [MyTime] */ \n"
  }
  $gaSet(runTime) configure -text ""
  update
}


##***************************************************************************
##** Wait
##** 
##** 
##***************************************************************************
proc Wait {txt count {color white}} {
  global gaSet
  puts "\nStart Wait $txt $count.....[MyTime]"; update
  Status $txt $color 
  for {set i $count} {$i > 0} {incr i -1} {
    if {$gaSet(act)==0} {return -2}
	 $gaSet(runTime) configure -text $i
	 RLTime::Delay 1
  }
  $gaSet(runTime) configure -text ""
  Status "" 
  puts "Finish Wait $txt $count.....[MyTime]\n"; update
  return 0
}


#***************************************************************************
#** Init_UUT
#***************************************************************************
proc Init_UUT {init} {
  global gaSet
  set gaSet(curTest) $init
  Status ""
  OpenRL
  $init
  CloseRL
  set gaSet(curTest) ""
  Status "Done"
}


# ***************************************************************************
# PerfSet
# ***************************************************************************
proc PerfSet {state} {
  global gaSet gaGui
  set gaSet(perfSet) $state
  puts "PerfSet state:$state"
  switch -exact -- $state {
    1 {$gaGui(noSet) configure -relief raised -image [Bitmap::get images/Set] -helptext "Run with the UUTs Setup"}
    0 {$gaGui(noSet) configure -relief sunken -image [Bitmap::get images/noSet] -helptext "Run without the UUTs Setup"}
    swap {
      if {[$gaGui(noSet) cget -relief]=="raised"} {
        PerfSet 0
      } elseif {[$gaGui(noSet) cget -relief]=="sunken"} {
        PerfSet 1
      }
    }  
  }
}
# ***************************************************************************
# MyWaitFor
# ***************************************************************************
proc MyWaitFor {com expected testEach timeout} {
  global buffer gaGui gaSet
  #Status "Waiting for \"$expected\""
  if {$gaSet(act)==0} {return -2}
  puts [MyTime] ; update
  set startTime [clock seconds]
  set runTime 0
  while 1 {
    #set ret [RLCom::Waitfor $com buffer $expected $testEach]
    #set ret [RLCom::Waitfor $com buffer stam $testEach]
    set ret [Send $com \r stam $testEach]
    foreach expd $expected {
      if [string match *$expd* $buffer] {
        set ret 0
      }
      puts "buffer:__[set buffer]__ expected:\"$expected\" expd:\"$expd\" ret:$ret runTime:$runTime" ; update
#       if {$expd=="PASSWORD"} {
#         ## in old versiond you need a few enters to get the uut respond
#         Send $com \r stam 0.25
#       }
      if [string match *$expd* $buffer] {
        break
      }
    }
    #set ret [Send $com \r $expected $testEach]
    set nowTime [clock seconds]; set runTime [expr {$nowTime - $startTime}] 
    $gaSet(runTime) configure -text $runTime
    #puts "i:$i runTime:$runTime ret:$ret buffer:_${buffer}_" ; update
    if {$ret==0} {break}
    if {$runTime>$timeout} {break }
    if {$gaSet(act)==0} {set ret -2 ; break}
    update
  }
  puts "[MyTime] ret:$ret runTime:$runTime"
  $gaSet(runTime) configure -text ""
  Status ""
  return $ret
}   
#***************************************************************************
#** Power
#***************************************************************************
proc Power {ps state} {
  global gaSet gaGui 
  puts "[MyTime] Power $ps $state"
  set ret 0
  switch -exact -- $ps {
    1   {set pioL 1}
    2   {set pioL 2}
    all {set pioL "1"}
  } 
  switch -exact -- $state {
    on  {
	    foreach pio $pioL {      
        RL[set gaSet(pioType)]Pio::Set $gaSet(idPwr$pio) 1
      }
    } 
	  off {
	    foreach pio $pioL {
	      RL[set gaSet(pioType)]Pio::Set $gaSet(idPwr$pio) 0
      }
    }
  }
#   $gaGui(tbrun)  configure -state disabled 
#   $gaGui(tbstop) configure -state normal
  Status ""
  update
  #exec C:\\RLFiles\\Btl\\beep.exe &
#   RLSound::Play information
  return $ret
}

#***************************************************************************
#** PowerOffOn
#***************************************************************************
proc PowerOffOn {} {
  Power all off
  RLTime::Delay 2
  Power all on
}
# ***************************************************************************
# GuiPower
# ***************************************************************************
proc GuiPower {n state} { 
  global gaSet 
  RLEH::Open
  switch -exact -- $n {
    1.1 - 2.1 - 3.1 - 4.1 - 5.1 - 6.1 - 7.1 - 8.1 {set portL [list $gaSet(pioPwr1)]}
    1.2 - 2.2 - 3.2 - 4.2 - 5.2 - 6.2 - 7.2 - 8.2 {set portL [list $gaSet(pioPwr2)]}      
    1 - 2 - 3 - 4 - 5 - 6 - 7 - 8                 {set portL [list $gaSet(pioPwr1)]}  
  }  
  ## 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8  {set portL [list $gaSet(pioPwr1) $gaSet(pioPwr2)]}  
  
  set channel [RetriveUsbChannel]    
  foreach rb $portL {
    set id [RL[set gaSet(pioType)]Pio::Open $rb RBA  $channel]
    puts "rb:<$rb> id:<$id>"
    RL[set gaSet(pioType)]Pio::Set $id $state
    RL[set gaSet(pioType)]Pio::Close $id 
  }
  RLEH::Close
} 

#***************************************************************************
#** Wait
#***************************************************************************
proc _Wait {ip_time ip_msg {ip_cmd ""}} {
  global gaSet 
  Status $ip_msg 

  for {set i $ip_time} {$i >= 0} {incr i -1} {       	 
	 if {$ip_cmd!=""} {
      set ret [eval $ip_cmd]
		if {$ret==0} {
		  set ret $i
		  break
		}
	 } elseif {$ip_cmd==""} {	   
	   set ret 0
	 }

	 #user's stop case
	 if {$gaSet(act)==0} {		 
      return -2
	 }
	 
	 RLTime::Delay 1	 
    $gaSet(runTime) configure -text " $i "
	 update	 
  }
  $gaSet(runTime) configure -text ""
  update   
  return $ret  
}

# ***************************************************************************
# AddToLog
# ***************************************************************************
proc AddToLog {line} {
  global gaSet
  #set logFileID [open tmpFiles/logFile-$gaSet(pair).txt a+]
  set logFileID [open $gaSet(logFile.$gaSet(pair)) a+] 
    puts $logFileID "..[MyTime]..$line"
  close $logFileID
}

# ***************************************************************************
# AddToPairLog
# ***************************************************************************
proc AddToPairLog {pair line}  {
  global gaSet
  set logFileID [open $gaSet(log.$pair) a+]
  puts $logFileID "..[MyTime]..$line"
  close $logFileID
}
# ***************************************************************************
# ShowLog 
# ***************************************************************************
proc ShowLog {} {
	global gaSet
	#exec notepad tmpFiles/logFile-$gaSet(pair).txt &
#   if {[info exists gaSet(logFile.$gaSet(pair))] && [file exists $gaSet(logFile.$gaSet(pair))]} {
#     exec notepad $gaSet(logFile.$gaSet(pair)) &
#   }
  if {[info exists gaSet(log.$gaSet(pair))] && [file exists $gaSet(log.$gaSet(pair))]} {
    exec notepad $gaSet(log.$gaSet(pair)) &
  }
}

# ***************************************************************************
# mparray
# ***************************************************************************
proc mparray {a {pattern *}} {
  upvar 1 $a array
  if {![array exists array]} {
	  error "\"$a\" isn't an array"
  }
  set maxl 0
  foreach name [lsort -dict [array names array $pattern]] {
	  if {[string length $name] > $maxl} {
	    set maxl [string length $name]
  	}
  }
  set maxl [expr {$maxl + [string length $a] + 2}]
  foreach name [lsort -dict [array names array $pattern]] {
	  set nameString [format %s(%s) $a $name]
	  puts stdout [format "%-*s = %s" $maxl $nameString $array($name)]
  }
  update
}
# ***************************************************************************
# GetDbrName
# ***************************************************************************
proc GetDbrName {} {
  global gaSet gaGui
  Status "Please wait for retriving DBR's parameters"
  set barcode [set gaSet(entDUT) [string toupper $gaSet(entDUT)]] ; update
  
  if [file exists MarkNam_$barcode.txt] {
    file delete -force MarkNam_$barcode.txt
  }
  wm title . "$gaSet(pair) : "
  after 500
  
#   set javaLoc1 C:\\Program\ Files\\Java\\jre6\\bin\\
#   set javaLoc2 C:\\Program\ Files\ (x86)\\Java\\jre6\\bin\\
#   if {[file exist $javaLoc1]} {
#     set javaLoc $javaLoc1
#   } elseif {[file exist $javaLoc2]} {
#     set javaLoc $javaLoc2
#   } else {
#     set gaSet(fail) "Java application is missing"
#     return -1
#   }
  # set javaLoc $gaSet(javaLocation)
  # catch {exec $javaLoc\\java -jar $::RadAppsPath/OI4Barcode.jar $barcode} b
  set fileName MarkNam_$barcode.txt
  after 1000
  # if ![file exists MarkNam_$barcode.txt] {
    # set gaSet(fail) "File $fileName is not created. Verify the Barcode"
    # #exec C:\\RLFiles\\Tools\\Btl\\failbeep.exe &
    # RLSound::Play fail
	  # Status "Test FAIL"  red
    # DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error
    # pack $gaGui(frFailStatus)  -anchor w
	  # $gaSet(runTime) configure -text ""
  	# return -1
  # }
  
  # set fileId [open "$fileName"]
    # seek $fileId 0
    # set res [read $fileId]    
  # close $fileId
  
  # #set txt "$barcode $res"
  # set txt "[string trim $res]"
  # #set gaSet(entDUT) $txt
  
  foreach {ret resTxt} [::RLWS::Get_OI4Barcode $barcode] {}
  if {$ret=="0"} {
    #  set dbrName [dict get $ret "item"]
    set dbrName $resTxt
  } else {
    set gaSet(fail) $resTxt
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBoxRamzor -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  set txt "[string trim $dbrName]"
  set gaSet(entDUT) ""
  puts "GetDbrName <$txt>"
  
  set initName [regsub -all / $dbrName .]
  puts "GetDbrName dbrName:<$dbrName>"
  puts "GetDbrName initName:<$initName>"
  set gaSet(DutFullName) $dbrName
  set gaSet(DutInitName) $initName.tcl
  
  file delete -force MarkNam_$barcode.txt
  #file mkdir [regsub -all / $res .]
  
  if {[file exists uutInits/$gaSet(DutInitName)]} {
    source uutInits/$gaSet(DutInitName)  
    #UpdateAppsHelpText  
  } else {
    ## if the init file doesn't exist, fill the parameters by ? signs
    foreach v {sw} {
      puts "GetDbrName gaSet($v) does not exist"
      set gaSet($v) ??
    }
    foreach en {licEn} {
      set gaSet($v) 0
    } 
  } 
  wm title . "$gaSet(pair) : $gaSet(DutFullName)"
  pack forget $gaGui(frFailStatus)
  
  ToggleTraceMenu
  #Status ""
  update
  BuildTests
  
  set ret [GetDbrSW $barcode]
  puts "GetDbrName ret of GetDbrSW:$ret" ; update
  if {$ret!=0} {
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  }  
  puts ""
  
  focus -force $gaGui(tbrun)
  if {$ret==0} {
    Status "Ready"
  }
  return $ret
}

# ***************************************************************************
# DelMarkNam
# ***************************************************************************
proc DelMarkNam {} {
  if {[catch {glob MarkNam*} MNlist]==0} {
    foreach f $MNlist {
      file delete -force $f
    }  
  }
}

# ***************************************************************************
# GetInitFile
# ***************************************************************************
proc GetInitFile {} {
  global gaSet gaGui
  set fil [tk_getOpenFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl]
  if {$fil!=""} {
    source $fil
    set gaSet(entDUT) "" ; #$gaSet(DutFullName)
    wm title . "$gaSet(pair) : $gaSet(DutFullName)"
    #UpdateAppsHelpText
    pack forget $gaGui(frFailStatus)
    Status ""
    BuildTests
  }
}
# ***************************************************************************
# UpdateAppsHelpText
# ***************************************************************************
proc UpdateAppsHelpText {} {
  global gaSet gaGui
  #$gaGui(labPlEnPerf) configure -helptext $gaSet(pl)
  #$gaGui(labUafEn) configure -helptext $gaSet(uaf)
  #$gaGui(labUdfEn) configure -helptext $gaSet(udf)
}

# ***************************************************************************
# RetriveDutFam
# RetriveDutFam [regsub -all / ETX-DNFV-M/I7/128S/8R .].tcl     (Alex-21-03-2021)
# ***************************************************************************
proc RetriveDutFam {{dutInitName ""}} {
  global gaSet 
  set gaSet(dutFam) NA 
  set gaSet(dutBox) NA 
  set gaSet(ps) NA
  set gaSet(10G) NA
  set gaSet(1G) NA
  set gaSet(clkOpt) NA
  set gaSet(sk) NA
  
  if {$dutInitName==""} {
    set dutInitName $gaSet(DutInitName)
  }
  puts "RetriveDutFam $dutInitName"
  
  if {[string match *.AC*.* $dutInitName]==1} {
    set ps AC
  } elseif {[string match *.DC*.* $dutInitName]==1} {
    set ps DC
  } elseif {[string match ETX-203AX_RJIO.* $dutInitName]==1 || \
            [string match ETX-203AX_COV.GE.* $dutInitName]==1 || \
            [string match ETX-203AX_SH.GE30.2SFP.2UTP2SFP.* $dutInitName]==1 || \
            [string match ETX-203AX_KOS.GE30.* $dutInitName]==1 ||\
            [string match ETX-203AX_TWC.N.GE30.2SFP.2UTP2SFP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-2I-10G_TWC.AC.4SFPP.4SFP4UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-2I-10G_FT.H.ACDC.4SFPP.12S12U.PTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX.GE.2SFP.4UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_CELLCOM.GE30.2SFP.2UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_SFR2.N.GE30.2SFP.4UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_KOS.N.GE30.2SFP.4UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_BYT.N.GE30.1SFP1UTP.2UTP2SFP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_ATT.GE30.2SFP.2SFP.X.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-2I-100G* $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_KOS.N.GE30.2SFP.2UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-2I-B.WR.2SFP.4UTP.RTR.tcl $gaSet(DutInitName)]==1} {
    set ps AC
  }
  
  if {[string match *.*XFP.* $dutInitName]==1} {
    regexp {(\d)XFP} $dutInitName - 10G
  } else {
    set 10G NA
  }
  
  set 1G None
  if {[string match *.*U.* $dutInitName]==1} {
    if [regexp {(([1|2])0)U\.} $dutInitName - utpQty b] {
      set 1G ${utpQty}UTP
    }
  }
  
  if {[string match *.*S.* $dutInitName]==1} {
    regexp {(([1|2])0)S\.} $dutInitName - sfpQty b
    set 1G ${sfpQty}SFP
  }
  if {[string match *.10U10S.* $dutInitName]==1} {
    set 1G 10SFP_10UTP
  }
  if {[string match *.12S12U.* $dutInitName]==1} {
    set 1G 12SFP_12UTP
  }
  
  if {[string match *.PTP.* $dutInitName]==1} {
    set clkOpt PTP
  } elseif {[string match *.SYE.* $dutInitName]==1} {
    set clkOpt SYE
  } else {
    set clkOpt NA
  }
  
  if {[string match *.ESK.* $dutInitName]==1} {
    set sk ESK
  } elseif {[string match *.BSK.* $dutInitName]==1} {
    set sk BSK
  } else {
    set sk NA
  }
#   if {[string match *_FT.* $dutInitName]==1} {
#     set sk ESK
#   }
  set gaSet(dutFam) $ps.$10G.$1G.$clkOpt.$sk
  set gaSet(ps) $ps
  set gaSet(10G) $10G
  set gaSet(1G) $1G
  set gaSet(clkOpt) $clkOpt
  set gaSet(sk) $sk
  
  if 0 {
  set gaSet(dutFam) 0.0.None.0.0
  
  if {[string match *.H.* $dutInitName]==1 || [string match *.K.* $dutInitName]==1 ||\
      [string match *.HN.* $dutInitName]==1} {
    set optL  [list etx h ps 10G 1G clkOpt sk]
  } elseif {[string match *.SFP.* $dutInitName]==1} {
    set optL  [list etx ps sfp 10G 1G clkOpt sk]
  } else {
    set optL  [list etx ps 10G 1G clkOpt sk]
  }
  
  if {[string match *.AC*.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) AC.$10G.$1G.$clkOpt.$sk  
    }
  }
  if {[string match *.DC*.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) DC.$10G.$1G.$clkOpt.$sk  
    }
  }
  if {[string match *.*XFP.* $dutInitName]==1} {
    foreach $optL [split $dutInitName .] {}
    set 10Gqty  [string index $10G 0]
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10Gqty.$1G.$clkOpt.$sk  
    }
  }
  if {[string match *.*0U.* $dutInitName]==1} {
    foreach $optL [split $dutInitName .] {}
    set 1Gtype  [string index $1G 0]0UTP
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1Gtype.$clkOpt.$sk  
    }
  }
  if {[string match *.*0S.* $dutInitName]==1} {
    foreach $optL [split $dutInitName .] {}
    set 1Gtype  [string index $1G 0]0SFP
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1Gtype.$clkOpt.$sk  
    }
  }
  if {[string match *.10U10S.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.10SFP_10UTP.$clkOpt.$sk  
    }
  }
  if {[string match *.PTP.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1G.PTP.$sk  
    }
  }
  if {[string match *.SYE.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1G.SYE.$sk  
    }
  }
  if {[string match *.ESK.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1G.$clkOpt.ESK  
    }
  }
  if {[string match *.ESK.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1G.$clkOpt.BSK  
    }
  }
  if {[string match *_FT.* $dutInitName]==1} {
    foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .] {
      set gaSet(dutFam) $ps.$10G.$1G.$clkOpt.ESK  
    }
  }
  }
  
  foreach par {ps 10G 1G clkOpt sk} {
    puts -nonewline "${par}=$gaSet($par), "
  }
  puts ""
  

#   puts "DutFam:$gaSet(dutFam)" ; update
#   foreach {ps 10G 1G clkOpt sk} [split $gaSet(dutFam) .]  {}
#   set gaSet(ps) $ps
#   set gaSet(10G) $10G
#   set gaSet(1G) $1G
#   set gaSet(clkOpt) $clkOpt
  
  
  
  puts "dutInitName:$dutInitName dutBox:$gaSet(dutBox) DutFam:$gaSet(dutFam)" ; update
  return {}
}                               
# ***************************************************************************
# DownloadConfFile
# ***************************************************************************
proc DownloadConfFile {cf cfTxt save com} {
  global gaSet  buffer
  puts "[MyTime] DownloadConfFile $cf \"$cfTxt\" $save $com"
  #set com $gaSet(comDut)
  if ![file exists $cf] {
    set gaSet(fail) "The $cfTxt configuration file ($cf) doesn't exist"
    return -1
  }
  Status "Download Configuration File $cf" ; update
  set s1 [clock seconds]
  set id [open $cf r]
  set c 0
  while {[gets $id line]>=0} {
    if {$gaSet(act)==0} {close $id ; return -2}
    if {[string length $line]>2 && [string index $line 0]!="#"} {
      incr c
      puts "line:<$line>"
      if {[string match {*address*} $line] && [llength $line]==2} {
        if {[string match *DefaultConf* $cfTxt] || [string match *RTR* $cfTxt]} {
          ## don't change address in DefaultConf
        } else {
          ##  address 10.10.10.12/24
          set dutIp 10.10.10.1[set gaSet(pair)]
          set address [set dutIp]/[lindex [split [lindex $line 1] /] 1]
          set line "address $address"
        }
      }
      if {[string match *EccXT* $cfTxt] || [string match *vvDefaultConf* $cfTxt] || [string match *aAux* $cfTxt]} {
        ## perform the configuration fast (without expected)
        set ret 0
        set buffer bbb
        RLSerial::Send $com "$line\r" 
      } else {
        if {[string match *Aux* $cfTxt]} {
          set gaSet(prompt) 205A
        } else {
          set waitFor ETX-2
        }
        if {[string match {*conf system name*} $line]} {
          set gaSet(prompt) [lindex $line end]
        }
        if {[string match *CUST-LAB-ETX203PLA-1* $line]} {
          set gaSet(prompt) "CUST-LAB-ETX203PLA-1"
        }
        if {[string match *BOOTSTRAP_ETX203AX* $line]} {
          set gaSet(prompt) "BOOTSTRAP_ETX203AX"
        }
        if {[string match *WallGarden_TYPE-3_et_4* $line]} {
          set gaSet(prompt) "WallGarden_TYPE-3"
        }
        if {[string match *ZTP* $line]} {
          set gaSet(prompt) "ZTP"
        }
        
        set ret [Send $com $line\r $gaSet(prompt) 60]
        
        if {[string match *KOSC-ETX-203AX* $buffer]} {
          set gaSet(prompt) "KOSC-ETX-203AX"
        }
        #Send $com "$line\r"
        #set ret [MyWaitFor $com {205A ETX-2 ztp} 0.25 60]
      }  
      if {$ret!=0} {
        set gaSet(fail) "Config of DUT failed"
        break
      }
      if {[string match {*cli error*} [string tolower $buffer]]==1} {
        if {[string match {*range overlaps with previous defined*} [string tolower $buffer]]==1} {
          ## skip the error
        } else {
          set gaSet(fail) "CLI Error"
          set ret -1
          break
        }
      }            
    }
  }
  close $id  
  if {$ret==0} {
    set ret [Send $com "exit all\r" $gaSet(prompt)]
    #Send $com "exit all\r" 
    #set ret [MyWaitFor $com {205A ETX-2 ztp} 0.25 60]
    if {$save==1} {
      set ret [Send $com "admin save\r" "successfull" 80]
    }
     
    set s2 [clock seconds]
    puts "[expr {$s2-$s1}] sec c:$c" ; update
  }
  Status ""
  puts "[MyTime] Finish DownloadConfFile" ; update
  return $ret 
}
# ***************************************************************************
# Ping
# ***************************************************************************
proc Ping {dutIp} {
  global gaSet
  puts "[MyTime] Pings to $dutIp" ; update
  set i 0
  while {$i<=4} {
    if {$gaSet(act)==0} {return -2}
    incr i
    #------
    catch {exec arp.exe -d}  ;#clear pc arp table
    catch {exec ping.exe $dutIp -n 2} buffer
    if {[info exist buffer]!=1} {
	    set buffer "?"  
    }  
    set ret [regexp {Packets: Sent = 2, Received = 2, Lost = 0 \(0% loss\)} $buffer var]
    puts "ping i:$i ret:$ret buffer:<$buffer>"  ; update
    if {$ret==1} {break}    
    #------
    after 500
  }
  
  if {$ret!=1} {
    puts $buffer ; update
	  set gaSet(fail) "Ping fail"
 	  return -1  
  }
  return 0
}
# ***************************************************************************
# GetMac
# ***************************************************************************
proc GetMac {fi} {
  puts "[MyTime] GetMac $fi" ; update
  set macFile c:/tmp/mac[set fi].txt
  exec $::RadAppsPath/MACServer.exe 0 1 $macFile 1
  set ret [catch {open $macFile r} id]
  if {$ret!=0} {
    set gaSet(fail) "Open Mac File fail"
    return -1
  }
  set buffer [read $id]
  close $id
  file delete $macFile)
  set ret [regexp -all {ERROR} $buffer]
  if {$ret!=0} {
    set gaSet(fail) "MACServer ERROR"
    exec beep.exe
    return -1
  }
  return [lindex $buffer 0]
}
# ***************************************************************************
# SplitString2Paires
# ***************************************************************************
proc SplitString2Paires {str} {
  foreach {f s} [split $str ""] {
    lappend l [set f][set s]
  }
  return $l
}

# ***************************************************************************
# GetDbrSW
# ***************************************************************************
proc GetDbrSW {barcode} {
  global gaSet gaGui
  set gaSet(dbrSW) ""
  
  set javaLoc $gaSet(javaLocation)
  #catch {exec $javaLoc\\java -jar $::RadAppsPath/SWVersions4IDnumber.jar $barcode} b
  foreach {res b} [::RLWS::Get_SwVersions $barcode] {}
  puts "GetDbrSW b:<$b>" ; update
  after 1000
  if ![info exists gaSet(swPack)] {
    set gaSet(swPack) ""
  }
  set swIndx [lsearch $b $gaSet(swPack)]  
  if {$swIndx<0} {
    set gaSet(fail) "There is no SW ID for $gaSet(swPack) ID:$barcode. Verify the Barcode."
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  set dbrSW [string trim [lindex $b [expr {1+$swIndx}]]]
  puts dbrSW:<$dbrSW>
  set gaSet(dbrSW) $dbrSW
  
#   set dbrBVerSwIndx [lsearch $b $gaSet(dbrBVerSw)]  
#   if {$dbrBVerSwIndx<0} {
#     set gaSet(fail) "There is no Boot SW ID for $gaSet(dbrBVerSw) ID:$barcode. Verify the Barcode."
#     RLSound::Play fail
# 	  Status "Test FAIL"  red
#     DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error
#     pack $gaGui(frFailStatus)  -anchor w
# 	  $gaSet(runTime) configure -text ""
#   	return -1
#   }
#   set dbrBVer [string trim [lindex $b [expr {1+$dbrBVerSwIndx}]]]
#   puts dbrBVer:<$dbrBVer>
#   set gaSet(dbrBVer) $dbrBVer
  
  pack forget $gaGui(frFailStatus)
  
  #set swTxt [glob SW*_$barcode.txt]
  #catch {file delete -force $swTxt}
  
  Status ""
  update
  BuildTests
  focus -force $gaGui(tbrun)
  return 0
}
# ***************************************************************************
# GuiMuxMngIO
# ***************************************************************************
proc GuiMuxMngIO {mngMode syncEmode} {
  global gaSet descript
  set channel [RetriveUsbChannel]   
  RLEH::Open
  set gaSet(idMuxMngIO) [RLUsbMmux::Open 1 $channel]
  MuxMngIO $mngMode $syncEmode
  RLUsbMmux::Close $gaSet(idMuxMngIO) 
  RLEH::Close
}
# ***************************************************************************
# MuxMngIO
##     MuxMngIO ioToGenMngToPc ioToGen
# ***************************************************************************
proc MuxMngIO {mngMode syncEmode} {
  global gaSet
  puts "MuxMngIO $mngMode $syncEmode"
  RLUsbMmux::AllNC $gaSet(idMuxMngIO)
  after 1000
  switch -exact -- $mngMode {
    ioToPc {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 7,2,9,14
    }
    ioToGenMngToPc {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 7,1,8,14
    }
    ioToGen {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 7,1
    }
    mngToPc {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 8,14
    }
    ioToCnt {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 7,3
    }
    nc {
      ## do nothing, already disconected
    }
  }
  switch -exact -- $syncEmode {
    ioToGen {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 15,21,22,28
    }
    ioToCnt {
      RLUsbMmux::ChsCon $gaSet(idMuxMngIO) 16,21,22,23
    }
    nc {
      ## do nothing, already disconected
    }
  }
}


# ***************************************************************************
# InitAux
# ***************************************************************************
proc InitAux {aux} {
  global gaSet
  set com $gaSet(com$aux)
  
  RLEH::Open
  set ret [RLSerial::Open $com 9600 n 8 1]
  
  set ret [Login205 $aux]
  if {$ret!=0} {
    set ret [Login205 $aux]
    
  }
  set gaSet(fail) "Logon fail"
  
  if {$ret==0} {
    Send $com "exit all\r" stam 0.25 
    set cf $gaSet([set aux]CF) 
    set cfTxt "$aux"
    set ret [DownloadConfFile $cf $cfTxt 1 $com]    
  }  
  catch {RLSerial::Close $com}
  RLEH::Close
  if {$ret==0} {
    Status "$aux is configured"  yellow
  } else {
    Status "Configuration of $aux failed" red
  }
  return $ret
} 
# ***************************************************************************
# wsplit
# ***************************************************************************
proc wsplit {str sep} {
  split [string map [list $sep \0] $str] \0
}
# ***************************************************************************
# LoadBootErrorsFile
# ***************************************************************************
proc LoadBootErrorsFile {} {
  global gaSet
  set gaSet(bootErrorsL) [list] 
  if ![file exists bootErrors.txt]  {
    return {}
  }
  
  set id [open  bootErrors.txt r]
    while {[gets $id line] >= 0} {
      set line [string trim $line]
      if {[string length $line] != 0} {
        lappend gaSet(bootErrorsL) $line
      }
    }

  close $id
  
#   foreach ber $bootErrorsL {
#     if [string length $ber] {
#      lappend gaSet(bootErrorsL) $ber
#    }
#   }
  return {}
}
# ***************************************************************************
# ToggleTraceMenu
# ***************************************************************************
proc ToggleTraceMenu {} {
  global gaSet
  if {[string match ETX-220*.tcl $gaSet(DutInitName)]==1} {
    set gaSet(readTrace) 0 ; # 1   07/08/2019 09:44:48 
    .mainframe setmenustate trac disabled
  } else {
    #set gaSet(readTrace) 0
    .mainframe setmenustate trac normal
  }
}
# ***************************************************************************
# CheckMac
# ***************************************************************************
proc CheckMacPerf {} {
  global gaSet gaGui
  
  set barc [string range $gaSet(1.barcode1) 0 10]
  set res [catch {exec java.exe -jar C://RadApps//CheckMAC.jar $barc A0B1C2D3E4F5} resChk]
  #puts "$barc res:<$res> resChk:<$resChk>"
  
  puts "[MyTime] Res of CheckMacPerf $barc : <$resChk>" ; update
  #set gaSet(ent1) ""
  if {$resChk=="0"} {  
    #set gaSet(entDUT$ba) "There is no MAC connected to $barc"
    set gaSet(fail) "There is no MAC connected to $barc"
    return -1
  } elseif {$resChk!="0"} {
    #puts "res:<$res>"
    if {$res=="1"} {
      set gaSet(fail)  "$resChk" 
      return -1
    } else {
      ## remove the 'already' word
      set resChk [lreplace $resChk [lsearch $resChk already] [lsearch $resChk already]]
      ## remove ID Number and add the barcode itself
      set resChk [lreplace $resChk [lsearch $resChk ID] [lsearch $resChk Number ] $barc]
      ## remove : from MAC
      set resChk [concat [lrange $resChk 0 end-1] [string trimleft [lindex $resChk end] :]]
      set gaSet(dbrMac) [lindex $resChk end]
      Status $resChk
      set txt "$resChk"
      #$gaGui(entDUT$ba) configure -background green
      set ret 0
    }
  }
  
  return 0
}  
 
# ***************************************************************************
# OpenTeraTerm
# ***************************************************************************
proc OpenTeraTerm {comName} {
  global gaSet
  set path1 C:\\Program\ Files\\teraterm\\ttermpro.exe
  set path2 C:\\Program\ Files\ \(x86\)\\teraterm\\ttermpro.exe
  set path3 C:\\teraterm\\ttermpro.exe
  if [file exist $path1] {
    set path $path1
  } elseif [file exist $path2] {
    set path $path2  
  } elseif [file exist $path3] {
    set path $path3  
  } else {
    puts "no teraterm installed"
    return {}
  }
  if {[string match *Dut* $comName] || [string match *Dls* $comName] || [string match *Aux* $comName]} {
    set baud 9600
  } else {
    set baud 115200
  }
  regexp {com(\w+)} $comName ma val
  set val Tester-$gaSet(pair).[string toupper $val] 
  exec $path /c=[set $comName] /baud=$baud /W="$val" &
  return {}
}  