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
tb_adv2 = lab2_adv_1_ivt.sv
src_adv2 = $(mod_adv2) $(tb_adv2)
vadv2 = $(patsubst %, $(adv2_dir)/%, $(src_adv2))

mod_adv2_2 = lab2_adv_2.sv enum_subset.sv
tb_adv2_2 = lab2_adv_2_t.sv
src_adv2_2 = $(mod_adv2_2) $(tb_adv2_2)
vadv2_2 = $(patsubst %, $(adv2_dir)/%, $(src_adv2_2))

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

# --- Targets ---
.PHONY: clean lb1_1 lb1_1w lb1_2 lb1_2w lab1_1 lab1_2 pra2_1 pra2_1_m1 pra2_2 adv2 adv2_2

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