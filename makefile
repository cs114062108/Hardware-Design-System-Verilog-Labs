# -- Compiler and directory variables --
# Compilers
IV = iverilog
VP = vvp
GTK = gtkwave

# Flags, important for compiling system verilog
FIV = -g2012

# Directories
vvpdir = vvps
wavedir = waves

# -- Source declare --
# Verilog source files
mod1_1 = practice_1.sv
src1_1 = $(mod1_1) practice_1_t.sv
v1_1 = $(patsubst %, lab1/%, $(src1_1))
src1_1w = $(mod1_1) practice_1_wt.sv
v1_1w = $(patsubst %, lab1/%, $(src1_1w))

mod1_2 = practice_2.sv
src1_2 = $(mod1_2) practice_2_t.sv
v1_2 = $(patsubst %, lab1/%, $(src1_2))
src1_2w = $(mod1_2) practice_2_wt.sv
v1_2w = $(patsubst %, lab1/%, $(src1_2w))

lab1_dir = lab1_lab

mod_lab1_1 = lab1_1.sv
src_lab1_1 = $(mod_lab1_1) lab1_1_t.sv
vlab1_1 = $(patsubst %, $(lab1_dir)/%, $(src_lab1_1))

mod_lab1_2 = lab1_2.sv
src_lab1_2 = $(mod_lab1_2) lab1_2_t.sv
vlab1_2 = $(patsubst %, $(lab1_dir)/%, $(src_lab1_2))

pra2_dir = pra2

mod_pra2_1 = lab2_1_practice.sv
src_pra2_1 = $(mod_pra2_1) lab2_1_practice_ivt.sv
vpra2_1 = $(patsubst %, $(pra2_dir)/%, $(src_pra2_1))
mod_pra2_1_m1 = lab2_1_practice_1.sv
src_pra2_1_m1 = $(mod_pra2_1_m1) lab2_1_practice_ivt_1.sv
vpra2_1_m1 = $(patsubst %, $(pra2_dir)/%, $(src_pra2_1_m1))

mod_pra2_2 = lab2_2_practice.sv
src_pra2_2 = $(mod_pra2_2) lab2_2_practice_ivt.sv
vpra2_2 = $(patsubst %, $(pra2_dir)/%, $(src_pra2_2))

adv2_dir = adv2

mod_adv2 = lab2_adv_1.sv enum_subset.sv
tb_adv2 = lab2_adv_1_t.sv
src_adv2 = $(mod_adv2) $(tb_adv2)
vadv2 = $(patsubst %, $(adv2_dir)/%, $(src_adv2))

mod_adv2_2 = lab2_adv_2.sv enum_subset.sv switch_reader.sv
tb_adv2_2 = lab2_adv_2_t.sv
src_adv2_2 = $(mod_adv2_2) $(tb_adv2_2)
vadv2_2 = $(patsubst %, $(adv2_dir)/%, $(src_adv2_2))

pra3_dir = pra3
mod_pra3_util = timer.sv clock_divider.sv

mod_pra3 = lab3_practice.sv $(mod_pra3_util)
src_pra3 = $(mod_pra3)
vpra3 = $(patsubst %, $(pra3_dir)/%, $(src_pra3))

tb_pra3_util = pra3_utils_tb0.sv
src_pra3_util = $(mod_pra3_util) $(tb_pra3_util)
vpra3_util = $(patsubst %, $(pra3_dir)/%, $(src_pra3_util))

adv3_dir = adv3
adv3_util_dir = $(adv3_dir)/utils

adv3_1_dir = $(adv3_dir)/part1_src
mod_adv3_1 = lab3_adv1.sv ss_dec_handler.sv ss_dec.sv
vmod_adv3_1 = $(patsubst %, $(adv3_1_dir)/%, $(mod_adv3_1))
util_adv3_1 = clock_divider.sv one_pulse.sv debounce.sv timer.sv
vutil_adv3_1 = $(patsubst %, $(adv3_util_dir)/%, $(util_adv3_1))
vadv3_1 = $(vmod_adv3_1) $(vutil_adv3_1)

adv3_2_dir = $(adv3_dir)/part2_src
mod_adv3_2 = lab3_adv2.sv ss_pat_handler.sv ss_pat.sv
vmod_adv3_2 = $(patsubst %, $(adv3_2_dir)/%, $(mod_adv3_2))
util_adv3_2 = clock_divider.sv one_pulse.sv debounce.sv timer.sv
vutil_adv3_2 = $(patsubst %, $(adv3_util_dir)/%, $(util_adv3_2))
vadv3_2 = $(vmod_adv3_2) $(vutil_adv3_2)

pra4_dir = pra4

mod_pra4 = lab4_practice.sv debounce.sv one_pulse.sv timer.sv
src_pra4 = $(mod_pra4)
vpra4 = $(patsubst %, $(pra4_dir)/%, $(src_pra4))

pra5_dir = pra5
mod_pra5 = lab5_practice.sv
tb_pra5 = lab5_practice_tb.sv
src_pra5 = $(mod_pra5) $(tb_pra5)
vpra5 = $(patsubst %, $(pra5_dir)/%, $(src_pra5))

lab5_dir = lab5
mod_lab5 = lab5_basic.sv

tb_lab5 = lab5_basic_tb.sv
src_lab5 = $(mod_lab5) $(tb_lab5)
vlab5 = $(patsubst %, $(lab5_dir)/%, $(src_lab5))

tb_lab5_hid = lab5_basic_tb_hidden.sv
src_lab5_hid = $(mod_lab5) $(tb_lab5_hid)
vlab5_hid = $(patsubst %, $(lab5_dir)/%, $(src_lab5_hid))

pra6_dir = pra6
mod_pra6 = lab6_practice_master.sv lab6_practice_slave.sv
tb_pra6 = lab6_practice_tb.sv
src_pra6 = $(mod_pra6) $(tb_pra6)
vpra6 = $(patsubst %, $(pra6_dir)/%, $(src_pra6))

lab6_dir = lab6
mod_lab6 = lab6_basic_master.sv lab6_basic_slave.sv
tb_lab6 = lab6_basic_tb.sv
src_lab6 = $(mod_lab6) $(tb_lab6)
vlab6 = $(patsubst %, $(lab6_dir)/%, $(src_lab6))

# .vvp requirements
vvp1_1 = $(vvpdir)/lab1_1.vvp
$(vvp1_1): $(v1_1)
vvp1_1w = $(vvpdir)/lab1_1w.vvp
$(vvp1_1w): $(v1_1w)

vvp1_2 = $(vvpdir)/lab1_2.vvp
$(vvp1_2): $(v1_2)
vvp1_2w = $(vvpdir)/lab1_2w.vvp
$(vvp1_2w): $(v1_2w)

vvp_lab1_1 = $(vvpdir)/lab1_lab_1.vvp
$(vvp_lab1_1): $(vlab1_1)

vvp_lab1_2 = $(vvpdir)/lab1_lab_2.vvp
$(vvp_lab1_2): $(vlab1_2)

vvp_pra2_1 = $(vvpdir)/pra2_1.vvp
$(vvp_pra2_1): $(vpra2_1)
vvp_pra2_1_m1 = $(vvpdir)/pra2_1_m1.vvp
$(vvp_pra2_1_m1): $(vpra2_1_m1)

vvp_pra2_2 = $(vvpdir)/pra2_2.vvp
$(vvp_pra2_2): $(vpra2_2)

vvp_adv2 = $(vvpdir)/adv2.vvp
$(vvp_adv2): $(vadv2)

vvp_adv2_2 = $(vvpdir)/adv2_2.vvp
$(vvp_adv2_2): $(vadv2_2)

vvp_pra3 = $(vvpdir)/pra3.vvp
$(vvp_pra3): $(vpra3)

vvp_pra3_util = $(vvpdir)/pra3_util.vvp
$(vvp_pra3_util): $(vpra3_util)

vvp_adv3_1 = $(vvpdir)/adv3_1.vvp
$(vvp_adv3_1): $(vadv3_1)

vvp_adv3_2 = $(vvpdir)/adv3_2.vvp
$(vvp_adv3_2): $(vadv3_2)

vvp_pra4 = $(vvpdir)/pra4.vvp
$(vvp_pra4): $(vpra4)

vvp_pra5 = $(vvpdir)/pra5.vvp
$(vvp_pra5): $(vpra5)

vvp_lab5 = $(vvpdir)/lab5.vvp
$(vvp_lab5): $(vlab5)

vvp_lab5_hid = $(vvpdir)/lab5_hid.vvp
$(vvp_lab5_hid): $(vlab5_hid)

vvp_pra6 = $(vvpdir)/pra6.vvp
$(vvp_pra6): $(vpra6)

vvp_lab6 = $(vvpdir)/lab6.vvp
$(vvp_lab6): $(vlab6)

# --- Targets ---
.PHONY: clean lb1_1 lb1_1w lb1_2 lb1_2w lab1_1 lab1_2 pra2_1 pra2_1_m1 pra2_2 adv2 adv2_2 pra3 pra3_util adv3_1 adv3_2 pra4 pra5 lab5 lab5_hid pra6 lab6

lb1_1: lb1_1_com lb1_1_sim
lb1_1_com: $(vvp1_1)
lb1_1_sim: run-lab1_1

lb1_1w: lb1_1w_com lb1_1w_sim
lb1_1w_com: $(vvp1_1w)
lb1_1w_sim: run-lab1_1w

lb1_2: lb1_2_com lb1_2_sim
lb1_2_com: $(vvp1_2)
lb1_2_sim: run-lab1_2

lb1_2w: lb1_2w_com lb1_2w_sim
lb1_2w_com: $(vvp1_2w)
lb1_2w_sim: run-lab1_2w

lab1_1: lab1_1_com lab1_1_sim
lab1_1_com: $(vvp_lab1_1)
lab1_1_sim: run-lab1_lab_1

lab1_2: lab1_2_com lab1_2_sim
lab1_2_com: $(vvp_lab1_2)
lab1_2_sim: run-lab1_lab_2

pra2_1: pra2_1_com pra2_1_sim
pra2_1_com: $(vvp_pra2_1)
pra2_1_sim: run-pra2_1

pra2_1_m1: pra2_1_m1_com pra2_1_m1_sim
pra2_1_m1_com: $(vvp_pra2_1_m1)
pra2_1_m1_sim: run-pra2_1_m1

pra2_2: pra2_2_com pra2_2_sim
pra2_2_com: $(vvp_pra2_2)
pra2_2_sim: run-pra2_2

adv2: adv2_com adv2_sim
adv2_com: $(vvp_adv2)
adv2_sim: run-adv2

adv2_2: adv2_2_com adv2_2_sim
adv2_2_com: $(vvp_adv2_2)
adv2_2_sim: run-adv2_2

pra3: pra3_com pra3_sim
pra3_com: $(vvp_pra3)
pra3_sim: run-pra3

pra3_util: pra3_util_com pra3_util_sim
pra3_util_com: $(vvp_pra3_util)
pra3_util_sim: run-pra3_util

adv3_1: adv3_1_com adv3_1_sim
adv3_1_com: $(vvp_adv3_1)
adv3_1_sim: run-adv3_1

adv3_2: adv3_2_com adv3_2_sim
adv3_2_com: $(vvp_adv3_2)
adv3_2_sim: run-adv3_2

pra4: pra4_com pra4_sim
pra4_com: $(vvp_pra4)
pra4_sim: run-pra4

pra5: pra5_com pra5_sim
pra5_com: $(vvp_pra5)
pra5_sim: run-pra5

lab5: lab5_com lab5_sim
lab5_com: $(vvp_lab5)
lab5_sim: run-lab5

lab5_hid: lab5_hid_com lab5_hid_sim
lab5_hid_com: $(vvp_lab5_hid)
lab5_hid_sim: run-lab5_hid

pra6: pra6_com pra6_sim
pra6_com: $(vvp_pra6)
pra6_sim: run-pra6

lab6: lab6_com lab6_sim
lab6_com: $(vvp_lab6)
lab6_sim: run-lab6

# -- Universal make logic --
# Compile pattern rule
$(vvpdir)/%.vvp: | $(vvpdir)
	@echo "==> Compiling $@"
	$(IV) $(FIV) -o $@ $^

# Simulation
run-%: $(vvpdir)/%.vvp | $(wavedir)
	@echo "==> Simulating $<"
	$(VP) $<

# Directories
$(vvpdir) $(wavedir):
	mkdir -p $@

# -- Clean --
clean:
	rm -rf $(vvpdir) $(wavedir)
