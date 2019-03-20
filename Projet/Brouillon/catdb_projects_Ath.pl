#!/usr/local/bin/perl

#------------------------------------------------------------------------
# Version du 11 Aout 2014 VERO
# Tableau restreint a Arabido uniquement
# On va rajouter l'ARRAY_TYPE car important pour arabido
# tout type confondu meme Affy
# rq : pas tres beau peut-etre qu'il faudrait rajouter un champs dans projets
# pour trier par Arabido / OtherSpecies
#------------------------------------------------------------------------
#-----------------------------------------------------------
# Version du 4/07/2014   (CATMA seul)
# visualisation des projets CATMA v6 et v7
# dans le meme tableau
# + prise en compte de la plateforme
# + le nb de swaps n'est pas cliquable pour v6/7
# - logo Chromochip uniquement pour site prive
#-----------------------------------------------------------
# Version du 4/02/2014   (CATMA seul)
# changement du type d'analyse suite a la modif de Vero
#  + type d'analyse = 'Arrays'
#-----------------------------------------------------------
# Version du 13/02/2013   (CATMA seul)
# + choix diff data / total data par bouton radio
#     lors de la recherche par id
#-----------------------------------------------------------
# Version du 29/09/09   (CATMA seul)
# + ORGANS dans le tableau des projets
# - SOURCE et ARRAY-TYPE dans le tableau des projets
# + ref biblio
# + message d'attente de chargement  (discret)
# + fonctionnalisation de l'affichage
#-----------------------------------------------------------

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';
use SQLCHIPS;
use CHIPS;
use consult_package;

#--Variables---------------------------------------------
my $ppty       = $CHIPS::DBname;
my $stylepath  = $CHIPS::STYLECSS;
my $catdblogo  = $CHIPS::CATDBLOGO;
my $gemnetlogo = $CHIPS::GEM2NETLOGO;
my $public     = $CHIPS::PUBLIC;
my $listmes    = "public";              # par defaut public
if ( $public =~ "<>" ) { $listmes = "private"; }
my $typanalyse = "'Arrays'";
# prise en compte des nouvelles versions de CATMA
# par contre les noms pour arabido sont CATMAxxx ou ATH1 uniquement
my @pltf = ( 'CATMA', 'NimbleGen', 'Agilent', 'Affymetrix' );
#formatage
@pltf = map { sprintf( "'%s'", $_ ) } @pltf;
my $pltf = join( ",", @pltf );
my $w           = new CGI;
my $countproj   = 0;
my $countexp    = 0;
my %radiolabels = ( '1' => 'all data', '2' => 'only differential data' );
my ( $projreq, $reqproj, $reqcoord, $orgreq, $reqorg, $reqbib );
my ( %hbiblio, %horgan,  %hgemnet );
my ( $i,       $nbline );
my ( $platf,   $tableau_CATMA );

#couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC;
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;
my $grisS = $consult_package::GRISS;

#tableau :
#noms des colonnes
my @nmtab = ( "PROJECT", "TITLE", "COORD", "ORGAN", "ARRAY DESIGN", "EXPERIMENT", "# SWAPS" );
#taille des cellules
my @ttd = ( "10%", "30%", "8%", "8%", "10%", "30%", "10%" );

#--Liens-----------------------------------------------
# lien PubMed
my $lkpubmed = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=";
# lien web projet GEM2Net
my $lkgem2net = $CHIPS::GEM2NET . "Profiles.php?project_id=";
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page d'accueil
my $lkaccueil = $CHIPS::CACCUEIL;
# consultation projets
my $lkproject = $CHIPS::CPROJECT;
# projets ChIP-chip
my $lkpchip = $CHIPS::CATDBCHROMO;
# projets Affy
my $lkpaffy = $CHIPS::CATDBAFFY;
# consultation details experiences
my $lkexpce = $CHIPS::CEXPCE;
# consultation details experiences Affy (monocouleur)
my $lkexpaffy = $CHIPS::CEXPAFFY;
## consultation coordinateur
my $lkcoord = $CHIPS::COORD;
# consultation donnees diff
my $lkdiff = $CHIPS::CDIFF;
# consultation donnees diff par id
my $lkdiffid = $CHIPS::CDIFFID;
# consultation donnees par keyword
my $lkprojkw = $CHIPS::CPROJKW;
# interrogation par liste de sonde/gene
my $lkmultiq = $CHIPS::MULTIQ;
# site FTP lien VERO
my $lkftpresnorm = $CHIPS::XLSPATH;    # pour les fichiers resNorm publics
# pour OtherSpecies VERO
my $lkotherspecies = $CHIPS::CATDBOTHERSPECIES;

# icone new
my $newicon  = $CHIPS::NEWICON;
my $urgvsmal = $CHIPS::URGVSMALL;
my $affx = $CHIPS::STYLEPATH . "affy_mini.png";
# image loading
my $loading = $CHIPS::STYLEPATH . "loading.gif";
#$w->img({-id=>"mydiv",-src=>$loading, -width=>120, -height=>90, -border=>0, -alt=>"Loading... please wait"})

#--PROJECT BROWSER------------------------------------
# CATMA toutes versions----
#--Requetes---
#$projreq = sprintf  "Select r.project_id, r.experiment_id, p.project_name, p.title, e.array_type, e.experiment_name,
#count(hr.replicat_id) from $ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.project p, $ppty.experiment e
#where r.project_id = p.project_id and r.experiment_id=e.experiment_id and p.is_public %s
#and e.analysis_type = '%s' and e.array_type in (%s)
#and r.replicat_id=hr.replicat_id and (r.rep_type = 'swap' or r.rep_type = 'r_swap') and hr.ref = 1
#group by p.project_name, e.experiment_name, p.title, e.array_type, r.project_id, r.experiment_id
#order by p.project_name, e.experiment_name", $public, $typanalyse , $pltf;

# Nouvelle requete VERO que Arabido (common_name='Arabidopsis') et toute platforme
$projreq = sprintf ("Select r.project_id, r.experiment_id, p.project_name, 
p.title, e.array_type, e.experiment_name, count(hr.replicat_id)
from chips.replicats r,chips.hybrid_replicats hr, chips.project p, chips.experiment e, 
chips.hybridization h, chips.array_type a
where r.project_id = p.project_id and r.experiment_id=e.experiment_id 
and h.experiment_id=e.experiment_id and h.hybridization_id=hr.hybridization_id
and a.array_type_name=h.array_type_name 
and p.is_public %s  and e.analysis_type in (%s) and e.array_type in (%s)  
and r.replicat_id=hr.replicat_id and (r.rep_type = 'swap' or r.rep_type = 'r_swap' or r.rep_type='r_affy') 
and (hr.ref=1 or hr.ref is null) 
and a.common_name='Arabidopsis'
group by p.project_name, e.experiment_name, p.title, e.array_type, r.project_id, r.experiment_id
order by p.project_name, e.experiment_name", $public, $typanalyse, $pltf);
$reqproj = &SQLCHIPS::do_sql($projreq);
my $listexp = join( ",", &SQLCHIPS::get_col( $reqproj, 1 ) );

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
and e.experiment_id in ($listexp) and p.is_public $public" );
$nbline = $reqorg->{NB_LINE};

for ( my $i = 0 ; $i < $nbline ; $i++ ) {
	if ( exists $horgan{ $reqorg->{LINES}[$i][0] } ) {
		$horgan{ $reqorg->{LINES}[$i][0] } .= sprintf( ", %s", $reqorg->{LINES}[$i][1] );
	} else {
		$horgan{ $reqorg->{LINES}[$i][0] } = $reqorg->{LINES}[$i][1];
	}
}
undef $reqorg;

# article(s) biblio associe  
$reqbib = &SQLCHIPS::do_sql(
"Select b.project_id, b.pubmed_id from $ppty.project_biblio b, $ppty.project p where 
	b.project_id = p.project_id and p.is_public $public" );
$nbline = $reqbib->{NB_LINE};

for ( $i = 0 ; $i < $nbline ; $i++ ) {
	# biblio
	if ( exists $hbiblio{ $reqbib->{LINES}[$i][0] } ) {
		push @{ $hbiblio{ $reqbib->{LINES}[$i][0] } }, $reqbib->{LINES}[$i][1];
	} else {
		$hbiblio{ $reqbib->{LINES}[$i][0] } = [ $reqbib->{LINES}[$i][1] ];
	}
}

# projet GEM2Net associe
$reqbib = &SQLCHIPS::do_sql(
"Select project_id, gem2net_id from $ppty.project where gem2net_id is not null and is_public $public" );
$nbline = $reqbib->{NB_LINE};

for ( $i = 0 ; $i < $nbline ; $i++ ) {
	# Gem2net
	if ( exists $hgemnet{ $reqbib->{LINES}[$i][0] } ) {
		push @{ $hgemnet{ $reqbib->{LINES}[$i][0] } }, $reqbib->{LINES}[$i][1];
	} else {
		$hgemnet{ $reqbib->{LINES}[$i][0] } = [ $reqbib->{LINES}[$i][1] ];
	}
}
undef $reqbib;

#--Traitements---
( $platf, $countproj, $tableau_CATMA ) = &table_projects( $reqproj, $reqcoord, \@nmtab );
undef $reqproj, $reqcoord;

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
		-title  => 'CATdb Projects',
		-author => 'bioinfo@evry.inra.fr',
		-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
		-head => [
				   meta( { -http_equiv => 'Pragma', -content => 'no-cache' } ),
				   meta( { -http_equiv => 'Cache-Control', -content    => 'no-cache, must-revalidate' } ),
				   meta( { -http_equiv => 'Expires', -content => '0' } )
				 ],
		-style => { -src => $stylepath },
		-onUnload => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
		-BGCOLOR  => "#FFFFFF",
		-script   => $JSCRIPT
  ), "\n";

#--entete--
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
				  )
		   ),
	$w->div( { -class => "titre" },
			 $w->a( { -href => $lkaccueil },
					$w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
				  ),
			 $w->br, "\n",
			 $w->font( { -size => 4 },
					   $w->b( { -style => 'Color:#336699' },
							  $w->i("~ Search & Consult Arabidopsis Projects~") )
					 )
		   ),
	$w->div( { -class => "insert" },
			 $w->table(
						$w->Tr(
								$w->td(
									$w->a( { -href => $lkotherspecies }, "see projects on Other Species", $w->br,
										  $w->img( {  -src    => $affx,
															  -border => 0,
															  -height => '30',
															  -title  => "Affymetrix projects at IPS2"
															}
										  )
									)
								)
							  ), 
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

#--recherche par mot cle--
print $w->div( { -class => 'banner' },
			   $w->div( { -class => 'bannertext' }, "Search by keyword" ) ),
  $w->br, "\n";
  
print $w->start_form( -method => 'POST', -action => $lkprojkw );

print $w->table( {	-width       => '87%',
							   -border      => 0,
							   -cellpadding => 5,
							   -cellspacing => 0,
							   -bgcolor     => $blanc
							}, "\n",
	$w->Tr( { -bgcolor => $blanc, -height => '35' },
			$w->td( { -width => '30%' }, $w->b("Enter a word to retreive projects:") ), "\n",
			$w->td( { -align => 'right', -colspan => 2 },
					$w->textfield( 'kwrd', '', 50, 50 )
				  ), "\n",
			$w->td( { -width => '20%' },
					"&nbsp;", $w->hidden( 'platform', $platf )
				  ), "\n"
		  ), "\n",
	$w->Tr( { -bgcolor => $blanc, -height => '35' },
		$w->td( { -colspan => 2 },
				$w->font( { -size => -2, -color => $grisS },
					$w->i("&nbsp;search a word in Projects, Experiments, Coordinators, Array types, Organs, Mutations, etc.")
				)
			  ), "\n",
		$w->td( { -align => 'right', -width => '25%' },
				$w->submit(
							-name    => 'submit',
							-value   => 'search projects',
							-onClick => "doValidation('wtdiv1')"
						  )
			  ), "\n",
		$w->td( { -align => 'center' },
			$w->div( { -id => "wtdiv1", -style => "visibility:hidden;color:#0066CC;height:5px;text-align:center" },
				$w->b("Searching ... please wait")
			)
		), "\n"
	), "\n",

	#ligne de mise en forme du tableau pour colspan! :
	$w->Tr( { -height => '0' }, $w->td(), $w->td(), $w->td(), $w->td() )
  ), "\n";
  
print $w->end_form, "\n";

#--recherche par id--
print $w->div( { -class => 'banner' },
			   $w->div( { -class => 'bannertext' }, "Search by Gene or GST" ) ),
  $w->br, "\n";

print $w->start_form( -method => 'POST', -action => $lkdiffid ), "\n";
print $w->table( {   -width       => '95%',
							   -border      => 0,
							   -cellpadding => 5,
							   -cellspacing => 0,
							   -bgcolor     => $blanc
							}, "\n",
	$w->Tr( { -bgcolor => $blanc, -height => '35' },
		$w->td( { -width => '46%' },
				$w->b("Submit a Gene ID"), " (<i>e.g.</i> AT1G69880) ",
				$w->b("or a GST ID"), " (<i>e.g.</i> CATMA1A59190)<b>:</b>"
		), "\n",
		$w->td( { -width => '29%', -align => 'right' },
				$w->textfield( 'idnum', '', 19, 17 )
			  ), "\n",
		#	$w->td( { -align => 'right'}, "&nbsp;"),"\n",
		$w->td( { -align => 'left' }, "&nbsp;view:&nbsp;",
				$w->radio_group(
											 -name      => 'totaldiff',
											 -values    => [ '1', '2' ],
											 -default   => '1',
											 -linebreak => '0',
											 -labels    => \%radiolabels
										   )
		), 
	), "\n",
	$w->Tr(
		$w->td( { -bgcolor => $blanc, -height => '35' },
			$w->div({-class=>'idlistfrm' },
				$w->a( { -href => $lkmultiq },
					   $w->b("&gt;&gt; OR click here to query CATdb with a list of Gene or GST IDs ")
					 ) )
			  ), "\n",
		$w->td( { -align => 'right' },
				$w->submit(
							-name    => 'submit',
							-value   => 'view data',
							-onClick => "doValidation('wtdiv2')"
						  )
			  ), "\n",
		$w->td( { -align => 'center' },
			$w->div( {	-id => "wtdiv2",
							   -style => "visibility:hidden;color:#0066CC;height:5px;text-align:center"
							},
				$w->b("Loading ... please wait")
			)
		)
	), "\n"
  ), "\n";

print $w->end_form, "\n";

#--projects browser--
print $w->div( { -class => 'banner' },
			   $w->div( { -class => 'bannertext' },
			   	sprintf ("Browse %d projects (%s) for <i>Arabidopsis thaliana</i>", $countproj, $listmes)
				)
			 ), "\n";
			 
print $w->div( { -align => 'right', -style => "color:yellow; font-size:12px;margin-right:-2px;" },
			   $w->font( { -style => "background:$grisS;" },
					$w->i("&nbsp;depending on Array Design, click on ", $w->b("numbers"), " in column '# SWAPS' ",
						$w->b("to view data"), " OR click on ", $w->b("resNorm to download data file&nbsp;") ) )
			 ), "\n";

print $tableau_CATMA;
print $w->br, "\n";

print $w->end_html;

#--Fonctions---------------------------------------------------
sub table_projects () {

	# pour CATMA et autre <> Affy & ChIP-chip
	my $reqprojet = shift;
	my $reqcoordi = shift;
	my $colnames  = shift;

	my ( $i, $j, $newproj, $vpbib, $vg2n );
	my ( @coord, $coname, $coordin, $coulor );
	my ( $entete, $trline, $tdline, $datatab, $dataline );
	my $oldproj  = '';
	my $contproj = 0;
	my $contexp  = 0;
	my $nblin1   = $reqprojet->{NB_LINE};

	if ( $nblin1 != 0 ) {
		# projets
		my ( @projid, @expid, @projn, @ptitl,  @platf, @expn, @nbchip, @arraytypeName, @arraytypeId );
		
		for ( $j = 0 ; $j < $nblin1 ; $j++ ) {
			push @projid, $reqprojet->{LINES}[$j][0];
			push @expid,  $reqprojet->{LINES}[$j][1];
			push @projn,  $reqprojet->{LINES}[$j][2];
			push @ptitl,  $reqprojet->{LINES}[$j][3];
			push @platf,  $reqprojet->{LINES}[$j][4];
			push @expn,   $reqprojet->{LINES}[$j][5];
			push @nbchip, $reqprojet->{LINES}[$j][6];
		}

		# coordinateurs
		my $nblin2 = $reqcoordi->{NB_LINE};
		for ( $i = 0 ; $i < $nblin2 ; $i++ ) {
			push( @coord, $reqcoordi->{LINES}[$i] );
		}
		undef $reqprojet, $reqcoordi;

		# nom des colonnes du tableau
		$entete = &table_entete($colnames);

		# contenu du tableau
		for ( $i = 0 ; $i < $nblin1 ; $i++ ) {
			$newproj = $projid[$i];
			if ( $newproj ne $oldproj ) {
				$contproj++;
				$contexp = 0;
				if ($tdline) {
					$datatab = $w->table( {	-border      => 0,
															-cellpadding => 1,
															-cellspacing => 0,
															-width       => '100%',
															-height      => "100%",
															-bgcolor     => $blanc
														  }, $datatab );
					$trline .= $w->Tr( $tdline, $w->td( { -valign  => 'top',  -bgcolor => $grisC }, $datatab ), "\n" );
					$datatab = '';
				}
	
				# insertion Gem2net (logo + lien)
				if ( exists $hgemnet{$newproj} ) {
					$vg2n = $w->img( { -src => $gemnetlogo, -border => 0, -alt => "GEM2Net", 
													-style  => "float:right; margin-right: 5px;" } );
	
					foreach ( @{ $hgemnet{$newproj} } ) {
						$vg2n = $w->a( { -href   => $lkgem2net . $_,
													   -descr  => "see related GEM2Net project",
													   -target => '_blank'
													 },
													 "&nbsp;&nbsp;", $vg2n );
					}
				} else {
					$vg2n = '';
				}
				$tdline = $w->td( { -width => $ttd[0], -valign => 'top', -bgcolor => $grisC, -nowrap },
									  $w->a( { -href => sprintf ("%s?project_id=%d", $lkproject, $newproj) }, $projn[$i] ), $vg2n );
	
				# insertion biblio
				if ( exists $hbiblio{$newproj} ) {
					$vpbib = $w->i("<br>Pubmed #&nbsp;");
					foreach ( @{ $hbiblio{$newproj} } ) {
						$vpbib .= $w->a( { -href => $lkpubmed . $_, -target => '_blank' }, $w->i("&nbsp;$_") );
					}
				} else {
					$vpbib = '';
				}
				$tdline .= $w->td( { -width => $ttd[1], -valign => 'top', -bgcolor => $grisC }, $ptitl[$i], $vpbib );
	
				# insertion coordinateur(s)
				$coordin = '';
				for ( $j = 0 ; $j < $nblin2 ; $j++ ) {
					if ( $coord[$j][0] eq $newproj ) {
						$coname = ucfirst( lc( $coord[$j][2] ) );
						$coordin .= $w->a( { -href => "javascript:openwdw('$lkcoord?contact_id=$coord[$j][1]','coord',400,170)" },
							$coname
						  );
						$coordin .= $w->br;
					}
				}
				$tdline .= $w->td( { -width => $ttd[2], -valign => 'top', -bgcolor => $grisC }, $coordin );
	
				# insertion organ
				$tdline .= $w->td( { -width => $ttd[3], -bgcolor => $grisC, -valign => 'top' }, $horgan{ $expid[$i] } );
	
				# rajout colonne array_type VERO
				# VERO requete pour aller chercher l'array_type et array_id
				my $reqarray = &SQLCHIPS::do_sql(
					"Select distinct a.array_type_id, h.array_type_name from chips.hybridization h, chips.array_type a 
				where h.experiment_id=$expid[$i] and a.array_type_name=h.array_type_name" );
				my $nbarraybyexp = $reqarray->{NB_LINE};
				
				my $linearray    = '';
				for ( $j = 0 ; $j < $nbarraybyexp ; $j++ ) {
					$linearray .= sprintf ("%s\n",
											$w->a( { -href => sprintf ("%s?array_type_id=%d", $lkproject, $reqarray->{LINES}[$j][0]) },  
														$reqarray->{LINES}[$j][1] ) );								
				}
				$tdline .= $w->td( { -width => $ttd[4], -bgcolor => $grisC, -valign  => 'top' }, $linearray );
			}

			# experiences
			### VERO ajout du resNorm pour Affy + lien
			my $resNormfile = sprintf( "resNorm_%s_exp%d.txt.gz", $projn[$i], $expid[$i] );
			my $resNormlnk = sprintf( "%s/%s", $lkftpresnorm, $resNormfile );    # lien public
			
			my $linkexp = $lkexpce;
			if ( $platf[$i] eq "Affymetrix" ) { $linkexp = $lkexpaffy; }
			
			$contexp++;
			$coulor = ( $contexp % 2 ) ? $grisC : $grisM;   #alternance couleur de ligne

			$dataline = $w->td( { -width => $ttd[5], -bgcolor => $coulor, -valign => 'top' },
						$w->a( { -href => sprintf ("%s?experiment_id=%d", $linkexp, $expid[$i])}, $expn[$i] ) );

			if ( $platf[$i] eq 'CATMA' ) {
				# recuperer le #SWAPS
				$dataline .= $w->td( { -width => $ttd[6], -bgcolor => $coulor, -align => 'right', -valign => 'top' },
							$w->a( { -href => sprintf ("%s?project_id=%d&experiment_id=%d&platform=%s", $lkdiff, $newproj, $expid[$i], $platf[$i]),
										   -onClick => "doValidation('wtdiv2')" }, $nbchip[$i] ) );
			} else {
				# recuperer le resNorm
				$dataline .= $w->td( { -width => $ttd[6], -bgcolor => $coulor, -valign => 'top', -align => 'right', -nowrap },
									 $w->a( { -href => $resNormlnk }, sprintf("(%d) &nbsp;resNorm file", $nbchip[$i]) ) );
			}

			$datatab .= $w->Tr( { -bgcolor => $coulor }, $dataline );
			$oldproj = $newproj;
		}

		# dernier projet
		$datatab = $w->table( { -border => 0,
												 -width => '100%',
												 -height => "100%",
												 -cellpadding => 1,
												 -cellspacing => 0,
												 -bgcolor => $blanc
											  }, $datatab );
		$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, $datatab ) );

		# affichage
		my $contenu = $w->table( { -width => '100%',
													-border => 0,
													-cellpadding => 1,
													-cellspacing => 1,
													-bgcolor => $blanc
												 }, "\n", $entete, "\n", $trline );

		return $platf[0], $contproj, $contenu;
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
	$subthline = $w->table( { -border => 0,
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

