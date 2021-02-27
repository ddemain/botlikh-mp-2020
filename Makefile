.DEFAULT_GOAL := check
.PHONY: check-ana check-gen check

%.lexd.hfst: %.lexd
	lexd $< | hfst-txt2fst -o $@
%.twol.hfst: %.twol
	hfst-twolc $< -o $@
%.pregen.hfst: %.lexd.hfst %.twol.hfst
	hfst-compose-intersect $^ -o $@

%.post.hfst: %.post.twol
	hfst-twolc $< -o $@
%.gen.hfst: %.pregen.hfst %.post.hfst
	hfst-compose-intersect $^ -o $@
%.ana.hfst: %.gen.hfst
	hfst-invert $< -o $@
%.txt: %.gen.hfst
	hfst-fst2strings $< -o $@
	cat $@

check-ana: main.ana.hfst gold-ana.txt
	bash compare.sh $^
check-gen: main.gen.hfst gold-gen.txt
	bash compare.sh $^
check: check-ana check-gen
