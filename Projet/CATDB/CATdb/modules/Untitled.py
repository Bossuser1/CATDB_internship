#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from django.db import models
# Create your models here.
import psycopg2
#from config import config
from django.test.html import Element
import os
import bs4, sys
import operator
import json

#from urllib.request import urlopen
from bs4 import BeautifulSoup
sys.path.insert(0, "../")

schema="public" #'chips'#

link_experiment="http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id="
from configparser import ConfigParser

def config(section='postgresql'):
    #os.getcwd()
    direction='/home/traore/Bureau/Dossier_Stage/CATDB_internship/Projet/CATDB/CATdb/'#'/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb''/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb'
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
    requete='select * from "+schema+".experiment;'
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
        requete="select * from "+schema+".experiment,"+schema+".project where project.project_id=experiment.project_id and experiment.experiment_id="+str(experiment_id)+";"
        data=read_data_sql(requete)
        response=data[1]['_value']
        if data[1]['_value']['analysis_type']=='RNA-Seq':
            try:
                requete="SELECT * from "+schema+".rnaseqdata where rnaseqdata.project_id="+data[1]['_value']['project_id']+"and rnaseqdata.experiment_id="+data[1]['_value']['experiment_id']+";" 
                current_data=read_data_sql(requete)
                if len(current_data)==1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element]
            except:
                pass
            try:
                requete="SELECT * from "+schema+".rnaseqlibrary where rnaseqlibrary.project_id="+data[1]['_value']['project_id']+"and rnaseqlibrary.experiment_id="+data[1]['_value']['experiment_id']+";" 
                current_data=read_data_sql(requete)
                if len(current_data)==1:
                    for element in current_data[1]['_value'].keys():
                            response[element]=current_data[1]['_value'][element]    
            except:
                pass
            try:
                requete="SELECT * from "+schema+".sample,"+schema+".sample_source,"+schema+".organism,"+schema+".ecotype where organism.organism_id=sample_source.organism_id and ecotype.ecotype_id=sample_source.ecotype_id and sample.project_id=sample_source.project_id and sample_source.sample_source_id=sample.sample_source_id and sample.experiment_id=sample_source.experiment_id and sample.project_id="+data[1]['_value']['project_id']+" and sample.experiment_id="+data[1]['_value']['experiment_id']+";"
                current_data=read_data_sql(requete)
                response['echantillon_nb']=len(current_data)
                response['echantillon']=current_data
            except:
                pass
            ###for publmed
            try:
                requete="SELECT * from "+schema+".project_Biblio,"+schema+".Biblio_list,"+schema+".project where Biblio_list.pubmed_id=project_Biblio.pubmed_id and project.project_id=project_Biblio.project_id and project.project_id="+data[1]['_value']['project_id']+";"
                current_data=read_data_sql(requete)
                if len(current_data)>1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element]
            except:
                pass
            try:
                ###for contact coordiantor
                requete="SELECT * from "+schema+".project_coordinator,"+schema+".contact,"+schema+".project where contact.contact_id=project_coordinator.contact_id and project.project_id=project_coordinator.project_id and project.project_id="+data[1]['_value']['project_id']+";"

                current_data=read_data_sql(requete)
                if len(current_data)>0:
                    response['coordiantor_nb']=len(current_data)
                    for rk in range(1,len(current_data)+1):
                        for element in current_data[rk]['_value'].keys():
                            response['coordiantor_'+str(rk)+'_'+element]=current_data[rk]['_value'][element]
            except:
                pass
            try:
                requete="SELECT * from "+schema+".project,"+schema+".experiment where project.project_id=experiment.project_id and project.project_id="+data[1]['_value']['project_id']+";"         
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
                requete="SELECT * from "+schema+".protocol where protocol.protocol_id="+response['protocol_id']+";"
                current_data=read_data_sql(requete)
                if len(current_data)>1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element]   
            except:
                pass
            try:
                #labelled_extract
                requete="SELECT * from "+schema+".labelled_extract,"+schema+".experiment where labelled_extract.project_id=experiment.project_id and  labelled_extract.experiment_id=experiment.experiment_id and labelled_extract.project_id="+data[1]['_value']['project_id']+" and experiment.experiment_id="+data[1]['_value']['experiment_id']+";"
                current_data=read_data_sql(requete)
                if len(current_data)>1:
                    for element in current_data[1]['_value'].keys():
                        response[element]=current_data[1]['_value'][element] 
            except:
                pass
            #replicats
            requete="SELECT * from "+schema+".replicats,"+schema+".experiment,"+schema+".project where  replicats.experiment_id=experiment.experiment_id and replicats.project_id=experiment.project_id and project.project_id="+data[1]['_value']['project_id']+" and experiment.experiment_id="+data[1]['_value']['experiment_id']+";"
            
            current_data=read_data_sql(requete)
            response['replicats']=len(current_data)
            for rv in range(1,len(current_data)+1):
                response['replicats_'+str(rv)]=current_data[rv]['_value']
                requete="SELECT * from "+schema+".replicats,"+schema+".diff_Analysis_value where diff_Analysis_value.replicat_id=replicats.replicat_id and replicats.replicat_id="+response['replicats_'+str(rv)]['replicat_id']+";"
                current_data1=read_data_sql(requete)
                if (len(current_data1)>0):
                    response['replicats_'+str(rv)+'diff_Analysis_value']=current_data1
                requete="SELECT * from "+schema+".replicats,"+schema+".stat_diff_Analysis where "+schema+".stat_diff_Analysis.replicat_id=replicats.replicat_id and replicats.replicat_id="+response['replicats_'+str(rv)]['replicat_id']+";"
                current_data2=read_data_sql(requete)
    except:
        print("attention")
        pass
    return response


# In[222]:


#experiment_id=100#591
#data1=project_rna_seq_info(experiment_id)#['echantillon_nb']




class data_table:
    def __init__(self,name):
        self.name=name
        self.list=[]
        self.data=[]
        self.current_data={}
        self.i=1
        
    def get_project_id_free(self):
        self.list=[]
        requete="select experiment.experiment_id, experiment.project_id from "+schema+".project,"+schema+".experiment  where project.project_id=experiment.project_id ;" #and is_public='yes'
        data=read_data_sql(requete)
        for el in range(1,len(data)+1):
            self.list.append(data[el]['_value']['experiment_id'])
        return self.list
    def get_unit_experminent(self):
        #print(self.list[self.i])
        direction='/home/traore/Bureau/Dossier_Stage/CATDB_internship/Projet/CATDB/CATdb/'#'/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb'#'/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb'#
        with open(direction+'/modules/data/test.json') as json_file:  
            for elemnt in json_file.readlines():
                try:
                    seq=elemnt.replace('{','').replace(' ','').replace('"','').replace(',','').split(':')
                    self.current_data[seq[0]]=seq[1]
                except:
                    pass
        return self.current_data    

    def get_all_table(self):
        for self.i in range(1,len(self.list)):
            #print(self.list[self.i])
            dat=project_rna_seq_info(self.list[self.i])
            #dat=self.get_unit_experminent()
            if (len(dat))>1:
                self.data.append(dat)
            #self.data.append(self.get_unit_experminent())
            #self.data[self.i]=self.get_unit_experminent()
        return self.data
    def sorted_data(self,col):
        self.data=sorted(self.data, key=operator.itemgetter(col))
        return self.data
    def get_specifique_data(self):
        colspecifique=['experiment_id','title','organism_name','organ','analysis_type','project_name','experiment_type','experiment_name','echantillon_nb','replicats']
        collabel=['Id','Title','Organism_name','organ','Analysis_type','Project_name','Experiment_type','Experiment_name','Size of Echantillon','Size of Replicats']

        selection=[]
        
        for k in self.data:
            sel={}
            for el in k.keys():
                if el in colspecifique:
                    sel[el]=k[el]
            selection.append(sel)
        gridarea=''
        for j in range(len(collabel)):
            gridarea=gridarea+'10px '
        gridarea=gridarea+'auto'    
        html="<table class='table table-bordered table-striped mb-0' cellspacing='0'width='100%'>" #table-bordered table-striped mb-0
        head_table="<thead><tr style='overflow-wrap: break-word;display: grid;grid-template-columns: "+gridarea+";' ><th class='th-sm col0'><input type='checkbox' id='all_call'></th>"
        for k in range(len(colspecifique)):
            head_table=head_table+'<th class="th-sm col'+str(k+1)+'">'+str(collabel[k])+'</th>'
        html=html+head_table+"</tr></thead><tbody>"
        for k in range(len(selection)):
            text="<td class='col0'><input type='checkbox' id='select_row"+str(k)+"'></td>"
            cpt=0
            for el in colspecifique:
                cpt=cpt+1
                try:
                    ans=selection[k][el]
                except:
                    ans=''
                    pass
                text=text+"<td class='col"+str(cpt)+"'>"+str(ans)+"</td>"
            html=html+"<tr>"+text+"</tr>"
        html=html+"</tbody></table>"
        return selection,html
    def specifique_information(self,col,ident):
        html="<div class='row'>"        
        for k in self.data:
            if k[col]==ident:
                #block description
                html=html+"<div class='description'><div><span>Project:<span><label>"+k['project_name']+"</label></div>"+"<div><span>Experiment Name:<span><label>"+k['experiment_name']+"</label></div>"+"<div><span>Experiment type:<span><label>"+k['experiment_type']+"</label></div>"
                try:
                    nb_ex=int(k['other_experiment_nb'])
                    if nb_ex>0:
                        for el in range(1,nb_ex+1):
                            html=html+"<div><span>Other Experiment "+str(el)+":</span><label>"+str(k['other_experiment_'+str(el)+'_experiment_name'])+"</label></div>"
                except:
                    pass
                html=html+'</div>'
                #block contact 
                html=html+"<div class='contact_prod'>"
                
                try:
                    nb_ex=int(k['coordiantor_nb'])
                    if nb_ex>0:
                        for el in range(1,nb_ex+1):
                            html=html+"<div><span>Contact "+str(el)+":</span><label>"+str(k['coordiantor_'+str(el)+'_last_name'])+"</label></div>"
                except:
                    pass
                html=html+"</div></div>"
                print(k)
                
                html=html+"<div class='biological_project'><span>Biologicial Interest:</span>"+k['biological_interest']+"</div>"
                #html=html+"<div class='row'>"
                #'gem2net_id'
                #'source'
                #<a class="btn btn-primary"></a>
                #   "<div>"
                return html
        return None
    
"""    
tableau=data_table('pass')
tableau.get_project_id_free()
tableau.get_all_table()
tableau.sorted_data('project_id')

av=tableau.get_specifique_data()
"""
