uplevel #0 source synopsys_dc.setup

# 00_design_setup.tcl
# Cell library name
# Cell name
# ICC path
set CHIP_LIB "DPRam_LIB" 
set TOP "ram_mod"
set ICC_HOME "/cad/CBDK/CBDK_TSMC018_Arm/CIC/ICC"

#======================================================================
# 1. 2. are for creating Library
#======================================================================
# 1. Technology Library
set TF [format "%s%s" $ICC_HOME "/tsmc18_CIC.tf"]
set TLU [format "%s%s" $ICC_HOME "/tluplus/t18.tluplus"]

# 1.1 mapping file for (.tf) map to (.itf)
set MAP [format "%s%s" $ICC_HOME "/tluplus/t18.map"]

# 2. Reference Library
set CORE_LIB [format "%s%s" $ICC_HOME "/ tsmc18_fram"]
set IO_LIB [format "%s%s" $ICC_HOME "/tpz973gv"]
set BON_LIB [format "%s%s" $ICC_HOME "/tpb973gv"]

# Gate-level v-code
set RTL_GATE "DP_Ram_syn.v"

# constraints (mode, corner, timing...)
set SDC "sdc_DP_ram.sdc"

#
set search_path      "/cad/CBDK/CBDK_TSMC018_Arm/SynopsysDC/db/  $search_path"
set target_library   "slow.db"
set link_library     "* $target_library dw_foundation.sldb"
set symbol_library   "generic.sdb"
set synthetic_library "dw_foundation.sldb"



#======================================================================
# Creating a Design Library
#======================================================================
create_mw_lib -technology $TF  \
    -mw_reference_library [format "%s %s %s" $CORE_LIB $IO_LIB $BON_LIB ] \
    -bus_naming_style {[%d]} \
    -open $CHIP_LIB


#======================================================================
# Import a Design
#======================================================================
import_designs -format verilog -top $TOP -cel $TOP $RTL_GATE

#======================================================================
# Set tlu_plus_files
#======================================================================
set_tlu_plus_files   -max_tluplus $TLU  -tech2itf_map  $MAP

#======================================================================
# Import SDC
#======================================================================
read_sdc -version Latest $SDC


#======================================================================
# Timing and Optimization Controls
#======================================================================
#set timing_enable_multiple_clocks_per_reg true ;   # for multiple clk
#set case_analysis_with_logic_constants true    ;   # for memory
set_fix_multiple_port_nets -all -buffer_constants

#======================================================================
# Timing Sanity Check ( if Slack < 0 here, APR will definitely fail )
#======================================================================
#set_zero_interconnect_delay_mode true
#report_constraint -all
#report_timing
#set_zero_interconnect_delay_mode false

#======================================================================
# Save Design
#======================================================================
save_mw_cel  -design [format  "%s%s" $TOP ".CEL;1"]
save_mw_cel  -design [format  "%s%s" $TOP ".CEL;1"] -as "design_setup"