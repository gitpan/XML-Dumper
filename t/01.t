#! /usr/local/bin/perl

use strict;
use XML::Dumper;
use Test::Harness;

BEGIN { $| = 1; print "1..12\n"; }

our $COMPRESSION_AVAILABLE;

INIT {
	eval { require Compress::Zlib; };
	if( $@ ) {
		$COMPRESSION_AVAILABLE = undef;
	} else {
		$COMPRESSION_AVAILABLE = 1;
	}
}

open TEST11, "t/data/01-11.xml" or die "Can't open 't/data/01-11.xml' for reading $!";
my $test_11_xml = join "", <TEST11>;
close TEST11;

my $test_12_xml;
if( $COMPRESSION_AVAILABLE ) {
	
	my $gz = Compress::Zlib::gzopen( "t/data/01-12.xml.gz", "rb" );
	my @xml;
	my $buffer;
	while( $gz->gzread( $buffer ) > 0 ) {
		push @xml, $buffer;
	}
	$gz->gzclose();
	$test_12_xml = join "", @xml;

} else {
	$test_12_xml = 'skip';
}

my $TestRuns = [
		 
# ===== SIMPLE SCALAR
<<'END_TEST1',
<perldata>
 <scalar>foo</scalar>
</perldata>
END_TEST1

# ===== SCALAR REFERENCE
<<'END_TEST2',
<perldata>
 <scalarref>Hi Mom</scalarref>
</perldata>
END_TEST2

# ===== HASH REFERENCE
<<'END_TEST3',
<perldata>
 <hashref>
  <item key="key1">value1</item>
  <item key="key2">value2</item>
 </hashref>
</perldata>
END_TEST3

# ===== ARRAY REFERENCE
<<'END_TEST4',
<perldata>
 <arrayref>
  <item key="0">foo</item>
  <item key="1">bar</item>
 </arrayref>
</perldata>
END_TEST4

# ===== MIXED DATATYPE
<<'END_TEST5',
<perldata>
 <arrayref>
  <item key="0">Scalar</item>
  <item key="1">
   <scalarref>ScalarRef</scalarref>
  </item>
  <item key="2">
   <arrayref>
    <item key="0">foo</item>
    <item key="1">bar</item>
   </arrayref>
  </item>
  <item key="3">
   <hashref>
    <item key="key1">value1</item>
    <item key="key2">value2</item>
   </hashref>
  </item>
 </arrayref>
</perldata>
END_TEST5

# ===== BLESSED SCALAR OBJECT
<<'END_TEST6',
<perldata>
 <scalarref blessed_package="Scalar_object">Hi Mom</scalarref>
</perldata>
END_TEST6

# ===== BLESSED HASH OBJECT
<<'END_TEST7',
<perldata>
 <hashref blessed_package="Hash_object">
  <item key="key1">value1</item>
  <item key="key2">value2</item>
 </hashref>
</perldata>
END_TEST7

# ===== BLESSED ARRAY OBJECT
<<'END_TEST8',
<perldata>
 <arrayref blessed_package="Array_object">
  <item key="0">foo</item>
  <item key="1">bar</item>
 </arrayref>
</perldata>
END_TEST8

# ===== HASH OBJECT WITH CIRCULAR REFERENCE
<<'END_TEST9',
<perldata>
 <hashref memory_address="0x40041d28">
  <item key="data">
   <hashref memory_address="0x40041d28">
   </hashref>
  </item>
  <item key="fname">Mike</item>
  <item key="lname">Wong</item>
 </hashref>
</perldata>
END_TEST9

# ===== BLESSED SCALAR OBJECT WITH CALLBACK
<<'END_TEST10',
<perldata>
 <scalarref blessed_package="Scalar_object">Testing callbacks</scalarref>
</perldata>
END_TEST10

# ===== FILE READING AND WRITING
$test_11_xml,

# ===== COMPRESSED FILE READING AND WRITING
$test_12_xml,

];

my $test_num;
my $test_xml;
TEST: foreach $test_xml (@$TestRuns)
{
	$test_num++;

	my $Dumper = new XML::Dumper();
	my $perl;
	my $xml;

	DO_TEST: {
		if( $test_num == 10 ) {
			$perl = $Dumper->xml2pl($test_xml, "callback" );
			$xml = $Dumper->pl2xml( $perl );
			last DO_TEST;
		}
		if( $test_num == 11 ) {
			$perl = $Dumper->xml2pl( 't/data/01-11.xml' );
			$xml = $Dumper->pl2xml( $perl, 't/data/01-11.xml' );
			last DO_TEST;
		}
		if( $test_num == 12 ) {
			if( not $COMPRESSION_AVAILABLE ) {
				print "ok $test_num # skip Compress::Zlib not installed, compression feature disabled.\n";
				next TEST;
			}
			$perl = $Dumper->xml2pl( 't/data/01-12.xml.gz' );
			$xml = $Dumper->pl2xml( $perl, 't/data/01-12.xml.gz' );
			last DO_TEST;
		}
		DEFAULT: {
			$perl = $Dumper->xml2pl($test_xml);
			$xml = $Dumper->pl2xml( $perl );
			last DO_TEST;
		}
	}
	
	if ( xml_compare( $test_xml, $xml ))
	{
		print "ok $test_num\n"; 
	}
	else
	{
		print "not ok $test_num\n";
		print STDERR ("Test $test_num failed: data doesn't match!\n\n" . 
					  "Perl tree:\n$test_xml\nXML tree:\n$xml\n\n");
	}
}

package Scalar_object;

# ============================================================
sub callback {
# ============================================================
	my $self = shift;

	print $$self, "\n";
}
1;
