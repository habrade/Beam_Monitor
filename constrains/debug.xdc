


connect_debug_port u_ila_0/probe0 [get_nets [list {ipbus_payload/slave2/ss_i[0]} {ipbus_payload/slave2/ss_i[1]} {ipbus_payload/slave2/ss_i[2]} {ipbus_payload/slave2/ss_i[3]} {ipbus_payload/slave2/ss_i[4]} {ipbus_payload/slave2/ss_i[5]} {ipbus_payload/slave2/ss_i[6]} {ipbus_payload/slave2/ss_i[7]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list ipbus_payload/slave2/spi/last_bit]]
connect_debug_port u_ila_0/probe7 [get_nets [list ipbus_payload/slave2/spi_busy]]






connect_debug_port u_ila_0/probe1 [get_nets [list {ipbus_payload/data_fifo_wr_din[0]} {ipbus_payload/data_fifo_wr_din[1]} {ipbus_payload/data_fifo_wr_din[2]} {ipbus_payload/data_fifo_wr_din[3]} {ipbus_payload/data_fifo_wr_din[4]} {ipbus_payload/data_fifo_wr_din[5]} {ipbus_payload/data_fifo_wr_din[6]} {ipbus_payload/data_fifo_wr_din[7]} {ipbus_payload/data_fifo_wr_din[8]} {ipbus_payload/data_fifo_wr_din[9]} {ipbus_payload/data_fifo_wr_din[10]} {ipbus_payload/data_fifo_wr_din[11]} {ipbus_payload/data_fifo_wr_din[12]} {ipbus_payload/data_fifo_wr_din[13]} {ipbus_payload/data_fifo_wr_din[14]} {ipbus_payload/data_fifo_wr_din[15]} {ipbus_payload/data_fifo_wr_din[16]} {ipbus_payload/data_fifo_wr_din[17]} {ipbus_payload/data_fifo_wr_din[18]} {ipbus_payload/data_fifo_wr_din[19]} {ipbus_payload/data_fifo_wr_din[20]} {ipbus_payload/data_fifo_wr_din[21]} {ipbus_payload/data_fifo_wr_din[22]} {ipbus_payload/data_fifo_wr_din[23]} {ipbus_payload/data_fifo_wr_din[24]} {ipbus_payload/data_fifo_wr_din[25]} {ipbus_payload/data_fifo_wr_din[26]} {ipbus_payload/data_fifo_wr_din[27]} {ipbus_payload/data_fifo_wr_din[28]} {ipbus_payload/data_fifo_wr_din[29]} {ipbus_payload/data_fifo_wr_din[30]} {ipbus_payload/data_fifo_wr_din[31]}]]


connect_debug_port u_ila_0/clk [get_nets [list twominus_clocks/clk_10m]]
connect_debug_port u_ila_0/probe0 [get_nets [list {ad9252_control/adc9252_control/config_9252/next_state[0]} {ad9252_control/adc9252_control/config_9252/next_state[1]} {ad9252_control/adc9252_control/config_9252/next_state[2]} {ad9252_control/adc9252_control/config_9252/next_state[3]} {ad9252_control/adc9252_control/config_9252/next_state[4]}]]
connect_debug_port u_ila_0/probe1 [get_nets [list {ad9252_control/adc9252_control/config_9252/current_state[0]} {ad9252_control/adc9252_control/config_9252/current_state[1]} {ad9252_control/adc9252_control/config_9252/current_state[2]} {ad9252_control/adc9252_control/config_9252/current_state[3]} {ad9252_control/adc9252_control/config_9252/current_state[4]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list ad9252_control/adc9252_control/config_9252/cfg_testdone]]
connect_debug_port u_ila_0/probe3 [get_nets [list ad9252_control/adc9252_control/config_9252/cfg_workdone]]

