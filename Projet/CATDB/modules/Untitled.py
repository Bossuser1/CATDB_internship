#!/usr/bin/env python
# coding: utf-8

# In[154]:


#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from django.db import models
# Create your models here.
import psycopg2
#from config import config
from django.test.html import Element
import os
import bs4, sys
from urllib.request import urlopen
from bs4 import BeautifulSoup
sys.path.insert(0, "../")

link_experiment="http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id="
from configparser import ConfigParser

def config(section='postgresql'):
    #os.getcwd()
    direction='/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb'
    if os.getcwd()[0:12]!="/home/traore":
    	filename=direction+'/database.ini'
    else:
    	filename=direction+'/database2.ini'
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)
    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))
 
    return db


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

def read_data_sql(requete):
    """
    input requete outupt data
    requete='select * from chips.experiment;'
    """
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
    return data


# In[ ]:





# In[ ]:





# In[143]:


def controleur_existance_old_expermiment(link_experiment,experiment_id):
    """permet de connaitre si le projet est present sur le site actuel"""
    html = urlopen(link_experiment+str(experiment_id)) # Insert your URL to extract
    bsObj = BeautifulSoup(html.read());

    for link in bsObj.find_all("div", {"class": 'titre'}):
        text=link.text.replace(' ','')
    if len(text)==0:
        return False
    else:
        return True   


# In[200]:


def project_rna_seq_info(experiment_id):
    response={}
    try:
        requete="select * from chips.experiment,chips.project where project.project_id=experiment.project_id and experiment.experiment_id="+str(experiment_id)+";"
        data=read_data_sql(requete)
        response=data[1]['_value']
        if data[1]['_value']['analysis_type']=='RNA-Seq':
            try:
                requete="SELECT * from chips.rnaseqdata where rnaseqdata.project_id="+data[1]['_value']['project_id']+"and rnaseqdata.experiment_id="+data[1]['_value']['experiment_id']+";" 
                current_data=read_data_sql(requete)
                if len(current_data)==1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element]
            except:
                pass
            try:
                requete="SELECT * from chips.rnaseqlibrary where rnaseqlibrary.project_id="+data[1]['_value']['project_id']+"and rnaseqlibrary.experiment_id="+data[1]['_value']['experiment_id']+";" 
                current_data=read_data_sql(requete)
                if len(current_data)==1:
                    for element in current_data[1]['_value'].keys():
                            response[element]=current_data[1]['_value'][element]    
            except:
                pass
            try:
                requete="SELECT * from chips.sample,chips.sample_source,chips.organism,chips.ecotype where organism.organism_id=sample_source.organism_id and ecotype.ecotype_id=sample_source.ecotype_id and sample.project_id=sample_source.project_id and sample_source.sample_source_id=sample.sample_source_id and sample.experiment_id=sample_source.experiment_id and sample.project_id="+data[1]['_value']['project_id']+" and sample.experiment_id="+data[1]['_value']['experiment_id']+";"
                current_data=read_data_sql(requete)
                response['echantillon_nb']=len(current_data)
                response['echantillon']=current_data
            except:
                pass
            ###for publmed
            try:
                requete="SELECT * from chips.project_Biblio,chips.Biblio_list,chips.project where Biblio_list.pubmed_id=project_Biblio.pubmed_id and project.project_id=project_Biblio.project_id and project.project_id="+data[1]['_value']['project_id']+";"
                current_data=read_data_sql(requete)
                if len(current_data)>1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element]
            except:
                pass
            try:
                ###for contact coordiantor
                requete="SELECT * from chips.project_coordinator,chips.contact,chips.project where contact.contact_id=project_coordinator.contact_id and project.project_id=project_coordinator.project_id and project.project_id="+data[1]['_value']['project_id']+";"

                current_data=read_data_sql(requete)
                if len(current_data)>0:
                    response['coordiantor_nb']=len(current_data)
                    for rk in range(1,len(current_data)+1):
                        for element in current_data[rk]['_value'].keys():
                            response['coordiantor_'+str(rk)+'_'+element]=current_data[rk]['_value'][element]
            except:
                pass
            try:
                requete="SELECT * from chips.project,chips.experiment where project.project_id=experiment.project_id and project.project_id="+data[1]['_value']['project_id']+";"         
                current_data=read_data_sql(requete)
                if len(current_data)>0:
                    response['other_experiment_nb']=len(current_data)-1
                    for rk in range(1,len(current_data)):
                        if current_data[rk]['_value']['experiment_id']!=data[1]['_value']['experiment_id']:
                            for element in current_data[rk]['_value'].keys():
                                response['other_experiment_'+str(rk)+'_'+element]=current_data[rk]['_value'][element]
            except:
                pass
                    
            try:
                #protocol
                requete="SELECT * from chips.protocol where protocol.protocol_id="+response['protocol_id']+";"
                current_data=read_data_sql(requete)
                if len(current_data)>1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element]   
            except:
                pass
            try:
                #labelled_extract
                requete="SELECT * from chips.labelled_extract,chips.experiment where labelled_extract.project_id=experiment.project_id and  labelled_extract.experiment_id=experiment.experiment_id and labelled_extract.project_id="+data[1]['_value']['project_id']+" and experiment.experiment_id="+data[1]['_value']['experiment_id']+";"
                current_data=read_data_sql(requete)
                if len(current_data)>1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element] 
            except:
                pass
            #replicats
            requete="SELECT * from chips.replicats,chips.experiment,chips.project where  replicats.experiment_id=experiment.experiment_id and replicats.project_id=experiment.project_id and project.project_id="+data[1]['_value']['project_id']+" and experiment.experiment_id="+data[1]['_value']['experiment_id']+";"
            
            current_data=read_data_sql(requete)
            response['replicats']=len(current_data)
            for rv in range(1,len(current_data)+1):
                response['replicats_'+str(rv)]=current_data[rv]['_value']
                requete="SELECT * from chips.replicats,chips.diff_Analysis_value where diff_Analysis_value.replicat_id=replicats.replicat_id and replicats.replicat_id="+response['replicats_'+str(rv)]['replicat_id']+";"
                current_data1=read_data_sql(requete)
                if (len(current_data1)>0):
                    response['replicats_'+str(rv)+'diff_Analysis_value']=current_data1
                requete="SELECT * from chips.replicats,chips.stat_diff_Analysis where chips.stat_diff_Analysis.replicat_id=replicats.replicat_id and replicats.replicat_id="+response['replicats_'+str(rv)]['replicat_id']+";"
                current_data2=read_data_sql(requete)
    except:
        print("attention")
        pass
    return response


# In[222]:


experiment_id=591
project_rna_seq_info(experiment_id)#['echantillon_nb']

import json

with open('data.txt') as json_file:  
    data = json.load(json_file)




