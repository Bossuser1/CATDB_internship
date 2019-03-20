#!/usr/local/bin/perl

#------------------------------------------------------------------------
# Modifie le 19/08/2014 VERO
# pour le nouveau format de tableau
#
# Version du 01/09/10
# recherche par keyword en fonction de la plateforme
# specifiee : affy ou chromochip
# non specifiee : autre
#------------------------------------------------------------------------
#use Data::Dumper qw(Dumper);    #pour affichage debug
use Carp;
use strict;
use CGI qw/:standard/;
use lib './';
use SQLCHIPS;
use CHIPS;
use consult_package;

#--Variables---------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $urgvsmal  = $CHIPS::URGVSMALL;
my $gemnetlogo = $CHIPS::GEM2NETLOGO;
my $public    = $CHIPS::PUBLIC;		#"='yes'";  #JPHT: depend du serveur
my $w         = new CGI;
my $kwd       = param('kwrd');
my $platf      = "";
my $countproj   = 0;
my $countexp    = 0;
my $errmsg      = '';
my $searchtitle = "Enter a word to retreive projects:";
my $table_RESULT;

my ( $reqproj, $reqcoord, $reqbib, $reqorg );
my ( $i, $nbline, $projids, @projid, $listexp );
my ( %horgan, %hbiblio, %hgemnet );
my $oldproj = '';
my $newproj;

#couleurs du tableau
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC;
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;

#noms des colonnes CATMA et autres
my @nmtab = ( "PROJECT", "TITLE", "COORD",  "ORGAN",  "ARRAY DESIGN",
			  			"EXPERIMENT", "NORMALIZED DATA<br># SWAPS" );
#taille des cellules
my @ttd = ( "10%", "30%", "8%", "8%", "10%", "30%", "10%" );

#navigateurs moz/msie:
my $datadecal = 90;
if ( ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) && ( int($1) < 7 ) ) {
	$datadecal = 0;
}

#--Liens-----------------------------------------------
# lien PubMed
my $lkpubmed = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=";
# lien web projet GEM2Net
my $lkgem2net = $CHIPS::GEM2NET . "Profiles.php?project_id=";
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page principale
my $lkaccueil = $CHIPS::CACCUEIL;
# lien catdb projects
my $lkcatdbproj = $CHIPS::CATDBPRO;
# lien consultation projets
my $lkproject = $CHIPS::CPROJECT;
# lien consultation details experiences
my $lkexpce = $CHIPS::CEXPCE;
# consultation details experiences Affy (monocouleur)
my $lkexpaffy = $CHIPS::CEXPAFFY;
# lien consultation coordinateur
my $lkcoord = $CHIPS::COORD;
# lien consultation donnees diff
my $lkdiff = $CHIPS::CDIFF;
# lien consultation donnees par keyword
my $lkprojkw = $CHIPS::CPROJKW;
# site FTP lien VERO
my $lkftpresnorm = $CHIPS::XLSPATH;    # pour les fichiers resNorm publics

# image survolee
my $query1 = $CHIPS::QUERY1;                        #query1.png
my $query2 = $CHIPS::QUERY2;                        #query2.png
my $logolink = $w->img( { -src => $query1, -border => 0, -width => 84, -height => 60, 
											-id => "NewQuery", -alt => "New Query" } );

#--Requetes---
if ( $kwd ne '' ) {

# recherche des project_id correspondant au keyword (recherche dans tous les champs) 
# [tables concernees: project, experiment, sample_source, sample, hybridization, project_coordinator, contact]
	$reqproj = &SQLCHIPS::do_sql(
"Select project_id from $ppty.project where is_public $public and (upper(project_name) like 
	 upper('%$kwd%') or title like '%$kwd%' or upper(source) like upper('%$kwd%') or biological_interest 
	 like '%$kwd%') UNION
	 Select e.project_id from $ppty.experiment e, $ppty.project p where e.project_id = p.project_id 
	 and is_public $public and (experiment_name like '%$kwd%' or experiment_factors like '%$kwd%' 
	 or experiment_type like '%$kwd%' or upper(analysis_type) like upper('%$kwd%')) UNION
	 Select distinct h.project_id from $ppty.hybridization h, $ppty.project p where h.project_id = 
	 p.project_id and p.is_public $public and upper(h.array_type_name) like upper('%$kwd%') UNION
	 Select p.project_id from $ppty.project_coordinator pc, $ppty.contact c, $ppty.project p where 
	 c.contact_id = pc.contact_id and pc.project_id = p.project_id and p.is_public $public and 
	 upper(c.last_name) like upper('%$kwd%') UNION
	 Select distinct s.project_id from $ppty.sample s, $ppty.project p where s.project_id = p.project_id 
	 and p.is_public $public and s.organ like '%$kwd%' UNION 
	 select distinct p.project_id from $ppty.sample_source ss, $ppty.project p where p.is_public 
	 $public and p.project_id=ss.project_id and (ss.organism_id in (select organism_id from 
	 $ppty.organism where upper(organism_name) like upper('%$kwd%')) or ss.ecotype_id in 
	 (select ecotype_id from $ppty.ecotype where upper(ecotype_name) like upper('%$kwd%')) or 
	 upper(ss.sample_source_name) like upper('%$kwd%') or upper(ss.mutant_type) like 
	 upper('%$kwd%') or upper(ss.genotype) like upper('%$kwd%'))" );
	@projid = &SQLCHIPS::get_col( $reqproj, 0 );

	if ( scalar @projid != 0 ) {
		$projids = join( ",", @projid );

# projets et experiences :
# VERO : nouvelle requete pour CATMA + autre  (plateforme non specifiee)
		$reqproj =
		  "Select r.project_id, r.experiment_id, p.project_name, p.title, 
			e.array_type, e.experiment_name, count(hr.replicat_id), h.array_type_name, a.array_type_id 
			from $ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.project p, 
			$ppty.experiment e, $ppty.hybridization h, $ppty.array_type a
			where r.project_id = p.project_id and r.experiment_id = e.experiment_id 
			and p.project_id in ($projids) and p.is_public $public 
			and h.experiment_id=e.experiment_id and h.hybridization_id=hr.hybridization_id
			and a.array_type_name=h.array_type_name 
			and r.replicat_id=hr.replicat_id 
			and (r.rep_type = 'swap' or r.rep_type = 'r_swap' or r.rep_type='r_affy')
			and (hr.ref=1 or hr.ref is null)
			and e.analysis_type='Arrays' 
			group by p.project_name, e.experiment_name, p.title, e.array_type, r.project_id, r.experiment_id ,h.array_type_name, a.array_type_id 
			order by p.project_name, e.experiment_name";

		$reqproj = &SQLCHIPS::do_sql($reqproj);
		$listexp = join( ",", &SQLCHIPS::get_col( $reqproj, 1 ) );
		
		# coordinateurs :
		$reqcoord = &SQLCHIPS::do_sql(
		"Select project_id, c.contact_id, c.last_name from $ppty.project_coordinator pc, $ppty.contact c 
			where pc.contact_id=c.contact_id and project_id in ($projids) order by project_id" );

		# organe(s) pour chaque experience :
		$reqorg = &SQLCHIPS::do_sql(
		"Select distinct e.experiment_id, s.organ from $ppty.experiment e, 
		$ppty.sample s,  $ppty.project p where e.experiment_id=s.experiment_id and e.project_id=p.project_id 
		and p.is_public $public and e.experiment_id in ($listexp)" );
		$nbline = $reqorg->{NB_LINE};
		
		for ( $i = 0 ; $i < $nbline ; $i++ ) {
			if ( exists $horgan{ $reqorg->{LINES}[$i][0] } ) {
				$horgan{ $reqorg->{LINES}[$i][0] } .= sprintf( ", %s", $reqorg->{LINES}[$i][1] );
			} else {
				$horgan{ $reqorg->{LINES}[$i][0] } = $reqorg->{LINES}[$i][1];
			}
		}
		undef $reqorg;

		# article biblio associe :
		$reqbib = &SQLCHIPS::do_sql(
		"Select b.project_id, b.pubmed_id from $ppty.project_biblio b, $ppty.project p where 
			b.project_id = p.project_id and p.project_id in ($projids)" );
		$nbline = $reqbib->{NB_LINE};
		
		for ( $i = 0 ; $i < $reqbib->{NB_LINE} ; $i++ ) {
			if ( exists $hbiblio{ $reqbib->{LINES}[$i][0] } ) {
				push @{ $hbiblio{ $reqbib->{LINES}[$i][0] } }, $reqbib->{LINES}[$i][1];
			} else {
				$hbiblio{ $reqbib->{LINES}[$i][0] } = [ $reqbib->{LINES}[$i][1] ];
			}
		}

		# projet associes a GEM2Net
		$reqbib = &SQLCHIPS::do_sql(
		"Select project_id, gem2net_id from $ppty.project where gem2net_id is not null and is_public $public 
		 and project_id in ($projids)" );
		$nbline = $reqbib->{NB_LINE};
		
		for ( $i = 0 ; $i < $nbline ; $i++ ) {
			if ( exists $hgemnet{ $reqbib->{LINES}[$i][0] } ) {
				push @{ $hgemnet{ $reqbib->{LINES}[$i][0] } }, $reqbib->{LINES}[$i][1];
			} else {
				$hgemnet{ $reqbib->{LINES}[$i][0] } = [ $reqbib->{LINES}[$i][1] ];
			}
		}
		undef $reqbib;
		
#--Traitements--- 
		# VERO : uniformisation pour toute plateforme
		( $platf, $countproj, $table_RESULT ) = &table_projects( $reqproj, $reqcoord, \@nmtab );
		undef $reqproj, $reqcoord;

	} else {
		$errmsg = 'keyword not found';
	}
} else {
	$errmsg = 'Please, enter a keyword';
}


#--HTML---------------------------------------------------
print $w->header();
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
  newnd = window.open(url,nom,"status=no,toolbar=no,location=no,directories=no,menubar=no,scrollbars=yes,resizable=no,width="+wth+",height="+hht+",opener=catdb");
  newnd.window.moveBy(50,10);
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

function retour(form){
 history.back();
}

END
print $w->start_html(
		-title  => 'CATdb Search keyword',
		-author => 'bioinfo@evry.inra.fr',
		-meta =>
		  { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
		-style    => { -src => $stylepath },
		-BGCOLOR  => "#FFFFFF",
		-onload   => "MM_preloadImages($query2)",
		-onUnload => "RedoValidation ('wtdiv1');",
		-script   => $JSCRIPT
  ), "\n";

#--entete--
print $w->div( { -class => "entete" },
		$w->div( { -class => "entete1" },
			$w->div( { -class => "logo" },
					 $w->a( { -href => $lkurgv },
							$w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } ) )
				   ),
			$w->div( { -class => "titre" },
					 $w->a( { -href => $lkaccueil },
							$w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } ),
							$w->br, "\n",
							$w->font( { -size => 4 },
									  $w->b( { -style => 'Color:#336699' },
										 $w->i("~ Keyword search result ~") ) ) )
				   ), "\n",
			$w->div( { -class => 'insert', 
					  -onmouseout  => "MM_swapImgRestore()",
					  -onmouseover => "MM_swapImage('NewQuery','','$query2',1)" }, 
					  $w->a( {-onClick => "retour(this.form);" },  $logolink )
			)
		)
  ), 
  $w->br, "\n";

# larges Wait messages :
#print	&consult_package::Wait_div(	"wtdiv1","Searching ... ... please wait",
#																	"position:fixed;top:19%;background-color:#FFFFEE;" ),"\n";

#--Recherche par mot cle--
print $w->div( { -class => 'banner', -style => "padding-top:${datadecal}px;" },
			   $w->div( { -class => 'bannertext' }, "New search" )
			 ),
  $w->br, "\n";

print $w->start_form( -method => 'POST', -action => $lkprojkw );

print $w->table( { -width       => '80%',
							   -border      => 0,
							   -cellpadding => 5,
							   -cellspacing => 0,
							   -bgcolor     => $blanc
							},
	$w->Tr( { -bgcolor => $blanc, -height => '35' }, 
			$w->td( { -width => '30%' },  $w->b($searchtitle) ),
			$w->td( { -colspan => 2, -align => 'right' }, $w->textfield( 'kwrd', '', 50, 50 ) ),
			$w->td( { -width => '20%' }, "&nbsp;" )
		  ), "\n",
	$w->Tr( { -bgcolor => $blanc, -height => '35' },
		$w->td( { -colspan => 2 },
			$w->font( { -size => -2, -color => '#555555' },
				$w->i( 
				"&nbsp;search a word in Projects, Experiments, Coordinators, Array types,  Organs, Samples, Mutations, etc." ) ) ),
		$w->td( { -align => 'right', -width => '25%' },
				$w->submit( -name    => 'submit',
									-value   => 'search projects',
									-onClick => "doValidation('wtdiv1')"
						  			) ),
						  			
		#messages d'attente :
		$w->td( { -align => 'center' },
			$w->div( { -id => "wtdiv1", -style => "visibility:hidden;color:#0066CC;height:5px;text-align:center" },
				$w->b("Searching ... please wait")
			) ) 
		), 

	#ligne de mise en forme du tableau :
	$w->Tr( { -height => '0' }, $w->td(), $w->td(), $w->td(), $w->td() )
  ), "\n";

print $w->end_form, "\n";

print $w->div( { -class => 'banner' },
			   $w->div( { -class => 'bannertext' },
						$w->font( { -color => '#FFFF00' }, "\"$kwd\"" ), "&nbsp;found in $countproj project(s)" )
			 ), "\n";

if ( $errmsg eq '' ) {

	#--projects browser--
	print $w->div("&nbsp;"), "\n";
	print $table_RESULT;
	print $w->br;

} else {

	#--error message--
	print $w->br;
	print $w->div( { -align => 'center' },
				   $w->font( { -size => 4, -color => '#FF0000' }, $w->b($errmsg) ) );
}

print $w->br, "\n";
print $w->center( $w->button( -name    => 'buttonSubmitRetour',
												-value   => 'BACK',
												-onClick => "retour(this.form);" ) );
print $w->end_html;

#--Fonctions---------------------------------------------------
sub table_projects () {

	# pour toute plateforme
	my $reqprojet = shift;
	my $reqcoordi = shift;
	my $colnames  = shift;

	my ( @projid, @expid, @projn, @ptitl, @platf, @expn, @nbchip, @arraytypeName, @arraytypeId );
	my ( $i, $j, $newproj, $vpbib, $vg2n );
	my ( $affyarray, $lkplatf, $platfrm );
	my ( @coord,     $coname,  $coordin );
	my ( $entete,    $trline,  $tdline, $datatab, $dataline );
	my ( $contenu, $coulor );
	my $oldproj  = '';
	my $contproj = 0;
	my $contexp  = 0;
	my $nblin1   = $reqprojet->{NB_LINE};

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
			push @arraytypeName, $reqprojet->{LINES}[$i][7];    # VERO array_type_name
			push @arraytypeId, $reqprojet->{LINES}[$i][8];  # VERO array_type_id
		}

		# coordinateurs
		my $nblin2 = $reqcoordi->{NB_LINE};
		for ( $i = 0 ; $i < $nblin2 ; $i++ ) {
			push( @coord, $reqcoordi->{LINES}[$i] );
		}
		undef $reqprojet, $reqcoordi;

		# nom des colonnes du tableau
		$entete = &table_entete($colnames);

		# CATMA / Affy / ChIP-chip
		$platfrm = $platf[0];
		if ( $platf[ $nblin1 - 1 ] eq 'Affymetrix' ) {
			$affyarray = &array_name_id( sprintf ("'%s'", join( "','", @nbchip ) ) );
		}

		# contenu du tableau
		for ( $i = 0 ; $i < $nblin1 ; $i++ ) {
			$newproj = $projid[$i];
			
			if ( $newproj ne $oldproj ) {
				$contproj++;
				$contexp = 0;
				
				if ($tdline) {
					$datatab = $w->table( { -border  => 0,
															-cellpadding => 1,
															-cellspacing => 0,
															-width       => '100%',
															-height      => "100%",
															-bgcolor     => $blanc
														  },
										  $datatab );
					$trline .= $w->Tr( $tdline, $w->td( { -valign => 'top', -bgcolor => $grisC }, $datatab ) );
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
											$coname );
						$coordin .= $w->br;
					}
				}
				$tdline .= $w->td( { -width => $ttd[2], -valign => 'top', -bgcolor => $grisC }, $coordin );

				# insertion organ
				$tdline .= $w->td( { -width => $ttd[3], -bgcolor => $grisC, -valign => 'top' }, $horgan{ $expid[$i] } );

				# rajout colonne array_type VERO
				$tdline .= $w->td( { -width => $ttd[4], -bgcolor => $grisC, -valign => 'top' },
					$w->a( { -href => "$lkproject?array_type_id= $arraytypeId[$i]" }, $arraytypeName[$i] ) );
			}

			# experiences
			### VERO ajout du resNorm pour Affy
			my $resNormfile = sprintf( "resNorm_%s_exp%d.txt.gz", $projn[$i], $expid[$i] );
			my $resNormlnk = sprintf( "%s/%s", $lkftpresnorm, $resNormfile );    # lien public
			
			my $linkexp = $lkexpce;
			if ( $platf[$i] eq "Affymetrix" ) { $linkexp = $lkexpaffy; }

			$contexp++;
			$coulor = ( $contexp % 2 ) ? $grisC : $grisM;   #alternance couleur de ligne
			
			$dataline = $w->td( { -width => $ttd[5], -bgcolor => $coulor, -valign  => 'top' },
					   				$w->a( { -href => "$linkexp?experiment_id=$expid[$i]" }, $expn[$i] ) );

			if ( $platf[$i] eq 'CATMA' ) {
				# recuperer le #SWAPS
				$dataline .= $w->td( { -width => $ttd[6], -bgcolor => $coulor, -align => 'right', -valign => 'top' },
					$w->a( { -href => "$lkdiff?project_id=$newproj&experiment_id=$expid[$i]&platform=$platf[$i]",
						   			-onClick => "doValidation('wtdiv2')" }, $nbchip[$i] ) );
			} else {    
				# recuperer le resNorm
				$dataline .= $w->td( { -width => $ttd[6], -bgcolor => $coulor, -valign => 'top', -align => 'right' },
										$w->a( { -href => $resNormlnk }, sprintf("(%d) &nbsp;resNorm file", $nbchip[$i]) ) );
			}

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
		$contenu = $w->table( { -width    => '100%',
												 -border      => 0,
												 -cellpadding => 1,
												 -cellspacing => 1,
												 -bgcolor     => $blanc
											  }, "\n", $entete, "\n", $trline );
	}
	
	return $platfrm, $contproj, $contenu;
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
							$w->Tr( { -bgcolor => $grisF, -style   => "Color:$blanc", -height  => '25' }, $subthline ) );
	$thline .= $w->td( { -align => 'center', -width => '60%' }, $subthline );
	$thline = $w->Tr( { -bgcolor => $grisF, -style => "Color:$blanc", -height => '25' }, $thline );
	
	return $thline;
}

sub array_name_id () {
	my $listname = shift;
	my $arrays   = {};

	my $reqarray = &SQLCHIPS::do_sql(
"Select array_type_name, array_type_id from $ppty.array_type where array_type_name in ($listname)" );
	my $nbl = $reqarray->{NB_LINE};

	for ( my $i = 0 ; $i < $nbl ; $i++ ) {
		$arrays->{ $reqarray->{LINES}[$i][0] } = $reqarray->{LINES}[$i][1];
	}
	undef $reqarray;
	
	return $arrays;
}

