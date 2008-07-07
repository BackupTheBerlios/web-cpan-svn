package Text::Qantor::Parser::Elem::ParaList;

use strict;
use warnings;


=head1 NAME

Text::Qantor::Parser::Elem::ParaList - a Qantor list-of-paragraphs.

=head1 VERSION

Version v0.0.1

=cut

use version; our $VERSION = qv('0.0.1');

=head1 DESCRIPTION

B<FILL IN>

=head1 FUNCTIONS

=head2 my $qantor = Text::Qantor::Parser::Elem::ParaList->new(\%args)

Initializes a new one.

=cut

use base 'Text::Qantor::Parser::Elem::Base';

__PACKAGE__->mk_accessors(qw(_list));

sub _init
{
    my ($self, $args) = @_;

    if ($args->{para})
    {
        $self->_list([$args->{para}]);
    }

    return;
}

=head2 $para_list->append($other_para_list)

Adds a copy of the paragraphs in $other_para_list to $para_list 

=cut

sub append
{
    my ($self, $other) = @_;

    push @{$self->_list()}, @{$other->_list()};

    return;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-qantor at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Qantor>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Qantor::Parser::Elem::ParaList

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Qantor>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Qantor>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Qantor>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Qantor>

=back


=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: mit

=cut

1;
