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

schema='chips'#

link_experiment="http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id="
from configparser import ConfigParser

def config(section='postgresql'):
    #os.getcwd()
    direction='/home/traore/Bureau/Dossier_Stage/CATDB_internship/Projet/CATDB/CATdb/'#'/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb'#'/export/home/gnet/btraore/WWW_DEV/cgi-bin/projects/CATDB/CATdb'#
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
            
        A=True
        if data[1]['_value']['analysis_type']=='RNA-Seq':
            response=data[1]['_value']
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
                response['echantillon']=current_data[1]['_value']
                all_orgnaism=[]
                for element in range(1,len(current_data)+1):
                    all_orgnaism.append(current_data[element]['_value']['organism_name'])
                ans=list(set(all_orgnaism))
                an=ans[0]
                for element in range(1,len(ans)):
                    an=an+','+ans[element]
                response['organism_name']=an
                
            except:
                pass
            try:
                requete="Select distinct e.experiment_id, s.organ from "+schema+".experiment e, "+schema+".sample s, "+schema+".project p where e.experiment_id=s.experiment_id and e.project_id=p.project_id and  p.project_id="+data[1]['_value']['project_id']+" and e.experiment_id="+data[1]['_value']['experiment_id']+";" 
                current_data=read_data_sql(requete)
                #print(requete)
                organ=[]
                try:
                    for element in range(1,len(current_data)+1):
                        organ.append(current_data[element]['_value']['organ'])
                    ans=list(set(organ))
                    an=ans[0]
                    for element in range(1,len(ans)):
                        an=an+','+ans[element]
                    response['organ']=an
                except:
                    pass                    
            except:
                pass
            
            
            try:
                requete="select * from "+schema+".array_type, "+schema+".organism,"+schema+".organism_ecotype,"+schema+".array_batch, "+schema+".array df , "+schema+".hybridization where organism.organism_id=organism_ecotype.organism_id and array_type.array_type_id=organism_ecotype.array_type_id and array_type.array_type_id=array_batch.array_type_id and df.array_batch_id=array_batch.array_batch_id and hybridization.array_id=df.array_id and hybridization.project_id="+data[1]['_value']['project_id']+" and hybridization.experiment_id="+data[1]['_value']['experiment_id']+";" 
                current_data=read_data_sql(requete)
                if 'organism_name' not in response.keys():
                    all_orgnaism=[]
                    for element in range(1,len(current_data)+1):
                        all_orgnaism.append(current_data[element]['_value']['organism_name'])
                    ans=list(set(all_orgnaism))
                    an=ans[0]
                    for element in range(1,len(ans)):
                        an=an+','+ans[element]
                    response['organism_name']=an                    
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
                if len(current_data)>0:
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
        requete="select distinct experiment.experiment_id, experiment.project_id from "+schema+".project,"+schema+".experiment  where project.project_id=experiment.project_id ;"#and project.is_public='yes';"
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
        #print(self.data)
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
            head_table=head_table+'<th class="th-sm col'+str(k+1)+'" onclick="sorted_table(\'tableau\',\'col'+str(k+1)+'\',bestcss);">'+str(collabel[k])+'<i class="fas fa-sort-up"></i></th>'
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
        print(self.data[0])
        html="<div class='row'>"        
        for k in self.data:
            if k[col]==ident:
                #block description
                html=html+"<div class='description'><div><span>Project:</span><label>"+k['project_name']+"</label></div>"+"<div><span>Experiment Name:</span><label>"+k['experiment_name']+"</label></div>"+"<div><span>Experiment type:</span><label>"+k['experiment_type']+"</label></div>"+"<div><span>Sequencer:</span><label>"+k['array_type']+"</label> <span>Analysis type:</span><label>"+k['analysis_type']+"</label></div>" 
                try:
                    nb_ex=int(k['other_experiment_nb'])
                    if nb_ex>0:
                        for el in range(1,nb_ex+1):
                            html=html+"<div><span>Other Experiment "+str(el)+":</span><label>"+str(k['other_experiment_'+str(el)+'_experiment_name'])+"</label></div>"
                except:
                    pass
                try:
                    html=html+"<div><span>Experiment factors:</span><label>"+k['experiment_factors']+"</label></div>"
                except:
                    pass
                try:
                    html=html+"<div><span>Source:</span><label>"+k['source']+"</label></div>"
                except:
                    pass
                html=html+"</div>"
                #block contact 
                html=html+"<div class='contact_prod'>"
                
                try:
                    nb_ex=int(k['coordiantor_nb'])
                    if nb_ex>1:
                        html=html+'<div class="coordinateur_project_ele" style="    display: flex;"><span> Contact(s) </span><div class="progress-bar progress-bar-warning" style="margin-left: 5%;width: 12.5%;">'+str(nb_ex)+'</div></div>'
                    if nb_ex==1:
                        html=html+'<div class="coordinateur_project_ele" style="    display: flex;"><span> Contact </span><div class="progress-bar progress-bar-warning" style="margin-left: 5%; width: 12.5%;">'+str(nb_ex)+'</div></div>'
                    if nb_ex>0:
                        for el in range(1,nb_ex+1):
                            text='<div class="coordinateur_project_ele"><div><i class="fas fa-user-tie"></i><span>Name</span>: '+k['coordiantor_'+str(el)+'_last_name']+' '+k['coordiantor_'+str(el)+'_first_name']+'</div>'
                            #text=text+'<div><i class="fas fa-mobile-alt"></i><span>Phone: </span> '+k['coordiantor_'+str(el)+'_phone']+'</div><div><i class="fas fa-envelope"></i><span>Email</span>:'+k['coordiantor_'+str(el)+'_email']+'</div><div><i class="fas fa-university"></i><span>Insitution:</span>'+k['coordiantor_'+str(el)+'_institution']+'</div>'
                            #text=text+'<div><i class="far fa-building"></i><span>Laboratory: </span> '+k['coordiantor_'+str(el)+'_laboratory']+'</div><div><i class="fas fa-map-marked"></i><span>Address:</span>'+k['coordiantor_'+str(el)+'_address']+'</div></div>'
                            html=html+text+'</div>'
                            #html=html+"<div><span>Contact "+str(el)+":</span><label>"+str(k['coordiantor_'+str(el)+'_last_name'])+"</label></div>"
                except:
                    pass
                html=html+"</div></div>"
                #print(k)
                
                html=html+"<div class='biological_project'><span>Biologicial Interest:</span>"+k['biological_interest']+"</div>"
                
                html=html+"<div class='file_project'>  <a id='experim' href='/CATdb/experiment.html?exp='> link </a></div>"#<span>Biologicial Interest:</span>"+k['biological_interest']+"
                
                    
                #html=html+"<div class='row'>"
                #'gem2net_id'
                #'source'
                #<a class="btn btn-primary"></a>
                #   "<div>"
                return html
        return None



def get_experiment_rnaseq_information_select(key): 
    response={}
    requete="select n1.sample_name,n1.organ,n1.genotype,n1.growth_conditions,n1.sample_id,n2.treatment_name from (select sample.sample_name,sample.sample_id,sample.organ,sample_source.genotype,sample_source.growth_conditions,sample.experiment_id,sample_source.sample_source_id,sample.sample_source_id from chips.sample LEFT JOIN chips.sample_source ON sample_source.sample_source_id=sample.sample_source_id where sample.experiment_id="+str(key)+") as n1 , chips.treatment as n2 ,chips.sample_treated as n3 where n2.experiment_id="+str(key)+" and n3.treatment_id=n2.treatment_id and n1.sample_id=n3.sample_id;"
    current_data=read_data_sql(requete)
    colspecifique=['sample_id','sample_name','organ','genotype','treatment_name','growth_conditions']
    collabel=['Id','Name','organ','genotype','treatment','growth_conditions']
    
    selection=[]
    list_select=[]
    if len(current_data)>0:
        for k in range(1,len(current_data)+1):
            sel={}
            for el in current_data[k]['_value'].keys():
                if el in colspecifique:
                    sel[el]=current_data[k]['_value'][el]
            selection.append(sel)
            list_select.append(current_data[k]['_value']['sample_id'])
    text=""
    if len(list_select)>0:
        text=list_select[0]
        for val in range(1,len(list_select)):
            text=text+','+list_select[val]
    print(text)
    if text!="":
        requete="select n1.sample_id,n1.sample_name,n1.organ,n1.genotype,n1.growth_conditions from (select sample.sample_id,sample.sample_name,sample.organ,sample_source.genotype,sample_source.growth_conditions,sample.experiment_id,sample_source.sample_source_id,sample.sample_source_id from chips.sample LEFT JOIN chips.sample_source ON sample_source.sample_source_id=sample.sample_source_id where sample.sample_id not in ("+text+") and sample.experiment_id="+str(key)+") as n1 ;"
    else:
        requete="select n1.sample_id,n1.sample_name,n1.organ,n1.genotype,n1.growth_conditions from (select sample.sample_id,sample.sample_name,sample.organ,sample_source.genotype,sample_source.growth_conditions,sample.experiment_id,sample_source.sample_source_id,sample.sample_source_id from chips.sample LEFT JOIN chips.sample_source ON sample_source.sample_source_id=sample.sample_source_id where sample.experiment_id="+str(key)+") as n1 ;"
    current_data1=read_data_sql(requete)
    if len(current_data1)>0:
        for k in range(1,len(current_data1)+1):
            sel={}
            for el in current_data1[k]['_value'].keys():
                if el in colspecifique:
                    sel[el]=current_data1[k]['_value'][el]
            sel['treatment_name']="No treatment"
            selection.append(sel)
    if len(selection)>0:        
        gridarea=''
        for j in range(len(collabel)):
            gridarea=gridarea+'100px '
        gridarea=gridarea+'auto'    
        html="<table class='table table-bordered table-striped mb-0' cellspacing='0'width='100%'>" #table-bordered table-striped mb-0
        head_table="<thead><tr style='overflow-wrap: break-word;display: grid;grid-template-columns: "+gridarea+";' ><th class='th-sm col0'><input type='checkbox' id='all_call'></th>"
        for k in range(len(colspecifique)):
            head_table=head_table+'<th class="th-sm col'+str(k+1)+'" onclick="sorted_table(\'tableau\',\'col'+str(k+1)+'\',bestcss);">'+str(collabel[k])+'<i class="fas fa-sort-up"></i></th>'
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
    return html
