#!/usr/bin/perl
#
# DESC: This script takes XML which has been dumped using XML::Dumper
#       and undumps the XML into Perl

# INCLUDES
use strict;
use XML::Parser;
use XML::Dumper;
use Data::Dumper;

# MAIN
# undump XML to perl   
# create new parser instance
my $parser = new XML::Parser(Style => 'Tree');

# parse the file into a tree
my $tree = $parser->parsefile("members.xml");

# create new instance of XML::Dumper
my $dump = new XML::Dumper;

# rebuild the Perl structure
my $newdata = $dump->xml2pl($tree);

# print the results
print Dumper($newdata);
