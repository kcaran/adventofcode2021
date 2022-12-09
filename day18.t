#!/usr/bin/env perl
#
# Tests for generic IntCode module
#
use strict;
use warnings;
use utf8;

use Test::More;
use day18;

sub reduce_t {
 my ($pair) = @_;

 return Pair->new( $pair )->reduce()->print();
}

is( reduce_t( '[[[[[9,8],1],2],3],4]' ), '[[[[0,9],2],3],4]', 'exp1' );
is( reduce_t( '[7,[6,[5,[4,[3,2]]]]]' ), '[7,[6,[5,[7,0]]]]', 'exp2' );
is( reduce_t( '[[6,[5,[4,[3,2]]]],1]' ), '[[6,[5,[7,0]]],3]', 'exp3' );
#is( reduce_t( '[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]' ), '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]', 'single' );
#is( reduce_t( '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]' ), '[[3,[2,[8,0]]],[9,[5,[7,0]]]]', 'exp5' );
is( reduce_t( '[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]' ), '[[3,[2,[8,0]]],[9,[5,[7,0]]]]', 'exp5' );

done_testing();
