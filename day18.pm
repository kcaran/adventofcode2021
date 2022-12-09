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

 sub reduce {
   my ($self, $pair) = @_;

   $pair = $self unless ($pair);

   if ($pair->{ level } == 4) {
       die "Did not compute" if (ref( $pair->{ x } ) || ref( $pair->{ y } ));
       my $x = $pair->{ x };
       my $y = $pair->{ y };
       my $pairstr = $pair->print();
       my $selfstr = $self->print();
       my $idx = index( $selfstr, $pairstr );
       my ($idx_x, $idx_y) = ($idx - 1, $idx + 5);
       while ($idx_x > 0) {
         if (substr( $selfstr, $idx_x, 1 ) =~ /(\d)/) {
           substr( $selfstr, $idx_x, 1 ) = $1 + $x;
           $idx_x = 0;
          }
         $idx_x--;
        }

       while ($idx_y < length( $selfstr )) {
         if (substr( $selfstr, $idx_y, 1 ) =~ /(\d)/) {
           substr( $selfstr, $idx_y, 1 ) = $1 + $y;
           $idx_y = length( $selfstr );
          }
         $idx_y++;
        }

       substr( $selfstr, $idx, 5, '0' );
       return Pair->new( $selfstr );
      }

   $pair->{ x }{ parent } = $pair if (ref($pair->{ x }));
   $pair->{ y }{ parent } = $pair if (ref($pair->{ y }));

   my $x = $pair->{ x };
   $self = $self->reduce( $x ) if (ref($x));

   my $y = $pair->{ y };
   $self = $self->reduce( $y ) if (ref($y));

   return $self;
  }

 sub reduce_old {
   my ($self) = @_;

   if ($self->{ level } == 4) {
       die "Did not compute" if (ref( $self->{ x } ) || ref( $self->{ y } ));
       my ($parent) = $self->{ parent };
       my $x = $self->{ x };
       my $y = $self->{ y };
       while ($parent && ($x > 0 || $y > 0)) {
         if (!ref($parent->{ x })) {
           $parent->{ x } += $x if ($x > 0);
           $x = -1;
          }
         if (!ref($parent->{ y })) {
           $parent->{ y } += $y if ($y > 0);
           $y = -1;
          }
         $parent = $parent->{ parent };
        }
       $self->{ parent }{ x } = 0 if ($self->{ parent }{ x } == $self);
       $self->{ parent }{ y } = 0 if ($self->{ parent }{ y } == $self);
      }

     $self->{ x }{ parent } = $self if (ref($self->{ x }));
     $self->{ y }{ parent } = $self if (ref($self->{ y }));

     my $x = $self->{ x };
     $x->reduce() if (ref($x));

     my $y = $self->{ y };
     $y->reduce() if (ref($y));

   return $self;
  }

 sub new {
  my ($class, $input, $level) = @_;
  my $self = {
    x => '',
    y => '',
    print => '',
    input => '',
    level => $level || 0,
  };

  $self->{ print } = $input;
  $self->{ input } = $input;

  while ((my $next = substr( $self->{ input }, 0, 1, '' )) ne ']') {
    if ($next eq '[') {
      if (substr( $self->{ input }, 0, 1 ) =~ /\d/) {
        $self->{ x } = substr( $self->{ input }, 0, 1, '' );
       }
      else {
        $self->{ x } = Pair->new( $self->{ input }, $self->{ level } + 1 );
        $self->{ input } = $self->{ x }{ input };
       }
     }
    elsif ($next eq ',') {
      if (substr( $self->{ input }, 0, 1 ) =~ /\d/) {
        $self->{ y } = substr( $self->{ input }, 0, 1, '' );
       }
      else {
        $self->{ y } = Pair->new( $self->{ input }, $self->{ level } + 1 );
        $self->{ input } = $self->{ y }{ input };
       }
     }
   }

  bless $self, $class;
  return $self;
 }
}

1;
