package WWW::GitHub::Gist;

use Carp;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;

use warnings;
use strict;

=head1 NAME

WWW::GitHub::Gist - Perl interface to Gist.GitHub.com

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

my $GIST_URL   = 'http://gist.github.com';
my $API_URL    = 'http://gist.github.com/api/v1';
my $API_FORMAT = 'json';

=head1 SYNOPSIS

WWW::GitHub::Gist is an object-oriented interface to Gist.GitHub.com.

    use WWW::GitHub::Gist;

    my $gist = WWW::GitHub::Gist->new(id => 'gist id');

    print $gist->info->{'user'}."\n";

    $gist = WWW::GitHub::Gist->new(user => 'username');

    foreach (@{$gist->user}) {
	    print $_->{'repo'}."\n";
    }

    $gist = WWW::GitHub::Gist->new(user => 'username', token => 'github token');

    $gist->add_file('test', 'some data here', '.txt');
    $gist->create;

=head1 METHODS

=head2 new

Create a L<WWW::GitHub::Gist> object

=cut

sub new {
	my ($class, %args) = @_;
 
	my $self = bless({%args}, $class);

	return $self;
}

=head2 info

Retrieve information about current gist

=cut

sub info {
	my $self = shift;
	
	my $url = "$API_URL/$API_FORMAT/".$self -> {'id'};

	return request($url, 'GET') -> {'gists'} -> [0];
}

=head2 file( $filename )

Retrieve a file of current gist.

=cut

sub file {
	my ($self, $filename) = @_;
	
	my $url = "$GIST_URL/raw/".$self -> {'id'}."/$filename";

	return get_request($url, 'GET');
}

=head2 user

Retrieve user's gists

=cut

sub user {
	my $self = shift;
	
	my $url = "$API_URL/$API_FORMAT/gists/".$self -> {'user'};

	return request($url, 'GET') -> {'gists'};
}

=head2 add_file( $filename, $data, $extension )

Add a file to the current gist

=cut

sub add_file {
	my ($self, $filename, $data, $extension) = @_;

	push @{$self -> {'files'}}, {'file_ext'      => $extension ? $extension : '.txt',
				     'file_name'     => $filename,
				     'file_contents' => $data};
}

=head2 create

Create a gist using files added with add_file()

=cut

sub create {
	my $self = shift;

	my @request = ('login', $self -> {'user'},
		       'token', $self -> {'token'}
	              );

	foreach my $file (@{$self -> {'files'}}) {
		my $ext      = $file -> {'file_ext'};
		my $filename = $file -> {'file_name'};
		my $data     = $file -> {'file_contents'};
		
		push @request,  "file_ext[$filename]" 	   => $ext,
				"file_name[$filename]"	   => $filename,
				"file_contents[$filename]" => $data;
	}
	
	my $url = "$API_URL/$API_FORMAT/new";

	return request($url, 'POST', \@request) -> {'gists'};
}

=head1 SUBROUTINES

=head2 request( $url, $type, $request )

Make an HTTP request and parse the response.

=cut

sub request {
	my ($url, $type, $request) = @_;
	my $response;

	if ($type eq 'GET') {
		$response = get_request($url);
	} elsif ($type eq 'POST') {
		$response = post_request($url, $request);
	}

	my $data = parse_response($response);

	return $data;
}

=head2 get_request( $url )

Make a GET request.

=cut

sub get_request {
	my $url = shift;
	my $ua = LWP::UserAgent -> new;
	$ua -> agent("");

	my $response = $ua -> request(GET $url) -> as_string;

	my $status = (split / /,(split /\n/, $response)[0])[1];

	croak "ERROR: Server reported status $status" if $status != 200;

	my @data = split('\n\n', $response);

	return $data[1];
}

=head2 post_request( $url, %request )

Make a POST request.

=cut

sub post_request {
	my ($url, $request) = @_;
	my $ua = LWP::UserAgent -> new;
	$ua -> agent("");

	my $response = $ua -> request(POST $url, $request) -> as_string;

	my $status = (split / /,(split /\n/, $response)[0])[1];
	
	croak "ERROR: Server reported status $status" if $status != 200;

	my @data = split('\n\n', $response);

	return $data[1];
}

=head2 parse_response( $data )

Parse the response of an HTTP request.

=cut

sub parse_response {
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

Gist.GitHub.com APIs are incomplete so many features are not accessible.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::GitHub::Gist
