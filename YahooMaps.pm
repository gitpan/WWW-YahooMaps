package WWW::YahooMaps;

require 5.005_62;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our $VERSION = '0.1';

use URI::Escape;

sub stringtolink {

    my ($country, $language, $string, $swap) = @_;

    $string =~ m@^([^\;\n]+)[\;\n]+([^\;\n]+)@s;
    my ($street, $city) = ($1, $2);

    if ($swap) {
	($street, $city) = ($city, $street);
    }

    my %addr = (
		"street" => $street,
		"city" => $city,
		"country" => $country,
		"language" => $language,
		);
        
    my $url = hashreftolink(\%addr);

    return $url;
}

sub hashreftolink {

    my ($rh_addr) = @_;

    #test if the language we want exists, whether we have given at least a country and a city
    if (&testlang($rh_addr->{language}) && 
        &testcountry($rh_addr->{country}) &&
        &cleanstring($rh_addr->{city})) {

        $rh_addr->{language} = &ukcheck($rh_addr->{language});
        $rh_addr->{country} = &ukcheck($rh_addr->{country});

	my $langdot = '';
	if ($rh_addr->{language} eq "us") {
	    $rh_addr->{language} = "";
	} else {
	    $langdot = '.';
	}

        my $url = "";
        $url  = "http://" . $rh_addr->{language} . $langdot . "maps.yahoo.com";
	$url .= "/py/lg:" . $rh_addr->{language};
	$url .= "/lc:" . $rh_addr->{language};
	$url .= "/maps.py?BFCat=&Pyt=Tmap&newFL=";    

        # street
        if ($rh_addr->{street}){
	    my $street = cleanstring($rh_addr->{street});
	    $street = uri_escape($street);  
	    $url .= "&addr=" . $street;
        }

        # city
        my $city = cleanstring($rh_addr->{city});
        $city = uri_escape($city);  
        $url .= "&csz=" . $city;

        # country
        $url .= "&country=" . $rh_addr->{country}; 
                                         
	return $url;

    } else {
	return 0;
    }

}

sub ukcheck {
    # needed because "uk" is not a ISO 3166 code
    # "gb" is the code, but Yahoo! uses uk
 
    my ($string) = @_;
    if ($string eq "gb"){
        return "uk";
    } else {
        return $string;
    }
}

sub testlang {

    my ($lang)  = @_;

    if ($lang){ 
	# list of languages in which Yahoo offers maps
	my %langs = (
		     "de" => 1,
		     "es" => 1,
		     "fr" => 1,
		     "gb" => 1,
		     "it" => 1,
		     "uk" => 1,
		     "us" => 1,
		     ); 
	return $langs{$lang} ? 1 : 0 ;
    } else {
        return 0;
    }
}

sub testcountry {

    my ($cty)  = @_;

    if ($cty){ 
	# list of countries for which Yahoo has maps
	my %ctys = (
		    "at" => 1,
		    "be" => 1,
		    "ch" => 1,
		    "de" => 1,
		    "es" => 1,
		    "fr" => 1,
		    "gb" => 1,
		    "it" => 1,
		    "lu" => 1,
		    "nl" => 1,
		    "pt" => 1,
		    "uk" => 1,
		    "us" => 1,
		    ); 
	return $ctys{$cty} ? 1 : 0 ;
    } else {
        return 0;
    }
}

sub cleanstring {
    #remove unecessary whitespace
    my ($string) = @_;
    $string =~ s@\n@ @g;   
    $string =~ s@^\s+@@g;      
    $string =~ s@\s+$@@g;      
    return $string;
}



1;

__END__

#documentation starts here - README

=head1 NAME

WWW::YahooMaps - Create links to Yahoo! Maps

=head1 SYNOPSIS

 use WWW::YahooMaps;

 #first method: PASSING ADDRESS BIT-BY-BIT
 my %addr = (
  "street" => "Rämistrasse 5",
  "city" => "8006 Zuerich",
  "country" => "ch",
  "language" => "de",
 );

 if (my $url = WWW:YahooMaps::hashreftolink(\%addr)){
      print "url1 $url\n";
 }

 #second method: ADDRESS INFO IN STRING
 #seperators can be ";" or newline "\n"
 #street should come before city
 #pass an additional 1 at the end if you want to pass city first
 if (my $url = WWW::YahooMaps::stringtolink("us","us","101 Morris Street; Sebastopol, CA 95472")){
      print "url2 $url\n";
 }


 if (my $url = WWW::YahooMaps::stringtolink("fr","fr","75017 Paris; 11 bis, rue Torricelli", 1)){
      print "url3 $url\n";
 }

Code above will print:

url1 http://de.maps.yahoo.com/py/lg:de/lc:de/maps.py?BFCat=&Pyt=Tmap&newFL=&addr=R%E4mistrasse%205&csz=8006%20Zuerich&country=ch

url2 http://maps.yahoo.com/py/lg:/lc:/maps.py?BFCat=&Pyt=Tmap&newFL=&addr=101%20Morris%20Street&csz=Sebastopol,%20CA%2095472&country=us

url3 http://fr.maps.yahoo.com/py/lg:fr/lc:fr/maps.py?BFCat=&Pyt=Tmap&newFL=&addr=11%20bis,%20rue%20Torricelli&csz=75017%20Paris&country=fr



=head1 DESCRIPTION

Pass a reference to a hash to hashreftolink() and get a link to the corresponding Yahoo! map.
Or, if you have a ready-string with the adress info, pass it to stringtolink() - see restrictions on $string above.

They offer maps for several countries - use the domain name for the {country} key. Currently available countries are: 

 - Austria (at)
 - Belgium (be)
 - France (fr)
 - Germany (de)
 - Italy (it)
 - Luxembourg (lu)
 - Netherlands (nl)
 - Portugal (pt)
 - Spain (es)
 - Switzerland (ch)
 - U.S.A. (us)
 - United Kingdom (gb/uk)

Note that you can display maps for Germany in French, by passing "fr" as {language} and "de" as {country}.
Supported languages are: 

 - American English (us)
 - British English (uk)
 - French (fr) 
 - German (de)
 - Italian (it)
 - Spanish (es)

The language also determines which Yahoo server is used - the servers for language="us" are in the US, while servers for all others are in Europe.

If Yahoo can't find the exact address you pass, it will show the user its best guess with some alternative links.

=head1 REQUIREMENTS

uses URI::Escape.

=head1 AUTHOR

Gabor Cselle, gaborcselle@yahoo.de

=head1 THANKS TO

Ed Freyfogle, who wrote the original version.

=head1 SEE ALSO

Find lists of ISO 3166 country codes here:
http://dir.yahoo.com/Reference/Standards/International_and_Regional_Standards_Bodies/International_Organization_for_Standardization__ISO_/ISO_Country_Codes/

=cut
