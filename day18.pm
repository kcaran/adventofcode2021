#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Pair;

 sub print {
  my ($self) = @_;

  my $result = '[';
  $result .= ref($self->{ x }) ? $self->{ x }->print() : $self->{ x };
  $result .= ',';
  $result .= ref($self->{ y }) ? $self->{ y }->print() : $self->{ y };
  $result .= ']';

  return $result;
 }

 sub explode {
   my ($self) = @_;

   my $stack = [];

   my $pair = $self;
   while (@{ $stack } || $pair) {
     while (ref($pair)) {
       if ($pair->{ level } == 4) {
         die "Did not compute" if (ref( $pair->{ x } ) || ref( $pair->{ y } ));
         my $x = $pair->{ x };
         my $y = $pair->{ y };
         my $selfstr = $self->print();
         my $idx = $pair->{ start };
         my $pre = substr( $selfstr, 0, $idx );
         my $post = substr( $selfstr, $idx );
# What would I do with regexes? I struggled with substr for so long!
         $post =~ s/^\[\d+,\d+\]//;
         $pre =~ s/(\d+)(?=\D*$)/$1+$x/e;
         $post =~ s/(\d+)/$1+$y/e;
         $selfstr = $pre . '0' . $post;
         return Pair->new( $selfstr );
        }
       push @{ $stack }, $pair;
       $pair = $pair->{ x };
      }
     $pair = pop @{ $stack };
     $pair = $pair->{ y };
    }

   return $self;
  }

 sub split {
   my ($self) = @_;

   my $selfstr = $self->print();
   return $self unless ($selfstr =~ /(\d{2})/);

   my $split = $1;
   my $idx = index( $selfstr, $split );
   my $val = sprintf "[%d,%d]", $split/2, $split/2 + $split % 2;
   substr( $selfstr, $idx, 2, $val );

   return Pair->new( $selfstr );
 }

 sub reduce {
   my ($self) = @_;

   my $new;

   do {
     do {
       $new = $self->explode();
       if ($self != $new) {
         $self = $new;
         $new = undef;
        }
      } while (!$new);
     $new = $self->split();
     if ($self != $new) {
       $self = $new;
       $new = undef;
      }
    } while (!$new);

   return $self;
  }

 sub new {
  my ($class, $input, $level, $index) = @_;
  my $self = {
    x => '',
    y => '',
    input => '',
    level => $level || 0,
    start => $index || 0,
    index => $index || 0,
  };

  $self->{ input } = $input;

  while ((my $next = substr( $self->{ input }, 0, 1, '' )) ne ']') {
    $self->{ index }++;
    if ($next eq '[') {
      if ($self->{ input } =~ s/^(\d+)//) {
        $self->{ x } = $1;
        $self->{ index } += length( $1 );
       }
      else {
        $self->{ x } = Pair->new( $self->{ input }, $self->{ level } + 1, $self->{ index } );
        $self->{ input } = $self->{ x }{ input };
        $self->{ index } = $self->{ x }{ index } + 1;
       }
     }
    elsif ($next eq ',') {
      if ($self->{ input } =~ s/^(\d+)//) {
        $self->{ y } = $1;
        $self->{ index } += length( $1 );
       }
      else {
        $self->{ y } = Pair->new( $self->{ input }, $self->{ level } + 1, $self->{ index } );
        $self->{ input } = $self->{ y }{ input };
        $self->{ index } = $self->{ y }{ index } + 1;
       }
     }
   }

  bless $self, $class;
  return $self;
 }
}

1;
