default:
	@rm -fr *.result *.cm*
	@for file in *.ml; do \
		echo "     testing '$$file' ..."; \
		$(PATH_OCAML_BIN)/ocamlc -c -I ../../_build -ppx '../../_build/src/syntax/bisect_ppx.byte -mode fast' -dsource $$file 2> $$file.result; \
		diff -q $$file.reference $$file.result || exit 1; \
	done
	@rm -fr *.result *.cm*
