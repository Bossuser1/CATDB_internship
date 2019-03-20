#!/usr/local/bin/perl

use Carp;    
use strict;
use CGI qw/:standard escapeHTML/;
use lib './';    # PACKAGES modifies sur /www/cgi-bin/projects/CATdb
use SQLCHIPS;
use CHIPS;

#--Variables---------------------------------------------
my $stylepath  = $CHIPS::STYLECSS;
my $ppty       = $CHIPS::DBname;
my $w          = new CGI;
my $contact_id = param('contact_id');

#--Requetes---
my $reqcoord = &SQLCHIPS::do_sql("select last_name, first_name, institution, email from 
$ppty.contact where contact_id = $contact_id"	);

my $lstnm = $reqcoord->{LINES}[0][0];
my $fstnm = $reqcoord->{LINES}[0][1];
my $insti = $reqcoord->{LINES}[0][2];
my $eml   = $reqcoord->{LINES}[0][3];

undef $reqcoord;

#--HTML---------------------------------------------------
print $w->header();
print $w->start_html(	-title   => 'CATdb Project coordinator',
											-meta    => { 'robots' => 'noindex,nofollow' },
											-author  => 'bioinfo@evry.inra.fr',
											-style   => { -src => $stylepath },
											-BGCOLOR => "#FFFFFF"
			);

#--info table--
print $w->table({  -width       => '100%',
									 -border      => 0,
									 -cellpadding => 2,
									 -cellspacing => 5,
									 -align       => 'center'
								 },
								 $w->Tr({ -height => 20 },
												 $w->td( { -class => "label" }, "&nbsp;First name:" ),
												 $w->td( { -class => "coord" }, $w->b($fstnm) )
								 ),
								 $w->Tr({ -height => 20 },
												 $w->td( { -class => "label" }, "&nbsp;Last name:" ),
												 $w->td( { -class => "coord" }, $w->b($lstnm) )
								 ),
								 $w->Tr({ -height => 20 },
												 $w->td( { -class => "label" }, "&nbsp;Institution:" ),
												 $w->td( { -class => "coord" }, $insti )
								 ),
								 $w->Tr({ -height => 20 },
												 $w->td( { -class => "label" }, "&nbsp;Email:" ),
												 $w->td( { -class => "coord" },
																 $w->a(	{ -href  => "mailto:$eml",
																					-style => "text-decoration:none;"
																				},
																				$w->b($eml)
																 )
												 )
								 )
			), "\n";
print $w->br;

print $w->div({ -align => 'right' },
							 $w->font({ -size => 2 },
												 $w->a( { -href  => "javascript:window.close()",
																	-style => "text-decoration:none; color:#CC0000;"
																},
																"[close]"
												 )
							 )
			);

print $w->end_html;
