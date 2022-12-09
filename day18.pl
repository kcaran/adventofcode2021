#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use day18;

my $input_data = $ARGV[0] || '[[[[[9,8],1],2],3],4]';

if ($input_data =~ /^\[/) {
  my $number = Pair->new( $input_data );
  my $reduced = $number->reduce();
  print $reduced->print(), "\n";
  exit;
 }

my @pairs = path( $input_data )->lines_utf8( { chomp => 1 } );
my $sum = Pair->new( shift @pairs )->reduce();
for my $p (@pairs) {
  $sum = Pair->new( "[" . $sum->print() . ",$p]" )->reduce();
  print $sum->print(), "\n";
 }

print "The final sum is ", $sum->print(), "\n";
print "The final magnitude is ", $sum->magnitude(), "\n";

exit;
