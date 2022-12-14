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
is( reduce_t( '[[[[0,7],4],[7,[[8,4],9]]],[1,1]]' ), '[[[[0,7],4],[[7,8],[6,0]]],[8,1]]', 'split1' );
is ( reduce_t( '[[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]],[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]]' ), '[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]', 'add1' );
is ( reduce_t( '[[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]],[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]]' ), '[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]', 'add2' );
is ( reduce_t( '[[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]],[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]]' ), '[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]', 'add3' );
#is ( reduce_t( '[]' ), '', 'add4' );
#is ( reduce_t( '[]' ), '', 'add5' );
#is ( reduce_t( '[]' ), '', 'add6' );
#is ( reduce_t( '[]' ), '', 'add7' );
#is ( reduce_t( '[]' ), '', 'add8' );
#is ( reduce_t( '[]' ), '', 'add9' );
#is ( reduce_t( '[]' ), '', 'add10' );
done_testing();
