#! /usr/local/bin/perl

use strict;
use XML::Dumper;
use Test::Harness;

BEGIN { $| = 1; print "1..6\n"; }

my $dump = new XML::Dumper;
my $perl;
my $xml;
my $xml_dump;

# ===== TEST 1: HANDLE SCALAR LITERALS
# Bug submitted 11/20/02 by Niels Vetger
my $perl = \"020525264"; 

if( eval{ $dump->pl2xml( $perl ) } && not $@ ) {
	print "ok 1\n";
} else {
	print "not ok 1\n";
}

# ===== TEST 2: HANDLE UNDEF() CORRECTLY
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

# ===== TEST 3: UNDEF() DATA  FOR ARRAYS
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

# ===== TEST 4: UNDEF() DATA FOR HASHES
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
	print "ok 4\n";
} else {
	print "not ok 4\n";
}

# ===== TEST 5: FUNCTIONAL VERSION
# Complaint mentioned on Perl Monks by crazyinsomniac
$perl = xml2pl( $xml );
$xml_dump = pl2xml( $perl );

if( xml_compare( $xml, $xml_dump ) ) {
	print "ok 5\n";
} else {
	print "not ok 5\n";
}

# ===== TEST 6: DTD
my $xml_dump_with_dtd;
$dump->dtd();

$perl = $dump->xml2pl( $xml );
$xml_dump_with_dtd = $dump->pl2xml( $perl );
$perl = $dump->xml2pl( $xml_dump );
$dump->dtd( 0 );
$xml_dump = $dump->pl2xml( $perl );

if( xml_compare( $xml_dump_with_dtd, $xml )) {
	print "ok 6\n";
} else {
	print "not ok 6\n";
}
