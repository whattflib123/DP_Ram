uplevel #0 source synopsys_dc.setup

#Read All Files
read_file -format verilog  DP_Ram.v

#select top module
current_design ram_mod
link

# Setup/hold time
set_operating_conditions -min_library gtech -min nom_pvt -max_library gtech -max nom_pvt

# Area Constraints
set_max_area 0

#generate Clock 
create_clock -name "clk" -period 15 -waveform { 0 7.5 } { clk }
set_dont_touch_network [ find clock clk ]
set_fix_hold [ find clock clk ]

set_clock_uncertainty 0.1 [get_clocks clk]
set_dont_use slow/CLK*
set_dont_use fast/CLK*
set verilogout_no_tri true
set_fix_multiple_port_nets -all -buffer_constants


#Synthesis all design
compile -exact_map -map_effort high -area_effort high

# Save and Output
write -format ddc     -hierarchy -output "DP_Ram_syn.ddc"
write_sdf -version 1.0  DP_Ram_syn.sdf
write -format verilog -hierarchy -output DP_Ram_syn.v
report_area > area.log
report_timing > timing.log
report_qor   >  DP_Ram_syn.qor
