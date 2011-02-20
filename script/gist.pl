#!/usr/bin/perl

use WWW::GitHub::Gist;

use strict;

=head1 NAME

gist.pl - GitHub Gist creator

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

gist.pl [OPTIONS]

=cut

die "For info type 'perldoc $0'\n" unless $#ARGV > 0;

my ($file, $login, $token, $ext);

$login = $ENV{GITHUB_USER};
$token = $ENV{GITHUB_TOKEN};

for (my $i = 0; $i < $#ARGV + 1; $i++) {
	$file	= $ARGV[$i+1] if ($ARGV[$i] eq "-f");
	$login	= $ARGV[$i+1] if ($ARGV[$i] eq "-l");
	$token	= $ARGV[$i+1] if ($ARGV[$i] eq "-t");
	$ext	= $ARGV[$i+1] if ($ARGV[$i] eq "-e");
	die "For info type 'perldoc $0'\n" if ($ARGV[$i] eq "-h");
}

open(FILE, $file) or die "ERROR: Enter a valid file name.";
my $data = join('', <FILE>);
close FILE;

my $basename = (split /\//, $file)[-1];

if ($ext eq '') {
	$ext = ".".($file =~ m/([^.]+)$/)[0];
	print "Found $ext extension. You can provide custom extension using '-e' option.\n";
}

my $gist = WWW::GitHub::Gist -> new(user => $login, token => $token);

$gist -> add_file($basename, $data, $ext);
my $info = $gist -> create;

my $repo = @$info[0] -> {'repo'};

print "Gist $repo successfully created.\n";
print "Public Clone URL: git://gist.github.com/$repo.git\n";
print "Private Clone URL: git\@gist.github.com:$repo.git\n";

=head1 OPTIONS

=over
		
=item -l	Specifies the username.

=item -t	User's GitHub API token, used for login.

=item -f	File to upload.

=item -e	File extension, used for syntax highlighting (optional).

=back

=head1 CONFIGURATION

Username and api token variables could be set via the GITHUB_USER and
GITHUB_TOKEN environment variables. These settings are overwritten by the
ones passed via command-line.

=head1 TOKEN

API token can be found on the Account Settings page.
Visit the url: https://github.com/account

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
