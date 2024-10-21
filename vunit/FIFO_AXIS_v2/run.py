#!/usr/bin/env python3

"""
VHDL FIFO
---------

test bench of FIFO.
"""

from pathlib import Path
from vunit import VUnit

VU = VUnit.from_argv()
VU.add_vhdl_builtins()
VU.add_osvvm()
VU.add_verification_components()

SRC_PATH 		= Path(__file__).parent / "src"


DESIGN_PATH		= Path(__file__).parent / "src/design"
PCKG_PATH		= Path(__file__).parent / "src/packages"
TEST_PATH		= Path(__file__).parent / "src/test"

VU.add_library("lib").add_source_files([SRC_PATH / DESIGN_PATH / "*.vhd",
										SRC_PATH / PCKG_PATH / "*.vhd",
										SRC_PATH / TEST_PATH / "*.vhd"] )

VU.set_compile_option("ghdl.a_flags", ["--ieee=synopsys", "-frelaxed-rules"])
VU.set_sim_option("ghdl.elab_flags", ["-fsynopsys"] )
#VU.set_sim_option("ghdl.gtkwave_script.gui",["-viewer"])


#design_lib = VU.add_library("design_lib").add_source_files( DESIGN_PATH/  "*.vhd" )
#pckg_lib = VU.add_library("pckg_lib").add_source_files(PCKG_PATH /  "*.vhd" )
#test_lib = VU.add_library("test_lib").add_source_files(TEST_PATH /  "*.vhd" )





VU.main()
