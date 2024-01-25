# 03_placement.tcl
set CHIP_LIB "CHIP_LIB"
set TOP "CHIP"
set ICC_HOME "/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC"
set SDC "asyn_fifo.sdc"
set DEF "../design_data/CHIP.def"
set ADD_TIE "../script/add_tie.tcl"
set RPT_PATH "../rpt/"
set POWER "VDD"
set GROUND "VSS"
set MAX_FANOUT 100
#======================================================================
# Start with a Good Design Setup
#======================================================================
check_physical_design -for_placement > \
 [format "%s%s%s" $RPT_PATH $TOP "_place_check.rpt"]
check_physical_constraints > \
 [format "%s%s%s" $RPT_PATH $TOP "_place_const.rpt"]
#======================================================================
# Test Features
#======================================================================
read_def $DEF
current_design $TOP
report_scan_chain > \
 [format "%s%s%s" $RPT_PATH $TOP "_place_scan.rpt"]
check_scan_chain > \
 [format "%s%s%s" $RPT_PATH $TOP "_place_scan_chk.rpt"]
#======================================================================
# Report the setting for high fanout synthesis
#======================================================================
report_ahfs_options > \
 [format "%s%s%s" $RPT_PATH $TOP "_place_ahfs_options.rpt"]
#======================================================================
# Checking high fanout nets
# Take a look at which nets are candidates for high fanout synthesis
# all_high_fanout # Returns all high fanout objects
#======================================================================
all_high_fanout -nets -threshold $MAX_FANOUT > \
 [format "%s%s%s" $RPT_PATH $TOP "_place_ahfs_net.rpt"]
#======================================================================
# Report Power before power optimization
#======================================================================
current_design $TOP
report_power > [format "%s%s%s" $RPT_PATH $TOP "_pre_power_opt.rpt"]
#======================================================================
# Reading SAIF file for Dynamic Power Optimization
#======================================================================
# /cad/synopsys/icc/2015.06-sp1/bin/vcd2saif -i ../design_data/CHIP.vcd -o ../design_data/CHIP.saif
#read_saif -input ../design_data/CHIP.saif -instance_name test_top/top
#======================================================================
# Place optimization
#======================================================================
source $ADD_TIE
set_host_options -max_cores 4
place_opt -optimize_dft -power -congestion
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
#======================================================================
# Report power after power optimization
#======================================================================
report_power > [format "%s%s%s" $RPT_PATH $TOP "_post_power_opt.rpt"]
#======================================================================
# Refine Placement (if congestion is not met do Refinement)
# Click Global Route Congestion on GUI window and Click Reload
#======================================================================
refine_placement -perturbation_level high
set_fix_hold [all_clocks]
psynopt;
psynopt -congestion; # -congestion
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
#======================================================================
# Save design
#======================================================================
report_timing > [format "%s%s%s" $RPT_PATH $TOP "_place_timing.rpt"]
report_timing -delay_type min > [format "%s%s%s" $RPT_PATH $TOP "_place_hold.rpt"]
#====================================
# Save design
#======================================================================
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"]
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"] -as "placement"