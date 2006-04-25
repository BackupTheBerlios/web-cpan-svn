package CGI::Application::NetNewsIface::Cache::DBI;

use strict;
use warnings;

use DBI;

=head1 NAME

CGI::Application::NetNewsIface::Cache::DBI - an internally used class to
form a fast cache of the NNTP data.

=head1 SYNOPSIS

    use CGI::Application::NetNewsIface::Cache::DBI;

    my $cache = CGI::Application::NetNewsIface::Cache::DBI->new(
        {
            'nntp' => $nntp,
            'dsn' => "dbi:SQLite:dbname=foo.sqlite",
        },
    );

=head1 FUNCTIONS

=head2 new({ %params })

Constructs a new cache object. Accepts a single argument - a hash ref with
named parameters. Required parameters are:

=over 4

=item 'nntp'

A handle to the Net::NNTP object that will be used for querying the NNTP
server.

=item 'dsn'

The DBI 'dsn' for the DBI initialization.

=back

=cut

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;

    $self->_initialize(@_);

    return $self;
}

sub _initialize
{
    my $self = shift;
    my $args = shift;

    $self->{'nntp'} = $args->{'nntp'};

    $self->{'dbh'} = DBI->connect($args->{'dsn'}, "", "");

    return 0;
}

=head2 $cache->select($group)

Selects the newsgroup $group.

=cut

sub select
{
    my ($self, $group) = @_;
    $self->{'group'} = $group;
    return $self->_update_group();
}

sub _update_group
{
    my $self = shift;
    
    my $group = $self->{'group'};
    my @info = $self->{'nntp'}->group($group);
    if (! @info)
    {
        die "Unknown group \"$group\".";
    }
    return 0;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@iglu.org.il> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-cgi-application-netnewsiface@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CGI-Application-NetNewsIface>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1;

