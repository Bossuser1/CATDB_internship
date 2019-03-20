#!/usr/local/bin/perl

#-----------------------------------------------------------
# Version de test de developpement  (avant sept 09)
#   pour CATMA seul
#
# + large message d'attente de chargement 
# et/ou image 
# + ref biblio
# pas de fonctionnalisation de l'affichage
#-----------------------------------------------------------

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
my $w         = new CGI;
my $coldeb    = 2;
my $countproj = 0;
my $countexp  = 0;
my $countaffy = 0;

my ( $projreq, $reqproj, $reqcoord, $reqbib);
my ( $reqstat, $nbpp,    $nbph, $nbtp, $nbth );
my ( $nblin1,  $nblin2,  $nbcol1 );
my ( @projid,  @expid,   @projn, @ptitl, @source, @platf, @expn, @nbchip );
my ( @coord,   $coordin, $coname, %biblio );
my ( $i,       $coulor );
my ( $subthline, $thline, $dataline, $datatab, $trline, $tdline );
my $oldproj = '';
my $newproj;
my ( $vexpid, $vprojn, $vptit, $vpsrc, $vplatf, $vexpn, $vnchip, $vpbib );

#couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC;
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;
my $grisS = $consult_package::GRISS;

#taille des cellules
my @ttd = ( "12%", "27%", "8%", "20%", "70%", "10%" );

#--Liens-----------------------------------------------
# lien PubMed
my $lkpubmed = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=";
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page d'accueil
my $lkaccueil = $CHIPS::CACCUEIL;
# consultation projets
my $lkproject = $CHIPS::CPROJECT;
# consultation details experiences
my $lkexpce = $CHIPS::CEXPCE;
# consultation coordinateur
my $lkcoord = $CHIPS::COORD;
# consultation donnees diff
my $lkdiff = $CHIPS::CDIFF;
# consultation donnees diff par id
my $lkdiffid = $CHIPS::CDIFFID;
# consultation donnees par keyword
my $lkprojkw = $CHIPS::CPROJKW;
# interrogation par liste de sonde/gene
my $lkmultiq = $CHIPS::MULTIQ;
# icone new
my $newicon  = $CHIPS::NEWICON;
my $urgvsmal = $CHIPS::URGVSMALL;
# image loading
my $loading = $CHIPS::STYLEPATH."loading2.gif";


#--PROJECT BROWSER------------------------------------
#--Requetes---
# CATMA
# projets et experiences avec nb de swaps :
$projreq = 'Select r.project_id, r.experiment_id, p.project_name as Project, p.title, p.source, 
e.array_type as "array type", e.experiment_name as Experiment, count(hr.replicat_id) as "# swaps" from ';
$projreq .= "$ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.project p, $ppty.experiment e 
where r.project_id = p.project_id and r.experiment_id=e.experiment_id and p.is_public $public 
and r.replicat_id=hr.replicat_id and (r.rep_type = 'swap' or r.rep_type = 'r_swap') and hr.ref = 1 
group by p.project_name, e.experiment_name, p.title, p.source, e.array_type, r.project_id,
 r.experiment_id order by p.project_name, e.experiment_name";

# projets et experiences avec nb de swaps ET array_type_name :
#$projreq = 'Select r.project_id, r.experiment_id, p.project_name as Project, p.title, p.source, 
#hy.array_type_name as "array type", e.experiment_name as Experiment, count(hr.replicat_id) as "# swaps" from ';
#$projreq .= "$ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.project p, $ppty.experiment e, 
#$ppty.hybridization hy where r.project_id = p.project_id and r.experiment_id=e.experiment_id and 
#hr.hybridization_id = hy.hybridization_id and r.project_id in (select project_id from project where 
#is_public $public) and r.replicat_id=hr.replicat_id and (r.rep_type='swap' or r.rep_type='r_swap') 
#and hr.ref = 1 group by p.project_name, e.experiment_name, p.title, p.source, hy.array_type_name, 
#r.project_id, r.experiment_id order by p.project_name, e.experiment_name";

$reqproj = &SQLCHIPS::do_sql($projreq);

$nblin1  = $reqproj->{NB_LINE};
$nbcol1  = $reqproj->{NB_COL};
@projid  = &SQLCHIPS::get_col( $reqproj, 0 );
@expid   = &SQLCHIPS::get_col( $reqproj, 1 );
@projn   = &SQLCHIPS::get_col( $reqproj, 2 );
@ptitl   = &SQLCHIPS::get_col( $reqproj, 3 );
@source  = &SQLCHIPS::get_col( $reqproj, 4 );
@platf   = &SQLCHIPS::get_col( $reqproj, 5 );
@expn    = &SQLCHIPS::get_col( $reqproj, 6 );
@nbchip  = &SQLCHIPS::get_col( $reqproj, 7 );

# coordinateurs :
$reqcoord = &SQLCHIPS::do_sql("Select pc.project_id, c.contact_id, c.last_name as coord from 
$ppty.project_coordinator pc, $ppty.contact c where pc.contact_id = c.contact_id and pc.project_id 
in (select project_id from $ppty.project where is_public $public) order by pc.project_id");

$nblin2 = $reqcoord->{NB_LINE};
for ( $i = 0 ; $i < $nblin2 ; $i++ ) {
	push( @coord, $reqcoord->{LINES}[$i] );
}

# article biblio associe :
$reqbib = &SQLCHIPS::do_sql("Select b.project_id, b.pubmed_id from $ppty.project_biblio b, 
$ppty.project p where b.project_id = p.project_id and p.is_public $public");

for ( $i = 0 ; $i < $reqbib->{NB_LINE} ; $i++ ) {
	if ( exists $biblio{$reqbib->{LINES}[$i][0]}) {
		push @{$biblio{$reqbib->{LINES}[$i][0]}}, $reqbib->{LINES}[$i][1];
	} else {
		$biblio{$reqbib->{LINES}[$i][0]} = [$reqbib->{LINES}[$i][1]];
	}
}

#--Traitements---
# mise en forme des resultats
if ( $nblin1 != 0 ) {
	
	# noms des colonnes
	for ( $i = 0 ; $i < $nbcol1 - $coldeb ; $i++ ) {
		if ( $i < 3 ) {
			if ( $i == 2 ) {
				$thline .= $w->td( { -width => $ttd[$i], -align => 'center' },
													 $w->b( $reqcoord->{COL_NAMES}[$i] ) );
			}
			$thline .= $w->td( { -width => $ttd[$i], -align => 'center' },
												 $w->b( $reqproj->{COL_NAMES}[ $i + $coldeb ] ) );
		} else {
			$subthline .= $w->td( { -width => $ttd[$i], -align => 'center' },
														$w->b( $reqproj->{COL_NAMES}[ $i + $coldeb ] ) );
		}
	}
	$subthline = $w->table( {	-border      => 0,
														-width       => '100%',
														-height      => "100%",
														-cellpadding => 0,
														-cellspacing => 0,
														-bgcolor     => $blanc
													},
											$w->Tr( { -bgcolor => $grisF,
																-style   => "Color:$blanc",
																-height  => '25'
															},
															$subthline
											)
								)	. "\n";
	$thline .= $w->td( { -align => 'center', -width => '45%' }, $subthline );
	$thline =	$w->Tr( { -bgcolor => $grisF, -style => "Color:$blanc", -height => '25' }, "\n", 
										$thline )	. "\n";
	undef $reqproj;
	undef $reqcoord;
			
	# contenu du tableau
	foreach $newproj (@projid) {
		$vexpid = shift @expid;
		$vprojn = shift @projn;
		$vptit  = shift @ptitl;
		$vpsrc  = shift @source;
		$vplatf = shift @platf;
		$vexpn  = shift @expn;
		$vnchip = shift @nbchip;
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
															$datatab )	. "\n";
				$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, 
										$datatab )) . "\n";
				$datatab = '';
			}
			$tdline = $w->td( { -width => $ttd[0], -valign => 'top', -bgcolor => $grisC, -nowrap },
									$w->a( { -href => "$lkproject?project_id=$newproj" }, $vprojn ) ) . "\n";

			# insertion biblio
			if ( exists $biblio{$newproj} ) {
				$vpbib = $w->i("<br>Pubmed #&nbsp;");
				foreach (@{$biblio{$newproj}}) {
					$vpbib .= $w->a({-href=>$lkpubmed.$_,-target=>'_blank'}, $w->i("&nbsp;$_"));
				}
			} else {
				$vpbib = '';
			}
			$tdline .= $w->td( { -width => $ttd[1], -valign => 'top', -bgcolor => $grisC }, 
									$vptit ) . "\n";

			# insertion coordinateur(s)
			$coordin = '';
			for ( $i = 0 ; $i < $nblin2 ; $i++ ) {
				if ( $coord[$i][0] eq $newproj ) {
					$coname = ucfirst( lc( $coord[$i][2] ) );
					$coordin .= $w->a( { -href =>"javascript:openwdw('$lkcoord?contact_id=$coord[$i][1]','coord',400,170)" },
											$coname	);
					$coordin .= $w->br;
				}
			}
			$tdline .= $w->td( { -width => $ttd[2], -valign => 'top', -bgcolor => $grisC }, 
									$coordin ) . "\n";
			$tdline .= $w->td( { -width => $ttd[2], -valign => 'top', -bgcolor => $grisC }, 
									$vpsrc ) . "\n";
		}

		# data
		$countexp++;
		$coulor = ( $countexp % 2 ) ? $grisC : $grisM;    #alternance couleur de ligne
		$dataline =
			$w->td( { -width => $ttd[3], -bgcolor => $coulor, -valign => 'top' }, $vplatf ) . "\n";
		$dataline .= $w->td( { -width => $ttd[4], -bgcolor => $coulor, -valign => 'top' },
										$w->a( { -href => "$lkexpce?experiment_id=$vexpid" }, $vexpn ) )	. "\n";
		$dataline .= $w->td( { -width => $ttd[5], -bgcolor => $coulor, -align => 'right', -valign => 'top' },
				$w->a({ -href => "$lkdiff?project_id=$newproj&experiment_id=$vexpid&platform=$vplatf", 
								-onClick => "doValidation('wtdiv2')" }, $vnchip )
			)	. "\n";
		$datatab .= $w->Tr( { -bgcolor => $coulor }, $dataline ) . "\n";
		$oldproj = $newproj;
	}

	# dernier projet
	$datatab = $w->table( {	-border      => 0,
													-width       => '100%',
													-height      => "100%",
													-cellpadding => 1,
													-cellspacing => 0,
													-bgcolor     => $blanc
												},
												$datatab
							)	. "\n";
	$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, 
							$datatab ) ) . "\n";
}

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

print $w->start_html(	-title   => 'CATdb Projects',
											-author  => 'bioinfo@evry.inra.fr',
											-meta    => { 'keywords' => 'Plant arabidopsis'},
											-head => [meta({-http_equiv=>'Pragma',-content=>'no-cache'}),
																meta({-http_equiv=>'Cache-Control', -content=>'no-cache, must-revalidate'}),
																meta({-http_equiv=>'Expires', -content=>'0'})
																],
											-style   => { -src => $stylepath },
											-onUnload => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
											-onBlur  => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
											-onfocusout => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
											-BGCOLOR => "#FFFFFF",
											-script  => $JSCRIPT
			), "\n";

#--entete--
print $w->div( { -class => "entete1" }, "\n",
				$w->div( { -class => "logo" },
					$w->a( { -href => "$lkurgv" },
						$w->img( { -src => "$urgvsmal", -border => 0, -alt => "URGV" } )
					)
				), "\n",
				$w->div( { -class => "titre" },
					$w->a( { -href => "$lkaccueil" },
						$w->img( { -src => "$catdblogo", -border => 0, -alt => "CATdb" } )
					), "\n",
					$w->br,	"\n",
					$w->font(	{ -size => 4 },
						$w->b( { -style => 'Color:#336699' },
							$w->i("~ Search & Consult ~")
						)
					), "\n"
				), "\n",
				$w->div( { -class => "insert" }, " " ), "\n"
			), "\n",
			$w->br, "\n";

#****---Message a decommenter lors des maintenances---****			
#print $w->div( { -align => "center",
#								 -style => "letter-spacing:1.1px;color:#FF0000;padding-top:10px;" },
#				$w->center($w->font( { -size => 2},
#							$w->b("*** Due to server maintenance, CATdb, FLAGdb++, UTILLdb and FiToCoGene will be unavailable on 29 and 30 July ***"))),
#							);
#----------------------------------------------------------		 
print $w->br, $w->br, "\n";
# larges Wait messages : 
print	&consult_package::Wait_div(	"wtdiv1","Searching ... ... please wait",
																	"position:fixed;top:19%;" ),"\n";
print	&consult_package::Wait_div(	"wtdiv2","Loading ... ... please wait",
																	"position:fixed;top:35%;" ),"\n";
# en image :
#print $w->img({-id=>"wtdiv2",-src=>$loading,-class=>"waitimg", -alt=>"Loading... please wait"});

#--recherche par mot cle--
print $w->div( { -class => 'banner' }, "\n", 
				$w->div( { -class => 'bannertext' }, "Search by keyword" )
			),
			$w->br, "\n";
print $w->start_form( -method => 'POST', -action => $lkprojkw );
print $w->table( {-width       => '87%',
									-border      => 0,
									-cellpadding => 5,
									-cellspacing => 0,
									-bgcolor     => $blanc
								}, "\n",
				$w->Tr( { -bgcolor => $blanc, -height => '35' }, "\n",
					$w->td( { -width => '25%' }, $w->b("Enter a word:") ), "\n",
				 	$w->td( { -align => 'right', -colspan => 2 }, $w->textfield( 'kwrd', '', 50, 50 ) ),"\n",
				 	$w->td( { -width => '20%' }, "&nbsp;" ), "\n"
				), "\n",
				$w->Tr( { -bgcolor => $blanc, -height => '35' }, "\n",
					$w->td(	{ -colspan => 2 },
						$w->font(	{ -size => -2, -color => $grisS },
							$w->i("&nbsp;search a word in Projects, Experiments, Coordinators, Array types, Organs, etc..."	)
						)
					), "\n",
					$w->td(	{ -align => 'right', -width => '25%' },
						$w->submit( -name=>'submit', -value=>'search projects', -onClick=>"doValidation('wtdiv1')"), "\n"
					),"\n",
					$w->td( { -align => 'center' }, "&nbsp;" ), "\n"
				), "\n",
				#ligne de mise en forme du tableau pour colspan! :
				$w->Tr( { -height => '0' }, $w->td(), $w->td(), $w->td(), $w->td()),	"\n"
			), "\n";
print $w->end_form, "\n";

#--recherche par id--
print $w->div( { -class => 'banner' }, "\n", 
				$w->div( { -class => 'bannertext' }, "Search by Gene or GST" )
			),
			$w->br, "\n";
			
print $w->start_form( -method => 'POST', -action => $lkdiffid ), "\n";
print $w->table( {-width       => '90%',
							 		-border      => 0,
							 		-cellpadding => 5,
							 		-cellspacing => 0,
							 		-bgcolor     => $blanc
						 		}, "\n",
				$w->Tr( { -bgcolor => $blanc, -height => '35' }, "\n",
					$w->td( { -width=>'46%'}, 
									$w->b("Enter a Gene ID"), " (e.g. AT1G69880) ",
									$w->b("or a GST ID"),     " (e.g. CATMA1A59190)",
									$w->b(":")
					), "\n",
					$w->td( { -width=>'29%',-align => 'right'}, $w->textfield( 'idnum', '', 19, 17 ) ),
					$w->td( { -align => 'right'}, "&nbsp;"),"\n",
				), "\n",
				$w->Tr( { -bgcolor => $blanc, -height => '35' }, "\n",
					$w->td(	$w->img( {-src    => $newicon,
														-height => 20,
														-border => 0,
														-alt    => 'new!'
														}
									),
									$w->a( { -href => $lkmultiq },
										$w->b("... Query CATdb with a list of Gene or GST IDs ")
									)
					), "\n",
					$w->td( { -align => 'right' }, 
									$w->submit( -name=>'submit', -value =>'view data',
															-onClick => "doValidation('wtdiv2')"), "\n" ),
					$w->td( { -align => 'center' }, "&nbsp;" ), "\n"				
					), "\n" 
			), "\n";
			
print $w->end_form, "\n";

#--projects browser--
print $w->div( { -class => 'banner' }, "\n",
				$w->div( { -class => 'bannertext' }, "Browse $countproj projects ($listmes)" ) ),	"\n";
print $w->div( { -align => 'right', -style => "color:yellow;font-size:12px;" },
				$w->font( { -style => "background:$grisS;" },
					$w->i( $w->b(" click on numbers to view data ") )
				)
			), "\n";
print $w->table( { -width       => '100%',
									 -border      => 0,
									 -cellpadding => 1,
									 -cellspacing => 1,
									 -bgcolor     => $blanc
								 }, "\n", 
								$thline, "\n", $trline
			), $w->br,"\n";

print $w->end_html;
