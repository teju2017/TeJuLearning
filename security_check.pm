#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl


#########################################################################
### Script name  : security_check.pm
### Author       : Thejas HM
### Creatio dt   : 24-JUL-2018
### Description  : Module to control the user entry
##########################################################################


use CGI;
use DBI;
use DBD::Oracle;
use Data::Dumper;
use YAML;




$ENV{ORACLE_HOME}="/sbcimp/run/tp/oracle/client/v11.2.0.3-64bit/client_1";
$ENV{LD_LIBRARY_PATH}="/sbclocal/gdmp/lib";
$ENV{PERL5LIB}="/sbcimp/run/pkgs/CORE/15.1.0/lib";
$ENV{TNS_ADMIN}="/sbclocal/gdmp/etc";



use lib qw(
/opt/apache24/lib
/sbclocal/gdmp/lib/perl/
/sbcimp/run/pd/csm/64-bit/cpan/5.16.3-2013.03/lib
/sbclocal/gdmp/web/cgi-bin/test
/sbclocal/gdmp/web/cgi-bin/
);




package security_check;


sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}


###### Method to check whether the user has the approver access  ####################

sub approver_check()
{
    $GPIN=@_[0];
    $query="select USER_GPN from onboarding_users where user_gpn= "."'".$GPIN."'" . " and approver='Y'";
    &logwritter("APPROVER_CHECK: GPIN PASSED IS $GPIN");
    &logwritter("APPROVER_CHECK QUERY: $query ");
    eval {
           my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
           $dbh->{AutoCommit}    = 1;
           $dbh->{RaiseError}    = 1;
           $dbh->{ora_check_sql} = 0;
           $dbh->{RowCacheSize}  = 16;
           my $sth = $dbh->prepare($query);
           $sth->execute();
           &logwritter("EXECUTION SUCCESSFUL for $query");
           if($sth->fetchrow_array())
           {
               &logwritter("USER $GPIN present in the table , proceeding with the next actions ");
               return "TRUE";
           }
          else
          {
               return "FALSE";
          }
       END 
           {
                $dbh->disconnect if defined($dbh);
           }
      };
}

           

######## Method to check whether the user has the memeber access ######################


sub user_check()
{
     $GPIN=@_[0];
     $query="select USER_GPN from onboarding_users where user_gpn= "."'".$GPIN."'" . "and approver='N'";
     &logwritter("GPIN PASSED IS $GPIN");
     &logwritter("Query value is $query");
     #print "Value of quy is $query \n";
     eval {
       my $dbh = DBI->connect("dbi:Oracle:carmen","carmen","electra#1")|| &logwritter($DBI::errstr);
       $dbh->{AutoCommit}    = 1;
       $dbh->{RaiseError}    = 1;
       $dbh->{ora_check_sql} = 0;
       $dbh->{RowCacheSize}  = 16;
       my $sth = $dbh->prepare($query);
       $sth->execute();
       if($sth->fetchrow_array())
       {
              &logwritter("USER $GPIN present in the table , proceeding with the next actions ");
              return "TRUE";
       }
       else
       {
              return "FALSE";
       }
       END {
               $dbh->disconnect if defined($dbh);
           }
       };
}

1;
