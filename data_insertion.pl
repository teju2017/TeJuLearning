#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

########################################################################
# Script name  : data_insertion.pl
# Author       : Thejas HM
# Creatio dt   : 01-JUN-2018
# Description  : Script to take the values from the submission form and 
#                to call the loading script
########################################################################


use CGI ':standard';


push(@INC,'/sbcimp/run/pd/csm/64-bit/perl/5.16.3/lib/5.16.3');


my $obj = new CGI;


$ENV{ORACLE_HOME}="/sbcimp/run/tp/oracle/client/v11.2.0.3-64bit/client_1";


####### BASIC INFORMATION #################


$Consult=$obj->param('Consult');
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

######## Taking the value from the HTTP ########################

my @http_array = http();
my $http_val=http('HTTP_SSO_EMAIL');

###### Take the sequence value and version ###############################

$consultation_id='consult_id_seq';
$system_version=0;

#####  Calling the script to insert the data into the database ###################

@param_array=($consultation_id,$Conname,$SME,$Appcontact,$BD,$isacid,$isacname,$Category,$priority,$entrydate,$startdate,$enddate,$consult_enddt,$feedsno,$archive,$location,$pds,$estimated_effort,$Actual_effort,$planned_con_enddt,$onboard_date,$servicetype,$Consultremarks,$Consultstatus,$OBContact,$Feeddescription,$AppITContact,$Request_type,$listid,$version,$archid,$LE,$tarsys,$frmat,$planrls,$Actrel,$Bqlink,$Tqlink,$PPMproject,$Costobj,$Onbostatus,$Obremarks,$overallstat,$Ovlstat,$system_version,$http_val);

##### Calling the script to insert the data #####################################

system('/sbclocal/gdmp/web/cgi-bin/database.pl',@param_array);
