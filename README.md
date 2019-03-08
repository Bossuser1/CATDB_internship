##CATDB

https://bl.ocks.org/mbhall88/22f91dc6c9509b709defde9dc29c63f2
dpkg-deb -x app.deb /path/to/target/dir/

dpkg -x libqt5gui5_5.11.3+dfsg-2_amd64.deb /home/IPS2/btraore/usr


libdbus-1-3 libqt5gui5 libqt5widgets5 libqt5qml5 libqt5quick5 libqt5webkit5 libqt5x11extras5 qml-module-qtquick2 qml-module-qtquick-controls qml-module-qtquick-dialogs qml-module-qtquick-window2 qml-module-qtquick-layouts

dpkg -x google-chrome-stable_current_amd64.deb /home/IPS2/btraore/usr


"select * from (select array_type_name, count(hybridization_id) from chips.hybridization where project_id in (select project_id from chips.project where is_public='yes') and experiment_id in (select experiment_id from chips.experiment where analysis_type='Arrays') and array_type_name in (select a.array_type_name from chips.array_type a where a.common_name<>'Arabidopsis') group by array_type_name) order by array_type_name;"

select * from (select array_type_name, count(hybridization_id) from chips.hybridization where project_id in (select project_id from chips.project where is_public='yes') and experiment_id in (select experiment_id from chips.experiment where analysis_type='Arrays') and array_type_name in (select a.array_type_name from chips.array_type a where a.common_name=='Arabidopsis') group by array_type_name) pf order by pf.array_type_name;


select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes');

select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes') INTO OUTFILE '/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/Test_scripts/chips_experiment.csv' FIELDS TERMINATED BY '#' ENCLOSED BY '$'LINES TERMINATED BY '\n';

select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes');

COPY (select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes')) to /export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/Test_scripts/chips_experiment.csv';


select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes'));

select S.project_name,O.project_id,O.experiment_name,O.experiment_type from chips.experiment O,chips.project S where O.project_id in (select project_id from chips.project where is_public='yes');

select * from (select S.project_name,O.project_id,O.experiment_name,O.experiment_type from chips.experiment O,chips.project S where O.project_id in (select project_id from chips.project where is_public='yes')) df limit 10;


SELECT Orders.OrderID, Customers.CustomerName, Orders.OrderDate
FROM Orders INNER JOIN Customers ON Orders.CustomerID=Customers.CustomerID;

copy (select S.project_name,O.project_id,O.experiment_name,O.experiment_type from chips.experiment O,chips.project S where O.project_id in (select project_id from chips.project where is_public='yes'))  to '/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/Test_scripts/chips_experiment.csv' csv header;


psql -U uselect -d CATDB -f test.sql
psql -p 1521 -U uselect -d CATDB -h dayhoff.ips2.u-psud.fr

pg_dump -U postgres -O <dbname> > <dbname>.sql
pg_dump -p 1521 -U uselect -d CATDB -h dayhoff.ips2.u-psud.fr

pg_dump -p 1521 -U uselect -d CATDB -h dayhoff.ips2.u-psud.fr  -N chips.extract_replicats -T spatial_ref_sys > dbexport.pgsql
pg_dump -Fd CATDB -f CATDB.sql

copy (select * from (select S.project_name,O.project_id,O.experiment_name,O.experiment_type from chips.experiment O,chips.project S where O.project_id in (select project_id chips.project where is_public='yes')) df limit 10;) to '/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/Test_scripts/chips_experiment.csv' csv header;


pg_dump -Fp -U db_superuser db_name > db.backup


git remote set-url origin git@github.com:Bossuser1/CATDB_internship.git
git clone https://github.com/Bossuser1/CATDB_internship.git

pg_dump -Fd CATDB -p 1521 -U uselect -h jacob.ips2.u-psud.fr -f /export/home/gnet/btraore/CATDB.sql

cp -r /export/home/gnet/btraore/CATDB_internship/Projet/CATDB/ /export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/
