# Ft pinout for Au

set_property PACKAGE_PIN D4 [get_ports {ft_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_clk}]
# ft_clk => 100000000Hz
create_clock -period 10.0 -name ft_clk_13 -waveform {0.000 5.0} [get_ports ft_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ft_clk_13]

set_property PACKAGE_PIN N6 [get_ports {ft_wakeup}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_wakeup}]

set_property PACKAGE_PIN M6 [get_ports {ft_reset}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_reset}]

set_property PACKAGE_PIN L2 [get_ports {ft_rxf}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_rxf}]

set_property PACKAGE_PIN L3 [get_ports {ft_txe}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_txe}]

set_property PACKAGE_PIN P9 [get_ports {ft_oe}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_oe}]

set_property PACKAGE_PIN N9 [get_ports {ft_rd}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_rd}]

set_property PACKAGE_PIN J1 [get_ports {ft_wr}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_wr}]

set_property PACKAGE_PIN H1 [get_ports {ft_be[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[0]}]

set_property PACKAGE_PIN K1 [get_ports {ft_be[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_be[1]}]

set_property PACKAGE_PIN C4 [get_ports {ft_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[0]}]

set_property PACKAGE_PIN G2 [get_ports {ft_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[1]}]

set_property PACKAGE_PIN G1 [get_ports {ft_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[2]}]

set_property PACKAGE_PIN J5 [get_ports {ft_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[3]}]

set_property PACKAGE_PIN J4 [get_ports {ft_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[4]}]

set_property PACKAGE_PIN G5 [get_ports {ft_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[5]}]

set_property PACKAGE_PIN G4 [get_ports {ft_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[6]}]

set_property PACKAGE_PIN H5 [get_ports {ft_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[7]}]

set_property PACKAGE_PIN H4 [get_ports {ft_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[8]}]

set_property PACKAGE_PIN F2 [get_ports {ft_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[9]}]

set_property PACKAGE_PIN E1 [get_ports {ft_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[10]}]

set_property PACKAGE_PIN J3 [get_ports {ft_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[11]}]

set_property PACKAGE_PIN H3 [get_ports {ft_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[12]}]

set_property PACKAGE_PIN H2 [get_ports {ft_data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[13]}]

set_property PACKAGE_PIN K3 [get_ports {ft_data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[14]}]

set_property PACKAGE_PIN K2 [get_ports {ft_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ft_data[15]}]

