.DEFAULT_GOAL := bot_num.ana.hfst
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
