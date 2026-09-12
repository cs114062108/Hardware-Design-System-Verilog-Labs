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
src1_1 = practice_1.sv practice_1_t.sv
v1_1 = $(patsubst %, lab1/%, $(src1_1))

src1_2 = practice_2.sv practice_2_t.sv
v1_2 = $(patsubst %, lab1/%, $(src1_2))

# .vvp requirements
vvp1_1 = $(vvpdir)/lab1_1.vvp
$(vvp1_1): $(v1_1)

vvp1_2 = $(vvpdir)/lab1_2.vvp
$(vvp1_2): $(v1_2)

# --- Targets ---
.PHONY: clean lb1_1 lb1_2

lb1_1: lb1_1_com lb1_1_sim
lb1_1_com: $(vvp1_1)
lb1_1_sim: sim-lab1_1

lb1_2: lb1_2_com lb1_2_sim
lb1_2_com: $(vvp1_2)
lb1_2_sim: sim-lab1_2

# -- Universal make logic --
# Compile pattern rule
$(vvpdir)/%.vvp: | $(vvpdir)
	@echo "==> Compiling $@"
	$(IV) $(FIV) -o $@ $^

# Simulation
sim-%: $(vvpdir)/%.vvp | $(wavedir)
	@echo "==> Simulating $<"
	$(VP) $<

# Directories
$(vvpdir) $(wavedir):
	mkdir -p $@

# -- Clean --
clean:
	rm -rf $(vvpdir) $(wavedir)