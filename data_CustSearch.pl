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


sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}



my $obj = new CGI;


#########################################################################
##### SUBROUTINE TO SEND THE EXTRACTED DATA  
#########################################################################

sub mail_sending_custom()
{

   ($to_address,$filename)=@_;
   &logwritter("TO_ADRESS VARIABLE IS :$to_address and filename is $filename");

  if ( ! defined $to_address )
  {
        print header();
        print $obj->start_html( -title => "Display ALL");
        print "<h3>TO_ADDRESS VARIABLE VALUE IS EMPTY</h3>";
        print end_html();
  }
  else
  {
        eval {
        $mail_string='/bin/mailx -a '.$filename.' -s "ONBOARDING SEARCH DETAILS EXTRACT" '. $to_address.'</sbclocal/gdmp/web/conf/msg_1.dat';
        &logwritter("mail string is ",$mail_string);
        system($mail_string);
        print header();
        print $obj->start_html( -title => "Display ALL");
        #print "<h3>TO_ADDRESS VARIABLE CONTAINS VALUE</h3>";
        #print "<p>$mail_string</p>";
        print "<h3>Search results have been sent to $to_address, Kindly check after a minute</h3>";
        print end_html();
        };
        if ($@)
        {
              system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"ISSUE IN SENDING THE MAIL TO $to_address, drop a mail to thejas-holalker.murulidhara@ubs.com for the issue");
        }
  }
}

###############################################################################
### SUBROUTINE TO EXTRACT THE INFORMATION BASED ON THE SEARCH CONDITION #######
###############################################################################

sub data_cust_extract()
{
    ($custquery,$tpin,$to_add)=@_;

    if ( defined $tpin)
    {
        $filename_cust="/tmp/".$tpin."_onboarding_extract.csv";
    }
    if (! $filename_cust)
    {
        &logwritter("Some serious error in the filename creation ");
        exit 1;
    }
       &logwritter("DATA_CUST_EXTRACT:FILE NAME IS $filename_cust ");
          
    my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
    $dbh->{AutoCommit}    = 1;
    $dbh->{RaiseError}    = 1;
    $dbh->{ora_check_sql} = 0;
    $dbh->{RowCacheSize}  = 16;
    $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD'");
    &logwritter("Just before the Prepare statement");
    my $sth = $dbh->prepare($quy);
    $sth->execute();
    &logwritter("DATA_CUST_EXTRACT:Executed the insert statement successfully");
    $rownum=1;
    $counter=0;
    $delim=",";
    $col_count=0;
    open(FH,">$filename_cust")||die "Cannot create the file \n";
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
   &logwritter("DATA_CUST_EXTRACT:CALLING THE MAIL SENDING METHOD");
   &mail_sending_custom($to_add,$filename_cust);
   &logwritter("DATA_CUST_EXTRACT:mail_sending=$to_add,filename=$filename_cust");
}


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
        $mail_string='/bin/mailx -a '.$filename_cust.' -s "ONBOARDING DETAILS EXTRACT" '. $to_address.'</sbclocal/gdmp/web/conf/msg.dat';
        &logwritter("mail string is ",$mail_string);
        my $ret=system($mail_string);
        if($ret eq 0 )
        {
                system("/sbclocal/gdmp/web/cgi-bin/message_display.pl","Mail has been sent to $to_address, Kindly check after a minute");
        }
        #print header();
        #print $obj->start_html( -title => "Display ALL");
        #print "<h3>TO_ADDRESS VARIABLE CONTAINS VALUE</h3>";
        #print "<p>$mail_string</p>";
        #print "<h3>Mail has been sent to $to_address, Kindly check after a minute </h3>";
        #print end_html();
  }
}


##############################################################################
#### Subroutine forming the search query and is calling when clicked on
#### Search and extract
##############################################################################

sub data_query_formation()
{
   my ($con_id,$entry_startdt,$entry_enddt,$tgt_system,$consult_name,$email,$con_status,$tpin,$to_address)=@_;
   &logwritter("DATA_QUERY_FORMATION:PRINTING THE VALUE OF THE VARIABLES");
   &logwritter($con_id,$entry_startdt,$entry_enddt,$tgt_system,$consult_name);
   if($con_id)
   {
       $String_1='consultation_id='."'".$con_id."'";
   }
   else
   {
       $String_1='1=1';
   }
   if ($entry_startdt)
   {
        $String_2='trunc(modification_date) >=to_date('."'".$entry_startdt."'".",'"."YYYY-MM-DD"."')";
   }
   else
   {
        $String_2='2=2'
   }
   if ($entry_enddt)
   {
        $String_3='trunc(modification_date) <=to_date('."'".$entry_enddt."'".",'"."YYYY-MM-DD"."')";
   }
   else
   {
         $String_3='3=3';
   }
   if (defined $tgt_system)
   {
      if ( $tgt_system eq 4 )
      {
          $String_4='4=4';
      }
      else
      {
          $String_4='TARGETSYSTEM='."'".$tgt_system."'";
      }
   }
   else
      {
          $String_4='4=4';
      }
   if ($consult_name)
   {
      $String_5='CONSULTATION_NAME='."'".$consult_name."'";
   }
   else
   {
      $String_5='5=5';
   }
   if ($email)
   {
      $String_6='email='."'".$email."'";
   }
   else
   {
      $String_6='6=6';
   }
   if (defined $con_status)
   {
      if  ( $con_status eq 7 )
      {
         $String_7='7=7';
      }
      else
      {
         $String_7='CONSULTATION_STATUS='."'".$con_status."'";
      }
   }
   else
   {
      $String_7='7=7';
   }
   $FINAL_WHERE_CLAUSE="where ".$String_1." and ".$String_2. " and ".$String_3." and ".$String_4." and ".$String_5." and ".$String_6. " and " .$String_7. " ORDER BY CONSULTATION_ID,SYSTEM_VERSION DESC";
   $FINAL_QUERY='select * from onboarding_portal_table '.$FINAL_WHERE_CLAUSE;
   $quy=$FINAL_QUERY;
   &logwritter("DATA_QUERY_FORMATION:$FINAL_QUERY");
   &logwritter("Calling the Select Query");
   &logwritter("DATA_QUERY_FORMATION :Calling the Final query for Custom Search");
   &data_cust_extract($quy,$tpin,$to_address);
}


###############################################################################
## Subroutine to form the custom search query and displaying the result list
##############################################################################
   
        
sub data_custom_search()
{
   my ($con_id,$entry_startdt,$entry_enddt,$tgt_system,$consult_name,$email,$con_status)=@_;
   &logwritter("PRINTING THE VALUE OF THE VARIABLES");
   &logwritter($con_id,$entry_startdt,$entry_enddt,$tgt_system,$consult_name);
   #if( defined $con_id)
   if($con_id)
   {
      $String_1='consultation_id='."'".$con_id."'";
   }
   else
   {
      $String_1='1=1';
   }
   if ($entry_startdt)
   {
       $String_2='trunc(modification_date) >=to_date('."'".$entry_startdt."'".",'"."YYYY-MM-DD"."')";
   }
   else
   {
       $String_2='2=2'
   }
   if ($entry_enddt)
   {
       $String_3='trunc(modification_date) <=to_date('."'".$entry_enddt."'".",'"."YYYY-MM-DD"."')";
   }
   else
   {
      $String_3='3=3';
   }
   if (defined $tgt_system)
   {
      if ( $tgt_system eq 4 )
      {
         $String_4='4=4';
      }
      else
      {
         $String_4='TARGETSYSTEM='."'".$tgt_system."'";
      }
   }
   else
   {
      $String_4='4=4';
   }
   if ($consult_name)
   {
      $String_5='CONSULTATION_NAME='."'".$consult_name."'";
   }
   else
   {
      $String_5='5=5';
   }
   if ($email)
   {
      $String_6='email='."'".$email."'";
   }
   else
   {
      $String_6='6=6';
   } 
   if (defined $con_status)
   {
      if  ( $con_status eq 7 )
      {
         $String_7='7=7';
      }
      else
     {
         $String_7='CONSULTATION_STATUS='."'".$con_status."'";
     }
  }
  else
  {
     $String_7='7=7';
  }
   $FINAL_WHERE_CLAUSE="where ".$String_1." and ".$String_2. " and ".$String_3." and ".$String_4." and ".$String_5." and ".$String_6." and ". $String_7." ORDER BY CONSULTATION_ID,SYSTEM_VERSION DESC";
   #print "Final clause is $FINAL_WHERE_CLAUSE \n";
   $FINAL_QUERY='select * from onboarding_portal_table '.$FINAL_WHERE_CLAUSE;
   $quy=$FINAL_QUERY;
   #print "Final query is $FINAL_QUERY \n";
   &logwritter("Calling the Select Query");
   &logwritter("Calling the Final query for Custom Search");
   &logwritter($quy);
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
  print "<script src=\"../js/jquery-3.2.0.js\"></script>
           <script src=\"../js/jquery-ui.js\"></script>
           <script src=\"../js/jquery.table.transpose.min.js\"></script>
           <script src=\"../js/jquery.freezeheader.js\"></script>
           <script src=\"../js/jquery.tablesorter.js\"></script>
           <script src=\"../js/jquery.table2excel.js\"></script>
   <tr>
            <th>
                <button id=\"btnTpVertical\" class=\"button\">Transpose</button>
                <button id=\"btnexport\" class=\"button\">Export</button>
                <br></br>
                <br></br>
            </th>
        </tr>";
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

.button {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 15px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    font-family: Arial;
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
   print "<table id=\"table1\" table class=minimalistBlack>
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
                \$("#table1").tablesorter({
                cssAsc: 'up',
                cssDesc: 'down'
                });
          }
          );
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
   print "<form action=../CustomSearch.html>
   <input type=submit value=BACK align=middle>
   </form>";
   print end_html();
   END {
   $dbh->disconnect if defined($dbh);
}
}

sub data_selected_columns()
{
    my ($con_id,$entry_startdt,$entry_enddt,$tgt_system,$consult_name,$email,$con_status)=@_;
   &logwritter("PRINTING THE VALUE OF THE VARIABLES");
   &logwritter($con_id,$entry_startdt,$entry_enddt,$tgt_system,$consult_name);
   if($con_id)
   {
   $String_1='consultation_id='."'".$con_id."'";
   }
   else
   {
   $String_1='1=1';
   }
   if ($entry_startdt)
   {
   $String_2='trunc(modification_date) >=to_date('."'".$entry_startdt."'".",'"."YYYY-MM-DD"."')";
   }
   else
   {
   $String_2='2=2'
   }
   if ($entry_enddt)
   {
   $String_3='trunc(modification_date) <=to_date('."'".$entry_enddt."'".",'"."YYYY-MM-DD"."')";
   }
   else
   {
   $String_3='3=3';
   }
   if (defined $tgt_system)
   {
   if ( $tgt_system eq 4 )
   {
   $String_4='4=4';
   }
   else
   {
   $String_4='TARGETSYSTEM='."'".$tgt_system."'";
   }
   }
   else
   {
   $String_4='4=4';
   }
    if ($consult_name)
   {
      $String_5='CONSULTATION_NAME='."'".$consult_name."'";
   }
   else
   {
      $String_5='5=5';
   }
   if ($email)
   {
      $String_6='email='."'".$email."'";
   }
   else
   {
      $String_6='6=6';
   }
   if (defined $con_status)
   {
      if  ( $con_status eq 7 )
      {
         $String_7='7=7';
      }
      else
     {
         $String_7='CONSULTATION_STATUS='."'".$con_status."'";
     }
  }
  else
  {
     $String_7='7=7';
  }
   $FINAL_WHERE_CLAUSE="where ".$String_1." and ".$String_2. " and ".$String_3." and ".$String_4." and ".$String_5." and ".$String_6." and ". $String_7." ORDER BY CONSULTATION_ID,SYSTEM_VERSION DESC";
   $FINAL_QUERY='select * from onboarding_portal_table '.$FINAL_WHERE_CLAUSE;
   $quy=$FINAL_QUERY;
   #print "Final query is $FINAL_QUERY \n";
   &logwritter("Calling the Select Query");
   &logwritter("Calling the Final query for Custom Search");
   &logwritter($quy);
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
  print "<script src=\"../js/jquery-3.2.0.js\"></script>
           <script src=\"../js/jquery-ui.js\"></script>
           <script src=\"../js/jquery.table.transpose.min.js\"></script>
           <script src=\"../js/jquery.freezeheader.js\"></script>
           <script src=\"../js/jquery.tablesorter.js\"></script>
           <script src=\"../js/jquery.table2excel.js\"></script>
   <tr>
            <th>
                <button id=\"btnTpVertical\" class=\"button\">Transpose</button>
                <button id=\"btnexport\" class=\"button\">Export</button>
                <br></br>
                <br></br>
            </th>
   </tr>";
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

.button {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 15px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
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
   print "<table id=\"table1\" table class=minimalistBlack>
          <thead>
          <tr>
                  <td>CONSULTATION_ID</td>
                  <td>CONSULTATION_NAME</td>
                  <td>RM_SME</td>
                  <td>APPLICATION_CONTACT</td>
                  <td>BUSINESS_DIVISION</td>
                  <td>ISACID</td>
                  <td>CATEGORY</td>
                  <td>PRIORITY</td>
                  <td>CONSULT_STARTDATE</td>
                  <td>NUMBER_OF_FEEDS</td>
                  <td>TARGET_ARCHIVE</td>
                  <td>LOCATION</td>
                  <td>PLANNED_ONBOARDDATE</td>
                  <td>CONSULTATION_REMARKS</td>
                  <td>CONSULTATION_STATUS</td>
                  <td>PPMPROJECT</td>
                  <td>COSTOBJECT</td>
                  <td>SYSTEM_VERSION</td>
                  <td>MODIFIED BY</td>
                  <td>MODIFICATION_DATE</td>
          </tr>
          </thead>\n";
          print "<tbody>";
   while(@data = $sth->fetchrow_array())
   {
       $counter=0;
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
                    $CATEGORY=	$data[7];
                    $PRIORITY=	$data[8];
                    $CONSULT_STARTDATE=	$data[10];
                    $NUMBER_OF_FEEDS=	$data[13];
                    $TARGET_ARCHIVE=	$data[14];
                    $LOCATION=	$data[15];
                    $PLANNED_ONBOARDDATE=	$data[20];
                    $CONSULTATION_REMARKS=	$data[22];
                    $CONSULTATION_STATUS=	$data[23];
                    $PPMPROJECT=	$data[38];
                    $COSTOBJECT=	$data[39];
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
                       <td>$CATEGORY</td>
                       <td>$PRIORITY</td>
                       <td>$CONSULT_STARTDATE</td>
                       <td>$NUMBER_OF_FEEDS</td>
                       <td>$TARGET_ARCHIVE</td>
                       <td>$LOCATION</td>
                       <td>$PLANNED_ONBOARDDATE</td>
                       <td>$CONSULTATION_REMARKS</td>
                       <td>$CONSULTATION_STATUS</td>
                       <td>$PPMPROJECT</td>
                       <td>$COSTOBJECT</td>
                       <td>$SYSTEM_VERSION</td>
                       <td>$EMAIL</td>
                       <td>$MODIFICATION_DATE</td>
              </tr>";
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
                \$("#table1").tablesorter({
                cssAsc: 'up',
                cssDesc: 'down'
                });
          }
          );
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
   print "<form action=../CustomSearch.html>
   <input type=submit value=BACK align=middle>
   </form>";
   print end_html();
   END {
   $dbh->disconnect if defined($dbh);
}
}



   
    


#----------- Getting the value from search screen --------------------------

my $a=$obj->param('consult_id');
my $b=$obj->param('Entry_date');
my $c=$obj->param('Entry_date_end');
my $d=$obj->param('TARGET');
my $e=$obj->param('Consultancy_Name');
my $f=$obj->param('email_id');
my $g=$obj->param('Consultstatus');
my @http_array = http();
my $email_add=http('HTTP_SSO_EMAIL');
my $tnumber=http('HTTP_SSO_GUID');
&logwritter("PRINT THE VALUE BEFORE CHECKING WITH THE IF : $a $b $c $d $e $f $g");
if ($obj->param('search_extract'))
{
    &data_query_formation($a,$b,$c,$d,$e,$f,$g,$tnumber,$email_add);
    &logwritter("cust extract values $a,$b,$c,$d,$e,$f,$g,$tnumber,$email_add");
}
if ($obj->param('showall'))
{    
  &data_custom_search($a,$b,$c,$d,$e,$f,$g);
  &logwritter("print value of a is $a,b is $b, c is $c, d is $d , e is $e, f is $f g is $g ");
}
if ($obj->param('fewcolumns'))
{
  &data_selected_columns($a,$b,$c,$d,$e,$f,$g);
  &logwritter("value of a is $a,b is $b, c is $c, d is $d , e is $e, f is $f g is $g");
}
