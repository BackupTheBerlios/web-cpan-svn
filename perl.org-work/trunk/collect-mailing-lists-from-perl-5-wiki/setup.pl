#!/usr/bin/perl

use strict;
use warnings;

use Common;

if (system("mysqladmin", "create", Common::get_mysql_db_name()))
{
    die "Could not create mysql database!";
}
    
