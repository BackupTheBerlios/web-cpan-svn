package Catalyst::Plugin::SanitizeUrl;

use strict;
use warnings;

our $VERSION = '0.2.0';

use base 'Catalyst::Plugin::SanitizeUrl::PrepAction';

sub get_action_path
{
    my $c    = shift;
    my $path = $c->req->path;
    return [ split /\//, $c->req->path, (-1) ];
}

1;

__END__
=head1 NAME

Catalyst::Plugin::SanitizeUrl - Make sure Catalyst does not ignore trailing slashes

=head1 SYNOPSIS

    use Catalyst 'SanitizeUrl';

=head1 DESCRIPTION

This plugin makes sure Catalyst is not agnostic to trailing slashes in the 
URLs passed to it by the user agent.

By default Catalyst will treat the following URLs:

    http://localhost:3000/one/two

And

    http://localhost:3000/one/two/

As the same, even though user agents treat them differently as far as relative
URLs are concerned.

This plugin will cause the trailing slashes to be included in the Catalyst
path.

=head2 EXTENDED METHODS

=head3 prepare

Sets up $c->{form}

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHOR

Shlomi Fish, C<shlomif@iglu.org.il>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the terms of the MIT X11 license.

(Just note that the ::PrepAction module is derived from the Catalyst code 
itself and so is distributed under the same terms as Perl itself).

=cut

