#! /usr/local/bin/perl

use XML::Dumper;
use Benchmark qw( timeit timestr );

print
	"This is a test to see how quickly XML::Dumper runs on your system.\n",
	"This may take anywhere from a few seconds to a few minutes.\n",
	"(For a 1.6 GHz Pentium 4, 512 MB RAM system, it takes a little over 17 seconds\n",
	"for 10,000 (the default) iterations.)\n\n";

my $count = 10000;

my $time = timeit( $count, '
  my $perl = [
    {
      fname		=> "Fred",
      lname		=> "Flintstone",
      residence	=> "Bedrock"
    },
    {
      fname		=> "Barney",
      lname		=> "Rubble",
      residence	=> "Bedrock"
    }
  ];

  my $dump = new XML::Dumper;
  my $xml = $dump->pl2xml( $perl );
  my $pl = $dump->xml2pl( $xml );
' );

print "$count loops of code took: ", timestr($time), "\n";

__END__

=head1 Results

=head2 Dumping Perl to XML

my $time = timeit( $count, '
  my $perl = [
    {
      fname		=> "Fred",
      lname		=> "Flintstone",
      residence	=> "Bedrock"
    },
    {
      fname		=> "Barney",
      lname		=> "Rubble",
      residence	=> "Bedrock"
    }
  ];
  my $dump = new XML::Dumper;
  my $xml = $dump->pl2xml( $perl );
' );

=head2 Dumping XML to Perl;

my $time = timeit( $count, '
  my $perl = [
    {
      fname		=> "Fred",
      lname		=> "Flintstone",
      residence	=> "Bedrock"
    },
    {
      fname		=> "Barney",
      lname		=> "Rubble",
      residence	=> "Bedrock"
    }
  ];

  my $dump = new XML::Dumper;
  my $xml = $dump->pl2xml( $perl );
  my $pl = $dump->xml2pl( $xml );
' );


