#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

#######################################################################
# Script name  : data_extract.pl
# Author       : Thejas HM
# Creatio dt   : 01-JUN-2018
# Description  : extracting the records into a file and mailing it
#######################################################################



use CGI ':standard';


use lib qw(
/opt/apache24/lib
/sbclocal/gdmp/lib/perl/
/sbcimp/run/pd/csm/64-bit/cpan/5.16.3-2013.03/lib
);


use CGI;
use DBI;
use DBD::Oracle;
use Data::Dumper;
use YAML;

$ENV{ORACLE_HOME}="/sbcimp/run/tp/oracle/client/v11.2.0.3-64bit/client_1";
$ENV{LD_LIBRARY_PATH}="/sbclocal/gdmp/lib";
$ENV{PERL5LIB}="/sbcimp/run/pkgs/CORE/15.1.0/lib";
$ENV{TNS_ADMIN}="/sbclocal/gdmp/etc";


my $obj = new CGI;



#############  HTTP VARIABLE DECLARATION ##############################

my @http_array = http();
my $to_address=http('HTTP_SSO_EMAIL');
$filename="/tmp/Onboarding_details.csv";


sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}


##### SUBROUTINE EXTRACTING THE DATA ###########################


sub data_extract()
{
   $quy="select * from onboarding_portal_table order by modification_date desc";
   &logwritter("This is the data extraction method");
   &logwritter("Calling the Select Query");
   my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
   $dbh->{AutoCommit}    = 1;
   $dbh->{RaiseError}    = 1;
   $dbh->{ora_check_sql} = 0;
   $dbh->{RowCacheSize}  = 16;
   $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD'");
   &logwritter("Just before the Prepare statement");
   my $sth = $dbh->prepare($quy);
   $sth->execute();
   &logwritter("Executed the insert statement successfully");
   $rownum=1;
   $counter=0;
   $delim=","; 
   $col_count=0;
   open(FH,">$filename")||die "Cannot create the file \n";
   while($col_count < $sth->{NUM_OF_FIELDS})
   {
      if($col_count==0)
      {
         $column_list=$sth->{NAME_uc}->[$col_count].$delim;
      }
      else
      {
         $column_list=$column_list.$sth->{NAME_uc}->[$col_count].$delim;
      }
      $col_count=$col_count+1;
   }
   print FH $column_list;
   print FH "\n";
   while(@data = $sth->fetchrow_array())
   {
     $count=$count+1;
     foreach $line (@data)
     {
        if ( $count == 1 )
        {
          $val=$line.",";
          $count=0;
        }
        else
        {
          $val=$val.$line.",";
        }
     }
     print FH $val;
     print FH "\n";
   }
   close(FH);
}


######## MAIL SENDING SUBROUTINE ##########################

sub mail_sending()
{

  if ( ! defined $to_address ) 
  {
        print header();
        print $obj->start_html( -title => "Display ALL");
        print "<h3>TO_ADDRESS VARIABLE VALUE IS EMPTY</h3>";
        print end_html();
  }
  else
  {
        #system('/bin/mailx -a $filename -s "ONBOARDING DETAILS EXTRACT" $to_address </tmp/msg.dat');
        $mail_string='/bin/mailx -a '.$filename.' -s "ONBOARDING DETAILS EXTRACT" '. $to_address.'</sbclocal/gdmp/web/conf/msg.dat'; 
        &logwritter("mail string is ",$mail_string); 
        system($mail_string);
        print header(); 
        print $obj->start_html( -title => "Display ALL");
        #print "<h3>TO_ADDRESS VARIABLE CONTAINS VALUE</h3>";
        #print "<p>$mail_string</p>";
        print "<h3>Mail has been sent to $to_address, Kindly check </h3>";
        print end_html();
  }
}

############################################################
##  CALLING THE SUBROUTINE
############################################################

&data_extract();
&mail_sending();
