package CondTestMore;

use base 'Test::More';

use Test::More;

BEGIN
{
*EXPORT = \@Test::More::EXPORT;
}

1;
