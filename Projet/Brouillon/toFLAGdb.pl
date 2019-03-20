#!/usr/local/bin/perl -w

use CGI qw/:standard :no_xhtml escape unescape/;	 
use Carp;
use strict;
#use CGI::Pretty;		# deprecated en perl 5.22

#Generate on the fly a .jnlp with the url parameter ID FEAT as an argument

print "Content-Type: application/x-java-jnlp-file";
print "\n\n";
my $retString="";

my $q = new CGI;
my $idFeat = $q->param('idFeat'); 

#for Affymetrix ATH1 (separator ;)
my @parms = $q->param; 
if (scalar(@parms) >1) {
	shift(@parms);
	$idFeat = sprintf ("%s;%s;", $idFeat, join (";", @parms));
}

$retString.= '<?xml version="1.0" encoding="utf-8"?> 
<jnlp spec="1.0+"
      codebase="http://tools.ips2.u-psud.fr/projects/FLAGdb++/Appli/"
      href="FLAGdb.jnlp">
   <information> 
      <title>FLAGdb++</title> 
      <vendor>URGV</vendor>
      <homepage href=""/>
      <description>FLAGdb++</description>
      <icon href="Flagdb.jpg"/>
      <offline-allowed/> 
   </information> 
  <security>
    <all-permissions/>
  </security>
   <resources>
      <j2se version="1.4+" initial-heap-size="64m" max-heap-size="512m" />
      <jar href="FLAGdb.jar"/>
      <jar href="FLAGdbCore.jar"/>
      <jar href="king.jar"/>
      <jar href="postgresql-9.3-1103.jdbc3.jar"/>
   </resources>
   <application-desc main-class="urgv.application.FLAGdb">';
$retString.= "        <argument>-params</argument>
        <argument>http://tools.ips2.u-psud.fr/projects/FLAGdb++/Appli/prodflagdb.xml</argument>
        <argument>-USER</argument>
        <argument>22OTHER07</argument>
        <argument>-DRIVER</argument>
        <argument>6</argument>
        <argument>-IDFEAT</argument>
        <argument>$idFeat</argument>        
   </application-desc>
</jnlp>";


print  ($retString);
exit;
