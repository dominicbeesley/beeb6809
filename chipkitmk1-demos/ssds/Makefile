all: all_chipkit

HOSTFS=~/hostfs



all_chipkit:	
	find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 ../../scripts/buildssd.sh


hostfs:	all_chipkit
	mkdir -p $(HOSTFS)/CKDEMO
	dfs read -d $(HOSTFS)/CKDEMO -i ckdemo.ssd


clean:
	rm -f *.ssd
