#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

my $small = {
	'start' => 1,
	'end' => 1,
};

{ package Cave;

sub is_small {
  my ($next) = @_;

  # See if we've already checked
  return 0 if (($small->{ $next } || 0) < 0);
  return 1 if (($small->{ $next } || 0) > 0);

  my $test = ($next =~ /^[a-z]+$/) ? 1 : -1;
  $small->{ $next } = $test;

  return $test > 0 ? 1 : 0;
 }

 sub move {
   my ($self, $next) = @_;

   # Don't go back to start
   return if ($next eq 'start');

   my $small = is_small( $next );
   if ($small && $self->{ visited }{ $next }) {
     return if ($self->{ twice });
    }

   my $new = Storable::dclone( $self );
   $new->{ twice } = $next if ($small && $new->{ visited }{ $next });
   $new->{ position } = $next;
   $new->{ visited }{ $next } = 1 if ($small);
   push @{ $new->{ path } }, $next;

   return $new;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    paths => {},
    visited => { 'start' => 1 },
    position => 'start',
    path => [ 'start' ],
    twice => '',
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    my ($start, $end) = $line =~ /^([^-]+)-(.*)$/;
    push @{ $self->{ paths }{ $start } }, $end;
    push @{ $self->{ paths }{ $end } }, $start;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input12.txt';
my @caves = ( Cave->new( $input_file ) );
my @paths = ();

while (@caves) {
  my $cave = shift @caves;
  my $pos = $cave->{ position };
  for my $next (@{ $cave->{ paths }{ $pos } }) {
    my $new_pos = $cave->move( $next );
    push @caves, $new_pos if ($new_pos && $next ne 'end');
    push @paths, $new_pos if ($new_pos && $next eq 'end');
   }
 }

print "There are ", scalar @paths, " possible paths.\n";

exit;
