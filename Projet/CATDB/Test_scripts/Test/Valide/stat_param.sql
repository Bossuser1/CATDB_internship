CREATE TABLE stat_param (
stat_param_id integer NULL,
stat_protocol_id integer NOT NULL,
param_name VARCHAR (30) NOT NULL,
value VARCHAR (30) NOT NULL,
default_value smallint NOT NULL );
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (3,3,"flag","-100",1);
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (1,1,"flag","-100",1);
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (2,2,"flag","-100",1);
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (4,5,"flag","-100",1);
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (5,8,"flag","-100",1);
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (6,15,"flag","-100",1);
INSERT INTO stat_param (stat_param_id,stat_protocol_id,param_name,value,default_value) VALUES (12,16,"flag","c(-75,-100)",1);
