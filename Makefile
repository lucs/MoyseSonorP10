# --------------------------------------------------------------------
.ONESHELL:

dPrj := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

dGen := $(dPrj)/gen
$(shell test -d $(dGen) || mkdir -p $(dGen))

# --------------------------------------------------------------------
txt: $(dGen)/moyse_sonor_p10.txt
txtpdf: $(dGen)/moyse_sonor_p10.txt.pdf

$(dGen)/moyse_sonor_p10.txt.pdf: $(dGen)/moyse_sonor_p10.txt
	~lucs/src/ppdf $< 9

$(dGen)/moyse_sonor_p10.txt: $(dPrj)/moyse_sonor_p10.raku
	$< txt > $@

# --------------------------------------------------------------------
ly: $(dGen)/moyse_sonor_p10.ly.pdf

$(dGen)/moyse_sonor_p10.ly.pdf: $(dGen)/moyse_sonor_p10.ly
	lilypond -o $< $<

$(dGen)/moyse_sonor_p10.ly: $(dPrj)/moyse_sonor_p10.raku
	$< ly > $@

