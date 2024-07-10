.PHONY: all clean test

MENHIR          := menhir

MENHIRFLAGS     := --infer --explain

OCAMLBUILD      := ocamlbuild -pkg unix -I src -use-ocamlfind -use-menhir -menhir "$(MENHIR) $(MENHIRFLAGS)"

COMP            := compiler

all:
	rm -f ./src/*.cmi
	$(OCAMLBUILD) $(COMP).native
	cp ./_build/src/*.cmi ./src/
	mv $(COMP).native $(COMP)

test: all
	./test/test.sh

debug:
	rm -f ./src/*.cmi
	$(OCAMLBUILD) $(COMP).d.byte
	cp ./_build/src/*.cmi ./src/
	mv $(COMP).d.byte $(COMP)

clean:
	rm -f *~ .*~
	$(OCAMLBUILD) -clean