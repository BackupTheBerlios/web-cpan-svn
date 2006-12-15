package Shlomif::MiniReporter::FetchQuery;

use strict;
use warnings;

use base 'Shlomif::MiniReporter::HelperObj';

__PACKAGE__->mk_accessors(qw(
    _all_records
    field_names
    groups
    _id
    _max_num_records
    query
    rows
    _status_value
));

sub _initialize
{
    my ($self, $args) = @_;
    $self->SUPER::_initialize($args);

    $self->_status_value($args->{status_value});
    $self->_max_num_records($args->{max_num_records});
    $self->_id($args->{id});
    $self->_all_records($args->{all_records});

    $self->_construct_query($args);

    # my $sth = $self->main()->_get_dbh()->prepare($self->query());

    # $sth->execute();

    # $self->rows($sth->fetchall_arrayref());

    return 0;
}

sub _get_status_val
{
    my $self = shift;

    return
        defined($self->_status_value()) ?
            $self->_status_value() :
            $self->main->_get_active_status_value()
            ;
}

sub _get_status_cond
{
    my ($self) = @_;

    return "status=" . $self->_get_status_val();
}

sub _get_where_clause
{
    my $self = shift;
    my $args = shift;
    my $extra_conds = shift || [];

    # TODO - check if main->_get_status_cond is used elsewhere.
    my @conds = ($self->_get_status_cond($args), @$extra_conds);

    return "WHERE " . join(" AND ", @conds);
}

sub _get_limit_clause
{
    my $self = shift;

    my $num = $self->_max_num_records();

    return ( defined($num) ? " LIMIT $num " : "" );
}

sub _construct_query
{
    my ($self, $args) = @_;

    my $field_names = $self->main->get_field_names();
    push @$field_names, ('status');

    my $where_clause = 
        $self->_get_where_clause(
            $args,
            $self->_get_fetch_where_clause_conds($args)
        );


    my $query_str = "SELECT " . join(", ", @$field_names) .
                    " FROM " . $self->main->config()->{'table_name'} .
    		" " . $where_clause .
    		" ORDER BY " . ($self->main->config()->{'order_by'} || "id DESC") .
            $self->_get_limit_clause();

    $self->query($query_str);
    $self->field_names($field_names);
    $self->groups(
        defined($self->main->_group_by_field()) ?
            $self->_sanitize_groups(
                $self->_get_fetch_groups($args)
            ) :
            [{id => "All", display => "All"},]
        );

    return;
}

sub _get_fetch_where_clause_conds
{
    my ($self, $args) = @_;

    if (defined($self->_id))
    {
        return ["id=" . $self->_id]
    }
    elsif ($self->_all_records())
    {
        return [];
    }
    else
    {
        return $self->_get_search_conds($args);
    }
}

sub _get_search_conds
{
    my ($self, $args) = @_;

    my $keyword = $args->{'keyword'} || "";

    if ($keyword =~ /^\s*$/)
    {
        return [];
    }
    else
    {
        return [ "(" . 
            join(" OR ", @{$self->_get_search_clauses($keyword)}).  ")" 
        ];
    }
}

sub _get_search_clauses
{
    my ($self, $keyword) = @_;

    # Avoid %'s because the keyword is used in a LIKE query in which
    # it can cause wildcard complexity attacks
    $keyword =~ tr/%//d;

    my $query = $self->main->_get_dbh()->quote("%${keyword}%");

    return [map {"($_->{sql} LIKE $query)" } $self->main->get_fields()];
}

sub _get_fetch_groups
{
    my ($self, $args) = @_;

    my $group = $args->{'group_choice'} || "";

    my $all_groups = sub { return $self->main->_get_group_list() };

    if (defined($self->_id))
    {
        # Doesn't matter much.
        return [];
    }
    elsif ($self->_all_records())
    {
        return $all_groups->();
    }
    else
    {
        return +($group eq "All") ? $all_groups->() : [ $group ];
    }
}

sub _sanitize_groups
{
    my ($self, $groups) = @_;

    my %map = (map { $_->{id} => 1} @{$self->main->_get_group_list()});

    return [grep { exists($map{$_->{id}}) } @$groups];
}
1;
