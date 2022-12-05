#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Paper;

 sub print {
   my ($self) = @_;

   my $max_y = @{ $self->{ paper } } - 1;
   my $max_x = @{ $self->{ paper }[0] } - 1;
   for my $y (0 .. $max_y) {
     my $line = '';
     for my $x (0 .. $max_x) {
        $line .= $self->{ paper }[$y][$x] ? '#' : '.';
       }
      print "$line\n";
     }

   return;
  }

 sub dots {
   my ($self) = @_;

   my $dots = 0;
   my $max_y = @{ $self->{ paper } } - 1;
   my $max_x = @{ $self->{ paper }[0] } - 1;
   for my $y (0 .. $max_y) {
     for my $x (0 .. $max_x) {
        $dots++ if ($self->{ paper }[$y][$x]);
       }
     }

   return $dots;
  }

 sub fold {
   my ($self) = @_;

   my $fold = shift @{ $self->{ folds } } || return;

   my $count = 0;
   if ($fold->{ axis } eq 'y') {
     my $max_x = @{ $self->{ paper }[0] } - 1;
     while ($count < $fold->{ line }) {
       my $row = pop @{ $self->{ paper } };
       for my $x (0 .. $max_x) {
         $self->{ paper }[$count][$x] = 1 if ($row->[$x]);
        }
       $count++;
      }
     # Remove folded row
     pop @{ $self->{ paper } };
    }
   else {
     my $max_y = @{ $self->{ paper } } - 1;
     while ($count < $fold->{ line }) {
       for my $y (0 .. $max_y) {
         my $x = pop @{ $self->{ paper }[$y] };
         $self->{ paper }[$y][$count] = 1 if ($x);
        }
       $count++;
      }
     # Remove folded column
     for my $y (0 .. $max_y) {
       pop @{ $self->{ paper }[$y] };
      }
    }

   return $self;
 }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    paper => [],
    folds => [],
  };

  my $max_x = 0;
  my $max_y = 0;
  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    $line =~ s/\s+$//;
    next unless ($line);
    if ($line =~ /^fold along ([xy])=(\d+)/) {
      push @{ $self->{ folds } }, { axis => $1, line => $2 };
     }
    else {
      my ($x, $y) = split( ',', $line );
      $self->{ paper }[$y][$x] = 1;
      $max_x = $x if ($x > $max_x);
      $max_y = $y if ($y > $max_y);
     }
   }

  for my $y (0 .. $max_y) {
    for my $x (0 .. $max_x) {
      $self->{ paper }[$y][$x] ||= 0;
     }
    }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input13.txt';

my $paper = Paper->new( $input_file );
$paper->fold();
print "There are ", $paper->dots(), " dots after one fold.\n";

while ($paper->fold()) {};

$paper->print();

exit;
