#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use Tie::IxHash;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use CHIPS;
use SQLCHIPS;
use consult_package;

#--Liens---------------------------------------------------------
# lien web URGV
my $lkurgv = $CHIPS::WURGV;
# lien page principale
my $lkaccueil = $CHIPS::CACCUEIL;
# lien catdb projects
my $lkcatdbproj = $CHIPS::CATDBPRO;
# lien consultation projets
my $lkproject = $CHIPS::CPROJECT;
# lien consultation experience
my $lkexpce = $CHIPS::CEXPCE;
# lien info sequence
my $lkinfo = $CHIPS::SEQINF;
# lien pour l'aide
my $lkhelp = $CHIPS::CATDBHLP;
# image survolee
my $query1 = $CHIPS::QUERY1;      #query1
my $query2 = $CHIPS::QUERY2;      #query2
my $imgdwd = $CHIPS::DOWNLOAD;    #download icon

#--Variables------------------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $archpath  = $CHIPS::CATDBTEMP;
my $dwldpath  = $CHIPS::TEMPLINK;
my $public    = $CHIPS::PUBLIC;
my $catdblogo = $CHIPS::CATDBLOGO;
my $urgvsmal  = $CHIPS::URGVSMALL;
my $typefeat  = "'GST','CHLORO','MITO'";
my $limite    = 100;
my $w         = new CGI;
my $idlist    = $w->param('idents');
my $idfhd     = $w->upload('ID_file');

my ( %listidents, @listidents, $listidents, $nbident );
tie %listidents, "Tie::IxHash";
my ( %spotIdents, @spotseqId, $listspotseqId, $spsqid );
my ( %repID, $listrepId, $rid );     # @repId
my ( $j, $nbline );
my $nbproj = 0;
my $nbexp  = 0;
my $nbswap = 0;
my $nbdata = 0;
my $nbgene = 0;
my ( $spid, $repid, $pval );
my ( $errmsg,    $libelle );
my ( @IDnotfnd,  $Idnotfnd, $Txtnotfnd );
my ( @replicaId, @projectId, @experimId );
my ( @replicaNa, @projectNa, @experimNa );
my %diff_data;
my %prob_name;
my %gene_name;
my ( $probeN, $geneN );
my ( $ctswap, $ctexp, $oldprojid, $oldexpid, $oldexpna, $oldprojna );
my ( $key0,      $key1,      $key2 );
my ( $lrt,       $pvl,       $coulor );
my ( $tdline,    $dataline,  $trdata, $donnees );
my ( $jstab_pro, $jstab_exp, $jstab_rep, $jstab_png );
my $back;
my $flnpro = "\tProjects:";
my $flnexp = "\tExperiments:";
my $flnswp = "\tdye-swaps:";
my $flncol = "GST ID\tGene ID";
my ( $fdata, $datafile, $filemsg );

#couleurs du tableau :
my $blanc = $consult_package::BLANC;
my $grisF = $consult_package::GRISF;
my $grisM = $consult_package::GRISM;
my $grisC = $consult_package::GRISC;
my $grisS = $consult_package::GRISS;
#couleur texte info :
my $cinfo = $grisC;  #"#FFFF99";

#navigateurs moz/msie:
my $popdecal  = 118;
my $datadecal = 355;
my $posit = 'relative';
if ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) {
	if ( int($1) < 7 ) {
		$popdecal  = 12;
		$datadecal = 40;
	} else {
		$popdecal = 130;  # au lieu de 128
		$posit = 'absolute';
	}
}


#--CONTROLES------------------------------------------------------
if ( $idlist eq '' && $idfhd eq '' ) {
	#formulaire vide
	$errmsg  = "&nbsp;";
	$libelle = 'Enter a list of Gene or GST IDs:';
	$nbident = '';
} else {
	$libelle = 'IDs in the query list:';
	if ( $idlist ne '' ) {
		# liste manuelle
		@listidents = split( '\n|,|;', $idlist );
	} elsif ($idfhd) {
		# fichier
		@listidents = <$idfhd>;
	}

	# construction de la liste des id, limitee a $limite (maximum 100)
	if ( scalar(@listidents) > $limite ) { @listidents = @listidents[ 0 .. $limite - 1 ]; }
	map { s/\s|\r//g } @listidents;
	@listidents = map { uc } @listidents;
	# liste sans doublon et sans ligne vide :
	foreach $rid (@listidents) {
		if ( $rid ne '' ) { $listidents{$rid} = $rid; }
	}
	$listidents = "'" . join( "','", ( keys %listidents ) ) . "'";
	$nbident = scalar( keys %listidents );
	$w->delete('idents');

	#--REQUETES------------------------------------------------------
	#1. verification des id dans la base (quelque soit l'identifiant)
	# et recup spotted_sequence_id:
	#-- pour les AGI:
	my $requete = &SQLCHIPS::do_sql(
		"select sg.spotted_sequence_id, sg.gene_name from $ppty.spot_gene sg, 
  $ppty.spotted_sequence ss where sg.spotted_sequence_id=ss.spotted_sequence_id and type_feat 
  in ($typefeat) and sg.GENE_NAME in ($listidents)"
	);
	$nbline = $requete->{NB_LINE};
	if ( $nbline == 0 ) {
		#-- pour les CATMA:
		$requete = &SQLCHIPS::do_sql(
			"Select spotted_sequence_id, seq_name from $ppty.spotted_sequence 
    where type_feat in ($typefeat) and SEQ_NAME in ($listidents)" );
		$nbline = $requete->{NB_LINE};
	}

	if ( $nbline > 0 ) {
		# liste des spotted_seq_id verifiee
		for ( $j = 0 ; $j < $nbline ; $j++ ) {
			$spsqid = $requete->{LINES}[$j][0];
			${ $spotIdents{ $requete->{LINES}[$j][1] } }{$spsqid} = $spsqid;
			push (@spotseqId, $spsqid);
		}
		$listspotseqId = join( ",", @spotseqId );    # liste valide
		undef $requete;
		
		#2. recuperation des donnees
		my $reqdata = &SQLCHIPS::do_sql(
			"Select s.spotted_seq_id, daf.replicat_id, daf.log_ratio, 
    daf.bonf_p_value from $ppty.diff_analysis_value daf, $ppty.spot s where daf.spot_id = 
    s.spot_id and s.spotted_seq_id in ($listspotseqId)"
		);

		$nbline = $reqdata->{NB_LINE};
		for ( $j = 0 ; $j < $nbline ; $j++ ) {
			$spid  = $reqdata->{LINES}[$j][0];
			$repid = $reqdata->{LINES}[$j][1];
			$pval  = $reqdata->{LINES}[$j][3];
			if ( $pval ne '' ) { $pval = sprintf( "%.0E", $pval ); }
			${ $diff_data{$spid} }{$repid} = sprintf( "%.3f,%s", $reqdata->{LINES}[$j][2], $pval );
			$repID{$repid} = 0;
		}
		$listrepId = join( ",", sort ( keys %repID ) );  # liste ordonnees sans doublon
		undef(%repID);		
		undef $reqdata;

		#3. recuperation des infos replicat, experiment, project
		my $reqinforep = &SQLCHIPS::do_sql(
			"Select r.replicat_id, p.project_id, e.experiment_id, r.replicat_extracts, 
    p.project_name, e.experiment_name from $ppty.replicats r, $ppty.project p, 
    $ppty.experiment e where r.project_id = p.project_id and r.experiment_id = 
    e.experiment_id and p.is_public $public and r.replicat_id in ($listrepId) order by 
    p.project_name, e.experiment_name, r.replicat_extracts"
		);
		$nbswap = $reqinforep->{NB_LINE};
		for ( $j = 0 ; $j < $nbswap ; $j++ ) {
			push( @replicaId, $reqinforep->{LINES}[$j][0] );
			push( @projectId, $reqinforep->{LINES}[$j][1] );
			push( @experimId, $reqinforep->{LINES}[$j][2] );
			push( @replicaNa, $reqinforep->{LINES}[$j][3] );
			push( @projectNa, $reqinforep->{LINES}[$j][4] );
			push( @experimNa, $reqinforep->{LINES}[$j][5] );
		}
		undef $reqinforep;

		#4. correspondance des noms sonde/gene
		my $reqseqgen = &SQLCHIPS::do_sql(
			"select distinct ss.spotted_sequence_id, ss.SEQ_NAME, sg.GENE_NAME from $ppty.spot s, 
			$ppty.spotted_sequence ss, $ppty.spot_gene sg where ss.spotted_sequence_id = 
			sg.spotted_sequence_id and ss.spotted_sequence_id=s.spotted_seq_id and 
			ss.spotted_sequence_id in ($listspotseqId) and s.control_id in (0,2,3,6)"
		);
		$nbline = $reqseqgen->{NB_LINE};
		for ( $j = 0 ; $j < $nbline ; $j++ ) {
			$prob_name{ $reqseqgen->{LINES}[$j][0] } = $reqseqgen->{LINES}[$j][1];
			$gene_name{ $reqseqgen->{LINES}[$j][0] } = $reqseqgen->{LINES}[$j][2];
		}
		undef $reqseqgen;

		#--MISE EN FORME--------------------------------------------------
		# Noms des colonnes
		#~~~~~~~~~~~~~~~~~~
		for ( $j = 0 ; $j < scalar(@projectId) ; $j++ ) {
			$coulor = ( $nbexp % 2 ) ? $grisC : $grisM;    #alternance couleur
			
			if ( $experimId[$j] != $oldexpid && $oldexpid ne '' ) {
				# ecrire experience precedente :
				$tdline .= $w->td({	 -colspan => "$ctswap",
														 -bgcolor => "$coulor",
														 -class   => "event,$oldprojid,$oldexpid,$ctswap"
													 },
													 $w->div("&nbsp;")
					)	. "\n";
				$jstab_exp .= "jsexp['$oldexpid']='$oldexpna';";    # tableau des experiments en js
				$flnexp .= sprintf( "\t%s%s", $oldexpna, "\t" x ( 2 * $ctswap - 1 ) );   # experiments en txt tabule
				$nbexp++;
				$ctexp += $ctswap;
				$ctswap = 0;
				
				if ( $projectId[$j] != $oldprojid && $oldprojid ne '' ) {
					# compter projet :
					$jstab_pro .= "jspro['$oldprojid']='$oldprojna';";    # tableau des projects en js
					$flnpro .= sprintf( "\t%s%s", $oldprojna, "\t" x ( 2 * $ctexp - 1 ) );  # projects en txt tabule
					$nbproj++;
					$ctexp = 0;
				}
			}

			# compter swap :
			$flnswp .= sprintf( "\t%s\t", $replicaNa[$j] ); # swaps en txt tabule
			$flncol .= "\tR\tP-VAL";    										# intitule colonne en txt tabule
			$ctswap++;
			$oldexpid  = $experimId[$j];
			$oldexpna  = $experimNa[$j];
			$oldprojid = $projectId[$j];
			$oldprojna = $projectNa[$j];
		}

		# ecrire dernier experience/projet
		$tdline .= $w->td({	 -colspan => "$ctswap",
												 -bgcolor => "$coulor",
												 -class   => "event,$oldprojid,$oldexpid,$ctswap"
											 },
											 $w->div("&nbsp;")
			)	. "\n";
		$jstab_exp .= "jsexp['$oldexpid']='$oldexpna';";      # tableau des experiments en js
		$jstab_pro .= "jspro['$oldprojid']='$oldprojna';";    # tableau des projects en js
		$ctexp += $ctswap;
		$flnexp .= sprintf( "\t%s%s", $oldexpna, "\t" x ( 2 * $ctswap - 1 ) );   # experiments en txt tabule
		$flnpro .= sprintf( "\t%s%s", $oldprojna, "\t" x ( 2 * $ctexp - 1 ) );   # projects en txt tabule
		$nbexp++;
		$nbproj++;

		# ecrire intitules   largeur col CATMA_ID = 67px, largeur col GENE_ID = 58px
		$tdline = $w->td( { -bgcolor => "$grisF", -style => "Color:$grisS;font-size:10px" },
											$w->b("GST ID") )
			. $w->td( { -bgcolor => "$grisF", -style => "Color:$grisS;font-size:10px" },
								$w->b("GENE ID") )
			. "\n"
			. $tdline;

		# Noms des sondes & data
		#~~~~~~~~~~~~~~~~~~~~~~~
		foreach $key0 ( keys %listidents ) {    #key0 est un nom de sonde/gene dans l'ordre saisi
			if ( !exists( $spotIdents{$key0} ) ) {
				push( @IDnotfnd, $key0 );           # memorisation des ID not found
			} else {
				foreach $key1 ( keys %{ $spotIdents{$key0} } ) {    #key1 est un spotted_seq_id
					                                                  # ecrire noms sonde & gene
					$probeN   = $prob_name{$key1};
					$geneN    = $gene_name{$key1};
					$dataline = $w->td( { -bgcolor => "$blanc", -style => "font-size:9px" },
															$w->a( { -href => "$lkinfo?ident=$probeN", -target =>'_blank' }, $probeN ) );
					$dataline .= $w->td( { -bgcolor => "$blanc", -style => "font-size:10px" },
															 $w->a( { -href => "$lkinfo?ident=$geneN", -target =>'_blank' }, $geneN ) )
						. "\n";
					$jstab_png .= "jspng['$probeN']='$geneN';";        # tableau des sondes/genes en js
					$fdata .= sprintf( "%s\t%s", $probeN, $geneN );    # noms sonde & gene en txt tabule
					$nbdata++;

					# ecrire une case couleur correspondant au log-ratio pour le swap
					for ( $j = 0 ; $j < scalar(@replicaId) ; $j++ ) {
						$key2 = $replicaId[$j];                              #key2 est un replicat_id
						$jstab_rep .= "jsrep['$key2']='$replicaNa[$j]';";    #tableau des swaps en js
						$oldexpid  = $experimId[$j];
						$oldprojid = $projectId[$j];
						if ( exists( ${ $diff_data{$key1} }{$key2} ) ) {
							( $lrt, $pvl ) = split( ',', ${ $diff_data{$key1} }{$key2} );
							if ( $pvl ne '' ) {
								$dataline .= $w->td({  -bgcolor => &consult_package::R_bgcolor( $pvl, $lrt ),
																			 -class => "event,$oldprojid,$oldexpid,0,$key2,$lrt,$pvl"
																		 }, ' '
								);
							} else {
								#...case vide
								$dataline .= $w->td({	 -bgcolor => &consult_package::R_bgcolor( '', '' ),
																			 -class   => "event,$oldprojid,$oldexpid,0,$key2"
																		 }, ' '
								);
							}
							$fdata .= sprintf( "\t%.3f\t%s", $lrt, $pvl );    # lgratio & pval en txt tabule
						}
					}
					$trdata .= $w->Tr( { -onMouseOver => "pbn='$probeN'" }, $dataline ) . "\n";
					$fdata .= "\n";
				}
			}
		}
		$donnees = $w->table({	-bgcolor     => "#000",
														-border      => "0",
														-rules       => 'all',
														-bordercolor => "#000",
														-cellspacing => 1,
														-cellpadding => 1,
														-style       => "text-align:center;font-size:6px;"
													}, "\n",
													$w->Tr($tdline),
													"\n", $trdata
			)	. "\n";

		# Liste des not found:
		$nbgene = scalar( keys %spotIdents );
		if ( scalar(@IDnotfnd) > 0 ) {
			$Txtnotfnd = "See the list of Ids not found at the bottom of the page";
			$Idnotfnd = join( ', ', @IDnotfnd );
			if ( $Idnotfnd ne '' ) {
				$Idnotfnd = $w->b( scalar(@IDnotfnd) ) . " ID(s) not found: " . $w->b($Idnotfnd);
			}
		}

		# Generation du fichier txt tabule:
		$datafile = sprintf( "GED_%s.txt", $$ );
		open( DATAFILE, '>', "$archpath$datafile" );
		if ( -f "$archpath$datafile" ) {
			print DATAFILE $flnpro, "\n", $flnexp, "\n", $flnswp, "\n", $flncol, "\n", $fdata;
			$filemsg = $w->img({-src => $imgdwd, -height => 32, -border => 0, -alt => 'download'} );
			$filemsg = $w->a( { -href => "$dwldpath$datafile" },
								$filemsg,
								" Download these results as a tabulated-text file (rigth click and save...)" );
		} else {
			$filemsg = '';
		}
		close DATAFILE;
	} else {
		# Pas de donnees
		$errmsg = "No data for this list of IDs";
	}
}

#Liste des identifiants de l'utilisateur:
$listidents =~ s/,/\n/g;
$listidents =~ s/'//g;

# back button form:
$back = $w->start_form( -action => "$lkcatdbproj" );
$back .= $w->submit( -name => 'buttonSubmitRetour', -value => 'BACK to Projects' );
$back .= $w->end_form;

#--HTML-----------------------------------------------------------
print $w->header();
my $JSCRIPT = <<END;

function retour (form) {
    history.back();
}

function vidlist () {
    document.forms["idform"].idents.value="";
    document.forms["idform"].ID_file.value="";
}

var waitStyle=null
function doValidation (thediv) {
	waitStyle = document.getElementById(thediv).style;
	bulleStyle= document.getElementById('ftip').style;
	dataStyle = document.getElementById('mydata').style;
	if (waitStyle) {
		waitStyle.visibility="visible";
		bulleStyle.visibility="hidden";
		dataStyle.visibility="hidden";
	}	
}
function RedoValidation (thediv) {
	waitStyle = document.getElementById(thediv).style;
	if (waitStyle) {
		waitStyle.visibility="hidden";
	}
}

var dataStyle=null
var bulleStyle=null
if (!document.layers && !document.all && !document.getElementById)
   event="chut";  //pour apaiser NN3 et autres antiquites

function fbulle(msg,evt,hauteur){
 var xfenetre,yfenetre,xpage,ypage,element=null;
 if (!hauteur) hauteur=80; // hauteur par defaut

  if (document.layers) {
     bulleStyle=document.layers['ftip'];
     bulleStyle.document.write('<layer bgColor="#ffd" '
       +'style="width:150px;border:1px solid black;color:#000">'
       + msg + '</layer>' );
     bulleStyle.document.close();
  } else if (document.all) {
     element=document.all['ftip']
  } else if (document.getElementById) {
     element=document.getElementById('ftip')
  }

  xpage = 50 ; ypage  = 250;

  if (element) {
     bulleStyle=element.style;
     element.innerHTML=msg;
  }
	
  if (bulleStyle) {
     bulleStyle.visibility="visible";
  }
}

document.onmouseover = MouseOver;

function MouseOver(evt) {
  evt = evt || event;
  var target = evt.target || evt.srcElement;
  if (target.nodeName == 'TD' || target.nodeName == 'td') {
    tabClass = target.className.split(',');

    if (tabClass[1]) {
      b(tabClass[0],""+tabClass[1],""+tabClass[2],tabClass[3],tabClass[4],tabClass[5],tabClass[6]);
    }
  }
}

var pbn
var jspro=new Array;
var jsexp=new Array;
var jsrep=new Array;
var jspng=new Array;
	
END
$JSCRIPT .= $jstab_pro . "\n";
$JSCRIPT .= $jstab_exp . "\n";
$JSCRIPT .= $jstab_rep . "\n";
$JSCRIPT .= $jstab_png . "\n";
$JSCRIPT .= "function b(evt, pid, eid, nbsw, rid, rt, pv) {
  msg = 'project: <a href=$lkproject?project_id='+pid+' target=_blank><b>'+jspro[pid]
       +'</b></a> &nbsp; experiment: <a href=$lkexpce?experiment_id='+eid+' target=_blank><b>'
       +jsexp[eid]+'</b></a>';
  if (nbsw > 0) {
     msg = msg +'&nbsp;&nbsp;<b>'+nbsw+'</b> dye-swaps';
  }
  if (rid) {
     msg = msg +' &nbsp; dye-swap: <a href=$lkexpce?experiment_id='+eid+'#'+rid+' target=_blank><b>'
     		+jsrep[rid]+'</b></a><br><a href=$lkinfo?ident='+pbn+' target=_blank><b>'+pbn+'</b></a> &nbsp; '
        +'<a href=$lkinfo?ident='+jspng[pbn]+' target=_blank><b>'+jspng[pbn]+'</b></a> &nbsp;&nbsp; ';
     if (rt) {
         msg = msg +'R: <b>'+rt+'</b> &nbsp; P-VAL: <b>'+pv+'</b>';
     } else {
         msg = msg +'<i>no data</i>';
     }
  }
  fbulle (msg, evt);
}";

print $w->start_html( -title  => 'CATdb multigene query',
											-author => 'bioinfo@evry.inra.fr',
											-meta   => { 'keywords' => 'CATdb', 'robots' => 'noindex,nofollow' },
											-style   => { -src => $stylepath },
											-onUnload => "RedoValidation ('wtdiv')",
											-onBlur  => "RedoValidation ('wtdiv')",
											-onfocusout => "RedoValidation ('wtdiv')",
											-BGCOLOR => "#FFFFFF",											
											-script  => $JSCRIPT
);

# entete fixe
print $w->div({ -class => "entete" }, "\n",
	$w->div({ -class => "entete1" }, "\n",
					 $w->div({ -class => "logo" },
										$w->a({ -href => $lkurgv },
													 $w->img( { -src => $urgvsmal, -height => "75", -border => 0, -alt => "IPS2" } )
										)
					 ), "\n",
					 $w->div({ -class => "titre" }, "\n",
										$w->a({ -href => $lkaccueil }, "\n",
													 $w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
										),
										$w->br, "\n",
										$w->font({ -size => 4, -color => '#336699' },
															$w->b( $w->i("~ Gene expression data ~"), $w->br, "NEW TEST VERSION" )
										), "\n"
					 ), "\n",
	), "\n",
	$w->br, "\n",
	$w->div({ -class => "entete2" }, "\n",
		$w->start_multipart_form( -method => 'POST', -name => "idform" ), "\n",

		# ID list & file form:
		$w->div({ -class => "pinfo" }, "\n",
						 $w->b($nbident, $libelle),
						 $w->br, "\n",
						 $w->textarea( -class => "idents",
													 -name  => "idents",
													 -value => $listidents
						 ),
						 $w->br, "\n",
						 $w->b("or select a text file containing IDs:"),
						 $w->br, "\n",
						 $w->filefield( -name => 'ID_file', -size => 40, -lang => "en" ), "\n",
						 $w->br, "\n",
						 $w->font({  -color => "#BB0000",
												 -size  => '-1',
												 -style => "font-weight:bold;"
											 },
											 "Note: you can enter up to 100 Gene or GST IDs, one per line"
						 ),
						 $w->br,
						 $w->br, "\n", "&nbsp; &nbsp;",
						 $w->button( -name => "Reset", -onClick => "javascript:vidlist()" ), "&nbsp;",
						 $w->submit( -class => "submitID",
												 -name  => 'SubmitListID',
												 -value => 'Submit to CATdb...',
												 -onClick => "doValidation('wtdiv')"
						 ), "\n", "\n"
		),
		$w->end_form, "\n",

		# Log-ratio scale, missing value, download, infos:
		$w->div({ -class => "iform" },
						 $w->br, "\n", &consult_package::R_scale(),
						 $w->br, "\n",
						 $w->font( { -color => $grisS }, $w->i( &consult_package::Missing_val() ) ),
						 $w->br, $w->br, "\n", 
						 $filemsg,
						 $w->br, $w->br, "\n",
						 $w->font({ -color => "$grisS", -size => '2', -style => "background:$cinfo" },
											 $w->b($nbgene),
											 " IDs found in ",
											 $w->b($nbproj),
											 " projects, ",
											 $w->b($nbexp),
											 " experiments, ",
											 $w->b($nbswap),
											 " dye-swaps"
						 ),
						 $w->br, "\n",
						 $w->font( { -color => $grisS }, $Txtnotfnd ), "\n"
		)
	), "\n",
	
	# Wait message: 
	&consult_package::Wait_div("wtdiv","Loading ... ... please wait"),"\n",

	# Info-bulle display: 
	$w->div({ -class => "tete", -style => "position:$posit; height:43px; margin-top:$popdecal"."px;" },
					 $w->div( { -class => "ftip", -id => "ftip"},
					 					"Sorry, unable to display info" ), "\n"
	), "\n"
), "\n";    #fin div entete
	

if ( $errmsg ne '' ) {
	# Erreur:
	print $w->div({ -id=>"mydata", -class => "corpus", -style => "top:$datadecal" . "px;" }, "\n",
								 $w->font( { -color => 'red', -size => '+1' }, $w->b($errmsg) ), "\n",
								 $w->br, $w->br, "\n",
								 $w->div( { -align => "center" }, $back )
		), "\n";
} else {
	# Data:
	print $w->div({ -id=>"mydata", -class => "corpus", -style => "top:$datadecal" . "px;" }, "\n",

		$w->font({ -color => $grisS, -style => "font-size:10px;" },
"&nbsp;&nbsp;>> move mouse over the table to see information about projects, experiments, dye-swaps or values",
			$w->br,
			$w->i(
"&nbsp;&nbsp;cells of the first line are as large as the number of dye-swaps of the experiment is high"
			)
		), "\n", $donnees, "\n",
		$w->p("Nb of lines: $nbdata"), "\n",
		$w->br, "\n",
		$w->font( { -color => $grisS }, $Idnotfnd ),
		$w->br, "\n",
		$w->div( { -align => "center" }, $back )
		), "\n";
}
print $w->end_html;
