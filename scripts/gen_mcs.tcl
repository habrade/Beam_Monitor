set PRJ_NAME [lindex $argv 0]
set BUILD_DIR [lindex $argv 1]
set BIT [lindex $argv 2]

write_cfgmem -force -format mcs -interface bpix16 -size 128  -loadbit "up 0x0 ${BIT}" -file ${BUILD_DIR}/${PRJ_NAME}.mcs
