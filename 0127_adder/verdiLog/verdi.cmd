simSetSimulator "-vcssv" -exec "./build/simv" -args
debImport "-dbdir" "./build/simv.daidir"
debLoadSimResult /home/aedu18/SUN/0127_adder/build/wave.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debExit
