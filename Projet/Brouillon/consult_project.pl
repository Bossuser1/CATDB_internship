#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './'; 
use SQLCHIPS;
use CHIPS;
use consult_package;

#Variables:
#~~~~~~~~~~
my $ppty          = $CHIPS::DBname;
my $stylepath     = $CHIPS::STYLECSS;
my $catdblogo     = $CHIPS::CATDBLOGO;
my $urgvsmal      = $CHIPS::URGVSMALL;
my $legend        = $CHIPS::DSLEGEND;
my $project_id    = param('project_id');
my $experiment_id = param('experiment_id');
my $arraytype_id  = param('array_type_id');
my $arraytype_name  = param('array_type_name');
my $subtitle      = 'Project';
my $project_name  = "";

my $public = $CHIPS::PUBLIC;
#my $varReqpublic=" is_public='yes'";# pour l'instant on regarde juste ca mais
# apres on prendra une date comme reference

#Liens:
#~~~~~~
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page principale
my $lkaccueil = $CHIPS::CACCUEIL;

# HTML:
#~~~~~~~~~~~
if ( $arraytype_id ne ''  || $arraytype_name ne '' ) { $subtitle = 'Array type'; }
my $i;
my (@biblio, $nbref);
my $w = new CGI;

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
print $w->start_html(
								-title  => "CATdb $subtitle info",
								-author => 'bioinfo@evry.inra.fr',
								-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
								-BGCOLOR => "#FFFFFF",
								-style   => { -src => $stylepath },
								-script  => $JSCRIPT
			), "\n";

# entete
print $w->div( { -class => "entete" }, "\n",
				$w->div(	{ -class => "entete1" }, "\n",
					$w->div( { -class => "logo" },
						$w->a( { -href => $lkurgv }, "\n",
							$w->img( { -src    => $urgvsmal, 
												-height => "75", 
												-border => 0,
												-alt    => "IPS2"
												}
							)
						)
					),
					$w->div( { -class => "titre" },
						$w->a( { -href => $lkaccueil }, "\n",
							$w->img( { -src    => $catdblogo,
												 -border => 0,
												 -alt    => "CATdb"
												}
							)
						),
						$w->br, "\n",
						$w->font( { -size => 4, -color => '#336699' },
							$w->b( $w->i("~ $subtitle info ~") )
					 	), "\n"
					), "\n"
				), "\n"
			),
			$w->br, "\n";
print $w->br;
print $w->br;
print $w->br;
print $w->br;

if ( $project_id ne '' ) {    # on interroge par projet
	                            # si experiment_id n'est pas renseigne:
	my $req = &SQLCHIPS::do_sql(
		"select experiment_id from $ppty.experiment where project_id=$project_id and 
		project_id in (select project_id from $ppty.project where is_public $public)"
	);

	# appel de la routine:Project
	&consult_package::consult_project($project_id);
	print $w->br, "\n";

	# appel de la routine:Experiment pour chaque exp
	for ( $i = 0 ; $i < $req->{NB_LINE} ; $i++ ) {
		&consult_package::consult_experiment( $req->{LINES}[$i][0] );  
		print $w->br, "\n";
	}
	undef $req;
	
} elsif ( $project_id eq '' && $experiment_id ne '' ) {    # on interroge par experience
	# faut aller chercher le nom du project
	my $req = &SQLCHIPS::do_sql(
		"select project_id from $ppty.experiment where experiment_id=$experiment_id and 
		project_id in (select project_id from $ppty.project where is_public $public)");
		
	$project_id = $req->{LINES}[0][0];
	$project_name = &consult_package::recupdbName( "Project", $project_id );
	undef $req;
	# appel au detail de l'experience pas direct car passe par un lien
	&consult_package::consult_experiment($experiment_id);
	
} elsif ( $arraytype_id ne "" ) {
	&consult_package::consult_array_type($arraytype_id);
}	elsif ( $arraytype_name ne "" ) {
	&consult_package::consult_array_name($arraytype_name);
} else {
	# le projet n'existe pas
	print $w->h3( { -align => 'center', -style => "color:red" },
							 "**** SORRY, THE PROJECT IS NOT AVAILABLE IN THE DATABASE ****" );
}
print $w->br, "\n";
print $w->center( $w->button( -name    => 'buttonSubmitRetour',
															-value   => 'BACK',
															-onClick => "retour(this.form);"
									)
			);

print $w->end_html;
