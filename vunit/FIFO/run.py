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

SRC_PATH = Path(__file__).parent / "src"



VU.add_library("fifo_lib").add_source_files(SRC_PATH /"design"/"Fifo_top.vhd")

VU.add_library("memtype_lib").add_source_files(SRC_PATH /"design"/"memtypes"/"*.vhd")

VU.add_library("memlogic_lib").add_source_files(SRC_PATH /"design"/"memlogic"/"*.vhd")

VU.add_library("tb_fifo_lib").add_source_files(SRC_PATH / "test" / "Fifo_top_tb.vhd")
VU.add_library("user_arith_lib").add_source_files(SRC_PATH / "packages" / "*.vhd" )


VU.main()
