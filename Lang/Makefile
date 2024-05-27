.PHONY: all clean test

MENHIR          := menhir

MENHIRFLAGS     := --infer --explain

OCAMLBUILD      := ocamlbuild -pkg unix -I src -use-ocamlfind -use-menhir -menhir "$(MENHIR) $(MENHIRFLAGS)"

COMP            := compiler

LS 				:= ls

all:
	rm -f ./src/*.cmi
	$(OCAMLBUILD) $(COMP).native
	$(OCAMLBUILD) $(LS).native
	cp ./_build/src/*.cmi ./src/
	mv $(COMP).native $(COMP)
	mv $(LS).native $(LS)

test: all
	./test/test.sh

debug:
	rm -f ./src/*.cmi
	$(OCAMLBUILD) $(COMP).d.byte
	$(OCAMLBUILD) $(LS).d.byte
	cp ./_build/src/*.cmi ./src/
	mv $(COMP).d.byte $(COMP)
	mv $(LS).d.byte $(LS)

clean:
	rm -f *~ .*~
	$(OCAMLBUILD) -clean