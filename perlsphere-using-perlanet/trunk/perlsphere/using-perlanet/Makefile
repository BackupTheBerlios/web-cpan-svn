all: index.html

index.html: index.tt subscriptions.opml perlanetrc
	./run

upload: all
	rsync -a -v --progress --rsh=ssh atom.xml index.html opml.xml $${HOMEPAGE_SSH_PATH}/perlsphere-using-perlanet/
