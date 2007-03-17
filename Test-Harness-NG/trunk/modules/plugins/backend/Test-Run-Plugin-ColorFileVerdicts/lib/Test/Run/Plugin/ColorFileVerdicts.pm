package Test::Run::Plugin::ColorFileVerdicts;

use warnings;
use strict;

use Term::ANSIColor;

=head1 NAME

Test::Run::Plugin::ColorFileVerdicts - make the file verdict ("ok", "NOT OK")
colorful.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Perhaps a little code snippet.


    package MyTestRun;
    
    use vars qw(@ISA);

    @ISA = (qw(Test::Run::Plugin::ColorFileVerdicts Test::Run::Obj));

    my $tester = MyTestRun->new(
        {
            test_files => 
            [
                "t/sample-tests/one-ok.t",
                "t/sample-tests/several-oks.t"
            ],
        }
        );

    $tester->runtests();

=cut

=head1 METHODS

=cut

sub _report_all_ok_test
{
    my ($self, $args) = @_;

    my $test = $self->last_test_obj;
    my $elapsed = $self->last_test_elapsed;

    $self->output()->print_message($test->ml().color("green")."ok$elapsed".color("reset"));
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-run-plugin-colorfileverdicts at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Run-Plugin-ColorFileVerdicts>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Run::Plugin::ColorFileVerdicts

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Run-Plugin-ColorFileVerdicts>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Run-Plugin-ColorFileVerdicts>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Run-Plugin-ColorFileVerdicts>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Run-Plugin-ColorFileVerdicts>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11

=cut

1; # End of Test::Run::Plugin::ColorFileVerdicts
