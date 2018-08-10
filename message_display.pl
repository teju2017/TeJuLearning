#!/sbcimp/run/pd/csm/64-bit/perl/5.16.3/bin/perl
#
########################################################################
## Script name  : data_search.pl
## Author       : Thejas HM
## Creatio dt   : 02-JUL-2018
## Description  : Generic program to handle the error
########################################################################

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

print $obj->header();
#print $obj->header("image/png");
print $obj->start_html( -title => "Display ALL");
print "<head>
 <h1>ONBOARDING PORTAL</h1>
 <img src=\"../ubs-logo.png\" alt=UBS Logo height=150 width=150>
 </head>
<style>
  h1 {
      color: black;
      font-family:Arial;
      background-color: powderblue;
	 }
  p {color: blue;}
  h1 {
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
</style>
<h2>@ARGV</h2>
</head>";
print "<form action=../index.html>
   <input type=submit value=\"GO TO HOME\" align=middle>
   </form>";
   print end_html();

