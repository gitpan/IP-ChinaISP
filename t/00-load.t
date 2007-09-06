#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'IP::ChinaISP' );
}

diag( "Testing IP::ChinaISP $IP::ChinaISP::VERSION, Perl $], $^X" );
