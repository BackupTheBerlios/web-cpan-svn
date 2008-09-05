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
    _curr_line
    _is_running
    _main_win
    _num_chars_to_trim_from_end
    _pos
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


    $self->_is_running(0);
}

=head2 $eatline->start_running()

Actually initialize the screen, which may take over it.

=cut

sub start_running
{
    my $self = shift;

    if ($self->_is_running())
    {
        return;
    }

    my $main_win = Curses->new();

    $self->_main_win($main_win);
    $self->_main_win->keypad(1);
    $self->_num_chars_to_trim_from_end(0);

    initscr();
    noecho();

    $self->_is_running(1);

    return;
}

=head2 $eatline->stop_running()

Actually finalize the screen.

=cut

sub stop_running
{
    my $self = shift;
    
    if (! $self->_is_running())
    {
        return;
    }

    endwin();
    $self->_main_win(undef);

    $self->_is_running(0);
    return;
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

    $self->stop_running();

    return;
}

sub _inc_num_chars_to_trim_from_end
{
    my $self = shift;

    $self->_num_chars_to_trim_from_end($self->_num_chars_to_trim_from_end()+1);

    return;
}

sub _fetch_num_chars_to_trim_from_end
{
    my $self = shift;

    my $ret = $self->_num_chars_to_trim_from_end();

    $self->_num_chars_to_trim_from_end(0);

    return $ret;
}

sub _line_len
{
    my $self = shift;

    return length($self->_curr_line());
}

sub _map_keys
{
    my ($keys, $action) = @_;
    return (map { $_ => $action } @$keys);
}

sub _get_keyboard_map
{
    my $self = shift;

    return
    {
        _map_keys(["\ca", KEY_HOME()] => "home"),
        _map_keys(["\ce", KEY_END()] => "end"),
        # These backspace settings are based on the hacks in 
        # lib/Curses/UI/Common.pm in get_key().
        _map_keys(["\cH", chr(127), KEY_BACKSPACE()] => "backspace"),
        _map_keys([KEY_DC()] => "delete"),
        _map_keys(["\cf", KEY_RIGHT()] => "right"),
        _map_keys(["\cb", KEY_LEFT()] => "left"),
        _map_keys(["\n"] => "enter"),
    };
}

sub _key_home
{
    my $self = shift;

    return $self->_move_to_start_line();
}

sub _key_end
{
    my $self = shift;

    return $self->_move_to_end_of_line();
}

sub _key_right
{
    my $self = shift;

    return $self->_inc_pos();
}

sub _key_left
{
    my $self = shift;

    return $self->_dec_pos();
}

sub _key_enter
{
    my $self = shift;

    return { action => "return", };
}

sub _key_backspace
{
    my $self = shift;

    return $self->_remove_char_before();
}

sub _key_delete
{
    my $self = shift;

    return $self->_remove_this_char();
}

sub _update_line_display
{
    my $self = shift;

    my ($y, $x);
    getyx ($y, $x);
    if (my $n = $self->_fetch_num_chars_to_trim_from_end())
    {
        $self->_main_win->move(
            $y, 
            $self->_line_len() - $n,
        );
        $self->_main_win->clrtoeol();
    }
    $self->_main_win->addstr($y,0,$self->_curr_line());
    $self->_main_win->move($y, $self->_pos());

    return;
}

=head2 $eatline->readline()

Reads a line from the terminal based on the editing constraints.

=cut

sub readline
{
    my $self = shift;

    $self->start_running();

    my $keyboard_map = $self->_get_keyboard_map();

    $self->_curr_line("");
    $self->_move_to_start_line();

    $self->_main_win->clrtoeol();

    while (my $char = $self->_main_win->getch())
    {
        my $verdict;
        if (exists($keyboard_map->{$char}))
        {
            $verdict = $self->can("_key_" . $keyboard_map->{$char})->($self);
        }
        else
        {
            $self->_insert_char(
                $char
            );
        }

        if (ref($verdict) eq "HASH")
        {
            if ($verdict->{action} eq "return")
            {
                return $self->_curr_line() . "\n";
            }
        }

        $self->_update_line_display();
    }
}

=head2 $eatline->_set_pos($idx)

Sets the position in the string.

=cut

sub _set_pos
{
    my ($self, $idx) = @_;

    $self->_pos($idx);

    return;
}

=head2 $eatline->_move_to_start_line()

Moves to the beginning of the line.

=cut

sub _move_to_start_line
{
    my $self = shift;

    return $self->_set_pos(0);
}

=head2 $eatline->_move_to_end_of_line()

Moves to the end of the line.

=cut

sub _move_to_end_of_line
{
    my $self = shift;

    return $self->_set_pos($self->_line_len());
}

sub _is_at_end_of_line
{
    my $self = shift;

    return ($self->_pos() == $self->_line_len());
}

sub _is_at_start_of_line
{
    my $self = shift;

    return ($self->_pos() == 0);
}

sub _inc_pos
{
    my $self = shift;

    if ($self->_is_at_end_of_line())
    {
        # Do nothing.
    }
    else
    {
        $self->_set_pos($self->_pos()+1);
    }

    return;
}

sub _dec_pos
{
    my $self = shift;

    if ($self->_is_at_start_of_line())
    {
        # Do nothing.
    }
    else
    {
        $self->_set_pos($self->_pos()-1);
    }

    return;
}

sub _insert_char
{
    my ($self, $char) = @_;

    my $line = $self->_curr_line();

    $line = substr($line, 0, $self->_pos())
          . $char
          . substr($line, $self->_pos())
          ;

    $self->_curr_line($line);

    $self->_inc_pos();

    return;
}

sub _remove_char_before
{
    my $self = shift;

    my $line = $self->_curr_line();

    if ($self->_is_at_start_of_line())
    {
        return;
    }

    substr($line, $self->_pos()-1, 1) = "";
    $self->_dec_pos();
    $self->_inc_num_chars_to_trim_from_end();

    $self->_curr_line($line);

    return;
}


sub _remove_this_char
{
    my $self = shift;

    my $line = $self->_curr_line();

    if ($self->_is_at_end_of_line())
    {
        return;
    }

    substr($line, $self->_pos(), 1) = "";
    $self->_inc_num_chars_to_trim_from_end();

    $self->_curr_line($line);

    return;
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
