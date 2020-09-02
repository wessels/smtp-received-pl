#!/usr/bin/perl
use strict;
use warnings;
use Date::Parse;
use POSIX;

sub do_line {
	my $line = shift;
	$line =~ s/\s+/ /g;
	my $from = '';
	my $by = '';
	my $for = '';
	my $ts = '';
	if ($line =~ /Received:\s+(from\s.*)\s+(by\s.*)\s(for\s.*); (.*)/) {
		$from = $1;
		$by = $2;
		$for = $3;
		$ts = $4;
	} elsif ($line =~ /Received:\s+(by\s.*)\s(for\s.*); (.*)/) {
		$from = '';
		$by = $1;
		$for = $2;
		$ts = $3;
	} elsif ($line =~ /Received:\s+(by\s.*); (.*)/) {
		$from = '';
		$by = $1;
		$for = '';
		$ts = $2;
	} elsif ($line =~ /Received:\s+(from\s.*)\s+(by\s.*); (.*)/) {
		$from = $1;
		$by = $2;
		$for = '';
		$ts = $3;
	} else {
		return;
	}
	my $tt = str2time($ts) or die;
	$ts = POSIX::strftime ('%Y-%m-%d %H:%M:%S UTC', gmtime($tt));
	print join(',', map {'"'.$_.'"'} ($ts,$from,$by,$for)). "\n";
}

my $line = '';
while (<>) {
	chomp;
	unless (/./) {
		# endof headers
		last;
	}
	unless (/^\s/) {
		# current line is not a continuation
		do_line($line) if $line;
		$line = '';
	}
	$line .= $_;
}
do_line($line) if $line;
exit(0);
