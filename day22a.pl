#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use List::Util qw( max min );
use Path::Tiny;

my @bound = (-50, 50, -50, 50, -50, 50);

{ package Cubes;

 sub init {
  my ($self, $cmd, $bound) = @_;

  my ($state) = ($cmd =~ /^(\S+)/);
  my (@ranges) = ($cmd =~ /(?:[xyz]=([^.]+)\.\.([^.,]+),?)/g);

  return $self if ($ranges[0] > $bound->[1]);
  return $self if ($ranges[1] < $bound->[0]);
  return $self if ($ranges[2] > $bound->[3]);
  return $self if ($ranges[3] < $bound->[2]);
  return $self if ($ranges[4] > $bound->[5]);
  return $self if ($ranges[5] < $bound->[4]);

  @ranges = map { ($ranges[$_*2] < $bound->[$_*2]) ? $bound->[$_*2] : $ranges[$_*2], ($ranges[$_*2+1] > $bound->[$_*2+1]) ? $bound->[$_*2+1] : $ranges[$_*2+1] } 0 .. 2;
  for my $x ($ranges[0] .. $ranges[1]) {
    for my $y ($ranges[2] .. $ranges[3]) {
      for my $z ($ranges[4] .. $ranges[5]) {
         if ($state eq 'on' && !$self->{ cubes }{ "$x,$y,$z" }) {
           $self->{ cubes }{ "$x,$y,$z" } = 1;
           $self->{ count }++;
          }
         if ($state eq 'off' && $self->{ cubes }{ "$x,$y,$z" }) {
           $self->{ cubes }{ "$x,$y,$z" } = 0;
           $self->{ count }--;
          }
        }
       }
     }

  return $self;
 }

 sub new {
  my ($class, $input) = @_;
  my $self = {
    cubes => {},
    count => 0,
  };
  bless $self, $class;

  return $self;
 }
}

my $min = [ -50, 50, -50, 50, -50, 50 ];
my $input_file = $ARGV[0] || 'input22.txt';
my $cubes = Cubes->new();
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  $cubes->init( $line, $min );
 }

print "There are $cubes->{ count } cubes lit.\n";

exit;
