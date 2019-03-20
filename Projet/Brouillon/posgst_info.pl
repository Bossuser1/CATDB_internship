#!/usr/local/bin/perl

use Carp;
use strict;
use CGI qw/:standard escapeHTML/;
use Tie::IxHash;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;

#Variables:
#~~~~~~~~~~
my $ppty = $CHIPS::DBname;
my $w = new CGI;
my $GSTtype = $CHIPS::GSTLEGEND; 
my ( %typqual, %GSTtype);
my ($wtabline, $cle);

tie %typqual, "Tie::IxHash";
%typqual = (
		"E" => "exonic",
		"EI" => "exonic > intronic",
		"EV" => "exonic > intergenic",
		"I" => "intronic",
		"IE" => "intronic > exonic",
		"M" => "overlapping",
		"R" => "repeated",
		"V" => "intergenic",
		"VE" => "intergenic > exonic" );

#Main
#~~~~~~~~~~
tie %GSTtype, "Tie::IxHash";
&freqGST_byType('type', \%GSTtype);

#HTML
#~~~~~~~~~~
# font-family: Comic Sans MS, Verdana, Arial, Helvetica, Geneva, sans-serif, DejaVu Sans 
print $w->header();
print $w->start_html(
								-title  => 'CATdb GST position info',
								-author => 'bioinfo@evry.inra.fr',
								-meta => { 'keywords' => 'Plant arabidopsis', 'robots' => 'noindex,nofollow' }
			);
			
print $w->h2({-style=>"color:#003366; font:16pt Comic Sans MS, Verdana, Geneva, sans-serif, DejaVu Sans; 
									font-weight:bold; margin-left:45px"},
			 				"GST positions relative to TAIR genes"),"\n";

$wtabline = $w->Tr(
							$w->td({-width=>'170px', -align=>"right", -valign=>"middle"}, "[E] : $typqual{'E'}"),"\n",
							$w->td({-width=>'295px', -rowspan=>9, -align=>"center", -valign=>'top'}, "\n",
								$w->img({-src=>"$GSTtype", -border=>0, -alt=>'GST positions'}) ),"\n",
							$w->td({-width=>'45px', -valign=>'middle'}, sprintf ("%.1f \%", $GSTtype{'E'})),"\n"
						);						
foreach $cle (keys %typqual) {
	if ($cle ne "E") {
		$wtabline .= $w->Tr($w->td({-align=>"right", -valign=>"middle"},"[$cle] : ",$typqual{$cle}), 
												$w->td({-valign=>'middle'}, sprintf ("%.1f \%", $GSTtype{$cle}) ))."\n";
	}
}
print $w->table({	-width=>'510px', -border=>0, -cellspacing=>1, -bgcolor=>'#EEEEEE', 
									-style=> "color:#3E36C5; font:9pt Geneva, Arial, Helvetica, sans-serif, DejaVu Sans;" 
								}, "\n",
								$wtabline ),"\n";

print $w->br;
print $w->a({	-href=>"javascript:window.close();",
							-style=>"text-decoration:none;color:#CC0000;font:8pt Geneva, Arial, Helvetica, sans-serif, DejaVu Sans;
												margin-left:460px;"}, 
							"[close]" ),"\n";
			
print $w->end_html;


#-FONCTIONS-------------------------------------------------------------------
sub freqGST_byType () {
	my $tpq = shift;
	my $hach = shift;

	my ($tabcat, $tabfrq, $ky);
	my $total = 0;
	
	# count total
#	my $req = &SQLCHIPS::do_sql("select count(*) from $ppty.annotation_spot where type_qual='$tpq' 
#																and qualifier is not null and qualifier <> 'superchromochip'");
#	$total = $req->{LINES}[0][0]; 
	# count categories
	my $req = &SQLCHIPS::do_sql("select distinct qualifier, count(*) from $ppty.annotation_spot where 
																type_qual='$tpq' and qualifier is not null and qualifier <> 'superchromochip' 
																group by qualifier");
	my $nbline = $req->{NB_LINE};

	for (my $i=0; $i < $nbline; $i++) {
		$tabcat = $req->{LINES}[$i][0];
		$tabfrq = $req->{LINES}[$i][1];
		$total += $tabfrq;				# count total
			
		if ($tabcat =~ /^([a-zA-Z]{1,2})/ ) {
			$ky = $1; 
			if (! exists $hach->{$ky}) {
				$hach->{$ky} = $tabfrq;
			} else {
				$hach->{$ky} = $hach->{$ky}+$tabfrq;
			}
		}
	}
	
	# calcul pourcentages
	my ($k, $v);
	while (($k, $v) = each %$hach) {
		$hach->{$k} = $hach->{$k}*100/$total;
	}

	return;
}

