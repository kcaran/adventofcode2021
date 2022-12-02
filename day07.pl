#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Crabs;

 sub fuel {
   my ($self, $steps) = @_;

   return 0 unless ($steps > 0);

   unless ($self->{ fuel }{ $steps }) {
     $self->{ fuel }{ $steps } = $self->fuel( $steps - 1 ) + $steps;
    }

   return $self->{ fuel }{ $steps };
  }

 sub move {
  my ($self, $to, $max) = @_;

  my $fuel = 0;
  for my $pos (keys %{ $self->{ points } }) {
    my $steps = abs( $to - $pos );
    $fuel += $self->fuel( $steps ) * $self->{ points }{ $pos };
    return if ($max && $fuel > $max);
   }

  return $fuel;
 }

 sub align {
  my ($self) = @_;

  my $min = 0;
  for my $pos (0 .. $self->{ max }) {
    my $fuel = $self->move( $pos, $min );
    $min = $fuel if ($fuel && (!$min || $fuel < $min));
   }

  return $min;
 }

 sub move_1 {
  my ($self, $to, $max) = @_;

  my $fuel = 0;
  for my $pos (keys %{ $self->{ points } }) {
    $fuel += abs( $to - $pos ) * $self->{ points }{ $pos };
    return if ($fuel > $max);
   }

  return $fuel;
 }

 sub align_1 {
  my ($self) = @_;

  my $min = $self->{ max } * $self->{ num_crabs };
  for my $pos (0 .. $self->{ max }) {
    my $fuel = $self->move_1( $pos, $min );
    $min = $fuel if ($fuel && $fuel < $min);
   }

  return $min;
 }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    points => {},
    max => 0,
    num_crabs => 0,
    fuel => { 1 => 1 },
  };

  my @values = split( ',', Path::Tiny::path( $input_file )->slurp_utf8( { chomp => 1 } ) );
  for my $val (@values) {
    $self->{ points }{ $val }++;
    $self->{ max } = $val if ($self->{ max } < $val);
    $self->{ num_crabs }++;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input07.txt';
my $crabs = Crabs->new( $input_file );

print "The fuel spent to align in part 1 is ", $crabs->align_1(), "\n";

print "The fuel spent to align in part 2 is ", $crabs->align(), "\n";

exit;
