#!/usr/local/bin/perl

use Carp;
use strict;
use Time::localtime;

use lib './';          # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;

#--Variables---
my $ppty = $CHIPS::DBname;
my $logpath = $CHIPS::DBLOG;
my $public   = $CHIPS::PUBLIC;
my $extractprog = $CHIPS::EXTRACTPG;
my $stamph = sprintf ("%02d%02d%02d",localtime->hour(),localtime->min(),localtime->sec());
my $logfile = sprintf ("extract_all_xls_%s.log", $stamph);

my ($projid, $expid);
my ($reqprojex, $nbprojex, $j);
my $rc;

#--selection des project_id et experiment_id publics---
$reqprojex = &SQLCHIPS::do_sql("select p.project_id, e.experiment_id from $ppty.project p, $ppty.experiment e where p.project_id=e.project_id and p.is_public $public");

$nbprojex = $reqprojex->{NB_LINE};
printf "*** Extracting data from %d (project,experiment) couples ***\n", $nbprojex;

#--Initialisation log file---
system ("date >>$logpath/$logfile");

#--Appel du programme d'extraction pour chaque couple (projet,experience)---
for ($j=0;$j<$nbprojex;$j++) {
  print "#$j Extract project: $reqprojex->{LINES}[$j][0], experiment: $reqprojex->{LINES}[$j][1]..... ";
  $rc = system ("./$extractprog $reqprojex->{LINES}[$j][0] $reqprojex->{LINES}[$j][1] >>$logpath/$logfile 2>>$logpath/$logfile");

  $rc==0 ?  print "done\n" :  print "aborted !\n";

}

#--log file termination---
system ("date >>$logpath/$logfile");
printf "... see report file %s/%s\n", $logpath, $logfile;
