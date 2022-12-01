#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input03.txt';

my @values = path( $input_file )->lines( { chomp => 1 } );

my @bits;

sub calc_bits {
  my ($values, $bit) = @_;

  my $bits = [ 0, 0 ];
  for my $num (@{ $values }) {
    my $bit = substr( $num, $bit, 1 );
    $bits->[$bit]++;
   }

  return $bits;
 }

for my $num (@values) {
  my @digits = split( '', $num );
  for my $i (0 .. $#digits) {
    my $bit = $digits[$i];
    $bits[$i][$bit]++;
   }
 }

my $gamma = '0b';
my $epsilon = '0b';
for my $b (@bits) {
  $gamma .= ($b->[1] >= $b->[0]) ? '1' : '0';
  $epsilon .= ($b->[1] >= $b->[0]) ? '0' : '1';
 }
$gamma = oct( $gamma );
$epsilon = oct( $epsilon );

print "The product of the gamma and epsilon is $gamma * $epsilon = ", $gamma * $epsilon, "\n";

# Save off the values for the second part
my @co2 = @values;

my $idx = 0;
while (@values > 1) {
  my $bits = calc_bits( \@values, $idx );
  my $max = $bits->[1] >= $bits->[0] ? 1 : 0;
  my @new_values = ();
  for my $val (@values) {
    push @new_values, $val if (substr( $val, $idx, 1 ) == $max);
   }
  @values = @new_values;
  $idx++;
 }

$idx = 0;
while (@co2 > 1) {
  my $bits = calc_bits( \@co2, $idx );
  my $min = $bits->[0] <= $bits->[1] ? 0 : 1;
  my @new_values = ();
  for my $val (@co2) {
    push @new_values, $val if (substr( $val, $idx, 1 ) == $min);
   }
  @co2 = @new_values;
  $idx++;
 }

my $oxy = oct( '0b' . $values[0] );
my $scrub = oct( '0b' . $co2[0] );

print "The life support rating is $oxy * $scrub = ", $oxy * $scrub, "\n";

exit;
