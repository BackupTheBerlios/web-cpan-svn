package WWW::BooksTracker::WWW::Form;

use base 'WWW::Form';

sub getFieldInputTdHTML
{
    return "<td class=\"value\">";
}

sub getFieldLabelTdHTML
{
    return "<td class=\"key\">";
}

1;
