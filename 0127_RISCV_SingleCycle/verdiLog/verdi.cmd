simSetSimulator "-vcssv" -exec "./build/simv" -args
debImport "-dbdir" "./build/simv.daidir"
debLoadSimResult /home/aedu18/SUN/0127_RISCV_SingleCycle/build/wave.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "1358" "335" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "1281" "31" "1278" "1360"
srcTBInvokeSim
verdiSetActWin -win $_InteractiveConsole_3
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_<Member>
srcHBSelect "tb_alu" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_alu.dut" -win $_nTrace1
srcHBSelect "tb_alu.a_if" -win $_nTrace1
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_alu.a_if" -scope
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_alu.a_if" -win $_nTrace1
srcSetScope "tb_alu.a_if" -delim "." -win $_nTrace1
srcHBSelect "tb_alu.a_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {41 41 1 5 1 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 2 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 97 1 3 -win $_nTrace1 -name "initial" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 3 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 99 1 0 -win $_nTrace1 -name "for" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 97 3 1 -win $_nTrace1 -name "begin" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 97 1 4 -win $_nTrace1 -name "initial" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 3 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 2 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 84 1 0 -win $_nTrace1 -name "driver" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 84 1 2 -win $_nTrace1 -name "driver" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 84 3 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 37 2 1 -win $_nTrace1 -name "driver" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 37 2 1 -win $_nTrace1 -name "driver" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 37 2 1 -win $_nTrace1 -name "driver" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 37 0 1 -win $_nTrace1 -name "class" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 6 0 -win $_nTrace1 -name "\(" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 5 0 -win $_nTrace1 -name "new" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 2 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 97 1 3 -win $_nTrace1 -name "initial" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 97 1 6 -win $_nTrace1 -name "initial" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 97 1 6 -win $_nTrace1 -name "initial" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 2 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 99 1 1 -win $_nTrace1 -name "for" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 98 1 1 -win $_nTrace1 -name "John" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -all -win $_nTrace1
srcSelect -win $_nTrace1 -range {1 109 1 2 1 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "tb_alu.a_if" -win $_nTrace1
srcSetScope "tb_alu.a_if" -delim "." -win $_nTrace1
srcHBSelect "tb_alu.a_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_alu.a_if" -win $_nTrace1
srcSetScope "tb_alu.a_if" -delim "." -win $_nTrace1
srcHBSelect "tb_alu.a_if" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {49 49 1 6 1 1}
srcTBAddBrkPnt -line 49 -file \
           /home/aedu18/SUN/0127_RISCV_SingleCycle/testbench/tb_alu.sv
srcSelect -win $_nTrace1 -range {49 49 1 6 1 1}
srcTBSetBrkPnt -disable -index 1
srcSelect -win $_nTrace1 -range {49 49 1 6 1 1}
srcTBSetBrkPnt -delete -index 1
srcSelect -win $_nTrace1 -range {49 49 1 6 1 1}
srcTBAddBrkPnt -line 49 -file \
           /home/aedu18/SUN/0127_RISCV_SingleCycle/testbench/tb_alu.sv
srcTBRunSim
srcHBSelect "tb_alu.John.receive" -win $_nTrace1
srcHBSelect "tb_alu.John.send" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_alu.John.send" -scope
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_alu.John.send" -scope
srcHBSelect "tb_alu.John.receive" -win $_nTrace1
srcHBSelect "tb_alu.John.new" -win $_nTrace1
srcHBSelect "tb_alu.John.receive" -win $_nTrace1
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_alu.John.receive" -scope
srcTBDVSelect -tab 1 -range {3-3} 
srcTBDVSelect -tab 1 -range {2-3} 
srcTBDVSelect -tab 1 -range {1-3} 
srcTBDVSelect -tab 1 -range {0-3} 
verdiSetActWin -dock widgetDock_<Watch>
srcTBDeleteDataTree -win $_nTrace1 -tab 1 -tree "a\[31:0\]"
srcTBDeleteDataTree -win $_nTrace1 -tab 1 -tree "aluControl\[3:0\]"
srcTBDeleteDataTree -win $_nTrace1 -tab 1 -tree "b\[31:0\]"
srcTBDeleteDataTree -win $_nTrace1 -tab 1 -tree "result\[31:0\]"
srcHBSelect "tb_alu.John.send" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_alu.John.send" -scope
srcHBSelect "tb_alu.John" -win $_nTrace1
srcSetScope "tb_alu.John" -delim "." -win $_nTrace1
srcHBSelect "tb_alu.John" -win $_nTrace1
srcHBSelect "tb_alu.John" -win $_nTrace1
srcSetScope "tb_alu.John" -delim "." -win $_nTrace1
srcHBSelect "tb_alu.John" -win $_nTrace1
srcHBDrag -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_alu.John" -scope
srcTBDVSelect -tab 1 -range {1-1} 
verdiSetActWin -dock widgetDock_<Watch>
srcTBRunSim
srcTBDVExpand -win $_nTrace1 -tab 1 -item {2} -level 1
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
debExit
