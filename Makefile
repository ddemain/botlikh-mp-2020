.DEFAULT_GOAL := check

tests = tests.csv
test_sources = $(shell sed -s 1d $(tests) | cut -d, -f5 | sort -u)

main.lexd.hfst: $(wildcard *.lexd)
	set -o pipefail; cat $^ | lexd | hfst-txt2fst -o $@
%.ana.hfst: %.gen.hfst
	hfst-invert $< -o $@
%.twol.hfst: %.twol
	hfst-twolc $< -o $@
%.pregen.hfst: %.lexd.hfst %.twol.hfst
	hfst-compose-intersect $^ -o $@
%.gen.hfst: %.pregen.hfst %.postgen.hfst
	hfst-compose $^ -o $@
%.postgen.hfst: boundaries.twol.hfst
	cp $< $@
%.pass.txt: $(tests)
	awk -F, '$$5 == "$*" && $$4 == "pass" {print $$1 ":" $$3}' $^  | sort -u > $@
%.ignore.txt: $(tests)
	awk -F, '$$5 == "$*" && $$4 == "ignore" {print $$1 ":" $$3}' $^  | sort -u > $@
check-gen: main.gen.hfst $(foreach t,$(test_sources),$(t).pass.txt $(t).ignore.txt)
	for t in $(test_sources); do echo $$t; bash compare.sh $< $$t.ignore.txt; bash compare.sh $< $$t.pass.txt || exit $$?; done
check: check-gen
