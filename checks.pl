#!/bin/env perl
use 5.36.0;
use lib qw(lib);
use Caslon::Flourosis;
use Feature::Compat::Try;

{
    check ArrayOfInt => sub { grep { m/\d+/ } @_ };
    try {
        my ArrayOfInt @data = (1,2);
        my ArrayOfInt $data = [1,2];
    #    say @data;
        my ArrayOfInt @bad = ("one");
    #    say @bad;
    } catch ($e) {
    #    say $e;
    }
}

{
	check Foo => sub { m/foo/i }; # this should be: check Foo { m/foo/i }
	my Foo $bar;
	$bar = 'Foo';
	#say "1: $bar";

	try {
		$bar = 'Bar';
	#	say "2: $bar";
	}
	catch($e) {
	#	say "e: $e";
	#	say "3: $bar";
	}
}

if (0) {
	check Any => sub { 1 };
	my Any $foo = 2;
	say "Any: $foo";
}

