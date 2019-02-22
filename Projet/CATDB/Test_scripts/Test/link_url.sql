CREATE TABLE link_url (
link_id integer NULL,
database VARCHAR (100) NULL,
url VARCHAR (300) NULL );
INSERT INTO link_url (link_id,database,url) VALUES (1,"NCBI","http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=search&db=protein&orig_db=protein&term=");
INSERT INTO link_url (link_id,database,url) VALUES (5,"TAIR","http://www.arabidopsis.org/servlets/Search?type=general&search_action=detail&method=1&sub_type=gene&name=");
INSERT INTO link_url (link_id,database,url) VALUES (3,"TIGR","http://www.tigr.org/tigr-scripts/euk_manatee/shared/ORF_infopage.cgi?db=ath1&orf=");
INSERT INTO link_url (link_id,database,url) VALUES (2,"GEO","http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc=");
INSERT INTO link_url (link_id,database,url) VALUES (7,"Affymetrix","http://www.affymetrix.com/products_services/arrays/specific/");
INSERT INTO link_url (link_id,database,url) VALUES (6,"ArrayExpress","http://www.ebi.ac.uk/arrayexpress/experiments/");
INSERT INTO link_url (link_id,database,url) VALUES (4,"FLAGdb","http://tools.ips2.u-psud.fr/cgi-bin/projects/CATdb/toFLAGdb.pl?idFeat=");
