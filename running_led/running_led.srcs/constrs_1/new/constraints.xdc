set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN E3 [get_ports clk]
set_property PACKAGE_PIN H5 [get_ports {leds[0]}]
set_property PACKAGE_PIN J5 [get_ports {leds[1]}]
set_property PACKAGE_PIN T9 [get_ports {leds[2]}]
set_property PACKAGE_PIN T10 [get_ports {leds[3]}]
set_property PACKAGE_PIN D9 [get_ports rst]

connect_debug_port u_ila_0/probe0 [get_nets [list {top_i/running_led_0/inst/state[0]} {top_i/running_led_0/inst/state[1]} {top_i/running_led_0/inst/state[2]}]]

set_property IOSTANDARD LVCMOS33 [get_ports busy_led]
set_property PACKAGE_PIN G6 [get_ports busy_led]
set_property IOSTANDARD LVCMOS33 [get_ports requst]
set_property PACKAGE_PIN C9 [get_ports requst]


set_property IOSTANDARD LVCMOS33 [get_ports ack]
set_property PACKAGE_PIN G3 [get_ports ack]
