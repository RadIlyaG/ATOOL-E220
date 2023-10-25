
#***************************************************************************
#**  Login
#***************************************************************************
proc Login {} {
  global gaSet buffer gaLocal
  set ret 0
  set gaSet(loginBuffer) ""
  set statusTxt $gaSet(sstatus)
  Status "Login into ETX220"
#   set ret [MyWaitFor $gaSet(comDut) {ETX-220A user>} 5 1]
  Send $gaSet(comDut) "\r" stam 0.25
  append gaSet(loginBuffer) "$buffer"
  Send $gaSet(comDut) "\r" stam 0.25
  append gaSet(loginBuffer) "$buffer"
  if {([string match {*220*} $buffer]==0) && ([string match {*203*} $buffer]==0) && ([string match {*user>*} $buffer]==0)} {
    set ret -1  
  } else {
    set ret 0
  }
  if {[string match {*Are you sure?*} $buffer]==0} {
   Send $gaSet(comDut) n\r stam 1
   append gaSet(loginBuffer) "$buffer"
  }
   
  if {[string match *password* $buffer]} {
    set ret 0
    Send $gaSet(comDut) \r stam 0.25
    append gaSet(loginBuffer) "$buffer"
  }
  if {[string match *FPGA* $buffer]} {
    set ret 0
    Send $gaSet(comDut) exit\r\r 220
    append gaSet(loginBuffer) "$buffer"
  }
  if {[string match *220* $buffer]} {
    set ret 0
    set gaSet(prompt) "ETX-220"
    return 0
  }
  if {[string match *203* $buffer]} {
    set ret 0
    set gaSet(prompt) "ETX-203"
    return 0
  }
  if {[string match *ETX-2I* $buffer]} {
    set ret 0
    set gaSet(prompt) "ETX-2I"
    return 0
  }
  if {[string match *ztp* $buffer]} {
    set ret 0
    set gaSet(prompt) "ztp"
    return 0
  }
  if {[string match *ZTP* $buffer]} {
    set ret 0
    set gaSet(prompt) "ZTP"
    return 0
  }
  if {[string match *CUST-LAB* $buffer]} {
    set ret 0
    set gaSet(prompt) "CUST-LAB-ETX203PLA-1"
    return 0
  }
  if {[string match *user* $buffer]} {
    Send $gaSet(comDut) su\r stam 0.25
    set ret [Send $gaSet(comDut) 1234\r "ETX-2"]
    if {[string match *220* $buffer]} {
      set ret 0
      set gaSet(prompt) "ETX-220"
    }
    if {[string match *203* $buffer]} {
      set ret 0
      set gaSet(prompt) "ETX-203"
    }
    if {[string match *ztp* $buffer]} {
      set ret 0
      set gaSet(prompt) "ztp"
    }
    if {[string match *ZTP* $buffer]} {
      set ret 0
      set gaSet(prompt) "ZTP"
    }
    if {[string match *CUST-LAB* $buffer]} {
      set ret 0
      set gaSet(prompt) "CUST-LAB-ETX203PLA-1"
    }
    if {[string match *BOOTSTRAP_ETX203AX* $buffer]} {
      set ret 0
      set gaSet(prompt) "BOOTSTRAP_ETX203AX"
    }
    
    $gaSet(runTime) configure -text ""
    return $ret
  }
  if {$ret!=0} {
#     set ret [Wait "Wait for ETX up" 20 white]
#     if {$ret!=0} {return $ret}  
  }
  for {set i 1} {$i <= 64} {incr i} { 
    if {$gaSet(act)==0} {return -2}
    Status "Login into ETX"
    puts "Login into ETX i:$i"; update
    $gaSet(runTime) configure -text $i
    Send $gaSet(comDut) \r stam 5
  
    append gaSet(loginBuffer) "$buffer"
    puts "<$gaSet(loginBuffer)>\n" ; update
    foreach ber $gaSet(bootErrorsL) {
      if [string match "*$ber*" $gaSet(loginBuffer)] {
       set gaSet(fail) "\'$ber\' occured during ETX's up"  
        return -1
      } else {
        puts "[MyTime] \'$ber\' was not found"
      } 
    }
  
    #set ret [MyWaitFor $gaSet(comDut) {ETX-220A user> } 5 60]
    if {([string match {*220*} $buffer]==1) || ([string match {*203*} $buffer]==1) || ([string match {*user>*} $buffer]==1)} {
      puts "if1 <$buffer>"
      if {[string match ETX-2I-100G*.tcl $gaSet(DutInitName)]==1} {
        if {[string match {*user>*} $buffer]==1} {
          set ret 0
          break
        }
      } else {      
        if {[string match *220* $buffer]} {
          set gaSet(prompt) "ETX-220"
        }
        if {[string match *203* $buffer]} {
          set gaSet(prompt) "ETX-203"
        }
        if {[string match *ztp* $buffer]} {
          set gaSet(prompt) "ztp"
        }
        if {[string match *ZTP* $buffer]} {
          set gaSet(prompt) "ZTP"
        }
        if {[string match *ETX-2I* $buffer]} {
          set gaSet(prompt) "ETX-2I"
        }
        if {[string match *CUST-LAB* $buffer]} {
          set gaSet(prompt) "CUST-LAB-ETX203PLA-1"
        }
        set ret 0
        break
      }
    }
    ## exit from boot menu 
    if {[string match *boot* $buffer]} {
      Send $gaSet(comDut) run\r stam 1
    }   
  }
    
    
  if {$ret==0} {
    if {[string match *user* $buffer]} {
      Send $gaSet(comDut) su\r stam 1
      set ret [Send $gaSet(comDut) 1234\r "ETX-2"]
      if {[string match *220* $buffer]} {
        set gaSet(prompt) "ETX-220"
      }
      if {[string match *203* $buffer]} {
        set gaSet(prompt) "ETX-203"
      }
      if {[string match *ztp* $buffer]} {
        set gaSet(prompt) "ztp"
      }
      if {[string match *ZTP* $buffer]} {
        set gaSet(prompt) "ZTP"
      }
      if {[string match *CUST-LAB* $buffer]} {
        set gaSet(prompt) "CUST-LAB-ETX203PLA-1"
      }
    }
  }  
  if {$ret!=0} {
    set gaSet(fail) "Login to ETX Fail"
  }
  $gaSet(runTime) configure -text ""
  if {$gaSet(act)==0} {return -2}
  Status $statusTxt
  return $ret
}
# ***************************************************************************
# FormatFlash
# ***************************************************************************
proc neFormatFlash {} {
  global gaSet buffer
  set com $gaSet(comDut)
  
  Power all on 
  
  return $ret
}

# ***************************************************************************
# DdrTest
# ***************************************************************************
proc DdrTest {} {
  global gaSet buffer
  Status "DDR Test"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  
  if {![info exists ::readLeSw2]} {
    set ::readLeSw2 1
  }
  if {$::readLeSw2=="1"} {
    ## if the  ::leSw2 is not defined early -> read it
    Send $com "exit all\r" stam 0.5
    set ret [Send $com "le\r" $gaSet(prompt)]
    if {$ret!=0} {return $ret}
    set res [regexp {sw\s+\"([\d\.\(\)]+)\"\s} $buffer ma leSw]
    if {$res==0} {
      set gaSet(fail) "Read SW fail"
    }
    puts "DdrTest ma:<$ma> leSw:<$leSw>"
    set leSw1 [lindex [split $leSw \(] 0]
    foreach {x y z} [split $leSw1 .] {}
    set leSw2 ${x}${y}${z}
    set ::leSw2 $leSw2
    puts "DdrTest leSw1:<$leSw1> leSw2:<$leSw2>"
  }
  
  Send $com "exit all\r" stam 0.25 
  Send $com "logon\r" stam 0.25 
  Status "Read MEA LOG"
  if {[string match {*command not recognized*} $buffer]==0} {
    set ret [Send $com "logon debug\r" password]
    if {$ret!=0} {return $ret}
    regexp {Key code:\s+(\d+)\s} $buffer - kc
    catch {exec $::RadAppsPath/atedecryptor.exe $kc pass} password
    set ret [Send $com "$password\r" $gaSet(prompt) 1]
    if {$ret!=0} {return $ret}
  }      
  
  set gaSet(fail) "Read MEA LOG fail"
  set ret [Send $com "debug mea\r" FPGA 11]
  if {$ret!=0} {return $ret}
  set ret [Send $com "mea debug log show\r" FPGA>> 30]
  if {$ret!=0} {return $ret}
  
#   if {[string match {*ENTU_ERROR*} $buffer]} {
#     set gaSet(fail) "\'ENTU_ERROR\' exists in the MEA log"
#     return -1
#   }
  if {$::leSw2=="570" || $::leSw2>="591"} {
    set ::calSucc "NA"
    set ::readWrite "NA"
    set res [regexp {EVENT -----cal_success (\d+)  Download Fpga} $buffer ma ::calSucc]
    if {$res==0} {
      set gaSet(fail) "Read \'cal_success\' fail"
      return -1
    } 
    set res [regexp {EVENT -----Read write  (\d+)  Reinit Fpga} $buffer ma ::readWrite]
    if {$res==0} {
      set gaSet(fail) "Read \'Read write\' fail"
      return -1
    } 
  } 

  if {[string match {*ENTU_ERROR Init DDR FAile................NOT OK*} $buffer]} {
    set gaSet(fail) "\'ENTU_ERROR Init DDR FAile................NOT OK\' exists in the MEA log"
    return -1
  }
  if {[string match {*ENTU_ERROR Write*} $buffer]} {
    set gaSet(fail) "\'ENTU_ERROR Write\' exists in the MEA log"
    return -1
  }
  if {[string match {*init DDR ..........................OK*} $buffer]==0} {
    set gaSet(fail) "\'init DDR ..OK\' doesn't exist in the MEA log"
    return -1
  }
  
  set gaSet(fail) "Exit from FPGA fail"
  set ret [Send $com "exit\r\r" $gaSet(prompt) 16]
  if {$ret!=0} {
    set ret [Send $com "\r\r" $gaSet(prompt)]
    if {$ret!=0} {return $ret}
  }
  return $ret
}  
# ***************************************************************************
# ReadIdBarcodeFromPage3
# ***************************************************************************
proc ReadIdBarcodeFromPage3 {} {
  global gaSet buffer
  set gaSet(BarcodeFromPage3) ""
  PowerOffOn
  
  set startSec [clock seconds]
  while 1 {
    set nowSec [clock seconds]
    set upSec [expr {$nowSec - $startSec}]
    if {$upSec>120} {
      set gaSet(fail) "Login to Boot fail"
      set ret -1
      break
    }
  
    Send $gaSet(comDut) "\r" stam 0.25
    if {[string match *boot* $buffer]} {
      set ret 0
      break
    }
    after 500 
  }
  
  if {$ret==0} {
    set ret [Send $gaSet(comDut) "d2 00\r" boot]
    if {$ret!=0} {
      set gaSet(fail) "Read Page fail"
    }
  }
  
  if {$ret==0} {
    set page3 ""
    set res [regexp {Page 3:\s+ ([\w\.]+)} $buffer ma page3] 
    if {$res==0} {
      set ret -1
      set gaSet(fail) "Read Page 03 fail"
    } 
    
    set b1 [lrange [split $page3 .] 2 12]
    set b2 ""
    foreach hex $b1 {
      append b2 [format %c [scan $hex %x]]
    }
    puts "page3:<$page3>"
    puts "b1:<$b1>"
    puts "b2:<$b2>"
    set gaSet(BarcodeFromPage3) $b2
  }
  
  return $ret
}
# ***************************************************************************
# Boot_Download
# ***************************************************************************
proc Boot_Download {} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Empty unit prompt"
  Send $com "\r\r" "=>" 2
  set ret [Send $com "\r\r" "=>" 2]
  if {$ret!=0} {
    # no:
    puts "Skip Boot Download" ; update
    set ret 0
  } else {
    # yes:   
    Status "Setup in progress ..."
    
    #dec to Hex
    set x [format %.2x $::pair]
    
    # Config Setup:
    Send $com "env set ethaddr 00:20:01:02:03:$x\r" "=>"
    Send $com "env set netmask 255.255.255.0\r" "=>"
    Send $com "env set gatewayip 10.10.10.10\r" "=>"
    Send $com "env set ipaddr 10.10.10.1[set ::pair]\r" "=>"
    Send $com "env set serverip 10.10.10.10\r" "=>"
    
    # Download Comment: download command is: run download_vxboot
    # the download file name should be always: vxboot.bin
    # else it will not work !
    if [file exists c:/download/vxboot.bin] {
      file delete -force c:/download/vxboot.bin
    }
    if {[file exists $gaSet(BootCF)]!=1} {
      set gaSet(fail) "The BOOT file ($gaSet(BootCF)) doesn't exist"
      return -1
    }
    file copy -force $gaSet(BootCF) c:/download              
    #regsub -all {\.[\w]*} $gaSet(BootCF) "" boot_file
    
    
        
    # Download:   
    Send $com "run download_vxboot\r" stam 1
    set ret [Wait "Download Boot in progress ..." 10]
    if {$ret!=0} {return $ret}
    
    file delete -force c:/download/vxboot.bin
    
    
    Send $com "\r\r" "=>" 1
    Send $com "\r\r" "=>" 3
    
    set ret [regexp {Error} $buffer]
    if {$ret==1} {
      set gaSet(fail) "Boot download fail" 
      return -1
    }  
    
    Status "Reset the unit ..."
    Send $com "reset\r" "stam" 1
    set ret [Wait "Wait for Reboot ..." 40]
    if {$ret!=0} {return $ret}
    
  }      
  return $ret
}

# ***************************************************************************
# FormatFlashAfterBootDnl
# ***************************************************************************
proc FormatFlashAfterBootDnl {} {
  global gaSet buffer
  set com $gaSet(comDut)
  #set formatFlash yes
  Status "Format Flash after Boot Download"
  Send $com "\r\r" "Are you sure(y/n)?" 2
  set ret [Send $com "\r\r" "Are you sure(y/n)?" 2]
  if {$ret!=0} {
    Wait "Wait for 5 sec" 5
    set ret [Send $com "\r\r" "Are you sure(y/n)?" 2]
    if {$ret!=0} {
      puts "Skip Flash format" ; update
      set ret 0
      set formatFlash now
    } else {
      set formatFlash yes
    }
  } else {
    set formatFlash yes    
  }
  if {$formatFlash=="yes"} {
    Send $com "y\r" "\[boot\]:"
    puts "Format in progress ..." ; update
    set ret [MyWaitFor $com "boot]:" 5 680]
  }
  return $ret
}

# ***************************************************************************
# SetSWDownload
# ***************************************************************************
proc SetSWDownload {} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Set SW Download"
  
  set ret [EntryBootMenu]
  if {$ret!=0} {return $ret}
  
  set ret [DeleteBootFiles]
  if {$ret!=0} {return $ret}
  
  if {[file exists $gaSet(SWCF)]!=1} {
    set gaSet(fail) "The SW file ($gaSet(SWCF)) doesn't exist"
    return -1
  }
     
  ## C:/download/SW/6.0.1_0.32/etxa_6.0.1(0.32)_sw-pack_2iB_10x1G_sr.bin -->> \
  ## etxa_6.0.1(0.32)_sw-pack_2iB_10x1G_sr.bin
  set tail [file tail $gaSet(SWCF)]
  set rootTail [file rootname $tail]
  if [file exists c:/download/$tail] {
    catch {file delete -force c:/download/$gaSet(pair)_$tail}
    after 1000
  }
    
  file copy -force $gaSet(SWCF) c:/download/$gaSet(pair)_$tail 
  
  #gaInfo(TftpIp.$::ID) = 10.10.8.1 (device IP)
  #gaInfo(PcIp) = "10.10.10.254" (gateway IP/server IP)
  #gaInfo(mask) = "255.255.248.0"  (device mask)  
  #gaSet(Apl) = C:/Apl/4.01.10sw-pack_203n.bin

  
  # Config Setup:
  Send $com "\r\r" "\[boot\]:"
  set ret [Send $com "\r\r" "\[boot\]:"]  
  if {$ret!=0} {
    set gaSet(fail) "Boot Setup fail"
    return -1
  }
#   Send $com "c\r" "file name" 
#   Send $com "$gaSet(pair)_$tail\r" "device IP"
  Send $com "c\r" "device IP"
  if [string match {*file name*} $buffer] {
    Send $com "$gaSet(pair)_$tail\r" "device IP"
  }
  
  Send $com "10.10.10.1[set gaSet(pair)]\r" "device mask"
  Send $com "255.255.255.0\r" "server IP"
  Send $com "10.10.10.10\r" "gateway IP"
  Send $com "10.10.10.10\r" "user"
  Send $com "vxworks\r" "(pw)" ;# vxworks

  # device name: 8313
  set ret [Send $com "\r" "quick autoboot"]  
  if {$ret!=0} {  
    Send $com "\r" "quick autoboot"
  } 

  Send $com "n\r" "protocol" 
  #Send $com "tftp\12" "baud rate" ;# 9600
  Send $com "ftp\r" "baud rate" ;# 9600
  Send $com "9600\r" "\[boot\]:"
  
  # Reboot:
  Status "Reset the unit ..."
  Send $com "reset\r" "y/n"
  Send $com "y\r" "\[boot\]:" 10
                                                               
  set i 1
  set ret [Send $com "\r" "\[boot\]:" 2]  
  while {($ret!=0)&&($i<=4)} {
    incr i
    set ret [Send $com "\r" "\[boot\]:" 2]  
  }
  
  
  if {$ret!=0} {
    set gaSet(fail) "Boot Setup fail."
    return -1 
  }  
  
  return $ret  
}
# ***************************************************************************
# DeleteBootFiles
# ***************************************************************************
proc DeleteBootFiles {} {
  global  gaSet buffer
  set com $gaSet(comDut)
  
  Status "Delete Boot Files"
  Send $com "dir\r" "\[boot\]:"
  set ret0 [regexp -all {No files were found} $buffer]
  set ret1 [regexp -all {sw-pack-1} $buffer]
  set ret2 [regexp -all {sw-pack-2} $buffer]
  set ret3 [regexp -all {sw-pack-3} $buffer]
  set ret4 [regexp -all {sw-pack-4} $buffer]
  set ret5 [regexp -all {factory-default-config} $buffer]
  set ret6 [regexp -all {user-default-config} $buffer]
  set ret7 [regexp {Active SW-pack is:\s*(\d+)} $buffer var ActSw]
  set ret8 [regexp -all {startup-config} $buffer]
  
  
  if {$ret7==1} {set ActSw [string trim $ActSw]}
  
  # No files were found:
  if {$ret0!=0} {
    puts "No files were found to delete" ; update
    return 0
  }
  
  foreach SwPack "1 2 3 4" {
    # Del sw-pack-X:
    if {[set ret$SwPack]!=0} {
      if {([info exist ActSw]== 1) && ($ActSw==$SwPack)} {
        # exist:  (Active SW-pack is: 1)
        Send $com "delete sw-pack-[set SwPack]\r" ".?"
        set res [Send $com "y\r" "deleted successfully" 40]
        if {$res!=0} {
          set gaSet(fail) "sw-pack-[set SwPack] delete fail"
          return -1      
        }      
      } else {
        # not exist: ("Active SW-pack isn't: X"   or  "No active SW-pac")
        set res [Send $com "delete sw-pack-[set SwPack]\r" "deleted successfully" 40]
        if {$res!=0} {
          set gaSet(fail) "sw-pack-[set SwPack] delete fail"
          return -1      
        }       
      }
      puts "sw-pack-[set SwPack] Delete" ; update
    } else {
      puts "sw-pack-[set SwPack] not found" ; update
    }
  }

  # factory-default-config:
  if {$ret5!=0} {
    set res [Send $com "delete factory-default-config\r" "deleted successfully" 20]
    if {$res!=0} {
      set gaSet(fail) "fac-def-config delete fail"
      return -1      
    } 
    puts "factory-default-config Delete" ; update      
  } else {
    puts "factory-default-config not found" ; update
  }
  
  # user-default-config:
  if {$ret6!=0} {
    set res [Send $com "delete user-default-config\12" "deleted successfully" 20]
    if {$res!=0} {
      set gaSet(fail) "Use-def-config delete fail"
      return -1      
    } 
    puts "user-default-config Delete" ; update      
  } else {
    puts "user-default-config not found" ; update
  }
  
  # startup-config:
  if {$ret8!=0} {
    set res [Send $com "delete startup-config\12" "deleted successfully" 20]
    if {$res!=0} {
      set gaSet(fail) "Use-str-config delete fail"
      return -1      
    } 
    puts "startup-config Delete" ; update      
  } else {
    puts "startup-config not found" ; update
  }  
    
  return 0
}

# ***************************************************************************
# EntryBootMenu
# ***************************************************************************
proc EntryBootMenu {} {
  global gaSet buffer
  puts "[MyTime] EntryBootMenu"; update
  set ret [Send $gaSet(comDut) \r\r "\[boot\]:" 2]
  if {$ret==0} {return $ret}
  set ret [Send $gaSet(comDut) \r\r "\[boot\]:" 2]
  if {$ret==0} {return $ret}
#   set ret [Reset2BootMenu $uut]
#   if {$ret!=0} {return $ret}
  Power all off
  RLTime::Delay 2
  Power all on
  RLTime::Delay 2
  Status "Entry to Boot Menu"
  set gaSet(fail) "Entry to Boot Menu fail"
  set ret [Send $gaSet(comDut) \r "stop auto-boot.." 20]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) \r\r "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  return 0
}

# ***************************************************************************
# SoftwareDownloadTest
# ***************************************************************************
proc SoftwareDownloadTest {} {
  global gaSet buffer 
  set com $gaSet(comDut)
  
  set tail [file tail $gaSet(SWCF)]
  set rootTail [file rootname $tail]
  # Download:   
  Status "Wait for download .."
  set gaSet(fail) "Application download fail"
  Send $com "download 1,$gaSet(pair)_[set tail]\r" "stam" 3
  if {[string match {*Are you sure(y/n)?*} $buffer]==1} {
    Send $com "y" "stam" 2
  }
   
  set ret [MyWaitFor $com "boot" 5 840]
  if {$ret!=0} {return $ret}
  
  catch {file delete -force c:/download/$gaSet(pair)_$tail}
 
  Status "Wait for set active 1 .."
  set ret [Send $com "set-active 1\r" "SW set active 1 completed successfully" 60] 
  if {$ret!=0} {
    set gaSet(fail) "Activate SW Pack1 fail"
    return -1
  }
  
  set ret [Send $com "run\r" "Loading" 60]
  return $ret
}  
# ***************************************************************************
# DateTime_Set
# ***************************************************************************
proc DateTime_Set {} {
  global gaSet buffer
  #OpenComUut
  Status "Set DateTime"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
  }
  if {$ret==0} {
    set gaSet(fail) "Logon fail"
    set com $gaSet(comDut)
    Send $com "exit all\r" stam 0.25 
    set ret [Send $com "configure system\r" >system]
  }
  if {$ret==0} {
    set gaSet(fail) "Set DateTime fail"
    set ret [Send $com "date-and-time\r" "date-time"]
  }
  if {$ret==0} {
    set pcDate [clock format [clock seconds] -format "%Y-%m-%d"]
    set ret [Send $com "date $pcDate\r" "date-time"]
  }
  if {$ret==0} {
    set pcTime [clock format [clock seconds] -format "%H:%M"]
    set ret [Send $com "time $pcTime\r" "date-time"]
  }
  return $ret
#   CloseComUut
#   RLSound::Play information
#   if {$ret==0} {
#     Status Done yellow
#   } else {
#     Status $gaSet(fail) red
#   } 
}
# ***************************************************************************
# LoadDefConf
# ***************************************************************************
proc LoadDefConf {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Load Default Configuration fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set cf $gaSet(DefaultCF) 
  set cfTxt "DefaultConfiguration"
  set ret [DownloadConfFile $cf $cfTxt 1 $com]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "file copy running-config user-default-config\r" "yes/no" ]
  if {$ret!=0} {return $ret}
  set ret [Send $com "y\r" "successfull" 30]
  
#   13/05/2019 16:48:20  Ronen asked to remove it
#   set ret [Send $com "admin factory-default-all\r" "yes/no" ]
#   if {$ret!=0} {return $ret}
#   set ret [Send $com "y\r" "in progress" 30]
  
  return $ret
}
# ***************************************************************************
# FactDefault
# ***************************************************************************
proc FactDefault {mode} {
  global gaSet buffer 
  Status "FactDefault $mode"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  foreach {b r p d ps np up} [split $gaSet(dutFam) .] {}
  set com $gaSet(comDut)
  
  
  set gaSet(fail) "Set to Default fail"
  Send $com "exit all\r" stam 0.25 
  Status "Factory Default..."
  if {$mode=="std"} {
    set ret [Send $com "admin factory-default\r" "yes/no" ]
  } elseif {$mode=="stda"} {
    set ret [Send $com "admin factory-default-all\r" "yes/no" ]
  }
  if {$ret!=0} {return $ret}
  set ret [Send $com "y\r" "seconds" 20]
  if {$ret!=0} {return $ret}
  
#   set ret [ReadBootVersion]
#   if {$ret!=0} {return $ret}
  
  set ret [Wait "Wait DUT down" 20 white]
  return $ret
}
# ***************************************************************************
# SwIdPerf
# ***************************************************************************
proc SwIdPerf {} {
  global gaSet buffer
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  
  set com $gaSet(comDut)
  set ret [Send $com "le\r" "stam" 1]
  set res [regexp {sw[\s\"]+([\d\.\(\)\w]+)\"}  $buffer ma val]
  if {$res==0} {
    set gaSet(fail) "Can't read SW"
    return -1
  }
  
#   18/05/2021 10:19:01
#   if {[string match ETX-2I-10G_TWC.AC.4SFPP.4SFP4UTP.tcl $gaSet(DutInitName)]==1} {
#     set sw 6.4.0(0.60)
#   } 
  if {[string match ETX-203AX_TWC.N.GE30.2SFP.2UTP2SFP.tcl $gaSet(DutInitName)]==1} {
    set sw 6.4.0(0.60)
  } elseif {[string match ETX-203AX.GE.2SFP.4UTP.tcl $gaSet(DutInitName)]==1} {
    set sw 6.7.1(0.25)G2
  } else {
    set sw $gaSet(dbrSW)
  }
  
  puts "val:<$val> sw:<$sw>"
  if {$sw!=$val} {
    set gaSet(fail) "The SW is \"$val\" instead of \"$sw\"" 
    return -1 
  }
  return 0
}
# ***************************************************************************
# LoadConf
# ***************************************************************************
proc LoadConf {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Load Configuration fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set cf $gaSet(ConfCF) 
  set cfTxt "Configuration"
  set ret [DownloadConfFile $cf $cfTxt 1 $com]
  if {$ret!=0} {return $ret}
  
  return $ret
}

# ***************************************************************************
# SerNumCleiCode_Perf
# ***************************************************************************
proc SerNumCleiCode_Perf {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Load Configuration fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "le\r" $gaSet(prompt)]  
  regexp {sw\s+\"([\.\d\(\)\w]+)\"\s} $buffer - sw
  puts "sw:$sw"
  set sw_norm [join  [regsub -all {[\(\)]} $sw " "]  . ] ; # 6.8.2(0.33) -> 6.8.2.0.33
  puts "DutInitName:<$gaSet(DutInitName)> sw:<$sw> sw_norm:<$sw_norm>"; update
  
  if {[string match {*ATT*} $gaSet(DutInitName)] && [package vcompare $sw_norm 6.8.2.0.32]!="-1"} {
    ## if sw_norm >=6.8.2.0.32
    set gaSet(fail) "show device-information fail"
    set ret [Send $com "exit all\r" $gaSet(prompt)]
    if {$ret!=0} {return $ret}
    set ret [Send $com "config system\r" $gaSet(prompt)]
    if {$ret!=0} {return $ret}
    Send $com "show device-information\r\r" system
    puts "buffer:<$buffer>"; update
    set res [regexp {Manufacturer Serial Number[\s\:]+([\w\s]+)\sConnectors} $buffer ma val]
    puts "Manufacturer Serial Number res:$res ma:$ma val:$val"
    if {$res==0} {
      set gaSet(fail) "No \'Manufacturer Serial Number\' field"  
      return -1
    }
    if {$val=="Unavailable" || $val=="Error" || $val=="Not Available"} {
      set gaSet(fail) "The \'Manufacturer Serial Number\' is \'$val\'"  
      return -1
    }
    set man_sn_len [string length $val]
    if {$man_sn_len!=16} {
      set gaSet(fail) "The length of the \'Serial Number\' is $man_sn_len. Should be 16"  
      return -1
    }
    if {[string is digit $val]==0} {
      set gaSet(fail) "The \'Serial Number\' ($val) is wrong. Should be only digits"  
      return -1
    }
    AddToPairLog $gaSet(pair) "Manufacturer Serial Number: $val"
    set gaSet(serNum) $val
    #if {$p1>=6 && $p2>=8 && $p3>=2 && $s1>=0 && $s2>=33} {}
    if {[package vcompare $sw_norm 6.8.2.0.33]!="-1"} {
      ## if sw_norm >=6.8.2.0.33
      set res [regexp {CLEI Code[\s\:]+([\w]+)\s} $buffer ma val]
      puts "CLEI Code res:$res ma:$ma val:$val"
      if {$res==0} {
        set gaSet(fail) "No \'CLEI Code\' field"  
        return -1
      }
      if {$val=="Unavailable" || $val=="Error"} {
        set gaSet(fail) "The \'CLEI Code\' is \'$val\'"  
        return -1
      }
      set clei_len [string length $val]
      if {$clei_len!=10} {
        set gaSet(fail) "The length of the \'CLEI Code\' is $clei_len. Should be 10"  
        return -1
      }
      AddToPairLog $gaSet(pair) "CLEI Code: $val"
    } else {
      puts "No ATT or sw < 6.8.2(0.33)"
      AddToPairLog $gaSet(pair) "No CLEI since SW: $sw - No ATT or sw < 6.8.2(0.33)"
    }
  } else {
    puts "No ATT or sw < 6.8.2(0.32)"
    AddToPairLog $gaSet(pair) "No SerNum since SW: $sw - No ATT or sw < 6.8.2(0.32)"
  }
  return $ret
}
# ***************************************************************************
# ReadMac
# ***************************************************************************
proc ReadMac {} {
  global gaSet
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Load Configuration fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "config system\r" system]  
  if {$ret!=0} {return $ret}
  set ret [Send $com "show device-information\r" system]  
  if {$ret!=0} {return $ret}
  set res [regexp {MAC Address[\s\:]+([0-9A-F\-]+)\s} $buffer ma val]
  if {$res==0} {
    set gaSet(fail) "Read MAC fail"
    return -1
  }
  set gaSet(1.mac1) [join [split $val "-"] ""]
  puts "ReadMac val:<$val> gaSet(1.mac1):<$gaSet(1.mac1)>"   
  return 0
}