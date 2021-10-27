# -------------timming constraint for GBE ---------------------------------------------------s
# 200MHZ system clk
create_clock -period 5.000 -name system_clock [get_ports sysclk_p]
#create_clock -period 5.000 -name system_clock [get_ports exclk_p]
# 125MHz GBE clk
#create_clock -period 8.000 -name sgmii_clock [get_ports sgmiiclk_q0_p]
# set different clock domaintwominus_clocks
#set_clock_groups -name async_sysclk_sgmii -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks sgmii_clock]
#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_ports rgmii_rxc]] -group [get_clocks -include_generated_clocks sgmii_clock]
# GBE delay setting
#set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_idelayctrl_common_i}]
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

create_clock -period 5.714 -name adc_a_DCO_p [get_ports adc_DCO_p]
create_clock -period 40.000 -name adc_a_FCO_p [get_ports adc_FCO_p]
# set different clock domain
#set_clock_groups -name async_adclk_sysclk -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks ddr_fifo_wr_clk]
#set_clock_groups -name async_adclkp_sysclk -asynchronous #	-group [get_clocks -include_generated_clocks system_clock] #		-group [get_clocks -include_generated_clocks adc_FCO_p]
#set_false_path -from [get_pins adc_9252_inst/adc_diff2single_inst/DCO_inst/I] -to [get_pins adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/CLK]
#set_false_path -hold -from [get_ports adc_DCO_p] -through [get_cells adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco] -through [get_cells adc_9252_inst/ad9252_dco_sync/BUFIO_dco] -to [get_cells adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco]
#set_min_delay -from [get_pins adc_9252_inst/adc_diff2single_inst/DCO_inst/O] -to [get_pins adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 7.63
#set_multicycle_path -setup -end -from [get_ports adc_DCO_p] -to [get_pins adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 3
#set_multicycle_path -hold -end -from [get_ports adc_DCO_p[0]] -to [get_pins ad_data_module/adc_amount.genblk1[0].adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 2
#set_multicycle_path -hold -end -from [get_ports adc_DCO_p[1]] -to [get_pins ad_data_module/adc_amount.genblk1[1].adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 2
#set_multicycle_path -hold -end -from [get_ports adc_FCO_p[0]] -to [get_pins ad_data_module/adc_amount.genblk1[0].adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master/DDLY] 1
#set_multicycle_path -hold -end -from [get_ports adc_FCO_p[1]] -to [get_pins ad_data_module/adc_amount.genblk1[1].adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master/DDLY] 1

set_multicycle_path -hold -end -from [get_ports adc_FCO_p] -to [get_pins ad_data_module/adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master/DDLY] 1
set_multicycle_path -hold -end -from [get_ports adc_DCO_p] -to [get_pins ad_data_module/adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco/D] 2
set_property IODELAY_GROUP AD_DEALY [get_cells {ad_data_module/adc_9252_inst/genblk1.genblk1[*].ad9252_data_inst/IDELAYE2_data}]
set_property IODELAY_GROUP AD_DEALY [get_cells ad_data_module/adc_9252_inst/ad9252_dco_sync/IDELAYE2_dco]
set_property IODELAY_GROUP AD_DEALY [get_cells ad_data_module/adc_9252_inst/ad9252_fco_sync/IDELAYE2_fco]


# IPbus clock
create_generated_clock -name ipbus_clk -source [get_pins ipbus_infra/clocks/mmcm/CLKIN1] [get_pins ipbus_infra/clocks/mmcm/CLKOUT3]

# Other derived clocks
create_generated_clock -name clk_aux -source [get_pins ipbus_infra/clocks/mmcm/CLKIN1] [get_pins ipbus_infra/clocks/mmcm/CLKOUT4]

# AD9512 Clock
#create_generated_clock -name ad9512_sclk -source [get_pins twominus_clocks/mmcm/CLKOUT3] [get_pins ad9512_refresh/spi_master_i/ad9512_sclk_OBUF]

## Twominus clocks
create_generated_clock -name clk_50m -source [get_pins twominus_clocks/mmcm/CLKIN1] [get_pins twominus_clocks/mmcm/CLKOUT0]
create_generated_clock -name clk_100m -source [get_pins twominus_clocks/mmcm/CLKIN1] [get_pins twominus_clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_10m -source [get_pins twominus_clocks/mmcm/CLKIN1] [get_pins twominus_clocks/mmcm/CLKOUT2]
create_generated_clock -name clk_200m -source [get_pins twominus_clocks/mmcm/CLKIN1] [get_pins twominus_clocks/mmcm/CLKOUT3]


set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_aux]]
set_clock_groups -asynchronous -group [get_clocks adc_a_DCO_p] -group [get_clocks -include_generated_clocks [get_clocks clk_100m]]
set_clock_groups -asynchronous -group [get_clocks adc_a_FCO_p] -group [get_clocks -include_generated_clocks [get_clocks clk_100m]]
#set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks ad9512_sclk]]
set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_50m]]
set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_100m]]
set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_10m]]
set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_200m]]


set_clock_groups -asynchronous -group [get_clocks clk_50m] -group [get_clocks -include_generated_clocks [get_clocks clk_100m]]
set_clock_groups -asynchronous -group [get_clocks clk_50m] -group [get_clocks -include_generated_clocks [get_clocks clk_10m]]
set_clock_groups -asynchronous -group [get_clocks clk_50m] -group [get_clocks -include_generated_clocks [get_clocks clk_200m]]


