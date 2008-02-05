use ExtUtils::MakeMaker;

WriteMakefile(
  AUTHOR => 'Shlomi Fish <shlomif@iglu.org.il>',
  NAME => 'IO::Socket::INET6',
  PREREQ_PM => {
	'Socket6'	=> '0.12',
  },
  VERSION_FROM => 'INET6.pm'
);
