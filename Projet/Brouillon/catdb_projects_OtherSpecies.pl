#!/usr/local/bin/perl

#------------------------------------------------------------------------
# Version du 11 Aout 2014 VERO
# Rajout dans le tableau de la colonne resNorm pour avoir acces direct
# au fichier de donnes qui se trouve dans ftp
# et du nbr de puces/exp
#
# Tableau doit marcher pour toutes les especes autre que Arabido
# donc pas que Affy mais aussi NimbleGen, Agilent etc...
#------------------------------------------------------------------------
# Version du 10/07/14 (AFFY seul)
# - logo ChromoChip uniquement pour site prive
#------------------------------------------------------------------------
# Version du 29/09/09 (AFFY seul)
#
# + recherche par keyword sur projets affy
# + liens sur logos plateformes
# - recherche par ID
# + lien sur plateforme affymetrix
# + nouveau programme consult_expce_affy.pl pour affymetrix
# + tableau des projets uniquement AFFYMETRIX
# + ORGANS dans les tableaux des projets
# - SOURCE et ARRAY-TYPE dans les tableaux des projets
# + ref biblio
# + message d'attente de chargement discret
# + fonctionnalisation de l'affichage
#------------------------------------------------------------------------

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';
use SQLCHIPS;
use CHIPS;
use consult_package;

#--Variables---------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $public    = $CHIPS::PUBLIC;
my $listmes   = "public";            # par defaut public
if ( $public =~ "<>" ) { $listmes = "private"; }
my $w        = new CGI;
my $contproj = 0;
my $contaffy = 0;
my $bansuff  = '';

my ( $proaffy, $reqpaffy, $reqcoord, $listexaffy );
my ( %horgan,  %hbiblio,  $i,        $nbline );
my ($tableau_AFFYM);

#couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC;
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;
my $grisS = $consult_package::GRISS;

#noms des colonnes AFFY
my @colaffym = ( "PROJECT", "TITLE", "COORD", "ORGAN", "ARRAY TYPE",
							 "EXPERIMENT", "NORMALIZED DATA<br>(# arrays)" );
#taille des cellules
my @ttd = ( "10%", "30%", "8%", "8%", "10%", "30%", "10%" );

#--Liens-----------------------------------------------
# lien PubMed
my $lkpubmed = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=";
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page d'accueil
my $lkaccueil = $CHIPS::CACCUEIL;
# consultation projets
my $lkproject = $CHIPS::CPROJECT;
# projets catma
my $lkpcatma = $CHIPS::CATDBPRO;
# projets ChIP-chip
my $lkpchip = $CHIPS::CATDBCHROMO;
# consultation details experiences
my $lkexpaffy = $CHIPS::CEXPAFFY;
# consultation details experiences
my $lkexpce = $CHIPS::CEXPCE;
# consultation coordinateur
my $lkcoord = $CHIPS::COORD;
# consultation donnees par keyword
my $lkprojkw = $CHIPS::CPROJKW;

# icone new
my $newicon  = $CHIPS::NEWICON;
my $urgvsmal = $CHIPS::URGVSMALL;
my $affx     = $CHIPS::STYLEPATH . "affy_mini.png";
my $catma    = $CHIPS::STYLEPATH . "catmaurgv.jpg";

# site FTP lien VERO
my $lkftpresnorm = $CHIPS::XLSPATH;    # pour les fichiers resNorm publics

#--PROJECTS BROWSER------------------------------------
# TOUS les projets VERO autre que Arabido
# donc ni CATMA et ni ATH1
# prise en compte de toutes les Platformes autre que pour Arabido (Affy, NimbleGen, Agilent)
my @pltf = ( 'NimbleGen', 'Agilent', 'Affymetrix' );
@pltf = map { sprintf( "'%s'", $_ ) } @pltf;
my $pltf = join( ",", @pltf );

# projets et experiences :
$proaffy = "Select distinct p.project_id, e.experiment_id, p.project_name, 
p.title, e.array_type, e.experiment_name, h.array_type_name 
from $ppty.project p, $ppty.experiment e, $ppty.hybridization h 
where e.project_id=p.project_id and h.experiment_id=e.experiment_id 
and p.is_public $public and e.array_type in ($pltf) and e.analysis_type in ('Arrays','CGH')
and h.array_type_name in 
(select a.array_type_name from $ppty.array_type a where a.common_name<>'Arabidopsis')
order by h.array_type_name, p.project_name, e.experiment_name";

$reqpaffy = &SQLCHIPS::do_sql($proaffy);
$listexaffy = join( ",", &SQLCHIPS::get_col( $reqpaffy, 1 ) );

# coordinateurs :
$reqcoord = &SQLCHIPS::do_sql(
"Select pc.project_id, c.contact_id, c.last_name from $ppty.project_coordinator pc, 
	$ppty.contact c where pc.contact_id = c.contact_id and pc.project_id in (select project_id 
	from $ppty.project where is_public $public) order by pc.project_id, c.last_name" );

# organe(s) pour chaque experience
my $reqorg = &SQLCHIPS::do_sql(
	"Select distinct e.experiment_id, s.organ 
from $ppty.experiment e, $ppty.sample s, $ppty.project p 
where e.experiment_id=s.experiment_id and e.project_id=p.project_id 
and e.experiment_id in ($listexaffy) and p.is_public $public" );
$nbline = $reqorg->{NB_LINE};

for ( my $i = 0 ; $i < $nbline ; $i++ ) {
	if ( exists $horgan{ $reqorg->{LINES}[$i][0] } ) {
		$horgan{ $reqorg->{LINES}[$i][0] } .=
		  sprintf( ", %s", $reqorg->{LINES}[$i][1] );
	} else {
		$horgan{ $reqorg->{LINES}[$i][0] } = $reqorg->{LINES}[$i][1];
	}
}
undef $reqorg;

# article(s) biblio associe :
my $reqbib = &SQLCHIPS::do_sql(
	"Select b.project_id, b.pubmed_id from $ppty.project_biblio b, 
$ppty.project p where b.project_id = p.project_id and p.is_public $public" );
$nbline = $reqbib->{NB_LINE};

for ( my $i = 0 ; $i < $nbline ; $i++ ) {
	if ( exists $hbiblio{ $reqbib->{LINES}[$i][0] } ) {
		push @{ $hbiblio{ $reqbib->{LINES}[$i][0] } }, $reqbib->{LINES}[$i][1];
	} else {
		$hbiblio{ $reqbib->{LINES}[$i][0] } = [ $reqbib->{LINES}[$i][1] ];
	}
}
undef $reqbib;

#--HTML---------------------------------------------------
print $w->header(), "\n";
my $JSCRIPT = <<END;
var waitStyle=null
function doValidation (thediv) {
	waitStyle = document.getElementById(thediv).style;
	if (waitStyle) {
		waitStyle.visibility="visible";
	}
}
function RedoValidation (thediv) {
	waitStyle = document.getElementById(thediv).style;
	if (waitStyle) {
		waitStyle.visibility="hidden";
	}
}
	
function openwdw(url,nom,wth,hht){
  newnd = window.open(url,nom,"toolbar=no,location=no,directories=no,menubar=no,scrollbars=yes,resizable=no,width="+wth+",height="+hht+",opener=catdb,status=no");
  newnd.window.moveBy(-50,10);
}

END

print $w->start_html(
	-title  => 'CATdb Projects on Other species',
	-author => 'bioinfo@evry.inra.fr',
	-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
	-head => [
			   meta( { -http_equiv => 'Pragma', -content => 'no-cache' } ),
			   meta( { -http_equiv => 'Cache-Control', -content    => 'no-cache, must-revalidate' } ),
			   meta( { -http_equiv => 'Expires', -content => '0' } )
			 ],
	-style => { -src => $stylepath },
	-onUnload => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
#					-onBlur  => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
#					-onfocusout => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
	-BGCOLOR => "#FFFFFF",
	-script  => $JSCRIPT
  ), "\n";

#--Entete--
my $chromoc = '';
if ( $public =~ "<>" ) {
	# Chromochip seulement pour le site prive
	$chromoc = $w->Tr(
		  $w->td( { -align => 'center' },
				  $w->div( { -class => "circlediv" },
						   $w->a( { -href => $lkpchip, -title => "ChIP-chip projects at IPS2" },
							   $w->h3( $w->b("ChIP-chip") ) )
						 )
				) );
}

print $w->div( { -class => "entete1" }, 
	 $w->div( { -class => "logo" },
			  $w->a( { -href => $lkurgv },
					 $w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } )
				   ),
			  $w->br, $w->br, "\n",
			  $w->img( { -src => $affx, -border => 0, -alt => "Affymetrix", -height => 28 } )
			),
	 $w->div( { -class => "titre" },
			  $w->a( { -href => $lkaccueil },
					 $w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
				   ),
			  $w->br, "\n",
			  $w->font( { -size => 4 },
						$w->b( { -style => 'Color:#336699' },
							$w->i("~ Search & Consult Other Species Projects ~")
						)
					 )
			),
	 $w->div( { -class => "insert" },
			  $w->table(
						 $w->Tr(
							   $w->td(
								   $w->a( { -href => $lkpcatma }, "see projects on Arabidopsis ", $w->br,
										 $w->img( { -src  => $catma,
															 -border => 0,
															 -alt    => "CATMA",
															 -height => '30',
															 -title  => "CATMA projects at IPS2"
														   }
										 )
								   )
							   )
							)
					   )
			)
  ),
  $w->br, $w->br, "\n\n";

#****---Message a decommenter lors des maintenances 	****
#print $w->div( { -align => "center",
#								 -style => "letter-spacing:1.1px;color:#FF0000;padding-top:10px;" },
#				$w->center($w->font( { -size => 3},
#						$w->b("*** Due to network maintenance, access to CATdb and FLAGdb++ will be pertubated on thursday the 15th of april ***")),
#				)
#			);
#-----------------------------------------------
print $w->br, $w->br, "\n";

# larges Wait messages :
#print	&consult_package::Wait_div(	"wtdiv1","Searching ... ... please wait",
#																	"position:fixed;top:19%;" ),"\n";
#print	&consult_package::Wait_div(	"wtdiv2","Loading ... ... please wait",
#																	"position:fixed;top:35%;" ),"\n";
# en image :
#print $w->img({-id=>"wtdiv2",-src=>$loading,-class=>"waitimg", -alt=>"Loading... please wait"});

#--Recherche par mot cle--
$bansuff = $w->font( { -size => -1 }, "(among projects)" );
print $w->div( { -class => 'banner' },
			   $w->div( { -class => 'bannertext' }, "Search by keyword ", $bansuff ) ),
  $w->br, "\n";
  
print $w->start_form( -method => 'POST', -action => $lkprojkw );

print $w->table( { -width       => '87%',
							   -border      => 0,
							   -cellpadding => 5,
							   -cellspacing => 0,
							   -bgcolor     => $blanc
							},
	$w->Tr( { -bgcolor => $blanc, -height => '35' },
		$w->td( { -width => '30%' }, $w->b("Enter a word to retreive projects:") ), 
		$w->td( { -align => 'right', -colspan => 2 }, $w->textfield( 'kwrd', '', 50, 50 ) ), 
		$w->td( { -width => '20%' }, "&nbsp;" )
	), "\n",
	$w->Tr( { -bgcolor => $blanc, -height => '35' },
		$w->td( { -colspan => 2 }, $w->font( { -size => -2, -color => $grisS },
						  $w->i(
"&nbsp;search a word in Projects, Experiments, Coordinators, Array types, Organs, Mutations, etc." ) )
			  ),
		$w->td( { -align => 'right', -width => '25%' },
				$w->submit(
							-name    => 'submit',
							-value   => 'search projects',
							-onClick => "doValidation('wtdiv1')"
						  )
			  ),
		$w->td( { -align => 'center' },
			$w->div( { -id => "wtdiv1", -style => "visibility:hidden;color:#0066CC;height:5px;text-align:center" },
				$w->b("Searching ... please wait") )
			)
	), "\n",
	
	#ligne de mise en forme du tableau pour colspan! :
	$w->Tr( { -height => '0' }, $w->td(), $w->td(), $w->td(), $w->td() )
 ), "\n";
 
print $w->end_form, "\n";

#--Projects browser Table--
( $contaffy, $tableau_AFFYM ) = &table_projects( $reqpaffy, $reqcoord, \@colaffym );
undef $reqpaffy, $reqcoord;

#--affichage AFFY--
print $w->div( { -class => 'banner' },
			   $w->div( { -class => 'bannertext' },
			   		sprintf ("Browse %d projects for various species (%s)", $contaffy, $listmes) )
			 ), "\n";

print $w->div( { -align => 'right', -style => "color:yellow; font-size:12px;margin-right:-2px;" },
			   $w->font( { -style => "background:$grisS;" },
					$w->i("&nbsp;in column 'NORMALIZED DATA' click on ", $w->b("resNorm to download data file&nbsp;") ) )
			 ), "\n";

print $tableau_AFFYM;
print $w->br, "\n";

print $w->end_html;

#--Fonctions---------------------------------------------------
sub table_projects () {

	# Modifiee pour AFFY
	my $reqprojet = shift;
	my $reqcoordi = shift;
	my $colnames  = shift;

	my ( @projid, @expid, @projn, @ptitl, @platf, @expn, @nbchip );
	my ( $i, $j, $newproj, $vpbib, $affyarray, $lkplatf );
	my ( @coord, $coname, $coordin, $coulor );
	my ( $entete, $trline, $tdline, $datatab, $dataline );
	my $oldproj   = '';
	my $countproj = 0;
	my $countexp  = 0;
	my $nblin1    = $reqprojet->{NB_LINE};

	if ( $nblin1 != 0 ) {

		# projets
		for ( $i = 0 ; $i < $nblin1 ; $i++ ) {
			push @projid, $reqprojet->{LINES}[$i][0];
			push @expid,  $reqprojet->{LINES}[$i][1];
			push @projn,  $reqprojet->{LINES}[$i][2];
			push @ptitl,  $reqprojet->{LINES}[$i][3];
			push @platf,  $reqprojet->{LINES}[$i][4];
			push @expn,   $reqprojet->{LINES}[$i][5];
			push @nbchip, $reqprojet->{LINES}[$i][6];
		}

		# coordinateurs
		my $nblin2 = $reqcoordi->{NB_LINE};
		for ( $i = 0 ; $i < $nblin2 ; $i++ ) {
			push( @coord, $reqcoordi->{LINES}[$i] );
		}
		undef $reqprojet, $reqcoordi;

		# nom des colonnes du tableau
		$entete = &table_entete($colnames);

		# lien sur plateforme affy
#		$affyarray = &array_name_id( "'" . join( "','", @nbchip ) . "'" );
		$affyarray = &array_name_id( sprintf ("'%s'", join( "','", @nbchip )) );
		
		# contenu du tableau
		for ( $i = 0 ; $i < $nblin1 ; $i++ ) {
			$newproj = $projid[$i];
			
			if ( $newproj ne $oldproj ) {
				$countproj++;
				$countexp = 0;
				
				if ($tdline) {
					$datatab = $w->table( { -border      => 0,
															-cellpadding => 1,
															-cellspacing => 0,
															-width       => '100%',
															-height      => "100%",
															-bgcolor     => $blanc
														  },
										  $datatab );
					$trline .= $w->Tr( $tdline, $w->td( { -valign  => 'top', -bgcolor => $grisC }, $datatab ) );
					$datatab = '';
				}
				$tdline = $w->td( { -width => $ttd[0], -valign => 'top', -bgcolor => $grisC },
							  		$w->a( { -href => "$lkproject?project_id=$newproj" }, $projn[$i] ) );

				# insertion biblio
				if ( exists $hbiblio{$newproj} ) {
					$vpbib = $w->i("<br>Pubmed #&nbsp;");
					foreach ( @{ $hbiblio{$newproj} } ) {
						$vpbib .= $w->a( { -href => $lkpubmed . $_, -target => '_blank' }, $w->i("&nbsp;$_") );
					}
				} else {
					$vpbib = '';
				}
				$tdline .= $w->td( {
									  -width   => $ttd[1],
									  -valign  => 'top',
									  -bgcolor => $grisC
								   },
								   $ptitl[$i],
								   $vpbib
								 ) . "\n";

				# insertion coordinateur(s)
				$coordin = '';
				for ( $j = 0 ; $j < $nblin2 ; $j++ ) {
					if ( $coord[$j][0] eq $newproj ) {
						$coname = ucfirst( lc( $coord[$j][2] ) );
						$coordin .= $w->a( { -href => "javascript:openwdw('$lkcoord?contact_id=$coord[$j][1]','coord',400,170)" },
							$coname );
						$coordin .= $w->br;
					}
				}
				$tdline .= $w->td( { -width => $ttd[2], -valign => 'top', -bgcolor => $grisC }, $coordin );

				# insertion organ
				$tdline .= $w->td( { -width => $ttd[3], -bgcolor => $grisC, -valign => 'top' }, $horgan{ $expid[$i] } );

				# array type VERO (je reclasse les colonnes)
				$lkplatf = sprintf ("%s?array_type_id=%s", $lkproject, $affyarray->{ $nbchip[$i] });
				$tdline .= $w->td( { -width => $ttd[4], -bgcolor => $grisC, -valign  => 'top' },
								   $w->a( { -href => $lkplatf, -onClick => "doValidation('wtdiv2')" }, $nbchip[$i] ) );
			}

			# experiences
			$countexp++;
			$coulor = ( $countexp % 2 ) ? $grisC : $grisM;  #alternance couleur de ligne

			### VERO ajout du resNorm
			# VERO nbr d'hybridation par experiments
			my $reqnbHyb = &SQLCHIPS::do_sql(
				"select count(hr.hybridization_id) from chips.replicats r, chips.hybrid_replicats hr where 
			r.experiment_id=$expid[$i] and r.replicat_id=hr.replicat_id and r.rep_type in ('r_affy','swap','r_swap')" );
			my $nbHyb = ( &SQLCHIPS::get_col( $reqnbHyb, 0 ) )[0];
			#my $nbHyb = $reqnbHyb->{LINES}[0][0];		#JPHT
			
			my $linkexp = $lkexpce;
			if ( $platf[$i] eq "Affymetrix" ) { $linkexp = $lkexpaffy; }
			
			my $resNormfile = sprintf( "resNorm_%s_exp%d.txt.gz", $projn[$i], $expid[$i] );
			my $resNormlnk = sprintf( "%s/%s", $lkftpresnorm, $resNormfile );    # lien public

			$dataline = $w->td( { -width => $ttd[5], -bgcolor => $coulor, -valign => 'top', -align => 'left' },
						$w->a( { -href => "$linkexp?experiment_id=$expid[$i]" }, $expn[$i] ) );

			# ajout VERO colonne resNorm
			$dataline .= $w->td( { -width => $ttd[6], -bgcolor => $coulor, -valign => 'top', -align => 'right' },
								 $w->a( { -href => $resNormlnk }, sprintf("(%d) &nbsp;resNorm file", $nbHyb) ) );
			$datatab .= $w->Tr( { -bgcolor => $coulor }, $dataline );
			$oldproj = $newproj;
		}

		# dernier projet
		$datatab = $w->table( { -border      => 0,
												 -width       => '100%',
												 -height      => "100%",
												 -cellpadding => 1,
												 -cellspacing => 0,
												 -bgcolor     => $blanc
											  },
							  $datatab );
		$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, $datatab ) );

		# affichage
		my $contenu = $w->table( { -width       => '100%',
														-border      => 0,
														-cellpadding => 1,
														-cellspacing => 1,
														-bgcolor     => $blanc
													 }, "\n", $entete, "\n", $trline );

		return $countproj, $contenu;
	}
}

sub table_entete () {
	my $nmtab = shift;            # pointeur sur tableau des noms de colonne
	my $nbcol = scalar @$nmtab;
	my ( $i, $thline, $subthline );

	# noms des colonnes
	for ( $i = 0 ; $i < $nbcol ; $i++ ) {
		if ( $i < 5 ) {
			$thline .= $w->td( { -width => $ttd[$i], -align => 'center' }, $w->b( $$nmtab[$i] ) );
		} else {
			$subthline .= $w->td( { -width => $ttd[$i], -align => 'center' }, $w->b( $$nmtab[$i] ) );
		}
	}
	$subthline = $w->table( { -border      => 0,
											   -width       => '100%',
											   -height      => "100%",
											   -cellpadding => 0,
											   -cellspacing => 0,
											   -bgcolor     => $blanc
											},
							$w->Tr( { -bgcolor => $grisF, -style => "Color:$blanc", -height => '25' }, $subthline )
						  );
	$thline .= $w->td( { -align => 'center', -width => '60%' }, $subthline );
	$thline = $w->Tr( { -bgcolor => $grisF, -style => "Color:$blanc", -height => '25' }, "\n", $thline );
	
	return $thline;
}

sub array_name_id () {
	my $listname = shift;
	my $arrays   = {};

	my $reqarray = &SQLCHIPS::do_sql(
"Select array_type_name, array_type_id from $ppty.array_type where array_type_name in ($listname)"
	);
	my $nbl = $reqarray->{NB_LINE};
	
	for ( my $i = 0 ; $i < $nbl ; $i++ ) {
		$arrays->{ $reqarray->{LINES}[$i][0] } = $reqarray->{LINES}[$i][1];
	}
	undef $reqarray;
	return $arrays;
}
