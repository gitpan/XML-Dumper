#! /usr/local/bin/perl

use strict;
use XML::Dumper;
use Test::Harness;

BEGIN { $| = 1; print "1..4\n"; }

my $dump = new XML::Dumper;
my $perl;
my $xml;
my $xml_dump;

# ===== HANDLE SCALAR LITERALS
# Bug submitted 11/20/02 by Niels Vetger
my $perl = \"020525264"; 

if( eval{ $dump->pl2xml( $perl ) } && not $@ ) {
	print "ok 1\n";
} else {
	print "not ok 1\n";
}

# ===== HANDLE UNDEF() CORRECTLY
# Bug submitted 11/26/02 by Peter S. May

$xml = '<perldata>
 <hashref memory_address="0x8296934">
  <item key="a" defined="false"></item>
  <item key="b"></item>
  <item key="c">Foo</item>
  <item key="d">
   <hashref memory_address="0x829c810">
    <item key="d1" defined="false"></item>
    <item key="d2"></item>
    <item key="d3">Bar</item>
   </hashref>
  </item>
 </hashref>
</perldata>
';

$perl = $dump->xml2pl( $xml );
$xml_dump = $dump->pl2xml( $perl );

if( xml_compare( $xml, $xml_dump ) ) {
	print "ok 2\n";
} else {
	print "not ok 2\n";
}

$xml = '<perldata>
 <arrayref memory_address="0x8296934">
  <item key="0" defined="false"></item>
  <item key="1"></item>
  <item key="2">Foo</item>
  <item key="3">
   <arrayref memory_address="0x829c810">
    <item key="0" defined="false"></item>
    <item key="1"></item>
    <item key="2">Bar</item>
   </arrayref>
  </item>
 </arrayref>
</perldata>
';

$perl = $dump->xml2pl( $xml );
$xml_dump = $dump->pl2xml( $perl );

if( xml_compare( $xml, $xml_dump ) ) {
	print "ok 3\n";
} else {
	print "not ok 3\n";
}

$xml = '<perldata>
 <arrayref memory_address="0x8296934">
  <item key="0" defined="false"></item>
  <item key="1"></item>
  <item key="2">Foo</item>
  <item key="3">
   <hashref memory_address="0x829c810">
    <item key="a" defined="false"></item>
    <item key="b"></item>
    <item key="c">Bar</item>
   </hashref>
  </item>
 </arrayref>
</perldata>
';

$perl = $dump->xml2pl( $xml );
$xml_dump = $dump->pl2xml( $perl );

if( xml_compare( $xml, $xml_dump ) ) {
	print "ok 3\n";
} else {
	print "not ok 3\n";
}


