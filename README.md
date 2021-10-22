## Beam Monitor Readout

### Environment
The readout system is developed and tested on:
* Ubuntu 20.04 LTS, Debian 10
* Xilinx Vivado 2020.2
* Python 3.7.3 or higher
* IPbus Software: main branch
* IPbus Firmware: main branch

### Simulation
Simulator: QuestaSim 10.7c Linux 64 bit

Directory: sim

For FPGA logic simulation (sim chip):
	make sim
	or
	make sim_nogui

### Note
1. LED status

LED5 (D5) ->  ad 9252 done

LED6 (D6) ->  adc data aligned

LED7 (D7) ->  dac config done

LED8 (D8) ->  ad 9512 done

LED9 (D9) ->  topmetal working

LED10 (D10) -> DCM locked

LED11 (D11) -> not used

LED12 (D12) -> not used

