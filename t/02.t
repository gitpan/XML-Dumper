#! /usr/local/bin/perl

use strict;
use XML::Dumper;
use Test::Harness;

BEGIN { $| = 1; print "1..1\n"; }

my $dump = new XML::Dumper;

my $data = \"020525264"; # Bug submitted 11/20/02 by Niels Vetger

if( eval{ $dump->pl2xml( $data ) } && not $@ ) {
	print "ok 1\n";
} else {
	print "not ok 1\n";
}
