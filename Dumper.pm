# ============================================================
# XML::
#  ____                                  
# |  _ \ _   _ _ __ ___  _ __   ___ _ __ 
# | | | | | | | '_ ` _ \| '_ \ / _ \ '__|
# | |_| | |_| | | | | | | |_) |  __/ |   
# |____/ \__,_|_| |_| |_| .__/ \___|_|   
#                       |_|           
# Perl module for dumping Perl objects from/to XML
# ============================================================
# 
# Copyright (c) 1998 Jonathan Eisenzopf <eisen@pobox.com>
# XML::Dumper is free software. You can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# ============================================================

=head1 NAME

XML::Dumper - Perl module for dumping Perl objects from/to XML

=head1 SYNOPSIS

  use XML::Dumper;
  my $dump = new XML::Dumper;

  my $perl	= '';
  my $xml	= '';

  # ===== Convert Perl code to XML
  $perl = [
    {
		fname		=> 'Fred',
		lname		=> 'Flintstone',
		residence	=> 'Bedrock'
    },
    {
		fname		=> 'Barney',
		lname		=> 'Rubble',
		residence	=> 'Bedrock'
    }
  ];
  $xml = $dump->pl2xml($perl);

  # ===== Convert XML to Perl code
  $xml = q|
  <perldata>
   <arrayref>
    <item key="0">
     <hashref>
  	<item key="fname">Fred</item>
  	<item key="lname">Flintstone</item>
  	<item key="residence">Bedrock</item>
     </hashref>
    </item>
    <item key="1">
     <hashref>
  	<item key="fname">Barney</item>
  	<item key="lname">Rubble</item>
  	<item key="residence">Bedrock</item>
     </hashref>
    </item>
   </arrayref>
  </perldata>
  |;

  my $perl = $dump->xml2pl($xml);

=head1 DESCRIPTION

XML::Dumper dumps Perl data to XML format. XML::Dumper can also read XML data 
that was previously dumped by the module and convert it back to Perl. Perl
objects are blessed back to their original packaging; if the modules are
installed on the system where the perl objects are reconstituted from xml, they
will behave as expected. Intuitively, if the perl objects are converted and
reconstituted in the same environment, all should be well. And it is.

Another fine challenge that this module rises to meet is that it understands
circular definitions. This includes doubly-linked lists, circular references,
and the so-called 'Flyweight' pattern of Object Oriented programming. So it
can take the gnarliest of your perl data, and should do just fine.

=head2 FUNCTIONS AND METHODS

=over 4

=cut

package XML::Dumper;

require 5.005_62;
use strict;

require Exporter;
use XML::Parser;

our @ISA = qw( Exporter );
our %EXPORT_TAGS = ( 'all' => [ qw( xml_compare xml_identity ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{ 'all' } } );
our @EXPORT = qw( xml_compare xml_identity );
our $VERSION = '0.55'; 

# ============================================================
sub new {
# ============================================================

=item * new - XML::Dumper constructor. 

Creates a lean, mean, XML dumping machine. It's also completely 
at your disposal.

=cut

# ------------------------------------------------------------
    my ($class) = map { ref || $_ } shift;
    my $self = bless {}, $class;

	$self->init;

    return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self = shift;
	$self->{ perldata }	= {};
	$self->{ xml }		= {};
	1;
}

# ============================================================
sub dump {
# ============================================================
	my $self = shift;
	my $ref = shift;
	my $indent = shift;

    my $string = '';

	# ===== REFERENCES
	if( ref $ref ) {
		no warnings;
		local $_ = ref( $ref );
		my $class = '';
		my $address = '';
		my $reused = '';

		PERL_TYPE: {

			# ----------------------------------------
			OBJECT: {
			# ----------------------------------------
				last OBJECT if /^(?:SCALAR|HASH|ARRAY)$/;
				$class = $_;
				&quote_xml_chars( $class );
				($_,$address) = scalar( $ref ) =~ /$class=([^(]+)\(([x0-9A-Fa-f]+)\)/;
			}

			# ----------------------------------------
			MEMORY_ADDRESS: {
			# ----------------------------------------
				last MEMORY_ADDRESS if( $class );
				($_,$address) = scalar( $ref ) =~ /([^(]+)\(([x0-9A-Fa-f]+)\)/;
			}

			$reused = exists( $self->{ xml }{ $address } );

			# ----------------------------------------
			if( /^SCALAR$/ ) {
			# ----------------------------------------
				my $type = 
					"<scalarref". 
					($class ? " blessed_package=\"$class\"" : '' ). 
					($address ? " memory_address=\"$address\"" : '' ).
					">";
				$self->{ xml }{ $address }++ if( $address );
				$string = 
					"\n" . 
					" " x $indent . 
					$type . 
					($reused ? '' : &quote_xml_chars($$ref)) . 
					"</scalarref>";
				last PERL_TYPE;
			}

			# ----------------------------------------
			if( /^HASH$/ ) {
			# ----------------------------------------
				my $type = 
					"<hashref". 
					($class ? " blessed_package=\"$class\"" : '' ). 
					($address ? " memory_address=\"$address\"" : '' ).
					">";
				$string = "\n" . " " x $indent . $type;
				$self->{ xml }{ $address }++ if( $address );
				if( not $reused ) {
					$indent++;
					foreach my $key (sort keys(%$ref)) {
						$string .= "\n" . " " x $indent . "<item key=\"" . &quote_xml_chars($key) . "\">";
						if (ref($ref->{$key})) {
							$string .= $self->dump( $ref->{$key}, $indent+1);
							$string .= "\n" . " " x $indent . "</item>";
						} else {
							$string .= &quote_xml_chars($ref->{$key}) . "</item>";
						}
					}
					$indent--;
				}
				$string .= "\n" . " " x $indent . "</hashref>";
				last PERL_TYPE;
			}

			# ----------------------------------------
			if( /^ARRAY$/ ) {
			# ----------------------------------------
				my $type = 
					"<arrayref". 
					($class ? " blessed_package=\"$class\"" : '' ). 
					($address ? " memory_address=\"$address\"" : '' ).
					">";
				$string .= "\n" . " " x $indent . $type;
				$self->{ xml }{ $address }++ if( $address );
				if( not $reused ) {
					$indent++;
					for (my $i=0; $i < @$ref; $i++) {
						$string .= "\n" . " " x $indent . "<item key=\"$i\">";
						if (ref($ref->[$i])) {
							$string .= $self->dump($ref->[$i], $indent+1);
							$string .= "\n" . " " x $indent . "</item>";
						} else {
							$string .= &quote_xml_chars($ref->[$i]) . "</item>";
						}
					}
					$indent--;
				}
				$string .= "\n" . " " x $indent . "</arrayref>";
				last PERL_TYPE;
			}

		}
    
    # ===== SCALAR
    } else {
		$string .= "\n" . " " x $indent . "<scalar>" . &quote_xml_chars($ref) . "</scalar>";
    }
    
    return($string);
}

# ============================================================
sub pl2xml {
# ============================================================

=item * pl2xml -

Converts Perl data to XML

Usage: See Synopsis

=cut

# ------------------------------------------------------------
    my $self = shift;
	my $ref = shift;

	$self->init;

    return(
		"<perldata>" .
		$self->dump($ref, 1) .
		"\n</perldata>\n"
	);
}

# ============================================================
sub undump {
# ============================================================
# undump
# Takes the XML generated by pl2xml, and recursively undumps it to 
# create a data structure in memory.  The top-level object is a scalar, 
# a reference to a scalar, a hash, or an array. Hashes and arrays may 
# themselves contain scalars, or references to scalars, or references to 
# hashes or arrays, with the exception that scalar values are never 
# "undef" because there's currently no way to represent undef in the dumped 
# data.
#
# ------------------------------------------------------------

	my $self = shift;
    my $tree = shift;
	my $callback = shift;

    my $ref = undef;
    my $FoundScalar;

	# make Perl stop whining about deep recursion and soft references
	no warnings; 

    TREE: for (my $i = 1; $i < $#$tree; $i+=2) {		
		no warnings;
		local $_ = lc( $tree->[ $i ] );
		my $class = '';
		my $address = '';

		PERL_TYPES: {
			# ----------------------------------------
			if( /^scalar$/ ) {
			# ----------------------------------------
			    ## Make a copy of the string
			    $ref = $tree->[$i+1]->[2];
			    last TREE;
			}

			# ===== FIND PACKAGE
			if( $tree->[ $i+1 ] && ref( $tree->[ $i +1 ] ) eq 'ARRAY' ) {
				if( exists $tree->[ $i+1 ][0]{ blessed_package } ) {
					$class = $tree->[ $i+1 ][ 0 ]{ blessed_package };
				}
			}

			# ===== FIND MEMORY ADDRESS
			if( $tree->[ $i+1 ] && ref( $tree->[ $i +1 ] ) eq 'ARRAY' ) {
				if( exists $tree->[ $i+1 ][0]{ memory_address } ) {
					$address = $tree->[ $i+1 ][ 0 ]{ memory_address };
				}
			}

			ALREADY_EXISTS_IN_MEMORY: {
				if( exists $self->{ perldata }{ $address } ) {
					$ref = $self->{ perldata }{ $address };
					last TREE;
				}
			}

			# ----------------------------------------
			if( /^scalarref/ ) {
			# ----------------------------------------
				## Make a ref to a copy of the string
				$ref = \ "$tree->[$i+1]->[2]";
				$self->{ perldata }{ $address } = $ref if( $address );
				if( $class ) {
					bless $ref, $class;
					if( defined $callback && $ref->can( $callback ) ) {
						$ref->$callback();
					}
				}
				last TREE;
			}

			# ----------------------------------------
			if( /^hashref/ ) {
			# ----------------------------------------
				$ref = {};
				$self->{ perldata }{ $address } = $ref if( $address );
				for (my $j = 1; $j < $#{$tree->[$i+1]}; $j+=2) {
					next unless $tree->[$i+1]->[$j] eq 'item';
					my $item_tree = $tree->[$i+1][$j+1];
					if( exists $item_tree->[0]{ key } ) {
						my $key = $item_tree->[ 0 ]{ key };
						$ref->{$key} = $self->undump($item_tree, $callback);
					}
				}
				if( $class ) {
					bless $ref, $class;
					if( defined $callback && $ref->can( $callback ) ) {
						$ref->$callback();
					}
				}
				last TREE;
	    	}

			# ----------------------------------------
			if( /^arrayref/ ) {
			# ----------------------------------------
				$ref = [];
				$self->{ perldata }{ $address } = $ref if( $address );
				for (my $j = 1; $j < $#{$tree->[$i+1]}; $j+=2) {
					next unless $tree->[$i+1]->[$j] eq 'item';
					my $item_tree = $tree->[$i+1][$j+1];
					if( exists $item_tree->[0]{ key } ) {
						my $key = $item_tree->[0]{ key };
						$ref->[$key] = $self->undump($item_tree, $callback);
					}
				}
				if( $class ) {
					bless $ref, $class;
					if( defined $callback && $ref->can( $callback ) ) {
						$ref->$callback();
					}
				}
			    last TREE;
			}

			if( /^0$/ ) {
	    		$FoundScalar = $tree->[$i + 1] unless defined $FoundScalar;
			}
		}
    }

    ## If $ref is not set at this point, it means we've just
    ## encountered a scalar value directly inside the item tag.
    
    $ref = $FoundScalar unless defined($ref);

    return ($ref);
}

# ============================================================
sub quote_xml_chars {
# ============================================================
    $_[0] =~ s/&/&amp;/g;
    $_[0] =~ s/</&lt;/g;
    $_[0] =~ s/>/&gt;/g;
    $_[0] =~ s/'/&apos;/g;
    $_[0] =~ s/"/&quot;/g;
    $_[0] =~ s/([\x80-\xFF])/&XmlUtf8Encode(ord($1))/ge;
    return($_[0]);
}

# ============================================================
sub xml2pl {
# ============================================================

=item * xml2pl -

Converts XML to a Perl datatype. If this method is given a second argument, 
XML::Dumper will use the second argument as a callback (if possible). 

Currently, the only supported invocation of callbacks is through soft
references. That is to say, the callback argument ought to be a string
that matches the name of a callable method for your classes. If you have
a congruent interface, this should work like a peach. If your class
interface doesn't have such a named method, it won't be called. The
null-string method is not supported, because I can't think of a good
reason to support it. (OK, that was lame, but that kind of thinking
makes my head hurt. If you can prove that null-string methods ought to
be allowed, I'll do it. If you don't know what the null-string method is,
curse The Damian for having invoked such a beast, and move along in
blissful ignorance).

=cut

# ------------------------------------------------------------
	my $self = shift;
	my $xml = shift;
	my $callback = shift;

	$self->init;

	my $parser = new XML::Parser(Style => 'Tree');
	my $tree = $parser->parse($xml);

    # Skip enclosing "perldata" level
    my $topItem = $tree->[1];
    my $ref = $self->undump($topItem, $callback);
    
    return($ref);
}

# ============================================================
sub xml_compare {
# ============================================================

=item * xml_compare - Compares xml for content

Compares two dumped Perl data structures (that is, compares the xml) for
identity in content. Use this function rather than perl's built-in string 
comparison, especially when dealing with perl data that is memory-location 
dependent (which pretty much means all references).  This function will 
return true for any two perl data that are either deep clones of each 
other, or identical. This method is exported by default.

=cut

# ------------------------------------------------------------
	my $xml1 = shift;
	my $xml2 = shift;

	$xml1 =~ s/\smemory_address="\dx[A-Za-z0-9]+"//g;
	$xml2 =~ s/\smemory_address="\dx[A-Za-z0-9]+"//g;

	return not( $xml1 cmp $xml2 );
}

# ============================================================
sub xml_identity {
# ============================================================

=item * xml_identity - Compares xml for identity

Compares two dumped Perl data structures (that is, compares the xml) for
identity in instantiation. This function will return true for any two
perl data that are identical, but not for deep clones of each other. This
method is also exported by default.

=cut

# ------------------------------------------------------------
	my $xml1 = shift;
	my $xml2 = shift;

	return ( $xml1 eq $xml2 );
}

# ============================================================
sub XmlUtf8Encode {
# ============================================================
# borrowed from XML::DOM
    my $n = shift;
    if ($n < 0x80) {
	return chr ($n);
    } elsif ($n < 0x800) {
        return pack ("CC", (($n >> 6) | 0xc0), (($n & 0x3f) | 0x80));
    } elsif ($n < 0x10000) {
        return pack ("CCC", (($n >> 12) | 0xe0), ((($n >> 6) & 0x3f) | 0x80),
                     (($n & 0x3f) | 0x80));
    } elsif ($n < 0x110000) {
        return pack ("CCCC", (($n >> 18) | 0xf0), ((($n >> 12) & 0x3f) | 0x80),
                     ((($n >> 6) & 0x3f) | 0x80), (($n & 0x3f) | 0x80));
    }
    return $n;
}

1;
__END__

=back

=head1 BUGS AND DEPENDENCIES

This module is guilty of several cardinal sins, not the least of which is
a change of API.

XML::Dumper has changed API since 0.4. While this violates most every benefit
of object-oriented programming, I felt it was necessary, as the functions
simply didn't work as advertised. That is, xml2pl really didnt accept xml
as an argument; what it wanted was an XML Parse tree. To correct for the 
API change, simply don't parse the XML before feeding it to XML::Dumper.

XML::Dumper also has no understanding of typeglobs (references or not),
references to regular expressions, or references to Perl subroutines.
If the whim strikes me, or if someone needs this feature, I may fix this.
Turns out that Data::Dumper doesn't do references to Perl subroutines,
either, so at least I'm in somewhat good company.

XML::Dumper requires two perl modules, both available from CPAN

	XML::Parser

XML::Parser itself relies on Clark Cooper's Expat implementation in Perl,
which in turn requires James Clark's expat package itself. See the
documentation for XML::Parser for more information.

=head1 REVISIONS

0.55	Removed documentation of non-implemented code, fixed MANIFEST
		errors. Fixed false dependency on Data::Dumper.

0.54	Added ability to handle soft referenced callbacks

0.53	Added ability to handle circular references

0.50	Added ability to dump and undump objects

0.40	I (Mike Wong) downloaded XML::Dumper from CPAN

=head1 CURRENT MAINTAINER

Mike Wong E<lt>mike_w3@pacbell.netE<gt>

=head1 ORIGINAL AUTHOR

Jonathan Eisenzopf E<lt>eisen@pobox.comE<gt>

=head1 CREDITS

Chris Thorman E<lt>ct@ignitiondesign.comE<gt>

L.M.Orchard E<lt>deus_x@pobox.comE<gt>

DeWitt Clinton E<lt>dewitt@eziba.comE<gt>

=head1 SEE ALSO

perl(1), XML::Parser(3).

=cut
