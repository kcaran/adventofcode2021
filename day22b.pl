#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my @bound = (-50, 50, -50, 50, -50, 50);

{ package Cubes;

use List::Util qw( max min );

 sub count {
  my ($self) = @_;
  my $count = 0;

  for my $cube (@{ $self->{ cubes } }) {
    $count += ($cube->[1] - $cube->[0] + 1)
				* ($cube->[3] - $cube->[2] + 1)
				* ($cube->[5] - $cube->[4] + 1);
   }

  return $count;
 }

 sub intersect {
  my ($self, $cube, $new) = @_;

  my $split = [];

  return [ $cube ] if ($cube->[0] > $new->[1]);
  return [ $cube ] if ($cube->[1] < $new->[0]);
  return [ $cube ] if ($cube->[2] > $new->[3]);
  return [ $cube ] if ($cube->[3] < $new->[2]);
  return [ $cube ] if ($cube->[4] > $new->[5]);
  return [ $cube ] if ($cube->[5] < $new->[4]);

  my $x_in = [ max( $cube->[0], $new->[0] ), min( $new->[1], $cube->[1] ) ];
  my $y_in = [ max( $cube->[2], $new->[2] ), min( $new->[3], $cube->[3] ) ];
  my $z_in = [ max( $cube->[4], $new->[4] ), min( $new->[5], $cube->[5] ) ];
  if ($cube->[0] < $x_in->[0]) {
    # Left x outside of new
    push @{ $split }, [ $cube->[0], $x_in->[0] - 1, @{ $cube }[2..5] ];
   }

  if ($cube->[1] > $x_in->[1]) {
    # Right x outside of new
    push @{ $split }, [ $x_in->[1] + 1, $cube->[1], @{ $cube }[2..5] ];
   }

  if ($cube->[2] < $y_in->[0]) {
    # Left x outside of new
    push @{ $split }, [ $x_in->[0], $x_in->[1], $cube->[2], $y_in->[0] - 1, @{ $cube }[4..5] ];
   }

  if ($cube->[3] > $y_in->[1]) {
    # Right x outside of new
    push @{ $split }, [ $x_in->[0], $x_in->[1], $y_in->[1] + 1, $cube->[3], @{ $cube }[4..5] ];
   }

  if ($cube->[4] < $z_in->[0]) {
    # Left x outside of new
    push @{ $split }, [ $x_in->[0], $x_in->[1], $y_in->[0], $y_in->[1], $cube->[4], $z_in->[0] - 1 ];
   }

  if ($cube->[5] > $z_in->[1]) {
    # Right x outside of new
    push @{ $split }, [ $x_in->[0], $x_in->[1], $y_in->[0], $y_in->[1], $z_in->[1] + 1, $cube->[5] ];
   }

  return $split;
 }

 sub init {
  my ($self, $cmd, $ranges) = @_;

  my ($state) = ($cmd =~ /^(\S+)/);
  my (@ranges) = ($cmd =~ /(?:[xyz]=([^.]+)\.\.([^.,]+),?)/g);
  my $new = [ @ranges ];

  # Split up the existing cubes from the new one
  my $cubes = [];
  for my $cube (@{ $self->{ cubes } }) {
    push @{ $cubes }, @{ $self->intersect( $cube, $new ) };
   }

  push @{ $cubes }, $new if ($state eq 'on');

  $self->{ cubes } = $cubes;

  return $self;
 }

 sub new {
  my ($class, $input) = @_;
  my $self = {
    cubes => [],
  };
  bless $self, $class;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input22.txt';
my $cubes = Cubes->new();
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  $cubes->init( $line );
 }

print "There are ", $cubes->count(), " cubes lit.\n";

exit;
