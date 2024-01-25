# 05_route.tcl
set TOP      "CHIP" ;# Top module
set TOP      "CHIP" ;# Top module
set RPT_PATH "../rpt/"
set ADD_TIE "../script/add_tie.tcl"
set POWER "VDD"
set GROUND "VSS"
#======================================================================
# Check Design and Report, after-CTS-pre-Route
#======================================================================
derive_pg_connection -power_net $POWER -power_pin $POWER -ground_net $GROUND -ground_pin $GROUND
report_timing > [format "%s%s%s" $RPT_PATH $TOP "_route_timing.rpt"]
check_routeability -error_cell CHIP.err > [format "%s%s%s" $RPT_PATH $TOP "_route_routability.rpt"]
#======================================================================
# Setting Routing Setting
#======================================================================
set_route_mode_options -zroute true
set_route_zrt_common_options -post_detail_route_redundant_via_insertion high \
   -concurrent_redundant_via_mode insert_at_high_cost \
   -concurrent_redundant_via_effort_level high \
   -freeze_layer_by_layer_name {{AP true}}   ; # don't use layer AP (metal 10) to avoid DRC violations
set ANTENNA_RULE "/cad/CBDK/CBDK_TN40G_Arm/CBDK_TSMC40_io_TSMC_v2.0/CIC/ICC/antenna_9lm_cic.clf"
source $ANTENNA_RULEset_route_zrt_detail_options -diode_libcell_names ANTENNA1_A9TR -insert_diodes_during_routing true ; # setting for fixing Antenna Violation
#======================================================================
# Detail Routing (1st Routing)
#======================================================================
route_zrt_group -all_clock_nets ; # Route all clk nets
route_zrt_auto ; # perform Global routing, Track assignment and Detail Routing automatically
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
report_timing > [format "%s%s%s" $RPT_PATH $TOP "_route_1st_timing.rpt"]
report_timing -delay_type min > [format "%s%s%s" $RPT_PATH $TOP "_route_1st_hold.rpt"]
#======================================================================
# Setting SI analysis, cross talk analysis
#======================================================================
set_si_options -delta_delay true \
   -static_noise true \
   -timing_window false \
   -min_delta_delay false \
   -static_noise_threshold_above_low 0.3 \
   -static_noise_threshold_below_high 0.3 \
   -route_xtalk_prevention true \
   -route_xtalk_prevention_threshold 0.3 \
   -analysis_effort low \
   -max_transition_mode normal_slew
#======================================================================
# Route Optimization (2nd Routing)
#======================================================================
set_fix_hold [all_clocks]
set_host_options -max_cores 4
route_opt -effort high -xtalk_reduction;
route_opt -incremental ;
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
report_timing > [format "%s%s%s" $RPT_PATH $TOP "_route_2nd_timing.rpt"]
report_timing -delay_type min > [format "%s%s%s" $RPT_PATH $TOP "_route_2nd_hold.rpt"]
#=======================================================================
# Verify Design and Reports (3rd Routing)
#======================================================================
verify_zrt_route > [format "%s%s%s" $RPT_PATH $TOP "_route_drc.rpt"]
route_zrt_detail -incremental true -initial_drc_from_input true ; # -max_number_iterations 120 # fix DRC problem
#route_opt -effort high -incremental ; # fix timing problem
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
report_timing > [format "%s%s%s" $RPT_PATH $TOP "_route_3rd_timing.rpt"]
report_timing -delay_type min > [format "%s%s%s" $RPT_PATH $TOP "_route_3rd_hold.rpt"]
#verify_drc -read_cell_view >> [format "%s%s%s" $RPT_PATH $TOP "_route_drc.rpt"]   ;   # dont use in EDA Cloud
report_constraint -all > [format "%s%s%s" $RPT_PATH $TOP "_route_con.rpt"]
report_design -physical > [format "%s%s%s" $RPT_PATH $TOP "_route_physical.rpt"] ; # check double via > 90%
report_power > [format "%s%s%s" $RPT_PATH $TOP "_route_power.rpt"]
#======================================================================
# Save Desgin
#======================================================================
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"]
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"] -as "route"