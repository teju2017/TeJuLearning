#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

########################################################################
## Script name  : data_access.pl
## Author       : Thejas HM
## Creatio dt   : 25-JUL-2018
## Description  : Script to insert and delete the GPIN, also to 
##                show the records
########################################################################



use CGI ':standard';


use lib qw(
/opt/apache24/lib
/sbclocal/gdmp/lib/perl/
/sbcimp/run/pd/csm/64-bit/cpan/5.16.3-2013.03/lib
/sbclocal/gdmp/web/cgi-bin/test
/sbclocal/gdmp/web/cgi-bin/
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


require security_check;
my $obj = new CGI;

######################################################################################
# Block to check the user authentication if he tries to access the html file
# and submit the request directly
######################################################################################

BEGIN
{
     require security_check;
     my $gpin=http('HTTP_SSO_GUID');
     $appr_ret=security_check::approver_check($gpin);
     $ret_value=security_check::user_check($gpin);
     my $obj = new CGI;
     if ( $appr_ret eq "TRUE" )
     {
        security_check::logwritter("$gpin is a approver, proceeding him with the access and revoking ability");
     }
     else
     {
        if ( $ret_value eq "TRUE" )
        {
           security_check::logwritter("GPIN is a member, proceeding with the next stage");
        }
        else
        {
            print $obj->redirect('http://a301-7773-3451.ldn.swissbank.com:8081/noaccess.html');
            exit 0;
        }
     }
} 



#############  LOG FILE WRITTER ##############################


sub logwritter()
{
  @msg=@_;
  open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
  print FH @msg;
  print FH "\n";
  close(FH);
}


######## METHOD TO GRANT THE ACCESS BY INSERTING THE DATA ###################################

sub data_access_approve()
{
   my($gpin,$app_flg,$user,$approved_by)=@_;
   $quy="insert into onboarding_users (USER_GPN,APPROVER,USER_NAME,APPROVED_BY,APPROVE_DATE) values (?,?,?,?,SYSDATE)";
   eval {
   my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
   $dbh->{AutoCommit}    = 1;
   $dbh->{RaiseError}    = 1;
   $dbh->{ora_check_sql} = 0;
   $dbh->{RowCacheSize}  = 16;
   $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD'");
   &logwritter("Just before the Prepare statement");
   my $sth = $dbh->prepare($quy);
   $sth->bind_param("1",$gpin);
   $sth->bind_param("2",$app_flg);
   $sth->bind_param("3",$user);
   $sth->bind_param("4",$approved_by);
   $sth->execute();
   $rowmod=$sth->rows();
   &logwritter("Executed the insert statement successfully and rowmod value is $rowmod");
   if ($rowmod == 1 )
   {
        system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"Access provided for GPIN $gpin");
   }
   else
   {
       system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"Some issue in providing the access for the GPIN $gpin");
   }
   END {
       $dbh->disconnect if defined($dbh);
   }
   };
}

######### METHOD TO REVOKE THE ACCESS BY REMOVING THE GPIN #######################################


sub data_access_revoke()
{
   $GPIN=@_[0]; 
   &logwritter("GPIN value is $GPIN ");
   $quy="delete from onboarding_users where USER_GPN="."'".$GPIN."'";
   #print "Value of delete statement is $quy \n";
   eval {
   my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
   $dbh->{AutoCommit}    = 1;
   $dbh->{RaiseError}    = 1;
   $dbh->{ora_check_sql} = 0;
   $dbh->{RowCacheSize}  = 16;
   $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD'");
   my $sth = $dbh->prepare($quy);
   $sth->execute();
   $rowmod=$sth->rows(); 
   if ( $rowmod > 0 )
   {
     &logwritter("DELETION OF GPIN $GPIN is successful ");
     system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"Access for GPIN $GPIN is revoked from the Onboarding portal");
     &logwritter("Executed the delete statement successfully and rowmod value is $rowmod");
   }
   else
   {
     &logwritter("ROWMOD value is not one , so no deletion has happened ");
     system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"Please check whether the GPIN exists");
   }
   END {
           $dbh->disconnect if defined($dbh);
   }
   };
}



############## METHOD TO DISPLAY THE ACCESS RELATED INFORMATION FROM THE PORTAL ##############


sub onboarding_users_details()
{
   $quy="select * from onboarding_users order by approve_date desc";
   my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
   my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| die "Database connection is failing ";
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
   print $obj->start_html( -title => "DISPLAY USER DETAILS");
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
  background: \#CFCFCF;
  background: -moz-linear-gradient(top, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  background: -webkit-linear-gradient(top, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  background: linear-gradient(to bottom, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  border-bottom: 3px solid #000000;
  font-size: 14px;
  font-weight: bold;
  color: #000000;
  text-align: center;
  font-family:Arial;
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


tr:nth-child(even) td { background: #f2f7f5; }

/* Cells in odd rows (1,3,5...) are another (excludes header cells)  */
tr:nth-child(odd) td { background: #FEFEFE; }

tr td:hover { background: #666; color: #FFF; }
/* Hover cell effect! */

</style>";
print "<table class=minimalistBlack>
          <thead>
          <tr>
                      <td>USER_GPN</td>
                      <td>APPROVER</td>
                      <td>USER_NAME</td>
                      <td>APPROVED_BY</td>
                      <td>APPROVED_DATE</td>
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
                $USER_GPN= $data[0];
                $APPROVER= $data[1];
                $USER_NAME= $data[2];
                $APPROVED_BY=$data[3];
                $APPROVED_DATE=$data[4];
              
              print "<tr>
                    <td>$USER_GPN</td>
                    <td>$APPROVER</td>
                    <td>$USER_NAME</td>
                    <td>$APPROVED_BY</td>
                    <td>$APPROVED_DATE</td>
                    </tr>";
              }
           }
       }
       print "</table>";
       print "\n";
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


############### GETTING THE FORM VALUES #####################

my $GPIN_NO="PSI".$obj->param('GPIN');
my $USER_NAME=$obj->param('username');
my $APPROVE_FLG=$obj->param('Approve_flag');
my @http_array = http();
my $APPROVED_BY=http('HTTP_SSO_EMAIL');


if($obj->param('show_access'))
{
    onboarding_users_details();
}
if($obj->param('revoke'))
{
   &data_access_revoke("$GPIN_NO"); 
}
if($obj->param('approve'))
{
  &data_access_approve("$GPIN_NO","$APPROVE_FLG","$USER_NAME","$APPROVED_BY"); 
}
