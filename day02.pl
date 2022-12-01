#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input02.txt';

{ package Position;

 sub move {
   my ($self, $command) = @_;
   my ($dir, $num) = ($command =~ /^(\S+)\s(\d+)$/);

   $self->{ x1 } += $num if ($dir eq 'forward');
   $self->{ y1 } -= $num if ($dir eq 'up');
   $self->{ y1 } += $num if ($dir eq 'down');

   # Part 2
   $self->{ aim } -= $num if ($dir eq 'up');
   $self->{ aim } += $num if ($dir eq 'down');
   if ($dir eq 'forward') {
     $self->{ hor } += $num;
     $self->{ depth } += $self->{ aim } * $num;
    }

   return $self;
 }

 sub new {
  my ($class) = @_;
  my $self = {
    x1 => 0,
    y1 => 0,
    hor => 0,
    aim => 0,
    depth => 0,
  };

  bless $self, $class;
  return $self;
 }
}

my @lines = path( $input_file )->lines( { chomp => 1 } );
my $pos = Position->new();

for my $go (@lines) {
  $pos->move( $go );
 }

print "The part 1 position product is ", $pos->{ x1 } * $pos->{ y1 }, "\n";
print "The part 2 position product is ", $pos->{ depth } * $pos->{ hor }, "\n";

exit;
