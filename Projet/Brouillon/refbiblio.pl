#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;

#--Variables---------------------------------------------
my $ppty      = $CHIPS::DBname;
my $stylepath = $CHIPS::STYLECSS;
my $catdblogo = $CHIPS::CATDBLOGO;
my $urgvsmal  = $CHIPS::URGVSMALL;
my $w         = new CGI;
my $ctref     = 0;
my ( $nbline, $i, $text, $citation);
my ( $accpubmed, $oldpubmed, $oldref, $projna, $tabref, $typeref);

#--Liens--------------------------------------------------
my $lkurgv    = $CHIPS::WURGV;
my $lkaccueil = $CHIPS::CACCUEIL;
my $lkprojct  = $CHIPS::CPROJECT . "?project_id=";
my $lkpubmed  = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=";

#--REQUETE-----------------------------------------------
#-articles par projet---
my $requete = &SQLCHIPS::do_sql( "select b.PUBMED_ID, b.AUTHORS, b.TITLE, b.BOOK_REF, p.PROJECT_NAME, 
							pb.PROJECT_ID, p.is_public from $ppty.BIBLIO_LIST b, $ppty.PROJECT_BIBLIO pb, 
							$ppty.project p where b.PUBMED_ID=pb.PUBMED_ID and pb.PROJECT_ID=p.PROJECT_ID order by 
							b.YEAR desc, b.AUTHORS, p.project_name"	);
$nbline = $requete->{NB_LINE};
for ( $i = 0 ; $i < $nbline ; $i++ ) {
	$accpubmed = $requete->{LINES}[$i][0];
	if ( $accpubmed == $oldpubmed ) {
		if ( $requete->{LINES}[$i][6] eq 'yes' ) {
			$projna = sprintf ("%s<br> + <br>%s", $projna, 
							$w->a( { -href => $lkprojct . $requete->{LINES}[$i][5] }, $requete->{LINES}[$i][4] ));
				
		} else {
			$projna = sprintf ("%s<br>+ <i>not yet available</i>", $projna);
		}
	} else {
		if ( $oldpubmed ne '' ) {
			$tabref .= &ref_table_line( $lkpubmed,   $oldpubmed,  $$oldref[1],
																	$$oldref[2], $$oldref[3], $projna );
			$ctref++;
		}
		if ( $requete->{LINES}[$i][6] eq 'yes' ) {
			$projna =	$w->a( { -href => $lkprojct . $requete->{LINES}[$i][5] }, $requete->{LINES}[$i][4] );
		} else {
			$projna = $w->i("not yet available");
		}
	}
	$oldref    = \@{ $requete->{LINES}[$i] };
	$oldpubmed = $accpubmed;
}

# derniere ligne
$ctref++;
$tabref .= &ref_table_line( $lkpubmed, $oldpubmed, $$oldref[1], $$oldref[2], $$oldref[3], $projna );
	
#-articles d'analyse globale---
my $requete = &SQLCHIPS::do_sql("select PUBMED_ID, AUTHORS, TITLE, BOOK_REF, TYPE_REF from 
							$ppty.BIBLIO_LIST where TYPE_REF is not null order by YEAR desc, TYPE_REF, PUBMED_ID");
$nbline = $requete->{NB_LINE};
for ( $i = 0 ; $i < $nbline ; $i++ ) {
	$typeref = $w->i($requete->{LINES}[$i][4]);
	$tabref .= &ref_table_line( $lkpubmed, $requete->{LINES}[$i][0], $requete->{LINES}[$i][1],
															$requete->{LINES}[$i][2], $requete->{LINES}[$i][3], $typeref);
	$ctref++;
}	

#-textes---PMID: 17940091
$citation = sprintf ("%s<br>%s <br>%s <br>%s",	
				$w->font({-color=>'#336699'}, $w->b("We will be pleased if users include the reference below in publications describing the use of CATdb data:")),
				$w->b("Gagnot S, Tamby JPh, Martin-Magniette ML, Bitton F, Taconnat L, Balzergue S, 
Aubourg S, Renou JP, Lecharny A, Brunaud V."),
				"CATdb: a public access to Arabidopsis transcriptome data from the URGV-CATMA platform. Nucleic Acids Res. 2008 Jan;36(Database issue):D986-90",
				$w->a({-href=>$lkpubmed."17940091",-target=>'_blank'},"PMID: #17940091")
); 		
#-- +PMID: 25392409
$citation = sprintf ("%s<br><br>%s <br>%s <br>%s <br>%s",	 $citation,
				$w->font({-color=>'#336699'}, $w->b("The new CATdb module GEM2Net is published:")),
				$w->b("Zaag R, Tamby JPh, Guichard C, Tariq Z, Rigaill G, Delannoy E, Renou JP, Balzergue S, Mary-Huard T, Aubourg S, Martin-Magniette ML, Brunaud V."),
				"GEM2Net: from gene expression modeling to -omics networks, a new CATdb module to investigate Arabidopsis thaliana genes involved in stress response. Nucleic Acids Res. 2015 Jan;43(Database issue):D1010-17",
				$w->a({-href=>$lkpubmed."25392409",-target=>'_blank'},"PMID: #25392409")
);

$text = sprintf ("You can find here %d published articles based on CATdb data:", $ctref );

#--HTML-----------------------------------------------------------
print $w->header();
my $JSCRIPT = <<END;

function retour(form){
    history.back();
}

END
print $w->start_html( -title  => 'CATdb Biblio',
											-author => 'bioinfo@evry.inra.fr',
											-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' },
											-style   => { -src => $stylepath },
											-BGCOLOR => "#FFFFFF",
											-script  => $JSCRIPT	), "\n";

print $w->div( { -class => "entete1" }, "\n",
				 $w->div( { -class => "logo" }, "\n",
						$w->a( { -href => $lkurgv },
									 $w->img( { -src => $urgvsmal, -height => "75", -border => 0,	-alt => "IPS2"	} )
						)
				 ), "\n",
				 $w->div( { -class => "titre" },
						$w->a( { -href => $lkaccueil },
									 $w->img( { -src => $catdblogo, -border => 0, -alt => "CATdb" } )
						),
						$w->br, "\n",
						$w->font( { -size => 4 },
								$w->b( { -style => 'Color:#336699' }, $w->i("~ Bibliography ~") )
						)
				 ), "\n"
			), "\n";
print $w->br, $w->br, $w->br, "\n";

print $w->div( { -class => 'banner' }, "\n", 
				$w->div( { -class => 'bannertext' }, "How to cite CATdb ?" ) ),
				$w->br, "\n";
print $w->div($citation);
print $w->br, $w->br, "\n";
print $w->a({-name=>"articles"},"");
print $w->div( { -class => 'banner' }, "\n", 
				$w->div( { -class => 'bannertext' }, "CATdb projects bibliography" ) ),
				$w->br, "\n";
print $w->div( { -class => 'data' }, "\n",
				$w->h3($text),
				$w->br, "\n",
				$w->table( { -align       => 'center',
										 -width       => '90%',
										 -border      => 1,
										 -rules       => 'all',
										 -bordercolor => '#777777',
										 -cellpadding => 5,
										 -cellspacing => 0,
										 -style       => "color:#555555;" }, "\n",
						 $w->Tr( { -align=>'center', -style=>"color:#FFFFFF;background:#BBBBBB;font-size:12px;" },
								 $w->td( {-nowrap}, $w->b("PMID") ),
								 $w->td( $w->b("REFERENCE") ),
								 $w->td( {-nowrap}, $w->b("CATdb &nbsp;PROJECT") )
						 ), "\n", 
						 $tabref	), "\n"
			), "\n";
print $w->br, $w->br, "\n";
print $w->div( { -class => "pied", -align => "center" },
				 $w->button( -name    => 'buttonSubmitRetour',
										 -value   => 'BACK',
										 -onClick => "retour(this.form);" ), "\n"
			);
print $w->end_html;

#--FUNCTION-------------------------------------------------------
sub ref_table_line () {
	my ( $lkpbmd, $acc, $aut, $titre, $bkref, $proj ) = @_;
	return $w->Tr(
								$w->td( { -class => 'bib' },
												$w->a( { -href => $lkpbmd . $acc, -target => 'blank' }, '#' . $acc )
								),
								$w->td( { -class => 'biblio' }, $w->b($aut), $w->br, $titre, '&nbsp', $bkref ),
								$w->td( { -class => 'bib' }, $proj )
	);
}
