#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

##############################################################################
# Script name  : data_modify.pl
# Author       : Thejas HM
# Creatio dt   : 10-JUL-2018
# Description  : Script to display the modify page and insert the changes
#                into the database
#############################################################################



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



my @value_array;
my $SYSTEM_VERSION;
my $record_counter;

#########################################################################
## Getting the value from the DB for the consultation id passed
#########################################################################

sub data_get_values()
{
    $con_id=shift;
    &logwritter("Calling the modify programe for the consultation id : $con_id");
    if( ! $con_id )
    {
       &logwritter("FATAL ERROR, no value found for the consultation_id");
       system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"FATAL ERROR, no value found for the consultation_id");
    }
    $query="select * from onboarding_portal_table where consultation_id=".$con_id."  and system_version=(select max(system_version) from onboarding_portal_table where consultation_id=".$con_id.")";
    #print "Query value is $query";
    my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
    $dbh->{AutoCommit}    = 1;
    $dbh->{RaiseError}    = 1;
    $dbh->{ora_check_sql} = 0;
    $dbh->{RowCacheSize}  = 16;
    $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD'");
    &logwritter("Just before the Prepare statement");
    my $sth = $dbh->prepare($query);
    $sth->execute();
    &logwritter("Executed the insert statement successfully");
    $rownum=1;
    while(@data = $sth->fetchrow_array())
    {
       $counter=0;
       $record_count=@data;
       if($record_count == 0 )
       {
           &logwritter("RECORD COUNT VALUE WHILE UPDATION IS :$record_count");
           system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"NO RECORD FOUND FOR THE CONSULTATION ID $con_id, check in the search page");
       }
           foreach $x (@data)
           {
             $counter=$counter+1;
             $record_counter=$record_counter+1;
             if( $counter eq 1 )
             {
                    $CONSULTATION_ID=   $data[0];
                    $CONSULTATION_NAME= $data[1];
                    $RM_SME=    $data[2];
                    $APPLICATION_CONTACT=       $data[3];
                    $BUSINESS_DIVISION= $data[4];
                    $ISACID=    $data[5];
                    $ISAC_SOLUTION_NAME=        $data[6];
                    $CATEGORY=  $data[7];
                    $PRIORITY=  $data[8];
                    $REQUEST_ENTRYDATE= $data[9];
                    $CONSULT_STARTDATE= $data[10];
                    $PLANNED_CONSULT_STARTDT=   $data[11];
                    $PLANNED_CONSULT_ENDDATE=   $data[12];
                    $NUMBER_OF_FEEDS=   $data[13];
                    $TARGET_ARCHIVE=    $data[14];
                    $LOCATION=  $data[15];
                    $FOUR_EYE_PRINCIPLE=        $data[16];
                    $ESTIMATED_EFF=     $data[17];
                    $ACTUAL_EFF=        $data[18];
                    $PLANNED_ENDDATE=   $data[19];
                    $PLANNED_ONBOARDDATE=       $data[20];
                    $SERVICETYPE=       $data[21];
                    $CONSULTATION_REMARKS=      $data[22];
                    $CONSULTATION_STATUS=       $data[23];
                    $OBCONTACT= $data[24];
                    $FEEDSDESCRIPTION=  $data[25];
                    $APPLICATION_IT_CONTACT=    $data[26];
                    $REQUEST_TYPE=      $data[27];
                    $LIST_ID=   $data[28];
                    $VERSION=   $data[29];
                    $ARCHIVE_ID=        $data[30];
                    $MANDATOR=  $data[31];
                    $TARGETSYSTEM=      $data[32];
                    $FORMAT=    $data[33];
                    $PLANNED_RELEASE=   $data[34];
                    $ACTUAL_RELEASE=    $data[35];
                    $BQLINK=    $data[36];
                    $TQLINK=    $data[37];
                    $PPMPROJECT=        $data[38];
                    $COSTOBJECT=        $data[39];
                    $ONBOARDSTATUS=     $data[40];
                    $ONBOARDINGREMARKS= $data[41];
                    $OVERALLSTATUS=     $data[42];
                    $OVERALLREMARKS=    $data[43];
                    $SYSTEM_VERSION=    $data[44];
                    $EMAIL=     $data[45];
                    $MODIFICATION_DATE= $data[46];

         }
       }  
    }

    if ( $record_counter > 0 )
    {
               @value_array=($CONSULTATION_NAME,$RM_SME,$APPLICATION_CONTACT,$BUSINESS_DIVISION,$ISACID,$ISAC_SOLUTION_NAME,$CATEGORY,$PRIORITY,$REQUEST_ENTRYDATE,$CONSULT_STARTDATE,$PLANNED_CONSULT_STARTDT,$PLANNED_CONSULT_ENDDATE,$NUMBER_OF_FEEDS,$TARGET_ARCHIVE,$LOCATION,$FOUR_EYE_PRINCIPLE,$ESTIMATED_EFF,$ACTUAL_EFF,$PLANNED_ENDDATE,$PLANNED_ONBOARDDATE,$SERVICETYPE,$CONSULTATION_REMARKS,$CONSULTATION_STATUS,$OBCONTACT,$FEEDSDESCRIPTION,$APPLICATION_IT_CONTACT,
   $REQUEST_TYPE,$LIST_ID,$VERSION,$ARCHIVE_ID,$MANDATOR,$TARGETSYSTEM,$FORMAT,$PLANNED_RELEASE,$ACTUAL_RELEASE,$BQLINK,$TQLINK,$PPMPROJECT,$COSTOBJECT,$ONBOARDSTATUS,$ONBOARDINGREMARKS,$OVERALLSTATUS,$OVERALLREMARKS);

     
     &logwritter("SYSTEM VERSION VALUE IS $SYSTEM_VERSION ");
     
     if ( defined $SYSTEM_VERSION )
     {
          $SYSTEM_VERSION=$SYSTEM_VERSION+1;
          &logwritter("SYSTEM VERSION VALUE AFTER MODIFICATION FOR CONSULTATION ID $CONSULTATION_ID IS $SYSTEM_VERSION");
     }

          &logwritter("CALLING THE DATA_EDIT_DISPLAY METHOD"); 
          &data_edit_display($CONSULTATION_NAME,$RM_SME,$APPLICATION_CONTACT,$BUSINESS_DIVISION,$ISACID,$ISAC_SOLUTION_NAME,$CATEGORY,$PRIORITY,$REQUEST_ENTRYDATE,$CONSULT_STARTDATE,$PLANNED_CONSULT_STARTDT,$PLANNED_CONSULT_ENDDATE,$NUMBER_OF_FEEDS,$TARGET_ARCHIVE,$LOCATION,$FOUR_EYE_PRINCIPLE,$ESTIMATED_EFF,$ACTUAL_EFF,$PLANNED_ENDDATE,$PLANNED_ONBOARDDATE,$SERVICETYPE,$CONSULTATION_REMARKS,$CONSULTATION_STATUS,$OBCONTACT,$FEEDSDESCRIPTION,$APPLICATION_IT_CONTACT,$REQUEST_TYPE,$LIST_ID,$VERSION,$ARCHIVE_ID,$MANDATOR,$TARGETSYSTEM,$FORMAT,$PLANNED_RELEASE,$ACTUAL_RELEASE,$BQLINK,$TQLINK,$PPMPROJECT,$COSTOBJECT,$ONBOARDSTATUS,$ONBOARDINGREMARKS,$OVERALLSTATUS,$OVERALLREMARKS,$SYSTEM_VERSION);
  }
  else
  {
        &logwritter("RECORD COUNT VALUE WHILE UPDATION IS :$record_counter");
        system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"NO RECORD FOUND FOR THE CONSULTATION ID $con_id, Kindly help to check in the search page");
  }
}
 

###########################################################################
## THIS METHOD DISPLAY THE FORM OF THE RECORD THAT NEEDS MODIFICATION
##########################################################################

sub data_edit_display()
{

   my ($CONSULTATION_NAME_PARAM,$RM_SME_PARAM,$APPLICATION_CONTACT_PARAM,$BUSINESS_DIVISION_PARAM,$ISACID_PARAM,$ISAC_SOLUTION_NAME_PARAM,$CATEGORY_PARAM,$PRIORITY_PARAM,$REQUEST_ENTRYDATE_PARAM,$CONSULT_STARTDATE_PARAM,$PLANNED_CONSULT_STARTDT_PARAM,$PLANNED_CONSULT_ENDDATE_PARAM,$NUMBER_OF_FEEDS_PARAM,$TARGET_ARCHIVE_PARAM,$LOCATION_PARAM,$FOUR_EYE_PRINCIPLE_PARAM,$ESTIMATED_EFF_PARAM,$ACTUAL_EFF_PARAM,$PLANNED_ENDDATE_PARAM,$PLANNED_ONBOARDDATE_PARAM,$SERVICETYPE_PARAM,$CONSULTATION_REMARKS_PARAM,$CONSULTATION_STATUS_PARAM,$OBCONTACT_PARAM,$FEEDSDESCRIPTION_PARAM,$APPLICATION_IT_CONTACT_PARAM,$REQUEST_TYPE_PARAM,$LIST_ID_PARAM,$VERSION_PARAM,$ARCHIVE_ID_PARAM,$MANDATOR_PARAM,$TARGETSYSTEM_PARAM,$FORMAT_PARAM,$PLANNED_RELEASE_PARAM,$ACTUAL_RELEASE_PARAM,$BQLINK_PARAM,$TQLINK_PARAM,$PPMPROJECT_PARAM,$COSTOBJECT_PARAM,$ONBOARDSTATUS_PARAM,$ONBOARDINGREMARKS_PARAM,$OVERALLSTATUS_PARAM,$OVERALLREMARKS_PARAM,$SYSTEM_VERSION_PARAM)=@_;


   #print "value of array after passing is @_ \n";
   
   
   

   print header();
   print $obj->start_html( -title => "Display ALL");
   print "<head>
           <title>RM CONSULTANCY ON BOARDING DETAILS</title>
           <h1>ONBOARDING DETAILS - MODIFICATION</h1>
           <img src=\"../ubs-logo.png\" alt=UBS Logo height=150 width=150>
           <script type=\"text/javascript\"
           src=\"../html5Forms.js-master/shared/js/modernizr.com/Modernizr-2.5.3.forms.js\">
           </script>
           <script type=\"text/javascript\"
           data-webforms2-support=\"date\"
           data-lang=\"en\"
           src=\"../html5Forms.js-master/shared/js/html5Forms.js\" > 
           </script> 
           </head>";
   print "<style>
h1 {
    text-align: center;
    color: black;
    font-family:Arial;
    background-color: powderblue;
}
</style>

<style>
input[type=number], select {
    width: 100%;
    padding: 12px 20px;
    margin: 8px 0;
    display: inline-block;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

input[type=text], select {
    width: 100%;
    padding: 12px 20px;
    margin: 8px 0;
    display: inline-block;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

input[type=date], select {
    width: 100%;
    padding: 12px 20px;
    margin: 10px 0;
    display: inline-block;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

input[type=submit] {
    width: 100%;
    background-color: #4CAF50;
    color: white;
    padding: 14px 20px;
    margin: 1px 0;
    border: none;
    border-radius: 2px;
    cursor: pointer;
        text-align:center;
}

input[type=submit]:hover {
    background-color: #45a049;
}

div {
    border-radius: 5px;
    background-color: #f2f2f2;
    padding: 20px;
}

  .center {
    text-align: center;
    border: 1.5px solid green;

   .Core {
            width: 10em;
            margin-right: 1em;
            padding:40px;
            height:425px;
            text-align:left
         }
        }

.Section2 {
    text-align: center;
    border:  1.5px solid green;

   .Core2 {
          padding:40px;
          height: 680px;
          width: 10em;
          text-align:left;
          margin-right: 1em;
         }

       }

.Section3{
    text-align: center;
    border:  1.5px solid green;

  .Core3 {
          padding:40px;
          height: 1000px;
          width: 10em;
          text-align:left;
          margin-right: 1em;
         }

}

.Section4{
    text-align: center;
    border:  1.5px solid green;

        .Core4 {
      padding:40px;
          height: 90px;
          width: 10em;
          text-align:left;
          margin-right: 1em;
         }



</style>";

print "<div class=center>
  <p>BASIC INFORMATION</p>
</div>

<div class=insert>
<div>
<form action=/cgi-bin/data_updation.pl method=GET>
<div class=Core>
 

  <div>
    <label for=name>CONSULTATION ID (read only)</label>
    <input type=number id=cid name=\"Consult\" value=\"$CONSULTATION_ID\" readonly=\"readonly\">
    <br></br>
  </div>


  <div>
    <label for=name>CONSULTATION NAME<span style=color:red;>*</span> </label>
    <input type=text id=conname name=Consultationname maxlength=100 required value=\"$CONSULTATION_NAME_PARAM\">
        <br></br>
  </div>

  <div>
    <label for=text>RM SME</label>
    <input type=text id=RM SME name=RMSME maxlength=100 value=\"$RM_SME_PARAM\">
    <br></br>
  </div>

  <div>
    <label for=msg>APPLICATION CONTACT</label>
    <input type=text id=appcontact name=Applicationcontact maxlength=100 value=\"$APPLICATION_CONTACT_PARAM\">
    <br></br>
  </div>

  <div>
    <label for=msg>BUSINESS DIVISION</label>
    <input type=text id=bd name=Businessdivision maxlength=100 value=\"$BUSINESS_DIVISION_PARAM\">
    <br></br>
  </div>

  <div>
    <label for=msg>I-SAC SOLUTION ID<span style=color:red;>*</span> </label>
    <input type=text id=isolid name=isacid maxlength=10 required value=\"$ISACID_PARAM\">
        <br></br>
  </div>

   <div>
    <label for=msg>I-SAC SOLUTION NAME<span style=color:red;>*</span> </label>
    <input type=text id=isolname name=isacname maxlength=10 required value=\"$ISAC_SOLUTION_NAME_PARAM\">
        <br></br>
  </div>

   <div>
    <label for=Category>CATEGORY</label>
    <select id=Category name=Category>
      <option value=$CATEGORY_PARAM>$CATEGORY_PARAM</option>
      <option value=MiFIDII>MiFIDII</option>
      <option value=ORI>ORI</option>
      <option value=Regulatory>Regulatory</option>
      <option value=1WMP>1WMP</option>
      <option value=Legal>Legal</option>
      <option value=CX2020>CX2020</option>
      <option value=GDPR>GDPR</option>
      <option value=DEC>DEC</option>
    </select>
   </div>

 <div>
    <label for=msg>PRIORITY<span style=color:red;>*</span> </label>
    <select id=pri name=Priority maxlength=5 required>
     <option value=$PRIORITY_PARAM>$PRIORITY_PARAM</option>
     <option value=High>HIGH</option>
     <option value=Low>LOW</option>
     <option value=Medium>MEDIUM</option>
     </select>
      <br></br>
  </div>

</div>

<body>
<div class=Section2>
  <p>RM CONSULTING</p>
</div>

</body>



<div class=Core2>

   <label for=textvalue>CONSULTATION START_DATE <span style=color:red;>*</span> </label>
    <input type=date id=constdt name=Consultationstartdate required value=$CONSULT_STARTDATE_PARAM>
        <br></br>
  </div>

   <div>
    <label for=msg>PLANNED_CONSULT_END_DATE<span style=color:red;>*</span> </label>
    <input type=date id=plconenddt name=plannedconsultenddate required value=$PLANNED_CONSULT_STARTDT_PARAM>
     <br></br>
  </div>

  <div>
    <label for=msg>CONSULTATION_END_DATE<span style=color:red;>*</span> </label>
    <input type=date id=conenddt name=Consultenddate required value=$PLANNED_CONSULT_ENDDATE_PARAM>
        <br></br>
  </div>

  <div>
    <label for=msg>NUMBER_OF_FEEDS</label>
    <input type=number id=feedsno name=feedsno value=\"$NUMBER_OF_FEEDS_PARAM\">
        <br></br>
  </div>

    <div>
         <label for=Category>TARGET_ARCHIVE</label>
         <select id=tarsystems name=tararchive>
         <option value=$TARGET_ARCHIVE_PARAM>$TARGET_ARCHIVE_PARAM</option>
         <option value=E-Comms>E-COMMS</option>
         <option value=ELA>ELA</option>
         <option value=GERA>GERA</option>
         <option value=Hidaras>HIDARAS</option>
         <option value=IDMS-LEGACY>IDMS-LEGACY</option>
         <option value=IDMS-1WMP>IDMS-1WMP</option>
         <option value=LAZAR>LAZAR</option>
         <option value=Legal File Archive>LEGAL FILE ARCHIVE</option>
         <option value=Multiple>MULTIPLE</option>
         <option value=No archiving needed>NO ARCHIVING NEEDED</option>
         <option value=OnDemand DE>ONDEMAND DE</option>
         <option value=Physical Archive>PHYSICAL ARCHIVE</option>
    </select>
        <br></br>
  </div>

   <div>
         <label for=Category>LOCATION</label>
         <select id=loc name=locate>
         <option value=$LOCATION_PARAM>$LOCATION_PARAM</option>
         <option value=CH>CH</option>
         <option value=DE>DE</option>
         <option value=HK>HK</option>
         <option value=HK/SG>HK/SG</option>
         <option value=IT>IT</option>
         <option value=JP>JP</option>
         <option value=SG>SG</option>
         <option value=Multiple>MULTIPLE</option>
         <option value=TW>TW</option>
         <option value=UK>UK</option>
         <option value=US>US</option>
    </select>
     <br></br>
  </div>

 <div>
   <label for=msg>4 EYE PRINCIPLE APPLIED (Y/N)</label>
    <select id=tarsystems name=principleapplied value=$FOUR_EYE_PRINCIPLE_PARAM>
           <option value=$FOUR_EYE_PRINCIPLE_PARAM>$FOUR_EYE_PRINCIPLE_PARAM</option>
           <option value=Y>Y</option>
           <option value=N>N</option>
   </select>
   <br></br>
  </div>


    <div>
    <label for=msg>ESTIMATED EFFORT(PDS)</label>
    <input type=text id=esteff name=Estimated effort maxlength=30 value=\"$ESTIMATED_EFF_PARAM\">
    <br></br>
    </div>

     <div>
    <label for=msg>ACTUAL EFFORT(PDS)</label>
    <input type=text id=acteff name=Actualeffort maxlength=30 value=\"$ACTUAL_EFF_PARAM\">
    <br></br>
     </div>

    <div>
       <label for=msg>PLANNED_CONSULTANCY_END_DT</label>
       <input type=date id=pl_con_end_dt name=planned_consult_end_dt value=\"$PLANNED_ENDDATE_PARAM\">
       <br></br>
     </div>

        <div>
      <label for=msg>PLANNED_CONSULTANCY_ONBOARD_DT</label>
      <input type=date id=pl_con_on_dt name=planned_con_onboard_date value=$PLANNED_ONBOARDDATE_PARAM>
      <br></br>
   </div>

    <div>
      <label for=msg>SERVICE TYPE</label>
      <input type=text id=servtype name=servicetype maxlength=30 value=\"$SERVICETYPE_PARAM\">
       <br></br>
    </div>


    <div>
    <label for=msg>CONSULTATION REMARKS</label>
    <input type=text id=conremarks name=Consultremarks maxlength=250 value=\"$CONSULTATION_REMARKS_PARAM\">
     <br></br>
  </div>

  <div>
    <label for=msg>CONSULTATION STATUS</label>
      <select id=constatus name=Consultstatus>
         <option value=\"$CONSULTATION_STATUS_PARAM\">$CONSULTATION_STATUS_PARAM</option>
         <option value=COMPLETED>COMPLETED</option>
         <option value=\"IN PROGRESS\">IN PROGRESS</option>
         <option value=\"IN RATIFICATION\">IN RATIFICATION</option>
         <option value=ONHOLD>ONHOLD</option>
         <option value=OPEN>OPEN</option>
         <option value=POSTPONED>POSTPONED</option>
     </select>
    <br></br>
  </div>

</div>

<div class=Section3>
  <p>ONBOARDING PREPARATION</p>
</div>

<div class=Core3>
  <div>
    <label for=name>OB CONTACT</label>
    <input type=text id=obcon name=OBContact maxlength=100 value=\"$OBCONTACT_PARAM\">
    <br></br>
  </div>

  <div>
    <label for=textvalue>FEED DESCRIPTION</label>
    <input type=text id=feeddesc name=Feeddescription maxlength=300 value=\"$FEEDSDESCRIPTION_PARAM\">
     <br></br>
  </div>

  <div>
    <label for=msg>APPLICATION IT CONTACT</label>
    <input type=text id=appitcon name=AppITContact maxlength=100 value=\"$APPLICATION_IT_CONTACT_PARAM\">
     <br></br>
  </div>

  <div>
    <label for=msg>REQUEST TYPE</label>
    <input type=text id=reqtype name=Request_type maxlength=100 value=\"$REQUEST_TYPE_PARAM\">
     <br></br>
  </div>

  <div>
    <label for=msg>LIST ID</label>
    <input type=text id=Liid name=listid maxlength=100 value=\"$LIST_ID_PARAM\">
        <br></br>
  </div>

  <div>
    <label for=msg>VERSION</label>
    <input type=text id=ver name=version maxlength=100 value=\"$VERSION_PARAM\">
        <br></br>
  </div>

  <div>
    <label for=msg>ARCHIVE ID</label>
    <input type=text id=arid name=archid maxlength=10 value=\"$ARCHIVE_ID_PARAM\">
        <br></br>
  </div>

  <div>
    <label for=msg>MANDATOR <span style=color:red;>*</span>  </label>
    <input type=text id=mand name=mandator maxlength=4 required value=\"$MANDATOR_PARAM\">
        <br></br>
  </div>

  <div>
    <label for=msg>TARGET SYSTEM</label>
        <select id=target_textvalue name=targetsystem>
         <option value=$TARGETSYSTEM_PARAM>$TARGETSYSTEM_PARAM</option>
         <option value=E-Comms>E-COMMS</option>
         <option value=ELA>ELA</option>
         <option value=GERA>GERA</option>
         <option value=Hidaras>HIDARAS</option>
         <option value=IDMS>IDMS</option>
         <option value=LAZAR>LAZAR</option>
         <option value=Legal File Archive>LEGAL FILE ARCHIVE</option>
         <option value=Multiple>MULTIPLE</option>
         <option value=No archiving needed>NO ARCHIVING NEEDED</option>
         <option value=OnDemand DE>ONDEMAND DE</option>
         <option value=Physical Archive>PHYSICAL ARCHIVE</option>
    </select>
    <br></br>
  </div>

  <div>
    <label for=msg>FORMAT</label>
      <select id=Catid name=format>
      <option value=$FORMAT_PARAM>$FORMAT_PARAM</option>
      <option value=1A>1A</option>
      <option value=1C>1C</option>
      <option value=2A>2A</option>
      <option value=2B>2B</option>
      <option value=3A>3A</option>
      <option value=3B>3B</option>
      <option value=3C>3C</option>
    </select>
        <br></br>
  </div>

  <div>
    <label for=msg>PLANNED RELEASE <span style=color:red;>*</span> </label>
    <input type=date id=planrel name=planrelease required value=$PLANNED_RELEASE_PARAM>
        <br></br>
  </div>

  <div>
    <label for=msg>ACTUAL RELEASE</label>
    <input type=date id=actrel name=Actrelease value=$ACTUAL_RELEASE_PARAM>
        <br></br>
  </div>

  <div>
    <label for=msg>BUSINESS QUESTIONAIRE LINK</label>
    <input type=text id=bq name=BQLink maxlength=300 value=\"$BQLINK_PARAM\">
        <br></br>
  </div>

  <div>
    <label for=msg>TECHNICAL QUSTIONAIRE LINK</label>
    <input type=text id=tq name=TQLink maxlength=300 value=\"$TQLINK_PARAM\">
     <br></br>
  </div>

    <div>
    <label for=msg>PPM PROJECT ID</label>
    <input type=text id=ppm name=PPMproject maxlength=30 value=\"$PPMPROJECT_PARAM\">
     <br></br>
     </div>

    <div>
    <label for=msg>COST OBJECT <span style=color:red;>*</span> </label>
    <input type=text id=coobj name=Costobject maxlength=40 required value=\"$COSTOBJECT_PARAM\">
        <br></br>
  </div>

    <div>
    <label for=msg>ONBOARDING STATUS</label>
         <select id=obstatus name=Oboardingstatus>
         <option value=\"$ONBOARDSTATUS_PARAM\">\"$ONBOARDSTATUS_PARAM\"</option>
         <option value=COMPLETED>COMPLETED</option>
         <option value=\"IN PROGRESS\">IN PROGRESS</option>
         <option value=\"IN RATIFICATION\">IN RATIFICATION</option>
         <option value=ONHOLD>ONHOLD</option>
         <option value=OPEN>OPEN</option>
         <option value=POSTPONED>POSTPONED</option>
         <option value=INSIGN-OFF>IN SIGN-OFF</option>
         <option value=Multiple>MULTIPLE</option>
         <option value=ANNOUNCED>ANNOUNCED</option>
    </select>
        <br></br>
  </div>

    <div>
    <label for=msg>OB REMARKS</label>
    <input type=text id=obrema name=OBremarks maxlength=250 value=\"$ONBOARDINGREMARKS_PARAM\">
        <br></br>
  </div>
</div>

<body>
<div class=Section4>
  <p>OVARALL INFORMATION</p>
</div>
</body>

<div class=Core4>
  <div>
    <label for=name>OVERALL STATUS</label>
    <input type=text id=ovlstat name=overallstatus maxlength=250 value=\"$OVERALLSTATUS_PARAM\">
    <br></br>
  </div>

  <div>
    <label for=textvalue>OVERALL REMARKS</label>
    <input type=text id=ovlrem name=overallremarks maxlength=300 value=\"$OVERALLREMARKS_PARAM\">
    <br></br>
  </div>

  <div>
    <label for=textvalue>SYSTEM_VERSION (Read only)</label>
    <input type=number id=sysver name=systemversion value=\"$SYSTEM_VERSION\" readonly=\"readonly\">
    <br></br>
  </div>

</div>

</style>
<input type=submit value=MODIFY align=middle>
</form>
</div>

<div class=back>
<div>
<form action=../index.html method=GET>
   <input type=submit value=\"GO TO HOME\" align=middle>
</form>";

}

################# GETINGT THE CONSULTATION ID ###################

$consultation_id=$obj->param('Consultid');

&data_get_values($consultation_id);
