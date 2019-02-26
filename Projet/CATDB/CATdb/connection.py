#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from django.db import models

# Create your models here.

import psycopg2
from CATdb.config import config
from django.test.html import Element
import os
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
    return data

def execution_requete(element,value_send,colname_send,order_ele=None):
    ### parametres
    if os.getcwd()[0:12]!="/home/traore":
    	my_ppty="chips"
    else:
    	my_ppty="public" #CHIPS

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
    
    
    #my_req_special="select o.organism_name,count(distinct ss.project_id) from "+my_ppty+".sample_source ss,"+my_ppty+".organism o where ss.project_id in( select project_id from "+my_ppty+".project where is_public='yes')  group by o.organism_name;"
    my_req_special="select o.organism_name,count(distinct ss.project_id) from "+my_ppty+".sample_source ss,"+my_ppty+".organism o where ss.project_id in( select project_id from "+my_ppty+".project ) and ss.organism_id=o.organism_id group by o.organism_name;" #where is_public='yes'
    
    my_req_recherche="SELECT * FROM global_search_element('Arabidopsis',param_schemas:=array['chips']);"
    
    my_req_recherche1="select project_id,Experiment_type,Experiment_name from "+my_ppty+".experiment where project_id in (select project_id from "+my_ppty+".project where is_public='yes');"
    
    #experiement="select * from chips.experiment where project_id in (select project_id from chips.project where is_public='yes'));"
    
    experiement="select * from (select S.project_name,O.project_id,O.experiment_name,O.experiment_type from "+my_ppty+".experiment O,"+my_ppty+".project S where O.project_id in (select project_id from "+my_ppty+".project where is_public='yes')) df limit 100;"
    
    get_project="select * from  "+my_ppty+".project where project.project_id="+value_send+";"
    
    get_contact="select contact.contact_id,contact.first_name,contact.last_name,contact.phone,contact.email,contact.institution,contact.laboratory,contact.address from "+my_ppty+".project_coordinator,"+my_ppty+".contact,"+my_ppty+".project where project.project_id=project_coordinator.project_id and contact.contact_id=project_coordinator.contact_id and project.project_id="+value_send+";"
    
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
    elif element=='get_project' and value_send!=None:
        requete=get_project 
    elif element=='get_contact' and value_send!=None:
        requete=get_contact
    else:
        try:
            requete=eval(element)
        except:
            requete=None
            pass
    
    my_req_special="select o.organism_name,count(distinct ss.project_id) from "+my_ppty+".sample_source ss,"+my_ppty+".organism o where ss.project_id in( select project_id from "+my_ppty+".project where is_public='yes') and ss.organism_id=o.organism_id group by o.organism_name;"
    
    
    
    if  element=='my_req_special' and order_ele==None:
         requete=my_req_special  
    elif element=='my_req_special' and order_ele!=None:    
        requete="select * from ("+requete.replace(";",')')+' dfg order by dfg.'+order_ele+";"
    elif  element=='my_querySpecies' and order_ele==None:
         requete=my_querySpecies  
    elif element=='my_querySpecies' and order_ele!=None:    
        requete="select * from ("+requete.replace(";",')')+' dfg order by dfg.'+order_ele+";"
    elif  element=='my_req_recherche1' and order_ele==None:
         requete=my_req_recherche1  
    elif element=='my_req_recherche1' and order_ele!=None:    
        requete="select * from ("+requete.replace(";",')')+' dfg order by dfg.'+order_ele+";"
    
    
    
        
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
    

def execution_requete_main_A(element,value_send,colname_send):
    my_ppty='CHIPS'
    my_reqstat ="Select count(*) from "+my_ppty+".biblio_list;"
    
    my_sample="SELECT sample.sample_name, sample.organ, sample.age_value, sample.age_unit, sample.age_db FROM "+my_ppty+".sample, "+my_ppty+".project WHERE project.project_id = sample.project_id AND project.is_public = 'yes';"
    
    my_sample_source="SELECT sample_source.project_id,sample_source.sample_source_name,organism.organism_name,sample_source.genotype,sample_source.mutant, sample_source.planting_date FROM "+my_ppty+".sample_source, "+my_ppty+".project , "+my_ppty+".organism, "+my_ppty+".Ecotype WHERE project.project_id=sample_source.project_id and project.is_public = 'yes' and Ecotype.ecotype_id=CAST(nullif(sample_source.ecotype_id, '') AS integer);"

    requete=my_sample_source
    if colname_send!=None:
    	requete="select * from ("+requete.replace(';','')+") df order by "+colname_send+";" 
    return read_data_sql(requete,element)	
