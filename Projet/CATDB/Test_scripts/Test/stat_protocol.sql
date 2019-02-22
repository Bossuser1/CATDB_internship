CREATE TABLE stat_protocol (
stat_protocol_id integer NULL,
stat_protocol_name VARCHAR (100) NULL,
analysis_type VARCHAR (100) NULL,
array_type_name VARCHAR (100) NOT NULL,
stat_prg_name VARCHAR (100) NULL,
note VARCHAR (4000) NOT NULL,
protocol_id integer NOT NULL,
user_id integer NOT NULL,
submission_date date NOT NULL );
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (4,"diff_analysis_CATMA","differential_analysis","CATMA","Differential_analysis.R","None",28,10,"2006-03-17");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (2,"CATMA_2.1_default","normalization","CATMA_2.1","normalisation.R","None",28,10,"2005-10-27");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (3,"CATMA_2_default","normalization","CATMA_2","normalisation.R","None",28,10,"2005-10-27");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (5,"CATMA_2.2_default","normalization","CATMA_2.2","normalisation.R","None",28,10,"2006-03-22");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (7,"raw_data","raw_data","CHROMO4_1","raw_data.R","None","None",10,"2006-10-23");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (8,"CATMA_2.3_default","normalization","CATMA_2.3","normalisation.R","None",28,5,"2007-01-02");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (9,"chip_data","chip_data","CHROMO4_1","chip_data.R","None","None",10,"2006-10-23");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (10,"chip_data","chip_data","CHROMO4_2","chip_data.R","None","None",10,"2006-10-23");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (11,"diff_analysis_AV","diff_analysis_chrIV","CHROMO4_1","Load_Diff_Analysis_AV.R","None","None",10,"2007-10-15");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (13,"Homoscedastique_differential_analysis","differential_analysis","AFFY","DiffAnalysis.unpaired.R","None","None",10,"2008-07-16");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (14,"Varmixt_VM_differential_analysis","differential_analysis","AFFY","differential_analysis.R","None","None",10,"2008-07-16");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (15,"CATMA_5_default","normalization","CATMA_5","normalisation.R","None",28,0,"2009-09-22");
INSERT INTO stat_protocol (stat_protocol_id,stat_protocol_name,analysis_type,array_type_name,stat_prg_name,note,protocol_id,user_id,submission_date) VALUES (16,"chromo4_transcript","normalization","CHROMO4_2","normalisation.R","None",10186,8,"2010-08-10");
