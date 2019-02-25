CREATE TABLE mutation_type_list (
mutation_name VARCHAR (100) NOT NULL,
mutation_type VARCHAR (100) NOT NULL,
mutation_factor VARCHAR (100) NOT NULL );
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-out","chemical mutagen","EMS");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-out","insertional mutagen","T-DNA");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-out","insertional mutagen","transposon");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-out","insertional mutagen","homologous recombination");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-out","ionizing radiation","fast neutron deletion");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-out","ionizing radiation","gamma irradiation");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-down","RNAi","shRNA");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-down","RNAi","siRNA");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("knock-down","RNAi","antisense RNA");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("overexpression","enhancer trap","");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("overexpression","promoter trap","");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("overexpression","gene trap","");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("unknown","unknown","unknown");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("constitutive","site-directed mutagenesis by PCR","homologous recombination");
INSERT INTO mutation_type_list (mutation_name,mutation_type,mutation_factor) VALUES ("overexpression","transfection","None");
