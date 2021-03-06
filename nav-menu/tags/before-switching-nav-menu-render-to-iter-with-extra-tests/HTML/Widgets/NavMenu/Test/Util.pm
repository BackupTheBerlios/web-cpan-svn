package HTML::Widgets::NavMenu::Test::Util;

use strict;

use Exporter;
use vars qw(@ISA);
@ISA=qw(Exporter);

use vars qw(@EXPORT);

@EXPORT = qw(compare_string_arrays);

sub compare_string_arrays
{
    my $arr1 = shift;
    my $arr2 = shift;
    my $len_cmp = (@$arr1 <=> @$arr2);
    if ($len_cmp)
    {
        print STDERR "Len is not the same: " . scalar(@$arr1) . " vs. " . scalar(@$arr2) . "\n";
        return $len_cmp;
    }
    my $i;
    for($i=0;$i<@$arr1;$i++)
    {
        my $item_cmp = $arr1->[$i] cmp $arr2->[$i];
        if ($item_cmp)
        {
            print STDERR "Item[$i] is not the same:\narr1: $arr1->[$i]\narr2: $arr2->[$i]\n";
            return $item_cmp;
        }
    }
    return 0;
}

1;
