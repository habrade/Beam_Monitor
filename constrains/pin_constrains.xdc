# Set FPGA I/O Pins

set_property PACKAGE_PIN R16 [get_ports {adc_data_p[0]}]
set_property PACKAGE_PIN T18 [get_ports {adc_data_p[1]}]
set_property PACKAGE_PIN U19 [get_ports {adc_data_p[2]}]
set_property PACKAGE_PIN T22 [get_ports {adc_data_p[3]}]
#set_property PACKAGE_PIN R18 [get_ports {adc_data_p[4]}]
#set_property PACKAGE_PIN U17 [get_ports {adc_data_p[5]}]
#set_property PACKAGE_PIN N18 [get_ports {adc_data_p[6]}]
#set_property PACKAGE_PIN P16 [get_ports {adc_data_p[7]}]


#set_property PACKAGE_PIN R21 [get_ports {adc_DCO_p[0]}]
#set_property PACKAGE_PIN R22 [get_ports {adc_FCO_p[0]}]

set_property PACKAGE_PIN R21 [get_ports adc_DCO_p]
set_property PACKAGE_PIN R22 [get_ports adc_FCO_p]

set_property PACKAGE_PIN G24 [get_ports sclk]
set_property PACKAGE_PIN J26 [get_ports mosi]
set_property PACKAGE_PIN J21 [get_ports miso]
set_property PACKAGE_PIN K23 [get_ports {ss[0]}]
set_property PACKAGE_PIN F25 [get_ports ad9512_function]

#set_property PACKAGE_PIN P24 [get_ports {ad_sclk[0]}]
#set_property PACKAGE_PIN K25 [get_ports {ad_sclk[1]}]
#set_property PACKAGE_PIN N24 [get_ports {ad_sdio[0]}]
#set_property PACKAGE_PIN K26 [get_ports {ad_sdio[1]}]
#set_property PACKAGE_PIN R26 [get_ports {ad_csb[0]}]
#set_property PACKAGE_PIN P26 [get_ports {ad_csb[1]}]

set_property PACKAGE_PIN P24 [get_ports ad9252_sclk]
set_property PACKAGE_PIN N24 [get_ports ad9252_sdio]
set_property PACKAGE_PIN R26 [get_ports ad9252_csb]

#set_property PACKAGE_PIN H26 [get_ports {da_sync[0]}]
#set_property PACKAGE_PIN H23 [get_ports {da_sync[1]}]
#set_property PACKAGE_PIN H22 [get_ports {da_sync[2]}]
#set_property PACKAGE_PIN J23 [get_ports {da_sync[3]}]
#set_property PACKAGE_PIN F23 [get_ports da_sdata]
#set_property PACKAGE_PIN D24 [get_ports da_sclk]

#set_property PACKAGE_PIN H6 [get_ports sgmiiclk_q0_p]
#set_property PACKAGE_PIN H5 [get_ports sgmiiclk_q0_n]
#set_property PACKAGE_PIN H13 [get_ports {rgmii_rxd[0]}]
#set_property PACKAGE_PIN H8 [get_ports {rgmii_rxd[1]}]
#set_property PACKAGE_PIN C9 [get_ports {rgmii_rxd[2]}]
#set_property PACKAGE_PIN G10 [get_ports {rgmii_rxd[3]}]
#set_property PACKAGE_PIN J13 [get_ports rgmii_rx_ctl]
#set_property PACKAGE_PIN E10 [get_ports rgmii_rxc]

#set_property PACKAGE_PIN D14 [get_ports {rgmii_txd[3]}]
#set_property PACKAGE_PIN D8 [get_ports {rgmii_txd[2]}]
#set_property PACKAGE_PIN D9 [get_ports {rgmii_txd[1]}]
#set_property PACKAGE_PIN H11 [get_ports {rgmii_txd[0]}]
#set_property PACKAGE_PIN G12 [get_ports rgmii_tx_ctl]
#set_property PACKAGE_PIN E11 [get_ports rgmii_txc]
set_property IOSTANDARD LVCMOS25 [get_ports {gmii* phy_rst}]
set_property PACKAGE_PIN E11 [get_ports gmii_gtx_clk]
set_property PACKAGE_PIN G12 [get_ports gmii_tx_en]
set_property PACKAGE_PIN A9 [get_ports gmii_tx_er]
set_property PACKAGE_PIN H11 [get_ports {gmii_txd[0]}]
set_property PACKAGE_PIN D9 [get_ports {gmii_txd[1]}]
set_property PACKAGE_PIN D8 [get_ports {gmii_txd[2]}]
set_property PACKAGE_PIN D14 [get_ports {gmii_txd[3]}]
set_property PACKAGE_PIN H12 [get_ports {gmii_txd[4]}]
set_property PACKAGE_PIN F8 [get_ports {gmii_txd[5]}]
set_property PACKAGE_PIN D13 [get_ports {gmii_txd[6]}]
set_property PACKAGE_PIN B9 [get_ports {gmii_txd[7]}]
set_property PACKAGE_PIN E10 [get_ports gmii_rx_clk]
set_property PACKAGE_PIN J13 [get_ports gmii_rx_dv]
set_property PACKAGE_PIN J8 [get_ports gmii_rx_er]
set_property PACKAGE_PIN H13 [get_ports {gmii_rxd[0]}]
set_property PACKAGE_PIN H8 [get_ports {gmii_rxd[1]}]
set_property PACKAGE_PIN C9 [get_ports {gmii_rxd[2]}]
set_property PACKAGE_PIN G10 [get_ports {gmii_rxd[3]}]
set_property PACKAGE_PIN A8 [get_ports {gmii_rxd[4]}]
set_property PACKAGE_PIN J11 [get_ports {gmii_rxd[5]}]
set_property PACKAGE_PIN J10 [get_ports {gmii_rxd[6]}]
set_property PACKAGE_PIN H9 [get_ports {gmii_rxd[7]}]
set_property PACKAGE_PIN F9 [get_ports phy_rst]

#set_property PACKAGE_PIN G9 [get_ports mdc]
#set_property PACKAGE_PIN G14 [get_ports mdio]
set_property PACKAGE_PIN F9 [get_ports phy_reset_n]

set_property PACKAGE_PIN M25 [get_ports ddr_init_done]
set_property PACKAGE_PIN V11 [get_ports hard_reset]
set_property PACKAGE_PIN E18 [get_ports exrst_p]


#set_property PACKAGE_PIN AB11 [get_ports sysclk_p]
#set_property PACKAGE_PIN AC11 [get_ports sysclk_n]

set_property PACKAGE_PIN D21 [get_ports tm_clk]
set_property PACKAGE_PIN C21 [get_ports tm_reset]
set_property PACKAGE_PIN A20 [get_ports tm_start]
set_property PACKAGE_PIN B20 [get_ports tm_speak]

set_property PACKAGE_PIN K22 [get_ports tm_marker]
#set_property PACKAGE_PIN L22 [get_ports {tm_markr_i[0]}]
#set_property PACKAGE_PIN K22 [get_ports {tm_markr_i[1]}]
#set_property PACKAGE_PIN J24 [get_ports {tm_markr_i[2]}]
#set_property PACKAGE_PIN J25 [get_ports {tm_markr_i[3]}]
#set_property PACKAGE_PIN H24 [get_ports {tm_markr_i[4]}]
#set_property PACKAGE_PIN G22 [get_ports {tm_markr_i[5]}]
#set_property PACKAGE_PIN F22 [get_ports {tm_markr_i[6]}]
#set_property PACKAGE_PIN E26 [get_ports {tm_markr_i[7]}]
#set_property PACKAGE_PIN E22 [get_ports {tm_markr_i[8]}]
#set_property PACKAGE_PIN D26 [get_ports {tm_markr_i[9]}]
#set_property PACKAGE_PIN C26 [get_ports {tm_markr_i[10]}]
#set_property PACKAGE_PIN C24 [get_ports {tm_markr_i[11]}]
#set_property PACKAGE_PIN C22 [get_ports {tm_markr_i[12]}]
#set_property PACKAGE_PIN A24 [get_ports {tm_markr_i[13]}]
#set_property PACKAGE_PIN A23 [get_ports {tm_markr_i[14]}]
#set_property PACKAGE_PIN E21 [get_ports {tm_markr_i[15]}]

set_property PACKAGE_PIN C19 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN B19 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN C17 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN C18 [get_ports {dip_sw[3]}]

set_property PACKAGE_PIN H16 [get_ports adc_data_aligned]
set_property PACKAGE_PIN D16 [get_ports ad_9252_done]
set_property PACKAGE_PIN G16 [get_ports dac_config_done]
set_property PACKAGE_PIN F15 [get_ports ad_9512_done]
set_property PACKAGE_PIN F19 [get_ports topmetal_working]

set_property PACKAGE_PIN G20 [get_ports {leds[0]}]
set_property PACKAGE_PIN K20 [get_ports {leds[1]}]
set_property PACKAGE_PIN J19 [get_ports {leds[2]}]


#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_rxd[3]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_rxd[2]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_rxd[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_rxd[0]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_txd[3]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_txd[2]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_txd[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_txd[0]}]
#set_property IOSTANDARD LVCMOS25 [get_ports ddr_init_done]
set_property IOSTANDARD LVCMOS25 [get_ports mdc]
set_property IOSTANDARD LVCMOS25 [get_ports mdio]

set_property IOSTANDARD LVCMOS15 [get_ports hard_reset]

#set_property IOSTANDARD LVDS_25 [get_ports exrst_p]

set_property IOSTANDARD LVCMOS25 [get_ports phy_reset_n]
#set_property IOSTANDARD LVCMOS25 [get_ports rgmii_rx_ctl]
#set_property IOSTANDARD LVCMOS25 [get_ports rgmii_rxc]
#set_property IOSTANDARD LVCMOS25 [get_ports rgmii_tx_ctl]
#set_property IOSTANDARD LVCMOS25 [get_ports rgmii_txc]
#set_property IOSTANDARD LVDS_25 [get_ports sysclk_p]
#set_property IOSTANDARD LVDS_25 [get_ports sysclk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sysclk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sysclk_n]
#set_property IOSTANDARD LVCMOS25 [get_ports {ad_csb[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {ad_csb[0]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {ad_sclk[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {ad_sclk[0]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {ad_sdio[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {ad_sdio[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports ad9252_csb]
set_property IOSTANDARD LVCMOS25 [get_ports ad9252_sclk]
set_property IOSTANDARD LVCMOS25 [get_ports ad9252_sdio]
set_property IOSTANDARD LVCMOS33 [get_ports da_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports da_sdata]
set_property IOSTANDARD LVCMOS33 [get_ports {da_sync[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {da_sync[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {da_sync[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {da_sync[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ss[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports sclk]
set_property IOSTANDARD LVCMOS33 [get_ports mosi]
set_property IOSTANDARD LVCMOS33 [get_ports miso]
set_property IOSTANDARD LVCMOS33 [get_ports ad9512_function]
set_property IOSTANDARD LVCMOS33 [get_ports tm_clk]
set_property IOSTANDARD LVCMOS33 [get_ports tm_reset]
set_property IOSTANDARD LVCMOS33 [get_ports tm_speak]
set_property IOSTANDARD LVCMOS33 [get_ports tm_start]
set_property IOSTANDARD LVCMOS33 [get_ports tm_marker]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[15]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tm_markr_i[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[15]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[14]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[13]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[12]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[11]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[10]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[9]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[8]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[7]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[6]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[5]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_p[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_DCO_p[1]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_DCO_p[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_FCO_p[1]}]
#set_property IOSTANDARD LVDS_25 [get_ports {adc_FCO_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports adc_DCO_p]
set_property IOSTANDARD LVDS_25 [get_ports adc_FCO_p]
set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports topmetal_working]
set_property IOSTANDARD LVCMOS25 [get_ports ad_9252_done]
set_property IOSTANDARD LVCMOS25 [get_ports ad_9512_done]
set_property IOSTANDARD LVCMOS25 [get_ports adc_data_aligned]
set_property IOSTANDARD LVCMOS25 [get_ports dac_config_done]
set_property IOSTANDARD LVCMOS25 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds[2]}]


set_property VCCAUX_IO DONTCARE [get_ports sysclk_p]

#############SPI Configurate Setting##################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property LOC IDELAYCTRL_X0Y0 [get_cells ad_data_inst/IDELAYCTRL_inst]


set_property LOC IDELAY_X0Y24 [get_cells {ad_data_inst/adc_9252_inst/ad9252_dco_sync/IDELAYE2_dco}]
set_property LOC R21 [get_cells {ad_data_inst/adc_9252_inst/adc_diff2single_inst/DCO_inst}]
set_property LOC ILOGIC_X0Y24 [get_cells {ad_data_inst/adc_9252_inst/ad9252_dco_sync/ISERDESE2_dco}]
set_property LOC BUFIO_X0Y1 [get_cells {ad_data_inst/adc_9252_inst/ad9252_dco_sync/BUFIO_dco}]
set_property LOC IDELAY_X0Y22 [get_cells {ad_data_inst/adc_9252_inst/ad9252_fco_sync/IDELAYE2_fco}]
set_property LOC ILOGIC_X0Y22 [get_cells {ad_data_inst/adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Master}]
set_property LOC ILOGIC_X0Y21 [get_cells {ad_data_inst/adc_9252_inst/ad9252_fco_sync/ISERDESE2_fco_Slave}]
set_property LOC R22 [get_cells {ad_data_inst/adc_9252_inst/adc_diff2single_inst/FCO_inst}]

#set_property LOC IDELAY_X0Y8 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[0].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y8 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[0].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y7 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[0].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC R16 [get_cells {ad_data_inst/adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[0].IBUFDS_data_D2S}]

#set_property LOC IDELAY_X0Y12 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[1].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y12 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[1].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y11 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[1].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC T18 [get_cells {ad_data_inst/adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[1].IBUFDS_data_D2S}]

#set_property LOC IDELAY_X0Y14 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[2].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y14 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[2].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y13 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[2].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC U19 [get_cells {ad_data_inst/adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[2].IBUFDS_data_D2S}]

#set_property LOC IDELAY_X0Y16 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[3].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y16 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[3].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y15 [get_cells {ad_data_inst/adc_9252_inst/genblk1.genblk1[3].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC T22 [get_cells {ad_data_inst/adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[3].IBUFDS_data_D2S}]

#set_property PACKAGE_PIN R25 [get_ports {adc_data_p[11]}]
#set_property LOC IDELAY_X0Y40 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[4].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y40 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[4].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y39 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[4].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC N26 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[4].IBUFDS_data_D2S}]
#set_property PACKAGE_PIN N26 [get_ports {adc_data_p[12]}]
#set_property LOC IDELAY_X0Y34 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[5].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y34 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[5].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y33 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[5].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC M24 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[5].IBUFDS_data_D2S}]
#set_property PACKAGE_PIN M24 [get_ports {adc_data_p[13]}]
#set_property LOC IDELAY_X0Y30 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[6].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y30 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[6].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y29 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[6].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC M21 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[6].IBUFDS_data_D2S}]
#set_property PACKAGE_PIN M21 [get_ports {adc_data_p[14]}]
#set_property LOC IDELAY_X0Y32 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[7].ad9252_data_inst/IDELAYE2_data}]
#set_property LOC ILOGIC_X0Y32 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[7].ad9252_data_inst/ISERDESE2_data_Master}]
#set_property LOC ILOGIC_X0Y31 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/genblk1.genblk1[7].ad9252_data_inst/ISERDESE2_data_Slave}]
#set_property LOC P19 [get_cells {ad_data_inst/adc_amount.genblk1[1].adc_9252_inst/adc_diff2single_inst/genblk1.data_diff_to_single[7].IBUFDS_data_D2S}]
#set_property PACKAGE_PIN P19 [get_ports {adc_data_p[15]}]


#set_property PACKAGE_PIN F17 [get_ports exclk_p]
#set_property IOSTANDARD LVDS_25 [get_ports exclk_p]


#set_property PACKAGE_PIN F17 [get_ports exclk_p]
set_property PACKAGE_PIN AB11 [get_ports sysclk_p]

