# 
# Copyright (c) 1998 Jonathan Eisenzopf <eisen@pobox.com>
# XML::Dumper is free software. You can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package XML::Dumper;

BEGIN {
    use strict;
    use vars qw($VAR1 $VERSION $ref $index);
    use Data::Dumper;
    $VERSION = '0.02';
}

sub new {
    my $class = {};
    local($index) = 0;
    bless $class;
}

sub xml2pl {
    my ($obj,$xml) = @_;
    return Dumper($xml);
}

sub pl2xml {
    my ($obj,$ref) = @_;
    print "<perl>";
    &Tree2XML($ref);
    print "\n</perl>\n";
}

sub Tree2XML {
    local ($ref) = shift;

    $index++;

    # SCALAR
    if (ref($ref) eq 'SCALAR') {
	print "\n", " "x$index, "<scalar>$$ref</scalar>";

    # HASH
    } elsif (ref($ref) eq 'HASH') {
	print "\n", " "x$index, "<hash>"; $index++;
	foreach my $key (keys(%$ref)) {
	    print "\n", " "x$index, "<key value=\"$key\">";
	    if (ref($ref->{$key})) {
		&Tree2XML($ref->{$key});
	    } else {
		print "$ref->{$key}</key>";
	    }
	}
	print "\n", " "x$index, "</hash>";

    # ARRAY
    } elsif (ref($ref) eq 'ARRAY') {
	print "\n", " "x$index, "<array>"; $index++;
	for (my $i=0; $i < @$ref; $i++) {
	    print "\n", " "x$index, "<item subscript=\"$i\">";
	    if (ref($ref->[$i])) {
		&Tree2XML($ref->[$i]);
	    } else {
		print "$ref->[$i]</item>";
	    }
	}
	print "\n", " "x$index, "</array>";
    }
    $index--;
}


1;
__END__

=head1 NAME

XML::Dumper - Perl module for dumping Perl objects into XML

=head1 SYNOPSIS

  use XML::Parser;
  use XML::Dumper;

  # create a new XML::Parser instance using Tree Style
  $parser = new XML::Parser (Style => 'Tree');

  # create new instance of XML::Dumper
  $dump = new XML::Dumper;

  # Convert XML to Perl code
  $tree = $parser->parsefile($file); 
  $tree = $parser->parse('<foo id="me">Hello World</foo>');
  # print the results
  print $dump->xml2pl($tree);

  # Convert Perl code to XML 
  # read file in Data::Dumper format
  open(PL,$file) || die "Cannot open $file: $!";
  $perl = eval(join("",<PL>));
  # print the results
  print $dump->pl2xml($perl);


=head1 DESCRIPTION

XML::Dumper can dump an XML file to Perl code using
Data::Dumper, or dump Perl code into XML.

This is done via the following 2 methods:
XML::Dumper::xml2pl
XML::Dumper::pl2xml

This module was originally intended for an article I
wrote for TPJ, but I wasn't able to work it in; but
maybe you'll find it useful.

Currently, you can only dump array and hashes. I plan
on adding the ability to dump more complex objects in
the future.

=head1 AUTHOR

Jonathan Eisenzopf, eisen@pobox.com

=head1 SEE ALSO

perl(1), XML::Parser(3).

=cut
