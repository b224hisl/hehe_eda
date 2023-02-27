#################################################################################
#
# Created by Genus(TM) Synthesis Solution 20.11-s111_1 on Sun Feb 13 16:49:41 CST 2022
#
#################################################################################

## library_sets
create_library_set -name default_emulate_libset_max \
    -timing { /work/stu/yzhu/ai-chip/hehe_eda/conda-env/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib  }

    ## rc_corner
create_rc_corner -name default_emulate_rc_corner \
    -preRoute_res 1.0 \
    -preRoute_cap 1.0 \
    -preRoute_clkres 0.0 \
    -preRoute_clkcap 0.0 \
    -postRoute_res {1.0 1.0 1.0} \
    -postRoute_cap {1.0 1.0 1.0} \
    -postRoute_xcap {1.0 1.0 1.0} \
    -postRoute_clkres {1.0 1.0 1.0} \
    -postRoute_clkcap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name default_emulate_delay_corner \
     -library_set default_emulate_libset_max \
    -rc_corner default_emulate_rc_corner

## constraint_mode
create_constraint_mode -name default_emulate_constraint_mode \
    -sdc_files { /work/stu/yzhu/ai-chip/hehe_eda/conda-env/share/openlane/scripts/base.sdc }

## analysis_view
create_analysis_view -name default_emulate_view \
    -constraint_mode default_emulate_constraint_mode \
    -delay_corner default_emulate_delay_corner

## set_analysis_view
set_analysis_view -setup { default_emulate_view } \
                  -hold { default_emulate_view }

