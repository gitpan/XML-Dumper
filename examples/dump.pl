#!/usr/bin/perl

# INCLUDES
use strict;
use vars qw($opt_2xml $opt_2perl $VAR1);
use Getopt::Long;
use XML::Parser;
use XML::Dumper;

# MAIN
GetOptions("2xml=s","2perl=s");

# check for command line argument
die "Syntax: dump2perl.pl --(2xml|2perl) <filename>\n\n" unless (defined($opt_2xml) || defined($opt_2perl));

# convert XML to perl
if ($opt_2perl) {    
    # create new parser instance
    my $parser = new XML::Parser(Style => 'Tree');

    # parse the file into a tree
    my $tree = $parser->parsefile($opt_2perl);

    # create new instance of XML::Dumper
    my $dump = new XML::Dumper;

    # print the results
    print $dump->xml2pl($tree);

# convert perl to XML
} elsif ($opt_2xml) {
    # open perl file
    open(XML,$opt_2xml) || die "Cannot open $opt_2xml for read: $!";

    # read file into $pdump
    my $pdump = eval(join("",<XML>));

    # create new instance of XML::Dumper
    my $dump = new XML::Dumper;

    # print the results
    print $dump->pl2xml($pdump);
}
