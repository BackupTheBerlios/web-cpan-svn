package WWW::BooksTracker::Const;

use strict;
use warnings;

use base 'Exporter';

use constant
{
    STATUS_ACTIVE => 0,
    STATUS_PENDING => 1,
    STATUS_DISABLED => 2,
    STATUS_DELETED => 2,
};

our @EXPORT_OK = ('STATUS_DISABLED', 'STATUS_ACTIVE', 
'STATUS_PENDING', 'STATUS_DELETED');

1;

