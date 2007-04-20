package Test::Run::Plugin::CmdLine::Output::GplArt;

use strict;
use warnings;

use Carp;
use Benchmark qw(timestr);
use NEXT;

use Test::Run::Core;

=head1 Test::Run::Plugin::CmdLine::Output::GplArt

This a module that implements the command line/STDOUT specific output of 
L<Test::Run::Obj>, which was taken out of L<Test::Run::Core> to increase
modularity.

=head1 MOTIVATION

This module implements the legacy code of the plugin as inherited from
Test::Harness. It has a derived class called 
L<Test::Run::Plugin::CmdLine::Output> that was written from scratch and
implements a new code under the MIT X11 license.

=cut

use base 'Test::Run::Core';

sub _fail_other_print_bonus_message
{
    my $self = shift;
    
    my $bonusmsg = $self->_bonusmsg() || "";
    $bonusmsg =~ s/^,\s*//;
    if ($bonusmsg)
    {
        $self->output()->print_message("$bonusmsg.");
    }
}

sub _report_failed_with_results_seen
{
    my ($self) = @_;

    $self->output()->print_message(
        $self->_get_failed_with_results_seen_msg(),
    );
}

sub _report
{
    my ($self, $args) = @_;
    my $event = $args->{'event'};
    my $msg;
    if ($event->{type} eq "success")
    {
        $msg = $self->_get_success_msg();
    }
    else
    {
        confess "Unknown \$event->{type} passed to _report!";
    }

    return $self->output()->print_message($msg);
}

sub _fail_other_print_top
{
    my $self = shift;

    my $max_namelen = $self->max_namelen();

    $self->output()->print_message(
        sprintf("%-${max_namelen}s", $self->_get_format_failed_str()) .
        $self->_get_format_middle_str() .
        $self->_get_format_list_str()
    );
    $self->output()->print_message("-" x $self->format_columns());
}

sub _report_final_stats
{
    my ($self) = @_;

    my $tot = $self->tot();

    $self->output()->print_message(
        sprintf("Files=%d, Tests=%d, %s",
           $tot->files(), $tot->max(), timestr($tot->bench(), 'nop'))
       );
}

sub _fail_other_report_test
{
    my $self = shift;
    my $script = shift;

    my $test = $self->failed_tests()->{$script};
    my $max_namelen = $self->max_namelen();
    my $list_len = $self->list_len();

    my @canon = split(/\s+/, $test->canon());

    my $canon_strings = $self->_fail_other_get_canon_strings([@canon]);

    $test->_assign_canon_strings({ main => $self, });
    
    $self->_fail_other_report_tests_print_summary({ test => $test});

    shift(@$canon_strings);

    foreach my $c (@$canon_strings)
    {
        $self->output()->print_message(
            sprintf((" " x ($self->format_columns() - $list_len) . 
                "%s"),
                $c
            ),
        );
    }
}

sub _report_tap_event
{
    my ($self, $args) = @_;
    
    my $raw_event = $args->{'raw_event'};

    if ($self->Verbose())
    {
        chomp($raw_event);
        $self->output()->print_message($raw_event);
    }
}

sub _report_test_progress
{
    my ($self, $args) = @_;

    my $totals = $args->{totals};

    my $curr = $totals->seen();
    my $next = $self->Strap()->next();
    my $max  = $totals->max();
    my $detail = $totals->last_detail;

    if ( $detail->ok() )
    {
        $self->output()->print_ml_less("ok $curr/$max");
    }
    else
    {
        $self->output()->print_ml("NOK $curr");
    }

    if ($curr > $next) 
    {
        $self->output()->print_message("Test output counter mismatch [test $curr]");
    }
    elsif ($curr < $next)
    {
        $self->output()->print_message(
            "Confused test output: test $curr answered after test " . 
            ($next - 1)
        );
    }
}

sub _report_script_start_environment
{
    my $self = shift;

    if ( $self->Debug() )
    {
        my $perl5lib = 
            ((exists($ENV{PERL5LIB}) && defined($ENV{PERL5LIB})) ?
                $ENV{PERL5LIB} :
                ""
            );

        $self->output()->print_message("# PERL5LIB=$perl5lib");
    }
}

=head1 LICENSE

This module is licensed under the GPL v2 or later or the Artistic license
(original only) and is copyrighted by Larry Wall, Michael G. Schwern, Andy
Lester and others.

=cut
1;
