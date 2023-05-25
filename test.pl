use 5.36.0;
no strict "refs";

my $p = 'A[Foo]|Undef';

eval "package $p { }";

*{$p.'::(('} = \&{ sub {} }; # set overloaded flag
*{$p.'::(""'} = \&{ sub { "foo" } }; # overload stringification

say for keys %{$p.'::'};
my $a = bless {}, $p;
say ref $a;
say $a;
