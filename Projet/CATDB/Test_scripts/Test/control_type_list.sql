CREATE TABLE control_type_list (
control_id integer NULL,
control_type VARCHAR (50) NOT NULL );
INSERT INTO control_type_list (control_id,control_type) VALUES (0,"NO CONTROL");
INSERT INTO control_type_list (control_id,control_type) VALUES (1,"EMPTY");
INSERT INTO control_type_list (control_id,control_type) VALUES (2,"CONTROL +");
INSERT INTO control_type_list (control_id,control_type) VALUES (3,"CONTROL -");
INSERT INTO control_type_list (control_id,control_type) VALUES (4,"BUFFER");
INSERT INTO control_type_list (control_id,control_type) VALUES (5,"UNKNOWN");
INSERT INTO control_type_list (control_id,control_type) VALUES (6,"FLAGGED");
