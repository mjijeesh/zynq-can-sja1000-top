from vunit import VUnit
from pathlib import Path

d = Path(__file__).parent
ui = VUnit.from_argv()

lib = ui.add_library("lib")
lib.add_source_files(str(x) for x in d.glob('*.vhd'))
lib.add_source_files(str(x) for x in d.glob('../hdl/*.vhd'))
ui.add_osvvm()
ui.main()
