#!/usr/local/bin/perl

use Carp;
use strict;    
use Tie::IxHash;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb 
use SQLCHIPS;
use CHIPS;
use consult_package;

#--Variables------------------------------------------------------
my $ppty          = $CHIPS::DBname;
my $archpath      = $CHIPS::TARPATH;
my $project_id    = $ARGV[0];
my $experiment_id = $ARGV[1];
my $datafile;
my ( $requete0, $requete1a, $requete1b, $requete2, $requete3, $requete4 );
my ( @Rep_id, @spotseqId, $LRep_id, $nbswap, $nbline);
my ( %seq_n, %gene_n, %gene_p, %biol_f, %qualtype, %qualpcr, %diff_data );
my ( $rsid, $rsna, $rgna );
my ( $j, $spid, $repid, $pvl );
my ( $key1,      $key2 );
my ( $proj_name, $titre );
my $nbenrg       = 0;
my $ligne_organs = "\t\t\t\tOrgans:";
my $ligne_swap   = "\t\t\t\tSwap:";
my $enrg         = "CATMA ID\tAGI CODE\tFUNCTION\tTYPE_QUAL\tPCR_RESULT";

#--CONTROLE------------------------------------------------------
if ( $project_id ne '' && $experiment_id ne '' ) {
	$proj_name = &consult_package::recupdbName( "project", $project_id);	
	$datafile = sprintf( "%s_exp%s.xls", &CHIPS::clean_filename($proj_name), $experiment_id );

	if ( !( -f "$archpath$datafile" && -T "$archpath$datafile" ) ) {
	#--Recuperation des donnees-----------
		# Replicats (id, noms et organes):
		$requete0 = &SQLCHIPS::do_sql(
			"Select distinct r.replicat_id, r.replicat_extracts, s1.organ, 
    s2.organ from $ppty.replicats r, $ppty.hybrid_replicats hr, $ppty.hybridization h, 
    $ppty.extract_pool ep1, $ppty.extract_pool ep2, $ppty.hybrid_labelled_extract hle1, 
    $ppty.hybrid_labelled_extract hle2,$ppty.sample_extract se1, $ppty.sample_extract se2, 
    $ppty.sample s1, $ppty.sample s2 where r.replicat_id=hr.replicat_id and 
    h.hybridization_id=hr.hybridization_id and h.cy3_extract_pool_id=hle1.labelled_extract_id 
    and hle1.extract_pool_id=ep1.extract_pool_id and ep1.extract_id=se1.extract_id and 
    se1.sample_id=s1.sample_id and h.cy5_extract_pool_id=hle2.labelled_extract_id and 
    hle2.extract_pool_id=ep2.extract_pool_id and ep2.extract_id=se2.extract_id and 
    se2.sample_id=s2.sample_id and r.experiment_id = $experiment_id and hr.ref=1 and 
    (r.rep_type = 'swap' or r.rep_type = 'r_swap') order by r.replicat_extracts"
		);
		$nbswap = $requete0->{NB_LINE};
		
		if ( $nbswap != 0 ) {	
			# organes, noms swaps & noms colonnes:
			for ( $j = 0 ; $j < $nbswap ; $j++ ) {
				push (@Rep_id, $requete0->{LINES}[$j][0]);
				$ligne_swap .= sprintf( "\t%s\t\t\t", $requete0->{LINES}[$j][1] );
				$ligne_organs .=
					sprintf( "\t%s/%s\t\t\t", $requete0->{LINES}[$j][3], $requete0->{LINES}[$j][2] );
				$enrg .= "\tI S1\tI S2\tR\tP-VAL";
			}
			$ligne_organs .= "\n";
			$ligne_swap   .= "\n";
			$enrg         .= "\n";
			$LRep_id = join( ',', @Rep_id );
			undef $requete0;

			# ouverture fichier:
			open( DATAFILE, '>', "$archpath$datafile" )
				or die "Can't create $archpath$datafile: $!\n";
			# ecriture titre:
			( $proj_name, $titre ) = &recupProjName( $project_id, $experiment_id, $nbswap );
			print DATAFILE $titre, $ligne_organs, $ligne_swap, $enrg;						

			# Annotation des sequences:
			$requete1a = &SQLCHIPS::do_sql("select gene_name, gene_product from $ppty.annotation_gene");
			$nbline = $requete1a->{NB_LINE};
			# hash pour l'annotation des séquences:
			for ( $j = 0 ; $j < $nbline ; $j++ ) {
				$gene_p{ $requete1a->{LINES}[$j][0] } = $requete1a->{LINES}[$j][1];
			}
			undef $requete1a;

			# Noms des sequences (CATMA id & AGI codes):
			# sur spot_id:
			#$requete1 = &SQLCHIPS::do_sql("Select s.spot_id, ss.seq_name, sp.gene_name, ag.gene_product from $ppty.spotted_sequence ss, $ppty.spot_gene sp, $ppty.spot s, $ppty.annotation_gene ag, (select distinct spot_id from $ppty.diff_analysis_value where replicat_id in ($LRep_id)) cv where cv.spot_id=s.spot_id and s.spotted_seq_id=ss.spotted_sequence_id(+) and ss.spotted_sequence_id=sp.spotted_sequence_id(+) and sp.gene_name=ag.gene_name(+) and s.control_id in (0,2,3,6) order by ss.seq_name");
			# sur spotted_seq_id:
			#$requete1 = &SQLCHIPS::do_sql("Select s.spotted_seq_id, ss.seq_name, sp.gene_name, ag.gene_product from $ppty.spotted_sequence ss, $ppty.spot_gene sp, $ppty.spot s, $ppty.annotation_gene ag, (select distinct spot_id from $ppty.diff_analysis_value where replicat_id in ($LRep_id)) cv where cv.spot_id=s.spot_id and s.spotted_seq_id=ss.spotted_sequence_id(+) and ss.spotted_sequence_id=sp.spotted_sequence_id(+) and sp.gene_name=ag.gene_name(+) and s.control_id in (0,2,3,6) order by ss.seq_name");
			#$requete1 = &SQLCHIPS::do_sql("Select s.spotted_seq_id, ss1.seq_name, sp1.gene_name, ag.gene_product FROM $ppty.spot s LEFT OUTER JOIN $ppty.spotted_sequence ss1 ON (s.spotted_seq_id=ss1.spotted_sequence_id), $ppty.spotted_sequence ss2 LEFT OUTER JOIN $ppty.spot_gene sp1 ON (ss2.spotted_sequence_id=sp1.spotted_sequence_id), $ppty.spot_gene sp2 LEFT OUTER JOIN $ppty.annotation_gene ag ON (sp2.gene_name=ag.gene_name),(select distinct spot_id from $ppty.diff_analysis_value where replicat_id in ($LRep_id)) cv WHERE cv.spot_id=s.spot_id and s.control_id in (0,2,3,6) order by ss1.seq_name");
			$requete1b = &SQLCHIPS::do_sql(
				"Select distinct s1.spotted_seq_id, ss.seq_name, sp.gene_name from 
			$ppty.spot s1 LEFT OUTER JOIN $ppty.spot_gene sp on (s1.spotted_seq_id=sp.spotted_sequence_id),
			$ppty.spot s2 LEFT OUTER JOIN $ppty.spotted_sequence ss on (s2.spotted_seq_id=ss.spotted_sequence_id),
			$ppty.diff_analysis_value cv where cv.replicat_id in ($LRep_id) and s1.control_id in (0,2,3,6) 
			and s2.control_id in (0,2,3,6) and s1.spot_id = cv.spot_id and s2.spot_id = cv.spot_id 
			order by ss.seq_name"
			);
			$nbline = $requete1b->{NB_LINE};

			# noms des sequences:
			tie %seq_n, "Tie::IxHash";
			for ( $j = 0 ; $j < $nbline ; $j++ ) {
				$rsid         = $requete1b->{LINES}[$j][0];
				$rsna         = $requete1b->{LINES}[$j][1];
				$rgna         = $requete1b->{LINES}[$j][2];
				$seq_n{$rsid} = $rsna;
				if ( !exists $gene_n{$rsid} ) {
					$gene_n{$rsid} = $rgna;
				} else {
					$gene_n{$rsid} = $gene_n{$rsid} . " " . $rgna;
				}
				if ( !exists $biol_f{$rsid} ) {
					$biol_f{$rsid} = $gene_p{$rgna};
				} else {
					$biol_f{$rsid} = $biol_f{$rsid} . " " . $gene_p{$rgna};
				}
			}
			undef %gene_p;
			undef $requete1b;
			
			# Diff analysis data:
			# sur spot_id:
			#$requete2 = &SQLCHIPS::do_sql("select distinct dav.spot_id, dav.replicat_id, dav.i_sample, dav.i_ref, dav.log_ratio, dav.bonf_p_value from $ppty.diff_analysis_value dav, $ppty.spotted_sequence ss, $ppty.spot s where dav.spot_id = s.spot_id and s.spotted_seq_id = ss.spotted_sequence_id and dav.replicat_id in ($LRep_id) and s.control_id in (0,2,3,6) order by dav.replicat_id, dav.spot_id");
			# sur spotted_seq_id:
			$requete2 = &SQLCHIPS::do_sql(
				"select distinct s.spotted_seq_id, dav.replicat_id, dav.i_sample, 
      dav.i_ref, dav.log_ratio, dav.bonf_p_value from $ppty.diff_analysis_value dav, $ppty.spot s 
      where dav.spot_id = s.spot_id and dav.replicat_id in ($LRep_id) and s.control_id in (0,2,3,6) 
      order by dav.replicat_id, s.spotted_seq_id"
			);
			$nbline = $requete2->{NB_LINE};

			# diff data:
			for ( $j = 0 ; $j < $nbline ; $j++ ) {
				$spid  = $requete2->{LINES}[$j][0];
				$repid = $requete2->{LINES}[$j][1];
				$pvl   = $requete2->{LINES}[$j][5];
				if ( $pvl ne '' ) { $pvl = sprintf( "%.0E", $pvl ); }
				else { $pvl = "NA"; }
				${ $diff_data{$spid} }{$repid} = sprintf( "\t%.2f\t%.2f\t%.3f\t%s",
																									$requete2->{LINES}[$j][2],
																									$requete2->{LINES}[$j][3],
																									$requete2->{LINES}[$j][4], $pvl );
			}
			undef $requete2;
									
			# Info 'type' pour chaque sonde....
			# sur spot_id:
			#$requete3=&SQLCHIPS::do_sql("select s.spot_id, an.qualifier from $ppty.annotation_spot an, $ppty.spotted_sequence ss, $ppty.spot s where s.spotted_seq_id=ss.spotted_sequence_id and ss.spotted_sequence_id=an.spotted_sequence_id and an.type_qual='type' and s.control_id in (0,2,3,6) and s.spot_id in (select distinct spot_id from $ppty.diff_analysis_value where replicat_id in ($LRep_id))");
			# sur spotted_seq_id:
			$requete3 = &SQLCHIPS::do_sql(
				"select an.spotted_sequence_id, an.qualifier from 
      $ppty.annotation_spot an, $ppty.spotted_sequence ss where ss.spotted_sequence_id = 
      an.spotted_sequence_id and an.type_qual='type' and ss.control_id in (0,2,3,6) and 
      an.spotted_sequence_id in (select distinct s.spotted_seq_id from $ppty.spot s, 
      $ppty.diff_analysis_value daf where s.spot_id=daf.spot_id and daf.replicat_id in ($LRep_id))"
			);
			$nbline = $requete3->{NB_LINE};

			# Info 'PCR_result' pour chaque sonde....
			# sur spot_id:
			#$requete4=&SQLCHIPS::do_sql("select s.spot_id, an.qualifier from $ppty.annotation_spot an, $ppty.spotted_sequence ss, $ppty.spot s where s.spotted_seq_id=ss.spotted_sequence_id and ss.spotted_sequence_id=an.spotted_sequence_id and an.type_qual='PCR_result' and s.control_id in (0,2,3,6) and s.spot_id in (select distinct spot_id from $ppty.diff_analysis_value where replicat_id in ($LRep_id))");
			# sur spotted_seq_id:
			$requete4 = &SQLCHIPS::do_sql(
				"select an.spotted_sequence_id, an.qualifier from 
      $ppty.annotation_spot an, $ppty.spotted_sequence ss where ss.spotted_sequence_id = 
      an.spotted_sequence_id and an.type_qual='PCR_result' and ss.control_id in (0,2,3,6) and 
      an.spotted_sequence_id in (select distinct s.spotted_seq_id from $ppty.spot s, 
      $ppty.diff_analysis_value daf where s.spot_id=daf.spot_id and daf.replicat_id in ($LRep_id))"
			);

			# qualite des sondes:
			for ( $j = 0 ; $j < $nbline ; $j++ ) {
				$qualtype{ $requete3->{LINES}[$j][0] } = $requete3->{LINES}[$j][1];
				$qualpcr{ $requete4->{LINES}[$j][0] }  = $requete4->{LINES}[$j][1];
			}
			undef $requete3;
			undef $requete4;

			#--Ecriture fichier------------------------------------------------
			# noms & donnees
			foreach $key1 ( keys %seq_n ) {
				$enrg = "";
				$nbenrg++;

				#noms + annotations:
				$enrg .= sprintf( "%s\t%s\t%s", $seq_n{$key1}, $gene_n{$key1}, $biol_f{$key1} );
				$enrg .= sprintf( "\t%s\t%s", $qualtype{$key1}, $qualpcr{$key1} );

				#donnees:
				foreach $key2 (@Rep_id) {
					if ( exists( ${ $diff_data{$key1} }{$key2} ) ) {
						$enrg .= $diff_data{$key1}{$key2};
					} else {
						$enrg .= "\t \t \t \t ";
					}
				}
				$enrg .= "\n";
				print DATAFILE $enrg;	
			}
			close DATAFILE;
			print "$archpath$datafile... done !\t($nbenrg data lines)\n";
		}
	} else {
		print "$archpath$datafile already exists... nothing to do !\n";
	}
} else {
	die "missing argument(s)... abort !\n";
}

#--FONCTIONS------------------------------------------------------
sub recupProjName() {
	my $projid = shift;
	my $expid  = shift;
	my $nbswp  = shift;
	my $v;

	# Project_name:
	my $reqproj =
		&SQLCHIPS::do_sql("select project_name from $ppty.project where project_id=$projid");
	if ( $reqproj->{NB_LINE} != 0 ) {

		# Experiment_name:
		my $reqexp =
			&SQLCHIPS::do_sql(
"select experiment_name from $ppty.experiment where experiment_id=$expid and project_id=$projid"
			);

		# Organism/ecotype:
		my $sourorg = &consult_package::recupOrganismEcotype($expid);
		$v .= "Project:\t$reqproj->{LINES}[0][0]\n";
		$v .= "Experiment:\t$reqexp->{LINES}[0][0]\n";
		$v .= "Organism (ecotype):\t$sourorg\n";
		$v .= "Number of swaps:\t$nbswp\n\n";
		$reqproj->{LINES}[0][0] =~ tr/ +/\_/;
	}
	return $reqproj->{LINES}[0][0], $v;
}

sub gzipFile() {
	my $archpath = shift;
	my $datafile = shift;
	system("cd $archpath; gzip $datafile");
	return $datafile . ".gz";
}
