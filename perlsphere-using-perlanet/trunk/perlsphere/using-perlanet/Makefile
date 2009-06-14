all:

upload: all
	rsync -a -v --progress --rsh=ssh atom.xml index.html opml.xml $${HOMEPAGE_SSH_PATH}/perlsphere-using-perlanet/
