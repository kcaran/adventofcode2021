#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input01.txt';

my @lines = path( $input_file )->lines( { chomp => 1 } );

sub part1 {
  # Don't count the initial measurement
  my $depth = 0;
  my $increases = -1;
  for my $m (@lines) {
    $increases++ if ($m > $depth);
    $depth = $m;
   }

  print "The number of larger depth increases is $increases\n";
 }

sub part2 {
  # Don't count the initial measurement
  my $depth = 0;
  my $increases = -1;
  for my $i (2..$#lines) {
     my $new_depth = $lines[$i] + $lines[$i-1] + $lines[$i-2];
     $increases++ if ($new_depth > $depth);
     $depth = $new_depth;
   }
  print "The number of larger window depth increases is $increases\n";
 }

part1();
part2();

exit;
