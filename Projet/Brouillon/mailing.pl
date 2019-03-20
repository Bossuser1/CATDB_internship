#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;

use lib './';   # PACKAGES specifiques dans .../cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;
use consult_package;

#--Variables---------------------------------------------
my $lkaccueil = $CHIPS::CACCUEIL;
my $tblspace = $CHIPS::TMP_TBLSPACE;
my $tmptable = $CHIPS::TMP_MAILLIST;
my $staff = $CHIPS::CATDBSTAFF;
my $w = new CGI;
my $emailad = $w->param('emailaddr');
my ($requete, $req);
my ($nbline, $maxid);
my ($errmsg, $mssg);
my ($rc, $subs);
my (@updlist, $updlist);


#--REQUETE-----------------------------------------------
$requete = &SQLCHIPS::do_sql("select count(*) from $tblspace.$tmptable where email='$emailad'");
$nbline = int($requete->{LINES}[0][0]);

if ($nbline == 0 || $nbline eq '0') {
  # recherche dernier id
  $requete = &SQLCHIPS::do_sql("select max(contact_id) from $tblspace.$tmptable");
  $maxid = int($requete->{LINES}[0][0]);
  # insertion dans la table MAILING_LIST
  $maxid = $maxid + 1;
  $SQLCHIPS::dbh->begin_work;  #debut de transaction
  $req = &SQLCHIPS::do_sql("insert into $tblspace.$tmptable values ($maxid,'$emailad')");

  if (defined($req->{ERR})) {
    $SQLCHIPS::dbh->rollback;
    $errmsg = sprintf ("\nError while inserting new subscriber %s in %s\nSQL error: %s", $emailad, $tmptable, $req->{ERRSTR});
    
    &consult_package::envoi_mail($staff,"CATdb mailing list Error",$errmsg, $staff);
    $subs = 3;  # insertion ko
  } else {
    $SQLCHIPS::dbh->commit;
    $mssg = sprintf ("\nWelcome to CATdb,\n\nYour subscription to CATdb mailing list is confirmed.\n
Thank you for your registration,\n\n\ton behalf of the CATdb Staff\n\n
note: To unsubscribe, send an Email to %s with \"unsubscribe\" in the subject\n", $staff);
    &consult_package::envoi_mail($emailad,"CATdb mailing list subscription", $mssg, $staff);
    $subs = 1;  # insertion ok
  }
} else {
  $subs = 2;  # deja dans mailing_list
}

# Redirection vers Accueil
print $w->redirect(-uri=>"$lkaccueil?subs=$subs#divers");

# Mailing list update
if ($subs == 1) {
  # recup + envoi de mailing list a catdbstaff
  $requete = &SQLCHIPS::do_sql("select email from $tblspace.$tmptable order by contact_id");
  @updlist = &SQLCHIPS::get_col($requete,0);
  $updlist = join("\n", @updlist);
  $mssg = sprintf ("\nNew suscriber: %s\n\nThe complete CATdb Mailing List is:\n\n%s", $emailad, $updlist);
  &consult_package::envoi_mail($staff,"CATdb Mailing list update", $mssg, $staff);
}
