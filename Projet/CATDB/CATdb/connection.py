#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from django.db import models

# Create your models here.

import psycopg2
from CATdb.config import config
from django.test.html import Element
#from config import config
#import psycopg2.extras 

def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config()
 
        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
 
        # create a cursor
        cur = conn.cursor()
        
        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')
 
        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
       
     # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
def read_data_sql(requete,element):
    "input requete outupt data"
    """
    requete='select * from chips.experiment;'
    """
    #data=requete.replace("'","").replace(";","").split()
    #if data[0]=='select' and requete[-1]==';':
    conn = None
    params = config()
    conn = psycopg2.connect(**params)
    cursor = conn.cursor()#cursor_factory=psycopg2.extras.DictCursor
    cursor.execute(requete)
    colnames = [desc[0] for desc in cursor.description]
    memory = cursor.fetchall()
    conn.close()
    #else:
    #    memory=requete
    #    print("Merci de verifier")

    cpt=0
    data=dict()
    for ele in range(len(memory)):
        cpt=cpt+1
        col=[]
        for ele1 in memory[ele]:
            col.append(str(ele1))
        dictionary ={'_key':cpt,"_value":dict(zip(colnames,col))}
        data[cpt]=dictionary
    name=element+'.csv'     
    #with open("/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/Test_scripts/"+name,"w") as ecr:
    #    ecr.write(str(data))
    #    ecr.close()
    return data

def execution_requete(element,value_send,colname_send):
    ### parametres
    my_ppty="CHIPS"

    # requete sur la nouvelle table info_catdbindex
    my_reqinfo ="Select info_code, info_value, info_name from "+my_ppty+".info_catdbindex order by info_code;"
    
    
    # creation/tri des infos :(creation de structures de données)
    ###Todo
    
    # Bilan Chiffres nbr de puces par especes
    # pas Arabidopsis dans nouveau champ common_name d'array_type et 
    # analysis_type='Arrays'
    # partie requete
    my_querySpecies="select array_type_name, count(hybridization_id) "+\
    "from "+my_ppty+".hybridization "+\
    "where project_id in (select project_id from "+my_ppty+".project where is_public='yes') "+\
    "and experiment_id in (select experiment_id from "+my_ppty+".experiment "+\
    "where analysis_type='Arrays') "+\
    "and array_type_name in "+\
    "(select a.array_type_name from "+my_ppty+".array_type a where a.common_name<>'Arabidopsis')"+\
    "group by array_type_name order by array_type_name;"
    
    #Pour le nombre de ref biblio
    my_reqstat ="Select count(*) from "+my_ppty+".biblio_list;"
    
    
    my_req_special="select o.organism_name,count(distinct ss.project_id) from chips.sample_source ss,chips.organism o where ss.project_id in( select project_id from chips.project where is_public='yes') and ss.organism_id=o.organism_id group by o.organism_name;"
    
    my_req_recherche="SELECT * FROM global_search_element('Arabidopsis',param_schemas:=array['chips']);"
    
    my_req_recherche1="select project_id,Experiment_type,Experiment_name from chips.experiment where project_id in (select project_id from chips.project where is_public='yes');"
    
    #experiement="select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes'));"
    
    experiement="select * from (select S.project_name,O.project_id,O.experiment_name,O.experiment_type from chips.experiment O,chips.project S where O.project_id in (select project_id from chips.project where is_public='yes')) df limit 100;"
    
    
    
    try:
        my_req_recherche_av="select * from "+colname_send+" where (is_public='yes' and project_name like '%"+value_send+"%');"
    except:
        pass
    if element=='my_reqinfo':
        requete=my_reqinfo
    elif element=='my_querySpecies':
        requete=my_querySpecies
    elif element=='my_reqstat':
        requete=my_reqstat    
    elif element=='my_req_special':
        requete=my_req_special    
    elif element=='my_req_recherche':
        requete=my_req_recherche        
    elif element=='my_req_recherche_av' and colname_send!=None and value_send!=None:
        requete=my_req_recherche_av     
    elif element=='my_req_recherche1':
        requete=my_req_recherche1
    elif element=='experiement':
        requete=experiement           
    else:
        try:
            requete=eval(element)
        except:
            requete=None
            pass
    if requete!=None:
        return read_data_sql(requete,element)    
    else:
        print("error") 

def execution_requete_new(element,value_send,colname_send,order_by):
    """
    fonction faite pour envoyer des orders by
    """
    my_ppty="CHIPS"
    
    my_querySpecies="select * from (select array_type_name, count(hybridization_id) "+\
    "from "+my_ppty+".hybridization "+\
    "where project_id in (select project_id from "+my_ppty+".project where is_public='yes') "+\
    "and experiment_id in (select experiment_id from "+my_ppty+".experiment "+\
    "where analysis_type='Arrays') "+\
    "and array_type_name in "+\
    "(select a.array_type_name from "+my_ppty+".array_type a where a.common_name<>'Arabidopsis')"+\
    "group by array_type_name order by array_type_name) pf order by pf."+order_by+";"
    
    
    #my_req_recherche1="select project_id,Experiment_type,Experiment_name from chips.experiment where project_id in (select project_id from chips.project where is_public='yes');"

    
    
    return read_data_sql(my_querySpecies,'text')    
    