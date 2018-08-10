#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

#########################################################################
## Script name  : data_updation.pl
## Author       : Thejas HM
## Creatio dt   : 01-JUN-2018
## Description  : Script to take the values from the submission form and
##                to call the loading script
#########################################################################


use CGI ':standard';


push(@INC,'/sbcimp/run/pd/csm/64-bit/perl/5.16.3/lib/5.16.3');


my $obj = new CGI;


$ENV{ORACLE_HOME}="/sbcimp/run/tp/oracle/client/v11.2.0.3-64bit/client_1";

use lib qw(
/opt/apache24/lib
/sbclocal/gdmp/lib/perl/
/sbcimp/run/pd/csm/64-bit/cpan/5.16.3-2013.03/lib
);

#MYG  End  Tag - GERA EOL
#
use CGI;
use DBI;
use DBD::Oracle;
use Data::Dumper;
use YAML;

$ENV{ORACLE_HOME}="/sbcimp/run/tp/oracle/client/v11.2.0.3-64bit/client_1";
$ENV{LD_LIBRARY_PATH}="/sbclocal/gdmp/lib";
$ENV{PERL5LIB}="/sbcimp/run/pkgs/CORE/15.1.0/lib";
$ENV{TNS_ADMIN}="/sbclocal/gdmp/etc";

my $rowmod;
my @param_array_edit;



####### BASIC INFORMATION #################


$Consultation_id=$obj->param('Consult');
$Conname=$obj->param('Consultationname');
$SME=$obj->param('RMSME');
$Appcontact=$obj->param('Applicationcontact');
$BD=$obj->param('Businessdivision');
$isacid=$obj->param('isacid');
$isacname=$obj->param('isacname');
$Category=$obj->param('Category');
$priority=$obj->param('Priority');

####### RM CONSULTING #####################

$entrydate=$obj->param('Requestentrydate');
$startdate=$obj->param('Consultationstartdate');
$enddate=$obj->param('plannedconsultenddate');
$consult_enddt=$obj->param('Consultenddate');
$feedsno=$obj->param('feedsno');
$archive=$obj->param('tararchive');
$location=$obj->param('locate');
$pds=$obj->param('principleapplied');
$estimated_effort=$obj->param('Estimated effort');
$Actual_effort=$obj->param('Actualeffort');
$planned_con_enddt=$obj->param('planned_consult_end_dt');
$onboard_date=$obj->param('planned_consult_end_dt');
$servicetype=$obj->param('servicetype');
$Consultremarks=$obj->param('Consultremarks');
$Consultstatus=$obj->param('Consultstatus');

########## ONBOARDING PREPARATION ###############

$OBContact=$obj->param('OBContact');
$Feeddescription=$obj->param('Feeddescription');
$AppITContact=$obj->param('AppITContact');
$Request_type=$obj->param('Request_type');
$listid=$obj->param('listid');
$version=$obj->param('version');
$archid=$obj->param('archid');
$LE=$obj->param('mandator');
$tarsys=$obj->param('targetsystem');
$frmat=$obj->param('format');
$planrls=$obj->param('planrelease');
$Actrel=$obj->param('Actrelease');
$Bqlink=$obj->param('BQLink');
$Tqlink=$obj->param('TQLink');
$PPMproject=$obj->param('PPMproject');
$Costobj=$obj->param('Costobject');
$Onbostatus=$obj->param('Oboardingstatus');
$Obremarks=$obj->param('OBremarks');

########## OVERALL INFORMATION ##############

$overallstat=$obj->param('overallstatus');
$Ovlstat=$obj->param('overallremarks');
$system_version="0";

######### Taking the value from the HTTP ########################

my @http_array = http();
my $http_val=http('HTTP_SSO_EMAIL');


my @param_array_edit=($Consultation_id,$Conname,$SME,$Appcontact,$BD,$isacid,$isacname,$Category,$priority,$entrydate,$startdate,$enddate,$consult_enddt,$feedsno,$archive,$location,$pds,$estimated_effort,$Actual_effort,$planned_con_enddt,$onboard_date,$servicetype,$Consultremarks,$Consultstatus,$OBContact,$Feeddescription,$AppITContact,$Request_type,$listid,$version,$archid,$LE,$tarsys,$frmat,$planrls,$Actrel,$Bqlink,$Tqlink,$PPMproject,$Costobj,$Onbostatus,$Obremarks,$overallstat,$Ovlstat,$system_version,$http_val);


##### LOG WRITTER ################################################


sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}



################# SQL QUERY FORMATION ##########################

sub sql_formation()
{
   @columns=@{$_[0]};
  
  $insert_statement="insert into onboarding_portal_table (CONSULTATION_ID,CONSULTATION_NAME,RM_SME,APPLICATION_CONTACT,BUSINESS_DIVISION,ISACID,ISAC_SOLUTION_NAME,CATEGORY,PRIORITY,REQUEST_ENTRYDATE,CONSULT_STARTDATE,PLANNED_CONSULT_STARTDT,PLANNED_CONSULT_ENDDATE,NUMBER_OF_FEEDS,TARGET_ARCHIVE,LOCATION,FOUR_EYE_PRINCIPLE,ESTIMATED_EFF,ACTUAL_EFF,PLANNED_ENDDATE,PLANNED_ONBOARDDATE,SERVICETYPE,CONSULTATION_REMARKS,CONSULTATION_STATUS,OBCONTACT,FEEDSDESCRIPTION,APPLICATION_IT_CONTACT,REQUEST_TYPE,LIST_ID,VERSION,ARCHIVE_ID,MANDATOR,TARGETSYSTEM,FORMAT,PLANNED_RELEASE,ACTUAL_RELEASE,BQLINK,TQLINK,PPMPROJECT,COSTOBJECT,ONBOARDSTATUS,ONBOARDINGREMARKS,OVERALLSTATUS,OVERALLREMARKS,SYSTEM_VERSION,EMAIL,MODIFICATION_DATE) values (";


   $counter=0;
   $length=@columns;

   &logwritter("length of array is $length");

   foreach $var (@columns)
   {
      $counter=$counter+1;
      if ( $counter == 1 )
      {
         $var1="consult_id_seq.nextval".",";
      }
      else
      {
         $var1=$var1."'".$var."'".",";
      }
   }
   $sysdate="sysdate";
   $var1=$var1.$sysdate.")";
   $final_statement=$insert_statement." ".$var1;
   return $final_statement;

}


################## Data insertion method ###########################

sub data_updation()
{
   my $query=@_[0];
   &logwritter("DATA_CLONING_INSERT: AM INSIDE THE data_updation now ");
   &logwritter("QUERY VALUE iS $query");
   eval {
       my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
       $dbh->{AutoCommit}    = 1;
       $dbh->{RaiseError}    = 1;
       $dbh->{ora_check_sql} = 0;
       $dbh->{RowCacheSize}  = 16;
       $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD'");
       my $sth = $dbh->prepare($query);
       $sth->execute();
       $rowmod=$sth->rows();
       &logwritter("Executed the insert statement successfully and rowmod value is $rowmod");
       END {
               $dbh->disconnect if defined($dbh);
           }
       };
}

########## CALLING THE METHODS IN THIS PROGRAM ######################

&logwritter("Paramter passed is @ARGV");
&logwritter("value is $par_length");
&logwritter("Calling the data_updation method");
&logwritter("Insert query method is $insert_quy");
my $insert_query=&sql_formation(\@param_array_edit);
my $ins_quy=$insert_query;
&logwritter("INSERT_QUERY VALUE IS $insert_query");
&data_updation($ins_quy) && system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"DATA SUBMISSION SUCCESSFUL");
if ($@)
{
      &logwritter("Value of rowmod is $rowmod ");
      system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"DATA SUBMISSION FAILED, If you are using IE, make sure the data field is given in the YYYY-MM-DD format");
}
