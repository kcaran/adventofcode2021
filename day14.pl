#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Polymer;

 sub score {
   my ($self) = @_;

   my %chars;

   # Seed with the initial character (which won't change)
   $chars{ substr( $self->{ template }, 0, 1 ) } = 1;

   for my $pair (keys %{ $self->{ pairs } }) {
     my $second_char = substr( $pair, 1, 1 );
     $chars{ $second_char } += $self->{ pairs }{ $pair };
    }
   my @sorted_keys = sort { $chars{ $a } <=> $chars{ $b } } keys %chars;

   return $chars{ $sorted_keys[-1] } - $chars{ $sorted_keys[0] };
  }

 sub insert {
   my ($self, $count) = @_;

   while ($count) {
     my %next;

     for my $pair (keys %{ $self->{ pairs } }) {
       my $mid = $self->{ rules }{ $pair };
       my $new1 = substr( $pair, 0, 1 ) . $mid;
       my $new2 = $mid . substr( $pair, 1, 1 );
       $next{ $new1 } += $self->{ pairs }{ $pair };
       $next{ $new2 } += $self->{ pairs }{ $pair };
      }

     $self->{ pairs } = { %next };
     $count--;
    }

   return $self;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    template => '',
    rules => {},
    pairs => {},
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  $self->{ template } = shift @lines;
  for my $i (0 .. length( $self->{ template } ) - 2) {
    my $pair = substr( $self->{ template }, $i, 2 );
    $self->{ pairs }{ $pair }++;
   }


  for my $line (@lines) {
    $line =~ s/\s+$//;
    next unless ($line);
    if ($line =~ /^(\S+) -> (\S+)/) {
      $self->{ rules }{ $1 } = $2;
     }
    }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input14.txt';
my $steps = $ARGV[1] || 10;
my $template = Polymer->new( $input_file );
$template->insert( $steps );

print "The score after $steps steps is ", $template->score(), "\n";

exit;
