# This *should* be portable (enough)

PDFLATEX   = pdflatex
# -halt-on-error:
#	exits LaTeX on almost all errors
# interaction=nonstopmode
#	exits LaTeX on file not found errors (e.g. \usepackage{...})
LATEXFLAGS = -halt-on-error -interaction=nonstopmode

COMPILE = $(PDFLATEX) $(LATEXFLAGS)

pdfs != ls */*.tex|sed 's/.tex/.pdf/'

.PHONY: all
all: $(pdfs) distclean

.PHONY: help
help:
	@echo "all           : create all .pdf"
	@echo "distclean     : remove .aux/.log/.out/.toc      files"
	@echo "clean         : remove .aux/.log/.out/.toc/.pdf files"

distclean:
	@echo "Removing .aux/.log/.out/.toc files..."
	@rm -f */*.aux */*.log */*.out */*.toc

.PHONY: clean
clean: distclean
	@echo "Removing .pdf files..."
	@rm -f */*.pdf

.SUFFIXES: .tex .pdf
.tex.pdf:
	@echo "Compiling $< to $@ ..."
	@d=`dirname $<`;f=`basename $<`;cd $$d; \
	if ! $(COMPILE) $$f >/dev/null 2>&1 ; then \
		$(COMPILE) $$f; \
	fi; \
	$(COMPILE) $$f >/dev/null 2>&1; \
	$(COMPILE) $$f >/dev/null 2>&1
