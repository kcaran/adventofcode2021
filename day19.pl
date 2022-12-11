#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Sensor;

 sub new {
  my ($class) = @_;
  my $self = {
    beacons => [],
  };

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input19.txt';
my @sensors;
my $sensor;
for my $line (Path::Tiny::path( $input_file )->lines( { chomp => 1 } )) {
  next unless ($line);
  if ($line =~ /scanner/) {
    push @sensors, $sensor if ($sensor);
    $sensor = Sensor->new();
   }
  else {
    my ($x, $y, $z) = split( ',', $line );
    push @{ $sensor->{ beacons } }, [$x, $y, $z];
   }
 }
push @sensors, $sensor if ($sensor);

exit;
