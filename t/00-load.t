#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::GitHub::Gist' ) || print "Bail out!
";
}

diag( "Testing WWW::GitHub::Gist $WWW::GitHub::Gist::VERSION, Perl $], $^X" );
