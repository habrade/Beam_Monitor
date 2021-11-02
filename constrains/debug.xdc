


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
connect_debug_port u_ila_0/clk [get_nets [list ipbus_infra/clocks/bufgipb_0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[0]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[1]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[2]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[3]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[4]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[5]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[6]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[7]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[8]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[9]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[10]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[11]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[12]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[13]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[14]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[15]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[16]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[17]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[18]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[19]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[20]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[21]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[22]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[23]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[24]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[25]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[26]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[27]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[28]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[29]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[30]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_port[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 15 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[0]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[1]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[2]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[3]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[4]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[5]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[6]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[7]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[8]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[9]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[10]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[11]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[12]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[13]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_count[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[0]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[1]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[2]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[3]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[4]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[5]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[6]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[7]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[8]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[9]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[10]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[11]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[12]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[13]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[14]} {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_data_count[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/empty}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/ipb_rd_ack}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_addr_match}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/rd_en}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {ipbus_payload/slave3/ipbus_slave_reg_fifo/rfifo.rfifo_gen[0].rfifo_i/valid_rdata_en}]]
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
