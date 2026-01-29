simSetSimulator "-vcssv" -exec "./build/simv" -args
debImport "-dbdir" "./build/simv.daidir"
debLoadSimResult /home/aedu18/SUN/0127_registerfile/build/wave.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "1" "31" "1278" "1360"
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
srcTBRunSim
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcSetScope "tb_registerfile.r_if" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_registerfile.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcSetScope "tb_registerfile.r_if" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcHBSelect "tb_registerfile.dut" -win $_nTrace1
srcSetScope "tb_registerfile.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.dut" -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcSetScope "tb_registerfile.r_if" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcHBSelect "tb_registerfile.unnamed\$\$_0" -win $_nTrace1
srcSetScope "tb_registerfile.unnamed\$\$_0" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.unnamed\$\$_0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcSetScope "tb_registerfile.r_if" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_registerfile.unnamed\$\$_0" -win $_nTrace1
srcSetScope "tb_registerfile.unnamed\$\$_0" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcSetScope "tb_registerfile.r_if" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 42 2 4 -win $_nTrace1 -name "driver" -ctrlKey off
srcTBSimReset
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_registerfile.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcSetScope "tb_registerfile.r_if" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.r_if" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {52 52 1 10 1 1}
srcTBAddBrkPnt -line 52 -file \
           /home/aedu18/SUN/0127_registerfile/tb_registerfile/tb_registerfile.sv
srcTBRunSim
srcHBSelect "tb_registerfile.drv" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_registerfile.drv" -scope
srcHBDrag -win $_nTrace1
srcHBSelect "tb_registerfile.drv" -win $_nTrace1
srcSetScope "tb_registerfile.drv" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.drv" -win $_nTrace1
srcHBSelect "tb_registerfile.drv" -win $_nTrace1
srcSetScope "tb_registerfile.drv" -delim "." -win $_nTrace1
srcHBSelect "tb_registerfile.drv" -win $_nTrace1
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_registerfile.drv" -scope
srcTBStepNext
srcTBStepNext
srcHBSelect "tb_registerfile.drv" -win $_nTrace1
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_registerfile.drv" -scope
srcTBDVExpand -win $_nTrace1 -tab 1 -item {1} -level 1
verdiSetActWin -dock widgetDock_<Watch>
srcTBRunSim
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
