transcript on

vlib rtl_work
vmap work rtl_work

vlib my_lib
vmap rtl_work my_lib

# add library
vcom -2008 -work my_lib {D:/GIT/github/Instruction_decoder/lib/types.vhd}

# add source
vcom -2008 -work work {D:/GIT/github/Instruction_decoder/src/instruction_decoder_v2.vhd}

# add testbench
vcom -2008 -work work {D:/GIT/github/Instruction_decoder/tb/instruction_decoder_v2_tb.vhd}

vsim -t 1ps -L my_lib -L rtl_work -L work -voptargs="+acc"  instruction_decoder_v2_tb

add wave *

view structure
view signals
run 70 us

radix hexadecimal
wave zoom full
