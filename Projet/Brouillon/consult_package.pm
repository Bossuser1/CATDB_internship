package consult_package;

use Carp;
use File::Basename;
use Tie::IxHash;
use MIME::Lite;
use lib './'; 
use SQLCHIPS;
use CHIPS;

#________________________________________________________________________
# Path & Liens
my $w2   = $CHIPS::CONSULTPATH2;
my $w1   = $CHIPS::CONSULTPATH;
my $w3   = $CHIPS::HTDOCPATH;
my $ppty = $CHIPS::DBname;

my $lkexpce    = $CHIPS::CEXPCE;
my $legend     = $CHIPS::DSLEGEND;
my $linkdesign = $CHIPS::DESIGNLINK;
my $lkinfo     = $CHIPS::SEQINF;
my $lksdiff    = $CHIPS::CDIFF;

# Images
my $bulupdw   = $CHIPS::BULUPDW;       #fleche de tri
my $ongauche  = $CHIPS::GAUCHE_ON;     #fleche gauche bleue
my $offgauche = $CHIPS::GAUCHE_OFF;    #fleche gauche grise
my $ondroite  = $CHIPS::DROITE_ON;     #fleche droite bleue
my $offdroite = $CHIPS::DROITE_OFF;    #fleche droite grise

# Couleurs (pour tableaux)
$BLANC = "#FFFFFF";  #blanc
$GRISC = "#EEEEEE";  #gris clair
$GRISM = "#DDDDDD";  #gris moyen
$GRISF = "#BBBBBB";  #gris fonce
$GRISS = "#555555";  #gris fort
$VERT  = "#009900";  #vert
$ROUGE = "#990000";  #rouge

# lien PubMed
my $lkpubmed = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=";

#_________________________________________________________________________
use strict;
use CGI qw/:standard/;
my $x = new CGI;

# seuil de p-value
my $pval_ctf = $CHIPS::PVALMAX;

# pour aller chercher que les projects publics
my $varReqpublic = sprintf (" is_public %s", $CHIPS::PUBLIC);
   # pour l'instant on regarde juste ca mais
   # apres on prendra une date comme reference

#_______________________________________________________________________________________
# Project
#_______________________________________________________________________________________
sub recupdbName () {
	my $table        = shift;
	my $valId        = shift;
	my $attributName = $table . "_name";
	my $attributId   = $table . "_id";

	my $req =	&SQLCHIPS::do_sql(
	"select $attributName from $ppty.$table where $attributId=$valId");

	my $name = ( &SQLCHIPS::get_col( $req, 0 ) )[0];

	return ($name);
}

sub consult_project {

	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#VARIABLES:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	my $project_id = shift;
	my @project_name;
	my @title;
	my @source;
	my @project_code;
	my @biological_interest;
	my @user_id;
	my @submission_date;
	my ( @First_name, @first_name_id );
	my ( @Last_name,  @last_name_id );
	my @phone;
	my @email;
	my @institution;
	my @laboratory;
	my @address;
	my @biblio;

	my (
		$variable_compteur, $variable1, $variable2, $variable3,
		$variable4,         $variable5, $variable6, $variable7,
		$variable8,         $variable9, $variable10, $variable11
	);
	my ( $ens1, $ens2, $ens3, $ens4 );

	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#REQUETES:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	my $req =	&SQLCHIPS::do_sql("select project_name, title, source, biological_interest from 
	$ppty.project where project_id=$project_id and $varReqpublic ");

	if ( $req->{NB_LINE} != 0 ) {
		@project_name        = &SQLCHIPS::get_col( $req, 0 );
		@title               = &SQLCHIPS::get_col( $req, 1 );
		@source              = &SQLCHIPS::get_col( $req, 2 );
		@biological_interest = &SQLCHIPS::get_col( $req, 3 );
	}

	my $req =	&SQLCHIPS::do_sql("select last_name, first_name, phone, email, institution,
	laboratory, address from $ppty.contact,$ppty.project_coordinator,$ppty.project where 
	contact.contact_id=project_coordinator.contact_id and project_coordinator.project_id=
	project.project_id and project.project_id=$project_id and $varReqpublic");

	if ( $req->{NB_LINE} != 0 ) {
		@Last_name   = &SQLCHIPS::get_col( $req, 0 );
		@First_name  = &SQLCHIPS::get_col( $req, 1 );
		@phone       = &SQLCHIPS::get_col( $req, 2 );
		@email       = &SQLCHIPS::get_col( $req, 3 );
		@institution = &SQLCHIPS::get_col( $req, 4 );
		@laboratory  = &SQLCHIPS::get_col( $req, 5 );
		@address     = &SQLCHIPS::get_col( $req, 6 );
	}
	
	# articles biblio associes
	my	$req = &SQLCHIPS::do_sql("Select b.pubmed_id from $ppty.project_biblio b, $ppty.project p 
	where b.project_id = p.project_id and p.project_id in ($project_id)");							
	@biblio = &SQLCHIPS::get_col($req,0);
	undef $req;

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#INSTRUCTIONS
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#Project identification:
	#~~~~~~~~~~~~~~~~~~~~~~
	$variable1 = $x->body( "Project name: $project_name[0]", $x->br );
	if ( $title[0] ne '' ) {
		$variable2 = $x->body( "Title: $title[0]", $x->br );
	}
	$variable3 = $x->body( "Biological question: $biological_interest[0]", $x->br );

	$ens2 = ("$variable1$variable2$variable3");

	#Source:
	#~~~~~~~~~~
	$variable4 = $x->body( "Source : $source[0]", $x->br );

	#Project coordinator(s):
	#~~~~~~~~~~~~~~~~~~~~~~~
	my @tab;
	my $i = 0;
	do {
		$variable5  = undef;
		$variable6  = undef;
		$variable7  = undef;
		$variable8  = undef;
		$variable9  = undef;
		$variable10 = undef;

		$variable_compteur = $x->h4( $x->u("Coordinator") );
		$variable5 =
			$x->body( "Last_name: $Last_name[$i]", $x->br, "First_name: $First_name[$i]", $x->br );
		if ( $institution[$i] ne '' ) {
			$variable6 = $x->body( "Institution: $institution[$i]", $x->br );
		}
		$variable7 = $x->body( "Laboratory: $laboratory[$i]", $x->br );
		if ( $phone[$i] ne '' ) {
			$variable8 = $x->body( "Phone: $phone[$i]\n", $x->br );
		}
		if ( $email[$i] ne '' ) {
			$variable9 = $x->body( "Email: $email[$i]\n", $x->br );
		}
		if ( $address[$i] ne '' ) {
			$variable10 = $x->body( "Address: $address[$i]\n", $x->br );
		}
		$ens3 =
			("$variable_compteur$variable5$variable6$variable7$variable8$variable9$variable10");
		push( @tab, $ens3 );
		$i++;
	} while ( $Last_name[$i] );
	
	if (scalar (@biblio) > 0) {
		foreach (@biblio) {
			$variable11 .= $x->a({-href=>$lkpubmed.$_, -target=>'_blank'}, $x->i("&nbsp;$_")," ");		
		} 
		$variable11 = ("Pubmed accession # $variable11");
	} else {
		$variable11 = '';
	}
	

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#AFFICHAGE
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	print $x->div(
		{ -class => 'banner' },
		$x->br,
		$x->div(
			{ -class => 'bannertext' },
			"Project: ", $x->font( { -color => 'yellow' }, $project_name[0] )
			)
		),
		$x->br;

	if ($variable11 ne '') {
		$ens4 = $x->th( { -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;BIBLIOGRAPHY" )
						. $x->td( { -align => 'left' }, $variable11 )
						),
	}

	print $x->table(
		{ -class => "info", -width => '90%', -align => 'center' },

		# caption($x->h3({-style=>'Color:#0000CC'},$x->br("Project $project_name[0]"))),
		$x->Tr(
			{ -align => 'left' },
			[
				$x->th(
					{ -BGCOLOR => "#C0C0C0", -width => '30%' },
					$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;PROJECT IDENTIFICATION" )
						. $x->td( { -align => 'left' }, $ens2 )
				),
				$x->th(
					{ -BGCOLOR => "#C0C0C0", -width => '30%' },
					$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;SOURCE" )
						. $x->td( { -align => 'left' }, $variable4 )
				),
				$x->th(
					{ -BGCOLOR => "#C0C0C0", -width => '30%' },
					$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;PROJECT COORDINATOR(S)" )
						. $x->td( { -align => 'left' }, @tab )
				),
				$ens4,
			]
		)
	);

}

#_______________________________________________________________________________________
# Experiment
#_______________________________________________________________________________________
sub consult_experiment {
	my $exp_id = shift;
	my @experiment_name;
	my @experiment_type;
	my @experiment_factors;
	my @analysis_type;
	my @array_type;
	my ( $ligne1, $ligne2, $ligne3, $ligne4, $ligne5, $ens, $dsgnfile );
	my ( @first_name_id, @last_name_id );
	my @note;
	my ( $lkrepos,  $repos );
	my ( @repos_db, @repos_ac );
	my ( $design,   $icodesign );

	my $req =	&SQLCHIPS::do_sql("select experiment_name,experiment_type,experiment_factors,
	array_type, analysis_type, note, repository_db, repository_access from $ppty.experiment 
	where experiment_id=$exp_id and project_id in (select project_id from $ppty.project where 
	$varReqpublic)");

	my $reqdsg = &SQLCHIPS::do_sql("Select p.protocol_file from $ppty.protocol p, 
	$ppty.experiment e where e.protocol_id = p.protocol_id and p.protocol_type = 'experiment' 
	and e.experiment_id = $exp_id");

	if ( $req->{NB_LINE} != 0 ) {
		@experiment_name    = &SQLCHIPS::get_col( $req, 0 );
		@experiment_type    = &SQLCHIPS::get_col( $req, 1 );
		@experiment_factors = &SQLCHIPS::get_col( $req, 2 );
		@array_type         = &SQLCHIPS::get_col( $req, 3 );
		@analysis_type      = &SQLCHIPS::get_col( $req, 4 );
		@note               = &SQLCHIPS::get_col( $req, 5 );
		@repos_db           = &SQLCHIPS::get_col( $req, 6 );
		@repos_ac           = &SQLCHIPS::get_col( $req, 7 );
		($dsgnfile) = &SQLCHIPS::get_col( $reqdsg, 0 );
	}

	# description:
	#~~~~~~~~~~~~~
	$ligne1 = $x->body( "Analysis type: $analysis_type[0]",           $x->br );
	$ligne2 = $x->body( "Experiment type: $experiment_type[0]",       $x->br );
	$ligne3 = $x->body( "Experiment factors: $experiment_factors[0]", $x->br );
	$ligne4 = $x->body( "Array type: $array_type[0]",                 $x->br );
	$ligne5 = $x->body( "Description: $note[0]",                      $x->br );

	$ens = ("$ligne1\n$ligne2\n$ligne3\n$ligne4");

	# lien descriptif experience
	#~~~~~~~~~~~~~~~~~
	if ($array_type[0] eq 'Affymetrix') {
		$lkexpce = $CHIPS::CEXPAFFY;
	}

	# design:
	#~~~~~~~~
	if ( $dsgnfile ne '' ) {
		my ( $dsgnname, $dsgnpath, $dsgnsufx ) = fileparse( $dsgnfile, qr/\.[^.]*/ );
		$design    = $linkdesign . $dsgnname . $dsgnsufx;
		$icodesign = $linkdesign . "vignette/" . $dsgnname . "_200" . $dsgnsufx;
		$design    = $x->i( "see experiment design:", $x->br )
			. $x->a(
			{ -href => "javascript:PopupImage('$design','$legend','','$experiment_name[0]')" },
			"\n",
			$x->img(
				{	-style  => 'background:#EEEEEE; border-color:#000070;',
					-src    => $icodesign,
					-border => 1,
					-alt    => " picture not yet available "
				}
			)
			);
	}

	# repository:
	#~~~~~~~~~~~~
	if ( scalar @repos_db > 0 ) {
		my $reqrepos =
			&SQLCHIPS::do_sql("Select URL from $ppty.link_url where DATABASE = '$repos_db[0]'");
		($lkrepos) = &SQLCHIPS::get_col( $reqrepos, 0 );
		$repos = $x->a(
			{ -href => "${lkrepos}$repos_ac[0]", -target => '_blank' },
			"\n",
			$x->b( $repos_db[0] ),
			" ...... accession # ",
			$repos_ac[0]
		);
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#AFFICHAGE
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	print $x->div(
		{ -class => 'banner' },
		$x->br,
		$x->div(
			{ -class => 'bannertext' },
			"Experiment: ",
			$x->a(
				{ -class => "rfbanner", -href => "$lkexpce?experiment_id=$exp_id" },
				$experiment_name[0]
			)
		)
		),
		$x->br;
	print $x->table(
		{ -class => "info", -width => '90%', -align => 'center' },

    #caption($x->h3({-style=>'Color:#0000CC'},"Experiment: ", $x->a({-href=>"./$lkexpce?experiment_id=$exp_id"},$experiment_name[0]))),
		$x->Tr(
			{ -align => 'left' },
			[
				$x->th(
					{ -BGCOLOR => "#C0C0C0", -width => '30%' },
					$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;EXPERIMENT TYPE" ),
					$x->td( { -align => 'left' }, [$ens] ),
					$x->td(
						{	-align   => 'right',
							-rowspan => 2,
							-nowrap,
							-style => "Color:#555555;"
						},
						$x->font( { -size => 1 }, $design )
					)
				),
				$x->th(
					{ -BGCOLOR => "#C0C0C0", -width => '30%' },
					$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;DESCRIPTION" ),
					$x->td( { -align => 'left' }, [$ligne5] )
				),
				$x->th(
					{ -BGCOLOR => "#C0C0C0", -width => '30%' },
					$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;PUBLIC REPOSITORY" ),
					$x->td( { -align => 'left' }, [$repos] )
				)
			]
		)
	);

}

#_______________________________________________________________________________________
# ArrayType
#_______________________________________________________________________________________
sub  consult_array_name () {
	my $arrayT_name = shift;

	my $req =	&SQLCHIPS::do_sql(
		"Select array_type_id from $ppty.array_type where upper(array_type_name) = upper('$arrayT_name')");

	&consult_array_type($req->{LINES}[0][0]);
}

sub consult_array_type () {
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#VARIABLES:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	my $arrayT_id = shift;
	my @array_type_name;
	my @platform_name;
	my @platform_type;
	my @note;
	my @spotting_plate;
	my @slide_dim;
	my @surface_type;
	my @coating_type;
	my @nature_attachment;
	my @strand;
	my @arrayer_IN_file;
	my @arrayer_OUT_file;
	my @submission_date;
	my @metablock_nb;
	my @metacol_nb;
	my @metarow_nb;
	my @col_nb;
	my @row_nb;
	my @avg_spot_dim;
	my @spot_nb;
	my @organism_ecotype;
	my @geo_platform;
	my @array_probe_file;
	my ( $ens1, $ens2 );
	my ( $variable1, $variable2, $variable3, $variable4, $variable4bis, $variable5, $variable6 );
	my $lkrepos;
	my $orga = "";

	my $req =
		&SQLCHIPS::do_sql("Select array_type_name,platform_name,platform_type,note,spotting_plate,
		slide_dim,surface_type,coating_type,nature_attachment,strand,user_id,submission_date, 
		arrayer_IN_file, arrayer_OUT_file,metablock_nb,metacol_nb,metarow_nb,col_nb,row_nb,
		avg_spot_dim, spot_nb, geo_platform, array_probe_file from $ppty.array_type where array_type_id=$arrayT_id");

	if ( $req->{NB_LINE} != 0 ) {
		@array_type_name   = &SQLCHIPS::get_col( $req, 0 );
		@platform_name     = &SQLCHIPS::get_col( $req, 1 );
		@platform_type     = &SQLCHIPS::get_col( $req, 2 );
		@note              = &SQLCHIPS::get_col( $req, 3 );
		@spotting_plate    = &SQLCHIPS::get_col( $req, 4 );
		@slide_dim         = &SQLCHIPS::get_col( $req, 5 );
		@surface_type      = &SQLCHIPS::get_col( $req, 6 );
		@coating_type      = &SQLCHIPS::get_col( $req, 7 );
		@nature_attachment = &SQLCHIPS::get_col( $req, 8 );
		@strand            = &SQLCHIPS::get_col( $req, 9 );
		@arrayer_IN_file   = &SQLCHIPS::get_col( $req, 12 );
		@arrayer_OUT_file  = &SQLCHIPS::get_col( $req, 13 );
		@metablock_nb      = &SQLCHIPS::get_col( $req, 14 );
		@metacol_nb        = &SQLCHIPS::get_col( $req, 15 );
		@metarow_nb        = &SQLCHIPS::get_col( $req, 16 );
		@col_nb            = &SQLCHIPS::get_col( $req, 17 );
		@row_nb            = &SQLCHIPS::get_col( $req, 18 );
		@avg_spot_dim      = &SQLCHIPS::get_col( $req, 19 );
		@spot_nb           = &SQLCHIPS::get_col( $req, 20 );
		@geo_platform = &SQLCHIPS::get_col( $req, 21 );
		@array_probe_file = &SQLCHIPS::get_col( $req, 22 );
		#@organism_ecotype  = &SQLCHIPS::get_col( $orgecoreq, 21 );
		
		#foreach (@organism_ecotype) {
		my ( $reqorga, $reqeco );
		$reqorga = &SQLCHIPS::do_sql("Select organism_name from $ppty.organism where organism_id 
		in	(select organism_id from $ppty.ORGANISM_ECOTYPE where array_type_id=$arrayT_id)");
		$reqeco =	&SQLCHIPS::do_sql("Select ecotype_name from $ppty.ecotype where ecotype_id in 
		(select ecotype_id from $ppty.ORGANISM_ECOTYPE where array_type_id=$arrayT_id)");
		$orga .= ( &SQLCHIPS::get_col( $reqorga, 0 ) )[0] . " ("
					. ( &SQLCHIPS::get_col( $reqeco, 0 ) )[0] . ") ";	
		#}
	}
	
	# Repository
	if ( $geo_platform[0] ne '' ) {
		my $reqrepos=&SQLCHIPS::do_sql("Select URL from $ppty.link_url where DATABASE='GEO'");
		$variable6 = $reqrepos->{LINES}[0][0].$geo_platform[0];
		undef $reqrepos;				
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#INSTRUCTIONS
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	$variable1 = $x->h3( "Array design name: ".$array_type_name[0], $x->br );
	if ( $note[0] ne '' ) {
		$variable2 = $x->body( "$note[0]", $x->br );
	}

	if ( $platform_name[0] ne 'Affymetrix' ) {
		$ens2 = ($variable1.$variable2);
		$variable3 = $x->body(
			"Platform name: ".$platform_name[0],
			$x->br, "Platform type: ".$platform_type[0],
			$x->br, "Biological bank format: ".$spotting_plate[0],
			$x->br, "Organism (ecotype): ".$orga
		);
		$variable4 = $x->body(
			"Array surface: ".$surface_type[0],
			$x->br,	"Array coating: ".$coating_type[0],
			$x->br,	"Attachment: ".$nature_attachment[0],
			$x->br,	"Strand number: ".$strand[0],
			$x->br,	"Slide dimension: ".$slide_dim[0]
		);
		$variable4bis = $x->body(
			"Metablocks: ".$metablock_nb[0],
			$x->br,	"Columns of blocks: ".$metacol_nb[0],
			$x->br,	"Rows of blocks: ".$metarow_nb[0],
			$x->br,	"Columns: ".$col_nb[0],
			$x->br,	"Rows: ".$row_nb[0],
			$x->br,	"Average spot diameter: ".$avg_spot_dim[0],
			$x->br,	"Spot number: ".$spot_nb[0],
		);
		$variable5 = $x->body(
			"Biological bank: ",
			$x->a(
				{ href => "$CHIPS::FILELINK" . $arrayer_IN_file[0], -target => 'OtherPage' },
				$arrayer_IN_file[0]
			),
			$x->br,	"Array design: ",
			$x->a(
				{ href => "$CHIPS::FILELINK" . $arrayer_OUT_file[0], -target => 'OtherPage' },
				$arrayer_OUT_file[0]
			),
			$x->br,	"Array probe design: ",
			$x->a(
				{ href => "$CHIPS::ARRPATH/" . $array_probe_file[0], -target => 'OtherPage' },
				$array_probe_file[0]
			)			
		);
		$variable6 = $x->body(
			"GEO accession: ",
			$x->a(
				{ href => $variable6, -target => 'OtherPage' },
				$geo_platform[0]
			)
		);
	} else {

		$ens2 = ($variable1.$variable2);
		$variable3 = $x->body("Platform name: ".$platform_name[0],
			$x->br,"Platform type: ".$platform_type[0], $x->br, );
		$variable4 = $x->body( "Spot nb :  ".$spot_nb[0]	);
		$variable5 = $x->body("Array design: ",
			$x->a(
				{ href => "$CHIPS::FILELINK" . $arrayer_OUT_file[0], -target => 'OtherPage' },
				$arrayer_OUT_file[0]
			)
			
		);

		my $reqchip = &SQLCHIPS::do_sql(
								"Select url from $ppty.link_url where database='$platform_name[0]'");
		$arrayer_OUT_file[0] =~ /(.*)_*.*\.cdf/;
		$variable6 = $x->body(
			"GEO accession: ",
			$x->a(
				{ href => $variable6, -target => 'OtherPage' },
				$geo_platform[0]
			), 
			$x->br, "Affymetrix - GeneChip<sup>&#174</sup> info: ",
			$x->a(
				{ href => $reqchip->{LINES}[0][0].lc($1).".affx", -target => 'OtherPage' },
				lc($1)
			)			
		);
		undef $reqchip;
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#AFFICHAGE
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	print $x->div(
		{ -class => 'banner' },
		$x->br,
		$x->div(
			{ -class => 'bannertext' },
			"Array type: ", $x->font( { -color => 'yellow' }, $array_type_name[0] )
		)
		),
		$x->br;

	if ( $platform_name[0] ne 'Affymetrix' ) {

		print $x->table(
			{ -class => "info", -width => '90%', -align => 'center' },
			$x->Tr(
				{ -align => 'left' },
				[
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;IDENTIFICATION" ) . $x->td($ens2)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;PLATFORM TYPE" ) . $x->td($variable3)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;ARRAY TYPE" ) . $x->td($variable4)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;ARRAY DESIGN" ) . $x->td($variable4bis)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;ARRAY DESCRIPTION FILES" )
							. $x->td($variable5)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;REPOSITORY" )
							. $x->td($variable6)
					)
				]
			)
		);
	} else {

		print $x->table(
			{ -class => "info", -width => '90%', -align => 'center' },
			$x->Tr(
				{ -align => 'left' },
				[
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;IDENTIFICATION" ) . $x->td($ens2)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;PLATFORM TYPE" ) . $x->td($variable3)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;ARRAY DESIGN" ) . $x->td($variable4)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;ARRAY DESCRIPTION FILE" )
							. $x->td($variable5)
					),
					$x->th(
						{ -BGCOLOR => "#C0C0C0", -width => '30%' },
						$x->h4( { -style => "Color:#FFFFFF" }, "&nbsp;REPOSITORY" )
							. $x->td($variable6)
					)
				]
			)
		);
	}

}

#_______________________________________________________________________________________
# Hybridization_data
#_______________________________________________________________________________________
#================================================================
# Function to retrieve differential data of hybridization
# Parameters:
#   $proj_id:   project_id
#   $exp_id:    experiment_id
#   $limite:    number of data to display
#   $pval_ctf:  p-value threshold
# this function is almost OBSOLESCENT !
#================================================================
sub get_differential_data {

	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#VARIABLES:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	my $proj_id  = shift;
	my $exp_id   = shift;
	my $limite   = shift;
	my $pval_ctf = shift;

	my ( $option, $requete0, $requete1, $requete2 );
	my ( $nbcol0, $nbcol1 );
	my ( @spotlist, $spotlist );
	my ( @Rep_id, @Rep_nm, @orgs1, @orgs2, @Sspot_id );
	my $LRep_id;
	my ( %seq_n, %gene_n, %diff_data );
	my ( $nbenr, $j, $spid, $repid, $pval );
	my ( $thline1, $thline2, $thline3, $trdata );
	my $retval;

	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#REQUETES
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	# id and names of replicats:
	$requete0 =
		&SQLCHIPS::do_sql("Select distinct r.replicat_id, r.replicat_extracts, s1.organ, s2.organ 
		from $ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.hybridization h, 
		$ppty.extract_pool ep1, $ppty.extract_pool ep2, $ppty.hybrid_labelled_extract hle1, 
		$ppty.hybrid_labelled_extract hle2,$ppty.sample_extract se1, $ppty.sample_extract se2, 
		$ppty.sample s1, $ppty.sample s2 where r.replicat_id=hr.replicat_id and 
		h.hybridization_id=hr.hybridization_id and h.cy3_extract_pool_id=hle1.labelled_extract_id 
		and hle1.extract_pool_id=ep1.extract_pool_id and ep1.extract_id=se1.extract_id and 
		se1.sample_id=s1.sample_id and h.cy5_extract_pool_id=hle2.labelled_extract_id and 
		hle2.extract_pool_id=ep2.extract_pool_id and ep2.extract_id=se2.extract_id and 
		se2.sample_id=s2.sample_id and r.experiment_id = $exp_id and hr.ref=1 and 
		(r.rep_type =	'swap' or r.rep_type = 'r_swap') order by r.replicat_extracts");

	@Rep_id = &SQLCHIPS::get_col( $requete0, 0 );
	$LRep_id = join( ',', @Rep_id );

	if ( $pval_ctf != 0 and $pval_ctf ne '' ) {
		$option = "and bonf_p_value < $pval_ctf";
	} else {
		$option = "";
	}

	# names of sequences (CATMA & AGI codes):
	#$requete1 =
	#	&SQLCHIPS::do_sql("Select s.spot_id, ss.seq_name, sp.gene_name from $ppty.spotted_sequence 
	#	ss, $ppty.spot_gene sp, $ppty.spot s, (select distinct spot_id from 
	#	$ppty.diff_analysis_value where replicat_id in ($LRep_id) $option) cv where 
	#	cv.spot_id=s.spot_id and ss.type_feat='GST' and s.spotted_seq_id=ss.spotted_sequence_id(+) 
	#	and ss.spotted_sequence_id=sp.spotted_sequence_id(+)");
	$requete1 =
		&SQLCHIPS::do_sql("Select s.spot_id, ss1.seq_name, sp.gene_name from $ppty.spot s LEFT 
		OUTER JOIN $ppty.spotted_sequence ss1 ON (s.spotted_seq_id=ss1.spotted_sequence_id), 
		$ppty.spotted_sequence ss2 LEFT OUTER JOIN $ppty.spot_gene sp ON 
		(ss2.spotted_sequence_id=sp.spotted_sequence_id), (select distinct spot_id from 
		$ppty.diff_analysis_value where replicat_id in ($LRep_id) and bonf_p_value < $pval_ctf) cv 
		where cv.spot_id=s.spot_id and ss1.type_feat='GST' and ss2.type_feat='GST'");

	if ( $requete1->{NB_LINE} <= $limite ) { $limite = $requete1->{NB_LINE} - 1; }
	@spotlist = ( &SQLCHIPS::get_col( $requete1, 0 ) )[ 0 .. $limite ];
	$spotlist = join( ',', @spotlist );

	# data values:
	$requete2 =
		&SQLCHIPS::do_sql("select distinct spot_id, replicat_id, i_sample, i_ref, log_ratio, 
		bonf_p_value from $ppty.diff_analysis_value where replicat_id in ($LRep_id) and spot_id 
		in ($spotlist)");

	# number of columns:
	$nbcol0 = scalar @Rep_id;        # nbre de replicat_id (ou swap)
	$nbcol1 = $requete1->{NB_COL};

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#INSTRUCTIONS
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	# recuperation des donnees
	for ( $j = 0 ; $j < $requete0->{NB_LINE} ; $j++ ) {
		$Rep_nm[$j] = $requete0->{LINES}[$j][1];
		$orgs1[$j]  = $requete0->{LINES}[$j][3];
		$orgs2[$j]  = $requete0->{LINES}[$j][2];
	}
	undef $requete0;

	for ( $j = 0 ; $j < $requete1->{NB_LINE} ; $j++ ) {
		$Sspot_id[$j]                        = $requete1->{LINES}[$j][0];
		$seq_n{ $requete1->{LINES}[$j][0] }  = $requete1->{LINES}[$j][1];
		$gene_n{ $requete1->{LINES}[$j][0] } = $requete1->{LINES}[$j][2];
	}
	undef $requete1;
	
	for ( $j = 0 ; $j < $requete2->{NB_LINE} ; $j++ ) {
		$spid  = $requete2->{LINES}[$j][0];
		$repid = $requete2->{LINES}[$j][1];
		$pval  = $requete2->{LINES}[$j][5];
		if ( $pval ne '' ) { $pval = sprintf( "%.0E", $pval ); }
		${ $diff_data{$spid} }{$repid} = sprintf(
			"%.2f,%.2f,%.3f,%s",
			$requete2->{LINES}[$j][2],
			$requete2->{LINES}[$j][3],
			$requete2->{LINES}[$j][4], $pval
		);
	}
	undef $requete2;
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#MISE EN FORME POUR AFFICHAGE
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	#columns names:
	#~~~~~~~~~~~~~~
	( $thline1, $thline2, $thline3 ) =
		&create_diff_col_names( $proj_id, $exp_id, \@Rep_id, \@Rep_nm, \@orgs1, \@orgs2 );

	#data:
	#~~~~~
	my @Spot_tab = keys %diff_data;
	( $nbenr, $trdata ) =
		&create_diff_data_lines( \@Spot_tab, \@Rep_id, \%seq_n, \%gene_n, \%diff_data );

	$retval = table( { -bgcolor => "#FFFFFF", -border => "1", -rules => 'all' },
		"\n", Tr($thline1), "\n", Tr($thline2), "\n", Tr($thline3), "\n", $trdata )
		. "\n";
	$retval .= br . "\nNumber of lines: $nbenr\n" . br;

	return $nbcol0, $retval;

}

#==========================================================================
# Function to retreive and sort by swap differential data of hybridization
# Parameters:
#   $proj_id:   project_id
#   $exp_id:    experiment_id
#   $rep_id:    replicat_id
#   $debut:     starting range of data to display
#   $limite:    number of data to display
#==========================================================================
sub sort_data_byswap {

	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#VARIABLES:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	my $proj_id = shift;
	my $exp_id  = shift;
	my $rep_id  = shift;
	my $debut   = shift;
	my $limite  = shift;

	my ( $requete0, $requete1, $requete2, $requete3, $requete4 );
	my ( @Rep_id, $LRep_id );
	my $refswap;
	my ( @Spot_id, $LSpot_id );
	my ( $nbswap,  $nbspot, $fin );
	my ( $j,       $nbline );
	my ( @idRep,   @Rep_ext, @orgs1, @orgs2 );
	my ( $spid,   $pval,   $repid );
	my ( %seq_n,  %gene_n, %diff_data );
	my ( $thlin1, $thlin2, $thlin3 );
	my ( $nbenr, $Trdata );
	my $navbar;
	my $retval;

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#REQUETES & RECUPERATION DES DONNEES
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# swap de ref et liste des autres swaps
	if ( $rep_id eq '' || $rep_id == '' ) {
		$requete0 = &SQLCHIPS::do_sql("Select replicat_id from $ppty.replicats where 
		experiment_id = $exp_id and (rep_type = 'swap' or rep_type = 'r_swap') order by 
		replicat_extracts, replicat_id");
		@Rep_id = &SQLCHIPS::get_col( $requete0, 0 );
		$rep_id = shift(@Rep_id);
	} else {
		$requete0 = &SQLCHIPS::do_sql("Select replicat_id from $ppty.replicats where 
		experiment_id = $exp_id and replicat_id <> $rep_id and (rep_type = 'swap' or 
		rep_type = 'r_swap') order by replicat_extracts, replicat_id");
		@Rep_id = &SQLCHIPS::get_col( $requete0, 0 );
	}
	$LRep_id = join( ',', @Rep_id );

	# Nom du swap de reference:
	$requete0 = &SQLCHIPS::do_sql("Select replicat_extracts from $ppty.replicats where 
	replicat_id = $rep_id and (rep_type = 'swap' or rep_type = 'r_swap')");
	($refswap) = &SQLCHIPS::get_col( $requete0, 0 );
	# number of swaps:
	$nbswap = scalar(@Rep_id) + 1;
	
	# DATA Pour le swap de reference:
	# nouvelle requete sur spotted_seq_id pour tenir compte d'array_type differents
#	$requete1 =	&SQLCHIPS::do_sql("Select s.spotted_seq_id, i_sample, i_ref, log_ratio, 
#	bonf_p_value from $ppty.diff_analysis_value daf, $ppty.spot s where s.spot_id = daf.spot_id 
#	and replicat_id = $rep_id and bonf_p_value <= $pval_ctf and s.control_id in (0,2,3,6) 
#	order by bonf_p_value, log_ratio desc");
	$requete1 =	&SQLCHIPS::do_sql("Select SP.spotted_seq_id, daf.i_sample, daf.i_ref, daf.log_ratio, daf.bonf_p_value 
	from (select spot_id, spotted_seq_id from chips.spot where control_id in (0,2,3,6)) AS SP,
	(select spot_id, replicat_id, i_sample, i_ref, log_ratio, bonf_p_value 
	from chips.diff_analysis_value where replicat_id=$rep_id and bonf_p_value <= $pval_ctf) AS daf 
	WHERE daf.spot_id=SP.spot_id order by daf.bonf_p_value, daf.log_ratio desc");

	$nbspot = $requete1->{NB_LINE};
	if ( ( $debut + $limite ) <= $nbspot ) {
		$fin = $debut + $limite;
	} else {
		$fin = $nbspot;
	}
	@Spot_id = ( &SQLCHIPS::get_col( $requete1, 0 ) )[ $debut .. $fin - 1 ];
	$LSpot_id = join( ',', @Spot_id );

	#data Pour le swap de reference
	$nbline = $fin;
	tie %diff_data, "Tie::IxHash";
	for ( $j = $debut ; $j < $nbline ; $j++ ) {
		$spid = $requete1->{LINES}[$j][0];
		$pval = $requete1->{LINES}[$j][4];
		if ( $pval ne '' ) { $pval = sprintf( "%.0e", $pval ); }
		${ $diff_data{$spid} }{$rep_id} = sprintf(
			"%.2f,%.2f,%.2f,%s",
			$requete1->{LINES}[$j][1],
			$requete1->{LINES}[$j][2],
			$requete1->{LINES}[$j][3], $pval
		);
	}
	undef $requete1;
	
	# DATA Pour les autres swaps:
	if ( scalar(@Rep_id) > 0 ) {
		# $requete2 = &SQLCHIPS::do_sql("Select spot_id, replicat_id, i_sample, i_ref, log_ratio, bonf_p_value from $ppty.diff_analysis_value where replicat_id in ($LRep_id) and spot_id in ($LSpot_id)");
		# nouvelle requete sur spotted_seq_id pour tenir compte d'array_type differents
#		$requete2 = &SQLCHIPS::do_sql("Select s.spotted_seq_id, replicat_id, i_sample, i_ref, 
#		log_ratio, bonf_p_value from $ppty.diff_analysis_value daf, $ppty.spot s where 
#		s.spot_id = daf.spot_id and replicat_id in ($LRep_id) and s.spotted_seq_id in ($LSpot_id)");

# optimisation de la requete en memoire en prenant qu'une partie de la table DAF!!!
# vero
#		my	$req="Select SP.spotted_seq_id, daf.replicat_id, daf.i_sample, daf.i_ref, daf.log_ratio, daf.bonf_p_value 
#		from (select spot_id, spotted_seq_id from chips.spot where spotted_seq_id in ($LSpot_id)) AS SP,
#	  (select replicat_id from chips.replicats where replicat_id in ($LRep_id)) AS REP, 
#	  (select spot_id, replicat_id, i_sample, i_ref, log_ratio, bonf_p_value from chips.diff_analysis_value 
#	  where replicat_id in ($LRep_id)) AS daf 
#	  where daf.replicat_id=REP.replicat_id and daf.spot_id=SP.spot_id";

	
	my	$req="Select SP.spotted_seq_id, daf.replicat_id, i_sample, i_ref, log_ratio, bonf_p_value
		from (select spot_id, spotted_seq_id from chips.spot where spotted_seq_id in ($LSpot_id)) AS SP,
	  (select replicat_id from chips.replicats where replicat_id in ($LRep_id)) AS REP, 
	  (select spot_id, replicat_id, to_char(i_sample,'90.99') as i_sample, to_char(i_ref,'90.99') as i_ref, 
	  to_char(log_ratio,'90.99') as log_ratio, to_char(bonf_p_value,'0.9999') as bonf_p_value 
	  from chips.diff_analysis_value where replicat_id in ($LRep_id)) AS daf 
	  where daf.replicat_id=REP.replicat_id and daf.spot_id=SP.spot_id";

		$requete2 = &SQLCHIPS::do_sql("$req");

		$LRep_id = "," . $LRep_id;    # pour que la requete4 fonctionne avec 1 seul swap

		$nbline = $requete2->{NB_LINE};
		for ( $j = 0 ; $j < $nbline ; $j++ ) {
			$spid  = $requete2->{LINES}[$j][0];
			$repid = $requete2->{LINES}[$j][1];
			$pval  = $requete2->{LINES}[$j][5];
			if ( $pval ne '' ) { $pval = sprintf( "%.0e", $pval ); }
			${ $diff_data{$spid} }{$repid} = sprintf("%.2f,%.2f,%.2f,%s", 
				$requete2->{LINES}[$j][2], 
				$requete2->{LINES}[$j][3],
				$requete2->{LINES}[$j][4], 
				$pval);
		}
		undef $requete2;
	}

	# names of sequences (CATMA & AGI codes):
	# $requete3 = &SQLCHIPS::do_sql("Select s.spot_id, ss.seq_name, sp.gene_name from $ppty.spotted_sequence ss, $ppty.spot_gene sp, $ppty.spot s where s.spot_id in ($LSpot_id) and s.spotted_seq_id=ss.spotted_sequence_id(+) and ss.spotted_sequence_id=sp.spotted_sequence_id(+)");
	# nouvelle requete sur spotted_seq_id pour tenir compte d'array_type differents
	#	Jointure externe ORACLE vs PgSQL :
	#"Select ss.spotted_sequence_id, ss.seq_name, sp.gene_name from $ppty.spotted_sequence ss, $ppty.spot_gene sp where ss.spotted_sequence_id in ($LSpot_id) and ss.spotted_sequence_id=sp.spotted_sequence_id(+)"
	$requete3 = &SQLCHIPS::do_sql("Select ss.spotted_sequence_id, ss.seq_name, sp.gene_name 
	 from $ppty.spotted_sequence ss LEFT OUTER JOIN $ppty.spot_gene sp ON 
	(ss.spotted_sequence_id = sp.spotted_sequence_id) where ss.spotted_sequence_id in 
	($LSpot_id)");

	$nbline = $requete3->{NB_LINE};
	for ( $j = 0 ; $j < $nbline ; $j++ ) {
		$seq_n{ $requete3->{LINES}[$j][0] }  = $requete3->{LINES}[$j][1];
		$gene_n{ $requete3->{LINES}[$j][0] } = $requete3->{LINES}[$j][2];
	}
	undef $requete3;

	# id et noms des replicats de l'experience:
	$requete4 = &SQLCHIPS::do_sql("Select distinct r.replicat_id, r.replicat_extracts, s1.organ, 
	s2.organ from $ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.hybridization h, 
	$ppty.extract_pool ep1, $ppty.extract_pool ep2, $ppty.hybrid_labelled_extract hle1, 
	$ppty.hybrid_labelled_extract hle2, $ppty.sample_extract se1, $ppty.sample_extract se2, 
	$ppty.sample s1, $ppty.sample s2 where r.replicat_id=hr.replicat_id and 
	h.hybridization_id=hr.hybridization_id and h.cy3_extract_pool_id=hle1.labelled_extract_id 
	and hle1.extract_pool_id=ep1.extract_pool_id and ep1.extract_id=se1.extract_id and 
	se1.sample_id=s1.sample_id and h.cy5_extract_pool_id=hle2.labelled_extract_id and 
	hle2.extract_pool_id=ep2.extract_pool_id and ep2.extract_id=se2.extract_id and 
	se2.sample_id=s2.sample_id and r.replicat_id in ($rep_id $LRep_id) and hr.ref=1 and 
	(r.rep_type = 'swap' or r.rep_type = 'r_swap') order by r.replicat_extracts");

	$nbline = $requete4->{NB_LINE};
	for ( $j = 0 ; $j < $nbline ; $j++ ) {
		$idRep[$j]   = $requete4->{LINES}[$j][0];
		$Rep_ext[$j] = $requete4->{LINES}[$j][1];
		$orgs1[$j]   = $requete4->{LINES}[$j][3];
		$orgs2[$j]   = $requete4->{LINES}[$j][2];
	}
	undef $requete4;

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#MISE EN FORME POUR AFFICHAGE
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#navigation bar:
	$navbar = &navigation_bar( $proj_id, $exp_id, $rep_id, $refswap, $debut, $limite, $nbspot );

	#column names:
	( $thlin1, $thlin2, $thlin3 ) =
		&create_diff_col_names( $proj_id, $exp_id, \@idRep, \@Rep_ext, \@orgs1, \@orgs2 );

	#data:
	$Trdata = &create_diff_data_lines( \@Spot_id, \@idRep, \%seq_n, \%gene_n, \%diff_data );

	#vers affichage:
	$retval = $x->table({
			-bgcolor     => "#FFFFFF",
			-border      => "1",
			-rules       => 'all',
			-bordercolor => "#555555",
			-cellspacing => 0,
			-cellpadding => 1
		}, "\n",
		$x->Tr($thlin1), "\n",
		$x->Tr($thlin2), "\n",
		$x->Tr($thlin3), "\n", $Trdata
		)	. "\n";

	return $nbswap, $navbar, $retval;

}

#----------------------------------------------------------------
#   Construire les entetes du tableau des données
#----------------------------------------------------------------
sub create_diff_col_names () {

	my $projid  = shift;
	my $expid   = shift;
	my $Repid   = shift;
	my $Rep_nom = shift;
	my $org1    = shift;
	my $org2    = shift;

	my $nbcol  = scalar( @{$Repid} );
	my @entete =
		( "<font color=red>I S1</font>", "<font color=green>I S2</font>", "R", "P-VAL" );
	my ( $i,       $elm,     $colspan );
	my ( $thline1, $thline2, $thline3 );

	$thline1 =
		$x->td( { -class => "label", -align => 'right', -colspan => '2' }, "organs: &nbsp" )
		. "\n";
	$thline2 =
		$x->td( { -class => "label", -align => 'right', -colspan => '2' }, "dye-swap name: &nbsp" )
		. "\n";
	$thline3 = $x->td( { -class => "label", -align => 'center' }, "GST ID" ) . "\n";
	$thline3 .= $x->td( { -class => "label", -align => 'center' }, "GENE ID" ) . "\n";

	for ( $i = 0 ; $i < $nbcol ; $i++ ) {
		$thline1 .=
			$x->td( { -align => 'center', -colspan => '5' }, ${$org1}[$i] . "/" . ${$org2}[$i] )
			. "\n";
		$thline2 .= $x->td(
			{ -align => 'center', -colspan => '5' },
			$x->a(
				{ -href => "$lkexpce?experiment_id=$expid#${$Repid}[$i]" },
				$x->b( ${$Rep_nom}[$i] )
			),
			"&nbsp;",
			$x->a(
				{ -href => "$lksdiff?project_id=$projid&experiment_id=$expid&swap_id=${$Repid}[$i]",
					-onClick => "doValidation('wtdiv1');" },
				$x->img( { -src => "$bulupdw", -border => 0, -width => 16, -alt => "^" } )
				)
			)
			. "\n";

		foreach $elm (@entete) {
			if ( $elm eq $entete[-1] ) { $colspan = "colspan=2"; }
			else { $colspan = ''; }
			$thline3 .=
				$x->td( { -class => "label", -align => 'center', -width => 31, $colspan }, $elm );
		}
	}

	return $thline1, $thline2, $thline3;
}

#----------------------------------------------------------------
#   Construire les lignes ordonnées du tableau de données
#----------------------------------------------------------------
sub create_diff_data_lines () {

	my $Sptid = shift;
	my $Repid = shift;
	my $seqn  = shift;
	my $gene  = shift;
	my $data  = shift;

	my $ctlines = 0;
	my ( @keytab, @trline, $trline );
	my ( $key1,   $key2,   $oldkey );
	my ( $is1,    $is2,    $lrt, $pvl );


	foreach $key1 ( @{$Sptid} ) {
		if ( $oldkey = grep ( $key1 == $_, @keytab ) ) {
			next;
		} else {
			push( @keytab, $key1 );

			#gst names:
			$ctlines++;
			push(
				@trline,
				(
					$x->td( a( { -href => "$lkinfo?ident=${$seqn}{$key1}" }, ${$seqn}{$key1} ) ),
					$x->td( a( { -href => "$lkinfo?ident=${$gene}{$key1}" }, ${$gene}{$key1} ) )
				)
			);

			#data:
			foreach $key2 ( @{$Repid} ) {

				if ( exists( ${ ${$data}{$key1} }{$key2} ) ) {
					( $is1, $is2, $lrt, $pvl ) = split( ',', ${$data}{$key1}{$key2} );

					if ( $pvl ne '' ) {

						#... ecrire data
						push(
							@trline,
							(
								$x->td( { -align => 'center', -bgcolor => I_bgcolor($is1) }, $is1 ),
								$x->td( { -align => 'center', -bgcolor => I_bgcolor($is2) }, $is2 ),
								$x->td(
									{
										-align   => 'center',
										-style   => "Color: #FFFFFF",
										-bgcolor => R_bgcolor( $pvl, $lrt ),
										-nowrap
									},
									$lrt
								),
								$x->td(
									{
										-align   => 'center',
										-style   => "Color: #555555",
										-bgcolor => PV_bgcolor($pvl),
										-nowrap
									},
									$pvl
								),
								$x->td( { -width => 1 }, "" )
							)
						);
					} else {

						#... ecrire vide
						push(
							@trline,
							(
								$x->td( { -bgcolor => I_bgcolor('') }, '' ),
								$x->td( { -bgcolor => I_bgcolor('') }, '' ),
								$x->td( { -bgcolor => R_bgcolor( $pvl, '' ) }, '' ),
								$x->td( { -bgcolor => PV_bgcolor($pvl) }, '' ),
								$x->td( { -width => 1, -border => 0 }, "" )
							)
						);
					}
				} else {

					#... ecrire vide
					push(
						@trline,
						(
							$x->td( { -bgcolor => I_bgcolor('') }, '' ),
							$x->td( { -bgcolor => I_bgcolor('') }, '' ),
							$x->td( { -bgcolor => R_bgcolor( $pvl, '' ) }, '' ),
							$x->td( { -bgcolor => PV_bgcolor($pvl) }, '' ),
							$x->td( { -width => 1, -border => 0 }, "" )
						)
					);
				}
			}
			$trline .= $x->Tr( join( '', @trline ) ) . "\n";
			@trline = "";
		}
	}

	return $trline;

}

#==========================================================================
# Sub-function to generate a navigation bar for diff data visualization
#==========================================================================
sub navigation_bar {

	my $projid = shift;
	my $expid  = shift;
	my $repid  = shift;
	my $repnom = shift;
	my $debut  = shift;
	my $limit  = shift;
	my $total  = shift;

	my $lkdiff = "$lksdiff?project_id=$projid\&experiment_id=$expid\&swap_id=$repid\&idb=";
	my ( $cible, $lien, $imgsrc );
	my $barre;
	my ( $nopage, $nbpages, $libpge );
	my $reste = $total % $limit;
	my $fin   = $total - $reste;

	# nb data & nom swap
	$lien =
		  $x->font( { -color => "#BB0000" }, $total )
		. " probes differentially expressed, sorted for the dye-swap "
		. $x->font( { -color => "#BB0000" }, $repnom );

	$barre .= $x->td( { -style => "color:#444444;" },
		$x->font( { -size => '1' }, $x->b( $lien . "&nbsp;" ) ) );

	# debut <<
	if ( $debut >= $limit ) {
		$cible  = $lkdiff . "0";
		$imgsrc = $x->img( { -src => "$ongauche", -border => 0, -alt => '<<' } );
		$lien   = $x->a( { -href => "$cible" }, $imgsrc . $imgsrc );
	} else {
		$imgsrc = $x->img( { -src => "$offgauche", -border => 0, -alt => '<<' } );
		$lien = $imgsrc . $imgsrc;
	}

	$barre .= $x->td( "&nbsp;" . $lien );

	# precedent <
	if ( $debut >= $limit ) {
		$cible = $lkdiff . ( $debut - $limit );
		$imgsrc = $x->img( { -src => "$ongauche", -border => 0, -alt => '<' } );
		$lien = $x->a( { -href => "$cible" }, $imgsrc );
	} else {
		$imgsrc = $x->img( { -src => "$offgauche", -border => 0, -alt => '<' } );
		$lien = $imgsrc;
	}

	$barre .= $x->td( "&nbsp;", $lien );

	# no page / nb total page
	$nopage  = int( $debut / $limit ) + 1;
	$nbpages = int( $total / $limit ) + 1;

	$libpge = "page $nopage / $nbpages";
	$barre .= $x->td( { -style => "color:#555555;" }, $x->i( "&nbsp;" . $libpge ) );

	# page 1.2.3...20
	#  my $nbpages = 20;
	#  my ($cpt, $cpt_deb, $cpt_fin);
	#  if ($debut >= ($nbpages * $limit)) {
	#    $cpt_fin = ($debut / $limit) + 1;
	#    $cpt_deb = $cpt_fin - $nbpages + 1;
	#  } else {
	#    $cpt_deb = 1;
	#    $cpt_fin = int($total / $limit);
	#    if ($reste != 0) { $cpt_fin++; }
	#    if ($cpt_fin > $nbpages) { $cpt_fin = $nbpages; }
	#  }

	#  for ($cpt=$cpt_deb; $cpt <= $cpt_fin; $cpt++) {
	#    if ($cpt == ($debut / $limit) + 1) {
	#      $barre .= $x->td($x->a({-class=>'off'}, $x->b("&nbsp;$cpt ")));
	#    } else {
	#      $cible = $lkdiff.(($cpt-1)*$limit);
	#      $barre .= $x->td($x->a({-href=>"$cible"}, $x->b("&nbsp;$cpt ")));
	#    }
	#  }

	# suivant >
	if ( $debut + $limit < $total ) {
		$cible = $lkdiff . ( $debut + $limit );
		$imgsrc = $x->img( { -src => "$ondroite", -border => 0, -alt => '>' } );
		$lien = $x->a( { -href => "$cible" }, $imgsrc );
	} else {
		$imgsrc = $x->img( { -src => "$offdroite", -border => 0, -alt => '>' } );
		$lien = $imgsrc;
	}

	$barre .= $x->td( "&nbsp;", $lien );

	# fin >>
	if ( $reste == 0 ) { $fin = $fin - $limit; }

	if ( $debut != $fin ) {
		$cible  = $lkdiff . $fin;
		$imgsrc = $x->img( { -src => "$ondroite", -border => 0, -alt => '>>' } );
		$lien   = $x->a( { -href => "$cible" }, $imgsrc . $imgsrc );
	} else {
		$imgsrc = $x->img( { -src => "$offdroite", -border => 0, -alt => '>>' } );
		$lien = $imgsrc . $imgsrc;
	}

	$barre .= $x->td( "&nbsp;", $lien );

	return $x->table( { -border => 0, -id => 'navig' }, $x->Tr($barre) );

}

#==========================================================================
# Sub-function to generate missing value legend
#==========================================================================
sub Missing_val {
	my $missval = table(
		{ -border => 0 },
		"\n",
		Tr(
			{ -height => 3, -style => "font-size:7.5pt;" },
			td( {-nowrap}, "missing value: " ),
			"\n",
			td(
				{ -valign => 'center' },
				"\n",
				table(
					{ -border => 0, -height => 9 },
					"\n", Tr( td( { -bgcolor => I_bgcolor(), -width => 35 }, "" ), "\n" )
				),
				"\n"
			)
		),
		"\n"
		)
		. "\n";

	return $missval;
}

#==========================================================================
# Sub-function to change tab cell's background color
# according to the intensity value
#==========================================================================
sub I_bgcolor {

	my $idata = shift;
	my %color = (
		'A' => '#666666',    # valeur nulle ou manquante
		'B' => '#777700',    # valeur entre 0 et 7
		'C' => '#B3B300',    # valeur entre 7 et 10
		'D' => '#DDDD55',    # valeur entre 10 et 13
		'E' => '#FFFF55',    # valeur superieure a 13
	);

	if ( $idata eq '' || $idata == '' || $idata < 0 ) {
		return $color{'A'};
	} elsif ( $idata >= 0 && $idata <= 7 ) {
		return $color{'B'};
	} elsif ( $idata > 7 && $idata <= 10 ) {
		return $color{'C'};
	} elsif ( $idata > 10 && $idata <= 13 ) {
		return $color{'D'};
	} elsif ( $idata > 13 ) {
		return $color{'E'};
	}

}

#==========================================================================
# Sub-function to generate intensity scale table
# legend for data consultation interfaces
#==========================================================================
sub I_scale {

	my $ichelle = table(
		{ -border => 0, -style => "font-size:7pt;" },
		"\n",
		Tr(
			{ -height => 3 },
			td( { -align => 'right' }, "&nbsp;" ),
			td( { -align => 'left', -width => 50 }, "0" ),
			td( { -align => 'left', -width => 50 }, "7" ),
			td( { -align => 'left', -width => 50 }, "10" ),
			td( { -align => 'left', -width => 50 }, "13" )
		),
		"\n",
		Tr(
			{ -height => 3, -style => "font-size:7.5pt;" },
			td( {-nowrap}, "normalized log<sub>2</sub> intensity I: " ),
			td(
				{ -colspan => 4, -valign => 'center' },
				table(
					{ -border => 0, -height => 10 },
					"\n",
					Tr(
						td( { -bgcolor => I_bgcolor(7),  -width => 50 }, "" ),
						td( { -bgcolor => I_bgcolor(10), -width => 50 }, "" ),
						td( { -bgcolor => I_bgcolor(13), -width => 50 }, "" ),
						td( { -bgcolor => I_bgcolor(14), -width => 50 }, "" )
					)
				),
				"\n"
			)
		),
		"\n"
		)
		. "\n";

	return $ichelle;

}

#==========================================================================
# Sub-function to change tab's cell background color
# according to the p-value and log-ratio value
# (scale range is fixed to -3<->3)
#==========================================================================
sub R_bgcolor {

	my $pval   = shift;
	my $lratio = shift;

	my $lrmax = 3;
	my $R     = 0;
	my $V     = 0;
	my $B     = 0;

	if ( $pval ne '' and $pval <= $pval_ctf ) {
		if ( $lratio eq '' ) {
			$R = 102;
			$V = 102;
			$B = 102;
		} elsif ( $lratio < 0 ) {
			$V = int( ( 0 - $lratio ) * ( 255 / $lrmax ) );
			if ( $V > 255 ) { $V = 255 }
		} else {
			$R = int( $lratio * ( 255 / $lrmax ) );
			if ( $R > 255 ) { $R = 255 }
		}
	} elsif ( $pval eq '' ) {
		$R = 102;
		$V = 102;
		$B = 102;
	}

	return ( $R == 0 && $V == 0 && $B == 0 )
		? sprintf("#000")
		: sprintf( "#%02x%02x%02x", $R, $V, $B );
}

#==========================================================================
# Sub-function to generate log-ratio scale table
# legend for data consultation interfaces
#==========================================================================
sub R_scale {

	my $spval   = $pval_ctf;
	my $rchelle = table(
		{ -border => 0, -cellspacing => 0, -style => "font-size:7pt;" },
		"\n",
		Tr(
			{ -height => 3 },
			td("&nbsp"),
			td( { -align => 'left',   -width => 40 }, "" ),
			td( { -align => 'left',   -width => 40 }, "-2.5" ),
			td( { -align => 'left',   -width => 40 }, "-1.5" ),
			td( { -align => 'left',   -width => 40 }, "-1" ),
			td( { -align => 'center', -width => 45 }, "no diff" ),
			td( { -align => 'right',  -width => 40 }, "1" ),
			td( { -align => 'right',  -width => 40 }, "1.5" ),
			td( { -align => 'right',  -width => 40 }, "2.5" ),
			td( { -align => 'right',  -width => 40 }, "" )
		),
		"\n",
		Tr(
			{ -height => 3, -style => "font-size:7.5pt;" },
			td( {-nowrap}, "normalized log<sub>2</sub>-ratio R: " ),
			td(
				{ -colspan => 9, -valign => 'center' },
				table(
					{ -border => 0, -height => 7, -cellspacing => 0 },
					"\n",
					Tr(
						td( { -bgcolor => R_bgcolor( $spval, -3 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, -2.5 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, -1.5 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, -1 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, 0 ), -width => 45 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, 1 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, 1.5 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, 2.5 ), -width => 40 }, "" ),
						"\n",
						td( { -bgcolor => R_bgcolor( $spval, 3 ), -width => 40 }, "" )
					)
				),
				"\n"
			)
		),
		"\n"
		)
		. "\n";
	return $rchelle;
}

#==========================================================================
# Sub-function to change tab's cell background color
# according to the P-value
#==========================================================================
sub PV_bgcolor {

	my $pvdata = shift;
	my $val1   = 0.00000001;
	my $val2   = 0.05;
	my %color  = (
		'A' => '#00FFFF',    # valeur egale a 0
		'B' => '#0099FF',    # valeur entre 0 et 1E-8
		'C' => '#000099',    # valeur entre 1E-8 et 5E-2
		'D' => '#000',       # valeur superieure a 5E-2
		'E' => '#666666'     # valeur manquante
	);

	if ( $pvdata eq '' ) {
		return $color{'E'};
	} elsif ( $pvdata <= 0 ) {
		return $color{'A'};
	} elsif ( $pvdata > 0 && $pvdata <= $val1 ) {
		return $color{'B'};
	} elsif ( $pvdata > $val1 && $pvdata <= $val2 ) {
		return $color{'C'};
	} elsif ( $pvdata > $val2 ) {
		return $color{'D'};
	}

}

#==========================================================================
# Sub-function to generate P-value scale table
# legend for data consultation interfaces
#==========================================================================
sub PV_scale {

	my $pvchelle = table(
		{ -border => 0, -style => "font-size:7pt;" },
		"\n",
		Tr(
			{ -height => 3 },
			td("&nbsp"),
			td( { -align => 'right', -width => 50 }, "0" ),
			td( { -align => 'right', -width => 50 }, "1.E-8" ),
			td( { -align => 'right', -width => 50 }, "5.E-2" ),
			td( { -align => 'right', -width => 50 }, "1" )
		),
		Tr(
			{ -height => 3, -style => "font-size:7.5pt;" },
			td( {-nowrap}, "Bonferroni p-Value: " ),
			td(
				{ -colspan => 4, -valign => 'center' },
				table(
					{ -border => 0, -height => 10 },
					"\n",
					Tr(
						td( { -bgcolor => PV_bgcolor(0), -width => 50 }, "" ),
						"\n",
						td( { -bgcolor => PV_bgcolor(0.00000001), -width => 50 }, "" ),
						"\n",
						td( { -bgcolor => PV_bgcolor(0.05), -width => 50 }, "" ),
						"\n",
						td( { -bgcolor => PV_bgcolor(0.1), -width => 50 }, "" )
					)
				),
				"\n"
			)
		),
		"\n"
		)
		. "\n";

	return $pvchelle;
}

#==========================================================================
# sub-function pour obtenir organism et ecotype a partir d'un experiment_id
# recupere tout et concatene la sortie: organism(ecotype)
#==========================================================================
sub recupOrganismEcotype() {

	my $expId = shift;

	my $reqSample = &SQLCHIPS::do_sql(
"select distinct organism_id, ecotype_id from $ppty.sample_source where experiment_id=$expId"
		);

	my @orga_id = &SQLCHIPS::get_col( $reqSample, 0 );
	my @eco_id  = &SQLCHIPS::get_col( $reqSample, 1 );

	my $j           = 0;
	my $Resorganism = "";

	for ( $j = 0 ; $j < scalar(@orga_id) ; $j++ ) {
		if ( $j != 0 ) { $Resorganism .= ", "; }    # encore un
		my $organism = &recupdbName( "organism", $orga_id[$j] );
		my $ecotype = "";
		if ( $eco_id[$j] ne "" ) {
			$ecotype = &recupdbName( "ecotype", $eco_id[$j] );
			if ($ecotype) { $organism .= " ($ecotype)"; }
		}

		$Resorganism .= $organism;
	}
	return $Resorganism;
}

#==========================================================================
# Envoi d'un mail (necessite module MIME::Lite, merci Philippe)
# 4 arguments : destinataire, sujet, message, expediteur
#==========================================================================
sub envoi_mail () {

	my ( $addr, $subj, $mssg, $retadd ) = @_;

	my $email = MIME::Lite->new(
		From    => "CATdb <$retadd>",
		To      => "$addr",
		Subject => "$subj",
		Data    => "$mssg"
	);

	$email->send( 'smtp', 'smtp.u-psud.fr' );

}

#==========================================================================
# Affichage d'une div de la classe .wait (cf. catdb_consult.css)
# 3 arguments : id, message, style
#==========================================================================
sub Wait_div () {
	
	my ($divid, $divtxt, $divstyle) = @_;
	my $waitdiv;
	
	if ($divstyle ne '') {
		$waitdiv = div ( {-id=> "$divid", -class=>"wait", -style=>"$divstyle"}, 
							h3( {-class=>"waitxt"}, $divtxt) );
	} else {
		$waitdiv = div ( {-id=> "$divid", -class=>"wait"}, 
							h3( {-class=>"waitxt"}, $divtxt) );
	}
	
	return $waitdiv;	
}

1;
