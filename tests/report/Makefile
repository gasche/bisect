COMPILE_FLAGS=-I ../../_build -pp '$(PATH_OCAML_BIN)/camlp4o str.cma -I ../../_build bisect_pp.cmo' bisect.$(LIB_EXT) $(FLAGS)
XMLLINT=$(shell which xmllint)

default: clean compile run report

clean::
	@rm -fr report
	@rm -f *.cm* *.out *.o *.jo result.* $(EXECUTABLE)

compile::
	@$(PATH_OCAML_BIN)/$(COMPILER) $(COMPILE_FLAGS) -o $(EXECUTABLE) source.ml

run::
	@$(RUN)$(EXECUTABLE) -inf 0 -sup 3 > /dev/null
	@$(RUN)$(EXECUTABLE) -inf 7 -sup 11 > /dev/null

report::
	@rm -fr report
	@$(REPORT) -bisect result.bisect *.out
	@$(REPORT) -csv result.csv *.out
	@$(REPORT) -dump-dtd result.dtd *.out
	@$(REPORT) -dump result.dump *.out
	@$(REPORT) -text result.text *.out
	@$(REPORT) -xml - *.out | grep -v '^<!\-\- generated by Bisect' > result.xml
	@$(REPORT) -xml-emma - *.out | grep -v '^<!\-\- generated by Bisect' > result.xml-emma
	@$(REPORT) -no-navbar -no-folding -html report *.out
	@grep -v 'class="footer"' report/file0000.html > result.html
ifeq ($(findstring xmllint,$(XMLLINT)),xmllint)
	@$(XMLLINT) --noout --dtdvalid result.dtd result.xml
	@$(XMLLINT) --noout result.xml-emma
else
endif
	@(for ext in bisect csv dtd dump html text xml xml-emma; do \
		echo "     testing '$$ext' format ..."; \
		diff -q result.$$ext reference.$$ext && rm -f result.$$ext; \
	done || exit 0)
	@rm -fr report
	@rm -f *.cm* *.out *.o *.jo $(EXECUTABLE)
