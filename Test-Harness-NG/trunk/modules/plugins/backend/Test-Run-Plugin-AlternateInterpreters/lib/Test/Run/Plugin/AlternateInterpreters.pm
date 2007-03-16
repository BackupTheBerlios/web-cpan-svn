package Test::Run::Plugin::AlternateInterpreters;

use warnings;
use strict;

use NEXT;

use base 'Test::Run::Base';
use base 'Class::Accessor';

=head1 NAME

Test::Run::Plugin::AlternateInterpreters - Define different interpreters for different test scripts with Test::Run.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(
    alternate_interpreters
));

sub _get_simple_params
{
    my $self = shift;
    return 
    [
        qw(alternate_interpreters), 
        @{$self->NEXT::_get_simple_params()}
    ];
}

=head1 SYNOPSIS

    package MyTestRun;

    use base 'Test::Run::Plugin::AlternateInterpreters';
    use base 'Test::Run::Obj';

=head1 FUNCTIONS

=cut


sub _init_strap
{
    my ($self, $test_file) = @_;
    $self->NEXT::_init_strap($test_file);
    
    if (defined(my $interpreters_ref = $self->alternate_interpreters()))
    {
        SCAN_INTERPRETERS:
        foreach my $i_ref (@$interpreters_ref)
        {
            if ($self->_does_interpreter_match($i_ref, $test_file))
            {
                $self->Strap()->Test_Interpreter($i_ref->{'cmd'});
                $self->Strap()->Switches("");
                $self->Strap()->Switches_Env("");
                last SCAN_INTERPRETERS;
            }
        }
    }
}

sub _does_interpreter_match
{
    my ($self, $i_ref, $test_file) = @_;

    my $pattern = $i_ref->{pattern};
    return ($test_file =~ m{$pattern});
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-run-plugin-alternateinterpreters at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test::Run::Plugin::AlternateInterpreters>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Run::Plugin::AlternateInterpreters

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test::Run::Plugin::AlternateInterpreters>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test::Run::Plugin::AlternateInterpreters>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test::Run::Plugin::AlternateInterpreters>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Run-Plugin-AlternateInterpreters/>

=back

=head1 ACKNOWLEDGEMENTS

Curtis "Ovid" Poe ( L<http://search.cpan.org/~ovid/> ) who gave the idea
of testing several tests from several interpreters in one go here:

L<http://use.perl.org/~Ovid/journal/32092>

=head1 SEE ALSO

L<Test::Run>, L<Test::Run::CmdLine>, L<TAP::Parser>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1; # End of Test::Run::Plugin::AlternateInterpreters
