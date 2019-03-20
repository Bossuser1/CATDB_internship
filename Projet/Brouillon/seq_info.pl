#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use Tie::IxHash;
use lib './';
use SQLCHIPS;
use CHIPS;
use consult_package;

#Variables:
#~~~~~~~~~~
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $urgvsmal  = $CHIPS::URGVSMALL;
my $w         = new CGI;
my $ident    = param('ident');

my ($requete1, $requete2);
my (@spotseqId, $nbspotseq, $listspotseqId);
my (@name, @altername, @primer3, @primer5, @seq, @type, @qualprobe, @genename, @qualgene);
my (@idvers, @navers);
my ($i, $j );

# pour l'annotation des genes
my %probegene;
my %probeannot;
my %probearray;
my %genesource;
my %geneproduct;
# type de sonde a exclure
my $lstexclus = "'ChromoChip','CATMA_v6'";

# message
my $mesgene = "no gene";
my $messeq  = "no sequence";
my $message = "";
my $gst_legend = '';

#Liens:
#~~~~~~
# lien page principale
my $lkaccueil = $CHIPS::CACCUEIL;
# lien vers consult_project.pl pour array-type
my $consproj = $CHIPS::CPROJECT."?array_type_id=";
# lien CATdb help
my $lkhelp = $CHIPS::CATDBHLP;
# lien position GST
my $lkgstpos = $CHIPS::POSGST; 
#my $GSTtype = $CHIPS::GSTLEGEND; 
# liens autres databases
my $lkflagdb   = "http://" . $CHIPS::SERVER . "/projects/FLAGdb++/Appli/FLAGdbV2.jnlp";
my $tairlogo   = $CHIPS::STYLEPATH . "/tair_logo.gif";
my $flagdblogo = $CHIPS::STYLEPATH . "/flagdb_logo.png";
my $ncbilogo   = $CHIPS::STYLEPATH . "/ncbi_logo.gif";

#navigateurs moz/msie:
my $datadecal = 80;
if ( ( $ENV{"HTTP_USER_AGENT"} =~ /MSIE (\d)./ ) && ( int($1) < 7 ) ) {
	$datadecal = 5;
}

#Requetes:
#~~~~~~~~~
# soit un identifiant de sonde, soit de gene
# on va chercher le ou les spotted_sequences associes quelque soit l'identifiant
#my $requete=&SQLCHIPS::do_sql("select distinct spotted_sequence_id from $ppty.spotted_sequence where SEQ_NAME='$ident' or OTHER_NAME='$ident' or spotted_sequence_id in (select spotted_sequence_id from $ppty.spot_gene where GENE_NAME='$ident')");
# plus rapide
$requete1 =	&SQLCHIPS::do_sql(
	"select spotted_sequence_id from $ppty.spotted_sequence where SEQ_NAME='$ident' or 
	OTHER_NAME='$ident' UNION select spotted_sequence_id from $ppty.spot_gene where GENE_NAME='$ident'"
	);
$nbspotseq = $requete1->{NB_LINE};   #scalar(@spotseqId);

if ( $nbspotseq == 0 ) { 
	$message = "the query ID does not exist in the database !";
} else {
	# on continue les recherches par les genes
	@spotseqId = &SQLCHIPS::get_col( $requete1, 0 );
	$listspotseqId = join( ",", @spotseqId );
	
	# on exclut certains types de sonde 
	$requete1 = &SQLCHIPS::do_sql(
		"select distinct ss.seq_name, ss.other_name, sp.sequence3, sp.sequence5, ss.sequences, 
		ss.type_feat from $ppty.spotted_sequence ss left outer join $ppty.spotted_primer sp on 
		(ss.spotted_sequence_id=sp.spotted_sequence_id) where ss.spotted_sequence_id in ($listspotseqId) 
		and ss.type_feat not in ($lstexclus)"
		);
	$nbspotseq = $requete1->{NB_LINE};   
	@name      = &SQLCHIPS::get_col( $requete1, 0 );
	@altername = &SQLCHIPS::get_col( $requete1, 1 );
	@primer3   = &SQLCHIPS::get_col( $requete1, 2 );    # 3'seq
	@primer5   = &SQLCHIPS::get_col( $requete1, 3 );    # 5'seq
	@seq       = &SQLCHIPS::get_col( $requete1, 4 );    # 5'sequence
	@type      = &SQLCHIPS::get_col( $requete1, 5 );    # type_feat
	undef $requete1;
	
	# pour chaque sonde....
	for ( $i = 0 ; $i < $nbspotseq ; $i++ ) {
		# on va chercher les info sur les genes
		$requete2 = &SQLCHIPS::do_sql(
			"select distinct g.gene_name, g.GENE_PRODUCT, g.ANNOT_SOURCE from $ppty.spot_gene sg, 
			$ppty.annotation_gene g where sg.spotted_sequence_id=$spotseqId[$i] and sg.gene_id=g.gene_id"
			);
		for ( $j = 0 ; $j < $requete2->{NB_LINE} ; $j++ ) {
			$geneproduct{ $requete2->{LINES}[$j][0] } = $requete2->{LINES}[$j][1];
			$genesource{ $requete2->{LINES}[$j][0] }  = $requete2->{LINES}[$j][2];
			$probegene{ $name[$i] } .= " " . $requete2->{LINES}[$j][0];
		}

		# on va chercher les info sur les sondes 
		$requete2 = &SQLCHIPS::do_sql(
			"select distinct type_qual, qualifier from $ppty.annotation_spot where spotted_sequence_id=$spotseqId[$i]"
			);
		$probeannot{ $name[$i] } = "";
		for ( $j = 0 ; $j < $requete2->{NB_LINE} ; $j++ ) {
			$probeannot{ $name[$i] } =
				  $probeannot{ $name[$i] }
				. $w->a( { -href => "#GSTlegend" }, $requete2->{LINES}[$j][0] ) . " : "
				. $requete2->{LINES}[$j][1]
				. $w->br;
		}
		
		# on va chercher les versions de puces sur lesquelles se trouve le spot
		$requete2 = &SQLCHIPS::do_sql(
			"Select s.array_type_id, a.array_type_name from $ppty.array_type a, $ppty.spot s where 
			a.array_type_id =	s.array_type_id and s.spotted_seq_id=$spotseqId[$i] order by 
			a.array_type_name"
			);
		@idvers = &SQLCHIPS::get_col($requete2, 0);
		@navers = &SQLCHIPS::get_col($requete2, 1);
		for ( $j = 0 ; $j < $requete2->{NB_LINE} ; $j++ ) {
			$navers[$j] = $w->a({-href=>$consproj.$idvers[$j]}, $navers[$j]);
		}
		$probearray{ $name[$i] } = join (", ", @navers);
	}
	undef $requete2;
}

## Traitements:
#~~~~~~~~~~~
my $tableprobe = "";
for ( $i = 0 ; $i < $nbspotseq ; $i++ ) {
	my $title = "Probe " . $w->font( { -color => '#FFFF00' }, $name[$i] );
	if ( $altername[$i] ne $name[$i] ) {
		$title = $title . $w->font( { -color => '#FFFF00' }, " ($altername[$i])" );
	}
	my $probe = &printwebtitle("$title");
	$probe .= &printwebtable( "type",             $type[$i] );
	$probe .= &printwebtable( "description",   $probeannot{ $name[$i] } );
	$probe .= &printwebtable( "primer 5\'",     $primer5[$i] );
	$probe .= &printwebtable( "primer 3\'",     $primer3[$i] );
	$probe .= &printwebtable( "sequence",     &formatseq( $seq[$i] ) );
	$probe .= &printwebtable( "spotted on", $probearray{ $name[$i] } );
	$probe .= &printwebtable( "associated genes", $probegene{ $name[$i] } );
	$probe .= &printwebtable( "CATdb link",
														"All results for this probe: "
															. &wlink( $name[$i], "CATdb", $name[$i] )
															. "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
													);

	if ( $name[$i] ne '' ) {
		my $linkp = "&nbsp;&nbsp;&nbsp;&nbsp;"
			. $w->a( { -href => $lkhelp . "?docInfo=CATdb_toFLAGdb.txt\&title=Consult" },
							 $w->i("(more info...)") );
		$probe .= &printwebtable(	"localisation link",
															"See position in genome with &nbsp;"
																. &wlink(	$name[$i], "FLAGdb",
																		$w->img( { -src    => "$flagdblogo",
																							 -border => 0,
																							 -alt    => "FLAGdb++"
																							}
																		)
																	)
																. $linkp
															);
	}
	$tableprobe .= $w->table( { -class => "info", -width => '100%' }, $probe );
}
my $tablegene = "";
my $instflagdb;
my @genename = keys(%geneproduct);

for ( $j = 0 ; $j < scalar(@genename) ; $j++ ) {
	my $gene = &printwebtitle( "Gene " . $w->font( { -color => '#FFFF00' }, $genename[$j] ) );
	$gene .= &printwebtable( "source",   $genesource{ $genename[$j] } );
	$gene .= &printwebtable( "function", $geneproduct{ $genename[$j] } );

	# les liens vers les autres bases
	my $link = "";

	# tair, tigr, ncbi
	if ( $genename[$j] =~ /AT\dG\d{5}/ ) {    # c'est du tair
		$link .= &wlink( $genename[$j], "TAIR",
							$w->img( { -src => "$tairlogo", -border => 0, -alt => "TAIR" } ), "_blank" )
							. $w->br;
		$link .= &wlink( $genename[$j], "NCBI",
							$w->img( { -src => "$ncbilogo", -border => 0, -alt => "NCBI" } ), "_blank" )
							. $w->br;
	}

	# FLAGdb; toutes les sondes sont dans flagdb++
	$link .= &wlink( $genename[$j], "FLAGdb",
									 $w->img( { -src => "$flagdblogo", -border => 0, -alt => "FLAGdb++" } )
									 . "&nbsp;&nbsp;&nbsp;&nbsp;"	);
	$link .= $w->a( { -href => $lkhelp . "?docInfo=CATdb_toFLAGdb.txt\&title=Consult" },
									$w->i("(more info...)") );
	$gene .= &printwebtable( "links", $link );
	$tablegene .= $w->table( { -class => "info", -width => '90%' }, $gene );
}
my $GSTlegend = &legend();

#Debut HTML:
#~~~~~~~~~~~
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
								-title  => 'CATdb Probe\'n Gene info',
								-author => 'bioinfo@evry.inra.fr',
								-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
								-style  => { -src => $stylepath },
								-script => $JSCRIPT
			);
print $w->div( { -class => "entete" }, "\n",
				$w->div( { -class => "entete1" }, "\n",
					$w->div( { -class => "logo" }, "\n",
						$w->a( { -href => $lkaccueil },
							$w->img( { -src => $urgvsmal, -height => "75",  -border => 0, alt => "IPS2" } )
						)
					), "\n",
					$w->div( { -class => "titre" }, "\n",
						$w->a( { -href => $lkaccueil }, "\n",
							$w->img( { -src    => $catdblogo,
												 -border => 0,
												 -alt    => "CATdb"
												}
							)
						),
						$w->br, "\n",
						$w->font( { -size => 4, -color => '#336699' },
							$w->b( $w->i("~ Probe'n Gene info ~") )
						), "\n"
					), "\n"
				),
				$w->br, "\n"
			), "\n";
			
if ( !$message ) {
	print $w->div( { -class => "data",
									 -align => "center",
									 -style => "padding-top:$datadecal" . "px"
								 }, "\n",
					$w->font( { -size => "2" }, "\n",
						$w->table( {	-width       => '95%',
													-align       => 'center',
													-cellspacing => 5
												},
							$w->Tr(
								$w->td( { -valign => 'top', -width => '59%' }, $tableprobe ),
								$w->td( { -width => '1%' }, "" ),
								$w->td( { -valign => 'top',
													-width  => '40%',
													-align  => 'right'
												}, $tablegene	)
							),
							$w->Tr(
								$w->td(),
								$w->td( { -align => 'right' }, $instflagdb )
							)
						), "\n",
					)
				), "\n", 
				$w->a( { -name => "GSTlegend" } ), 
				$w->br, "\n", $w->br, "\n", $w->br, "\n",
				$w->div( { -class => "data", -align => "center", -style => "font-size:9px;" }, "\n",
					$w->table( { -width => '60%', -align => 'center', -cellspacing => 5 }, $GSTlegend )
				), "\n";

} else {
	print $w->div( { -class => "data",
									 -align => 'center',
									 -style => "padding-top:$datadecal" . "px"
								 },
					$w->font( { -size => "4", -color => 'red' }, $w->b($message) ), "\n"
				), "\n", $w->br, "\n";
}

print $w->br, "\n", $w->br, "\n",
			$w->div( { -class => "pied", -align => "center" }, "\n",
				$w->button(	-name    => 'buttonSubmitRetour',
										-value   => 'BACK',
										-onClick => "retour(this.form);"
				), "\n"
			), "\n";

print $w->end_html;

#-FONCTIONS-------------------------------------------------------------------
# normalisation de l'ecriture
# pour toutes les ecritures web des tables
sub printwebtable() {
	my ( $title, $val ) = @_;
	my $grisF = "#BBBBBB";
	my $new   =
		$w->Tr(   $w->td( { -bgcolor => $grisF, -style => "color: white;" }, $w->b($title) )
						. $w->td( { -align => 'left', -wrap => 1 }, $val ) );
	return ($new);
}

sub printwebtitle() {
	my $t = shift;

	#  my $new=$w->div({-class=>'banner'},$w->br,
	my $new = $w->br . $w->div( { -class => 'bannertext' }, "$t" );
	return ($new);
}

# formate la sequence pour la sortie
sub formatseq() {
	my $seq    = shift;
	my $newseq = "";
	my $lg     = 40;
	my $ind    = 0;
	my $fgt    = "";
	while ( $ind < length($seq) ) {
		$newseq .= substr( $seq, $ind, $lg ) . $w->br;
		$ind += $lg;
	}
	return $newseq;
}

# pour les liens vers l'exterieur, on va faire une table
# comme dans flagdb
sub wlink() {
	my $id     = shift;
	my $base   = shift;
	my $com    = shift;
	my $target = shift;
	my $url;
	
	if ( $target eq '' ) { $target = "_self"; }
	if ( $base eq 'CATdb' ) {
		$url = $CHIPS::CDIFFID . "?idnum=$id";
	} else {
		my $req =	&SQLCHIPS::do_sql("select url from $ppty.link_url where upper(database)=upper('$base')");
		$url = ( &SQLCHIPS::get_col( $req, 0 ) )[0] . $id;
	}
	my $link = $w->a( { -href => $url, -target => "$target" }, "$com" );
	return $link;
}

# legendes pour les GST
sub legend() {
	my $blanc = $consult_package::BLANC;
	my $grisF = $consult_package::GRISF;
	my $grisM = $consult_package::GRISM;
	my $grisS = $consult_package::GRISS;

	my ( $ky,  $cell, $mk, $att );
	my ( %GSTtype, %GSTpcr );
	my ( %pcrqual, %typqual );
	tie %pcrqual, "Tie::IxHash";
	%pcrqual = ( "B" => "amplified from BAC clone",
							 "G" => "amplified from genomic DNA",
							 "T" => "amplified from transcripts (cDNA)",
							 "0" => "PCR amplification not detected in electrophoresis gel",
							 "1" => "PCR amplification is ok (quantity and GST size are good)",
							 "2" => "weak PCR amplification",
							 "3" => "PCR amplification gives multiple products",
							 "4" => "PCR product gives product with unexpected size"
	);
	tie %typqual, "Tie::IxHash";
	%typqual = (
		"E" => "GST is inside an exon",
		"EI" => "GST overlaps an exon-intron boundary, predominantly in exon",
		"EV" => "GST overlaps an exon-intergenic boundary",
		"I" => "GST is inside an intron",
		"IE" => "GST overlaps an intron-exon boundary, predominantly in intron",
		"M" => "GST tags multiple genes",
		"R" => "GST tags a repeated region",
		"V" => "GST is in intergenic region",
		"VE" => "GST overlaps an intergenic-exon boundary",
		"1" =>
"the closest paralogous region shares less than 40% of identity with the GST (specificity is good)",
		"2" =>
"the closest paralogous region shares between 40% and 70% of identity with the GST (specificity is medium)",
		"3" =>
"the closest paralogous region shares more than 70% of identity with the GST (specificity is low)",
		"4" => "GST is 100% identical to several genomic regions"
	);
	
	# legendes PCR_result
	%GSTpcr= &freqGST_byTypePCR ('PCR_result');
	my $pcr_legend = $w->Tr( { -height => 20, -bgcolor => $grisF, -style => "color:$blanc" },
											$w->td( { -colspan => 3 },
												$w->b( "&nbsp;the '",
													$w->font( { color => 'black' }, "PCR_result" ), "' description" )
											),
											$w->td( { -nowrap }, "% GST" )
										);

	foreach $ky ( keys %pcrqual ) {
		if ( $ky =~ /[0-9]/ ) { 
			if ( int($ky) > 0 ) { $mk = "&nbsp;"; } else { $mk = "&nbsp;+"; }
			$cell = $w->td( { -bgcolor => $blanc,
												-width => "5%",
												-align => 'right',
												-style => "color:$grisS"
											}, "$mk");
			$cell .= $w->td( { -bgcolor => $grisM,
												-width   => "5%",
												-align   => 'right',
												-style   => "color:$grisS"
											 }, $ky );
		} else { 
			$cell = $w->td( { -bgcolor => $grisM,
												-width   => "10%",
												-align   => 'left',
												-colspan => 2,
												-style   => "color:$grisS"
											}, $ky );
		}
		$pcr_legend .= $w->Tr(
											$cell,
											$w->td( { -align   => 'left',
															  -bgcolor => $grisM,
																-style   => "color:$grisS"
															}, $pcrqual{$ky}),
											$w->td( { -align   => 'right',
																-bgcolor => $grisM,
																-style   => "color:$grisS"
															},  sprintf ("%.1f", $GSTpcr{$ky}) )
										)	. "\n";
	}

	$pcr_legend = $w->table( { -border      => 0,
														 -cellpadding => 2,
														 -cellspacing => 3,
														 -bgcolor     => $blanc,
														 -width       => "100%"
													 }, $pcr_legend )	. "\n";
													 
	# legendes Type de GST
	%GSTtype = &freqGST_byTypePCR ('type');
	my $typ_legend = $w->Tr( { -height => 20, -bgcolor => $grisF, -style => "color:$blanc" },
											$w->td( { -colspan => 3 },
												$w->b( "&nbsp;the '",
													$w->font( { -color => 'black' }, 
														$w->a({-href=>"javascript:openwdw('$lkgstpos','GST',520,520)"}, "Type" )),
															"' description&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(position and specificity)"
												)
											),
											$w->td( {-nowrap}, "% GST" )
									 );
									 
	foreach $ky ( keys %typqual ) {
		if ( $ky =~ /[0-9]/ ) { 
			if ( int($ky) > 1 ) { $mk = "&nbsp;"; } else { $mk = "&nbsp;+"; }
			$cell = $w->td( { -bgcolor => $blanc,
												-width => "5%",
												-align => 'right',
												-style => "color:$grisS"
											}, "$mk");
			$cell .= $w->td( { -bgcolor => $grisM,
												-width   => "5%",
												-align   => 'right',
												-style   => "color:$grisS"
											 }, $ky );
		} else { 
			$cell = $w->td( { -bgcolor => $grisM,
												-width   => "10%",
												-align   => 'left',
												-colspan => 2,
												-style   => "color:$grisS"
											}, $ky );
		}
		
		$typ_legend .= $w->Tr(
											$cell,
											$w->td( { -align   => 'left',
																-bgcolor => $grisM,
																-style   => "color:$grisS"
															}, $typqual{$ky} ),
											$w->td( { -align   => 'right',
																-bgcolor => $grisM,
																-style   => "color:$grisS"
															},  sprintf ("%.1f", $GSTtype{$ky}) )
									 ) . "\n";
	}

	$typ_legend = $w->table( { -border      => 0,
														 -cellpadding => 2,
														 -cellspacing => 3,
														 -bgcolor     => $blanc,
														 -width       => "100%"
													 }, $typ_legend  ) . "\n";

	my $gst_legend = $w->table( { -border      => 0,
																-width       => '70%',
																-align       => 'center',
																-cellspacing => 10
															},
									 		$w->Tr( { -valign => 'top' },
													$w->td( { -width => '48%' }, $pcr_legend ),
													$w->td( { -width => '52%' }, $typ_legend )
											),
											$w->Tr(
													$w->td(),
													$w->td(
															$w->i(
													"&nbsp;see FLAGdb++ for more information on genes and GST positions"
															)
													)
											)
									 ) . "\n";
	return $gst_legend;
}

sub freqGST_byTypePCR () {
	my $tpq = shift;
	my %hachage;
	my $ky;
	
	# count total
	my $req = &SQLCHIPS::do_sql("select count(*) from $ppty.annotation_spot where type_qual='$tpq' 
																and qualifier is not null and qualifier <> 'superchromochip'");
	my $total = $req->{LINES}[0][0]; 
	# count categories
	my $req = &SQLCHIPS::do_sql("select distinct qualifier, count(*) from $ppty.annotation_spot where 
																type_qual='$tpq' and qualifier is not null and qualifier <> 'superchromochip' 
																group by qualifier");
	my @tabcat = &SQLCHIPS::get_col( $req, 0 );
	my @tabfrq = &SQLCHIPS::get_col( $req, 1 );
	
	# synthese 
	for (my $i=0; $i<scalar @tabcat; $i++) {
		# les lettres:
		if ($tabcat[$i] =~ /^([a-zA-Z]{1,2})/ ) {    
			$ky = $1; 
			if (! exists $hachage{$ky}) {
				&remplirHash($ky, $tabfrq[$i], \%hachage);
			} else {
				&remplirHash($ky, $hachage{$ky}+$tabfrq[$i], \%hachage);
			}
		}
		# les chiffres:
		if ($tabcat[$i] =~ /^[a-zA-Z]{1,2}([0-9])/) {     
			$ky = $1; 
			if (! exists $hachage{$ky}) {
				&remplirHash($ky, $tabfrq[$i], \%hachage);
			} else {
				&remplirHash($ky, $hachage{$ky}+$tabfrq[$i], \%hachage);
			}
		}		
	}
	
	# calcul pourcentages
	my ($k, $v);
	while (($k, $v) = each %hachage) {
		$hachage{$k} = $hachage{$k}*100/$total;
	}

	return %hachage;
}

sub remplirHash () {
	my ($cle, $val, $hach) = @_;

	$$hach{$cle} = $val;
	return ;
}
