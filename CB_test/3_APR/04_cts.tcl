# 04_cts.tcl
set TOP "CHIP" ;# Top module
set RTP_PATH "../rpt/"
set POWER "VDD"
set GROUND "VSS"
#======================================================================
# Check Design and Report
#======================================================================
#set cts_enable_clock_at_hierarchical_pin true
check_physical_design -stage pre_clock_opt > [format "%s%s%s" $RPT_PATH $TOP "_cts_check.rpt"]
check_clock_tree
report_clock > [format "%s%s%s" $RTP_PATH $TOP "_cts_clk.rpt"]
report_clock -skew > [format "%s%s%s" $RTP_PATH $TOP "_cts_skew.rpt"]
report_clock_tree -summary > [format "%s%s%s" $RTP_PATH $TOP "_cts_clktree_pre.rpt"]
report_constraint -all > [format "%s%s%s" $RTP_PATH $TOP "_cts_const.rpt"]
report_timing > [format "%s%s%s" $RTP_PATH $TOP "_cts_timing_pre.rpt"]
#======================================================================
# Clock Optimization (takes time)
#======================================================================
set_fix_hold [all_clocks]
set_host_options -max_cores 4
clock_opt -fix_hold_all_clocks -congestion -optimize_dft -no_clock_route ; # -operating_condition min : use this when hold time violation can not be removed , -congestion
clock_opt -only_psyn -fix_hold_all_clocks -congestion -no_clock_route
#optimize_clock_tree -buffer_sizing -buffer_relocation -gate_sizing -gate_relocation -delay_insertion -search_repair_loop 2 -operating_condition max -routed_clock_stage None
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
#======================================================================
# Report CTS timing
#======================================================================
report_clock_tree -summary > [format "%s%s%s" $RTP_PATH $TOP "_cts_clktree_opt.rpt"]
report_timing > [format "%s%s%s" $RTP_PATH $TOP "_cts_timing_opt.rpt"]
report_timing -delay_type min > [format "%s%s%s" $RTP_PATH $TOP "_cts_hold.rpt"] ; # check hold time violation
#======================================================================
# Save Desgin
#======================================================================
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"]
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"] -as "cts"