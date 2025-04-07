wm iconify . ; update

set ::RadAppsPath c:/RadApps
package require registry
set gaSet(hostDescription) [registry get "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" srvcomment ]
set jav [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment" CurrentVersion]
set gaSet(javaLocation) [file normalize [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment\\$jav" JavaHome]/bin]


if 1 {
  set gaSet(radNet) 0
  foreach {jj ip} [regexp -all -inline {v4 Address[\.\s\:]+([\d\.]+)} [exec ipconfig]] {
    if {[string match {*192.115.243.*} $ip] || [string match {*172.18.9*} $ip]} {
      set gaSet(radNet) 1
    }  
  }
  if {$gaSet(radNet)} {
    set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/autosyncapp/rlautosync.tcl]
    set mTimeRL  [file mtime c:/tcl/lib/rl/rlautosync.tcl]
    puts "mTimeTds:$mTimeTds mTimeRL:$mTimeRL"
    if {$mTimeTds>$mTimeRL} {
      puts "$mTimeTds>$mTimeRL"
      file copy -force //prod-svm1/tds/install/ateinstall/jate_team/autosyncapp/rlautosync.tcl c:/tcl/lib/rl
      after 2000
    }
    set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/autoupdate/rlautoupdate.tcl]
    set mTimeRL  [file mtime c:/tcl/lib/rl/rlautoupdate.tcl]
    puts "mTimeTds:$mTimeTds mTimeRL:$mTimeRL"
    if {$mTimeTds>$mTimeRL} {
      puts "$mTimeTds>$mTimeRL"
      file copy -force //prod-svm1/tds/install/ateinstall/jate_team/autoupdate/rlautoupdate.tcl c:/tcl/lib/rl
      after 2000
    }
    if 1 {
      set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/LibUrl_WS/LibUrl.tcl]
      set mTimePwd  [file mtime [pwd]/LibUrl.tcl]
      puts "mTimeTds:$mTimeTds mTimePwd:$mTimePwd"
      if {$mTimeTds>$mTimePwd} {
        puts "$mTimeTds>$mTimePwd"
        file copy -force //prod-svm1/tds/install/ateinstall/jate_team/LibUrl_WS/LibUrl.tcl ./
        after 2000
      }
    }
    update
  }
  
  package require RLAutoUpdate
  set s1 //prod-svm1/tds/AT-Testers/JER_AT/ilya/Tools/AT-ETX220_Download/software/
  set d1 [pwd]
  #set s2 //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/ETX-2i-64ET1/download
  #set d2 c://download
  set noCopyL [list  [pwd]/tmpFiles]
  set noCopyGlobL [list init* result*]
  set emailL [list ilya_g@rad.com]


  # set ret [RLAutoUpdate::AutoUpdate [list $s1 $d1 $s2 $d2] -noCopyL $noCopyL -noCopyGlobL $noCopyGlobL -emailL $emailL]
  set ret [RLAutoUpdate::AutoUpdate [list $s1 $d1] -noCopyGlobL $noCopyGlobL -noCopyL $noCopyL]  ; # [-emailL $emailL]
  if {$ret=="-1"} {exit}
  
  if {$gaSet(radNet)} {
    set gMessage ""
    set s2 [file normalize W:/winprog/ATE]
    set d2 [file normalize $::RadAppsPath]
    set ret [RLAutoUpdate::AutoUpdate "$s2 $d2" \
        -noCopyGlobL {Get_Li* Macreg.2* Macreg-i* DP* *.prd}]
    #console show
    puts "ret:<$ret>"
    set gsm $gMessage
    foreach gmess $gMessage {
      puts "$gmess"
    }
    update
    if {$ret=="-1"} {
      set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
      -message "The AutoSync process did not perform successfully.\n\n\
      Do you want to continue? "]
      if {$res=="no"} {
        #SQliteClose
        exit
      }
    }
  }
}

package require BWidget
package require img::ico
package require RLSerial
package require RLEH
package require RLTime
package require RLStatus
#package require RLEtxGen
package require RLExPio
package require RLSound
#package require RLScotty ; #RLTcp
package require ezsmtp
package require http
package require sqlite3


source Gui_E220Dnl.tcl
source Main_E220Dnl.tcl
source Lib_Put_E220Dnl.tcl
source Lib_Gen_E220Dnl.tcl
source Lib_Ds280e01_Etx2iB.tcl
source [info host]/init$gaSet(pair).tcl
source lib_bc.tcl
source Lib_DialogBox.tcl
source Lib_FindConsole.tcl
source LibEmail.tcl
source LibIPRelay.tcl
source lib_SQlite.tcl
source LibUrl.tcl
# source Lib_Etx204.tcl
#source lib_chkDdr.tcl

source uutInits/$gaSet(DutInitName)

if ![info exists gaSet(pioType)] {
  set gaSet(pioType) Ex
}
if {$gaSet(pioType)=="Usb"} {
  package require RLUsbPio
}

set gaSet(act) 1
set gaSet(initUut) 1
set gaSet(oneTest)    0
set gaSet(puts) 1
set gaSet(noSet) 0

set gaSet(toTestClr)    #aad5ff
set gaSet(toNotTestClr) SystemButtonFace
set gaSet(halfPassClr)  #ccffcc

set gaSet(useExistBarcode) 0
set gaSet(relDebMode) Release
#set gaSet(1.barcode1) CE100025622

if ![file exists c:/logs]  {
  file mkdir c:/logs
}
if ![file exists c:/logs/ddr]  {
  file mkdir c:/logs/ddr
}
if {![info exists gaSet(readTrace)] || $gaSet(readTrace)==""} {
  set gaSet(readTrace) 1
}


GUI
update idletask

#wm iconify .
BuildTests
update


wm deiconify .
wm geometry . $gaGui(xy)
update

Status "Ready"