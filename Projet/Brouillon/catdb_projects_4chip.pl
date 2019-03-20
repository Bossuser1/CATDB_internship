#!/usr/local/bin/perl

#-----------------------------------------------------------
# Version du 29/08/10   (ChIP-chip sur ChromoChip seul)
#
# + recherche par keyword sur projets chromochip
# + liens sur logos plateformes
# - recherche par ID
# + tableau des projets uniquement ChIP-chip sur CHROMOCHIP 
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

#--Variables--------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $public    = $CHIPS::PUBLIC;
my $listmes   = "public";            # par defaut public
if ( $public =~ "<>" ) { $listmes = "private"; }
my $w         = new CGI;
my $countproj = 0;
my $countexp  = 0;
my $platf = 'Chromochip';
my $typanalyse = 'ChIP-chip';
my $bansuff = '';

my ( $projreq, $reqproj, $reqcoord, $reqorg, $reqbib );
my ( %hbiblio, %horgan );
my ( $i, $nbline);
my ( $tableau_CATMA, $rplatf);

#couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC;
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;
my $grisS = $consult_package::GRISS;

#tableau :
#noms des colonnes
my @nmtab = ("PROJECT", "TITLE", "COORD", "ORGANS", "EXPERIMENT", "# SWAPS"); 
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
# projets catma
my $lkpcatma = $CHIPS::CATDBPRO;
# projets affy
my $lkpaffy = $CHIPS::CATDBAFFY;
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
my $affx    = $CHIPS::STYLEPATH."affy_mini.png";
my $catma = $CHIPS::STYLEPATH."catmaurgv.jpg";
# image loading
my $loading = $CHIPS::STYLEPATH."loading.gif";
#$w->img({-id=>"mydiv",-src=>$loading, -width=>120, -height=>90, -border=>0, -alt=>"Loading... please wait"})

#--PROJECT BROWSER------------------------------------
# CHROMOCHIP----
#--Requetes---
# projets et experiences avec nb de swaps :
$projreq = "Select r.project_id, r.experiment_id, p.project_name, p.title, e.array_type, e.experiment_name, 
count(hr.replicat_id) from $ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.project p, $ppty.experiment e 
where r.project_id = p.project_id and r.experiment_id=e.experiment_id and p.is_public $public 
and e.array_type='$platf' and e.analysis_type = '$typanalyse'
and r.replicat_id=hr.replicat_id and (r.rep_type = 'swap' or r.rep_type = 'r_swap') and hr.ref = 1 
group by p.project_name, e.experiment_name, p.title, e.array_type, r.project_id, r.experiment_id 
order by p.project_name, e.experiment_name";
$reqproj = &SQLCHIPS::do_sql($projreq);

# coordinateurs :
$reqcoord = &SQLCHIPS::do_sql(
	"Select pc.project_id, c.contact_id, c.last_name from $ppty.project_coordinator pc, 
	$ppty.contact c where pc.contact_id = c.contact_id and pc.project_id in (select project_id 
	from $ppty.experiment where array_type='$platf' and analysis_type = '$typanalyse') 
	order by pc.project_id, c.last_name"
);

# organe(s) pour chaque experience
$reqorg =&SQLCHIPS::do_sql(
	"Select distinct e.experiment_id, s.organ from $ppty.experiment e, $ppty.sample s, $ppty.project p 
	where e.experiment_id=s.experiment_id and e.project_id=p.project_id and p.is_public $public and 
	e.array_type = '$platf' and e.analysis_type = '$typanalyse'"
);
$nbline = $reqorg->{NB_LINE};
for ($i=0;$i<$nbline;$i++) {
	if (exists $horgan{$reqorg->{LINES}[$i][0]} ) {
		$horgan{$reqorg->{LINES}[$i][0]} .= sprintf(", %s", $reqorg->{LINES}[$i][1]) ;
	} else {
		$horgan{$reqorg->{LINES}[$i][0]} = $reqorg->{LINES}[$i][1];
	}
}
undef $reqorg;

# article(s) biblio associe :
$reqbib = &SQLCHIPS::do_sql(
	"Select b.project_id, b.pubmed_id from $ppty.project_biblio b, $ppty.project p where 
	b.project_id = p.project_id and p.is_public $public"
);
$nbline = $reqbib->{NB_LINE};
for ( $i = 0 ; $i < $nbline ; $i++ ) {
	if ( exists $hbiblio{$reqbib->{LINES}[$i][0]}) {
		push @{$hbiblio{$reqbib->{LINES}[$i][0]}}, $reqbib->{LINES}[$i][1];
	} else {
		$hbiblio{$reqbib->{LINES}[$i][0]} = [$reqbib->{LINES}[$i][1]];
	}
}
undef $reqbib;

#--Traitements---
($rplatf, $countproj, $tableau_CATMA)  = &table_projects($reqproj, $reqcoord, \@nmtab);
undef $reqproj, $reqcoord;
if ($rplatf ne '') { $platf = $rplatf  }

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

print $w->start_html(	-title   => sprintf ("CATdb %s Projects", ucfirst($typanalyse)),
											-author  => 'bioinfo@evry.inra.fr',
											-meta    => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
											-head => [meta({-http_equiv=>'Pragma',-content=>'no-cache'}),
																meta({-http_equiv=>'Cache-Control', -content=>'no-cache, must-revalidate'}),
																meta({-http_equiv=>'Expires', -content=>'0'})
																],
											-style   => { -src => $stylepath },
											-onUnload  => "RedoValidation ('wtdiv1'); RedoValidation ('wtdiv2');",
											-BGCOLOR => "#FFFFFF",
											-script  => $JSCRIPT
			), "\n";

#--entete--
print $w->div( { -class => "entete1" }, "\n",
				$w->div( { -class => "logo" },
					$w->a( { -href => $lkurgv },
						$w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } )
					), $w->br,
					$w->div({-class => "circlediv"}, $w->h3({-style=>"color:blue"}, $w->b("ChIP-chip")) )
				), "\n",
				$w->div( { -class => "titre" },
					$w->a( { -href => $lkaccueil },
						$w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
					), "\n",
					$w->br,	"\n",
					$w->font(	{ -size => 4 },
						$w->b( { -style => 'Color:#336699' },
							$w->i("~ Search & Consult ~")
						)
					), "\n"
				), "\n",
				$w->div( { -class => "insert" }, 
					$w->table(
						$w->Tr( $w->td({-nowrap}, $w->font({-size=>"-1", -style=>'Color:#336699;'}, 
															$w->i("see projects on other<br>plateforms:")))
						),
						$w->Tr( $w->td( $w->a( {-href=>$lkpcatma},
						 									$w->img({-src=>$catma, -border=>0, -alt=>"CATMA", -height=>'30',
						 										-title=>"CATMA projects at URGV"} )))
						),
						$w->Tr( $w->td( $w->a( {-href=>$lkpaffy},
						 									$w->img({-src=>$affx, -border=>0, -alt=>"Affymetrix", -height=>'30',
						 										-title=>"Affymetrix projects at IPS2"} )))
						)
					)
			  ), "\n"
			), "\n",
			$w->br, $w->br,"\n";

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
$bansuff = $w->font({-size=>-1}, "(among $typanalyse projects)");
print $w->div( { -class => 'banner' }, "\n", 
				$w->div( { -class => 'bannertext' }, "Search by keyword $bansuff" )
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
					$w->td( { -colspan => 2 }, $w->b("Enter a word to search among <i>$typanalyse ($platf)</i> projects:")), "\n",
				 	$w->td( { -width => '30%', -align => 'right'}, $w->textfield( 'kwrd', '', 50, 50 ) ),"\n",
				 	$w->td( { -width => '20%' }, "&nbsp;", $w->hidden('platform', $platf), 
				 																	$w->hidden('typanalyse', $typanalyse)), "\n"
				), "\n",
				$w->Tr( { -bgcolor => $blanc, -height => '35' }, "\n",
					$w->td(	{ -colspan => 2 },
						$w->font(	{ -size => -2, -color => $grisS },
							$w->i("&nbsp;search a word in Projects, Experiments, Coordinators, Array types, Organs, Mutations, etc..."	)
						)
					), "\n",
					$w->td(	{ -align => 'right', -width => '25%' },
						$w->submit( -name=>'submit', -value=>'search projects', -onClick=>"doValidation('wtdiv1')"), "\n"
					),"\n",
					$w->td( { -align => 'center' },  $w->div({ -id=>"wtdiv1", -style=>"visibility:hidden;color:#0066CC;height:5px;text-align:center"},
											$w->b("Searching ... please wait"))), "\n"
				), "\n",
				#ligne de mise en forme du tableau pour colspan! :
				$w->Tr( { -height => '0' }, $w->td(), $w->td(), $w->td(), $w->td()),	"\n"
			), "\n";
print $w->end_form, "\n";

#--projects browser Table--
print $w->div( { -class => 'banner' }, "\n",
				$w->div( { -class => 'bannertext' }, "Browse $countproj $typanalyse ($platf) projects ($listmes)" ) ),	"\n";
print $w->div( { -align => 'right', -style => "color:yellow;font-size:12px;" },
				$w->font( { -style => "background:$grisS;" },
					$w->i( $w->b(" click on numbers to view data ") )
				)
			), "\n";
print $tableau_CATMA;
print $w->br,"\n";
	
print $w->end_html;


#--Fonctions---------------------------------------------------
sub table_projects () {
	# pour ChIP-chip
	my $reqprojet = shift;
	my $reqcoordi = shift;
	my $colnames = shift;
	
	my ($i, $j, $newproj, $vpbib);
	my (@coord, $coname, $coordin, $coulor);
	my ($entete, $trline, $tdline, $datatab, $dataline);
	my $oldproj = '';
	my $contproj = 0;
	my $contexp  = 0;
	my $nblin1  = $reqprojet->{NB_LINE};

	if ( $nblin1 != 0 ) {
		# projets
		my @projid  = &SQLCHIPS::get_col( $reqprojet, 0 );
		my @expid   = &SQLCHIPS::get_col( $reqprojet, 1 );
		my @projn   = &SQLCHIPS::get_col( $reqprojet, 2 );
		my @ptitl   = &SQLCHIPS::get_col( $reqprojet, 3 );
		my @platf   = &SQLCHIPS::get_col( $reqprojet, 4 );
		my @expn    = &SQLCHIPS::get_col( $reqprojet, 5 );
		my @nbchip  = &SQLCHIPS::get_col( $reqprojet, 6 );	
		
		# coordinateurs
		my $nblin2 = $reqcoordi->{NB_LINE};
		for ( $i = 0 ; $i < $nblin2 ; $i++ ) {
			push( @coord, $reqcoordi->{LINES}[$i] );
		}
		undef $reqprojet, $reqcoordi;
		
		# nom des colonnes du tableau
		$entete = &table_entete ($colnames);
		
		# contenu du tableau
		for ( $i = 0 ; $i < $nblin1 ; $i++ ) {
			$newproj = $projid[$i];
			if ( $newproj ne $oldproj ) {
				$contproj++;
				$contexp = 0;
				if ($tdline) {
					$datatab = $w->table( { -border      => 0,
																	-cellpadding => 1,
																	-cellspacing => 0,
																	-width       => '100%',
																	-height      => "100%",
																	-bgcolor     => $blanc
																},
																$datatab ) . "\n";
					$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, 
											$datatab )) . "\n";
					$datatab = '';
				}
				$tdline = $w->td( { -width => $ttd[0], -valign => 'top', -bgcolor => $grisC, -nowrap },
										$w->a({-href=>"$lkproject?project_id=$newproj"}, 
													$projn[$i] ) ). "\n";
				# insertion biblio
				if ( exists $hbiblio{$newproj} ) {
					$vpbib = $w->i("<br>Pubmed #&nbsp;");
					foreach (@{$hbiblio{$newproj}}) {
						$vpbib .= $w->a({-href=>$lkpubmed.$_, -target=>'_blank'}, $w->i("&nbsp;$_"));
					}
				} else {
					$vpbib = '';
				}				
				$tdline .= $w->td( { -width => $ttd[1], -valign => 'top', -bgcolor => $grisC }, 
											$ptitl[$i], $vpbib) . "\n";
				# insertion coordinateur(s)
				$coordin = '';
				for ( $j = 0 ; $j < $nblin2 ; $j++ ) {
					if ( $coord[$j][0] eq $newproj ) {
						$coname = ucfirst(lc($coord[$j][2]));
						$coordin .= $w->a( {-href =>"javascript:openwdw('$lkcoord?contact_id=$coord[$j][1]','coord',400,170)"},
												$coname	);
						$coordin .= $w->br;
					}
				}
				$tdline .= $w->td( { -width => $ttd[2], -valign => 'top', -bgcolor => $grisC }, 
										$coordin ) . "\n";
			}
			# experiences
			$contexp++;
			$coulor = ( $contexp % 2 ) ? $grisC : $grisM;    #alternance couleur de ligne
			$dataline =	$w->td( {-width=>$ttd[3], -bgcolor=>$coulor, -valign=>'top'}, $horgan{$expid[$i]} )."\n";
			$dataline .= $w->td( { -width => $ttd[4], -bgcolor => $coulor, -valign => 'top', -align=>'left' },
											$w->a( { -href => "$lkexpce?experiment_id=$expid[$i]" }, $expn[$i] ) )	. "\n";
			$dataline .= $w->td( { -width => $ttd[5], -bgcolor => $coulor, -align => 'right', -valign => 'top' },
				$w->a({ -href => "$lkexpce?experiment_id=$expid[$i]#datatar", -onClick => "doValidation('wtdiv2')" }, 
									$nbchip[$i] ) )	. "\n";
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
													$datatab )."\n";
		$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, 
								$datatab))."\n";
	
		# affichage
		my $contenu = $w->table( { -width       => '100%',
																 -border      => 0,
																 -cellpadding => 1,
																 -cellspacing => 1,
																 -bgcolor     => $blanc
															 	}, "\n", 
															$entete, "\n", $trline )."\n";
										
		return  $platf[0], $contproj, $contenu;	
	}
}

sub table_entete () {
	my $nmtab = shift;  	# pointeur sur tableau des noms de colonne  
	my $nbcol = scalar @$nmtab;
	my ($i, $thline, $subthline);
		
	# noms des colonnes
	for ( $i = 0 ; $i < $nbcol ; $i++ ) {
		if ($i < 3 ) {
			$thline .= $w->td( { -width => $ttd[$i], -align => 'center' },
												 $w->b( $$nmtab[$i] ) );			
		} else {
			$subthline .= $w->td( { -width => $ttd[$i], -align => 'center' },
														$w->b( $$nmtab[$i] ) );
		}
	}
	$subthline = $w->table( {	-border      => 0,
														-width       => '100%',
														-height      => "100%",
														-cellpadding => 0,
														-cellspacing => 0,
														-bgcolor     => $blanc },
											$w->Tr( { -bgcolor => $grisF,
																-style   => "Color:$blanc",
																-height  => '25' },
															$subthline )
								)	. "\n";
	$thline .= $w->td( { -align => 'center', -width => '45%' }, $subthline );
	$thline =	$w->Tr( { -bgcolor => $grisF, -style => "Color:$blanc", -height => '25' }, "\n", 
										$thline )	. "\n";
	return $thline;
}

