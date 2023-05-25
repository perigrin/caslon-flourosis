#!/bin/env perl
use 5.36.0;
use Lexical::Types;
use BEGIN::Lift;
use Object::Pad qw( :experimental(mop) );
use Feature::Compat::Try;

class Check {
	method check($v) { }
    method get_message($value) { "$value is not a valid ${\ref $self}" }

	use Variable::Magic qw(wizard cast);;

	my $wiz = wizard(
		data => sub ($v, $tc, @) { $tc->new() },
		set => sub ($v, $t) {
			local $_ = $$v; die
			$t->get_message($$v) unless $t->check($$v);
			();
		},
	);

    sub TYPEDSCALAR { cast $_[1], $wiz, $_[0]; () }
};

BEGIN {
    BEGIN::Lift::install(__PACKAGE__, 'check', sub ($class, $check) {
        my $mop = Object::Pad::MOP::Class->create_class( "$class", isa => 'Check');
        $mop->add_method('check', sub($s, $v)  { $check->($v) });
        $mop->seal;
    })
}

{
	check Foo => sub { m/foo/i }; # this should be: check Foo { m/foo/i }
	my Foo $bar;
	$bar = 'Foo';
	say "1: $bar";

	try {
		$bar = 'Bar';
		say "2: $bar";
	}
	catch($e) {
		say "e: $e";
		say "3: $bar";
	}
}

{
	check Any => sub { 1 };
	my Any $foo = 2;
	say "Any: $foo";
}

{
	check Int => sub { m/\d+/ };
	check Even => sub {
		my Int $i = $_[0]; # this should be a signature: check Even (Int $i) { ... }
		$i % 2 == 0
	};

	try {
		my Even $i = 2;
		my Even $j = 3;
	}
	catch ($e) {
		say "$e";
	}

	try {
		my Even:: $p = 'A';
	} catch ($e) { say $e }
}

{
    next; # doesn't work
	#sub test(Int $f) { say $f }

	test(1);
	try { test('a') } catch($e) { say $e }
}

{
    try {
        use constant RefArray => 'Ref[Array]';
        check 'Ref[Array]' => sub { ref $_ eq 'ARRAY' };
        my RefArray $ref = {};
    } catch ($e) { say $e }
}
