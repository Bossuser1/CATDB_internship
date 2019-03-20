#!/usr/local/bin/perl

#-----------------------------------------------------------
# Version du 4/07/2014  
# prise en compte des CATMA v6 et v7
#
#-----------------------------------------------------------
# Version du 31/08/10
# Pgm pour generer le bilan complet sur un projet et un experience
# base sur le meme principe que le fichier genere pour GEO
# mais avec une sortie HTML
# ==> remanie pour l'affichage correct des swaps en HTML
# ==> et pas d'ecriture de LOG
# ==> prise en compte des specificites des puces Chromochip

#use Data::Dumper qw(Dumper);    #pour affichage debug
use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use Tie::IxHash;
use File::Basename;
use File::Copy;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;

#CONSTANTES
#~~~~~~~~~~
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $urgvsmal  = $CHIPS::URGVSMALL;
my $public    = $CHIPS::PUBLIC;
my $w         = new CGI;

# recup du numero d'experience
my $expId = param('experiment_id');

#my $fileLOG =$CHIPS::DBLOG."/ConsultProject.log";
my $imgdwd   = $CHIPS::DOWNLOAD;    #download icon
my $PGPATH   = $CHIPS::PGPATH;
my $weburgv  = $CHIPS::WURGV;
my $home     = $CHIPS::CACCUEIL;
my $consproj = $CHIPS::CPROJECT;
my $consdiff = $CHIPS::CDIFF;
my $legend   = $CHIPS::DSLEGEND;
my $sysdate  = &CHIPS::sysdate();
my $finddata =	$CHIPS::FILEDATA . "/";     # repertoire des fichiers de donnees (grp ou cel)
my $linkdata   = $CHIPS::DATALINK . "/";
my $findproto  = $CHIPS::FILEUPLOAD . "/";
my $linkproto  = $CHIPS::FILELINK . "/";
my $linkArch   = $CHIPS::TARPATH;
my $linkdesign = $CHIPS::DESIGNLINK;
my $linkvignet = $CHIPS::DESIGNLINK . "vignette/";
my $lkftpgpr   = $CHIPS::GPRPATH;
my $lkftpresnorm = $CHIPS::XLSPATH;				# pour les fichiers resNorm publics

#VARIABLES
#~~~~~~~~~
my %swap_project;
tie %swap_project, "Tie::IxHash";
my %swap_exp;
tie %swap_exp, "Tie::IxHash";
my %swap_hyb;
tie %swap_hyb, "Tie::IxHash";
my %swap_type;
tie %swap_type, "Tie::IxHash";
my %other_rep;
my ( $projectId, $exp, $project, $title, $bioInterest, $exptype, $description, $ispublic );
my ( $repos, $repos_db, $repos_ac, $lkrepos );
my ( $array, $expfactor, $analysistype, $projectslide, $projectslideId );
my $userHybId;    # user inclus
my $isnotpub;     # non public
my ( $i, $j );
my ( @ky_swap_type, $ky_idx );                # pour le positionnement d'une ancre
my ( @hybswap, @replicat, @hyb, @reptype );
my ( @hybref, $replicat_ref, $replicat_type, $nbhyb, $hyblist );
my @listrep;
my ( $thisproject,    $printProj, $printSerie );
my ( $thisexpdata,    $design,    $smalldesign, $designlibelle );
my ( @othexpname,     $otherlibelle, $otherplandexp );
my ( $printTableSwap, $printSwap, $printSwapFile );  # partie series_repeat (pour indiquer les swap)
my @listFileName;    # liste des fichiers pour l'archive  # utile si l'archive est faite a la volee
my ( $hybId, $hybIdswap );
my ( $printSample, $printHybrid, $tableValue );  # var pour echantillons et valeurs et les hybridations
my ( $cy3Id, $cy5Id, $array_name, $arrayTypeId );
my ( $cy3sourceId, $cy5sourceId );
my $protocol = {};
my $printRep;    # replicats biologiques ou techniques
my ( $filetar, $filelink );

#navigateurs moz/msie:
my $datadecal = 102;
if ( ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) && ( int($1) < 7 ) ) {
	$datadecal = 0;
}

#REQUETE & TRAITEMENTS
#~~~~~~~~~~~~~~~~~~~~~
# verification si on trouve bien le projet et l'exp dans la base
my $req_project = &SQLCHIPS::do_sql(
	"SELECT e.experiment_name, p.project_id, p.project_name, 
p.title, p.biological_interest, e.EXPERIMENT_TYPE, e.NOTE, p.is_public, e.array_type, 
e.experiment_factors, e.analysis_type, e.protocol_id, e.repository_db, e.repository_access 
FROM $ppty.project p, $ppty.experiment e WHERE p.project_id = e.project_id and 
e.experiment_id = $expId and p.is_public $public"
);

$exp            = $req_project->{LINES}[0][0];
$projectId      = $req_project->{LINES}[0][1];
$project        = $req_project->{LINES}[0][2];
$title          = $req_project->{LINES}[0][3];
$bioInterest    = $req_project->{LINES}[0][4];
$exptype        = $req_project->{LINES}[0][5];
$description    = $req_project->{LINES}[0][6];
$ispublic       = $req_project->{LINES}[0][7];
$array          = $req_project->{LINES}[0][8];
$expfactor      = $req_project->{LINES}[0][9];
$analysistype   = $req_project->{LINES}[0][10];
$projectslideId = $req_project->{LINES}[0][11];
$repos_db       = $req_project->{LINES}[0][12];
$repos_ac       = $req_project->{LINES}[0][13];
undef $req_project;

# diapo sur le design du project
if ( $projectslideId ne "" ) {
	my $preq = &SQLCHIPS::do_sql(
		"select PROTOCOL_FILE from $ppty.protocol where PROTOCOL_ID=$projectslideId" );
	$projectslide = $preq->{LINES}[0][0];
	undef $preq;
}

# Distinction CATMA v2-5/ NimbleGen-Agilent v6-7
my ($extrd, $archext, $resNormfile, $deslibelle, $dwnlibelle, $refconsdiff);
$extrd = '.gpr';				# extension des fichiers rawdata
$archext = 'rawdata.tar';
$dwnlibelle = "Access normalized data for this experiment";
$refconsdiff = sprintf ( "%s?project_id=%d&experiment_id=%d", $consdiff, $projectId,$expId);

if ($array ne 'CATMA') { 
	$extrd = '.pair';
	$archext = 'data.tar';
	$resNormfile = sprintf ("resNorm_%s_exp%d.txt.gz", $project, $expId);  	# nom fichier resNorm
	$dwnlibelle = "Download normalized data for this experiment<i>(resNorm file)</i>";
	$refconsdiff = sprintf ("%s/%s",$lkftpresnorm, $resNormfile);
	
}

# ID user
my $requser = &SQLCHIPS::do_sql(
	"select distinct user_id from $ppty.hybridization where experiment_id=$expId" );
$userHybId = $requser->{LINES}[0][0];
undef $requser;

my $nodata     = 0;
my $noswap     = 0;
my $nbswap     = 0;
my $nbreplicat = 0;

if ( $ispublic ne "yes" && $ENV{'HOST'} =~ /urgv/ ) {
	# message project non public
	$isnotpub = $w->h2( { -align => 'center', -style => "color:red" },
											"**** SORRY, THIS PROJECT IS NOT AVAILABLE ****" );
} else {
	# projet public
	# Les protocoles de data processing ne changent pas
	# donc on va chercher le contenu dans des fichiers
	# marche seulement pour les analyses de puces CATMA
	# my $filedataprocessing=&recupProtocolFile("./local_data/data_processing.txt");
	# Pour la version TEXT on met la descritpion des stats directement dans une variable
	my $filedataprocessing =
		"The statistical analysis was based on one dye-swap, <i>i.e.</i> two arrays 
  containing the GSTs and 384 controls. The raw data comprised the logarithm of median feature pixel 
  intensity at wavelength 635 nm (<font color='red'>red</font>) and 532 nm (<font color='green'>green</font>). 
  No background was subtracted. An array-by-array normalization was performed to remove systematic biases. 
  First, we excluded spots that were considered badly formed features by the experimenter (Flags=-100). Then we 
  performed a global intensity-dependent normalization using the loess procedure (see Yang <i>et 
  al.</i>, 2002) to correct the dye bias. Finally, on each block, the log-ratio median is subtracted 
  from each value of the log-ratio of the block to correct a print-tip effect on each metablock. 
  To determine differentially expressed genes, we performed a paired t-test on the log-ratios. 
  The raw P-values were adjusted by the Bonferroni method, which controls the Family Wise Error 
  Rate (FWER) (Ge <i>et al.</i>, 2003).";

	@hybswap = ();    # on va mettre les hyb par swap
    # On va aller chercher les swaps et hybridations
    # on comptabilise tout mais on gardera que les swap pour les hybridations
	my $reqswap = &SQLCHIPS::do_sql(
		"select rh.replicat_id, rh.hybridization_id, r.rep_type from $ppty.hybrid_replicats rh, $ppty.replicats r 
  		where r.project_id=$projectId and experiment_id=$expId and rh.replicat_id=r.replicat_id order by 
  		rh.replicat_id, rh.hybridization_id"
	);
	my $nbl = $reqswap->{NB_LINE};
	
	if ( $nbl != 0 ) {
		for (my $k=0; $k < $nbl; $k++) {
			push (@replicat, $reqswap->{LINES}[$k][0]);
			push (@hyb, $reqswap->{LINES}[$k][1]);
			push (@reptype, $reqswap->{LINES}[$k][2]);
		}
		undef $reqswap;
		
		# pour chaque replicat on regroupe par replicat
		$replicat_ref  = $replicat[0];
		$replicat_type = $reptype[0];
		@hybref        = ( $hyb[0] );
		for ( $j = 1 ; $j < scalar(@replicat) ; $j++ ) {
			if ( $replicat[$j] == $replicat_ref ) {    # meme replicat donc on regroupe ensemble
				push( @hybref, $hyb[$j] );
			} else {    # on passe a un nouveau replicat donc on stock le precedent
				$nbhyb                       = scalar(@hybref);
				$hyblist                     = join( ", ", @hybref );
				$hybswap[$nbswap]            = [@hybref];
				$swap_hyb{$replicat_ref}     = $nbhyb;
				$swap_project{$replicat_ref} = $projectId;
				$swap_exp{$replicat_ref}     = $expId;
				$swap_type{$replicat_ref}    = $replicat_type;
				$nbreplicat++;

				if ( $nbhyb <= 2 ) {
					$nbswap++;
				} else {
					$noswap++;
			 		# on va aller chercher la liste des sous-replicat de ce replicat biologique ou technique
					my $reqrep = &SQLCHIPS::do_sql(
						"select REPLICAT_EXTRACTS from $ppty.replicats where replicat_id in
	   				(select LINK_REP from $ppty.LINK_REPLICATS where REPLICAT_ID=$replicat_ref)"
					);
					@listrep = &SQLCHIPS::get_col( $reqrep, 0 );
					$other_rep{$replicat_ref} = join( " and ", @listrep );
				}

				# nouveau on reinitialise
				$replicat_ref  = $replicat[$j];
				@hybref        = ( $hyb[$j] );
				$nbhyb         = 1;
				$hyblist       = "";
				$replicat_type = $reptype[$j];
			}
		}

		# on traite le dernier cas
		$nbhyb                       = scalar(@hybref);
		$hyblist                     = join( ", ", @hybref );
		$hybswap[$nbswap]            = [@hybref];
		$swap_hyb{$replicat_ref}     = $nbhyb;
		$swap_project{$replicat_ref} = $projectId;
		$swap_exp{$replicat_ref}     = $expId;
		$swap_type{$replicat_ref}    = $replicat_type;
		$nbreplicat++;

		if ( $nbhyb <= 2 ) {
			$nbswap++;
		} else {
			$noswap++;
			# on va aller chercher la liste des sous-replicat de ce replicat biologique ou technique
			my $reqrep = &SQLCHIPS::do_sql(
				"select REPLICAT_EXTRACTS from $ppty.replicats where replicat_id in 
      		(select LINK_REP from $ppty.LINK_REPLICATS where REPLICAT_ID=$replicat_ref)"
			);
			@listrep = &SQLCHIPS::get_col( $reqrep, 0 );
			$other_rep{$replicat_ref} = join( " and ", @listrep );
			undef $reqrep;
		}
	} else {
		$nodata++;
	}

	# on recupere les replicat_id qui serviront d'ancre
	@ky_swap_type = keys(%swap_type);
	$ky_idx       = 0;

	# on va aller chercher les caracteristiques des echantillons de chaque
	# hybridation (nom, tissu,...)
	# Impression du projet et de l'experience
	$thisproject = $w->a( { -href => $consproj . "?project_id=$projectId" }, $project );
	$printProj = &printProject( $thisproject, $exp, $bioInterest, $title, $projectslide );

	# Repository
	if ( $repos_db ne '' ) {
		my $reqrepos = &SQLCHIPS::do_sql("Select URL from $ppty.link_url where DATABASE='$repos_db'");
		($lkrepos) = $reqrepos->{LINES}[0][0];
		$repos = $w->a( { -href => "${lkrepos}$repos_ac", -target => '_blank' },
										"\n", $w->b($repos_db), " ...... accession # $repos_ac" );
		undef $reqrepos;				
	}

	# Impression des SERIES
	$printSerie = &printSeries( $projectId, $nbswap, $userHybId, $exp, $exptype, $description, $array,
									$expfactor, $analysistype, $ky_swap_type[$ky_idx], $repos );

	# Design :
	# nom du fichier du plan d'experience : $projectslide
	if ( $projectslide ne '') {
		my ( $dsgnname, $dsgnpath, $dsgnsufx ) = fileparse( $projectslide, qr/\.[^.]*/ );
		$design = sprintf ("%s%s%s", $linkdesign, $dsgnname, $dsgnsufx);
		$smalldesign = sprintf ("%s%s_300%s", $linkvignet, $dsgnname , $dsgnsufx);
		$designlibelle = "Experimental design " . $w->i("(click to enlarge):");
		$design = $w->a( { -href => "javascript:PopupImage('$design','$legend','$project','$exp')" },
								$w->img( {	-style  => 'background:#EEEEEE;border-color:#000070',
														-left   => 1,
														-src    => $smalldesign,
														-border => 1,
														-alt    => " picture not yet available "
													}
								)
							);
		$thisexpdata = $w->a( { -href => $refconsdiff },
											$w->img( { -src    => $imgdwd,
																 -height => 32,
																 -border => 0,
																 -alt    => 'download'
																}
											),
											$dwnlibelle
									 );
	} else {
		$designlibelle = "Experimental design: ";
		$design = $w->p( { -style => 'color:orange' }, "Sorry, not yet available !" );
	}

	# noms des autres experiences du projet
	my $reqothexp = &SQLCHIPS::do_sql( "select experiment_name, experiment_id from 
  $ppty.experiment where project_id = $projectId and experiment_id <> $expId" );
	
	for ($i=0; $i < $reqothexp->{NB_LINE}; $i++) {
		$otherlibelle = "Other experimental design(s) for this project:";
		$otherplandexp .=	$w->Tr(
			$w->td( $w->a( { -href => "consult_expce.pl?experiment_id=$reqothexp->{LINES}[$i][1]" }, 
			$reqothexp->{LINES}[$i][0] ) ) );
	}
	undef $reqothexp;

	# Pour les protocols et leur detail : on va tous les recuperer pour les afficher a la fin
	# tableau protocol un peu comme un hachage: cle =type de protocol
	# type = extract, label, hybrid
	$protocol->{extract}  = [];    # tabeau des protocols car pls par projets pour un meme type
	$protocol->{label}    = [];
	$protocol->{'hybrid'} = [];
	
	# VERO POUR chaque SWAP
	# Astuce pour eviter de repeter le swap
	my %rep_deja_traite=();
	while ( my ( $rep, $type ) = each(%swap_type) ) {
	if($rep_deja_traite{$rep} eq ''){ # si pas deja traite
		$rep_deja_traite{$rep}=$rep;
		if ( $type eq "swap" || $type eq "r_swap" ) {    # on va ecrire que pour les swap
			    # on va gerer les projets par swap
			    # initialisation des var au niveau d'un swap
			my $sampleCy3 = {};    # pour rassembler les donnees sur cy3
			my $sampleCy5 = {};    # pour rassembler les donnees sur cy5
			my $hyb       = {};    # pour rassembler les donnees generales sur l'hybridation
			                       # dont on aura besoin au niveau des hybridations
			$hyb->{bioInterest} = $bioInterest;
			$hyb->{title}       = $title;

			# on va aller chercher uniquement le swap de reference et son nom
			my $reqSwap = &SQLCHIPS::do_sql(
				"select hr.hybridization_id, r.REPLICAT_EXTRACTS from $ppty.replicats r, 
      $ppty.HYBRID_REPLICATS hr where hr.REPLICAT_ID=$rep and hr.REF=1 and 
      r.replicat_id=hr.replicat_id"
			);
			$hybId = $reqSwap->{LINES}[0][0];
			$hyb->{Name} = $reqSwap->{LINES}[0][1];


			# on recupere aussi l'hybridation contraire pour les fichiers a recuperer
			my $reqSwap = &SQLCHIPS::do_sql(
				"select hr.hybridization_id, r.REPLICAT_EXTRACTS from $ppty.replicats r, 
      $ppty.HYBRID_REPLICATS hr where hr.REPLICAT_ID=$rep and hr.REF=0 and 
      r.replicat_id=hr.replicat_id"
			);
			$hybIdswap = $reqSwap->{LINES}[0][0];
			$hyb = &recupScanFile( $hybIdswap, $hyb, "_swap" );
			undef $reqSwap;
			
			# aller chercher les donnees dans hybridation
			# le code barre, Cy3, Cy5
			my $reqHyb = &SQLCHIPS::do_sql(
				"select HYBRIDIZATION_NAME, CY3_EXTRACT_POOL_ID, CY5_EXTRACT_POOL_ID, 
      ARRAY_TYPE_NAME, user_id from $ppty.HYBRIDIZATION where HYBRIDIZATION_ID=$hybId"
			);
			$hyb->{codebarre} = $reqHyb->{LINES}[0][0];
			$cy3Id            = $reqHyb->{LINES}[0][1];
			$cy5Id            = $reqHyb->{LINES}[0][2];
			$array_name   = $reqHyb->{LINES}[0][3];
			$arrayTypeId = &recupdbId( "ARRAY_TYPE", $array_name );
			$userHybId = $reqHyb->{LINES}[0][4]; #( &SQLCHIPS::get_col( $reqHyb, 4 ) )[0];
			undef $reqHyb;
			
			# on recupere les noms des Extraits marques
			$sampleCy3->{Name} = &recupdbName( "labelled_extract", $cy3Id );
			$sampleCy5->{Name} = &recupdbName( "labelled_extract", $cy5Id );

			# on va former le nom pour Sample_Title: echCy3 vs EchCy5
			#$hyb->{TitleName} = $sampleCy3->{Name} . " vs " . $sampleCy5->{Name};

			# aller chercher les donnees protocol de scan et autre lies a l'hybridation
			$hyb = &recupScanProtocol( $hybId, $hyb );
			$hyb = &recupHybProtocol( $sampleCy3->{Name}, $sampleCy5->{Name}, $hybId, $hyb );
			&protocolFile( $hyb->{hybrid_proto_file}, "hybrid", $protocol );
			push( @listFileName, $hyb->{data_file} );
			push( @listFileName, $hyb->{data_file_swap} );
			$protocol->{'data'}[0] = $filedataprocessing;
			$hyb->{array_type}     = $array_name;
			$hyb->{array_type_id}  = $arrayTypeId;
			$hyb->{replicat_id}    = $rep;

			# On va chercher le protocol des extraits et des labelling
			# treatment sur les fichiers de protocols
			( $sampleCy5, $hyb ) = &recupExtractProtocol( $cy5Id, $sampleCy5, $hyb );
			( $sampleCy3, $hyb ) = &recupExtractProtocol( $cy3Id, $sampleCy3, $hyb );
			&protocolFile( $hyb->{extract_proto_file}, "extract", $protocol );
			( $sampleCy5, $hyb ) = &recupLabelProtocol( $cy5Id, $sampleCy5, $hyb );
			( $sampleCy3, $hyb ) = &recupLabelProtocol( $cy3Id, $sampleCy3, $hyb );
			&protocolFile( $hyb->{label_proto_file}, "label", $protocol );

			# on va chercher ce qu'il nous faut dans la table sample pour Cy3 et Cy5
			( $sampleCy3, $cy3sourceId ) = &recupSample( $cy3Id, $projectId, $expId, $sampleCy3, $array, $analysistype );
			( $sampleCy5, $cy5sourceId ) = &recupSample( $cy5Id, $projectId, $expId, $sampleCy5, $array, $analysistype );

			# on va chercher ce qu'il nous faut dans la table sample_source pour Cy3 et Cy5
			$sampleCy3 = &recupSampleSource( $cy3sourceId, $sampleCy3 );
			$sampleCy5 = &recupSampleSource( $cy5sourceId, $sampleCy5 );

			# on va chercher pour les traitement si y en a un
			$sampleCy3 = &recupTreatment( $cy3Id, $sampleCy3 );
			$sampleCy5 = &recupTreatment( $cy5Id, $sampleCy5 );

			# on va chercher pour la molecule a extraires
			$sampleCy3 = &recupMoleculeType( $cy3Id, $sampleCy3 );
			$sampleCy5 = &recupMoleculeType( $cy5Id, $sampleCy5 );

			# on cherche l'id du replicat suivant pour l'ancre
			if ( $ky_idx < scalar(@ky_swap_type) ) { $ky_idx++; }
			else { $ky_idx = ''; }

			# impression 1ere lame
			$printSample = &printofhybEntete( $printSample, $hyb );
			$printSample = &printofhybSample( $printSample, "1", $sampleCy5, "Cy5", $array, $analysistype );
			$printSample = &printofhybSample( $printSample, "2", $sampleCy3, "Cy3", $array, $analysistype, 
																						$ky_swap_type[$ky_idx] );
			$printHybrid = &printofhybEnd( $printHybrid, $hyb );

# recuperation des valeurs d'hybridation
#$tableValue=&printTableEntete($tableValue);
#$tableValue=&recupValues($rep,$arrayTypeId,$tableValue,"0"); # 1= partiel 10 valeurs seulement
# pour affichage des Samples
			 $printSwap ="";
			 $printSwapFile ="";
			 $printSwap = &printwebtitle( "Swap: " . $w->font( { -color => '#FFFF00' }, $hyb->{Name}) );
			 $printSwap .= $w->table( { -class => "info", -width => '80%', -align => 'center' }, $printSample );
			 $printSwapFile = $w->table({	-class => "info",
																		-width => '80%',
																		-align => 'center',
																		-style => "border-top:0px"
																	},
																	$printHybrid );
			 $printSample = '';
			 $printHybrid = '';
			 $printTableSwap = sprintf ( "%s%s%s\n", $printTableSwap, $printSwap, $printSwapFile );
			
		} # fin if swap,r_swap
	}# fin if rep deja traite
	}# fin while

	# impression des replicats biologiques ou techniques qui vont ensemble
	if ( $noswap != 0 ) {    # s'il y a des rep biologiques
		$j = 0;
		while ( my ( $v, $k ) = each(%other_rep) ) {
			$j++;
			$printRep .= &printwebtable( "replicat bio $j", $k );
		}
		$printRep =
			$w->table( { -class => "info", -width => '80%', -align => 'center' }, $printRep ), "\n",
			$printRep = &printwebtitle("Biological replicats") . $printRep;
	}

	# affiche les protocols -> voir partie HTML
	#my $printProto=&printProtocol($protocol);
	#print $w->table({-class=>"info",-width=>'80%',-align=>'center'},$printProto);
	# fichier tar des GPR ou CEL avant
	# my $filetar=&archiveFiles($project,$expId, $archext, $CHIPS::TARPATH,$finddata,@listFileName);
	# si l'archive n'est pas deja faite on appelle la fct archive File
	# mais pour aller plus vite et prendre moins de place on les a deja fait et compresser
	if ($array ne 'CATMA') { 
		$filetar  = &linkarchiveFiles( lc($project), $expId,  $archext);
	} else {
		$filetar  = &linkarchiveFiles( $project, $expId,  $archext);
	}
	
	$filelink = &linkFile( $filetar, $lkftpgpr, "_self" );
}


#HTML
#~~~~
print $w->header();
my $JSCRIPT = <<END;
function PopupImage(img, legend, proj, exp) {
  titre = proj+" :: "+exp;
  tableau = "<TABLE width='100%' border=0 cellspacing=5><tr><td><IMG src='"+img+"' border=0 alt='Experimental design'></td><td width='25%'><IMG src='"+legend+"' border=1 style='background:#EFEFEF; border-color:#000070' alt='Legends'></td></tr></table>";

  w=open("",'image','width=400,height=400,toolbar=no,location=no,directories=no,statusbar=no,menubar=no,scrollbars=no,resizable=yes,navigationbar=no');	
  w.document.write("<HTML><HEAD><TITLE>"+titre+"</TITLE></HEAD>");
  w.document.write("<SCRIPT language=javascript> function checksize()  { if (document.images[0].complete) { if (document.images[0].height < document.images[1].height) { hautmax = document.images[1].height; } else { hautmax = document.images[0].height; } window.resizeTo(document.images[0].width+document.images[1].width+70, hautmax+90); window.focus(); } else { setTimeout('check()',250); } } </"+"SCRIPT>");
  w.document.write("<BODY onload='checksize()' leftMargin=2 topMargin=2 marginwidth=2 marginheight=5>"); //<IMG src='"+img+"' border=0><IMG src='"+legend+"' border=1>");
  w.document.write(tableau);
  w.document.write("</BODY></HTML>");
  w.document.close();
}

function retour(form){
    history.back();
}

END
print $w->start_html(	-title  => 'CATdb Experiment info',
											-author => 'bioinfo@evry.inra.fr',
											-meta   => { 'keywords' => 'CATdb', 'robots' => 'noindex,nofollow' },
											-style   => { -src => $stylepath },
											-BGCOLOR => "#FFFFFF",
											-script  => $JSCRIPT
			);
			
if ( $isnotpub ne '' ) {
	print $w->div( { -class => "entete" }, "\n", 
					&printLogo( $weburgv, $home ), "\n", 
					$w->br, "\n", $isnotpub );
} else {

	# Entete:
	print $w->div( { -class => "entete" }, "\n", 
					&printLogo( $weburgv, $home, $project, $exp ) ), "\n";

	# Corps:
	print $w->div( { -class => "corpus", -style => "top:" . $datadecal . "px;" }, "\n",
					# affichage project + design
					&printwebtitle("Project's complete description"),	"\n",
					$w->table( { -border => 0, -cellspacing => 5, -align => 'center' },
						$w->Tr(
							$w->td( { -width => '70%', -valign => 'top' },
								$w->table( { -class => "info", -width => '100%' }, 
													$printProj,	$printSerie
								), "\n"
							),
							$w->td( { -align  => 'center',
												-style  => 'color:#555555',
												-valign => 'top'
											}, "\n",
								$w->table( { -width => '100%', -border => 0 },
									$w->Tr( $w->td( {-nowrap}, $designlibelle ) ), "\n",
									$w->Tr( $w->td($design) ), "\n",
									$w->Tr( $w->td($thisexpdata) ), "\n",
									$w->Tr( $w->td('&nbsp;') ), "\n",
									$w->Tr( $w->td( $w->i($otherlibelle) ) ), "\n", $otherplandexp
								), "\n"
						 	)
						)
					), "\n",

					# affichage des Samples
					$printTableSwap,

					# affichage des replicats biologiques ou techniques
					$printRep, "\n",

					# affichage des protocoles
					&printwebtitle("Details on protocols used for this project"),
					$w->table( { -class => "info", -width => '80%', -align => 'center' },
							 			&printProtocol($protocol)
					), "\n",

					# affichage lien fichier tar
					&printwebtitle("Download raw data ($extrd files) of this project"),
	
	 				$w->table( { -class => "info", -width => '80%', -align => 'center' },
										&printDownload($filelink)
					), "\n",
					$w->br, "\n",

					# bouton back
					$w->div( { -class => "pied", -align => "center" },
						$w->button( -name    => 'buttonSubmitRetour',
											  -value   => 'BACK',
												-onClick => "retour(this.form);"
						)
					), "\n",
				), "\n";    #fin div corpus
}

print $w->end_html;

################################## FUNCTIONS #################################
# nettoie les chaines de caracteres
sub clean() {
	my $var = shift;
	$var =~ s/\n/ /g;    # pas de retour a la ligne
	$var =~ s/\r/ /g;
	$var =~ s/ +/ /g;
	return $var;
}

# recuperer a partir d'un identifiant le champs Name correspondant dans une table
sub recupdbName() {
	my $table        = shift;
	my $valId        = shift;
	my $attributName = $table . "_name";
	my $attributId   = $table . "_id";
	my $req          =
		&SQLCHIPS::do_sql("select $attributName from $ppty.$table where $attributId=$valId");
	my $name = $req->{LINES}[0][0];
	return ($name);
}

# recuperer a partir d'un nom (champs_name) le champs ID correspondant dans une table
sub recupdbId() {
	my $table        = shift;
	my $valName      = shift;
	my $attributName = $table . "_name";
	my $attributId   = $table . "_id";
	my $req = &SQLCHIPS::do_sql(
		"select $attributId from $ppty.$table where $attributName='$valName'" );
	my $id = $req->{LINES}[0][0];
	return ($id);
}

#-----------------------------------
# Impressions des Projects:
# entete logo
sub printLogo() {
	my $wurgv  = shift;
	my $catdb  = shift;
	my $proj   = shift;
	my $ex     = shift;
	my $projex = "";
	if ( $proj ne '' ) {
		$projex = &printProjectExperiment( $proj, $ex );
	}
	my $logo = $w->div( { -class => "entete1", -align => 'center' },
											$w->div( { -class => "logo" },
															 $w->a( { -href => $wurgv },
																			$w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" }
																			)
															 )
											),
											$w->div( { -class => "titre" },
															 $w->a( { -href => $catdb },
																			$w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" }
																			)
															 ),
															 $w->br,
															 $w->br,
															 $projex,
															 $w->br
											)
							)
							. $w->br
							. $w->br . "\n";
	return $logo;
}

# titre project experiment
sub printProjectExperiment() {
	my $proj = shift;
	my $ex   = shift;
	my $new = $w->div( { -align => 'center', -style => 'font-weight:bold; font-size:11pt; Color:#336699' },
						 $w->i( "~ Project: ",
										$w->font( { -size => 4, -style => 'font-weight:bold; color:#000070;' },
															$proj
										),
										" &nbsp;~&nbsp; Experiment: ",
										$w->font( { -size => 4, -style => 'font-weight:bold; color:#000070;' }, $ex
										),
										" ~"
							)
						);
	return ($new);
}

# tableau Project
sub printProject() {
	my $proj  = shift;
	my $ex    = shift;
	my $bio   = shift;
	my $title = shift;
	my $slide = shift;
	my $pr;
	$pr .= &printwebtable( "Project name ", $proj );
	if ( $title ne "" ) {
		$pr .= &printwebtable( "Project title", $title );
	}
	$pr .=
		&printwebtable( "Biological interest", $bio );    # on met ca pour sample_description mais
	                                                    # en fait on a rien d'autre a ajouter
	$pr .= &printwebtable( "Experiment name", $ex );
	return ($pr);
}

#-----------------------------------
# Normalisation de l'ecriture:
# pour toutes les ecritures web des titres
sub printwebtitle() {
	my $t   = shift;
	my $new =
		  $w->div( { -class => 'banner' }, $w->br, $w->div( { -class => 'bannertext' }, $t ) )
		. $w->br;
	return ($new);
}

# pour toutes les ecritures web des tables
sub printwebtable() {
	my ( $title, $val ) = @_;
	my $grisF = "#BBBBBB";
	my $new = $w->Tr(
										$w->td( { -bgcolor => $grisF, -style => "color:white;" }, $w->b($title)
										),
										$w->td($val)
						);
	return ($new);
}

# liens url
# trois parametres dont $target = _self (meme fenetre) ou _blank (nouvelle fenetre)
sub linkFile() {
	my ( $f, $link, $target ) = @_;
	my $newf;
	if ( $f ne "" ) {
		$newf = $w->a( { -href => "$link/$f", -target => $target }, " $f " );
	}
	return $newf;
}

#-----------------------------------
# Recuperer les parametres du scan:
# rq juste pour 2 couleurs pour l'instant
sub recupScanProtocol() {
	my ( $hid, $val ) = @_;
	my $reqScan =	&SQLCHIPS::do_sql(
"select PMT_VOLTAGE_1, PMT_VOLTAGE_2, LASER_POWER, LASER_POWER_2, SOFTWARE_ANALYSIS from 
$ppty.SCANANALYSIS_PROTOCOL where SCANANALYSIS_protocol_id in (select SCANANALYSIS_PROTOCOL_ID 
from $ppty.HYBRID_IMAGEDATA where HYBRIDIZATION_ID=$hid)"
		);
	my $voltcy3  = $reqScan->{LINES}[0][0];
	my $voltcy5  = $reqScan->{LINES}[0][1];
	my $lasercy3 = $reqScan->{LINES}[0][2];
	my $lasercy5 = $reqScan->{LINES}[0][3];
	my $soft     = $reqScan->{LINES}[0][4];
	undef $reqScan;
	$val->{scan_protocol} =
"$soft, Cy3:pmt voltage 532nm,$voltcy3,laser power $lasercy3, Cy5:635nm,pmt voltage $voltcy5,laser power $lasercy5";
	$val = &recupScanFile( $hid, $val, "" );
	return $val;
}

# recuperation des fichiers lies au scan
sub recupScanFile() {
	my $h        = shift;
	my $v        = shift;
	my $name     = shift;    # pour l'autre hybridation du swap
	my $reqfiles = &SQLCHIPS::do_sql(
"select DATA_FILE_name, IMAGE_FILE_NAME from $ppty.IMAGE_DATA_FILE where IMAGE_DATA_FILE_ID in 
(select IMAGE_DATA_FILE_ID from $ppty.HYBRID_IMAGEDATA where HYBRIDIZATION_ID=$h)"
		);
	if ( $name eq "" ) {
		$v->{'data_file'}  = $reqfiles->{LINES}[0][0];
		$v->{'image_file'} = $reqfiles->{LINES}[0][1];
	} else {
		$v->{"data_file$name"}  = $reqfiles->{LINES}[0][0];
		$v->{"image_file$name"} = $reqfiles->{LINES}[0][1];
	}
	undef $reqfiles;
	return $v;
}

#-----------------------------------
# Pour les Hybridations:
# entete des hybridations
sub printofhybEntete() {
	my $p      = shift;
	my $hybrid = shift;
	$p .= &printwebtable( "Swap name", $w->b( $hybrid->{Name}) );
	$p .= &printwebtable(	"Array type",
							$w->a( { -href => "./consult_project.pl?array_type_id=$hybrid->{array_type_id}" },
										$hybrid->{array_type}
							)
				);
	return $p;
}

# par channel
sub printofhybSample() {
	my $p        = shift;
	my $ch       = shift;
	my $sample   = shift;
	my $name     = shift;
	my $platf = shift;
	my $typanalyse = shift;	
	my $replid   = shift;   # pour l'ancre
	my $libcolor = "white";
	my $grwpro   = "growth protocol";

	# on va mettre le channel au nom
	if ( $name eq "Cy5" ) {
		$name = $w->font( { -color => 'red', -style => 'font-weight: bold;' }, $name );
		$libcolor = "red";
	} elsif ( $name eq "Cy3" ) {
		$name = $w->font( { -color => 'green', -style => 'font-weight: bold;' }, $name );
		$libcolor = "green";
		if ( $replid ne '' ) { $grwpro .= $w->a( { -name => $replid }, ' ' ); }
	}
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "Channel" ), $name );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "Sample name" ), $sample->{Name} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "organism" ), $sample->{organism} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "organ" ), $sample->{tissue} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "characteristics" ),
												$sample->{characteristics} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "mutation" ), $sample->{mutant} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "treatment protocol" ),
												$sample->{treatment} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, $grwpro ), $sample->{growthcond} );

	if ( $platf eq 'Chromochip' && $typanalyse eq 'ChIP-chip' ) {
		$p .= &printwebtable( $w->font( { -color => $libcolor }, "immuno-precipitation" ), $sample->{ip} );
	}
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "molecule type" ),
												$sample->{molecule_type} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "extract protocol" ),
												$sample->{extract_protocol} );
	$p .= &printwebtable( $w->font( { -color => $libcolor }, "labelling protocol" ),
												$sample->{label_protocol} );
	return $p;
}

# fin entete hybridation
sub printofhybEnd() {
	my $p      = shift;
	my $hybrid = shift;

#  $p.=&printwebtable("Data file", &linkFile($hybrid->{data_file},$linkdata,"_blank").",".&linkFile($hybrid->{data_file_swap},$linkdata,"_blank"));
#  $p.=&printwebtable("Image file", &linkFile($hybrid->{image_file},$linkdata,"_blank").",".&linkFile($hybrid->{image_file_swap},$linkdata,"_blank"));
	$p .= &printwebtable( "Data file", $hybrid->{data_file} . ", " . $hybrid->{data_file_swap} );
	return $p;
}

# Recuperer les parametres de l'hybridation
sub recupHybProtocol() {
	my ( $cy3, $cy5, $hid, $val ) = @_;
	my $reqProto = &SQLCHIPS::do_sql(
	"select h.QUANTITY_VALUE, h.QUANTITY_UNIT, p.PROTOCOL_file from $ppty.hybridization h LEFT 
   OUTER JOIN $ppty.protocol p ON p.PROTOCOL_ID=h.PROTOCOL_ID where hybridization_id=$hid"
	);
	my $qval  = $reqProto->{LINES}[0][0];
	my $qunit = $reqProto->{LINES}[0][1];
	my $pfile = $reqProto->{LINES}[0][2];
	undef $reqProto;
	$val->{hyb_protocol}      = "$cy5 Cy5 / $cy3 Cy3 : $qval $qunit";
	$val->{hybrid_proto_file} = $pfile;
	return $val;
}

# Recuperer les parametres du labelling protocol
sub recupLabelProtocol() {
	my $lid = shift;    # pour le LabelledextractId
	my $val = shift;    # par extrait
	my $hyb = shift;    # par hybridation (deatil du protocol avec le fichier associe)
	my $reqProto = &SQLCHIPS::do_sql(
		"select LABELLING_TYPE, LABEL_NAME, MOLECULE_TYPE, AMPLIFICATION, QUANTITY_VALUE, 
		QUANTITY_UNIT , p.protocol_file from $ppty.LABELLED_PROTOCOL lp LEFT OUTER JOIN 
		$ppty.protocol p ON p.PROTOCOL_ID=lp.PROTOCOL_ID where lp.LABELLED_PROTOCOL_ID in 
  (select LABELLED_PROTOCOL_ID from $ppty.labelled_extract where LABELLED_extract_id=$lid)"
	);
	my $nb      = $reqProto->{NB_COL} - 1;
	my $labtype = $reqProto->{LINES}[0][0];
	my $lab     = $reqProto->{LINES}[0][1];
	my $moltype = $reqProto->{LINES}[0][2];
	my $ampli   = $reqProto->{LINES}[0][3];
	my $qval    = $reqProto->{LINES}[0][4];
	my $qunit   = $reqProto->{LINES}[0][5];
	my $pfile   = $reqProto->{LINES}[0][6];
	undef $reqProto;
	$val->{label_protocol} =
		"labelling $lab $labtype, amplificate=$ampli, $moltype $qval $qunit";
	$hyb->{label_proto_file} = $pfile;
	return ( $val, $hyb );
}

# Recuperer les parametres du protocol d'extraction
# depend si il y a des pool ou pas
sub recupExtractProtocol() {
	my $lid = shift;    # pour le LabelledextractId
	my $val = shift;    # par extrait
	my $hyb = shift;    # par hybridation (deatil du protocol avec le fichier associe)
	$val->{extract_protocol} = "";    # on reinitialise

	# attention un peu complique suivant si il y a un Pool ou pas
	my $reqProto = &SQLCHIPS::do_sql(
		"select ep.EXTRACT_POOL_FLAG, e.extract_name, ep.quantity_value, ep.quantity_unit, 
		p.protocol_file from $ppty.EXTRACT e LEFT OUTER JOIN $ppty.protocol p	ON 
		p.PROTOCOL_ID=e.PROTOCOL_ID , $ppty.extract_pool ep where ep.extract_id=e.extract_id and 
		ep.EXTRACT_pool_ID in (select EXTRACT_pool_ID from $ppty.labelled_extract where 
   LABELLED_extract_id=$lid)"
	);
	my @flag         = &SQLCHIPS::get_col( $reqProto, 0 );
	my @extract_name = &SQLCHIPS::get_col( $reqProto, 1 );
	my @qval         = &SQLCHIPS::get_col( $reqProto, 2 );
	my @qunit        = &SQLCHIPS::get_col( $reqProto, 3 );
	my @pfile        = &SQLCHIPS::get_col( $reqProto, 4 );
	undef $reqProto;
	if ( $flag[0] == 1 ) {    # il existe un pool d'extrait
		$val->{extract_protocol} = "Pool of extract, ";
	}
	my $j;
	for ( $j = 0 ; $j < scalar(@flag) ; $j++ ) {
		$val->{extract_protocol} .= "$extract_name[$j]: $qval[$j] $qunit[$j] - ";
	}
	$hyb->{extract_proto_file} = $pfile[0];
	return ( $val, $hyb );
}

# Permet de recuperer tous les champs neccessaires dans la table
# sample_source a partir d'un sample_source_id
sub recupSampleSource() {
	## Modifiee pour la nouvelle ontologie des mutants  ##
	my $ssId = shift;
	my $val  = shift;
	my $reqSample = &SQLCHIPS::do_sql(
		"select organism_id, ecotype_id, mutant, genotype, growth_conditions, sample_source_name,
		mutant_type, mutant_loci from $ppty.sample_source where sample_source_id=$ssId" );
  
	my $orga_id = $reqSample->{LINES}[0][0];
	my $eco_id  = $reqSample->{LINES}[0][1];
	$val->{organism} = &recupdbName( "organism", $orga_id );
	$val->{ecotype} = "";
	if ( $eco_id ne "" ) {
		$val->{ecotype} = &recupdbName( "ecotype", $eco_id );
		$val->{organism} .= " ($val->{ecotype})";
	}
	my $mutant     = $reqSample->{LINES}[0][2];
	my $muttype = $reqSample->{LINES}[0][6];
	my $mutloci = $reqSample->{LINES}[0][7];
	my $growthcond = $reqSample->{LINES}[0][4];
	$val->{sourceName} = $reqSample->{LINES}[0][5];
	$val->{genotype} = $reqSample->{LINES}[0][3];
	undef $reqSample;

	# pour le mutant
#	if ( $mutant eq "yes" && $genotype ne "" ) { $val->{mutant} = " - mutant: $genotype ($muttype)"; }
	if ($muttype eq "" ) { $muttype = "unknown"; }
	if ($mutloci eq "" ) { $mutloci = "unknown"; }
	if ( $mutant eq "yes" && $val->{genotype} ne "" ) { 
		$val->{mutant} = "name: $val->{genotype} - type: $muttype - refers to gene ID(s): $mutloci"; 
	}
	if ( $mutant eq "yes" && $val->{genotype} eq "" ) {
		print LOG
"\t --> ERREUR a corriger : pas de genotype alors que mutant pour le projet=$project, exp=$exp et sample_source_name=$val->{sourceName}";
	}
	if ( $mutant eq "no" ) { $val->{mutant} = "none"; }

	# pour traiter les growth conditions et characteristics
	if ( $val->{genotype} ne "" ) {$val->{genotype} = "- genotype: $val->{genotype}"}
	if ( $val->{ecotype} ne "" ) { $val->{ecotype} = "ecotype: $val->{ecotype}"; }
	else {
		$val->{ecotype} = "organism: $val->{organism}" ;
	}
	$val->{characteristics} = $val->{ecotype} . " " . $val->{genotype} . " " . $val->{age};
	$growthcond              = &clean($growthcond);
	$val->{growthcond} = $val->{tissue} . " - " . $growthcond;
	return ($val);
}

# Permet de recuperer tous les champs neccessaires dans la table
# sample a partir d'un extrait marque
sub recupSample() {
	my $extractpoolId = shift;
	my $p            = shift;    # j'ai garde project et exp pour etre sur d'aller
	                              # chercher le bon extrait et ne pas m'emmeler adns les
	                              # requetes imbriques
	my $e            = shift;
	my $val         = shift;
	my $platf		= shift;
	my $typanalyse = shift;

	my $reqSample = &SQLCHIPS::do_sql(
	"select distinct organ, dev_stage, AGE_VALUE,age_unit, to_char(HARVEST_DATE,'DD-MM-YY'), 
	HARVEST_PLANTNB, sample_source_id from $ppty.sample where sample_id in (select sample_id 
	from $ppty.sample_extract where EXTRACT_ID in (select EXTRACT_ID from $ppty.extract_pool 
	where extract_pool_id in (select EXTRACT_POOL_ID from $ppty.labelled_extract where 
	LABELLED_EXTRACT_ID=$extractpoolId and project_id=$p and experiment_id=$e)))");

	if ($reqSample->{NB_LINE} == 0  && ($platf eq 'Chromochip' && $typanalyse eq 'ChIP-chip')) {
		$reqSample = &SQLCHIPS::do_sql( 
		"select distinct organ, dev_stage, AGE_VALUE,age_unit, to_char(HARVEST_DATE,'DD-MM-YY'), 
		HARVEST_PLANTNB, sample_source_id from $ppty.sample where sample_id in (select sample_id 
		from $ppty.sample_extract where EXTRACT_ID in (select EXTRACT_ID from $ppty.extract_pool where 
		extract_pool_id in (select extract_pool_id from $ppty.ip where ip_id = (select EXTRACT_POOL_ID from 
		$ppty.labelled_extract where LABELLED_EXTRACT_ID=$extractpoolId and project_id=$p and 
		experiment_id=$e))))");
	}

	$val->{tissue} = $reqSample->{LINES}[0][0];
	my $devstage = $reqSample->{LINES}[0][1];
	$val->{age} = $reqSample->{LINES}[0][2] . " ".$reqSample->{LINES}[0][3];
	my $harvest = $reqSample->{LINES}[0][4];
	my $plantnb = $reqSample->{LINES}[0][5];
	my $source  = $reqSample->{LINES}[0][6];
	undef $reqSample;
	
	# pour l'age
	if ( $val->{age} ne "" ) { $val->{age} = " - age: " . $val->{age}; }
	if ( $devstage ne "" ) {
		$val->{age} = $val->{age} . " - dev.stage (Boyes <i>et al.</i> Plant Cell 2001): $devstage";
	}
	if ( $val->{age} eq "" ) { $val->{age} = " - harvest date: $harvest"; }
	
	# pour chromochip
	if ( $platf eq 'Chromochip'  && $typanalyse eq 'ChIP-chip' ) {
		# on recupere les infos IP de l'echantillon immuno-precipite 
		my $reqip = 	&SQLCHIPS::do_sql(
		"select antibody_name, antibody_ref, quantity_value, quantity_unit from $ppty.ip 
 		where  ip_flag=1 and ip_id in (select extract_pool_id from labelled_extract where 
 		labelled_extract_id = $extractpoolId and experiment_id = $e and project_id=$p)"
 		);
 		if ( $reqip->{NB_LINE} != 0 ) {
 			$val->{ip} =  "antibody: ".$reqip->{LINES}[0][0]." (".$reqip->{LINES}[0][1].") - DNA quantity:&nbsp;";
 			$val->{ip} .= $reqip->{LINES}[0][2]."&nbsp;".$reqip->{LINES}[0][3];
 		} else {
 			$val->{ip} = "-";
 		}
	}
	
	return ( $val, $source );
}

# Pour recuperer les donnees de treatment
#
sub recupTreatment() {
	my $extractpoolId = shift;
	my $val           = shift;
	my $reqTreatment  =	&SQLCHIPS::do_sql(
	"select TREATMENT_TYPE, TREATMENT_FACTOR, FACTOR_NAME, TREATMENT_CONDITION, 
	TIME_ELAPSED_VALUE, TIME_ELAPSED_UNIT, MEASURE_VALUE, MEASURE_UNIT, note, treatment_name 
	from $ppty.TREATMENT where Treatment_id in (select distinct TREATMENT_id from 
	$ppty.sample_treated where sample_id in (select sample_id from $ppty.sample_extract where 
	EXTRACT_ID in (select EXTRACT_ID from $ppty.extract_pool where extract_pool_id in (select 
	EXTRACT_POOL_ID from $ppty.labelled_extract where LABELLED_EXTRACT_ID=$extractpoolId))))"
		);
	my $pb             = 0;
	my $bilanTreatment = "";
	my $nbline = $reqTreatment->{NB_LINE};
	$val->{treatment} = "";

	if ( $nbline >= 1 ) {
		my @type       = &SQLCHIPS::get_col( $reqTreatment, 0 );
		my @typefactor = &SQLCHIPS::get_col( $reqTreatment, 1 );
		my @factor     = &SQLCHIPS::get_col( $reqTreatment, 2 );
		my @cond       = &SQLCHIPS::get_col( $reqTreatment, 3 );
		my @time       = &SQLCHIPS::get_col( $reqTreatment, 4 );
		my @timeunit   = &SQLCHIPS::get_col( $reqTreatment, 5 );
		my @mes        = &SQLCHIPS::get_col( $reqTreatment, 6 );
		my @mesunit    = &SQLCHIPS::get_col( $reqTreatment, 7 );
		my @note       = &SQLCHIPS::get_col( $reqTreatment, 8 );
		my @treatment_name = ( &SQLCHIPS::get_col( $reqTreatment, 9 ) )[0];
		my $j;

		for ( $j = 0 ; $j < $nbline ; $j++ ) {
			$bilanTreatment = "Name: $treatment_name[$j] - $type[$j] - $typefactor[$j]";
			$cond[$j]       = &clean( $cond[$j] );
			$note[$j]       = &clean( $note[$j] );
			if ( $factor[$j] ne "" ) { $bilanTreatment .= ": $factor[$j] "; }
			if ( $mes[$j]    ne "" ) { $bilanTreatment .= "quantity $mes[$j] $mesunit[$j] "; }
			if ( $time[$j]   ne "" ) { $bilanTreatment .= "time $time[$j] $timeunit[$j] "; }
			$val->{treatment} .= $bilanTreatment . ". $note[$j]";
		}
	} else {    # donc pas de traitement
		$val->{treatment} = "no treatment";
	}
	undef $reqTreatment;	
	return $val;
}

# recupere le type de molecule extraite
# et comparer avec leur liste
sub recupMoleculeType() {
	my $extractpoolId = shift;
	my $val           = shift;
	my %tabcorresp = ( "total RNA", "total RNA", "DNA",  "genomic DNA",
										 "mRNA",      "plyA RNA",  "aRNA", "other",
										 "cRNA",      "other",  "chromatin",  "other"
	);

	# a verifier pour cRNA et aRNA
	my $reqExtract = &SQLCHIPS::do_sql(
	"select molecule_type from $ppty.extract where extract_id in (select EXTRACT_ID from 
	$ppty.extract_pool where extract_pool_id in (select EXTRACT_POOL_ID from $ppty.labelled_extract 
	where LABELLED_EXTRACT_ID=$extractpoolId))"
	);
	if ($reqExtract->{NB_LINE} == 0) {
		$reqExtract = &SQLCHIPS::do_sql(
		"select molecule_type from $ppty.extract where extract_id in (select EXTRACT_ID from 
		$ppty.extract_pool where extract_pool_id in (select EXTRACT_POOL_ID from ip where ip_id =
		(select EXTRACT_POOL_ID from labelled_extract where LABELLED_EXTRACT_ID=$extractpoolId)))"
		);
	}

	my $moltype = $reqExtract->{LINES}[0][0];
	undef $reqExtract;
	$val->{molecule_type} = $tabcorresp{$moltype};
	return $val;
}

#-----------------------------------
# Pour les Protocoles:
# impression des protocols
sub printProtocol() {
	my ($p) = @_;
	$p = &printwebtable( "Extract protocol", &linkProto( @{ $protocol->{extract} } ) );
	$p .= &printwebtable( "Labelled protocol ",     &linkProto( @{ $protocol->{label} } ) );
	$p .= &printwebtable( "Hybridization protocol", &linkProto( @{ $protocol->{hybrid} } ) );
	$p .= &printwebtable( "Data processing",        $protocol->{data}[0] );
}

# pour faire un lien sur les protocols, sachant que ce sont des listes
# on affiche le contenu si fichier txt et 1 seul
sub linkProto() {
	my @list     = @_;
	my $drap     = 0;
	my $newproto = "";    # fichier TXT
	my $list     = "";    # liste des fichiers non TXT
	foreach my $l (@list) {
		if ( $drap == 0 && lc($l) =~ ".txt" ) {    # on peut le recuperer car fichier TXT
			$drap = 1;
			my $proto;
			open( pro, "$findproto$l" );
			while (<pro>) {
				$proto .= $_;
			}
			close(pro);
			$newproto = &clean($proto);
		} else {
			$list .= $w->a( { -href => "$CHIPS::FILELINK$l", -target => 'OtherPage' }, "$l  " );
		}
	}
	if ( $list ne "" ) {
		$newproto = $newproto . " $list";
	}
	return $newproto;
}

# verifie si nouveau protocol ou pas
# pour qu'il y en ai un seul par projet si toujours le meme
sub protocolFile() {
	my ( $pf, $type ) = @_;
	if ( $pf ne "" ) {    #  y a un fichier
		my $ok   = 0;
		my @list = @{ $protocol->{$type} };
		foreach my $l (@list) {
			if ( $l eq $pf ) { $ok = 1; last; }
		}
		if ( $ok == 0 ) {    # pas deja dans la liste on rajoute
			push( @{ $protocol->{$type} }, $pf );
		}
	}
}

# Pour recuperer dans une variable le contenu d'un fichier decrivant un protocol
sub recupProtocolFile() {
	my $f = shift;
	open( pro, $f ) || die "file $f does not exist ****** stop\n";
	my $proto;
	while (<pro>) {
		chomp($_);
		$proto .= $_;
	}
	close(pro);
	return ($proto);
}

#-----------------------------------
# Pour les Archives:
# pour faire l'archive tar des fichier de donnees brutes
sub archiveFiles() {
	my ( $p, $exid, $tarext, $reptar, $rep, @list ) = @_;
	$p =~ tr/ +/\_/;

	# pour le 1er on cree l'archive
	my $first = shift(@list);
	my $f     = sprintf( "%s_exp%s_%s", $p, $exid,  $tarext);
	my $tar   = $reptar . $f;                                   # ecrire l'archive au bon endroit

	# on verifie si l'archive du projet n'est pas deja presente
	# pas besoin de la recree
	# my $tar=$tar.".gz"; #si on zip
	if ( !-e $tar ) {
		system("cd $rep; tar cvf $tar $first");

		# ensuite on rajoute chaque fichier dans l'archive
		foreach my $fi (@list) {
			system("cd $rep; tar uvf $tar $fi");
		}

		#system("gzip -9 $tar"); # si on zip
	}
	return $f;
}

# ne genere pas l'archive, va juste donner les nom de l'archive a aller chercher
sub linkarchiveFiles() {
	my ( $p, $exid, $reptar ) = @_;

	# les blancs et () genent pour les archives
	$p =~ tr/ +/\_/;
	$p =~ s/\(//g;
	$p =~ s/\)//g;

	# pour le 1er on cree l'archive
	my $f = sprintf( "%s_exp%s_%s", $p, $exid,  $reptar);
	my $f = $f . ".gz";    # on a compresse
	return $f;
}

# pour download files
sub printDownload() {
	my $archfile = shift;
	my $p = &printwebtable( $w->a( { -name => "datatar" }, ' ' )."Archive of raw data files", $archfile );
}

#-----------------------------------
# Pour les Series:
sub printSeries() {
	my $projectId   = shift;
	my $nb          = shift;
	my $id          = shift;    # l'operateur de l'hybridation
	my $exp         = shift;
	my $exptype     = shift;
	my $desc        = shift;
	my $arraytype   = shift;
	my $factors     = shift;
	my $analysetype = shift;
	my $replid      = shift;
	my $reposit     = shift;
	my $p           = "";
	$p .= &printwebtable( "Experiment type",    $exptype );
	$p .= &printwebtable( "Experiment factors", $factors );
	$p .= &printwebtable( "Type of array",      "$analysetype type $arraytype" );

	# pour gerer les replicats biologiques
	my $plus = "";
	if ( $noswap != 0 ) {
		$plus = " and $noswap biological replicates";
	}

	# insertion de l'ancre du premier swap
	my $ovdesign = "Overall design" . $w->a( { -name => $replid }, ' ' );
	$p .= &printwebtable( $ovdesign, "$nb dye-swap (technical replicates)$plus" );

	# aller chercher les contacts
	my $reqContact = &SQLCHIPS::do_sql(
		"select FIRST_NAME, LAST_NAME from $ppty.contact c where c.contact_id in (select contact_id 
  from $ppty.project_coordinator p where p.project_id=$projectId) or c.contact_id=$id"
	);
	my @fname = &SQLCHIPS::get_col( $reqContact, 0 );
	my @lname = &SQLCHIPS::get_col( $reqContact, 1 );
	undef $reqContact;
	my $j;
	my $ok = 0;
	for ( $j = 0 ; $j < scalar(@fname) ; $j++ ) {
		$fname[$j] =~ s/ /-/g;
		$p .= &printwebtable( "Contributor", "$fname[$j],$lname[$j]" );
		if ( ( uc $lname[$j] ) eq "RENOU" ) {
			$ok = 1;
		}
	}
	if ( $ok == 0 && $analysetype ne 'ChIP-chip') {    # JP n'est pas ecrit donc on le rajoute
		$p .= &printwebtable( "Contributor", "Jean-Pierre,Renou" );
	}

	# et on rajoute systematiquement ML
	if ( $analysetype ne 'ChIP-chip' ) {
		$p .= &printwebtable( "Contributor", "Marie-Laure,Martin-Magniette" );
	}

	# description
	$p .= &printwebtable( "Experiment description", $desc );

	# repository
	$p .= &printwebtable( "Public repository", $reposit );
	return ($p);
}

#-----------------------------------
# les fonctions non utilisees
# Pour ecrire l'entete des colones de valeurs
sub printTableEntete() {
	my $v = shift;
	$v .= "#SPOT NAME = SPOT Name (alternative name)\n";
	$v .= "#SAMPLE CY5 = Normalized Intensities\n";
	$v .= "#SAMPLE CY3 = Normalized Intensities\n";
	$v .= "#Log Ratio = CY5/CY3\n";
	$v .= "#Pvalue= Bonferonni test\n";
	return $v;
}

# recuperation du tableau de valeurs
sub recupValues() {
	my $repId   = shift;
	my $arrayId = shift;
	my $v       = shift;
	my $partiel = shift;
	my %spotDiff;
	my %spotSeq;
	tie %spotSeq, "Tie::IxHash";    # pour garder l'ordre
	my $j;

	#  # pour limiter la sortie si necessaire
	#  # marche pas si on ne tre pas tout par spot_id
	#  my $reqResume="";
	#  if($partiel eq "1"){
	#    $reqResume=" and rownum <=5";
	#  }
	# la partie nom des sequences sans tri
	# avant la restriction on triait par nom de seq
	my $seqValues = &SQLCHIPS::do_sql(
		"select s.spot_id, ss.seq_name, ss.other_name from $ppty.SPOTTED_SEQUENCE ss, 
  $ppty.SPOT s where s.array_type_id=$arrayId and s.control_id in (0,2,3,6) and 
  ss.SPOTTED_SEQUENCE_ID=s.SPOTTED_SEQ_ID order by ss.seq_name"
	);
	if ( $seqValues->{NB_LINE} != 0 ) {
		for ( $j = 0 ; $j < $seqValues->{NB_LINE} ; $j++ ) {

			# penser a mettre un lien sur CATdb plus tard avec LINK_PRE:http://www.
			if (    $seqValues->{LINES}[$j][2] eq ""
					 || $seqValues->{LINES}[$j][2] eq $seqValues->{LINES}[$j][1] )
			{
				$spotSeq{ $seqValues->{LINES}[$j][0] } = $seqValues->{LINES}[$j][1];
			} else {
				$spotSeq{ $seqValues->{LINES}[$j][0] } =
					"$seqValues->{LINES}[$j][1] ($seqValues->{LINES}[$j][2])";
			}
		}
	}
	undef $seqValues;
	
	# la partie valeurs normalisees
	# on prend pas les valeurs normalisees car donnees par swap
	# et pas par hybridation donc on donne juste le flag
	my $seqDiffValues = &SQLCHIPS::do_sql(
		"select d.spot_id, d.I_REF , d.I_SAMPLE, d.LOG_RATIO, d.BONF_P_VALUE 
  from $ppty.DIFF_ANALYSIS_VALUE d where d.replicat_id=$repId" );
	if ( $seqDiffValues->{NB_LINE} != 0 ) {
		for ( $j = 0 ; $j < $seqDiffValues->{NB_LINE} ; $j++ ) {
			$spotDiff{ $seqDiffValues->{LINES}[$j][0] } =
"$seqDiffValues->{LINES}[$j][1]\t$seqDiffValues->{LINES}[$j][2]\t$seqDiffValues->{LINES}[$j][3]\t$seqDiffValues->{LINES}[$j][4]";
		}
	}
	undef $seqDiffValues;
	
	# impression
	my @spotId = keys(%spotSeq);
	my $j      = 1;
	foreach my $potId (@spotId) {

		# avec le nom de la sequence
		$v .= $spotSeq{$potId} . "\t" . $spotDiff{$potId} . "\n";

		# sans le nom de la sequences car deja dans platform
		$j++;
	}
	$j = $j - 1;
	return ($v);
}
