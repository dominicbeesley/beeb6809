HOSTFSDIR=~/hostfs


all: all_beeb

all_beeb:	
	find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 ../scripts/buildssd.sh --hostfs $(HOSTFSDIR)

clean:
	rm -f *.ssd
