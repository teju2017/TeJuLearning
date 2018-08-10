#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

#######################################################################
# Script name  : data_Custsearch.pl
# Author       : Thejas HM
# Creatio dt   : 27-JUN-2018
# Description  : Custom search contents display and extraction of same
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


##### LOGWRITTER ###########################################################

sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}


######## METHOD EXTRACTING THE COMPLETE MIGRATED DATA #######################

sub data_historical_data()
{
   $quy="select * from ONBOARDING_DETAILS_MIGRATION";
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
  print header();
  print $obj->start_html( -title => "Display ALL");
  print "<style>
  table.minimalistBlack {
  border: 3px solid #000000;
  width: 100%;
  text-align: left;
  border-collapse: collapse;
  }
  table.minimalistBlack td, table.minimalistBlack th {
  border: 1px solid #000000;
  padding: 4px 4px;
  }
  table.minimalistBlack tbody td {
  font-size: 12px;
  font-family:Arial;
  }
  table.minimalistBlack thead {
  background: #CFCFCF;
  background: -moz-linear-gradient(top, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  background: -webkit-linear-gradient(top, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  background: linear-gradient(to bottom, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%); 
  border-bottom: 3px solid #000000;
  font-size: 15px;
  font-weight: bold;
  color: #000000;
  text-align: center;
  font-family:Arial;
}

tr:nth-child(even) td { background: #f2f7f5; }

/* Cells in odd rows (1,3,5...) are another (excludes header cells)  */
tr:nth-child(odd) td { background: #FEFEFE; }

tr td:hover { background: #666; color: #FFF; }
/* Hover cell effect! */

</style>";
   
 print "<table class=minimalistBlack>
      <thead>
       <tr>
         <td>CONSULTATION_ID</td>
        <td>CONSULTATION_NAME</td>
        <td>RM_SME</td>
        <td>APPLICATION_CONTACT</td>
        <td>BUSINESS_DIVISION</td>
        <td>ISACID</td>
        <td>ISAC_SOLNAME</td>
        <td>CATEGORY</td>
        <td>PRIORITY</td>
        <td>ENTRYDATE</td>
        <td>STARTDATE</td>
        <td>ENDDATE</td>
        <td>NUMBER_OF_FEEDS</td>
        <td>TARGET_ARCHIVE</td>
        <td>LOCATION</td>
        <td>PDS</td>
        <td>ESTIMATED_EFF</td>
        <td>ACTUAL_EFF_PDS</td>
        <td>PLANNED_CONS_END_DATE</td>
        <td>PLANNED_ONBOARD_DATE</td>
        <td>SERVICETYPE</td>
        <td>CONSULTATION_REMARKS</td>
        <td>CONSULTATION_STATUS</td>
        <td>OBCONTACT</td>
        <td>FEEDSDESCRIPTION</td>
        <td>APPLICATION_IT_CONTACT</td>
        <td>REQUEST_TYPE</td>
        <td>LIST_ID</td>
        <td>VERSION</td>
        <td>ARCHIVE_ID</td>
        <td>MANDATOR</td>
        <td>TARGETSYSTEM</td>
        <td>FORMAT</td>
        <td>PLANNED_RELEASE</td>
        <td>ACTUAL_RELEASE</td>
        <td>BQLINK</td>
        <td>TQLINK</td>
        <td>PPMPROJECT</td>
        <td>COSTOBJECT</td>
        <td>ONBOARDSTATUS</td>
        <td>ONBOARDINGREMARKS</td>
        <td>OVERALLSTATUS</td>
        <td>OVERALLREMARKS</td>
       </tr>
      </thead>\n";
while(@data = $sth->fetchrow_array())
{
    $counter=0;
    foreach $x (@data)
       {
         $counter=$counter+1;
         if( $counter eq 1 )
         {
           $CONSULTATION_ID=       $data[0];
           $CONSULTATION_NAME=     $data[1];
           $RM_SME=        $data[2];
           $APPLICATION_CONTACT=   $data[3];
           $BUSINESS_DIVISION=     $data[4];
           $ISACID=        $data[5];
           $ISAC_SOLNAME=  $data[6];
           $CATEGORY=      $data[7];
           $PRIORITY=      $data[8];
           $ENTRYDATE=     $data[9];
           $STARTDATE=     $data[10];
           $ENDDATE=       $data[11];
           $NUMBER_OF_FEEDS=       $data[12];
           $TARGET_ARCHIVE=        $data[13];
           $LOCATION=      $data[14];
           $PDS=   $data[15];
           $ESTIMATED_EFF= $data[16];
           $ACTUAL_EFF_PDS=        $data[17];
           $PLANNED_CONS_END_DATE= $data[18];
           $PLANNED_ONBOARD_DATE=  $data[19];
           $SERVICETYPE=   $data[20];
           $CONSULTATION_REMARKS=  $data[21];
           $CONSULTATION_STATUS=   $data[22];
           $OBCONTACT=     $data[23];
           $FEEDSDESCRIPTION=      $data[24];
           $APPLICATION_IT_CONTACT=        $data[25];
           $REQUEST_TYPE=  $data[26];
           $LIST_ID=       $data[27];
           $VERSION=       $data[28];
           $ARCHIVE_ID=    $data[29];
           $MANDATOR=      $data[30];
           $TARGETSYSTEM=  $data[31];
           $FORMAT=        $data[32];
           $PLANNED_RELEASE=       $data[33];
           $ACTUAL_RELEASE=        $data[34];
           $BQLINK=        $data[35];
           $TQLINK=        $data[36];
           $PPMPROJECT=    $data[37];
           $COSTOBJECT=    $data[38];
           $ONBOARDSTATUS= $data[39];
           $ONBOARDINGREMARKS=     $data[40];
           $OVERALLSTATUS= $data[41];
           $OVERALLREMARKS=        $data[42];
 
         print "<tr>
                     <td>$CONSULTATION_ID</td>
                     <td>$CONSULTATION_NAME</td>
                     <td>$RM_SME</td>
                     <td>$APPLICATION_CONTACT</td>
                     <td>$BUSINESS_DIVISION</td>
                     <td>$ISACID</td>
                     <td>$ISAC_SOLNAME</td>
                     <td>$CATEGORY</td>
                     <td>$PRIORITY</td>
                     <td>$ENTRYDATE</td>
                     <td>$STARTDATE</td>
                     <td>$ENDDATE</td>
                     <td>$NUMBER_OF_FEEDS</td>
                     <td>$TARGET_ARCHIVE</td>
                     <td>$LOCATION</td>
                     <td>$PDS</td>
                     <td>$ESTIMATED_EFF</td>
                     <td>$ACTUAL_EFF_PDS</td>
                     <td>$PLANNED_CONS_END_DATE</td>
                     <td>$PLANNED_ONBOARD_DATE</td>
                     <td>$SERVICETYPE</td>
                     <td>$CONSULTATION_REMARKS</td>
                     <td>$CONSULTATION_STATUS</td>
                     <td>$OBCONTACT</td>
                     <td>$FEEDSDESCRIPTION</td>
                     <td>$APPLICATION_IT_CONTACT</td>
                     <td>$REQUEST_TYPE</td>
                     <td>$LIST_ID</td>
                     <td>$VERSION</td>
                     <td>$ARCHIVE_ID</td>
                     <td>$MANDATOR</td>
                     <td>$TARGETSYSTEM</td>
                     <td>$FORMAT</td>
                     <td>$PLANNED_RELEASE</td>
                     <td>$ACTUAL_RELEASE</td>
                     <td>$BQLINK</td>
                     <td>$TQLINK</td>
                     <td>$PPMPROJECT</td>
                     <td>$COSTOBJECT</td>
                     <td>$ONBOARDSTATUS</td>
                     <td>$ONBOARDINGREMARKS</td>
                     <td>$OVERALLSTATUS</td>
                     <td>$OVERALLREMARKS</td>
         </tr>";
        }
        else
        {
      
        }
     }
}
   print "</table>";
   print "\n";
   print "<br></br>";
   print "\n";
   print "<form action=../index.html>
   <input type=submit value=GotoHome align=middle>
   </form>";
   print end_html();
   END {
   $dbh->disconnect if defined($dbh);
 }
   }


###################################
# Calling the subroutine
###################################

&data_historical_data();
