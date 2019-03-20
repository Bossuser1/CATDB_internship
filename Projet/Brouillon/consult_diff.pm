package consult_diff;

=pod

=head1 NAME

 consult_diff.pm

=head1 SYNOPSIS
 
=head1 DESCRIPTION

 Package utilise pour l'interface de consultation de CATdb
 permet la consultation par identifiant (GST ou AGI) 
 et l'affichage HTML des données transcriptome 
 
=head1 CONTENT

=head2 Controler un identifiant et Recuperer les id associes

 isGene_ID()  
 isGST_ID()  
 getRelated_ID()
 
=head2 Gerer une table temporaire des donnees d'analyse diff

 createTmp_table() 
 fillTmp_table() 
 dropTmp_table()
 
=head2 Selectionner les donnees d'analyse diff d'une table temporaire

 checkTmp_Data() 
 countTmp_Data() 
 selectTmp_Data()
 
=head2 Gerer les enregistrements de la table VISITE

 existVisite() 
 insertVisite() 
 updateVisite() 
 deleteVisite()
 
=head2 Gerer l'envoi du mail d'erreur (warnmail)

 getWarnmail() 
 setWarnmail() 
 resetWarnmail()
 
=head2 Mettre en forme les donnees d'analyse diff pour un tableau HTML

 displayTmp_Coln() 
 displayTmp_Data()
 
=head1 SUBROUTINES

=cut

use Carp;
use strict;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;
use consult_package;

my $ppty     = $CHIPS::DBname;                  # "chips"
my $visite   = $CHIPS::TMP_VISITED;
my $tabspace = $CHIPS::TMP_TBLSPACE;      # "chips_tmp"
my $pgspace  = $CHIPS::TMP_PGTBLSPACE;  # "esp_data_tmp"
my $errlogf  = $CHIPS::TMP_LOGFILE;           # "tmp_error.log"
my $public   = $CHIPS::PUBLIC;

my $user_name = $ENV{'REMOTE_USER'};
$user_name = lc $user_name;

#_______________________________________________________________________________________
# HTML & Tableau 
#_______________________________________________________________________________________
use CGI qw/:standard escapeHTML/;
my $w = new CGI;

# liens
my $lkproject = $CHIPS::CPROJECT;
my $lkexpce   = $CHIPS::CEXPCE;
my $lkdiffid  = $CHIPS::CDIFFID;
# image
my $bulupdw = $CHIPS::BULUPDW;    #fleche de tri
# couleurs du tableau
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC; 
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;
my $vert  = $consult_package::VERT;
my $rouge = $consult_package::ROUGE;

# taille des cellules
my @ttd = ( "20%", "22%", "9%", "12%", "17%", "5%", "5%", "5%", "5%" );	

#_______________________________________________________________________________________
###
###  ** CONSULTATION par IDENTIFIANT **
###
#_______________________________________________________________________________________
# Controler un identifiant et Recuperer les id associes
#_______________________________________________________________________________________

=head2 function
 
 Title		: isGene_ID
 Usage		: $boolean = consult_diff::isGene_ID($idvar)
 Prerequisite	: $ppty : nom du schema
 Function	: none
 Returns	: $boolean (0|1)
 Args		: $idvar, string (identifiant CATMA ou AGI)

=cut

sub isGene_ID () {

	# Teste si un identifiant est un code AGI, renvoie un booleen
	my $idvar = shift;
	my $req   = 
		&SQLCHIPS::do_sql("SELECT count(*) from $ppty.spot_gene where gene_name='$idvar'");
	my $ctl = $req->{LINES}[0][0];  #&SQLCHIPS::get_col( $req, 0 );

	if ( $ctl > 0 ) {
		return 1;
	} else {
		return 0;
	}
}

=head2 function

 Title		: isGST_ID
 Usage		: $boolean = consult_diff::isGST_ID($idvar)
 Prerequisite	: $ppty : nom du schema
 Function	: none
 Returns	: $boolean (0|1)
 Args		: $idvar, string (identifiant CATMA ou AGI)

=cut

sub isGST_ID () {

	# Teste si un identifiant est un code GST, renvoie un booleen
	my $idvar = shift;
	my $req   =
		&SQLCHIPS::do_sql("SELECT count(*) from $ppty.spotted_sequence where seq_name='$idvar'");
	my $ctl = $req->{LINES}[0][0];  # &SQLCHIPS::get_col( $req, 0 );

	if ( $ctl > 0 ) {
		return 1;
	} else {
		return 0;
	}
}

sub getRelated_Gene () {

	# Recupere les identifiants AGI associes a un code GST, renvoie un tableau
	my $idvar = shift;
	my $req   = 
		&SQLCHIPS::do_sql("SELECT sg.gene_name from $ppty.spot_gene sg, $ppty.spotted_sequence ss \
		where ss.spotted_sequence_id = sg.spotted_sequence_id	and ss.seq_name = '$idvar'");

	return &SQLCHIPS::get_col( $req, 0 );
}

sub getRelated_GST () {

	# Recupere les identifiants GST associes a un code AGI, renvoie un tableau
	my $idvar = shift;
	my $req   = 
		&SQLCHIPS::do_sql("SELECT ss.seq_name, ss.other_name from $ppty.spot_gene sg, \
	$ppty.spotted_sequence ss	where ss.spotted_sequence_id = sg.spotted_sequence_id and \
	sg.gene_name = '$idvar' and ss.type_feat = 'GST'");
	my @idasso = &SQLCHIPS::get_col( $req, 0 );
	push( @idasso, &SQLCHIPS::get_col( $req, 1 ) );

	my %htab;    # pour construire une liste sans doublons
	foreach (@idasso) {
		$htab{$_} = $_;
	}

	return ( keys %htab );
}

=head2 function

 Title		: getRelated_ID
 Usage		: @array = consult_diff::getRelated_ID($idvar, $idtyp)
 Prerequisite	: $ppty : nom du schema
 Functions	: getRelated_GST(), getRelated_Gene()
 Returns	: @array | 0
 Args		: $idvar, string  (identifiant CATMA ou AGI)
       		  $idtyp, string  (type de l'identifiant : GST ou Gene)

=cut

sub getRelated_ID () {
	
	# Appelle les fonctions pour recuperer les identifiants associes a un ID
	my $idvar = shift;
	my $idtyp = shift;
	
	if ($idtyp =~ /^Gene/) {
		return &getRelated_GST ($idvar);		
	} elsif ($idtyp =~ /^GST/) {
		return &getRelated_Gene ($idvar);
	} else {
		return 0;
	}
}

#_______________________________________________________________________________________
# Gerer une table temporaire des donnees d'analyse diff (creation, remplissage, destruction)
#_______________________________________________________________________________________

=head2 function

 Title		: createTmp_table
 Usage		: $sqlerr = createTmp_table($nomtable, $sousreqt)
 Prerequisite	: $tabspace : nom du tablespace 
                  $ppty : nom du schema
 Function	: none
 Returns	: $sqlerr, string
 Args		: $nomtable, string (nom de la table a creer)
         	  $sousreqt, string  (sous-requete de selection des donnees a inserer)
 							  
=cut

sub createTmp_table () {

	# Cree une table temporaire pour la consultation des donnees
	my $nomtable = shift;
	my $sousreqt = shift;
	my $sqlerr   = '';

	$SQLCHIPS::dbh->begin_work;		#debut de transaction
	my $req = &SQLCHIPS::do_sql(
		"CREATE TABLE $tabspace.$nomtable (
 															replicat_id						 integer,  
 															i_ref                  numeric(6,4), 
 															i_sample               numeric(6,4),
 															log_ratio              numeric(6,4), 
 															bonf_p_value           numeric(5,4) )
 															tablespace $pgspace"
	);
	
	if ( defined( $req->{ERR} ) ) {
		# en cas d'erreur de creation de la table (tablespace plein par exemple)
		$sqlerr .= "createTmp_table::CREATE ".$req->{ERRSTR}."\n";
		$SQLCHIPS::dbh->rollback;
	}	else {
		$SQLCHIPS::dbh->commit;    # commit immediat pour eviter les pb de concurrence (?)		
		$req = &SQLCHIPS::do_sql("INSERT INTO $tabspace.$nomtable \
			(Select daf.replicat_id, daf.i_ref, daf.i_sample, daf.log_ratio, daf.bonf_p_value \
			from $ppty.diff_analysis_value daf where daf.spot_id in ($sousreqt))");
			
		if ( defined( $req->{ERR} ) ) {
			# en cas d'erreur d'insertion dans la table
			$sqlerr .= "createTmp_table::INSERT ".$req->{ERRSTR}."\n";
			$SQLCHIPS::dbh->rollback;
		} else {
			$SQLCHIPS::dbh->commit;  
		}		
	}
	
	return $sqlerr;
}

=head2 function

 Title		: fillTmp_table
 Usage		: $sqlerr = consult_diff::fillTmp_table($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $ppty : nom du schema
 Function	: none
 Returns	: $sqlerr, string
 Args		: $nomtable, string (nom de la table a remplir)
 
=cut

sub fillTmp_table () {

	# Complete la table temporaire pour la consultation des donnees
	my $nomtable = shift;
	my $sqlerr   = '';
	my ( $id, $cy3o, $cy5o );

	$SQLCHIPS::dbh->begin_work;		#debut de transaction
	my $req = &SQLCHIPS::do_sql(
		"ALTER TABLE $tabspace.$nomtable add project_id integer;
 		ALTER TABLE $tabspace.$nomtable add experiment_id integer;
 		ALTER TABLE $tabspace.$nomtable add replicat_extracts varchar(100);
 		ALTER TABLE $tabspace.$nomtable add platform varchar(40);
 		ALTER TABLE $tabspace.$nomtable add cy3_extract_pool_id integer;
 		ALTER TABLE $tabspace.$nomtable add cy5_extract_pool_id integer;
 		ALTER TABLE $tabspace.$nomtable add cy3_organ varchar(100);
 		ALTER TABLE $tabspace.$nomtable add cy5_organ varchar(100);"
	);
	if ( defined( $req->{ERR} ) ) {	
		$sqlerr .= "fillTmp_table::ALTER ".$req->{ERRSTR}."\n"; 
		$SQLCHIPS::dbh->rollback; 
	}				
	
	$req = &SQLCHIPS::do_sql(
		"UPDATE $tabspace.$nomtable set 
				project_id=(select r.project_id from $ppty.replicats r where r.replicat_id=$nomtable.replicat_id), 
				experiment_id=(select r.experiment_id from $ppty.replicats r where r.replicat_id=$nomtable.replicat_id),
				replicat_extracts=(select replicat_extracts from $ppty.replicats r where r.replicat_id=$nomtable.replicat_id)"
	);
	$req = &SQLCHIPS::do_sql(
		"UPDATE $tabspace.$nomtable set
				platform=(select h.array_type_name from $ppty.replicats r, $ppty.hybridization h, $ppty.hybrid_replicats hr where r.replicat_id=$nomtable.replicat_id and r.replicat_id= hr.replicat_id and hr.hybridization_id = h.hybridization_id and hr.ref = 1),
				cy3_extract_pool_id=(select h.cy3_extract_pool_id from $ppty.replicats r, $ppty.hybridization h, $ppty.hybrid_replicats hr where r.replicat_id=$nomtable.replicat_id and r.replicat_id= hr.replicat_id and hr.hybridization_id = h.hybridization_id and hr.ref = 1),
				cy5_extract_pool_id=(select h.cy5_extract_pool_id from $ppty.replicats r, $ppty.hybridization h, $ppty.hybrid_replicats hr where r.replicat_id=$nomtable.replicat_id and r.replicat_id= hr.replicat_id and hr.hybridization_id = h.hybridization_id and hr.ref = 1)"
	);
	if ( defined( $req->{ERR} ) ) {	
		$sqlerr .= "fillTmp_table::UPDATE Platform ".$req->{ERRSTR}."\n"; 
		$SQLCHIPS::dbh->rollback; 
	}		
	
	$req = &SQLCHIPS::do_sql(
		"SELECT distinct tmp.replicat_id, s1.organ as cy3_organ, s2.organ as cy5_organ from $tabspace.$nomtable tmp,
 				$ppty.hybrid_labelled_extract hle1, $ppty.extract_pool ep1, $ppty.sample_extract se1, $ppty.sample s1, 
 				$ppty.hybrid_labelled_extract hle2, $ppty.extract_pool ep2, $ppty.sample_extract se2, $ppty.sample s2 
 				where tmp.cy3_extract_pool_id=hle1.labelled_extract_id and hle1.extract_pool_id=ep1.extract_pool_id and 
 				ep1.extract_id=se1.extract_id and se1.sample_id=s1.sample_id and tmp.cy5_extract_pool_id=hle2.labelled_extract_id 
 				and hle2.extract_pool_id=ep2.extract_pool_id and ep2.extract_id=se2.extract_id and se2.sample_id=s2.sample_id"
	);
	my @repid     = &SQLCHIPS::get_col( $req, 0 );
	my @cy3_organ = &SQLCHIPS::get_col( $req, 2 );
	my @cy5_organ = &SQLCHIPS::get_col( $req, 1 );

	foreach $id (@repid) {
		$cy3o = shift @cy3_organ;
		$cy5o = shift @cy5_organ;
		$req  =	&SQLCHIPS::do_sql(
			"UPDATE $tabspace.$nomtable set cy3_organ='$cy3o', cy5_organ='$cy5o' where replicat_id = $id"
			);
	}
	if ( defined( $req->{ERR} ) ) {	
		$sqlerr .= "fillTmp_table::UPDATE Organ ".$req->{ERRSTR}."\n"; 		
		$SQLCHIPS::dbh->rollback; 
	}
	
	if (!$sqlerr) { $SQLCHIPS::dbh->commit; }
	return $sqlerr;
}

=head2 function

 Title		: dropTmp_table
 Usage		: $sqlerr = consult_diff::dropTmp_table($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $errlogf : nom du fichier log
                  $user_name : nom de l'utilisateur
 Function	: none
 Returns	: $sqlerr, string
 Args		: $nomtable, string (nom de la table a supprimer)
 
=cut

sub dropTmp_table () {

	# Supprime une table temporaire du tablespace et log dans tmp_error.log
	my $nomtable = shift;
	my $sqlerr   = '';

	$SQLCHIPS::dbh->begin_work;		#debut de transaction
	my $req = "DROP TABLE $tabspace.$nomtable";
	$req = &CHIPS::exec_req($req,$errlogf,$errlogf,$user_name);
	
	if ($req != 1) {
		# en cas d'erreur
		$sqlerr .= 'dropTmp_table::DROP Error '.$req."\n";
		$SQLCHIPS::dbh->rollback;
	} else {
		$SQLCHIPS::dbh->commit;
	}

	return $sqlerr;
}

#_______________________________________________________________________________________
# Selectionner les donnees d'analyse diff d'une table temporaire
#_______________________________________________________________________________________

=head2 function

 Title		: checkTmp_Data
 Usage		: $nbenr = consult_diff::checkTmp_Data($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
 Function	: none
 Returns	: $nbenr, integer
 Args		: $nomtable, string (nom de la table)
 
=cut

sub checkTmp_Data () {
	# Controle s'il existe des donnees dans la table temporaire
	my $nomtable = shift;
	my $nbenr;
	
	my $req = &SQLCHIPS::do_sql("SELECT count(*) from $tabspace.$nomtable");
	$nbenr = $req->{LINES}[0][0];  # &SQLCHIPS::get_col( $req, 0 );
	undef $req;
	return $nbenr;
}

=head2 function

 Title		: countTmp_Data
 Usage		: ($nbproj, $nbexp) = consult_diff::countTmp_Data($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $ppty : nom du schema
                  $public : valeur de is_public
 Function	: none
 Returns	: $nbproj, integer (nombre de projets)
                  $nbexp, integer (nombre d'experiences)
 Args		: $nomtable, string (nom de la table)
 
=cut

sub countTmp_Data () {
	# Renvoie les nombres de projets et d'experiences de la table temporaire
	my $nomtable = shift;
	my ($nbproj, $nbexp);
		
	my $req =	&SQLCHIPS::do_sql(
			"SELECT count(distinct t.project_id), count(distinct t.experiment_id) from 
			$tabspace.$nomtable t, $ppty.project p, $ppty.experiment e where t.project_id=p.project_id 
			and t.experiment_id=e.experiment_id and p.is_public $public"
		);
	$nbproj = $req->{LINES}[0][0];  #&SQLCHIPS::get_col( $req, 0 );
	$nbexp  = $req->{LINES}[0][1];  #&SQLCHIPS::get_col( $req, 1 );
	undef $req;
	return ($nbproj, $nbexp);
}

=head2 function

 Title		: selectTmp_Data    (or selectDiff_Tmp_Data)
 Usage		: $requete = consult_diff::selectTmp_Data($nomtable, $orderopt)
 Prerequisite	: $tabspace : nom du tablespace 
                  $ppty : nom du schema
                  $public : valeur de is_public
 Function	: none
 Returns	: $requete, ref
 Args		: $nomtable, string (nom de la table)
                  $orderopt, string (clause order by)
 							  
=cut

sub selectTmp_Data () {
	# Selectionne les donnees de la table temporaire, renvoie le pointeur sur requete
	my $nomtable = shift;
	my $orderopt = shift;
	
	my $reqdata = 'SELECT distinct t.project_id, t.experiment_id, t.replicat_id, t.cy5_organ, 
		p.project_name as project, e.experiment_name as experiment, t.platform as "array type", 
		t.cy3_organ as organs, t.replicat_extracts as "S1 / S2", t.I_sample as "I S1", t.I_ref as 
		"I S2", t.log_ratio as "R= IS1-IS2", t.bonf_p_value as "p-val" from ';
  $reqdata .=  "$tabspace.$nomtable t, $ppty.project p, $ppty.experiment e where 
  	t.project_id=p.project_id and t.experiment_id=e.experiment_id and	p.is_public $public 
  	order by $orderopt";

	my $requete = &SQLCHIPS::do_sql($reqdata);
	undef $reqdata;
	return $requete;
}

sub selectDiff_Tmp_Data () {
	# Selectionne seulement les donnees DIFF de la table temporaire, renvoie le pointeur sur requete
	my $nomtable = shift;
	my $orderopt = shift;

	my $reqdata = 'SELECT distinct t.project_id, t.experiment_id, t.replicat_id, t.cy5_organ, 
		p.project_name as project, e.experiment_name as experiment, t.platform as "array type", 
		t.cy3_organ as organs, t.replicat_extracts as "S1 / S2", t.I_sample as "I S1", t.I_ref as 
		"I S2", t.log_ratio as "R= IS1-IS2", t.bonf_p_value as "p-val" from ';
	$reqdata .=  "$tabspace.$nomtable t, $ppty.project p, $ppty.experiment e where 
  		t.project_id=p.project_id and t.experiment_id=e.experiment_id and	p.is_public $public 
  		and t.bonf_p_value < 0.05 order by $orderopt";

	my $requete = &SQLCHIPS::do_sql($reqdata);
	undef $reqdata;
	return $requete;
}
	
#_______________________________________________________________________________________
# Gerer les enregistrements de la table VISITE
#_______________________________________________________________________________________

=head2 function

 Title		: existVisite
 Usage		: $boolean = consult_diff::existVisite($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: none
 Returns	: $boolean (0|1) 
 Args		: $nomtable, string (nom de la table)
 
=cut

sub existVisite () {
	# Verifie l'existence d'un enregistrement dans la table VISITE, renvoie un booleen
	my $nomtable = shift;

	my $req = &SQLCHIPS::do_sql("SELECT count(*) from $tabspace.$visite where table_name = '$nomtable'");
	my $ctl = $req->{LINES}[0][0];  #&SQLCHIPS::get_col( $req, 0 );
	
	if ( $ctl > 0 ) {
		return 1;
	} else {
		return 0;
	}	
}

=head2 function

 Title		: insertVisite
 Usage		: $sqlerr = consult_diff::insertVisite($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: CHIPS::sysdate()
 Returns	: $sqlerr, string 
 Args		: $nomtable, string (nom de la table)
 
=cut

sub insertVisite() {
	# Insere un nouvel enregistrement dans la table VISITE
	my $nomtable = shift;
	my $sqlerr   = '';
	my $datstamp = &CHIPS::sysdate();

	$SQLCHIPS::dbh->begin_work;		#debut de transaction
	my $req = &SQLCHIPS::do_sql(
		"INSERT INTO $tabspace.$visite (table_name,creation_date,last_visited,nb_visit) values \
		('$nomtable',to_date('$datstamp','DD-MM-YYYY'),to_date('$datstamp','DD-MM-YYYY'),1)"
	);

	if ( defined( $req->{ERR} ) ) {
		# en cas d'erreur
		$sqlerr .= "insertVisite::INSERT ".$req->{ERRSTR}."\n";
		$SQLCHIPS::dbh->rollback;
	} else {
		$SQLCHIPS::dbh->commit;		
	}

	return $sqlerr;
}

=head2 function

 Title		: updateVisite
 Usage		: $sqlerr = consult_diff::updateVisite($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: CHIPS::sysdate()
 Returns	: $sqlerr, string 
 Args		: $nomtable, string (nom de la table)
 
=cut

sub updateVisite() {
	# Met a jour un enregistrement dans la table VISITE
	my $nomtable = shift;
	my $sqlerr   = '';
	my $datstamp = &CHIPS::sysdate();
	my $nbvisit;

	my $req =
		&SQLCHIPS::do_sql("SELECT NB_VISIT from $tabspace.$visite where table_name='$nomtable'");
	$nbvisit = $req->{LINES}[0][0];  #&SQLCHIPS::get_col( $req, 0 );
	$nbvisit++;
	
	$SQLCHIPS::dbh->begin_work;		#debut de transaction	
	$req = &SQLCHIPS::do_sql(
		"UPDATE $tabspace.$visite set LAST_VISITED=to_date('$datstamp','DD-MM-YYYY'), \
		NB_VISIT=$nbvisit where table_name='$nomtable'"
		);

	if ( defined( $req->{ERR} ) ) {
		# en cas d'erreur
		$sqlerr .= "updateVisite::UPDATE ".$req->{ERRSTR}."\n";
		$SQLCHIPS::dbh->rollback;
	} else {
		$SQLCHIPS::dbh->commit;
	}

	return $sqlerr;
}

=head2 function

 Title		: deleteVisite
 Usage		: $sqlerr = consult_diff::deleteVisite($nomtable)
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: none
 Returns	: $sqlerr, string 
 Args		: $nomtable, string (nom de la table)
 
=cut

sub deleteVisite() {
	# Supprime un enregistrement dans la table VISITE
	my $nomtable = shift;
	my $sqlerr   = '';
	
	$SQLCHIPS::dbh->begin_work;		#debut de transaction
	my $req = &SQLCHIPS::do_sql("DELETE from $tabspace.$visite where table_name='$nomtable'");

	if ( defined( $req->{ERR} ) ) {
		# en cas d'erreur
		$sqlerr .= "deleteVisite::DELETE ".$req->{ERRSTR}."\n";
		$SQLCHIPS::dbh->rollback;
	} else {
		$SQLCHIPS::dbh->commit;		
	}

	return $sqlerr;	
}

#______ _________________________________________________________________________________
# Gerer l'envoi du mail d'erreur (warnmail)
#_______________________________________________________________________________________

=head2 function

 Title		: getWarnmail
 Usage		: $wmflag = consult_diff::getWarnmail()
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: CHIPS::sysdate()
 Returns	: $wmflag, integer 
 Args		: none
 
=cut

sub getWarnmail () {

	# Recupere le flag d'envoi du mail d'erreur (warnmail)
	my $wmflag;
	my $datstamp = &CHIPS::sysdate();

	my $req =
		&SQLCHIPS::do_sql("SELECT nb_visit from $tabspace.$visite where table_name = 'warnmail'");    
	$wmflag = $req->{LINES}[0][0];  #&SQLCHIPS::get_col( $req, 0 );

	return $wmflag;
}

=head2 procedure

 Title		: setWarnmail
 Usage		: consult_diff::setWarnmail()
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: CHIPS::sysdate()
 Returns	: none
 Args		: none
 
=cut

sub setWarnmail () {

	# Positionne le flag d'envoi du mail d'erreur (warnmail)
	my $datstamp = &CHIPS::sysdate();
	
	$SQLCHIPS::dbh->begin_work;		#debut de transaction	
	my $req = 
		&SQLCHIPS::do_sql("UPDATE $tabspace.$visite set LAST_VISITED=to_date('$datstamp','DD-MM-YYYY'), \
		NB_VISIT=1 where table_name='warnmail'");
	$SQLCHIPS::dbh->commit;
	return;
}

=head2 procedure

 Title		: resetWarnmail
 Usage		: consult_diff::resetWarnmail()
 Prerequisite	: $tabspace : nom du tablespace 
                  $visite : nom de la table visite
 Function	: none
 Returns	: none
 Args		: none
 
=cut

sub resetWarnmail () {

	# Reinitialise le flag d'envoi du mail d'erreur (warnmail)
	$SQLCHIPS::dbh->begin_work;		#debut de transaction	
	my $req =	
		&SQLCHIPS::do_sql("UPDATE $tabspace.$visite set NB_VISIT=0 where table_name='warnmail'");
	$SQLCHIPS::dbh->commit;
	return;
}

#_______________________________________________________________________________________
# Mettre en forme les donnees d'analyse diff pour un tableau HTML
#_______________________________________________________________________________________

=head2 function

 Title		: displayTmp_Coln
 Usage		: \$thline = consult_diff::displayTmp_Coln($numid, $debut, $resultat)
 Prerequisite	: $lkdiffid : lien 
                  $bulupdw : image fleche
                  $coulor : couleur de police
 Function	: none
 Returns	: \$thline, ref 
 Args		: $numid, string  (identifiant CATMA ou AGI)
                  $debut, integer  (index de debut)
                  $resultat, ref  (ref sur resultat de requete de selection des donnees)
 							  
=cut

sub displayTmp_Coln () {

	# Genere une ligne de noms de colonnes au format HTML,
	# renvoie un pointeur sur ligne de tableau HTML
	my $numid = shift;
	my $debut = shift; 
	my $resultat = shift;
	my $bradio = shift;
	
	my $nbcoln = $resultat->{NB_COL};
	my ($updw, $coulor, $thline);
	
	# noms des colonnes
	for (my $i = 0 ; $i < $nbcoln - $debut ; $i++ ) {
		$coulor = $blanc;
		#option de tri
		if ( $i == 0 || $i == 1 || $i == 3 || $i == 7 || $i == 8 ) {
			$updw = "&nbsp;&nbsp;&nbsp;";
			$updw .= $w->a({ -href => "$lkdiffid?idnum=$numid&chptri=$i&totaldiff=$bradio" },
									$w->img({	-src    => "$bulupdw",
													-border => 0,
													-height => 9,
													-width  => 16,
													-alt    => "^" }
									)
								);
		} else {
			$updw = "";
		}
		#valeurs
		if ( $i == 6 ) {
			$coulor = $vert;
		} elsif ( $i == 5 ) {
			$coulor = $rouge;
		}
		
		$thline .= $w->td({ -width => $ttd[$i], -align => 'center' },
								 $w->font({ -color => "$coulor" }, 
										$w->b( $resultat->{COL_NAMES}[ $i + $debut ] ) ), $updw
							 );
	}
	$thline = $w->Tr(
							$w->td(
								$w->table({ -border => 0, -width => "100%" },"\n", 
									$w->Tr( { -bgcolor => $grisF, -height => '25' }, "\n", $thline )
								), "\n"
							)
						)	. "\n";
						
	return 	\$thline;
}

=head2 function

 Title		: displayTmp_Data
 Usage		: \$DataTable = consult_diff::displayTmp_Data($lrmaxi, $resultat)
 Prerequisite	: $lkproject, $lkexpce : liens
                  $blanc, $grisF, $coulor : couleurs
 Function	: none
 Returns	: \$DataTable, ref 
 Args		: $lrmaxi, integer  (echelle log-ratio)
                  $resultat, ref  (ref sur resultat de requete de selection des donnees)
 							  
=cut

sub displayTmp_Data () {

	# Met les donnees au format HTML, 
	# renvoie un pointeur sur lignes de tableau HTML
	my $lrmaxi = shift;
	my $resultat = shift;

	my ($newproj, $oldproj, $oldexp);
	my $countexp = 0;
	my ($viref, $vismp, $vrval);
	my ($dataline, $coulor, $tdline, $trline);
	my $DataTable;
	my $nblines = $resultat->{NB_LINE};
	my (@projid, @expid, @repid, @org5, @projn, @expn, @platf, @org3, @repn, @iref, @ismp, @rval, @pval);
	
	for (my $i = 0; $i < $nblines; $i++) {
		push (@projid, $resultat->{LINES}[$i][0]);
		push (@expid, $resultat->{LINES}[$i][1]);
		push (@repid, $resultat->{LINES}[$i][2]);
		push (@org5, $resultat->{LINES}[$i][3]);
		push (@projn, $resultat->{LINES}[$i][4]);
		push (@expn, $resultat->{LINES}[$i][5]);
		push (@platf, $resultat->{LINES}[$i][6]);
		push (@org3, $resultat->{LINES}[$i][7]);
		push (@repn, $resultat->{LINES}[$i][8]);
		push (@iref, $resultat->{LINES}[$i][9]);
		push (@ismp, $resultat->{LINES}[$i][10]);
		push (@rval, $resultat->{LINES}[$i][11]);
		push (@pval, $resultat->{LINES}[$i][12]);		
	}

	# donnees
	foreach $newproj (@projid) {
		my $newexp = shift @expid;
		my $newrep = shift @repid;
		my $vorg3  = shift @org3;
		my $vorg5  = shift @org5;
		my $vprojn = shift @projn;
		my $vexpn  = substr( shift @expn, 0, 38 );
		my $vrepn  = shift @repn;
#		my $vplatf = substr( shift @platf, 0, 5 );
		my $vplatf = shift @platf;
		my $viref  = sprintf( "%.2f", shift @iref );
		my $vismp  = sprintf( "%.2f", shift @ismp );		
		my $vrval  = sprintf( "%.3f", shift @rval );
		my $vpval  = shift @pval;
		
		# valeurs vides si p-val manquante
		if ( $vpval ne '' ) {
			$vpval = sprintf( "%.0E", $vpval );
		} else {
			$viref = '';
			$vismp = '';
			$vrval = '';
		}
		 
		# organes differents
		if ( $vorg3 ne $vorg5 ) { $vorg3 .= "/$vorg5"; }
		
		# intensite/ratio/pvalue
		$dataline =	$w->td({ -class => "tbot", -width => $ttd[3], -align => 'center' }, $vorg3 );
		$dataline .= $w->td({ -class => "tbot", -width => $ttd[4] },
			$w->a({ -href => "$lkexpce?experiment_id=$newexp#$newrep" }, $vrepn ) );
		$dataline .= $w->td({	-class => "tbot",	-width => $ttd[5], -align => 'center',
				-bgcolor => &consult_package::I_bgcolor($viref)	}, $viref	)	. "\n";
		$dataline .= $w->td({	-class => "tbot",	-width => $ttd[6], -align => 'center',
				-bgcolor => &consult_package::I_bgcolor($vismp)	}, $vismp	)	. "\n";
		$dataline .= $w->td({	-class => "tbot", -width => $ttd[7], -align => 'center',
				-style   => "Color:$blanc",	
				-bgcolor => &consult_package::R_bgcolor( $vpval, $vrval, $lrmaxi )	}, $vrval ) . "\n";
		$dataline .= $w->td({ -class => "tbot",	-width => $ttd[8], -align => 'center',
				-style   => "Color:$grisF",
				-bgcolor => &consult_package::PV_bgcolor($vpval) },	$vpval ) . "\n";

		# projet/experience
		if ( $newproj eq $oldproj ) {
			if ( $newexp eq $oldexp ) {
				$tdline = $w->td({ -colspan => 3 }, "&nbsp;" );
			} else {
				$countexp++;
				$coulor = ( ($countexp) % 2 ) ? $grisC : $grisM;    #alternance couleur de ligne
				
				$tdline = $w->td({ -width => $ttd[0] },
					$w->a({ -href => "$lkproject?project_id=$newproj" }, $vprojn ), "\n" ) . "\n";
				$tdline .= $w->td({ -width => $ttd[1] },
					$w->a({ -href => "$lkexpce?experiment_id=$newexp" }, $vexpn ), "\n" ) . "\n";
				$tdline .= $w->td({ -width => $ttd[2], -align => 'center' }, $vplatf ) . "\n";
			}
			
			$tdline .= $dataline;
			
		} else {
			#projet precedent
			if ($trline) {
				$DataTable .= $w->Tr({ -class => "datatr" },
												$w->td({ -valign => 'top' },"\n",
													$w->table({ -width       => '100%',
																			-border      => 0,
																			-cellspacing => 0,
																			-cellpadding => 1
																		}, "\n", $trline
													),"\n"
												)
											);
				$trline = '';
			}

			#nouveau projet
			$countexp++;
			$coulor = ( ($countexp) % 2 ) ? $grisC : $grisM;    #alternance couleur de ligne

			$tdline = $w->td({ -width => $ttd[0] },
						$w->a({ -href => "$lkproject?project_id=$newproj" }, $vprojn ), "\n" );
			$tdline .= $w->td({ -width => $ttd[1] },
						$w->a({ -href => "$lkexpce?experiment_id=$newexp" }, $vexpn ), "\n" );
			$tdline .= $w->td({ -width => $ttd[2], -align => 'center' }, $vplatf ) . "\n";
			$tdline .= $dataline;
		}

		$trline .= $w->Tr({ -bgcolor => "$coulor" }, $tdline ) . "\n";
		$oldproj = $newproj;
		$oldexp  = $newexp;
	}

	#dernier projet
	$DataTable .= $w->Tr({ -class => "datatr" },
									$w->td({ -valign => 'top' }, "\n",
										$w->table({	-width       => '100%',
																-border      => 0,
																-cellspacing => 0,
																-cellpadding => 1
															}, "\n", $trline
										), "\n"
									)
								)	. "\n";


	return \$DataTable;
}


1;

__END__