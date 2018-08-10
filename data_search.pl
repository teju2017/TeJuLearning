#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

#######################################################################
# Script name  : data_search.pl
# Author       : Thejas HM
# Creatio dt   : 01-JUN-2018
# Description  : Displaying all the records present in the table
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



#############  LOG FILE WRITTER ##############################


sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}


#### Subroutine showing all the data #######################


sub data_select_all()
{
   $quy="select * from onboarding_portal_table order by modification_date desc";
   &logwritter("Calling the Select Query");
   #my $dbh = DBI->connect("dbi:Oracle:DCANU11B","carmen","electra#1") || die "Database connection is failing ";
   my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
   #my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| die "Database connection is failing ";
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
   #print $obj->start_html( -title => "Display ALL");
   print $obj->start_html();
   #print "<head>
   print " <script src=\"../js/jquery-3.2.0.js\"></script>
          <script src=\"../js/jquery-ui.js\"></script>
          <script src=\"../js/jquery.table.transpose.min.js\"></script>
       	  <script src=\"../js/jquery.freezeheader.js\"></script>
	  <script src=\"../js/jquery.tablesorter.js\"></script>
	  <script src=\"../js/jquery.table2excel.js\"></script>
          <h1 align=\"center\">PORTAL DATA - ONBOARDING DETAILS</h1>
          <style>
           h1 {
                color: black;
                font-family:Arial;
                background-color: powderblue;
              }
           </style>

        <tr>
            <th>
                <button id=\"btnTpVertical\" class=\"button\">Transpose</button>
                <button id=\"btnexport\" class=\"button\">Export</button>
	        <br></br>
		<br></br>
            </th>
        </tr>
<style>
.button {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 15px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;

    h1 {
      color: black;
      font-family:Arial;
      background-color: powderblue;
       }



}
</style>";
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

input[type=submit]
{
    width: 12%;
    background-color: #4CAF50;
    color: white;
    padding: 14px 20px;
    margin: 1px 0;
    border: none;
    border-radius: 2px;
    cursor: pointer;
    text-align:center;
}

table.minimalistBlack tbody td {
  font-size: 12px;
  font-family:Arial;
}


thead th.up {
    padding-right: 20px;
    background-image: url(data:image/gif;base64,R0lGODlhFQAEAIAAACMtMP///yH5BAEAAAEALAAAAAAVAAQAAAINjI8Bya2wnINUMopZAQA7);
}

thead th.down {
    padding-right: 20px;
    background-image: url(data:image/gif;base64,R0lGODlhFQAEAIAAACMtMP///yH5BAEAAAEALAAAAAAVAAQAAAINjB+gC+jP2ptn0WskLQA7);
}


table.minimalistBlack thead {
  background: #CFCFCF;
  background: -moz-linear-gradient(top, \#dbdbdb 0%, \#d3d3d3 66\%, \#CFCFCF 100\%);
  background: -webkit-linear-gradient(top, \#dbdbdb 0%, \#d3d3d3 66\%, \#CFCFCF 100\%);
  background: linear-gradient(to bottom, \#dbdbdb 0\%, \#d3d3d3 66\%, \#CFCFCF 100\%);
  border-bottom: 3px solid #000000;
  font-size: 14px;
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
   print "<table id=\"table1\" class=minimalistBlack>
          <thead>
          <tr>
                     <td>CONSULTATION_ID</td>
                      <td>CONSULTATION_NAME</td>
                      <td>RM_SME</td>
                      <td>APPLICATION_CONTACT</td>
                      <td>BUSINESS_DIVISION</td>
                      <td>ISACID</td>
                      <td>ISAC_SOLUTION_NAME</td>
                      <td>CATEGORY</td>
                      <td>PRIORITY</td>
                      <td>REQUEST_ENTRYDATE</td>
                      <td>CONSULT_STARTDATE</td>
                      <td>PLANNED_CONSULT_STARTDT</td>
                      <td>PLANNED_CONSULT_ENDDATE</td>
                      <td>NUMBER_OF_FEEDS</td>
                      <td>TARGET_ARCHIVE</td>
                      <td>LOCATION</td>
                      <td>FOUR_EYE_PRINCIPLE</td>
                      <td>ESTIMATED_EFF</td>
                      <td>ACTUAL_EFF</td>
                      <td>PLANNED_ENDDATE</td>
                      <td>PLANNED_ONBOARDDATE</td>
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
                      <td>SYSTEM_VERSION</td>
                      <td>MODIFIED BY</td>
                      <td>MODIFICATION_DATE</td>
          </tr>
          </thead>\n";
          print "<tbody>";
   while(@data = $sth->fetchrow_array())
   {
       $counter=0;
       #print "Rownum value is $rownum \n";
       foreach $x (@data)
       {
         $counter=$counter+1;
         #print "column no $counter:- $x \n";
         if( $counter eq 1 )
         { 
                $CONSULTATION_ID=	$data[0];
                $CONSULTATION_NAME=	$data[1];
                $RM_SME=	$data[2];
                $APPLICATION_CONTACT=	$data[3];
                $BUSINESS_DIVISION=	$data[4];
                $ISACID=	$data[5];
                $ISAC_SOLUTION_NAME=	$data[6];
                $CATEGORY=	$data[7];
                $PRIORITY=	$data[8];
                $REQUEST_ENTRYDATE=	$data[9];
                $CONSULT_STARTDATE=	$data[10];
                $PLANNED_CONSULT_STARTDT=	$data[11];
                $PLANNED_CONSULT_ENDDATE=	$data[12];
                $NUMBER_OF_FEEDS=	$data[13];
                $TARGET_ARCHIVE=	$data[14];
                $LOCATION=	$data[15];
                $FOUR_EYE_PRINCIPLE=	$data[16];
                $ESTIMATED_EFF=	$data[17];
                $ACTUAL_EFF=	$data[18];
                $PLANNED_ENDDATE=	$data[19];
                $PLANNED_ONBOARDDATE=	$data[20];
                $SERVICETYPE=	$data[21];
                $CONSULTATION_REMARKS=	$data[22];
                $CONSULTATION_STATUS=	$data[23];
                $OBCONTACT=	$data[24];
                $FEEDSDESCRIPTION=	$data[25];
                $APPLICATION_IT_CONTACT=	$data[26];
                $REQUEST_TYPE=	$data[27];
                $LIST_ID=	$data[28];
                $VERSION=	$data[29];
                $ARCHIVE_ID=	$data[30];
                $MANDATOR=	$data[31];
                $TARGETSYSTEM=	$data[32];
                $FORMAT=	$data[33];
                $PLANNED_RELEASE=	$data[34];
                $ACTUAL_RELEASE=	$data[35];
                $BQLINK=	$data[36];
                $TQLINK=	$data[37];
                $PPMPROJECT=	$data[38];
                $COSTOBJECT=	$data[39];
                $ONBOARDSTATUS=	$data[40];
                $ONBOARDINGREMARKS=	$data[41];
                $OVERALLSTATUS=	$data[42];
                $OVERALLREMARKS=	$data[43];
                $SYSTEM_VERSION=	$data[44];
                $EMAIL=	$data[45];
                $MODIFICATION_DATE=	$data[46];

            
               print "<tr>
                         <td>$CONSULTATION_ID</td>
                          <td>$CONSULTATION_NAME</td>
                          <td>$RM_SME</td>
                          <td>$APPLICATION_CONTACT</td>
                          <td>$BUSINESS_DIVISION</td>
                          <td>$ISACID</td>
                          <td>$ISAC_SOLUTION_NAME</td>
                          <td>$CATEGORY</td>
                          <td>$PRIORITY</td>
                          <td>$REQUEST_ENTRYDATE</td>
                          <td>$CONSULT_STARTDATE</td>
                          <td>$PLANNED_CONSULT_STARTDT</td>
                          <td>$PLANNED_CONSULT_ENDDATE</td>
                          <td>$NUMBER_OF_FEEDS</td>
                          <td>$TARGET_ARCHIVE</td>
                          <td>$LOCATION</td>
                          <td>$FOUR_EYE_PRINCIPLE</td>
                          <td>$ESTIMATED_EFF</td>
                          <td>$ACTUAL_EFF</td>
                          <td>$PLANNED_ENDDATE</td>
                          <td>$PLANNED_ONBOARDDATE</td>
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
                          <td>$SYSTEM_VERSION</td>
                          <td>$EMAIL</td>
                          <td>$MODIFICATION_DATE</td>

              </tr>";
           # print "Consultation_id=$Consultation_id \n Consultation_name=$Consultation_name \n request_entdt=$request_entdt \n";
         }
         else
         {
            #print "column $counter:- $x ";
         }
       }
       #print "####################################################";
       $rownum=$rownum+1;
  }
   my $JQUERY= <<END_MESSAGE;
            <script type="text/javascript">
            \$(function () {
            //initialize
            if (!\$("#table1").is(":blk-transpose"))
                \$("#table1").transpose({ mode: 0 });

             });

        \$("#btnTpVertical").click(function () {
            var currentMode = \$("#table1").data("tp_mode");
            if (currentMode == undefined) {
                \$("#table1").transpose("transpose");
               \$("#btnTpVertical").html("Reset");
            }
            else {
                \$("#table1").transpose("reset");
                \$("#btnTpVertical").html("Transpose");
            }
        });
   
       </script>

       <script type="text/javascript">
       \$(document).ready(function () {
            \$("#table1").freezeHeader();
        });

        \$(document).ready(function() 
          {
               \$("#table1").tablesorter();
          });
       </script> 

       <script>
       \$("#btnexport").click(function () {
			   \$("#table1").table2excel(
			{
			  exclude  : ".excludeThisClass",
			  name     : "Onboarding",
			  filename : "Onboarding_portal_information"
			}); 
 
       });
     </script>

      

END_MESSAGE

   print "</tbody>
          </table>";
   print "\n";
   print "$JQUERY
          </body>";
   print "<br></br>";
   print "\n";
   print "<form action=../index.html>
   <input type=submit value=\"GO TO HOME\" align=middle>
   </form>";
   print end_html();   
   END {
   $dbh->disconnect if defined($dbh);
    }
   }


&data_select_all();
