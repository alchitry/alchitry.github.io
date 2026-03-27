# Ft+ pinout for top of Pt

set_property PACKAGE_PIN H4 [get_ports {ft_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_clk}]
# ft_clk => 100000000Hz
create_clock -period 10.0 -name ft_clk_13 -waveform {0.000 5.0} [get_ports ft_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ft_clk_13]

set_property PACKAGE_PIN AB22 [get_ports {ft_wakeup}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_wakeup}]

set_property PACKAGE_PIN AB21 [get_ports {ft_reset}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_reset}]

set_property PACKAGE_PIN N2 [get_ports {ft_rxf}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_rxf}]

set_property PACKAGE_PIN P2 [get_ports {ft_txe}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_txe}]

set_property PACKAGE_PIN AB18 [get_ports {ft_oe}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_oe}]

set_property PACKAGE_PIN AA18 [get_ports {ft_rd}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_rd}]

set_property PACKAGE_PIN E3 [get_ports {ft_wr}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_wr}]

set_property PACKAGE_PIN M2 [get_ports {ft_be[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[0]}]

set_property PACKAGE_PIN M1 [get_ports {ft_be[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[1]}]

set_property PACKAGE_PIN L1 [get_ports {ft_be[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[2]}]

set_property PACKAGE_PIN F3 [get_ports {ft_be[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[3]}]

set_property PACKAGE_PIN R14 [get_ports {ft_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[0]}]

set_property PACKAGE_PIN P14 [get_ports {ft_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[1]}]

set_property PACKAGE_PIN R16 [get_ports {ft_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[2]}]

set_property PACKAGE_PIN P15 [get_ports {ft_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[3]}]

set_property PACKAGE_PIN R17 [get_ports {ft_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[4]}]

set_property PACKAGE_PIN P16 [get_ports {ft_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[5]}]

set_property PACKAGE_PIN P17 [get_ports {ft_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[6]}]

set_property PACKAGE_PIN N17 [get_ports {ft_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[7]}]

set_property PACKAGE_PIN W17 [get_ports {ft_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[8]}]

set_property PACKAGE_PIN V17 [get_ports {ft_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[9]}]

set_property PACKAGE_PIN T18 [get_ports {ft_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[10]}]

set_property PACKAGE_PIN R18 [get_ports {ft_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[11]}]

set_property PACKAGE_PIN AB20 [get_ports {ft_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[12]}]

set_property PACKAGE_PIN AA19 [get_ports {ft_data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[13]}]

set_property PACKAGE_PIN V19 [get_ports {ft_data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[14]}]

set_property PACKAGE_PIN V18 [get_ports {ft_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[15]}]

set_property PACKAGE_PIN G4 [get_ports {ft_data[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[16]}]

set_property PACKAGE_PIN H3 [get_ports {ft_data[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[17]}]

set_property PACKAGE_PIN G3 [get_ports {ft_data[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[18]}]

set_property PACKAGE_PIN P5 [get_ports {ft_data[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[19]}]

set_property PACKAGE_PIN P4 [get_ports {ft_data[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[20]}]

set_property PACKAGE_PIN P6 [get_ports {ft_data[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[21]}]

set_property PACKAGE_PIN N5 [get_ports {ft_data[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[22]}]

set_property PACKAGE_PIN M6 [get_ports {ft_data[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[23]}]

set_property PACKAGE_PIN M5 [get_ports {ft_data[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[24]}]

set_property PACKAGE_PIN L5 [get_ports {ft_data[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[25]}]

set_property PACKAGE_PIN L4 [get_ports {ft_data[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[26]}]

set_property PACKAGE_PIN K6 [get_ports {ft_data[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[27]}]

set_property PACKAGE_PIN J6 [get_ports {ft_data[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[28]}]

set_property PACKAGE_PIN E2 [get_ports {ft_data[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[29]}]

set_property PACKAGE_PIN D2 [get_ports {ft_data[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[30]}]

set_property PACKAGE_PIN M3 [get_ports {ft_data[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[31]}]

