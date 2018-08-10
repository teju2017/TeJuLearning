#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl


################################################################################
## Script name  : data_security.pl
## Author       : Thejas HM
## Creatio dt   : 20-JUL-2018
## Description  : Script controlling the access to the Portal
###############################################################################



use lib qw(
/opt/apache24/lib
/sbclocal/gdmp/lib/perl/
/sbcimp/run/pd/csm/64-bit/cpan/5.16.3-2013.03/lib
/sbclocal/gdmp/web/cgi-bin/test
/sbclocal/gdmp/web/cgi-bin/
);

require security_check;
use CGI ':standard';



my $gpin=http('HTTP_SSO_GUID');


$appr_ret=security_check::approver_check($gpin);
$ret_value=security_check::user_check($gpin);

####################################################################
## Using the security_check package to check the access
####################################################################

security_check::logwritter("APPROVER REQUEST RETURN VALUE IS : $appr_ret ");
security_check::logwritter("MEMBER REQUEST RETURN VALUE IS : $ret_value ");


my $obj = new CGI;

if ( $appr_ret eq "TRUE" )
{
    security_check::logwritter('APPROVER REQUEST IS TRUE FOR GPIN');
    print $obj->redirect('http://a301-7773-3451.ldn.swissbank.com:8081/index_approver.html');
}
else 
{
   if ( $ret_value eq "TRUE" )
   {
       security_check::logwritter('GPIN is a member, proceeding with the next stage');
       print $obj->redirect('http://a301-7773-3451.ldn.swissbank.com:8081/index_member.html');
   }
   else
   {
     print $obj->redirect('http://a301-7773-3451.ldn.swissbank.com:8081/noaccess.html');
   }
}
