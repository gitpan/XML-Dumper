#! /usr/local/bin/perl

use strict;
use blib;
use XML::Dumper;
use Test::Harness;

BEGIN { $| = 1; print "1..10\n"; }

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

];

my $TestNum;
my $TestData;
foreach $TestData (@$TestRuns)
{
	$TestNum++;

	my $Dumper = new XML::Dumper();
	my $Ref;

	if( $TestNum == 10 ) {
		$Ref = $Dumper->xml2pl($TestData, "callback" );

	} else {
		$Ref = $Dumper->xml2pl($TestData);
	}
	
	my $ReDump = $Dumper->pl2xml($Ref);
	
	if ( xml_compare( $TestData, $ReDump ))
	{
		print "ok $TestNum\n"; 
	}
	else
	{
		print "not ok $TestNum\n";
		print STDERR ("Test $TestNum failed: data doesn't match!\n\n" . 
					  "Perl tree:\n$TestData\nXML tree:\n$ReDump\n\n");
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
