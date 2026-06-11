# Ft+ pinout for bottom of Pt

set_property PACKAGE_PIN D17 [get_ports {ft_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_clk}]
# ft_clk => 100000000Hz
create_clock -period 10.0 -name ft_clk_13 -waveform {0.000 5.0} [get_ports ft_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ft_clk_13]

set_property PACKAGE_PIN AB1 [get_ports {ft_wakeup}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_wakeup}]

set_property PACKAGE_PIN AA1 [get_ports {ft_reset}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_reset}]

set_property PACKAGE_PIN A16 [get_ports {ft_rxf}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_rxf}]

set_property PACKAGE_PIN A15 [get_ports {ft_txe}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_txe}]

set_property PACKAGE_PIN AA3 [get_ports {ft_oe}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_oe}]

set_property PACKAGE_PIN Y3 [get_ports {ft_rd}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_rd}]

set_property PACKAGE_PIN D16 [get_ports {ft_wr}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_wr}]

set_property PACKAGE_PIN A19 [get_ports {ft_be[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[0]}]

set_property PACKAGE_PIN B21 [get_ports {ft_be[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[1]}]

set_property PACKAGE_PIN A21 [get_ports {ft_be[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[2]}]

set_property PACKAGE_PIN E16 [get_ports {ft_be[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[3]}]

set_property PACKAGE_PIN Y2 [get_ports {ft_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[0]}]

set_property PACKAGE_PIN W2 [get_ports {ft_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[1]}]

set_property PACKAGE_PIN AB6 [get_ports {ft_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[2]}]

set_property PACKAGE_PIN AB7 [get_ports {ft_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[3]}]

set_property PACKAGE_PIN Y7 [get_ports {ft_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[4]}]

set_property PACKAGE_PIN Y8 [get_ports {ft_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[5]}]

set_property PACKAGE_PIN AB8 [get_ports {ft_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[6]}]

set_property PACKAGE_PIN AA8 [get_ports {ft_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[7]}]

set_property PACKAGE_PIN AA6 [get_ports {ft_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[8]}]

set_property PACKAGE_PIN Y6 [get_ports {ft_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[9]}]

set_property PACKAGE_PIN AB5 [get_ports {ft_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[10]}]

set_property PACKAGE_PIN AA5 [get_ports {ft_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[11]}]

set_property PACKAGE_PIN AB2 [get_ports {ft_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[12]}]

set_property PACKAGE_PIN AB3 [get_ports {ft_data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[13]}]

set_property PACKAGE_PIN Y9 [get_ports {ft_data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[14]}]

set_property PACKAGE_PIN W9 [get_ports {ft_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[15]}]

set_property PACKAGE_PIN C17 [get_ports {ft_data[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[16]}]

set_property PACKAGE_PIN B17 [get_ports {ft_data[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[17]}]

set_property PACKAGE_PIN B18 [get_ports {ft_data[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[18]}]

set_property PACKAGE_PIN C13 [get_ports {ft_data[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[19]}]

set_property PACKAGE_PIN B13 [get_ports {ft_data[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[20]}]

set_property PACKAGE_PIN A13 [get_ports {ft_data[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[21]}]

set_property PACKAGE_PIN A14 [get_ports {ft_data[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[22]}]

set_property PACKAGE_PIN C22 [get_ports {ft_data[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[23]}]

set_property PACKAGE_PIN B22 [get_ports {ft_data[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[24]}]

set_property PACKAGE_PIN E22 [get_ports {ft_data[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[25]}]

set_property PACKAGE_PIN D22 [get_ports {ft_data[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[26]}]

set_property PACKAGE_PIN D20 [get_ports {ft_data[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[27]}]

set_property PACKAGE_PIN C20 [get_ports {ft_data[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[28]}]

set_property PACKAGE_PIN E21 [get_ports {ft_data[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[29]}]

set_property PACKAGE_PIN D21 [get_ports {ft_data[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[30]}]

set_property PACKAGE_PIN A18 [get_ports {ft_data[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[31]}]

