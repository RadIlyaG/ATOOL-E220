To add some bizarre option of ETX-203 perform the following:
1. Add the option to file Lib_Gen_E220Dnl.tcl , proc RetriveDutFam , line ~692
## 2. Add the option to file Gui_E220Dnl.tcl , proc ButRun , line ~304
3. Add the option to file Main_E220Dnl.tcl , proc BuildTests , line ~16. Pay attention! Put the option to right If-Else accordingly to the required Tests 
4. Check if to add the option to file Lib_Put_E220Dnl.tcl , proc Login , line ~113