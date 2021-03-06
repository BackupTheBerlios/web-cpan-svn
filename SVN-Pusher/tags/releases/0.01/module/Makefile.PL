#!/usr/bin/perl
use ExtUtils::MakeMaker;

my $required_svn = '0.37.0';

WriteMakefile(
    AUTHOR              => 'Shlomi Fish <shlomif@iglu.org.il>',
    ABSTRACT            => 'Push to remote subversion repositories',
    NAME                => 'SVN::Pusher',
    VERSION_FROM        => 'lib/SVN/Pusher.pm',
    PREREQ_PM           => {
        'SVN::Core'   => $required_svn,
        'URI::Escape' => '0',
    },
    EXE_FILES    => [ 
		'bin/svn-pusher',
		 ],
    dist                => {
        COMPRESS        => 'gzip -9',
        SUFFIX          => '.gz',
    },
);

die "SVN::Core $required_svn must be manually installed"
    unless eval {require SVN::Core} && $SVN::Core::VERSION >= $required_svn;
