package CHIPS;

# Module CHIPS.pm pour l'interface de consultation publique 
# -----------------------------------------------------------------------------------
# Changement Aout 2014 pour ouverture GEM2Net
# On revoit les pages de CATdb
# site de consultation /CATdb
use SQLCHIPS;
use CHIPSLOCAL;

# nouveau DNS pour IPS2
#$DNS="ips2.universite-paris-saclay.fr";
$DNS="ips2.u-psud.fr";

################# Generalite valable sur tous les serveurs #############
# lien http vers le site URGV (IPS2)
$WURGV   = "http://tools.ips2.u-psud.fr/";
$WebURGV = "/www/urgv/htdocs/projects/transcriptome/";
$WIPS2 = "http://www.ips2.u-psud.fr/";

# lien ftp vers le site ftp URGV en production
$FTPCATDB = "ftp://tools.ips2.u-psud.fr/CATdb/";
$FTPPATH  = "/ftp/ftpuser/pub/CATdb";

# Email du staff CATdb et coordinateur
#$CATDBSTAFF = "catdbstaff\@evry.inra.fr";  
$CATDBSTAFF = "gnet.db\@ips2.upsaclay.fr";		#"veronique.brunaud\@u-psud.fr, jean-philippe.tamby\@u-psud.fr";
$ADTCOORD   = "ludivine.soubigou-taconnat\@inra.fr";
$ADLEGAL =  "cil-dpo\@inra.fr";				# pour mentions legales 


########### Connexion au serveur #########################
# on teste sur quelle machine on est
BEGIN {
	
	$PUBLIC="='yes'";
		
	# jacob defaut
	$SERVER    = "jacob.$DNS";
	$HTDOCPATH="/www/jacob/htdocs/projects/transcriptome";
	$WPGPATH=$CHIPSLOCAL::LOCAL."/cgi-bin/projects/CATdb";
	$PGPATH=$WPGPATH;
	
	# les pgm dependent de l'endroit ou l'on travaille
	if ( $ENV{'HOST'} =~/tools/) {
			# nouveau serveur public ips2
			$SERVER    = "tools.$DNS";
    	$HTDOCPATH="/www/urgv/htdocs/projects/transcriptome";
    	$WPGPATH="/www/urgv/cgi-bin/projects/CATdb";
    	$PGPATH="/cgi-bin/projects/CATdb";
    	
  	} elsif ($ENV{'HOST'} =~ /jacob/) {
    	# jacob
    	$PUBLIC="='yes'"; # base de prod mais donnees publique
    	#$PUBLIC="<>'yes'"; # base de prod mais donnees privees
    	
  	} elsif ($ENV{'HOST'} =~ /dayhoff/) {
    	# dayhoff
			$SERVER    = "dayhoff.$DNS";
    	$HTDOCPATH="/www/dayhoff/htdocs/projects/transcriptome";
    	$WPGPATH="/www/dayhoff/cgi-bin/projects/CATdb";
    	$PGPATH="/cgi-bin/projects/CATdb";
    	$PUBLIC="<>'yes'";
  	
  	}
}

# liens vers autres repertoires ou pgm
$DBLOG          = $HTDOCPATH . "/DBLOG";
$FILEUPLOAD     = $HTDOCPATH . "/fileUpload/";
$FILEDATA       = $HTDOCPATH . "/Data";
$STATPATH       = $HTDOCPATH . "/Stat";
$LOADPATH       = $HTDOCPATH . "/DBLOAD";
$TARPATH        = $HTDOCPATH . "/Archives/";
$DESIGNPATH     = $HTDOCPATH . "/Design/";
$CATDBSTYLEPATH = $HTDOCPATH . "/CATdb_style/";
$CATDBTEMP      = $HTDOCPATH . "/Temp/";

$TEMPLINK   = "/projects/transcriptome/Temp/";
$FILELINK   = "/projects/transcriptome/fileUpload/";
$DATALINK   = "/projects/transcriptome/Data/";
$TARLINK    = "/projects/transcriptome/Archives";
$DESIGNLINK = "/projects/transcriptome/Design/";
# rajouter en juil. 2012 pour garder les resNorm
$REPFILENORMAFFY = "/projects/transcriptome/exportGEO/Affy/"; # rep fichier normalise (resNorm) d'Affy

# download public/prive :
$ARRPATH = $FTPCATDB . "array_design";
$GPRPATH = $FTPCATDB . "gpr_cel";
$XLSPATH = $FTPCATDB . "data_norm";
if ($ENV{'HOST'} =~ /dayhoff/) {
	$GPRPATH = $DATALINK;
	$XLSPATH = $TARLINK;
}

#schema
$DBname = "chips";
# tables temporaires, sert lors du menage des tables temporaires
$TMP_PGTBLSPACE = "esp_data_tmp";   # ancien = 5 Go
#$TMP_PGTBLSPACE = "esp_data_newtmp";   # nouveau = 50 Go 
$TMP_TBLSPACE = "chips_tmp";
$TMP_VISITED  = "VISITE";
$TMP_MAILLIST = "MAILING_LIST";
$TMP_LOGFILE  = "tmp_error.log";

# avant PG
# $CONSULTPATH=$PGPATH."/consult/test_version2";
# $CONSULTPATH2=$PGPATH."/consult/fichEssai";
$CONSULTPATH = $PGPATH . "../CATdb";

# L'interface de consultation
$CACCUEIL  = $PGPATH . "/catdb_index.pl";
$CATDBPRO  = $PGPATH . "/catdb_projects_Ath.pl"; # VERO projects Ath
#$CATDBPRO  = $PGPATH . "/catdb_projects.pl";
$CATDBHLP  = $PGPATH . "/catdb_help.pl"; 
$CPROJECT  = $PGPATH . "/consult_project.pl";
$CEXPCE    = $PGPATH . "/consult_expce.pl";
$CPROJKW   = $PGPATH . "/cons_proj_kw.pl";
$CDIFF     = $PGPATH . "/cons_diff.pl";
$CDIFFID   = $PGPATH . "/cons_diff_id.pl";
$SEQINF    = $PGPATH . "/seq_info.pl";
$COORD     = $PGPATH . "/contact_info.pl";
$MULTIQ    = $PGPATH . "/cons_multi_seq.pl";
$MAILING   = $PGPATH . "/mailing.pl";
$REFBIBLIO = $PGPATH . "/refbiblio.pl";
$EXTRACTPG = $PGPATH . "/extract_diff2xls.pl";
$POSGST = $PGPATH . "/posgst_info.pl";
# L'interface de consultation pour autres especes
#$CATDBAFFY  = $PGPATH . "/catdb_projects_affy.pl";
$CATDBOTHERSPECIES  = $PGPATH . "/catdb_projects_OtherSpecies.pl"; # VERO Other Species
$CEXPAFFY = $PGPATH . "/consult_expce_affy.pl"; 
$CATDBCHROMO = $PGPATH . "/catdb_projects_4chip.pl";

# style pour la consultation
$STYLEPATH  = "/projects/transcriptome/CATdb_style/";
$STYLECSS   = $STYLEPATH . "catdb_consult.css";
$CATDBLOGO  = $STYLEPATH . "catdb_logo.png"; 		#454x41
#$CATDBLOGO  = $STYLEPATH . "CATdb_logo2.png";  	#454x38
#$CATDBLOGO  = $STYLEPATH . "CATdb_logo3.png"; 	#487x41
$BULUPDW    = $STYLEPATH . "bul_updw.gif";              #fleche de tri
$DSLEGEND   = $STYLEPATH . "05Legends_300.gif";       #legende des designs
$GSTLEGEND = $STYLEPATH . "LegendGSTtype.png"; 	# legende des types de GST
$DOWNLOAD   = $STYLEPATH . "download.gif";              #download icon
$ACCESS1    = $STYLEPATH . "access1-anim.gif";          #access data blue
$ACCESS2    = $STYLEPATH . "access2.png";               #access data red
$ACCESS3    = $STYLEPATH . "access3-small.png";         #small access data blue
$ACCESS4    = $STYLEPATH . "access4-small.png";         #small access data red
$QUERY1     = $STYLEPATH . "query1.png";                #new query blue
$QUERY2     = $STYLEPATH . "query2.png";                #new query red
$NEWICON    = $STYLEPATH . "new-icon.gif";              #icone new
$GAUCHE_ON  = $STYLEPATH . "gauche_on.gif";             #fleche gauche bleue
$GAUCHE_OFF = $STYLEPATH . "gauche_off.gif";            #fleche gauche grise
$DROITE_ON  = $STYLEPATH . "droite_on.gif";             #fleche droite bleue
$DROITE_OFF = $STYLEPATH . "droite_off.gif";            #fleche droite grise
#$URGVSMALL  = "/logos/urgv_small.jpg";				# logo urgv haut-gauche
$URGVSMALL  = "/logos/logo-ips2-trans.png";			# logo ips2 haut-gauche
$PVALMAX = 0.05;    # seuil de p-value pour toutes les donnees presentees

# liens externes
$FLAGDB = $WURGV."/projects/FLAGdb++/HTML/";
$CATMA = "http://www.catma.org";
$AFFX = "http://www.affymetrix.com/";
$AGILENT="http://www.agilent.com/";
$NIMBLEGEN="http://www.nimblegen.com/";
$GEM2NET = $WURGV."/GEM2NET/";
$GEM2NETLOGO = "/projects/GEM2NET/logos/GEM2NET_logo5_small.png";
$GEM2NETLOGOLARGE = "/projects/GEM2NET/logos/GEM2NET_logo5_transpa.png";
$GEM2NET_DESC = "/projects/GEM2NET/logos/GEM2NET02_wf_small.jpg";

############################### FONCTIONS DE BASE ###################
# Recuperation de la date du jour.
sub sysdate() {
	my @sysdate = localtime();
	my $sysdate =
		sprintf( "%2.2d-%2.2d-%4.4d", $sysdate[3], $sysdate[4] + 1, $sysdate[5] + 1900 );

	#my $day=(split(/\//,$sysdate))[0];
	#my $month=(split(/\//,$sysdate))[1];
	#my $year=(split(/\//,$sysdate))[2];
	return ($sysdate);
}

#verifie le format de la date
sub verif_date() {
	my ( $month, $day, $year ) = @_;
	my $date_code = $month . "-" . $day . "-" . $year;

	if ( $day > 31
		or $day < 1
		or $month > 12
		or $month < 1
		or $date_code !~ m"\d{2}-\d{2}-\d{2}" )
	{
		return ();
	}
	return ($date_code);
}

# Requete sur un champ d'une table de la base
# surtout utile pour les tables correspondant a des listes
# possibilite d'une condition
sub DBreq() {
	my $table = shift;
	$table = $DBname . ".$table";
	my $attribut = shift;
	my $where    = shift;

	my $if_where;
	if ( $where ne '' ) {
		$if_where = "where $where";
	}
	my $req =
		&SQLCHIPS::do_sql(
		"select distinct $attribut from $table $if_where order by $attribut");

	my @list = &SQLCHIPS::get_col( $req, 0 );

	#my @list1=&SQLCHIPS::get_col($req,1);

	return ( $req->{ORDER}, @list );

	#if($list1[0] ne ''){ return(@list0,@list1); }else{ return(@list0,$req->{ORDER}); }
}

# Requete juste pour extraire un champs d'une table
sub DBlist() {
	my $table = shift;
	$table = $DBname . ".$table";
	my $attribut = shift;

	my $req = &SQLCHIPS::do_sql("select $attribut from $table order by $attribut");

	my @list = &SQLCHIPS::get_col( $req, 0 );

	return (@list);
}

# execution de la requete et verifie si y a une erreur et LOG tout
sub exec_req() {
	my $requete  = shift;         # requete
	my $filegood = shift;         # fichier des erreurs
	my $filebad  = shift;         # fichier des bonnes requetes
	my $username = shift;
	my @sysdate  = localtime();
	my $hour = sprintf( "%2dh%2d", $sysdate[2], $sysdate[1] );

	my $date = &sysdate();
	my $req  = &SQLCHIPS::do_sql($requete);
	if ( defined( $req->{ERRSTR} ) ) {
		my $file = $DBLOG . "/" . $filebad;

		open( LOGBAD, ">>$file" );
		print LOGBAD
"REM *** No insert $$ ** $date $hour ** $username ** $req->{ERRSTR}\n $req->{ORDER};\n\n";
		close(LOGBAD);
		return ( $req->{ERRSTR} );    # erreur
	}
	else {
		my $file = $DBLOG . "/" . $filegood;
		open( LOGGOOD, ">>$file" );
		print LOGGOOD
			"REM *** Insert $$ ** $date $hour** $username ** \n $req->{ORDER};\n\n";
		close(LOGGOOD);
		return (1);                   # good
	}
}

# execution de la requete et verifie s'il y a une erreur et LOG erreur seule
# (derivee de la fonction precedente)
sub exec_req_logerr() {
	my $requete = shift;            # requete
	my $filebad = shift;            # fichier des erreurs

	my @sysdate = localtime();
	my $hour    = sprintf( "%2dh%2d", $sysdate[2], $sysdate[1] );

	my $date = &sysdate();
	my $req  = &SQLCHIPS::do_sql($requete);
	if ( defined( $req->{ERRSTR} ) ) {
		my $file = $DBLOG . "/" . $filebad;

		open( LOGBAD, ">>$file" );
		print LOGBAD "REM *** $date $hour ** $username ** $req->{ERRSTR};\n\n";
		close(LOGBAD);
		return ( 0, $req->{ERRSTR} );    # erreur
	}
	else {
		return ( 1, $req );              #ok
	}
}

sub verif_unicite() {

	# fct qui verifie l'unicite d'un champs et retourne la cle (ou un
	# autre champs) de cette table

	my ( $table, $tableid, $col, $val ) = @_;

	# table : nom de la table
	# $tableid : nom du champs id de la table
	# $col et $val : la colonne et valeur a tester

	$val =~ tr/a-z/A-Z/;
	my $req =
		&SQLCHIPS::do_sql("select $tableid from $table where upper($col)='$val'");
	my $id = ( &SQLCHIPS::get_col( $req, 0 ) )[0];
	return $id;
}

sub verif_unicite_byproject() {

	# fct qui verifie l'unicite d'un champs et retourne la cle (ou un
	# autre champs) de cette table

	my ( $table, $tableid, $col, $val, $pid, $eid ) = @_;

	# table : nom de la table
	# $tableid : nom du champs id de la table
	# $col et $val : la colonne et valeur a tester

	$val =~ tr/a-z/A-Z/;
	my $req =
		&SQLCHIPS::do_sql("select $tableid from $table where upper($col)='$val' and 
		project_id=$pid and experiment_id=$eid");
	my $id = ( &SQLCHIPS::get_col( $req, 0 ) )[0];
	return $id;
}

# verifie l'existence d'une table dans la DB et retourne un booleen
sub exist_table() {

	my $nomtable = shift;    # nom de la table
	my $tblsapce = lc(shift);
	my $and      = '';

	if ( $tblsapce ne '' ) { $and = "SCHEMANAME = '$tblsapce' and"; }

	my $req =	&SQLCHIPS::do_sql(
		"Select tablename from pg_tables where $and upper(tablename) = upper('$nomtable')");

	if ( $req->{NB_LINE} != 0 ) {
		return 1;                  # exist
	}
	else {
		return 0;                  # not exist
	}

}    

# nettoie une sting (nom de fichier) des metacaracteres
sub clean_filename(){
  my $note=shift;

	$note=~ s/[<>=\!\?\*]//g;
	$note=~ s/[\+\|\/\s+]/\_/g;
 	$note=~ s/\'//g;
  $note=~ s/\"//g;
  #$note=~ s/[\r]+//g; # pour les retours chariot de windows

  return($note);
}

1;
