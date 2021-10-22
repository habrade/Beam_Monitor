# -------------timming constraint for GBE ---------------------------------------------------
# 200MHZ system clk
create_clock -period 5.000 -name system_clock [get_ports sys_clk_p]
create_clock -period 5.000 -name system_clock [get_ports exclk_p]
# 125MHz GBE clk
#create_clock -period 8.000 -name sgmii_clock [get_ports sgmiiclk_q0_p]
# set different clock domain
#set_clock_groups -name async_sysclk_sgmii -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks sgmii_clock]
#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_ports rgmii_rxc]] -group [get_clocks -include_generated_clocks sgmii_clock]
# GBE delay setting
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_idelayctrl_common_i}]
#set_property IDELAY_VALUE 30 [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_i/*/rgmii_interface/delay_rgmii_rx*}]
#set_property IDELAY_VALUE 30 [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_i/*/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]
# If TEMAC timing fails, use the following to relax the requirements
# The RGMII receive interface requirement allows a 1ns setup and 1ns hold - this is met but only just so constraints are relaxed
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -max -1.5 [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -min -2.8 [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -clock_fall -max -1.5 -add_delay [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -clock_fall -min -2.8 -add_delay [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]

# ------------- timing constraint for reset ------------------------
#set_false_path -from [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *GLOBAL_RST_reg*}] -filter {NAME =~ *C}]

# -------------timming for topmetal and ad9252
# 350MHz
#create_clock -period 5.7143 -name adc_a_DCO_p [get_ports {adc_DCO_p[0]}]
#create_clock -period 5.7143 -name adc_b_DCO_p [get_ports {adc_DCO_p[1]}]
# 50MHz
#create_clock -period 40.000 -name adc_a_FCO_p [get_ports {adc_FCO_p[0]}]
#create_clock -period 40.000 -name adc_b_FCO_p [get_ports {adc_FCO_p[1]}]

create_clock -period 5.7143 -name adc_a_DCO_p [get_ports {adc_DCO_p}]
create_clock -period 40.000 -name adc_a_FCO_p [get_ports {adc_FCO_p}]
# set different clock domain
#set_clock_groups -name async_adclk_sysclk -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks ddr_fifo_wr_clk]
#set_clock_groups -name async_adclkp_sysclk -asynchronous #	-group [get_clocks -include_generated_clocks system_clock] #		-group [get_clocks -include_generated_clocks adc_FCO_p]
#set_false_path -from [get_pins adc_9252_inst/adc_diff2single_inst/DCO_inst/I] -to [get_pins adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/CLK]
#set_false_path -hold -from [get_ports adc_DCO_p] -through [get_cells adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco] -through [get_cells adc_9252_inst/ad9252_dco_sync/BUFIO_dco] -to [get_cells adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco]
#set_min_delay -from [get_pins adc_9252_inst/adc_diff2single_inst/DCO_inst/O] -to [get_pins adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 7.63
#set_multicycle_path -setup -end -from [get_ports adc_DCO_p] -to [get_pins adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 3
#set_multicycle_path -hold -end -from [get_ports adc_DCO_p[0]] -to [get_pins ad_data_inst/adc_amount.genblk1[0].adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 2
#set_multicycle_path -hold -end -from [get_ports adc_DCO_p[1]] -to [get_pins ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 2
#set_multicycle_path -hold -end -from [get_ports adc_FCO_p[0]] -to [get_pins ad_data_inst/adc_amount.genblk1[0].adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master/DDLY] 1
#set_multicycle_path -hold -end -from [get_ports adc_FCO_p[1]] -to [get_pins ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master/DDLY] 1

set_multicycle_path -hold -end -from [get_ports adc_FCO_p] -to [get_pins ad_data_inst/adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master/DDLY] 1
set_multicycle_path -hold -end -from [get_ports adc_DCO_p] -to [get_pins ad_data_inst/adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 2
set_property IODELAY_GROUP AD_DEALY [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[*].ad9252_data_inst/IDELAYE2_data}]
set_property IODELAY_GROUP AD_DEALY [get_cells {ad_data_inst/adc_9252_inst/ad9252_dco_sync/IDELAYE2_dco}]
set_property IODELAY_GROUP AD_DEALY [get_cells {ad_data_inst/adc_9252_inst/ad9252_fco_sync/IDELAYE2_fco}]






