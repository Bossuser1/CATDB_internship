#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb 
use CHIPS;
use consult_diff;

#--Constantes---------------------------------------------
my $ppty      = $CHIPS::DBname;              # "chips"
my $tblspace  = $CHIPS::TMP_TBLSPACE;   # "chips_tmp"
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $urgvsmal  = $CHIPS::URGVSMALL;

#--Email catdbstaff
my $staff = $CHIPS::CATDBSTAFF;

#--Parametres---------------------------------------------
my $chptri = param('chptri');
my $idnum  = uc( param('idnum') );
my $radio = param('totaldiff');
$idnum =~ s/\ //g;
my $tmptable = '"TMP_' . $idnum.'"';
my $pgtmptable = 'TMP_' . $idnum;
 
my %optiontri = (
	'0' => 'p.project_name, e.experiment_name',
	'1' => 'e.experiment_name, p.project_name',
	'3' => 't.cy3_organ, t.cy5_organ, p.project_name, e.experiment_name',
	'7' => 't.log_ratio, p.project_name, e.experiment_name',
	'8' => 't.bonf_p_value, p.project_name, e.experiment_name'
);

#--Liens------------------------------------------------
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page principale
my $lkaccueil = $CHIPS::CACCUEIL;
# lien catdb projects
my $lkcatdbproj = $CHIPS::CATDBPRO;
# lien info sequence
my $lkseqinfo = $CHIPS::SEQINF;
# lien pour l'aide
my $lkhelp = $CHIPS::CATDBHLP;

#--Affichage---------------------------------------------
# images survolees
my $query1  = $CHIPS::QUERY1;     #query1
my $query2  = $CHIPS::QUERY2;     #query2
my $bulupdw = $CHIPS::BULUPDW;  #fleche de tri

# couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisS = $consult_package::GRISS;

#--Test navigateurs moz/msie-------------------------------
my $datadecal = 280;
if ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) {
	if ( int($1) < 7 ) {
		$datadecal = 5;
	} else {
		$datadecal = 255;
	}
}

#--Variables------------------------------------------------
my $w = new CGI;

my ( $errmsg,  $errsql );
my ( $sousreq, $typid, $typasso );
my ( $nblin,  $nbproj, $nbexp );
my ( @asso,  $resultat);
my ( @projid, @expid, @repid, @projn, @expn, @platf );
my ( @org3, @org5, @repn, @iref, @ismp, @rval, @pval );
my $listasso;
my $lrmax = 3;
my ( $updw, $thline);
my ($soustitre, $backbutton);

#--MAIN------------------------------------------------------
# Controle de l'identifiant
if ( &consult_diff::isGene_ID($idnum) ) {
	# c'est un code AGI...
	$sousreq = "Select s.spot_id from $ppty.spot_gene sg, $ppty.spot s where \
	sg.spotted_sequence_id=s.spotted_seq_id and sg.gene_name = '$idnum'";
	$typid   = "Gene ID";
	$typasso = "probe(s)";

} elsif ( &consult_diff::isGST_ID($idnum) ) {
	# c'est un id CATMA...
	$sousreq = "Select s.spot_id from $ppty.spotted_sequence ss, $ppty.spot s where \
	ss.spotted_sequence_id=s.spotted_seq_id and ss.seq_name = '$idnum'";
	$typid   = "GST ID";
	$typasso = "locus(i)";

} else {
	# identifiant invalide
	$typid  = "Query ID";
	$nblin  = 0;
	$nbproj = 0;
	$nbexp  = 0;
	$errmsg = "Gene or GST ID unknown !";
}

if ( !$errmsg ) {
	# Controles d'existence dans tablespace et dans Visite
	if (!&CHIPS::exist_table($pgtmptable, $tblspace) && &consult_diff::existVisite($tmptable)) {
		&consult_diff::deleteVisite($tmptable);
	} 
	elsif (&CHIPS::exist_table($pgtmptable, $tblspace) && !&consult_diff::existVisite($tmptable)) {
		&consult_diff::dropTmp_table ($tmptable);
	}
	
	# Creation de la table temporaire
	if (!&CHIPS::exist_table($pgtmptable, $tblspace)) {
		# c'est une nouvelle table...
		if ( !( $errsql = &consult_diff::createTmp_table( $tmptable, $sousreq ) ) ) {
			# creation ok
			if (&consult_diff::checkTmp_Data($tmptable) > 0) {
				# il y a des data... on complete
				if (! ($errsql = &consult_diff::fillTmp_table($tmptable))) {
					# + insertion dans visite
					&consult_diff::insertVisite($tmptable);
				} else {
					# erreur de creation/completion
					&consult_diff::dropTmp_table($tmptable);
					$nblin  = 0;
					$nbproj = 0;
					$nbexp  = 0;
					$errmsg =
				  	"Sorry, the data are not accessible (system full), please retry later."
						. $w->br
						. $w->font({ -size => '-1' },
						"An e-mail has already been sent to the administrator to fix the problem. Feel free to ask any question by e-mailing to "
						. $w->a( { -href => "mailto:$staff" },"<span style=\"color: rgb(204, 0, 0);\">$staff</span>" ));
				}
			} else {
				# la table creee est vide
				&consult_diff::dropTmp_table($tmptable);
				$nblin  = 0;
				$nbproj = 0;
				$nbexp  = 0;			
				$errmsg = "Sorry, no data for this $typid !";
			}
		} else {
				# erreur de creation
				$nblin  = 0;
				$nbproj = 0;
				$nbexp  = 0;			
				$errmsg = "Sorry, the data are not accessible, please retry later." . $w->br. $w->font({ -size => '-1' },
						"An e-mail has been sent to the administrator at "
						. $w->a( { -href => "mailto:$staff" },"<span style=\"color: rgb(204, 0, 0);\">$staff</span>" ));
			
		}
	
		# Si erreur : envoie mail d'erreur + positionne flag
		if ($errsql) {
			if (&consult_diff::getWarnmail() == 0) {
				&consult_diff::setWarnmail();
			}
		} else {
			# reinitialise flag
			&consult_diff::resetWarnmail();
		}
		
	} else {
		&consult_diff::updateVisite($tmptable);
	} ### fin si ! existe pg_table 
	
	# Selection des donnees
	if (! $errsql && ! $errmsg) {
		# nombre de projets et experiences
		($nbproj, $nbexp) = &consult_diff::countTmp_Data ($tmptable);
		if ($nbproj == 0) {
			# les donnees existent mais ne sont pas disponibles  (ex: pas publiques)
			$nblin  = 0;
			$errmsg = "Sorry, the data are not accessible for this $typid !";
			# et on supprime la table...
			&consult_diff::dropTmp_table($tmptable);
			&consult_diff::deleteVisite($tmptable);
		} else {
			# selection/recuperation des donnees
			if ( $chptri eq "" ) { $chptri = '0'; }
			if ($radio eq '2') {
				$resultat = &consult_diff::selectDiff_Tmp_Data($tmptable, $optiontri{$chptri}); # seulement les results diff 
			} else {
				$resultat = &consult_diff::selectTmp_Data($tmptable, $optiontri{$chptri});			# tous les results
			}
			$nblin  = $resultat->{NB_LINE};
	
			# liste des id associes
			@asso = &consult_diff::getRelated_ID( $idnum, $typid );
			for (my $i = 0 ; $i < scalar @asso ; $i++ ) {
				$listasso .= $w->a( { -href => "$lkseqinfo?ident=$asso[$i]" }, $w->b("$asso[$i]") );
				$listasso .= ", ";
			}
			$listasso = substr( $listasso, 0, length($listasso) - 2 );
		}
	} 
} ### fin si ! errmsg

#--HTML------------------------------------------------------------
# back button form:
$backbutton = $w->start_form( -action => "$lkcatdbproj" );
$backbutton .= $w->submit( -name => 'buttonSubmitRetour', -value => 'BACK' );
$backbutton .= $w->end_form;

print $w->header();
my $JSCRIPT = <<END;
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
END

print $w->start_html(
					-title   => 'CATdb Diff id',
					-author  => 'bioinfo@evry.inra.fr',
					-meta    => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
					-BGCOLOR => "#FFFFFF",
					-onload  => "MM_preloadImages($query2);",
					-style   => { -src => $stylepath },
					-script  => $JSCRIPT
			),"\n";

# entete fixe
if ($radio eq '2') { $soustitre = "~ Differential gene expression data ~"; }
else { $soustitre = "~ Gene expression data ~"; }

print $w->div({ -class => "entete" },"\n",
				$w->div({ -class => "entete1" },"\n",
					$w->div({ -class => "logo" },
						$w->a({ -href => $lkurgv },
							$w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } )
						)
					),"\n",
					$w->div({ -class => "titre" },
						$w->a({ -href => $lkaccueil },
							$w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
						),
						$w->br,	"\n",
						$w->font({ -size => 4 },
							$w->b( { -style => 'Color:#336699' }, $w->i($soustitre) )
						),"\n"
					),"\n",
					$w->div({ -class => 'insert' },
						$w->a({	-href  => $lkcatdbproj,
										-onmouseout  => "MM_swapImgRestore()",
										-onmouseover => "MM_swapImage('NewQuery','','$query2',1)"	},
							$w->img({	-src  => $query1,
												-border => 0,
												-width  => 84,
												-height => 60,
												-id     => "NewQuery",
												-alt    => "New Query" }
							)
						),
					),"\n"
				),"\n",   ### fin entete1
				$w->br, "\n",
				$w->div({ -class => "entete2" },"\n",
					$w->div({ -class => "pinfo" },
						$w->br,	"\n",
						$w->table({ -border => 0 },	"\n",					
							$w->Tr(
								$w->td({ -align => 'left' }, $typid,":" ),
								$w->td(
									$w->font({ -size => 3 },"\n", 
										$w->a({ -href => "$lkseqinfo?ident=$idnum" },"\n", $w->b($idnum) )
									)
								)
							),"\n",
							$w->Tr(
								$w->td({ -align => 'left', -valign => 'top' }, "associated $typasso:" ),
								$w->td({ -valign => 'top' }, "\n $listasso" )
							),"\n",
							$w->Tr(
								$w->td( { -colspan => 2 }, "&nbsp;" )
							),"\n",
							$w->Tr(
								$w->td({ -colspan => 2, -align => 'left', -nowrap }, "found in: ",
									$w->b($nbproj), "&nbsp;projects, &nbsp;",
									$w->b($nbexp),  "&nbsp;experiments, &nbsp;",
									$w->b($nblin),  "&nbsp;dye-swaps"	)
							),"\n",
							$w->Tr(
								$w->td({ -colspan => 2 }, "&nbsp;" )
							),"\n",
							$w->Tr(
								$w->td({ -colspan => 2, -align => 'left', -nowrap },
									$w->b(
										$w->a({ -href => "$lkhelp?docInfo=CATdb_statcatma.txt\&title=Statistical" },
														"More information on statistical analyses" )
									)
								)
							),"\n"
						),"\n"
					),"\n",
					$w->div({ -class => "iform" },
						$w->font({ -size => -2 }, &consult_package::I_scale(),"\n",
										 &consult_package::R_scale($lrmax),"\n",
										 &consult_package::PV_scale(),"\n"
						)
					),"\n"
				),   ### fin entete2
				$w->br,"\n",
				$w->div({ -class => "tete", -style => "padding-left:2px;" },"\n",
					$w->font({ -size => -4, -color => $grisS },"\n",
						$w->table({ -border => 0, -height => 8, -width => "100%" },"\n",
							$w->Tr(
								$w->td({ -width => '52%' },
									$w->i("&nbsp;click on ",
										$w->img({ -src 	=> $bulupdw,
															-border => 0,
															-height => 6,
															-width  => 12,
															-alt    => "^" }
										),	" to sort"
									)
								),"\n",
								$w->td({ -align => 'left' }, $w->i( &consult_package::Missing_val() ) )
							)
						),"\n"
					),"\n",
					$w->table({	-width       => "100%",
											-border      => 0,
											-bgcolor     => $blanc,
											-cellpadding => 0,
											-cellspacing => 2 },"\n",
										 ${&consult_diff::displayTmp_Coln ($idnum,4,$resultat,$radio)}, "\n" 
					),"\n"
				),"\n"  ### fin div tete
			),"\n";    ### fin entete fixe

if ( !$errmsg ) {
	# data:
	print $w->div({ -class => "corpus", -style => "padding-top:" . $datadecal . "px;" }, "\n",
					$w->div({ -class => "tete" },	"\n",
						$w->table({	-width       => "100%",
												-border      => 0,
												-bgcolor     => $blanc,
												-rules       => "rows",
												-cellpadding => 1,
												-cellspacing => 2
											}, "\n",
											${&consult_diff::displayTmp_Data($lrmax,$resultat)}
						), "\n"
					),
					$w->br, "\n",
					$w->div({ -class => "pied", -align => "center" }, "\n", $backbutton ), "\n"
				), "\n";
} else {
	# error message:
	print $w->div({ -class => "corpus", -style => "padding-top:" . $datadecal . "px;" }, "\n",
					$w->div({ -class => "tete" }, "\n",
						$w->font({ -size => "+1", -color => "red" }, "\n", $w->b("&nbsp;&nbsp; $errmsg") ) 
					),
					$w->br, "\n",
					$w->div({ -class => "pied", -align => "center" }, "\n", $backbutton ), "\n"
				), "\n";
}

print $w->end_html;
