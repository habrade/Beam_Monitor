


connect_debug_port u_ila_0/probe0 [get_nets [list {ipbus_payload/slave2/ss_i[0]} {ipbus_payload/slave2/ss_i[1]} {ipbus_payload/slave2/ss_i[2]} {ipbus_payload/slave2/ss_i[3]} {ipbus_payload/slave2/ss_i[4]} {ipbus_payload/slave2/ss_i[5]} {ipbus_payload/slave2/ss_i[6]} {ipbus_payload/slave2/ss_i[7]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list ipbus_payload/slave2/spi/last_bit]]
connect_debug_port u_ila_0/probe7 [get_nets [list ipbus_payload/slave2/spi_busy]]






connect_debug_port u_ila_0/probe1 [get_nets [list {ipbus_payload/data_fifo_wr_din[0]} {ipbus_payload/data_fifo_wr_din[1]} {ipbus_payload/data_fifo_wr_din[2]} {ipbus_payload/data_fifo_wr_din[3]} {ipbus_payload/data_fifo_wr_din[4]} {ipbus_payload/data_fifo_wr_din[5]} {ipbus_payload/data_fifo_wr_din[6]} {ipbus_payload/data_fifo_wr_din[7]} {ipbus_payload/data_fifo_wr_din[8]} {ipbus_payload/data_fifo_wr_din[9]} {ipbus_payload/data_fifo_wr_din[10]} {ipbus_payload/data_fifo_wr_din[11]} {ipbus_payload/data_fifo_wr_din[12]} {ipbus_payload/data_fifo_wr_din[13]} {ipbus_payload/data_fifo_wr_din[14]} {ipbus_payload/data_fifo_wr_din[15]} {ipbus_payload/data_fifo_wr_din[16]} {ipbus_payload/data_fifo_wr_din[17]} {ipbus_payload/data_fifo_wr_din[18]} {ipbus_payload/data_fifo_wr_din[19]} {ipbus_payload/data_fifo_wr_din[20]} {ipbus_payload/data_fifo_wr_din[21]} {ipbus_payload/data_fifo_wr_din[22]} {ipbus_payload/data_fifo_wr_din[23]} {ipbus_payload/data_fifo_wr_din[24]} {ipbus_payload/data_fifo_wr_din[25]} {ipbus_payload/data_fifo_wr_din[26]} {ipbus_payload/data_fifo_wr_din[27]} {ipbus_payload/data_fifo_wr_din[28]} {ipbus_payload/data_fifo_wr_din[29]} {ipbus_payload/data_fifo_wr_din[30]} {ipbus_payload/data_fifo_wr_din[31]}]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list twominus_clocks/clk_10m]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 5 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ad9252_control/adc9252_control/config_9252/next_state[0]} {ad9252_control/adc9252_control/config_9252/next_state[1]} {ad9252_control/adc9252_control/config_9252/next_state[2]} {ad9252_control/adc9252_control/config_9252/next_state[3]} {ad9252_control/adc9252_control/config_9252/next_state[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 5 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {ad9252_control/adc9252_control/config_9252/current_state[0]} {ad9252_control/adc9252_control/config_9252/current_state[1]} {ad9252_control/adc9252_control/config_9252/current_state[2]} {ad9252_control/adc9252_control/config_9252/current_state[3]} {ad9252_control/adc9252_control/config_9252/current_state[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list ad9252_control/adc9252_control/config_9252/cfg_testdone]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list ad9252_control/adc9252_control/config_9252/cfg_workdone]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list twominus_clocks/clk_100m]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[0]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[1]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[2]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[3]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[4]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[5]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[6]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[7]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[8]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[9]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[10]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[11]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[12]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[13]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[14]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[15]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[16]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[17]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[18]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[19]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[20]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[21]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[22]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[23]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[24]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[25]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[26]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[27]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[28]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[29]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[30]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_din[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 1 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rfifo_wr_en}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_100m]
