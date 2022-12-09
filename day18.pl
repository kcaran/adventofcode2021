#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use day18;

my $input_data = $ARGV[0] || '[[[[[9,8],1],2],3],4]';

my $number = Pair->new( $input_data );

my $reduced = $number->reduce();

print $reduced->print(), "\n";

exit;
