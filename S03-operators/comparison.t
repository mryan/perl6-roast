use v6;
use Test;

plan 56;

# N.B.:  relational ops are in relational.t

# L<S03/Nonchaining binary precedence/Order::Less, Order::Same, or Order::More>
is-deeply(+Order::Less, -1, 'Order::Less numifies to -1');
is-deeply(+Order::Same,  0, 'Order::Same numifies to 0');
is-deeply(+Order::More,  1, 'Order::More numifies to 1');

#L<S03/Comparison semantics>

# spaceship comparisons (Num)
is-deeply(1 <=> 1, Order::Same, '1 <=> 1 is same');
is-deeply(1 <=> 2, Order::Less, '1 <=> 2 is less');
is-deeply(2 <=> 1, Order::More, '2 <=> 1 is more');

is-deeply 0 <=> -1,      Order::More, '0 <=> -1 is less';
is-deeply -1 <=> 0,      Order::Less, '-1 <=> 0 is more';
is-deeply 0 <=> -1/2,    Order::More, '0 <=> -1/2 is more';
is-deeply 0 <=> 1/2,     Order::Less, '0 <=> 1/2 is less';
is-deeply -1/2 <=> 0,    Order::Less, '-1/2 <=> 0 is more';
is-deeply 1/2 <=> 0,     Order::More, '1/2 <=> 0 is more';
is-deeply 1/2 <=> 1/2,   Order::Same, '1/2 <=> 1/2 is same';
is-deeply -1/2 <=> -1/2, Order::Same, '-1/2 <=> -1/2 is same';
is-deeply 1/2 <=> -1/2,  Order::More, '1/2 <=> -1/2 is more';
is-deeply -1/2 <=> 1/2,  Order::Less, '-1/2 <=> 1/2 is less';

is-deeply 1 <=> NaN, Nil, "NaN numeric comparison always produces Nil";
is-deeply NaN <=> 1, Nil, "NaN numeric comparison always produces Nil";
is-deeply NaN <=> NaN, Nil, "NaN numeric comparison always produces Nil";

is-deeply 1 cmp NaN, Less, "NaN generic comparison sorts NaN in with alphabetics";
is-deeply NaN cmp 1, More, "NaN generic comparison sorts NaN in with alphabetics";
is-deeply NaN cmp NaN, Same, "NaN generic comparison sorts NaN in with alphabetics";

is-deeply exp(i * pi) <=> -1, Same, "<=> ignores tiny imaginary values";
is-deeply exp(i * pi) * 1e10 <=> -1 * 1e10, Same, "<=> ignores tiny imaginary values, scaled up";
is-deeply exp(i * pi) * 1e-10 <=> -1 * 1e-10, Same, "<=> ignores tiny imaginary values, scaled down";
{
    my $*TOLERANCE = 1e-18;
    throws-like 'exp(i * pi) <=> -1', Exception, "(unless they exceed the signficance)";
    throws-like 'exp(i * pi) * 1e10 <=> -1 * 1e10', Exception, "(still fails scaled up)";
    throws-like 'exp(i * pi) * 1e-10 <=> -1 * 1e-10', Exception, "(still fails scaled down)";
}

# leg comparison (Str)
is-deeply('a' leg 'a',     Order::Same, 'a leg a is same');
is-deeply('a' leg 'b',     Order::Less, 'a leg b is less');
is-deeply('b' leg 'a',     Order::More, 'b leg a is more');
is-deeply('a' leg 1,       Order::More, 'leg is in string context');
is-deeply("a" leg "a\0",   Order::Less, 'a leg a\0 is less');
is-deeply("a\0" leg "a\0", Order::Same, 'a\0 leg a\0 is same');
is-deeply("a\0" leg "a",   Order::More, 'a\0 leg a is more');

# cmp comparison
is-deeply('a' cmp 'a',     Order::Same, 'a cmp a is same');
is-deeply('a' cmp 'b',     Order::Less, 'a cmp b is less');
is-deeply('b' cmp 'a',     Order::More, 'b cmp a is more');
is-deeply(1 cmp 1,         Order::Same, '1 cmp 1 is same');
is-deeply(1 cmp 2,         Order::Less, '1 cmp 2 is less');
is-deeply(2 cmp 1,         Order::More, '2 cmp 1 is more');
is-deeply('a' cmp 1,       Order::More, '"a" cmp 1 is more'); # unspecced P5 behavior
is-deeply("a" cmp "a\0",   Order::Less, 'a cmp a\0 is less');
is-deeply("a\0" cmp "a\0", Order::Same, 'a\0 cmp a\0 is same');
is-deeply("a\0" cmp "a",   Order::More, 'a\0 cmp a is more');

# Test that synthetics compare properly
is-deeply "\c[BOY, ZWNJ]" cmp  "\c[BOY, ZWJ]", Order::Less, "Synthetic codepoints compare properly";
is-deeply "\c[BOY, ZWJ]"  cmp "\c[BOY, ZWNJ]", Order::More, "Synthetic codepoints compare properly";
# Test that synthetics containing the same starter characters but different in length compare with
# the longer one as More than the shorter one
is-deeply "\c[BOY, ZWJ, ZWJ]"  cmp "\c[BOY, ZWJ]", Order::More, "Synthetic codepoints compare properly";

# compare numerically with non-numeric
{
    class Blue {
        method Numeric() { 3; }
        method Real()    { 3; }
    }
    my $a = Blue.new;

    ok +$a == 3, '+$a == 3 (just checking)';
    ok $a == 3, '$a == 3';
    ok $a != 4, '$a != 4';
    nok $a != 3, 'not true that $a != 3';

    lives-ok { $a < 5 }, '$a < 5 lives okay';
    lives-ok { $a <= 5 }, '$a <= 5 lives okay';
    lives-ok { $a > 5 }, '$a > 5 lives okay';
    lives-ok { $a >= 5 }, '$a => 5 lives okay';
}

# vim: ft=perl6
