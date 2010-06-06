use Test::More tests => 1;

use strict;
use WWW::GitHub::Gist;

my $gist = WWW::GitHub::Gist->new;

can_ok($gist, qw(info user file add_file create));
