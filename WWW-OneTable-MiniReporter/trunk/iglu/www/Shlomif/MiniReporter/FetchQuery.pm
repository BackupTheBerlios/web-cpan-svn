package Shlomif::MiniReporter::FetchQuery;

use strict;
use warnings;

use base 'Shlomif::MiniReporter::HelperObj';

__PACKAGE__->mk_accessors(qw(
    _all_records
    field_names
    _group_choice
    groups
    _id
    _keyword
    _max_num_records
    query
    rows
    _status_value
    _sth
));

sub _attrs_to_assign
{
    return 
    [qw(
        all_records
        group_choice
        id
        keyword
        max_num_records
        status_value
    )];
}

sub _initialize
{
    my ($self, $args) = @_;
    $self->SUPER::_initialize($args);

    foreach my $attr (@{$self->_attrs_to_assign()})
    {
        $self->set("_$attr", $args->{$attr});
    }

    $self->_construct_query();

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

    return $self->_tmap("status") . "=" . $self->_get_status_val();
}

sub _get_text_table_cond
{
    my $self = shift;

    return $self->_tmap("id") . "=" . $self->_text_table() . ".id";
}

sub _get_where_clause
{
    my $self = shift;
    my $extra_conds = shift || [];

    my @conds = 
    (
        $self->_get_status_cond(), 
        $self->_get_text_table_cond(), 
        @$extra_conds
    );

    return "WHERE " . join(" AND ", @conds);
}

sub _get_limit_clause
{
    my $self = shift;

    my $num = $self->_max_num_records();

    return ( defined($num) ? " LIMIT $num " : "" );
}

sub _table_name
{
    my $self = shift;

    return $self->main->_table_name;
}

sub _tmap_list
{
    my ($self, $list) = @_;

    my $table_name = $self->_table_name;

    return [map { "${table_name}.$_" } @$list];
}

sub _tmap
{
    my ($self, $v) = @_;

    return $self->_tmap_list([$v])->[0];
}

sub _construct_query
{
    my ($self) = @_;

    my $field_names = $self->main->get_field_names();
    push @$field_names, ('status');

    my $where_clause = 
        $self->_get_where_clause(
            $self->_get_fetch_where_clause_conds()
        );

    my $table_name = $self->_table_name;

    my $query_str = "SELECT " . 
            join(", ", @{$self->_tmap_list($field_names)}) .
            " FROM $table_name, " . $self->_text_table() .
            " " . $where_clause .
    		" ORDER BY " . ($self->main->config()->{'order_by'} || $self->_tmap("id") . "DESC") .
            $self->_get_limit_clause();

    $self->query($query_str);
    $self->field_names($field_names);
    $self->groups(
        defined($self->main->_group_by_field()) ?
            $self->_sanitize_groups(
                $self->_get_fetch_groups()
            ) :
            [{id => "All", display => "All"},]
        );

    return;
}

sub _get_fetch_where_clause_conds
{
    my ($self) = @_;

    if (defined($self->_id))
    {
        return [$self->_table_name() . ".id=" . $self->_id]
    }
    elsif ($self->_all_records())
    {
        return [];
    }
    else
    {
        return $self->_get_search_conds();
    }
}

sub _get_search_conds
{
    my $self = shift;

    my $keyword = $self->_keyword() || "";

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

sub _text_table
{
    my $self = shift;

    return $self->main()->config()->{text_table_name};
}

sub _get_search_clauses
{
    my ($self, $keyword) = @_;

    # Avoid %'s because the keyword is used in a LIKE query in which
    # it can cause wildcard complexity attacks
    $keyword =~ tr/%//d;

    my @words = split(/\s+/, $keyword);

    my $text_table = $self->_text_table();

    return [
        map 
        {
            "${text_table}.mytext LIKE " .
            $self->_get_dbh()->quote('%'.$_.'%')
        }
        @words
    ];
}

sub _get_fetch_groups
{
    my ($self) = @_;

    my $group = $self->_group_choice() || "";

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

sub prepare_sth
{
    my $self = shift;

    my $sth = $self->_get_dbh()->prepare($self->query());

    $sth->execute();
    
    $self->_sth($sth);

    return;
}

sub fetch_row
{
    my $self = shift;

    return $self->_sth->fetchrow_arrayref;
}

sub detach
{
    my $self = shift;

    $self->SUPER::detach();

    $self->_sth(undef);
}

1;
