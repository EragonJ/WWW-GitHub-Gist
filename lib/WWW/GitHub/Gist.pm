package WWW::GitHub::Gist;

use Carp;
use JSON;
use HTTP::Tiny;

use strict;
use warnings;

=head1 NAME

WWW::GitHub::Gist - Perl interface to GitHub's Gist pastebin service

=cut

use constant GIST_URL	=> 'http://gist.github.com';
use constant API_URL	=> 'http://gist.github.com/api/v1';
use constant API_FORMAT	=> 'json';

my $http = HTTP::Tiny -> new();

=head1 SYNOPSIS

L<WWW::GitHub::Gist> is an object-oriented interface to the pastebin
service of GitHub L<gist.github.com>.

    use feature 'say';
    use WWW::GitHub::Gist;

    my $gist = WWW::GitHub::Gist -> new(id => 'gist id');

    # Print the gist's author
    say $gist -> info -> {'owner'};

    # Print every ID of the gists owned by USERNAME
    $gist = WWW::GitHub::Gist -> new(user => 'USERNAME');

    foreach (@{ $gist -> user() }) {
      say $_ -> {'repo'};
    }

    # Create a new gist and print its ID
    my $login = `git config github.user`;
    my $token = `git config github.token`;

    chomp $login; chomp $token;

    $gist = WWW::GitHub::Gist -> new(
      user  => $login,
      token => $token
    );

    $gist -> add_file('test', 'some data here', '.txt');
    say $gist -> create() -> {'repo'};

=head1 METHODS

=head2 new( %args )

Create a L<WWW::GitHub::Gist> object. The C<%args> hash may contain the
following fields:

=over

=item C<id>

The ID of an existing gist.

=item C<user>

The name of a GitHub user.

=item C<token>

The GitHub token used for the login.

=back

=cut

sub new {
	my ($class, %args) = @_;

	my $self = bless({%args}, $class);

	return $self;
}

=head2 info()

Returns an hash containing the following fields:

=over

=item C<owner>

The author of the gist.

=item C<created_at>

The date of creation of the gist.

=item C<repo>

The ID of the gist, which identifies its repository.

=item C<files>

An array of the file names contained in the gist.

=item C<public>

Wheter the gist is public or not.

=item C<description>

The description of the gist.

=back

=cut

sub info {
	my $self = shift;

	my $url		= API_URL.'/'.API_FORMAT.'/'.$self -> {'id'};
	my $response	= $http -> get($url);

	if ($response -> {'status'} != 200) {
		croak 'Err: '.$response -> {'reason'};
	}

	my $info	= _parse_response($response -> {'content'});

	return @{ $info -> {'gists'} }[0];
}

=head2 file( $filename )

Retrieve the selected file content of the current gist.

=cut

sub file {
	my ($self, $filename) = @_;

	my $url		= GIST_URL.'/raw/'.$self -> {'id'}."/$filename";
	my $response	= $http -> get($url);

	if ($response -> {'status'} != 200) {
		croak 'Err: '.$response -> {'reason'};
	}

	return $response -> {'content'};
}

=head2 user()

Retrieve user's gists

=cut

sub user {
	my $self = shift;

	my $url		= API_URL.'/'.API_FORMAT.'/gists/'.$self -> {'user'};
	my $response	= $http -> get($url);

	if ($response -> {'status'} != 200) {
		croak 'Err: '.$response -> {'reason'};
	}

	my $info	= _parse_response($response -> {'content'});

	return $info -> {'gists'};
}

=head2 add_file( $filename, $data, $extension )

Add a file to the current gist

=cut

sub add_file {
	my ($self, $filename, $data, $extension) = @_;

	push @{ $self -> {'files'} },
		{
			'file_ext'      => $extension ? $extension : '.txt',
			'file_name'     => $filename,
			'file_contents' => $data
		};
}

=head2 create

Create a gist using files added with add_file() and returns its info
in a hash. See C<info()> for more details.

=cut

sub create {
	my @params;
	my $self = shift;

	my $url		= API_URL.'/'.API_FORMAT.'/new';

	my $login	= 'login='.$self -> {'user'};
	my $token	= 'token='.$self -> {'token'};

	push @params, $login, $token;

	foreach my $file (@{$self -> {'files'}}) {
		my $ext		= $file -> {'file_ext'};
		my $filename	= $file -> {'file_name'};
		my $data	= $file -> {'file_contents'};

		push @params,	"file_ext[$filename]=$ext",
				"file_name[$filename]=$filename",
				"file_contents[$filename]=$data";
	}

	my $response = $http -> request('POST', $url, {
		content => join("&", @params),
		headers => {'content-type' => 'application/x-www-form-urlencoded'}
	});

	if ($response -> {'status'} != 200) {
		croak 'Err: '.$response -> {'reason'};
	}

	my $info	= _parse_response($response -> {'content'});

	return @{ $info -> {'gists'} }[0];
}

=head1 INTERNAL SUBROUTINES

=head2 _parse_response( $data )

Parse the response of an HTTP request.

=cut

sub _parse_response {
	my $data = shift;

	my $json_text = decode_json $data;

	return $json_text;
}

=head1 EXTENSION

The extension variable is used by GitHub to set proper syntax
highlighting rules.

GitHub supports the following extensions/languages:

	.txt		Plain Text
	.as		ActionScript
	.c		C
	.cs		C#
	.cpp		C++
	.css		CSS
	.cl		Common Lisp
	.diff		Diff
	.el		Emacs Lisp
	.hrl		Erlang
	.html		HTML
	.hs		Haskell
	.java		Java
	.js		JavaScript
	.lua		Lua
	.m		Objective-C
	.php		PHP
	.pl		Perl
	.py		Python
	.rb		Ruby
	.sql		SQL
	.scala		Scala
	.sls		Scheme
	.tex		TeX
	.xml		XML
	.ascx		ASP
	.scpt		AppleScript
	.arc		Arc
	.asm		Assembly
	.bat		Batchfile
	.befunge	Befunge
	.boo		Boo
	.b		Brainfuck
	.ck		ChucK
	.clj		Clojure
	.coffee		CoffeeScript
	.cfm		ColdFusion
	.feature	Cucumber
	.d		D
	.darcspatch	Darcs Patch
	.pas		Delphi
	.duby		Duby
	.dylan		Dylan
	.e		Eiffel
	.f		FORTRAN
	.s		GAS
	.kid		Genshi
	.ebuild		Gentoo Ebuild
	.eclass		Gentoo Eclass
	.po		Gettext Catalog
	.go		Go
	.man		Groff
	.mustache	HTML+Django
	.erb		HTML+ERB
	.phtml		HTML+PHP
	.hx		HaXe
	.haml		Haml
	.ini		INI
	.weechatlog	IRC log
	.io		Io
	.ll		LLVM
	.mak		Makefile
	.mao		Mako
	.ron		Markdown
	.matlab		Matlab
	.mxt		Max/MSP
	.md		MiniD
	.moo		Moocode
	.myt		Myghty
	.nu		Nu
	.numpy		NumPy
	.ml		OCaml
	.j		Objective-J
	.pir		Parrot Internal Representation
	.pd		Pure Data
	.pytb		Python traceback
	.r		R
	.rhtml		RHTML
	.raw		Raw token data
	.cw		Redcode
	.sass		Sass
	.self		Self
	.sh		Shell
	.st		Smalltalk
	.tpl		Smarty
	.sc		SuperCollider
	.tcl		Tcl
	.tcsh		Tcsh
	.txt		Text
	.vhdl		VHDL
	.v		Verilog
	.vim		VimL
	.bas		Visual Basic
	.yml		YAML
	.jsp		jsp
	.mu		mupad
	.ooc		ooc
	.rst		reStructuredText

=head1 AUTHOR

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-github-gist at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-GitHub-Gist>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::GitHub::Gist

You can also look for information at:

=over 4

=item Git repository

L<http://github.com/AlexBio/WWW-GitHub-Gist>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-GitHub-Gist>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-GitHub-Gist>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-GitHub-Gist>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-GitHub-Gist/>

=back

=head1 ACKNOWLEDGEMENTS

Gist.GitHub.com APIs are incomplete, so many features are not accessible.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::GitHub::Gist
