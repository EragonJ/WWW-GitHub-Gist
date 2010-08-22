use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::GitHub::Gist',
    AUTHOR              => q{Alessandro Ghedini <alexbio@cpan.org>},
    VERSION_FROM        => 'lib/WWW/GitHub/Gist.pm',
    ABSTRACT_FROM       => 'lib/WWW/GitHub/Gist.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    EXE_FILES	=> ['script/gist.pl'],
    PREREQ_PM => {
        'Test::More' => 0,
        'LWP::UserAgent' => 0,
        'HTTP::Request::Common' => 0,
        'JSON' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-GitHub-Gist-*' },
);
