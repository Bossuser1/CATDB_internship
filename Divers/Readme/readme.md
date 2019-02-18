### for jacob
ssh -XC btraore@jacob.ips2.u-psud.fr

smb://filer-ips2.ups.u-psud.fr/ips2$

/TEMPO/gnet/BIOINFO

cd ~
###for database
psql -p 1521 -U uselect -d CATDB 


python manage.py runserver jacob.ips2.u-psud.fr:8080

select o.organism_name,count(distinct ss.project_id) from chips.sample_source ss,chips.organism o where ss.project_id in( select project_id from chips.project where is_public='yes') and ss.organism_id=o.organism_id group by o.organism_name;

psql postgresql://uselect:seloct06@localhost:1521/CATDB

#pour la documentation
/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/docs/build/html/index.html
/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/docs.


pour les mises a jour du fichier static

1- assurer vous que le fichier setting.py du projet sois en absolue tels que ci dessous
STATIC_ROOT =os.path.join(BASE_DIR,'static')
/static/'# os.path.join(BASE_DIR,'static')
STATIC_URL = '/static/'



rpm2cpio numpy-1.7.1-13.el7.x86_64.rpm | cpio -ivd

2- aller dans le dossier principal et faite 

python manage.py collectstatic

####les couleurs

vert de IPS #81b92f


#slider {
    width: 200px;
    height: 100%;
    background-color: #79CC00;
    position: relative;
    box-shadow: 1px 1px 12px #a3ab98;
}

#copier vers le servers
scp info-circle-solid.svg btraore@jacob.ips2.u-psud.fr:/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb/static/icons/info-cirlce-solid.svg

scp /home/IPS2/btraore/Téléchargements/book-cover-svgrepo-com.svg btraore@jacob.ips2.u-psud.fr:/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb/static/icons/book-cover-svgrepo-com.svg


scp -r /home/IPS2/btraore/Documents/Document btraore@jacob.ips2.u-psud.fr:/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/Test_scripts

/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB

scp -r btraore@jacob.ips2.u-psud.fr:/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/ home/IPS2/btraore/Documents/Document
scp -r btraore@jacob.ips2.u-psud.fr:/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/ /home/IPS2/btraore/Bureau/Stage/Projet/
