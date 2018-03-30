#!/usr/bin/perl
# Yebeltal Asseged
# Testing :  realself.

use strict;
use warnings;
no warnings;
use URI;
use Web::Scraper;

use Encode;
use lib "lib";
use YAML;
use Text::CSV;
use Term::ProgressBar;

my $count          = 1;
my $total          = 0;
my $total4         = 0;
my $cvsOutput      = "Test.csv";
my @streetAddress  = ();
my @localAddress   = ();
my @regionAddress  = ();
my @postalAddress  = ();
my @fullname       = ();
my @targetWebsite  = ();
my @twitterLink    = ();
my @googlePlusLink = ();
my @phone          = ();
my @linkR          = ();

my $progress_bar4;
my $count1 = 0;
my $count2 = 1;
my $count4;

#start
my $start = 0;

my $csv = Text::CSV->new(
   { binary => 1, auto_diag => 1, eol => "\n" } ) # should set binary attribute.
  or die "Cannot use CSV: " . Text::CSV->error_diag();
open my $fh, ">>", "$cvsOutput" or die "$cvsOutput: $!";

#$csv->print(
#             $fh,
#             [
#               "Full Name",
#               "Phone",
#               "Street Address",
#               "Local Address",
#               "Region Address",
#               "Postal Address",
#               "Website",
#               "Twitter",
#               "Google plus",
#               "Realself Address"
#             ]
#);

# preparation
print "Preparation: \n";
#################################################################################
# get USA links
my $DoctorsLink = scraper
{
 process 'div.page-element', "Doctors[]" => scraper
 {
  process "ul.list-unstyled > li >a", "link[]" => '@href';
 };
};

my @Link       = ();
my $trigerCopy = 0;
my $webScrapeAW =
  $DoctorsLink->scrape( URI->new("http://www.realself.com/find") );
for my $doctors ( @{ $webScrapeAW->{Doctors} } )
{
 if ( $trigerCopy == 2 )
 {
  foreach my $item ( @{ $doctors->{"link"} } )
  {

   if ( $item =~ '\bhttp://www.realself.com/find/Alabama\b' || $trigerCopy )
   {
    push( @Link, $item );

   }
  }
 }
 $trigerCopy++;
}
#################################################################################

#################################################################################
# get international links including canada
my $DoctorsLink = scraper
{
 process 'div.page-element-list', "Doctors[]" => scraper
 {
  process "ul.list-unstyled > li >a", "link[]" => '@href';
 };
};

my $trigerCopy = 0;
$webScrapeAW = $DoctorsLink->scrape( URI->new("http://www.realself.com/find") );
for my $doctors ( @{ $webScrapeAW->{Doctors} } )
{
 if ( $trigerCopy < 2 )
 {
  foreach my $item ( @{ $doctors->{"link"} } )
  {
   # only take the first two hashes
   push( @Link, $item );

   # print $item. "\n";
  }
 }
 $trigerCopy++;
}
#################################################################################

#################################################################################
#scraping
$total = scalar(@Link);
print "Preparation Done.\n\nScraping pages: \n";

#begin scraping pages
foreach my $info ( 0 .. $#Link )
{
 #if ( $count1 > 22 ){ }
 linkCity( @Link[$info] );
 $count1++;

 scrapPrint();

 #  {last;}
}

##################################################################################
#
##################################################################################
##Writing cvs
#scrapPrint();

#################################################################################

#################################################################################
#link city
sub linkCity
{
 my $url = shift;
 my $webScrapeC;

 my @Link2;

 my $DoctorsC = scraper
 {
  process 'div#content', "Doctors[]" => scraper
  {
   process "ul.list-unstyled > li >a", "link[]" => '@href';
  };
 };
 $webScrapeC = $DoctorsC->scrape( URI->new($url) );
 for my $doctors ( @{ $webScrapeC->{Doctors} } )
 {
  foreach my $item ( @{ $doctors->{"link"} } )
  {
   push( @Link2, $item );

  }
 }

 # begin scraping pages
 foreach my $info ( 0 .. $#Link2 )
 {
  getSpeciality( @Link2[$info] );

  #last;
 }
}
#################################################################################

#################################################################################
# get speciality
sub getSpeciality
{
 my $url = shift;
 my $webScrapeS;
 my @Link3;
 my $DoctorsS = scraper
 {
  process 'div.row', "Doctors[]" => scraper
  {
   process "div.col-sm-4 >ul.list-unstyled > li >a", "link[]" => '@href';
  };
 };
 $webScrapeS = $DoctorsS->scrape( URI->new($url) );
 my $count = 0;
 for my $doctors ( @{ $webScrapeS->{Doctors} } )
 {

  if ( $count == 2 )
  {
   foreach my $item ( @{ $doctors->{"link"} } )
   {
    push( @Link3, $item );

    #print $item."\n";
    #browseDoctors($item);
   }
  }

  $count++;
 }

 # begin scraping pages
 foreach my $info ( 0 .. $#Link3 )
 {

  browseDoctors( @Link3[$info] );
 }
}
#################################################################################

#################################################################################
# get doctors link
#browseDoctors(
#             "http://www.realself.com/find/Dominican-Republic/Plastic-Surgeon");

sub browseDoctors
{
 my $url = shift;
 my $webScrapeSp;

 my @Link4;
 my $DoctorsSp = scraper
 {
  process 'div.row', "Doctors[]" => scraper
  {
   process "div.dr-card >div.bd > p.widget-element >a", "link[]" => '@href';
  };
 };
 my $count = 0;
 $webScrapeSp = $DoctorsSp->scrape( URI->new($url) );

 for my $doctors ( @{ $webScrapeSp->{Doctors} } )
 {

  if ( $count == 1 )
  {
   foreach my $item ( @{ $doctors->{"link"} } )
   {

    #print $item."\n";
    #scrapAdd($item);

    push( @Link4, $item );

   }
  }
  $count++;
 }
 $total4 = scalar(@Link4);
 $count4 = 1;

 my $totalC = $count1 / $total * 100;
 print "\n\n Overall: $totalC%  currenlty $url\n";
 $progress_bar4 = Term::ProgressBar->new($total4);

 # begin scraping page
 foreach my $info ( 0 .. $#Link4 )
 {

  scrapAdd( @Link4[$info] );

  $progress_bar4->update($count4);
  $count4++;
 }
}

#################################################################################

#################################################################################
# get values
#scrapAdd(
#"http://www.realself.com/find/California/Riverside/Plastic-Surgeon/Robert-Hardesty#about"
#);

sub scrapAdd
{
 my $url = shift;
 push( @linkR, $url );

 my $DoctorsP = scraper
 {
  process 'div#sidebar', "Doctors[]" => scraper
  {
   process "div > p > span", "phone" => 'TEXT';

  };
 };

 my $DoctorsAdd = scraper
 {
  process 'div.widget-element', "Doctors[]" => scraper
  {
   process "div.widget-element >address > span", "address[]"     => 'TEXT';
   process "p > a",                              "targetWebsite" => 'TEXT';
   process "ul >li > a.twt",                     "targetTwitter" => '@href';
   process "ul >li > a.gplus",                   "targetGoogle"  => '@href';
  };
 };

 # my $DoctorsWeb = scraper
 # {
 #  process 'div.widget-element', "Doctors[]" => scraper
 #  {
 #
 #  };
 # };

 my $DoctorsN = scraper
 {
  process 'div.profile-header-content', "Doctors[]" => scraper
  {
   process "h1", "fullname" => 'TEXT';
  };
 };

 # my $DoctorsTwiter = scraper
 # {
 #  process 'div.widget-element', "Doctors[]" => scraper
 #  {
 #
 #  };
 # };

 # my $DoctorsGoogle = scraper
 # {
 #  process 'div.widget-element', "Doctors[]" => scraper
 #  {
 #
 #  };
 # };

 #  my $DoctorsEducation = scraper
 # {
 #  process 'div#tabs-container > div.tab-pane', "Doctors[]" => scraper
 #  {
 #   process "section.page-element", "targetEdu" => 'TEXT';
 #  };
 # };

 my $webScrapeAdd = $DoctorsAdd->scrape( URI->new($url) );

 #my $webScrapeWeb     = $DoctorsWeb->scrape( URI->new($url) );
 #my $webScrapeTwitter = $DoctorsTwiter->scrape( URI->new($url) );
 #$webScrapeGoogle  = $DoctorsGoogle->scrape( URI->new($url) );
 my $webScrapeN = $DoctorsN->scrape( URI->new($url) );
 my $webScrapeP = $DoctorsP->scrape( URI->new($url) );

 #website
 my $webCount = 1;
 for my $doctors ( @{ $webScrapeAdd->{Doctors} } )
 {
  # it has 4 arrays
  if ( scalar @{ $webScrapeAdd->{Doctors} } != 5 )
  {
   push( @targetWebsite, " " );
   last;
  }

  #if it has 5
  elsif ( $webCount == 5 )
  {
   if ( $doctors->{"targetWebsite"} =~ m/\S+/ )
   {
    push( @targetWebsite, $doctors->{"targetWebsite"} );
   } else
   {
    push( @targetWebsite, " " );
   }
  }
  $webCount++;
 }

 #twitter
 my $webCount = 1;
 for my $doctors ( @{ $webScrapeAdd->{Doctors} } )
 {
  # it has 4 arrays
  if ( scalar @{ $webScrapeAdd->{Doctors} } != 5 )
  {
   push( @twitterLink, " " );
   last;
  }

  #if it has 5
  elsif ( $webCount == 5 )
  {
   if ( $doctors->{"targetTwitter"} =~ m/\S+/ )
   {
    push( @twitterLink, $doctors->{"targetTwitter"} );
   } else
   {
    push( @twitterLink, " " );
   }
  }
  $webCount++;
 }

 #google
 $webCount = 1;
 for my $doctors ( @{ $webScrapeAdd->{Doctors} } )
 {
  # it has 4 arrays
  if ( scalar @{ $webScrapeAdd->{Doctors} } != 5 )
  {
   push( @googlePlusLink, " " );
   last;
  }

  #if it has 5
  elsif ( $webCount == 5 )
  {
   if ( $doctors->{"targetGoogle"} =~ m/\S+/ )
   {
    push( @googlePlusLink, $doctors->{"targetGoogle"} );
   } else
   {
    push( @googlePlusLink, " " );
   }
  }
  $webCount++;
 }

 for my $doctors ( @{ $webScrapeAdd->{Doctors} } )
 {
  #warn Dump $doctors->{"address"};
  if ( $doctors->{"address"}[0] =~ m/\S+/ )
  {
   push( @streetAddress, $doctors->{"address"}[0] );
  } else
  {
   push( @streetAddress, " " );
  }
  if ( $doctors->{"address"}[1] =~ m/\S+/ )
  {
   push( @localAddress, $doctors->{"address"}[1] );
  } else
  {
   push( @localAddress, " " );
  }
  if ( $doctors->{"address"}[2] =~ m/\S+/ )
  {
   push( @regionAddress, $doctors->{"address"}[2] );
  } else
  {
   push( @regionAddress, " " );
  }
  if ( $doctors->{"address"}[3] =~ m/\S+/ )
  {
   push( @postalAddress, $doctors->{"address"}[3] );
  } else
  {
   push( @postalAddress, " " );
  }
  last;
 }

 for my $doctors ( @{ $webScrapeP->{Doctors} } )
 {

  if ( deletePeriod( $doctors->{"phone"} ) =~ m/(d{3})?[0-9]{3}[-]?[0-9]{4}/ )
  {
   push( @phone, deletePeriod( $doctors->{"phone"} ) );
  } else
  {
   push( @phone, " " );
  }

 }

 for my $doctors ( @{ $webScrapeN->{Doctors} } )
 {
  push( @fullname, $doctors->{"fullname"} );
 }

}
#################################################################################

#################################################################################
# write cvs

sub scrapPrint
{

 my $totalP = scalar(@fullname);
 print "\\n\nUpdating your CVS file... ";
 print "\n\n";

 my $progress_bar = Term::ProgressBar->new($totalP);
 foreach my $info ( $start .. $#fullname )
 {

# "Full Name",  "Phone","Street Address","Local Address","Region Address","Postal Address", "Website", "Twitter", "Google plus","Realself Address" ] );
  $csv->print(
               $fh,
               [
                 $fullname[$info],       $phone[$info],
                 @streetAddress[$info],  @localAddress[$info],
                 @regionAddress[$info],  @postalAddress[$info],
                 @targetWebsite[$info],  @twitterLink[$info],
                 @googlePlusLink[$info], @linkR[$info]
               ]
  );

  #  print "Name: "
  #    . $fullname[$info]
  #    . "\nphone: "
  #    . $phone[$info]
  #    . "\nSaddress: "
  #    . @streetAddress[$info]
  #    . "\nLaddress: "
  #    . @localAddress[$info]
  #    . "\nRaddress: "
  #    . @regionAddress[$info]
  #    . "\nPddress: "
  #    . @postalAddress[$info]
  #    . "\ngoogle: "
  #    . @googlePlusLink[$info]
  #    . "\ntwitter: "
  #    . @twitterLink[$info]
  #    . "\nwebsite: "
  #    . @targetWebsite[$info] . "\n\n";

  $progress_bar->update($count2);
  $count2++;

 }

 #$start=$totalP;

}
print "\n\n\nScraping http://www.realself.com/ is now complete\n\n\n";
#################################################################################

# delete period on phone numbers
sub deletePeriod($)
{
 my $string = shift;
 $string =~ s/[.]//g;
 return $string;
}

close $fh;
