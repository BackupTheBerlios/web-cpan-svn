# This is an assisting module. It makes sure Test::More is present, and if not
# gracefully exists. Otherwise it behaves the same as Test::More.
# 

package CondTestMore;

use vars qw(@ISA);

@ISA=qw(Test::More);

BEGIN
{
    eval {
       require Test::More;
    };
    if ($@)
    {
        warn "You don't have Test::More. Terminating";
        exit 0;
    }
}

1;
