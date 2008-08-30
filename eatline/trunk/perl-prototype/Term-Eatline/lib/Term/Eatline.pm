package Term::Eatline;

use warnings;
use strict;

use List::Util qw(min);

=head1 NAME

Term::Eatline - a Perl prototype for libeatline - the BSDLed GNU readline 
replacement and extension.

=head1 VERSION

Version v0.0.1

=cut

use version; our $VERSION = qv('0.0.1');

use base 'Class::Accessor';

use Curses;

__PACKAGE__->mk_accessors(qw(
    _main_win
    ));

=head1 SYNOPSIS

Perhaps a little code snippet.

    use Term::Eatline;

    my $eatline = Term::Eatline->new();

    while (my $line = $eatline->readline())
    {
        # Do something with $line.
    }

=head1 FUNCTIONS

=head2 my $eatline = Term::Eatline->new({%args})

The constructor.

=cut

sub new
{
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);

    $self->_init($args);

    return $self;
}

sub _init
{
    my ($self, $args) = @_;

    my $main_win = Curses->new();

    $self->_main_win($main_win);
    $self->_main_win->keypad(1);

    initscr();
    noecho();
}

sub DESTROY
{
    my $self = shift;

    print "\n\n\n\n\n\nAre you sure?\n\n\n\n";

    $self->_destroy();
}

sub _destroy
{
    my $self = shift;

    $self->_main_win(undef);

    endwin();
}

=head2 $eatline->readline()

Reads a line from the terminal based on the editing constraints.

=cut

sub readline
{
    my $self = shift;

    my $line = "";
    my $pos = 0;
    my ($y, $x);
    while (my $char = $self->_main_win->getch())
    {
        if (($char eq "\ca") || ($char eq KEY_HOME()))
        {
            $pos = 0;
        }
        elsif (($char eq "\ce") || ($char eq KEY_END()))
        {
            $pos = length($line);
        }
        elsif ($char eq KEY_RIGHT())
        {
            if (++$pos > length($line))
            {
                $pos--;
            }
        }
        elsif ($char eq KEY_LEFT())
        {
            if (--$pos < 0)
            {
                $pos++;
            }
        }
        elsif ($char eq "\n")
        {
            $line .= "\n";
            return $line;
        }
        else
        {
            $line = substr($line, 0, $pos)
                  . $char
                  . substr($line, $pos)
                  ;

            $pos++;
        }

        getyx ($y, $x);
        $self->_main_win->addstr($y,0,$line);
    }
}


=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-term-eatline at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Term-Eatline>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::Eatline


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Term-Eatline>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Term-Eatline>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Term-Eatline>

=item * Search CPAN

L<http://search.cpan.org/dist/Term-Eatline>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11 Licence
( L<http://www.opensource.org/licenses/mit-license.php> )

=cut

1; # End of Term::Eatline
