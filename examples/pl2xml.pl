#!/usr/bin/perl
#
# DESC: This script takes a Perl structure and dumps it to XML

# INCLUDES
use strict;
use XML::Dumper;

# MAIN
# build a reference to an array of hashes
my $data = [
	    {
		first => 'Jonathan',
		last => 'Eisenzopf',
		email => 'eisen@pobox.com'
		},
	    {
		first => 'Larry',
		last => 'Wall',
		email => 'larry@wall.org'
		}
	    ];

# Dump Perl to XML
# create new instance of XML::Dumper
my $dump = new XML::Dumper;

# print the results
print $dump->pl2xml($data);


