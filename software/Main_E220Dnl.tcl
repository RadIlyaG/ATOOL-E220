# ***************************************************************************
# BuildTests
# ***************************************************************************
proc BuildTests {} {
  global gaSet gaGui glTests
  
  if {![info exists gaSet(DutInitName)] || $gaSet(DutInitName)==""} {
    puts "\n[MyTime] BuildTests DutInitName doesn't exists or empty. Return -1\n"
    return -1
  }
  puts "\n[MyTime] BuildTests DutInitName:$gaSet(DutInitName)\n"
  
  RetriveDutFam 
  foreach {b r p d ps np up} [split $gaSet(dutFam) .] {}
  
  if {[string match ETX-203AX_RJIO.H.GE30.2S6H.4S6H.tcl $gaSet(DutInitName)]==1 ||\
      [string match ETX-203AX_COV.GE.2SFP.4UTP.tcl $gaSet(DutInitName)]==1 ||\
      [string match ETX-203AX_SH.GE30.2SFP.2UTP2SFP.tcl $gaSet(DutInitName)]==1 ||\
      [string match ETX-203AX_KOS.GE30.2SFP.4UTP.tcl $gaSet(DutInitName)]==1 ||\
      [string match ETX-203AX_CELLCOM.GE30.2SFP.2UTP.tcl $gaSet(DutInitName)]==1 ||\
      [string match ETX-203AX_BYT.N.GE30.1SFP1UTP.2UTP2SFP.tcl $gaSet(DutInitName)]==1 ||\
      [string match ETX-203AX_KOS.N.GE30.2SFP.2UTP.tcl $gaSet(DutInitName)]==1} {
    set lTestsAllTests [list  SetDownload  SoftwareDownload LoadDefaultConfiguration] 
  } elseif {[string match ETX-2I-10G_TWC.AC.4SFPP.4SFP4UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX.GE.2SFP.4UTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-2I-B.WR.2SFP.4UTP.RTR.tcl $gaSet(DutInitName)]==1} {
    set lTestsAllTests [list SetDownload SoftwareDownload SW_ID]
  } elseif {[string match ETX-203AX_TWC.N.GE30.2SFP.2UTP2SFP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-2I-10G_FT.H.ACDC.4SFPP.12S12U.PTP.tcl $gaSet(DutInitName)]==1 ||\
            [string match ETX-203AX_SFR2.N.GE30.2SFP.4UTP.tcl $gaSet(DutInitName)]==1} {
    set lTestsAllTests [list SetDownload SoftwareDownload SW_ID LoadDefaultConfiguration]
  } elseif {[string match ETX-203AX_KOS.N.GE30.2SFP.4UTP.tcl $gaSet(DutInitName)]==1} {
    set lTestsAllTests [list Pages SetDownload  SoftwareDownload LoadDefaultConfiguration] 
  } elseif {[string match ETX-203AX_ATT.GE30.2SFP.2SFP.X.tcl $gaSet(DutInitName)]==1} {
    set lTestsAllTests [list Pages SetDownload SoftwareDownload CheckMac SerNumCleiCode LoadDefaultConfiguration] 
  } elseif {[string match ETX-2I-100G* $gaSet(DutInitName)]==1} {
    set lTestsAllTests [list FormatFlash Pages SetDownload  SoftwareDownload \
      SetToDefault LoadConfiguration LoadDefaultConfiguration]
  } else {
    set lTestsAllTests [list FormatFlash SetDownload Pages SoftwareDownload \
      SetTimeDate SetToDefault LoadConfiguration LoadDefaultConfiguration]
  }
  
  # 10:07 25/10/2023
  lappend lTestsAllTests Mac_BarCode
  
  set glTests ""
  set gaSet(TestMode) AllTests
  set lTests [set lTests$gaSet(TestMode)]
  
#   if {$gaSet(defConfEn)=="1"} {
#     lappend lTests LoadDefaultConfiguration
#   }
  
  for {set i 0; set k 1} {$i<[llength $lTests]} {incr i; incr k} {
    lappend glTests "$k..[lindex $lTests $i]"
  }
  
  set gaSet(startFrom) [lindex $glTests 0]
  $gaGui(startFrom) configure -values $glTests -height [llength $glTests]
  
}
# ***************************************************************************
# Testing
# ***************************************************************************
proc Testing {} {
  global gaSet glTests

  set startTime [$gaSet(startTime) cget -text]
  set stTestIndx [lsearch $glTests $gaSet(startFrom)]
  set lRunTests [lrange $glTests $stTestIndx end]
  
  if ![file exists c:/logs] {
    file mkdir c:/logs
    after 1000
  }
  set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M"]
  set gaSet(logFile) c:/logs/logFile_[set ti]_$gaSet(pair).txt
#   if {[string match {*Leds*} $gaSet(startFrom)] || [string match {*Mac_BarCode*} $gaSet(startFrom)]} {
#     set ret 0
#   }
  
  set pair 1
  if {$gaSet(act)==0} {return -2}
    
  set ::pair $pair
  puts "\n\n ********* DUT start *********..[MyTime].."
  Status "DUT start"
  set gaSet(curTest) ""
  update
    
#   AddToLog "********* DUT start *********"
  AddToPairLog $gaSet(pair) "********* DUT start *********"
#   if {$gaSet(dutBox)!="DNFV"} {
#     AddToLog "$gaSet(1.barcode1)"
#   }     
  puts "RunTests1 gaSet(startFrom):$gaSet(startFrom)"

  foreach numberedTest $lRunTests {
    set gaSet(curTest) $numberedTest
    puts "\n **** Test $numberedTest start; [MyTime] "
    update
    
      
    set testName [lindex [split $numberedTest ..] end]
    $gaSet(startTime) configure -text "$startTime ."
#     AddToLog "Test \'$testName\' started"
    AddToPairLog $gaSet(pair) "Test \'$testName\' started"
    set ret [$testName 1]
    if {$ret!=0 && $ret!="-2" && $testName!="Mac_BarCode" && $testName!="ID" && $testName!="Leds"} {
#     set logFileID [open tmpFiles/logFile-$gaSet(pair).txt a+]
#     puts $logFileID "**** Test $numberedTest fail and rechecked. Reason: $gaSet(fail); [MyTime]"
#     close $logFileID
#     puts "\n **** Rerun - Test $numberedTest finish;  ret of $numberedTest is: $ret;  [MyTime]\n"
#     $gaSet(startTime) configure -text "$startTime .."
      
#     set ret [$testName 2]
    }
    
    if {$ret==0} {
      set retTxt "PASS."
    } else {
      set retTxt "FAIL. Reason: $gaSet(fail)"
    }
#     AddToLog "Test \'$testName\' $retTxt"
    AddToPairLog $gaSet(pair) "Test \'$testName\' $retTxt"
       
    puts "\n **** Test $numberedTest finish;  ret of $numberedTest is: $ret;  [MyTime]\n" 
    update
    if {$ret!=0} {
      break
    }
    if {$gaSet(oneTest)==1} {
      set ret 1
      set gaSet(oneTest) 0
      break
    }
  }

  puts "RunTests4 ret:$ret gaSet(startFrom):$gaSet(startFrom)"   
  return $ret
}



# ***************************************************************************
# BootDownload
# ***************************************************************************
proc BootDownload {run} {
  set ret [Boot_Download]
  if {$ret!=0} {return $ret}
  
  set ret [FormatFlashAfterBootDnl]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# FormatFlash
# ***************************************************************************
proc FormatFlash {run} {
  set ret [FormatFlashAfterBootDnl]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# SetDownload
# ***************************************************************************
proc SetDownload {run} {
  set ret [SetSWDownload]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# Pages
# ***************************************************************************
proc Pages {run} {
  global gaSet buffer
  set ret [EntryBootMenu]
  if {$ret!=0} {return $ret}
  if ![info exist gaSet(1.barcode2)] {
    set gaSet(1.barcode2) stam
  }
  set ret [GetPageFile $gaSet($::pair.barcode1) $gaSet($::pair.barcode2)]
  if {$ret!=0} {return $ret}
  
  set ret [WritePages]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# SoftwareDownload
# ***************************************************************************
proc SoftwareDownload {run} {
  
  set ret [EntryBootMenu]
  if {$ret!=0} {return $ret}
  
  set ret [SoftwareDownloadTest]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# SetTime
# ***************************************************************************
proc SetTimeDate {run} {
  set ret [DateTime_Set]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# LoadDefaultConfiguration
# ***************************************************************************
proc LoadDefaultConfiguration {run} {
  global gaSet  
  Power all on
  set cf $gaSet(DefaultCF)
  if {$cf=="" || $cf=="c:/aa"} {
    set ret 0
  } else {
    set ret [LoadDefConf]
  }
  return $ret
}
# ***************************************************************************
# SetToDefault
# ***************************************************************************
proc SetToDefault {run} {
  global gaSet gaGui
  Power all on
  # 08:08 15/02/2023 set ret [FactDefault std]
  set ret [FactDefault stda]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# SW_ID
# ***************************************************************************
proc SW_ID {run} {
  global gaSet gaGui
  Power all on
  set ret [SwIdPerf]
  return $ret
}
# ***************************************************************************
# LoadConfiguration
# ***************************************************************************
proc LoadConfiguration {run} {
  global gaSet  
  Power all on
  set cf $gaSet(ConfCF)
  if {$cf=="" || $cf=="c:/aa"} {
    set ret 0
  } else {
    set ret [LoadConf]
  }
  return $ret
}
# ***************************************************************************
# SerNumCleiCode
# ***************************************************************************
proc SerNumCleiCode {run} {
  global gaSet  
  Power all on
  set ret [SerNumCleiCode_Perf]
  return $ret
}
# ***************************************************************************
# CheckMac
# ***************************************************************************
proc CheckMac {run} {  
  global gaSet
  set ret [CheckMacPerf]
  if {$ret!=0} {
    return $ret
  }
  set ret [ReadMac]
  if {$ret!=0} {
    return $ret
  }
  puts "CheckMac dbrMac=$gaSet(dbrMac) uutMac=$gaSet(1.mac1)"
  if {$gaSet(dbrMac) != $gaSet(1.mac1)} {
    set gaSet(fail) "DbrMac=$gaSet(dbrMac) UutMac=$gaSet(1.mac1)"
    set ret -1
  } else {
    set ret 0
  }
  return $ret
}
# ***************************************************************************
# Mac_BarCode
# ***************************************************************************
proc Mac_BarCode {run} {
  global gaSet  
  set pair $::pair 
  puts "Mac_BarCode \"$pair\" "
  mparray gaSet *mac* ; update
  mparray gaSet *barcode* ; update
  set badL [list]
  set ret -1
  foreach unit {1} {
    if ![info exists gaSet($pair.mac$unit)] {
      set ret [ReadMac]
      if {$ret!=0} {return $ret}
    }  
  } 
  foreach unit {1} {
    if {![info exists gaSet($pair.barcode$unit)] || $gaSet($pair.barcode$unit)=="skipped"}  {
      set ret [ReadBarcode]
      if {$ret!=0} {return $ret}
    }  
  }
  
  #set ret [ReadBarcode [PairsToTest]]
#   set ret [ReadBarcode]
#   if {$ret!=0} {return $ret}
  set ret [RegBC]
      
  return $ret
}
