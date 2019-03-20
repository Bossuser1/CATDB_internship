#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;
use consult_package;

#--Variables------------------------------------------------------
my $ppty          = $CHIPS::DBname;
my $stylepath     = $CHIPS::STYLECSS;
my $catdblogo     = $CHIPS::CATDBLOGO;
my $urgvsmal      = $CHIPS::URGVSMALL;
my $public        = $CHIPS::PUBLIC;
my $pval_ctf      = $CHIPS::PVALMAX;
my $w             = new CGI;
my $project_id    = param('project_id');
my $experiment_id = param('experiment_id');
my $platform_name = param('platform');	
my $replicat_id   = param('swap_id');
my $idebut        = param('idb');
my $nblimit       = 50;
my $offset  		= 0;
my $sourorg 	= "";
my $pltf = 'CATMA';		# restriction sur le type de puce

my ( $experiment_name, $project_name, $project_fname);
my ( $nbrep,           $nbtotal );
my ( $navig,           $diff_data );
my $dwnlfile;

#--Liens---------------------------------------------------------
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# page principale
my $lkaccueil = $CHIPS::CACCUEIL;
# lien catdb projects
my $lkcatdbproj = $CHIPS::CATDBPRO;
# consultation projets
my $lkproject = $CHIPS::CPROJECT;
# lien consultation experience
my $lkexpce = $CHIPS::CEXPCE;
# lien rep download data_norm
my $lkdwnld = $CHIPS::XLSPATH;
# lien pour l'aide
my $lkhelp = $CHIPS::CATDBHLP;

# images
my $query1  = $CHIPS::QUERY1;            #query1
my $query2  = $CHIPS::QUERY2;            #query2
my $imgdwd  = $CHIPS::DOWNLOAD;        #download icon
my $bulupdw = $CHIPS::BULUPDW;           #fleche de tri
my $grisS   = $consult_package::GRISS;

#navigateurs moz/msie:
my $datadecal = 220;
if ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) {
	if ( int($1) < 7 ) {
		$datadecal = 5;
	} else {
		$datadecal = 215;
	}
}


#--REQUETES------------------------------------------------------
# Platform_name list:
#my $req =
#	&SQLCHIPS::do_sql("select distinct platform_name, array_type_name from $ppty.array_type");
#@platform_name = &SQLCHIPS::get_col( $req, 0 );
#@array_type    = &SQLCHIPS::get_col( $req, 1 );
#foreach $elm (@platform_name) {
#	$H_platform{$elm} = shift @array_type;
#}

# Project_name:
#my $req = &SQLCHIPS::do_sql(
#	"select project_name from $ppty.project where project_id=$project_id and is_public $public");
my $req = &SQLCHIPS::do_sql(
	"select p.project_name from $ppty.project p, $ppty.experiment e where e.project_id=p.project_id and 
	p.project_id=$project_id and p.is_public $public and e.array_type='$pltf' and e.analysis_type = 'Arrays'");
	
if ( $req->{NB_LINE} == 0 ) {
	$project_name = "<font color=red>THIS PROJECT IS NOT AVAILABLE</font>";
} else {
	$project_name = $req->{LINES}[0][0];

	# Experiment_name:
	$experiment_name = &consult_package::recupdbName( "experiment", $experiment_id );
	if ( length($experiment_name) > 43 ) { $offset = 16; }

	# Organism/ecotype:
	$sourorg = &consult_package::recupOrganismEcotype($experiment_id);

	#--TRAITEMENTS---------------------------------------------------
	# downloadable file name :
	$dwnlfile = sprintf( "%s_exp%s.xls", &CHIPS::clean_filename($project_name), $experiment_id );

	# nb_swap, navigation bar and data :
	if ( $idebut eq '' || int($idebut) < 0 ) { $idebut = 0; }
	( $nbrep, $navig, $diff_data ) =
		&consult_package::sort_data_byswap( $project_id, $experiment_id, $replicat_id,
		int($idebut), $nblimit );
}

#--HTML------------------------------------------------------------
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

function retour(form){
    history.back();
}

END
print $w->start_html(
	-title   => 'CATdb Diff. expression',
	-author  => 'bioinfo@evry.inra.fr',
	-meta    => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
	-BGCOLOR => "#FFFFFF",
	-onload  => "MM_preloadImages($query2);",
	-onUnload => "RedoValidation ('wtdiv1');",
	-onBlur  => "RedoValidation ('wtdiv1');",
	-onfocusout => "RedoValidation ('wtdiv1');",
	-style  => { -src => $stylepath },
	-script => $JSCRIPT
	), "\n";

# entete fixe
print $w->div({ -class => "entete" },	"\n",
	$w->div({ -class => "entete1" },		"\n",
		$w->div({ -class => "logo" },
			$w->a({ -href => $lkurgv },
				$w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } )
			)
		), "\n",
		
		$w->div({ -class => "titre" }, "\n",
			$w->a({ -href => $lkaccueil },
				"\n", $w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
			),
			$w->br,	"\n",
			$w->font({ -size => 4 },
				$w->b( { -style => 'Color:#336699' }, $w->i("~ Differential expression data ~") )
			), "\n"
		), "\n",
		
		$w->div({ -class => 'insert' },	"\n",
			$w->a({ -href        => $lkcatdbproj,
							-onmouseout  => "MM_swapImgRestore()",
							-onmouseover => "MM_swapImage('NewQuery','','$query2',1)"
						},
				$w->img({	-src    => $query1,
									-border => 0,
									-width  => 84,
									-height => 60,
									-id     => "NewQuery",
									-alt    => "New Query"
								}
				)
			), "\n"
		),
	), "\n",
	$w->br,	"\n",

	$w->div({ -class => "entete2" }, "\n",
		# Project, Experiment, Organism:
		$w->div({ -class => "pinfo" }, "\n",
			$w->table({ -border => 0 },	"\n",
				$w->Tr(
					$w->td( { -valign => "top", -nowrap }, "Project:" ),
					$w->td(
						$w->font({ -size => "2" },
							$w->a({ -href => "$lkproject?project_id=$project_id" }, $w->b("$project_name"))
						)
					)
				), "\n",
				$w->Tr(
					$w->td( { -valign => "top" }, "Experiment:" ),
					$w->td(
						$w->font({ -size => "2" },
							$w->a({ -href => "$lkexpce?experiment_id=$experiment_id" },
								$w->b("$experiment_name")
							)
						)
					)
				), "\n",
				$w->Tr(
					$w->td( { -valign => "bottom" }, "Organism (ecotype):" ),
					$w->td( { -valign => "bottom" }, $w->b( $w->i($sourorg) ) )
				),"\n",
				$w->Tr( $w->td( { -colspan => 2 }, "&nbsp;" ) ),"\n",
				$w->Tr(
					$w->td( {-nowrap}, "Number of dye-swaps:" ),
					$w->td( { -valign => "bottom" }, $w->b($nbrep) )
				),"\n",
				$w->Tr( $w->td( { -colspan => 2 }, "&nbsp;" ) ), "\n",
				$w->Tr(
					$w->td({ -valign => "bottom", -colspan => 2 },
						$w->b(
							$w->a({ -href => "$lkhelp?docInfo=CATdb_statcatma.txt\&title=Statistical" },
								"More information on statistical analyses"
							)
						)
					)
				), "\n"
			), "\n"
		), "\n",

		# Intensity scale, log-ratio scale, p-value scale, missing value:
		$w->div({ -class => "iform" },
			$w->font({ -size => -2 }, "\n", 
				&consult_package::I_scale(), "\n",
				&consult_package::R_scale(), "\n", 
				&consult_package::PV_scale(), "\n"
			),
			$w->br,	"\n",
			$w->font({ -size => '1', -color => "$grisS" },
				$w->i( &consult_package::Missing_val() )), "\n",
			$w->div({-id=>"wtdiv1", -style=>"visibility:hidden;float:right;margin-top:-10px;margin-right:15px"}, 
				$w->font({-size=>4, -color=>"#FF6600"}, $w->b("Sorting ... ... please wait")))
		), "\n"
	), "\n",
	$w->br,	$w->br,
), "\n";    #fin div entete

# Body:
print $w->p("connecte a $SQLCHIPS::dbName sur $SQLCHIPS::SERVER\n<br>");


print $w->div({ -class => "corpus", -style => "padding-top:$datadecal" . "px;" },	"\n",
	$w->div({ -class => "tete", -style => "padding-left:5px;" }, "\n",

		# Download icon & text:
		$w->a({ -href => "$lkdwnld/$dwnlfile" },
			$w->img( { -src => $imgdwd, -height => 36, -border => 0, -alt => 'download' } ),
			$w->b("Download All the Data")
		),
		$w->font({ -color => $grisS },
			$w->i("(tabulated-text file compatible with MS-Excel<sup>&reg;</sup>)")
		),
		$w->br, "\n",
		$w->a({
				-href  => "$lkhelp?docInfo=CATdb_xlsmacro.txt\&title=Download",
				-style => "hover:$grisS;"
			},
			$w->b( $w->i("Download a Macro to add colors to data columns of the text file") )
		),
		$w->br,	"\n",

		# Information text:
		$w->p("Data presented have Bonferroni p-Value < $pval_ctf and are sorted by Bonferroni 
			p-Value and log<sub>2</sub>-ratio, for the first dye-swap by default",
			$w->br,
			$w->font({ -color => $grisS },
				$w->i( "click on ",
					$w->img( { -src => $bulupdw, -border => 0, -width => 12, -alt => "^" } ),
					" to sort a dye-swap by p-Value and log<sub>2</sub>-ratio"
				)
			)
		), "\n"
	), "\n",
	
	$w->div({ -class => "corps" }, "\n",

		# Nav bar & Data table:
		$w->div({ -class => "data" }, "\n", 
			$navig, "\n",
			$w->div({-id=>"wtdiv1",-style=>"position:fixed;float:right;visibility:hidden;margin-right:5px;margin-top:-18px;height:10px;color:#FF6600" }, 
							$w->font({-size=>3}, $w->b("Sorting ... ... please wait"))),"\n",
			$w->br, "\n", 
			$diff_data, "\n",
			$w->br, $navig, "\n"
		),
		$w->br,	"\n"
	), "\n",

	# bouton back:
	$w->div({ -class => "pied", -align => "center" },
		$w->button(
			-name    => 'buttonSubmitRetour',
			-value   => 'BACK',
			-onClick => "retour(this.form);"
		), "\n"
	)
), "\n";

print $w->end_html;
