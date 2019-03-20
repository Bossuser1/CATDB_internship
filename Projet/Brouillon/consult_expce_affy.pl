#!/usr/local/bin/perl

# Pgm pour generer le bilan complet sur un projet et une experience AFFY
# base sur le meme principe que le fichier genere pour GEO
# mais avec une sortie HTML
# ==> remanie pour l'affichage correct des hybridations en HTML
# ==> et pas d'ecriture de LOG

#use Data::Dumper qw(Dumper);    #pour affichage debug
use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use Tie::IxHash;
use lib './';
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

my $imgdwd     = $CHIPS::DOWNLOAD;                 #download icon
my $PGPATH     = $CHIPS::PGPATH;
my $weburgv    = $CHIPS::WURGV;
my $home       = $CHIPS::CACCUEIL;
my $consproj   = $CHIPS::CPROJECT;
my $consdiff   = $CHIPS::CDIFF;
my $legend     = $CHIPS::DSLEGEND;
my $sysdate    = &CHIPS::sysdate();
my $finddata   = $CHIPS::FILEDATA . "/";           # repertoire des fichiers de donnees (grp ou cel)
my $linkdata   = $CHIPS::DATALINK . "/";
my $findproto  = $CHIPS::FILEUPLOAD . "/";
my $linkproto  = $CHIPS::FILELINK . "/";
my $linkArch   = $CHIPS::TARPATH;
my $linkdesign = $CHIPS::DESIGNLINK;
my $linkvignet = $CHIPS::DESIGNLINK . "vignette/";
my $lkftpgpr   = $CHIPS::GPRPATH;
my $lkftpresnorm = $CHIPS::XLSPATH;				# pour les fichiers resNorm publics
my $lkresnorm = $CHIPS::REPFILENORMAFFY;		# pour les fichiers resNorm prives

#navigateurs moz/msie:
my $datadecal = 102;
if ( ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) && ( int($1) < 7 ) ) {
	$datadecal = 0;
}

#VARIABLES
#~~~~~~~~~
# recup du numero d'experience
my $expId = param('experiment_id');

my ( $isnotpub );
my ( $i, $nbhyb ); 
my ( $thisproject, $printProj, $printSerie );
my ( $repos, $repos_db, $repos_ac, $lkrepos);
my ( $hybId );
my ( $affyId, $affyId_list, $array_name, $arrayTypeId, $affysourceId);
my ( $printSample, $printHybrid );  # var pour echantillons et valeurs et les hybridations
my ( $printTableSwap, $printSwap, $printSwapFile );  # partie series_repeat (pour indiquer les swap)
my ( $filetar, $filelink );
my ($dwnlibelle, $resNormfile, $resNormlnk);
my $printRep;

my $nbreplicat = 0;
my $nbsample =0;
my %replicat;
tie %replicat, "Tie::IxHash";
my $series = {};
tie%$series, "Tie::IxHash";
my $protocol = {};
	$protocol->{extract}  = [];    # tabeau des protocols car pls par projets pour un meme type
	$protocol->{label}    = [];
	$protocol->{'hybrid'} = [];


#REQUETE & TRAITEMENTS
#~~~~~~~~~~~~~~~~~~~~~
# verification si on trouve bien le projet et l'exp dans la base
my $req_project = &SQLCHIPS::do_sql(
	"SELECT e.experiment_name, p.project_id, p.project_name, p.title, p.biological_interest, 
	e.EXPERIMENT_TYPE, e.NOTE, p.is_public, e.array_type, e.experiment_factors, e.analysis_type, 
	e.repository_db, e.repository_access FROM $ppty.project p, $ppty.experiment e WHERE 
	p.project_id = e.project_id and e.experiment_id = $expId and p.is_public $public" 
);
my $exp          = $req_project->{LINES}[0][0];
my $projectId    = $req_project->{LINES}[0][1];
my $project      = $req_project->{LINES}[0][2];
my $title        	= $req_project->{LINES}[0][3];
my $bioInterest  = $req_project->{LINES}[0][4];
my $exptype      = $req_project->{LINES}[0][5];
my $description  = $req_project->{LINES}[0][6];
my $ispublic     = $req_project->{LINES}[0][7];
my $array        = $req_project->{LINES}[0][8];
my $expfactor    = $req_project->{LINES}[0][9];
my $analysistype = $req_project->{LINES}[0][10];
my $repos_db     = $req_project->{LINES}[0][11];
my $repos_ac     = $req_project->{LINES}[0][12];
undef $req_project;

# ID user
my $requser = &SQLCHIPS::do_sql(
	"Select distinct user_id from $ppty.hybridization where experiment_id=$expId"
);
my $userHybId = $requser->{LINES}[0][0];
undef $requser; 

if ( ( $ispublic ne 'yes' ||  $array ne "Affymetrix") && $ENV{'HOST'} =~ /urgv/ ) {    #(if 1)
	# message project non public (ou non Affymetrix)
	$isnotpub = $w->h2( { -align => 'center', -style => "color:red" },
											"**** SORRY, THIS PROJECT IS NOT AVAILABLE ****" );
} else {    #(else if 1)
	# Impression du projet 
	$thisproject = $w->a( { -href => $consproj . "?project_id=$projectId" }, $project );
	$printProj = &printProject( $thisproject, $exp, $bioInterest, $title );
	# Repository
	if ( $repos_db ne '' ) {
		my $reqrepos=&SQLCHIPS::do_sql("Select URL from $ppty.link_url where DATABASE='$repos_db'");
		($lkrepos) = $reqrepos->{LINES}[0][0];
		$repos = $w->a( { -href => "${lkrepos}$repos_ac", -target => '_blank' },
										"\n", $w->b($repos_db), " ...... accession # $repos_ac" );
		undef $reqrepos;				
	}
	
	# protocole stat pour Affy
	my $filedataprocessing = "The data were normalized with the GCRMA algorithm (Irizarry <i>et al</i>., 
												2003), available in the Bioconductor package (Gentleman and Carey, 2002).";
												
	# lien download vers le fichier resNorm
	$resNormfile = sprintf ("resNorm_%s_exp%d.txt.gz", $project, $expId);
	$dwnlibelle = "Download the normalized data for this experiment:";
	
	if ($ispublic ne 'yes') {
		$resNormlnk = sprintf ("%s%s", $lkresnorm, $resNormfile);			# lien prive
	} else {
		$resNormlnk = sprintf ("%s/%s", $lkftpresnorm, $resNormfile);		# lien public
	}
	
	$resNormlnk = $w->a( { -href => $resNormlnk }, 
									$w->img( { -src    => $imgdwd,
														 -height => 32,
														 -border => 0,
														 -alt    => 'download'
														}
									), "&nbsp;", $resNormfile
							 );

	# recup des hybridations de type 'r_affy' groupees par replicat (biologique)
	my $reqhyb = &SQLCHIPS::do_sql(
		"Select rh.replicat_id, rh.hybridization_id from $ppty.hybrid_replicats rh, $ppty.replicats r 
		where r.project_id=$projectId and experiment_id=$expId and rh.replicat_id=r.replicat_id 
		and r.rep_type='r_affy' order by rh.replicat_id, rh.hybridization_id"
	);
	$nbhyb = $reqhyb->{NB_LINE};
	# on regroupe les hybridations par replicat
	if ( $nbhyb != 0 ) {  							 #(if 3)	
		for ($i=0; $i<$nbhyb; $i++) {
			push @{$replicat{$reqhyb->{LINES}[$i][0]}}, $reqhyb->{LINES}[$i][1];
		}
		$nbsample = scalar (@{$replicat{$reqhyb->{LINES}[0][0]}}) -1;  # nb rep biologiques
		undef $reqhyb;
		$nbreplicat = scalar (keys %replicat);  # nb sample

		# Impression des SERIES (experience)
		$printSerie =
			&printSeries( $projectId, $nbreplicat, $userHybId, $exp, $exptype, $description, $array,
										$expfactor, $analysistype, $nbsample, $repos );

		# pour chaque replicat...
		while ( my ( $rep, $hybid ) = each(%replicat) ) {         #(while W1)
			my $hybrid_ref = $$hybid[0];           # premiere hybridation du replicat
			my $hybrid_list = join ",", @$hybid;   # liste des hybridations du replicat
			my $sampleBiotin = {};  # pour rassembler les donnees sur biotin (affy)
			my $hyb       = {};       	 # pour rassembler les donnees generales sur l'hybridation
			                       					 # dont on aura besoin au niveau des hybridations

			# on va chercher le nom du replicat pour l'hybridation de ref 
			my $reqSwap = &SQLCHIPS::do_sql(
				"Select r.REPLICAT_EXTRACTS from $ppty.replicats r, $ppty.HYBRID_REPLICATS hr where 
      		r.replicat_id=hr.replicat_id and hr.REPLICAT_ID=$rep and hr.hybridization_id=$hybrid_ref"
      	);
			$hyb->{Name} = $reqSwap->{LINES}[0][0];
			undef $reqSwap;
			
			# Aller chercher les donnees dans hybridation :
			# le code barre
			my $reqHyb = &SQLCHIPS::do_sql(
				"select HYBRIDIZATION_NAME, AFFY_EXTRACT_POOL_ID, ARRAY_TYPE_NAME from 
      		$ppty.HYBRIDIZATION where HYBRIDIZATION_ID in ($hybrid_list) order by HYBRIDIZATION_ID"
			);
			$hyb->{codebarre} = $reqHyb->{LINES}[0][0];
			$affyId           = $reqHyb->{LINES}[0][1];
			$affyId_list = join ",", &SQLCHIPS::get_col($reqHyb, 1);
			$array_name = $reqHyb->{LINES}[0][2];
			$arrayTypeId = &recupdbId( "ARRAY_TYPE", $array_name );
			undef $reqHyb;

			# on recupere les noms des Extraits marques
			my $reqLabel = &SQLCHIPS::do_sql(
				"Select labelled_extract_name from $ppty.labelled_extract where labelled_extract_id in ($affyId_list)"
			);
			$sampleBiotin->{Name} = join ", ", &SQLCHIPS::get_col($reqLabel, 0);
			$hyb->{TitleName} = $sampleBiotin->{Name};
			undef $reqLabel;

			# aller chercher les donnees protocol de scan et autre lies a l'hybridation
			$hyb = &recupScanFile( $hybrid_list, $hyb );
			$hyb = &recupHybProtocol( $sampleBiotin->{Name}, $hybrid_list, $hyb );
			&protocolFile( $hyb->{hybrid_proto_file}, "hybrid", $protocol );
#			push( @listFileName, $hyb->{data_file} );  ## inutile !
			$protocol->{'data'}[0] = $filedataprocessing;
			$hyb->{array_type}     = $array_name;
			$hyb->{array_type_id} = $arrayTypeId;
			$hyb->{replicat_id}      = $rep;

			# On va chercher le protocol des extraits et des labelling
			# treatment sur les fichiers de protocols
			( $sampleBiotin, $hyb ) = &recupExtractProtocol( $affyId_list, $sampleBiotin, $hyb );
			&protocolFile( $hyb->{extract_proto_file}, "extract", $protocol );
			( $sampleBiotin, $hyb ) = &recupLabelProtocol( $affyId_list, $sampleBiotin, $hyb );
			&protocolFile( $hyb->{label_proto_file}, "label", $protocol );

			# on va chercher ce qu'il nous faut dans la table sample ($affysourceId= sample_source_id)
			( $sampleBiotin, $affysourceId ) = &recupSample( $affyId, $projectId, $expId, $sampleBiotin );
			# on va chercher ce qu'il nous faut dans la table sample_source 
			$sampleBiotin = &recupSampleSource( $affysourceId, $sampleBiotin );
			# on va chercher les traitements si y en a 
			$sampleBiotin = &recupTreatment( $affyId, $sampleBiotin );
			# on va chercher pour la molecule a extraires
			$sampleBiotin = &recupMoleculeType( $affyId, $sampleBiotin );

			# impression 1ere lame
			$printSample = &printofhybEntete( $printSample, $hyb, "Sample" );
			$printSample = &printofhybSample( $printSample, "1", $sampleBiotin, "Biotin" );
			$printHybrid = &printofhybEnd( $printHybrid, $hyb );
			
			# pour affichage des Samples
			$printSwap = &printwebtitle( "Sample: " . $w->font( { -color => '#FFFF00' }, $hyb->{Name} ) );
			$printSwap .=
				$w->table( { -class => "info", -width => '80%', -align => 'center' }, $printSample );
			$printSwapFile = $w->table({	-class => "info",
																		-width => '80%',
																		-align => 'center',
																		-style => "border-top:0px"
																	},
																	$printHybrid
											 );
			$printSample = '';
			$printHybrid = '';
			$printTableSwap .= $printSwap . $printSwapFile . "\n"; 
	} #(fin while W1)	

		# recup des Series de normalisation
		$series = &recupSeries ($projectId, $expId, $series);
		
		while ( my ( $k, $v ) = each(%$series) ) {
			$printRep .= &printwebtable( "$k", join ", ",@$v );
		}
		$printRep =	$w->table( { -class => "info", -width => '80%', -align => 'center' }, $printRep ), "\n";
		$printRep = &printwebtitle("Normalized data series") . $printRep;
		
		# fichier tar des GPR ou CEL public/prive .... voir dans quel repertoire 
		$filetar  = &linkarchiveFiles( $project, $expId, $linkArch );
		$filelink = &linkFile( $filetar, $lkftpgpr, "_self" );

	} else {   #(else if 3)
		$isnotpub = $w->h2( { -align => 'center', -style => "color:red" },
												"**** SORRY,  NO DATA AVAILABLE FOR THIS EXPERIMENT ****" );
	} #(fin if 3)	

} #(fin if 1)


#HTML
#~~~~
print $w->header();
my $JSCRIPT = <<END;
function PopupImage(img, legend, proj, exp) {
  titre = proj+" :: "+exp;
  tableau = "<TABLE width='100%' border=0 cellspacing=5><tr><td><IMG src='"+img+"' border=0 alt='Experimental design'></td><td width='25%'><IMG src='"+legend+"' border=1 style='background:#EFEFEF; border-color:#000070' alt='Legends'></td></tr></table>";

  w=open("",'image','width=400,height=400,location=no,toolbar=no,scrollbars=no,resizable=yes,menubar=no');	
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
print $w->start_html(	-title  => 'CATdb '.ucfirst($array).' Experiment info',
											-author => 'bioinfo@evry.inra.fr',
											-meta   => { 'keywords' => 'CATdb', 'robots' => 'noindex,nofollow' },
											-style   => { -src => $stylepath },
											-BGCOLOR => "#FFFFFF",
											-script  => $JSCRIPT
			);

if ( $isnotpub ne '' ) {				#(if 9)
	print $w->div( { -class => "entete" }, "\n", 
					&printLogo( $weburgv, $home ), "\n", 
					$w->br, "\n", $isnotpub );
					
} else {			#(else if 9)
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
								# tableau du download des data normalisees
								$w->table( { -width => '100%', -border => 0 },
									$w->Tr( $w->td( {-nowrap}, $dwnlibelle ) ), "\n",
									$w->Tr( $w->td($resNormlnk))
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
					&printwebtitle("Download raw data (*.CEL files) of this project"),
					$w->table( { -class => "info", -width => '80%', -align => 'center' },
										&printDownload($filelink)
					), "\n",
					
					# bouton back
					$w->br, "\n",
					$w->div( { -class => "pied", -align => "center" },
						$w->button( -name    => 'buttonSubmitRetour',
											  -value   => 'BACK',
												-onClick => "retour(this.form);"
						)
					),"\n"					
				), "\n";    #fin div corpus
				
} #(fin if 9)

print $w->end_html;


###################### FUNCTIONS ######################
# nettoie les chaines de caracteres
sub clean() {
	my $var = shift;
	$var =~ s/\n/ /g;    # pas de retour a la ligne
	$var =~ s/\r/ /g;
	$var =~ s/ +/ /g;
	return $var;
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
	undef $req;
	return ($id);
}

# recuperer a partir d'un identifiant le champs Name correspondant dans une table
sub recupdbName() {
	my $table        = shift;
	my $valId        = shift;
	my $attributName = $table . "_name";
	my $attributId   = $table . "_id";
	my $req = &SQLCHIPS::do_sql("select $attributName from $ppty.$table where $attributId=$valId");
	my $name = $req->{LINES}[0][0];
	undef $req;
	return ($name);
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
																			$w->img( { -src=> $urgvsmal, -height => "75", -border=>0, -alt=>"IPS2"}
																			)
															 )
											),
											$w->div( { -class => "titre" },
															 $w->a( { -href => $catdb },
																			$w->img( { -src=> $catdblogo, -border=>0, -alt=>"CATdb"}
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
	my $new = $w->div( { -align=>'center', -style=>'font-weight:bold; font-size:11pt; Color:#336699'},
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
	$pr .= &printwebtable( "Project name ", $proj, "nowrap" );
	if ( $title ne "" ) {
		$pr .= &printwebtable( "Project title", $title );
	}
	$pr .= &printwebtable( "Biological interest", $bio );    # on met ca pour sample_description mais
	                                                    									# en fait on a rien d'autre a ajouter
	$pr .= &printwebtable( "Experiment name", $ex );
	return ($pr);
}

#-----------------------------------
# Pour les Series (experiences):   						**Modifiee pour AFFY**
sub printSeries() {
	my $projectId = shift;
	my $nb         = shift;
	my $id          = shift;    # l'operateur de l'hybridation
	my $exp         = shift;
	my $exptype  = shift;
	my $desc       = shift;
	my $arraytype = shift;
	my $factors    = shift;
	my $analysetype = shift;
	my $replid      = shift;  	# nb de replicats biologiques
	my $reposit    = shift;
	my $p           = "";
	$p .= &printwebtable( "Experiment type",    $exptype );
	$p .= &printwebtable( "Experiment factors", $factors );
	$p .= &printwebtable( "Type of array", "$analysetype type $arraytype" );

	# pour gerer les replicats biologiques
	my $plus = "";
	if ( $replid != 0 ) {
		$plus = "with $replid biological replicate(s)";   ## Modif pour Affy ##
	}

	# insertion de l'ancre du premier swap     ## Supprime pour Affy ##
#	my $ovdesign = "Overall design" . $w->a( { -name => $replid }, ' ' );
	$p .= &printwebtable( "Overall design", "$nb sample(s) $plus" );

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
		if ( ( uc $lname[$j] ) eq "BALZERGUE" ) {
			$ok = 1;
		}
	}
	if ( $ok == 0 ) {    # si SB n'est pas ecrit alors on la rajoute
		$p .= &printwebtable( "Contributor", "Sandrine,Balzergue" );
	}

	# et on rajoute systematiquement MLM
	$p .= &printwebtable( "Contributor", "Marie-Laure,Martin-Magniette" );

	# description
	$p .= &printwebtable( "Experiment description", $desc );

	# repository
	$p .= &printwebtable( "Public repository", $reposit );
	return ($p);
}

#-----------------------------------
# Normalisation de l'affichage:
# pour toutes les ecritures web des titres
sub printwebtitle() {
	my $t   = shift;
	my $new =
		  $w->div( { -class => 'banner' }, $w->br, $w->div( { -class => 'bannertext' }, "$t" ) )
		. $w->br;
	return ($new);
}

# pour toutes les ecritures web des tables
sub printwebtable() {
	my ( $title, $val, $nowrp ) = @_;
	my $grisF = "#BBBBBB";
	my $new = $w->Tr(
										$w->td( { -bgcolor => "$grisF", -style => "color:white;", $nowrp }, $w->b($title) ),
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
		$newf = $w->a( { -href => "$link/$f", -target => "$target" }, " $f " );
	}
	return $newf;
}

#-----------------------------------
# Pour les Hybridations:
# Recuperer les parametres de l'hybridation   **Modifiee pour AFFY**
sub recupHybProtocol() {
	## Modifiee pour AFFY ##
	my ( $cy3, $hid, $val ) = @_;
	my @name = split(", ", $cy3);  

	my $reqProto = &SQLCHIPS::do_sql(
	"select h.QUANTITY_VALUE, h.QUANTITY_UNIT, p.PROTOCOL_file from $ppty.hybridization h LEFT 
   OUTER JOIN $ppty.protocol p ON p.PROTOCOL_ID=h.PROTOCOL_ID where hybridization_id in ($hid)"
	);
	my @qval = &SQLCHIPS::get_col($reqProto, 0);  
	my @qunit = &SQLCHIPS::get_col($reqProto, 1); 
	$val->{hybrid_proto_file} = $reqProto->{LINES}[0][2];
	undef $reqProto;

	for (my $i=0; $i<scalar @name; $i++) {
		$name[$i] = "biotinylated $name[$i] : ${qval[$i]}${qunit[$i]}";
	}
	$val->{hyb_protocol} = join ", ", @name;
	return $val;
}

# recuperation des fichiers lies au scan     **Modifiee pour AFFY**
sub recupScanFile() {
	my $h        = shift;
	my $v        = shift;

	my $reqfiles = &SQLCHIPS::do_sql(
"select DATA_FILE_name, IMAGE_FILE_NAME from $ppty.IMAGE_DATA_FILE where IMAGE_DATA_FILE_ID 
in (select IMAGE_DATA_FILE_ID from $ppty.HYBRID_IMAGEDATA where hybridization_id in ($h))"
	);
	$v->{'data_file'}  = join ", ", &SQLCHIPS::get_col($reqfiles, 0);  
	$v->{'image_file'} =join ", ", &SQLCHIPS::get_col($reqfiles, 1);  
	undef $reqfiles;
	return $v;
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

# Recuperer les parametres du protocol d'extraction     **Modifiee pour AFFY**
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
		LABELLED_extract_id in ($lid) )"
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
		$val->{extract_protocol} .= "$extract_name[$j]: $qval[$j]$qunit[$j] - ";
	}
	$hyb->{extract_proto_file} = $pfile[0];
	return ( $val, $hyb );
}

# Recuperer les parametres du labelling protocol    **Modifiee pour AFFY**
sub recupLabelProtocol() {
	my $lid = shift;    # pour le LabelledextractId
	my $val = shift;    # par extrait
	my $hyb = shift;    # par hybridation (deatil du protocol avec le fichier associe)
	
	my $reqProto = &SQLCHIPS::do_sql(
		"select LABELLING_TYPE, LABEL_NAME, MOLECULE_TYPE, AMPLIFICATION, QUANTITY_VALUE, 
		QUANTITY_UNIT , p.protocol_file from $ppty.LABELLED_PROTOCOL lp LEFT OUTER JOIN 
		$ppty.protocol p ON p.PROTOCOL_ID=lp.PROTOCOL_ID where lp.LABELLED_PROTOCOL_ID in 
  		(select LABELLED_PROTOCOL_ID from $ppty.labelled_extract where LABELLED_extract_id in ($lid) )"
	);
#	my $nb      = $reqProto->{NB_COL} - 1;
	my $labtype = $reqProto->{LINES}[0][0];
	my $lab     = $reqProto->{LINES}[0][1];
	my $moltype = $reqProto->{LINES}[0][2];
	my $ampli   = $reqProto->{LINES}[0][3];
	my $qval    = $reqProto->{LINES}[0][4];
	my $qunit   = $reqProto->{LINES}[0][5];
	my $pfile   = $reqProto->{LINES}[0][6];
	undef $reqProto;
	$val->{label_protocol} =
		"labelling $lab $labtype, amplificate=$ampli, $moltype ${qval}$qunit";
	$hyb->{label_proto_file} = $pfile;
	return ( $val, $hyb );
}

# Permet de recuperer tous les champs neccessaires dans la table
# sample a partir d'un extrait marque
sub recupSample() {
	my $extractpoolId = shift;
	my $p             = shift;    # j'ai garde project et exp pour etre sur d'aller
	                              # chercher le bon extrait et ne pas m'emmeler adns les
	                              # requetes imbriques
	my $e             = shift;
	my $val           = shift;
	my $reqSample     = &SQLCHIPS::do_sql(
	"select distinct organ, dev_stage, AGE_VALUE,age_unit, to_char(HARVEST_DATE,'DD-MM-YY'), 
	HARVEST_PLANTNB, sample_source_id from $ppty.sample where sample_id in (select sample_id 
	from $ppty.sample_extract where EXTRACT_ID in (select EXTRACT_ID from $ppty.extract_pool 
	where extract_pool_id in (select EXTRACT_POOL_ID from $ppty.labelled_extract where 
	LABELLED_EXTRACT_ID = $extractpoolId and project_id=$p and experiment_id=$e)))"
		);
	$val->{tissue} = $reqSample->{LINES}[0][0];
	my $devstage = $reqSample->{LINES}[0][1];
	$val->{age} = $reqSample->{LINES}[0][2] . $reqSample->{LINES}[0][3];
	my $harvest = $reqSample->{LINES}[0][4];
	my $plantnb = $reqSample->{LINES}[0][5];
	my $source  = $reqSample->{LINES}[0][6];
	# recup de la planting_date pour l'age
	$reqSample = &SQLCHIPS::do_sql( 
		"Select to_char(planting_date,'DD-MM-YY') from $ppty.sample_source where sample_source_id=$source"
		 );
	my $planting = $reqSample->{LINES}[0][0];
	undef $reqSample;
	
	# pour l'age
	if ( $val->{age} ne "" ) { $val->{age} = " - age: " . $val->{age}; }
	if ( $devstage ne "" ) {
		$val->{age} = $val->{age} . " - dev. stage: $devstage";
	}
	if ( $val->{age} eq "" ) { $val->{age} = " - planting date: $planting, harvest date: $harvest"; }
	return ( $val, $source );
}

# Permet de recuperer tous les champs neccessaires dans la table
# sample_source a partir d'un sample_source_id  (LOG desactivee)  **Modifiee pour Age**
sub recupSampleSource() {
	## Modifiee pour la nouvelle ontologie des mutants  ##
	my $ssId = shift;
	my $val  = shift;
	my $reqSample = &SQLCHIPS::do_sql(
		"select organism_id, ecotype_id, mutant, genotype, growth_conditions, sample_source_name, 
		mutant_type, mutant_loci from $ppty.sample_source where sample_source_id=$ssId"
	);
	my $orga_id = $reqSample->{LINES}[0][0];
	my $eco_id  = $reqSample->{LINES}[0][1];
	$val->{organism} = &recupdbName( "organism", $orga_id );
	$val->{ecotype} = "";
	if ( $eco_id ne "" ) {
		$val->{ecotype} = &recupdbName( "ecotype", $eco_id );
	}
	my $mutant     = $reqSample->{LINES}[0][2];
	my $genotype   = $reqSample->{LINES}[0][3];
	$val->{genotype} = $reqSample->{LINES}[0][3];
	my $growthcond = $reqSample->{LINES}[0][4];
	$val->{sourceName} = $reqSample->{LINES}[0][5];
	my $muttype = $reqSample->{LINES}[0][6];
	my $mutloci = $reqSample->{LINES}[0][7];
	undef $reqSample;

	# pour le mutant
	if ($muttype eq "" ) { $muttype = "unknown"; }
	if ($mutloci eq "" ) { $mutloci = "unknown"; }
	if ( $mutant eq "yes" && $val->{genotype} ne "" ) { 
		$val->{mutant} = "name: $val->{genotype} - type: $muttype - refers to gene ID(s): $mutloci"; 
	}
#	if ( $mutant eq "yes" && $genotype ne "" ) { $val->{mutant} = " ; mutant: $genotype ($muttype)"; }
#	if ( $mutant eq "yes" && $genotype eq "" ) {
#		print LOG
#				"\t --> ERREUR a corriger  : pas de genotype alors que mutant pour le projet=$project et 
#				exp=$exp et sample_source_name=$val->{sourceName}";
#	}
	if ( $mutant eq "no" ) { $val->{mutant} = "none"; }

	# pour traiter les growth conditions et characteristics
	if ( $val->{genotype} ne "" ) {$val->{genotype} = "- genotype: $val->{genotype}"}
	if ( $val->{ecotype} ne "" ) { $val->{ecotype} = "ecotype: $val->{ecotype}"; }
	else {
		$val->{ecotype} = "organism: $val->{organism}" ;
	}
	$val->{characteristics} = $val->{ecotype} . " " . $val->{genotype} . " " . $val->{age};
	$growthcond             		= &clean($growthcond);
	$val->{growthcond}     = $val->{tissue} . " - " . $growthcond;
	return ($val);
}

# Pour recuperer les donnees de treatment
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
			$bilanTreatment = "Name:$treatment_name[$j] - $type[$j] - $typefactor[$j]";
			$cond[$j]       = &clean( $cond[$j] );
			$note[$j]       = &clean( $note[$j] );
			if ( $factor[$j] ne "" ) { $bilanTreatment .= ": $factor[$j] "; }
			if ( $mes[$j]    ne "" ) { $bilanTreatment .= "quantity $mes[$j]$mesunit[$j] "; }
			if ( $time[$j]   ne "" ) { $bilanTreatment .= "time $time[$j]$timeunit[$j] "; }
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
										 "mRNA",      "polyA RNA",  "aRNA", "other",
										 "cRNA",      "other"	);

	# a verifier pour cRNA et aRNA
	my $reqExtract = &SQLCHIPS::do_sql(
	"select molecule_type from $ppty.extract where extract_id in (select EXTRACT_ID from 
	$ppty.extract_pool where extract_pool_id in (select EXTRACT_POOL_ID from $ppty.labelled_extract 
	where LABELLED_EXTRACT_ID=$extractpoolId))"
		);
	my $moltype = $reqExtract->{LINES}[0][0];
	undef $reqExtract;
	$val->{molecule_type} = $tabcorresp{$moltype};
	return $val;
}

# entete des hybridationspour AFFY
sub printofhybEntete() {
	my $p      = shift;
	my $hybrid = shift;
	my $lab = shift;
	$p .= &printwebtable( "$lab name", $w->b( $hybrid->{Name} ) );
	$p .= &printwebtable(	"Array type",
							$w->a( { -href => "./consult_project.pl?array_type_id=$hybrid->{array_type_id}" },
										$hybrid->{array_type}
							)
				);
}

# par channel   							**Modifiee pour ajouter AFFY**
sub printofhybSample() {
	## Modifiee pour AFFY ##
	my $p        = shift; 
	my $ch       = shift;	
	my $sample   = shift;	
	my $name     = shift;
#	my $replid   = shift;			#pour l'ancre
	my $libcolor = "white";
	my $grwpro   = "growth protocol";

	# on va mettre le channel au nom
	if ( $name eq "Cy5" ) {
		$name = $w->font( { -color => 'red', -style => 'font-weight: bold;' }, $name );
		$libcolor = "red";
	} elsif ( $name eq "Cy3" ) {
		$name = $w->font( { -color => 'green', -style => 'font-weight: bold;' }, $name );
		$libcolor = "green";
#		if ( $replid ne '' ) { $grwpro .= $w->a( { -name => $replid }, ' ' ); }
	} elsif ( $name eq "Biotin" ) {   # pour AFFY
		$name = $w->font( { -color => '#FF4400', -style => 'font-weight: bold;' }, $name );
		$libcolor = "#FF4400";
	}
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "Channel" ), $name );
	$p .=
		&printwebtable( $w->font( { -color => "$libcolor" }, "Biol. replicate names" ), $sample->{Name} );
	$p .=
		&printwebtable( $w->font( { -color => "$libcolor" }, "organism" ), $sample->{organism} );
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "organ" ), $sample->{tissue} );
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "characteristics" ),
												$sample->{characteristics} );
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "mutation" ), $sample->{mutant} );												
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "treatment protocol" ),
												$sample->{treatment} );
	$p .=
		&printwebtable( $w->font( { -color => "$libcolor" }, "$grwpro" ), $sample->{growthcond} );
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "molecule type" ),
												$sample->{molecule_type} );
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "extract protocol" ),
												$sample->{extract_protocol} );
	$p .= &printwebtable( $w->font( { -color => "$libcolor" }, "labelling protocol" ),
												$sample->{label_protocol} );
}

# fin entete hybridation 			**Modifiee pour ajouter AFFY**
sub printofhybEnd() {
	my $p      = shift;
	my $hybrid = shift;

	$p .= &printwebtable( "Data file", $hybrid->{data_file} );
}

# recuperer les series d'experiences normalisees ensemble  	**creee pour AFFY**
sub recupSeries () {
	my $pid = shift;
	my $exid = shift;	
	my $val = shift;
	
	my $reqserie = &SQLCHIPS::do_sql(
		"Select r.replicat_extracts, (select labelled_extract_name from $ppty.labelled_extract, 
		$ppty.hybridization where hybridization_id=hr.hybridization_id and affy_extract_pool_id = 
		labelled_extract_id) as name from $ppty.hybrid_replicats hr, $ppty.replicats r where 
		hr.replicat_id=r.replicat_id and r.project_id=$pid and r.experiment_id=$exid and 
		r.rep_type='s_affy' order by name"
	);
	if ( $reqserie->{NB_LINE} != 0 ) { 
		for ($i=0; $i<$reqserie->{NB_LINE}; $i++) {
			push @{$val->{$reqserie->{LINES}[$i][0]}}, $reqserie->{LINES}[$i][1];
		}
	}
	undef $reqserie;	
	return $val;
}

#-----------------------------------
# Pour les Archives:
# ne genere pas l'archive, va juste donner les nom de l'archive a aller chercher
sub linkarchiveFiles() {
	my ( $p, $exid, $reptar ) = @_;

	# les blancs et () genent pour les archives
	$p =~ tr/ +/\_/;
	$p =~ s/\(//g;
	$p =~ s/\)//g;

	# pour le 1er on cree l'archive
	my $f = sprintf( "%s_exp%s_data.tar", lc($p), $exid );
	my $f = $f . ".gz";    # on a compresse	
	return $f;
}

# pour download files
sub printDownload() {
	my $archfile = shift;
	my $p = &printwebtable( "Archive of raw data files", $archfile );
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
			open( pro, "<".$findproto.$l );
			while (<pro>) {
				$proto .= $_;
			}
			close(pro);
			$newproto = &clean($proto);
		} else {
			$list .= $w->a( { -href => "$CHIPS::FILELINK/$l", -target => 'OtherPage' }, "$l  " );
		}
	}
	if ( $list ne "" ) {
		$newproto = $newproto . " $list";
	}
	return $newproto;
}





