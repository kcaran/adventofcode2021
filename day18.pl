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
my $sum = Pair->new( $pairs[0] )->reduce();
for my $p (1 .. @pairs - 1) {
  $sum = Pair->new( "[" . $sum->print() . "," . $pairs[$p] . "]" )->reduce();
 }

print "The final sum is ", $sum->print(), "\n";
print "The final magnitude is ", $sum->magnitude(), "\n";

my $max = 0;
for my $i (0 .. @pairs - 1) {
  for my $j (0 .. @pairs - 1) {
    next if ($i == $j);
    $sum = Pair->new( "[" . $pairs[$i] . "," . $pairs[$j] . "]" )->reduce()->magnitude();
    $max = $sum if ($sum > $max);
    $j++;
   }
  $i++;
 }

print "The largest magnitude is $max\n";

exit;
