#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl

########################################################################
## Script name  : data_mail_request.pl
## Author       : Thejas HM
## Creatio dt   : 27-JUN-2018
## Description  : This script is used to trigger a mail for providing 
##                the access to the portal
########################################################################



use CGI ':standard';


use lib qw(
/opt/apache24/lib
/sbclocal/gdmp/lib/perl/
/sbcimp/run/pd/csm/64-bit/cpan/5.16.3-2013.03/lib
);


my $obj=new CGI();

sub logwritter()
{
    @msg=@_;
    open(FH,'>>/tmp/fil.log')||die "Cannot write into the file ";
    print FH @msg;
    print FH "\n";
    close(FH);
}


sub mail_sending_request()
{

   my ($to_address,$gpin)=@_;
   &logwritter("MAIL_REQUEST:TO_ADRESS VARIABLE IS :$to_address");

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
        $to_address=$to_address." thejas-holalker.murulidhara\@ubs.com";
        $mail_string='/bin/mailx -s "ONBOARDING PORTAL ACCESS REQUEST:GPIN:- '.$gpin.'" '.$to_address.'</sbclocal/gdmp/web/conf/msg_request.dat';
        &logwritter("mail string is ",$mail_string);
        my $ret=system($mail_string);
        print header();
        print $obj->start_html( -title => "Display ALL");
        print "<h3>mail has been sent to the approver copying you, kindly contact the approver sridhar.raman\@ubs.com directly for urgent request</h3>";
        print end_html();
        };
        if ($@)
        {
           system('/sbclocal/gdmp/web/cgi-bin/message_display.pl',"ISSUE IN SENDING THE MAIL TO $to_address, drop a mail to thejas-holalker.murulidhara\@ubs.com for the issue");
        }
  }
}


my @http_array = http();
my $email_add=http('HTTP_SSO_EMAIL');
my $tnumber=http('HTTP_SSO_GUID');
&logwritter("tnumber = $tnumber");
&mail_sending_request($email_add,$tnumber);
