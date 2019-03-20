#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';    
use SQLCHIPS;
use CHIPS;

# Pour lire les fichier de documentations ou aides
# en argument le nom du fichier d'aide a trouve
# Le fichier TXT est en fait du HTML pour la mise en forme
# la 1ere ligne du fichier doit etre le titre qui apparait
# dans la baniere
#--Variables---------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $logopath  = $CHIPS::STYLEPATH;
my $staff		= $CHIPS::CATDBSTAFF;
my $adleg		= $CHIPS::ADLEGAL;
my $w         = new CGI;

my ( $reqstat, $i );
my ( @arrtyp,  @nbarr, @arraytab );
my ( $nbpp,    $nbph );
my ( $nbtp,    $nbth );               

#--Liens-----------------------------------------------
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page d'accueil
my $lkaccueil = $CHIPS::CACCUEIL;
# lien table project
my $lkproject = $CHIPS::CATDBPRO;
# logo urgv
my $urgvsmal = $CHIPS::URGVSMALL;

#--adresse Email decoupee-----------------------------------------
my ($a, $b, $c, $d, $e) = $staff =~ /^(\w+)\.(\w+)\@(\w+)\.(\w+)\.(\w+)$/;
my $gnet = sprintf (q\<script type=text/javascript>var a="%s"; var b="%s"; var c="%s"; var d="%s"; var e="%s";\, $a, $b, $c, $d, $e);
$gnet = sprintf (q\%s document.write('<a href="mailto:?to='+a+'.'+b+'@'+c+'.'+d+'.'+e+'&subject=[CATdb]">');\, $gnet);  
$gnet = sprintf (q\%s document.write('<font color="#CC0000">'+a+'.'+b+'@'+c+'.'+d+'.'+e+'</font></a>');\, $gnet);  
$gnet = sprintf (q\%s</script>\, $gnet);  

my ($a, $b, $c) = $adleg =~ /^(.+)@(.+)\.(.+)$/;	
my $legal = sprintf (q\<script type=text/javascript>var a="%s"; var b="%s"; var c="%s"; \, $a, $b, $c);
$legal = sprintf (q\%s document.write('<a href="mailto:'+a+'@'+b+'.'+c+'"><font color="#0000CC">' +a+'@'+b+'.'+c+'</font></a>');\, $legal);  
$legal = sprintf (q\%s</script>\, $legal);  

#--- RECUPERATION DU TEXT ----------------------------
my $file = sprintf ("%s%s",  $CHIPS::CATDBSTYLEPATH, $w->param("docInfo"));

# le titre est mis dans la 1er ligne du fichier TXT
my $text = "";
open( IN, $file );
my $title = <IN>;
while (<IN>) {
	if ($_ =~ /\$/) {
		$text .= eval($_);
	} else {
		$text .= $_;
	}
}
close(IN);

#--HTML---------------------------------------------------
print $w->header();
my $JSCRIPT = <<END;
function openwdw(url,nom,wth,hht){
  newnd = window.open(url,nom,"width="+wth+",height="+hht+",toolbar=no,location=no,directories=no,statusbar=no,menubar=no,scrollbars=no,resizable=yes,navigationbar=no,personal=no,opener=catdb");
  newnd.window.moveBy(-50,10);
}

function retour(form){
    history.back();
}

END
print $w->start_html(
								-title  => 'CATdb Help',
								-author => 'GNet',
								-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
								-style   => { -src => $stylepath },
								-BGCOLOR => "#FFFFFF",
								-script  => $JSCRIPT
	), "\n";

#--titre et logo--
print $w->div( { -class => "entete1" }, 
							 $w->div(	{ -class => "logo" },
												$w->a( { -href => $lkurgv },
															 $w->img({ -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" }
															 )
												)
							 ), 
							 $w->div( { -class => "titre" },
												$w->a( { -href => $lkaccueil },
															 $w->img({ -src => $catdblogo, -border => 0, -alt => "CATdb" }
															 )
												),
												$w->br, 
												$w->font({ -size => 4 },
														$w->b( { -style => 'Color:#336699' }, $w->i("~ More Info ~") )
												),
							 ), 
							 $w->div( { -class => "insert" }, " " )
			);
print $w->br, $w->br;

#--description--
print $w->div( { -class => 'banner' }, 
				$w->div( { -class => 'bannertext' }, $title ) ),	$w->br;
print $w->div( { -class => 'data' }, $w->h3($text) );
print $w->br, $w->br;
print $w->div( { -class => "pied", -align => "center" },
							 $w->button(
													 -name    => 'buttonSubmitRetour',
													 -value   => 'BACK',
													 -onClick => "retour(this.form);"
							 )
);
print $w->end_html;
