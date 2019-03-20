#!/usr/local/bin/perl

=pod

=head1 NAME 

 CATdb  a Complete Arabidopsis Transcriptome database
 
=head1  SYNOPSIS

 catdb_index.pl  (programme perl-cgi)
 
=head1 DESCRIPTION

 Page d'accueil de l'interface d'interrogation/visualisation des donnees
 transcriptome issues des plates formes CATMA et AFFYMETRIX de l'URGV 
 ------------------------------------------------------------------
 Version du 13/12/2016 JPHT
 + modifiaction du texte des contacts en fin de page 
 + mise a jour des liens url
 ------------------------------------------------------------------
 Version du 12 aout 2014 VERO
 + nouveau format de la page avec GEM2Net
 + reorganistion en 2 parties principales (Arabido et OtherSpecies)
 + rajout du champ common_name dans la base pour simplifier les 2 tableaux
 + common_type= 'Arabidopsis' ou nom commun de l'organisme 'wheat, poplar...'
 -----------------------------------------------------------
 Version du 24/11/11
 + requete Stats sur nouvelle table pour meilleure performance
 -----------------------------------------------------------
 Version de 08/10
 + ajout des Chromochip en acces prive
 -----------------------------------------------------------
 Version du 28/09/09
 + encart Affymetrix
 + Approx. nb genes per Array design
 -----------------------------------------------------------
 
=cut

use Carp;
use strict qw/subs/;	#equivalent a  no strict "refs" + no strict "vars" 
use CGI qw/:standard escapeHTML/;
use Tie::IxHash;
use lib './';
use SQLCHIPS;
use CHIPS;
use consult_package;

# Activer l'autoflush de la sortie standard 
select ( ( select (STDOUT), $| = 1 ) [0] );

#--Parametres---------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $logopath  = $CHIPS::STYLEPATH;
my $public    = $CHIPS::PUBLIC; 
my $listmes   = "public";            # par defaut public
if ( $public =~ "<>" ) { $listmes = "private"; }
my $w    = new CGI;
my $subs = int( $w->param('subs') );

#couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisC = $consult_package::GRISC;
my $grisM = $consult_package::GRISM;
my $grisF = $consult_package::GRISF;
my $grisS = $consult_package::GRISS;

#--Liens-----------------------------------------------
# lien web URGV (IPS2)
my $lkurgv = $CHIPS::WIPS2;		#$CHIPS::WURGV;

# lien ftp URGV
my $lkftp = $CHIPS::FTPCATDB;

# consultation
my $lkproject = $CHIPS::CATDBPRO;
my $lkhelp    = $CHIPS::CATDBHLP;
my $lkcproj   = $CHIPS::CPROJECT;
my $lkbiblio  = $CHIPS::REFBIBLIO;
my $lkmailing = $CHIPS::MAILING;
my $staff     = $CHIPS::CATDBSTAFF;
my $access2   = $CHIPS::GEM2NETLOGOLARGE;
my $urgvsmal  = $CHIPS::URGVSMALL;
my $urgvmini  = $logopath . "urgv_mini.png";
my $catma     = $logopath . "catma_mini.png";
my $flagdb    = $logopath . "flagdb_logo.png";
my $newicon  = $CHIPS::NEWICON;

# pour OtherSpecies
my $lkotherspecies = $CHIPS::CATDBOTHERSPECIES;
# pour Chromochip
my $lkp4chip = $CHIPS::CATDBCHROMO;

# sponsors
my $lkinra  = "http://www.inra.fr/";
my $lkcnrs  = "http://www.cnrs.fr";
my $lkinapg = "http://www.agroparistech.fr/";
my $lkueve  = "http://www.univ-evry.fr";

# GEM2net
my $lkgem2net  = $CHIPS::GEM2NET;
my $image_gem2net_desc=$CHIPS::GEM2NET_DESC;

#navigateurs moz/msie:
my $datadecal = 90;
if ( ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) && ( int($1) < 7 ) ) {
	$datadecal = 0;
}

#--Variables---------------------------------------------
my ($i, $nbline, $nbarray );
my $nbibref;
my (@info, @nbgene, @nbarray, @arrays);

#--STATS de CATdb-----------------------------------------
# requete sur la nouvelle table info_catdbindex
my $reqinfo = &SQLCHIPS::do_sql (
	"Select info_code, info_value, info_name from $ppty.info_catdbindex order by info_code"
);
$nbline = $reqinfo->{NB_LINE};

# creation/tri des infos :  
for ($i=0 ; $i < $nbline ; $i++) {
	# chaque info dans tableau @info 
	if ($reqinfo->{LINES}[$i][0] =~ /^info/) {
		push(@info, $reqinfo->{LINES}[$i][1] );
	
	# chaque nbgene dans tableau @nbgene	
	} elsif ($reqinfo->{LINES}[$i][0] =~ /^nbgene/) {
		push(@nbgene, $reqinfo->{LINES}[$i][1] );
	
	#	chaque array dans tableaux @nbarray et @arrays	
	} elsif ($reqinfo->{LINES}[$i][0] =~ /^array/) {
		push(@nbarray, $reqinfo->{LINES}[$i][1]);
		push(@arrays, $reqinfo->{LINES}[$i][2]);
	}
}
$nbarray = scalar(@arrays);
undef $reqinfo;

if ( $public =~ "<>" ) {
	@info = @info[6..@info-1];	# infos privees
} else {
	@info = @info[0..5];		# infos publiques
}

# Bilan Chiffres VERO
# demander a Jph de changer info[0]= Ath et info[5]=Other species publiques
my $total_project_public_Ath=$info[0]; # Ath =CATMA + AFFY
my $total_project_public_OtherSpecies=$info[4]; # OtherSpecies
my $total_project_public=$total_project_public_Ath+$total_project_public_OtherSpecies; # Ath + Other

# Bilan Chiffres nbr de puces par especes
# pas Arabidopsis dans nouveau champ common_name d'array_type et 
# analysis_type='Arrays'
# partie requete
my $querySpecies=&SQLCHIPS::do_sql("select array_type_name, count(hybridization_id) 
from $ppty.hybridization 
where project_id in (select project_id from $ppty.project where is_public='yes') 
and experiment_id in (select experiment_id from $ppty.experiment 
where analysis_type='Arrays') 
and array_type_name in 
(select a.array_type_name from $ppty.array_type a where a.common_name<>'Arabidopsis')
group by array_type_name order by array_type_name");
my $nbspecies=$querySpecies->{NB_LINE} ;

# partie HTML table	
my ($statspecies,$statnbbyspecies);		
$statspecies = $w->td( { -width   => "20%", -bgcolor => $grisF, -style => "color:$blanc"},
								$w->b("Array design for species") );
$statnbbyspecies = $w->td( { -bgcolor => $grisF, -style => "color:$blanc"},
							  $w->b("Number of microarrays per array type") );
for (my $i=0 ; $i < $nbspecies; $i++) {
		my $species=$querySpecies->{LINES}[$i][0];
		my $nbbyspecies=$querySpecies->{LINES}[$i][1];
		$statspecies = sprintf ("%s\n%s", $statspecies, 
		 			$w->td( { -align => 'center', -bgcolor => $grisM, -width => "7%",  -style => "color:$grisS",  -nowrap },
			 		$w->b( $w->a( { -href  => "$lkcproj?array_type_name=$species", -title => "$species info" },  $species )) ) );
	  $statnbbyspecies = sprintf ("%s\n%s", $statnbbyspecies, 
	  				$w->td( { -align => 'center', -bgcolor => $grisM, -style => "color:$grisS" }, $w->b( $nbbyspecies) ));	  
}
$statspecies = $w->Tr( { -height => 18 }, $statspecies );
$statnbbyspecies  = $w->Tr( { -height => 18 }, $statnbbyspecies );

#Pour le nombre de ref biblio
my $reqstat = &SQLCHIPS::do_sql("Select count(*) from $ppty.biblio_list");
$nbibref = $reqstat->{LINES}[0][0];
undef $reqstat;

#-- TEXT --------------------------------------------------
## partie presentation de CATdb
my $query0 = "CATdb is <font color=#CC0000>a collection of Plant transcriptomic data</font>, firstly dedicated to the expression of <a href='#arab'>Arabidopsis</a> genes and then extended to <a href='#othsp'>20 other species</a>.";

my $query1 = 	sprintf (" CATdb contains data on <font color=#CC0000>%d projects (%d hybrized samples) in public access</font> out of a total of %d projects (%d hybridized samples).", $total_project_public, (2*$info[1]), $info[2], (2*$info[3]) );

my $query2 = 	"From CATdb you can access all the details of transcriptome experiments \
from experiment design with a description of each sample (plant, growth conditions, treatments) \
to statistical analyses (normalized expression data and differential analyses).";

my $queryMore = $w->a( { -href=>"$lkhelp?docInfo=CATdb_explore.txt\&title=Consult" },
							  "&gt;&gt;&nbsp;More information to explore CATdb" );
my $introMore = $w->a( { -href => "$lkhelp?docInfo=CATdb_more.txt\&title=Database" },
							  "&gt;&gt;&nbsp;More information on CATdb database" );
							  
## Partie Arabido
my $arabido = "CATdb provides access to a large collection of 
trancriptomic data for <i>Arabidopsis thaliana</i>, mainly hybridized with the 2-colors 
CATMA (Complete Arabidopsis Transcriptome Micro-Array, Crow <i>et al.</i> NAR 2003).
The CATMA design has been updated to include almost all the annotated genes in Arabidopsis (TAIR + EuGene predictions)";
						  
## partie stat des array_type
my $statarray = $w->td( { -width   => "20%", -bgcolor => $grisF, -style => "color:$blanc"},
								$w->b("Number of Arabidopsis microarrays per array type") );
my $statgene = $w->td( { -bgcolor => $grisF, -style => "color:$blanc"},
							  $w->b("Number of gene loci covered per array design ") );

for ($i = 0; $i < $nbarray; $i++) {
	my $arrayname = $arrays[$i];
	$statarray = sprintf ("%s\n%s", $statarray, 
								$w->td( { -align   => 'center',
												 -bgcolor => $grisM,
												 -width   => "10%", 
												 -style   => "color:$grisS", 
												 -nowrap
											 },
								 $w->b( $nbarray[$i] ),	"&nbsp; ",
								 $w->a( { -href  => "$lkcproj?array_type_name=$arrayname",
													-title => "$arrayname array info"
												 },  $arrayname )
	  ));
	$statgene = sprintf ("%s\n%s", $statgene, 
								$w->td( {	-align   => 'center',
													-bgcolor => $grisM,
													-style   => "color:$grisS"
												},
								$w->b( $nbgene[$i] )
	  ));
}

$statarray = $w->Tr( { -height => 18 }, $statarray );
$statgene  = $w->Tr( { -height => 18 }, $statgene );

## Partie GEM2Net
my $gem2net="GEM2Net is a new module of CATdb which the main objective is 
to provide a global overview of gene response of Arabidopsis under stress stimuli.
This approach is based on a clustering of a subset of CATdb data and explores 
various resources to annotate clusters in order to get insights into gene functions.";

## Parie Otherspecies blabla
my $otherspecies= sprintf ("CATdb stores data of %d array types to study trancriptome of various species (mainly Plants). These array designs are produced with different technologies (Affymetrix, NimbleGen, Agilent)", $nbspecies );

## Annexes FTP, biblio,  mailing list et contact
my $ftpsite = sprintf ("All Normalized and Raw data in public access can be downloaded from the FTP site:&nbsp;%s",
$w->a( { -href => $lkftp, -title => 'FTP site for CATdb data files' }, $lkftp )); 

## partie biblio
my $biblio = sprintf ("%s<br>%s", 
			$w->a( { -href => $lkbiblio, -title => 'citing CATdb' }, "&gt;&gt; How to cite CATdb?"),
			$w->a ({ -href => $lkbiblio.'#articles', -title => 'references to CATdb' }, "&gt;&gt; See the $nbibref publications related to CATdb projects..."));


## decoupage de l'adresse e-mail pour l'antispam
my ($a, $b, $c, $d, $e) = $staff =~ /^(\w+)\.(\w+)\@(\w+)\.(\w+)\.(\w+)$/;
 # + code javascript :
my ($gnet, $g1, $g2, $g3);
$g1 = sprintf (q\<script type=text/javascript>var a="%s"; var b="%s"; var c="%s"; var d="%s"; var e="%s";\, $a, $b, $c, $d, $e);
$g2 = sprintf (q\%s document.write('<a href="mailto:?to='+a+'.'+b+'@'+c+'.'+d+'.'+e+'&subject=[CATdb]">');\, $g1);  
$g3 = sprintf (q\%s document.write('<font color="#CC0000">'+a+'.'+b+'@'+c+'.'+d+'.'+e+'</font></a>');\, $g2);  
$gnet = sprintf (q\%s</script>\, $g3);  

$g3 = sprintf (q\%s document.write('<font color="white">Contact us</font></a>');\, $g2);  
my $contactUs = sprintf (q\%s</script>\, $g3);  

## partie mailing list
my $maillist = sprintf (
			"Users can join the %s to receive Email notification for new updates of CATdb (projects and tools)",
			$w->font({-color=>'#CC0000'}, "mailing list ") );
$maillist = sprintf ("%s %s\n", $maillist, $w->start_form (
									  -name     => "maillist",
									  -method   => 'POST',
									  -action   => $lkmailing,
									  -onSubmit => "return verifmail()" ) );

$maillist = sprintf (
				"%s %sEnter your Email address: &nbsp; %s &nbsp;&nbsp;%s &nbsp;&nbsp;&nbsp;&nbsp;... you will receive a confirmation Email %s<font color=#00BB00>%s", 
					$maillist, $w->br, 
					$w->textfield( -name => "emailaddr", -size => 40, -default => '' ),
					$w->submit( -name => 'SubmitEmailaddr', -value => 'Subscribe' ), 
					$w->br
					);
if ( $subs == 1 ) {
	$maillist = sprintf ("%s%sYour subscription is done, the confirmation Email is being sent", $maillist, $w->br);
} elsif ( $subs == 2 ) {
	$maillist = sprintf ("%s%sYou have already subscribe to this mailing list", $maillist, $w->br);
} elsif ( $subs == 3 ) {
	$maillist = sprintf ("%s%sProblem while subscribing, please retry or contact %s",	$maillist, $w->br, $gnet);
}
$maillist .= "</font>";

## partie contact
my $contact1 = sprintf ( "CATdb contacts: for any problems, questions or comments you can send an Email to %s", $gnet);
  
my $contact2 = sprintf ("Both %s and %s teams are, jointly to the %s, in charge of the transcriptomic facilities at IPS2, namely:", 
		$w->a({-href=>$lkurgv."/spip.php?article112", -title=>"GNet Team"}, "Genomics Networks (GNet)")	, 
		$w->a({-href=>$lkurgv."/spip.php?article200", -title=>"OGE team"}, "Organellar Gene Expression (OGE)"),
		$w->a({-href =>$lkurgv."/spip.php?article213", -title=>"POPS Transcriptomic platform"}, "POPS Transcriptomic Platform" ));

my $contact3 = "- Bioinformatics support is provided by Marie-Laure Martin-Magniette (GNet team manager), Jean Philippe Tamby and \
V&eacute;ronique Brunaud (CATdb manager)<br>- Claire Lurin (OGE team manager), Etienne Delannoy and Ludivine Soubigou-Taconnat \
(POPS platform manager) are in charge of technical and biological expertise in transcriptome analyses";

  
#--HTML---------------------------------------------------
print $w->header();
my $JSCRIPT = <<END;
var _paq = _paq || [];
/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
 _paq.push(['trackPageView']);
 _paq.push(['enableLinkTracking']);
 (function() {
	var u="//stat.di.u-psud.fr/";
	_paq.push(['setTrackerUrl', u+'piwik.php']);
	_paq.push(['setSiteId', '64']);
	var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
	g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
 })(); 

function verifmail() {
  var admail = document.maillist.emailaddr.value;
  if (admail == "") {
     alert("Please, enter an Email address");
     return false;
  } else if ((admail.indexOf("@")>0) && (admail.indexOf(".")>0)) {
     return true;
  } else {
     alert("invalid Email address, please check !");
     return false;
  }
}
END
print $w->start_html(
							 -title   => 'Welcome to CATdb',
							 -author => 'GNet',
							 -meta    => { 'keywords' => 'Plant arabidopsis' , 'robots' => 'noindex,nofollow' },
							 -style   => { -src => $stylepath },
							 -BGCOLOR => "#FFFFFF",
							 -script  => $JSCRIPT
  );

#--titre et logo--
print $w->div(
			  { -class => "entete" },
			  $w->div(
						  { -class => "entete1" },
						  $w->div(
									  { -class => "logo" },
									  $w->a(
												{ -href => $lkurgv, -title => $lkurgv },
												$w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } )
									  )
						  ),
						  $w->div(
									  { -class => "titre" },
									  "\n",
									  $w->img( { -src => $catdblogo, -alt => "CATdb" } ),
									  $w->br,
									  "\n",
									  $w->font(
													{ -size => 5, -color => "#336699" },
													$w->b( $w->i("~ Welcome ~") )
									  ),
						  ),
						  $w->div(
									  { -class => 'insert' },
									  $w->a(
												{-href        => $lkgem2net,
												  -title       => "access GEM2Net"
												 
												},
												$w->img(
															{-src    => $access2,
															  -border => 0,
															  -width  => 120,
															  -id     => "gem2net"
															}
												)
									  ),
						  )
			  ),
			  $w->br, $w->br
);

##--- Database info
#print $w->div({-align => "left", -style => "color:#FF6600;padding-top:${datadecal}px;"},"***  ".$ENV{'HOST'}." se connecte sur ".$SQLCHIPS::SERVER. " ***");
##---Message a decommenter lors des maintenances :
#print $w->div(
#	{
#		-align => "left",
#		-style => "letter-spacing:1.5px;color:#FF6600;padding-top:${datadecal}px;"
#	},
#			$w->h3($w->center($w->font( { -size => 4, -color=>"#FF0000", -style => "letter-spacing:1.1px"},
#			$w->b("Due to server maintenance, access to CATdb and GEM2Net will be interrupted on Thursday 13th December, 2018.", 
#			$w->br, "Please, accept our apologies for the inconvenience. "))
#			
#			)), $w->br
#);			
#-----------------------------------------------------------

# description tres rapide
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },
					"\n", $w->h3($query0), );
print $w->div( { -class => 'data', -style => "height:15px; background:$grisM; padding:1px 1px 20px 10px; " },
				 $w->h3($query1), );
print $w->a({-name=>'arab'}, '');
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },
				"\n", $w->h3($query2), );
# liens more info
print $w->div( { -class => 'data', -style => "padding-left:10px;"}, "\n", $w->h3($queryMore,"<br>",$introMore) );
print $w->div( { -class => 'banner' },"\n", 
					$w->div( { -class => 'bannertext' },
								"&nbsp;Explore&nbsp;",
								$w->a(
										 {	 -class => 'rfbanner',
											 -href  => $lkproject,
											 -title => "click to explore Arabidopsis projects & data"
										 },
										 "the ", $w->b($total_project_public_Ath), " Arabidopsis projects in $listmes access"
								)
					)
  ),
  $w->br;

# Tableau des differentes puces CATMA + ATH1 pour Arabido
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },
					$w->h3($arabido) );
print $w->br;
print $w->div(
					{ -class => 'data' },
					$w->table(
								  {  -border      => 0,
									  -cellpadding => 2,
									  -cellspacing => 5,
									  -bgcolor     => $blanc,
									  -width       => "90%"
								  },"\n",
								  $statarray,
								  $statgene
					)
  ),
  $w->br;

#-- Explore GEM2Net --
print $w->div(
					{ -class => 'banner' },
					$w->div(
								{ -class => 'bannertext'},
								$w->a(
										 { -class => 'rfbanner',
											 -href  => $lkgem2net,
											 -title => "click to explore GEM2Net"
										 },
								$w->img({ -src =>$newicon, -width=>'25px', -height=>'18px'}) ,
								"<span style='color:#00ffff'>&nbsp;GEM2Net</span> &nbsp;a module of CATdb to explore Arabidopsis Stress Response"
								)
					)
  );

print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },
					$w->h3($gem2net),
			$w->h3( "In CATdb, projects selected for GEM2Net are indicated by this icon &nbsp;", 
				$w->a(
						{	-href  => $lkgem2net,
							-title => "click to access GEM2Net"
						},
						$w->img(
											{-src    => $CHIPS::GEM2NETLOGO,
											  -border => 0,
											  -style => 'vertical-align: bottom;'
											}
										)
						), "... click on it to access data &amp; analyses."));

print $w->div({ -class => 'title', -align  => 'center'}, 	
				   $w->img(
							{-src    => $image_gem2net_desc,
							 -height => "220px",
							 -border => 0
							 }	)
					), $w->br;

# Explore Other Species
print $w->div( { -class => 'banner' }, $w->a({-name=>'othsp'},''),
					$w->div(
								{ -class => 'bannertext' }, "&nbsp;Explore&nbsp;",
								$w->a(
										 {	-class => 'rfbanner',
											 -href  => $lkotherspecies,
											 -title => "click to explore Other Species projects & Data"
										 },
										 sprintf ("the %s Other Species projects in %s access", 
										 				$w->b($total_project_public_OtherSpecies), $listmes)
								)
					)
  ),
  $w->br;

# Tableau des differentes puces pour Other species
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },
					$w->h3($otherspecies) );
print $w->br;
print $w->div(
					{ -class => 'data' },
					$w->table(
								  {	  -border      => 0,
									  -cellpadding => 2,
									  -cellspacing => 5,
									  -bgcolor     => $blanc,
									  -width       => "90%"
								  }, 
								  $statspecies,
								  $statnbbyspecies
					)
					
  ),
  $w->br;

#--contacts---
print $w->div( { -class => 'banner' },
					$w->a( { -name => "divers" }, ' ' ),
					$w->div( { -class => 'bannertext' }, "&nbsp;Miscellaneous: FTP site, Bibliography, Mailing list & Contacts" ) ),
  $w->br;

# Miscellenous: ftp, biblio, mailing list and contact
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },	$w->h3($ftpsite) ,$w->h3($biblio) ),
 $w->br;

# mailing list form:	
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },	$w->h3($maillist) );
print $w->br;

# contacts:
print $w->div( { -class => 'data', -style => "background:$grisC; padding:5px 10px;" },
					$w->h3($contact1), 	"\n", $w->h3($contact2),"\n", $w->h3($contact3));
print $w->br;

#--pied de page---
print $w->div( { -class => 'banner' }, "\n" );
print $w->br;
print $w->div( { -class => 'pied' },
	$w->i( { -style=>'color:#FF6600;'},
"This&nbsp;site&nbsp;is&nbsp;optimized &nbsp;for&nbsp;Mozilla&nbsp;Firefox<sup>&reg;</sup>&nbsp;or&nbsp;MS-IE<sup>&reg;</sup> 7+" ), 
    $w->br, $w->br,
 					$w->table(
								  { -align => 'center', -border => 0, -width => '90%' },
								  $w->Tr(
											 $w->td(
														{ -width => '25%' },
														$w->a(
																 { -href => $lkinra },
																 $w->img(
																			 { -src    => sprintf ("%slogoInra3.png", $logopath),  
																				-border => 0,
																				-alt    => "INRA",
																				-title => "Institut National de la Recherche Agronomique"
																			 }
																 )
														)
											 ),
											 $w->td(
														{ -width => '25%', -align => 'center' },
														$w->a(
																 { -href => $lkcnrs },
																 $w->img(
																			 { -src    => sprintf ("%slogoCnrs3.gif", $logopath),
																				-border => 0,
																				-alt    => "CNRS",
																				-title => "Centre National de la Recherche Scientifique"
																			 }
																 )
														)
											 ),
											 $w->td(
														{ -width => '25%', -align => 'center' },
														$w->a(
																 { -href => $lkinapg },
																 $w->img(
																			 { -src    => sprintf ("%slogoInapg3.gif", $logopath),
																				-border => 0,
																				-alt    => "AgroParisTech",
																				-title => "Agro-Paris-Tech"
																			 }
																 )
														)
											 ),
											 $w->td(
														{ -width => '25%', -align => 'center' },
														$w->a(
																 { -href => $lkueve },
																 $w->img(
																			 { -src    => sprintf ("%slogoEvry3.gif", $logopath),
																				-border => 0,
																				-alt    => "UEVE",
																				-title => "Universite d\'Evry - Val d\'Essonne"
																			 }
																 )
														)
											 )
								  )
					),
					
      $w->br, $w->br,
      			# tableau des mentions legales
 					$w->table( { -align => 'center', -border => 0, -width => '100%', -rules=>'none', -style=>'background-color:navy;color:white;'},
 						$w->Tr(
									$w->td(	{-width => '25%'}, "&nbsp;Copyright &copy; INRA 2007-2018" ),
									$w->td(	{-width => '25%'}, $contactUs ),
									$w->td(	{-width => '25%'}, 
										$w->a( { -style=>"color:white;decoration:none;", -href=>"$lkhelp?docInfo=CATdb_credits_en.txt\&title=Credit"}, 
													"Credits & Legal notice") ),
									$w->td(	{-width => '25%'}, 
										$w->a( {-style=>"color:white;decoration:none;", -href=>"$lkhelp?docInfo=CATdb_legal_en.txt\&title=Legal"}, 
													"Terms of use") )
						)
					)
  );
print $w->end_html;
