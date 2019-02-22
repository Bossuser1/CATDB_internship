CREATE TABLE stat_param_list (
analysis_type VARCHAR (100) NOT NULL,
array_type_name VARCHAR (100) NULL,
stat_prg_name VARCHAR (100) NULL,
software VARCHAR (100) NOT NULL,
param_name VARCHAR (30) NULL,
value VARCHAR (200) NOT NULL,
default_value VARCHAR (30) NOT NULL,
value_desc VARCHAR (200) NOT NULL,
multiple_value smallint NOT NULL,
param_modify smallint NULL,
pdf_doc VARCHAR (100) NOT NULL );
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CATMA_2","normalisation.R","R","flag","-50,-75","-100","flag -100 removed",1,1,"CATMA.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CATMA_2.1","normalisation.R","R","flag","-50,-75","-100","flag -100 removed",1,1,"CATMA.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CATMA_2.2","normalisation.R","R","flag","-50,-75","-100","flag -100 removed",1,1,"CATMA.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_1","normalisation.R","R","flag","-50,-75","-100","flag -100 removed",1,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_1","normalisation.R","R","ddm1","F","T","Knob removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_1","normalisation.R","R","Flagged","T","F","Flagged tiles not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_1","normalisation.R","R","MPB","F","T","Multiple PCR products removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_1","normalisation.R","R","N","T","F","Null PCR products not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_2","normalisation.R","R","ddm1","F","T","knob removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_2","normalisation.R","R","Flagged","T","F","Flagged tiles not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_2","normalisation.R","R","B0.G0","T","F","Null PCR products not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_2","normalisation.R","R","B3.G3","T","F","Multiple PCR products not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_2","normalisation.R","R","B4.G4","T","F","Wrong size PCR products not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CHROMO4_2","normalisation.R","R","empty","T","F","empty spot not removed",0,1,"puce-chromo.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CATMA_2.3","normalisation.R","R","flag","-50,-75","-100","flag -100 removed",1,1,"CATMA.pdf");
INSERT INTO stat_param_list (analysis_type,array_type_name,stat_prg_name,software,param_name,value,default_value,value_desc,multiple_value,param_modify,pdf_doc) VALUES ("normalization","CATMA_5","normalisation.R","R","flag","-50,-75","-100","flag -100 removed",1,1,"CATMA.pdf");
