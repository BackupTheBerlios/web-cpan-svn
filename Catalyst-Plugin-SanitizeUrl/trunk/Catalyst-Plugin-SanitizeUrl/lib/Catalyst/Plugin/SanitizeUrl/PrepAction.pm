package Catalyst::Plugin::SanitizeUrl::PrepAction;

use strict;
use warnings;

our $VERSION = '0.2.0';

=head1 NAME

Catalyst::Plugin::SanitizeUrl::PrepAction  - A class to abstract functionality 
out of the prepare_action method.

=head1 SYNOPSIS

For internal use by L<Catalyst::Plugin::SanitizeUrl> .

=head2 $c->get_action_path

Calculate the path components for the action. Returns an array reference
containing the 

=cut

sub get_action_path {
    my $c    = shift;
    my $path = $c->req->path;
    return [ split /\//, $c->req->path ];
}

=head2 $c->prepare_action

Prepare action. This function is nearly identical to the one in Catalyst.pm
with the only difference is the extraction of the get_action_path() 
method. <sigh />

=cut


sub prepare_action {
    my $c    = shift;
    my $path;    
    my @path = @{$c->get_action_path};
    $c->req->args( \my @args );

    while (@path) {
        $path = join '/', @path;
        if ( my $result = ${ $c->get_action($path) }[0] ) {

            # It's a regex
            if ($#$result) {
                my $match    = $result->[1];
                my @snippets = @{ $result->[2] };
                $c->log->debug(
                    qq/Requested action is "$path" and matched "$match"/)
                  if $c->debug;
                $c->log->debug(
                    'Snippets are "' . join( ' ', @snippets ) . '"' )
                  if ( $c->debug && @snippets );
                $c->req->action($match);
                $c->req->snippets( \@snippets );
            }

            else {
                $c->req->action($path);
                $c->log->debug(qq/Requested action is "$path"/) if $c->debug;
            }

            $c->req->match($path);
            last;
        }
        unshift @args, pop @path;
    }

    unless ( $c->req->action ) {
        $c->req->action('default');
        $c->req->match('');
    }

    $c->log->debug( 'Arguments are "' . join( '/', @args ) . '"' )
      if ( $c->debug && @args );
}

=head1 SEE ALSO

L<Catalyst::Plugin::SanitizeUrl>

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

Modified by Shlomi Fish, C<shlomif@iglu.org.il> (All rights disclaimed).

=head1 LICENSE

This program is free software. You may copy or redistribute it under the same 
terms as Perl itself.

=cut

