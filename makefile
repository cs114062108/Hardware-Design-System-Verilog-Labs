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
v1_1 = lab1/practice_1.sv lab1/practice_1_t.sv

# .vvp requirements
vvp1_1 = $(vvpdir)/lab1_1.vvp
$(vvp1_1): $(v1_1)

# --- Targets ---
.PHONY: clean lb1_1

lb1_1: lb1_1_com lb1_1_sim
lb1_1_com: $(vvp1_1)
lb1_1_sim: sim-lab1_1

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