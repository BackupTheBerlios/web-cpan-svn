use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'WWW::Form',
    'VERSION_FROM'	=> 'Form.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    'PM'                => {'Form.pm' => '$(INST_LIBDIR)/Form.pm',
                            'FieldValidator.pm' => '$(INST_LIBDIR)/FieldValidator.pm'}
);
