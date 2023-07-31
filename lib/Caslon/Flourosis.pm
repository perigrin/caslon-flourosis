use 5.36.0;
use Lexical::Types;
use BEGIN::Lift;
use Object::Pad qw( :experimental(mop) );

class Check {
	method check($v) { }
    method get_message($value) { "$value is not a valid ${\ref $self}" }

	use Variable::Magic qw(wizard cast);;

	my $wiz = wizard(
		data => sub ($v, $tc, @) { $tc->new() },
		set => sub ($v, $t) {
            say $$v;
			local $_ = $$v;
			$t->get_message($$v) unless $t->check($$v);
			();
		},
        store => sub ($v, $t) {
			local $_ = $$v;
            $t->get_message($$v) unless $t->check($$v);
            ();
        }
	);

    sub TYPEDSCALAR { warn $_[0]; cast $_[1], $wiz, $_[0]; () }
};

package Caslon::Flourosis {
    sub import {
        my $caller = caller;
        BEGIN::Lift::install($caller, 'check', sub ($class, $check) {
            warn $class;
            my $mop = Object::Pad::MOP::Class->create_class( "$class", isa => 'Check');
            $mop->add_method('check', sub($s, @v)  { scalar $check->(@v) });
            $mop->seal;
        });
        Lexical::Types->import;
    }
}

1;
__END__
