.SUFFIXES: .gnuplot .tex .pdf

%.tex: %.gnuplot
	gnuplot -e " \
	set format '$$%g$$' ; \
	set terminal epslatex standalone color \
	header '\usepackage{amsmath}\usepackage{amssymb}' \
	; \
	set output '$@' \
	" $<

%.pdf: %.tex
#	@echo "\\end{document}"
	pdflatex $<
	@mkdir -p junk
	@mv *-inc-eps* junk/
	@mv *-inc.eps junk/
	@mv *.aux junk/
	@mv *.log junk/

all: entropy.pdf
