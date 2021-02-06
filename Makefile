.DEFAULT_GOAL := check
%.lexd.hfst: %.lexd
	lexd $< | hfst-txt2fst -o $@
%.txt: %.lexd.hfst
	hfst-fst2strings $< -o $@
	cat $@
%.ana.hfst: %.gen.hfst
	hfst-invert $< -o $@
%.twol.hfst: %.twol
	hfst-twolc $< -o $@
%.gen.hfst: %.lexd.hfst %.twol.hfst
	hfst-compose-intersect $^ -o $@
check-ana: main.ana.hfst gold-ana.txt
	bash compare.sh $^
check-gen: main.gen.hfst gold-gen.txt
	bash compare.sh $^
check: check-ana check-gen
