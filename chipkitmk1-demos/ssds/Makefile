all: all_chipkit


all_chipkit:	
	find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 ../../scripts/buildssd.sh

clean:
	rm -f *.ssd
