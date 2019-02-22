CREATE TABLE unit_list (
unit_id integer NULL,
table_name VARCHAR (30) NOT NULL,
attribut_name VARCHAR (30) NOT NULL,
unit_name VARCHAR (30) NOT NULL,
unit_abv VARCHAR (10) NOT NULL,
unit_db VARCHAR (10) NOT NULL,
formula VARCHAR (50) NOT NULL );
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (0,"treatment","time_elapsed_unit","min","min","min","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (1,"treatment","time_elapsed_unit","hour","hour","min","X * 60");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (2,"treatment","time_elapsed_unit","day","day","min","X * 60 * 24");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (3,"treatment","time_elapsed_unit","week","week","min","X * 60 * 24 * 7");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (4,"treatment","time_elapsed_unit","month","month","min","X * 60 * 24 * 30");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (5,"treatment","measure_unit","mM","mM","mM","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (6,"treatment","measure_unit","percent","%","%","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (7,"treatment","measure_unit","ul","ul","ul","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (8,"treatment","measure_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (9,"treatment","measure_unit","ml","ml","ul","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (10,"treatment","measure_unit","mg","mg","ug","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (11,"treatment","measure_unit","°","°","°","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (12,"sample","age_unit","hour","hour","day","X / 24");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (13,"sample","age_unit","day","day","day","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (14,"sample","age_unit","week","week","day","X*7");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (15,"sample","age_unit","month","month","day","X * 30");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (16,"extract","quantity_unit","ng","ng","ug","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (17,"extract","quantity_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (18,"extract","quantity_unit","mg","mg","ug","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (19,"extract","material_unit","g","g","g","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (20,"extract","material_unit","ug","ug","g","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (21,"extract","material_unit","mg","mg","g","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (22,"labelled_protocol","concentration_unit","pM","pM","uM","X * 1000 * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (23,"labelled_protocol","concentration_unit","nM","nM","uM","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (24,"labelled_protocol","concentration_unit","uM","uM","uM","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (25,"labelled_protocol","concentration_unit","mM","mM","uM","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (26,"labelled_protocol","quantity_unit","pg","pg","ug","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (27,"labelled_protocol","quantity_unit","ng","ng","ug","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (28,"labelled_protocol","quantity_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (29,"labelled_protocol","quantity_unit","mg","mg","ug","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (30,"extract_pool","quantity_unit","ng","ng","ug","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (31,"extract_pool","quantity_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (32,"extract_pool","quantity_unit","mg","mg","ug","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (33,"hybridization","quantity_unit","ng","ng","ug","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (34,"hybridization","quantity_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (35,"hybridization","quantity_unit","mg","mg","ug","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (36,"hybridization","quantity_unit","pg","pg","ug","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (37,"labelled_protocol","quantity_unit","pmol","pmol","umol","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (38,"labelled_protocol","quantity_unit","nmol","nmol","umol","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (39,"labelled_protocol","quantity_unit","umol","umol","umol","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (40,"labelled_protocol","quantity_unit","mmol","mmol","umol","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (41,"extract_pool","quantity_unit","nmol","nmol","umol","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (42,"extract_pool","quantity_unit","umol","umol","umol","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (43,"extract_pool","quantity_unit","mmol","mmol","umol","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (44,"hybridization","quantity_unit","nmol","nmol","umol","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (45,"hybridization","quantity_unit","umol","umol","umol","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (46,"hybridization","quantity_unit","mmol","mmol","umol","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (47,"hybridization","quantity_unit","pmol","pmol","umol","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (48,"hybridization","quantity2_unit","ng","ng","ug","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (49,"hybridization","quantity2_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (50,"hybridization","quantity2_unit","mg","mg","ug","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (51,"hybridization","quantity2_unit","pg","pg","ug","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (52,"hybridization","quantity2_unit","nmol","nmol","umol","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (53,"hybridization","quantity2_unit","umol","umol","umol","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (54,"hybridization","quantity2_unit","mmol","mmol","umol","X * 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (55,"hybridization","quantity2_unit","pmol","pmol","umol","X / 1000 / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (57,"IP","quantity_unit","ul","ul","ul","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (58,"treatment","measure_unit","cfu/g","cfu/g","cfu/g","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (59,"treatment","measure_unit","cfu/ml","cfu/ml","cfu/ml","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (60,"treatment","measure_unit","g/l","g/l","g/l","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (56,"IP","quantity_unit","ug","ug","ug","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (61,"treatment","measure_unit","l/ha","l/ha","l/ha","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (63,"treatment","measure_unit","uE","uE","uE","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (62,"treatment","measure_unit","uM","uM","mM","X / 1000");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (60,"treatment","measure_unit","nM","nM","nM","X");
INSERT INTO unit_list (unit_id,table_name,attribut_name,unit_name,unit_abv,unit_db,formula) VALUES (64,"sample","age_unit","year","year","day","X * 365");
