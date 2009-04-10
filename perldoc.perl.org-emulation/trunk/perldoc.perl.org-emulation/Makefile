all: test

got/perlsyn.html: create-perldoc.perl.org.pl
	@perl create-perldoc.perl.org.pl

test: got/perlsyn.html
	diff -u expected/perlsyn.html got/perlsyn.html
