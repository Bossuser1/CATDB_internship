#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 25 14:15:16 2019

@author: traore
"""

#extract name

import sys
import numpy as np
try:
    from CATdb.modules.requete  import getdata,getdata_map
    from CATdb.modules.palette_color import getcolor
except:
    pass
try:
    from requete  import getdata,getdata_map
    from palette_color import getcolor
except:
    pass
import  pandas as pd
import random

#SELECT extract_id,extract_name,molecule_type,CONCAT(quantity_value,' ',quantity_unit) as quantity ,concat("extract".material_value,' ',"extract".material_unit) as materiel FROM chips."extract" where project_id='295' and experiment_id='592';
#
key='106'


#echnatillon
#requete="SELECT sample.sample_id,sample.sample_name,sample.organ, sample.dev_stage,sample.harvest_date,sample.age_unit,sample.age_value,sample.project_id,sample.experiment_id,sample.sample_source FROM chips.sample where experiment_id='"+key+';"
def sampling_get(key,filtre_list=[]):
    requete="SELECT sample_source.sample_source_id, sample_source.sample_source_idname, sample_source.sample_source_name, sample_source.organism_id,  sample_source.ecotype_id,  sample_source.genotype,  sample_source.mutant,  sample_source.growth_conditions,  sample_source.planting_date,  sample_source.operator_id,  sample_source.book_ref,  sample_source.project_id,  sample_source.experiment_id,  sample_source.user_id,  sample_source.submission_date, sample_source.mutant_type,  sample_source.mutant_loci,  sample.sample_source_id,  sample.sample_id,  sample.sample_name, concat(sample.harvest_date,' ',sample.age_value,'',sample.age_unit, sample.dev_stage) as age_date_dev, sample.age_db, sample.organ, sample.harvest_plantnb,sample.experiment_id FROM " 
    requete+="chips.sample_source,chips.sample WHERE sample.sample_source_id = sample_source.sample_source_id AND sample.experiment_id = sample_source.experiment_id and sample.experiment_id='"+key+"';"
    requete="select s.sample_name,e.extract_name, o.organism_name, s.organ,concat(s.dev_stage,'/',s.age_value,'',s.age_unit,' /',s.harvest_date) as \"dev stage/age/date\",CONCAT(eco.ecotype_name,'', ss.genotype) as \"ecotype/genotype\", s.note as \"growth condition\" from chips.sample_source ss, chips.organism o, chips.ecotype eco, chips.sample s, chips.sample_extract se, chips.extract e where o.organism_id=ss.organism_id and eco.ecotype_id=ss.ecotype_id and ss.experiment_id='"+key+"' and s.sample_source_id=ss.sample_source_id and se.sample_id=s.sample_id and e.extract_id=se.extract_id;"
    order=['sample_name','organism_name','organ','dev stage/age/date','ecotype/genotype','growth condition']
    data=getdata_map(requete)
    filtre_list=[]
    html_body=""
    try:
        if len(data)>0:
            
            for keyel in  data.keys():
               row="<tr>"
               thead="<tr class='head_table'>"
               for element in order:
                   if element not in filtre_list and element in data[keyel]['_value'].keys():
                       value=data[keyel]['_value'][element]
                       if value=='None':
                          value='' 
                       thead+="<td class='head_table'>"+element+"<td>"
                       row+="<td>"+value+"<td>"
               row+="</tr>"
               html_body+=row
    except:
        pass    
    #html_body+="</tbody>"
    html='<table style="font-size: calc(100%);"><tbody>'+thead+html_body+'</tbody></table>'
    return html
#print(html)

#requete="SELECT sample.sample_source_id,sample.sample_name,sample.harvest_date,sample.age_value,"
#requete+=" sample.age_unit, sample.age_db,sample.dev_stage, sample.organ,sample.harvest_plantnb,  sample.experiment_id, sample_treated.sample_id, sample.sample_id, sample_treated.experiment_id,sample_treated.project_id FROM chips.sample,chips.sample_treated WHERE sample.sample_id = sample_treated.sample_id"
#requete+=" AND sample.experiment_id = sample_treated.experiment_id AND sample.project_id = sample_treated.project_id"
#requete+=" and  sample.experiment_id ='"+key+"';"



def sampling_table(key):
    requete="select pro.protocol_type,pro.protocol_file,concat(e.material_value,e.material_unit) as material,e.quality_file,e.extract_name,e.molecule_type,concat(e.quantity_value,' ',e.quantity_unit) as quantity, o.organism_name, concat(s.dev_stage,'',s.age_value,'',s.age_unit,'',s.harvest_date) as \"dev stage/age/date\",CONCAT(eco.ecotype_name,'/', ss.genotype) as \"ecotype/genotype\", "\
    "s.organ,ss.mutant,(select treatment_name from chips.treatment where treatment_id=t.treatment_id), substr(ss.growth_conditions,1,2000) from chips.sample_source ss, chips.organism o, chips.ecotype eco, chips.protocol pro,chips.sample_extract se,chips.extract e, chips.sample s LEFT OUTER JOIN chips.sample_treated t ON t.sample_id=s.sample_id where e.protocol_id=pro.protocol_id and o.organism_id=ss.organism_id and eco.ecotype_id=ss.ecotype_id and ss.experiment_id='"+str(key)+"' and s.sample_source_id=ss.sample_source_id and se.sample_id=s.sample_id and e.extract_id=se.extract_id order by extract_name;"
    r,data=getdata(requete)
    dat=pd.DataFrame(data)
    dat.columns=r
    dat=dat.drop_duplicates()
    text=np.transpose(dat)
    a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a111,a112,a113="","","","","","","","","","","","",""
    a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a201,a202,a203="","","","","","","","","","","","",""
    for i in text.keys():
        row="<tr>"
        a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a201,a202,a203=text[i][1],text[i][2],text[i][3],text[i][4],text[i][5],text[i][6],text[i][7],text[i][8],text[i][9],text[i][10],text[i][11],text[i][12],text[i][13]
        a11="" if a11==a1 else text[i][1]
        a12="" if a12==a2 else text[i][2]
        a13="" if a13==a3 else text[i][3]
        a14="" if a14==a4 else text[i][4]
        a15="" if a15==a5 else text[i][5]
        a16="" if a16==a6 else text[i][6]
        a17="" if a17==a7 else text[i][7]
        a18="" if a18==a8 else text[i][8]
        a19="" if a19==a9 else text[i][9]
        a20="" if a20==a10 else text[i][10]
        a201="" if a201==a111 else text[i][11]
        a202="" if a202==a112 else text[i][12]
        a203="" if a203==a113 else text[i][13]
        cont="<td>"+a14+"</td>"+"<td>"+a17+"</td>"+"<td>"+a15+"</td>"+"<td>"+a20+"</td>"+"<td>"+a17+"</td>"
        a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a111,a112,a113=text[i][1],text[i][2],text[i][3],text[i][4],text[i][5],text[i][6],text[i][7],text[i][8],text[i][9],text[i][10],text[i][11],text[i][12],text[i][13]
        row+=cont+"</tr>"
        #print(row)
    return text

#absc=np.transpose(sampling_table(541))


#daa=absc.groupby(['organism_name','molecule_type','organ','extract_name']).count()
#print(absc.to_html())


#select concat(e.material_value,e.material_unit) as material,e.quality_file,e.extract_name,e.molecule_type,concat(e.quantity_value,' ',e.quantity_unit) as quantity, o.organism_name, concat(s.dev_stage,'',s.age_value,'',s.age_unit,'',s.harvest_date) as "dev stage/age/date",CONCAT(eco.ecotype_name,'/', ss.genotype) as "ecotype/genotype", s.organ,ss.mutant,(select treatment_name from chips.treatment where treatment_id=t.treatment_id), substr(ss.growth_conditions,1,20) from chips.sample_source ss, chips.organism o, chips.ecotype eco, chips.sample_extract se,chips.extract e, chips.sample s LEFT OUTER JOIN chips.sample_treated t ON t.sample_id=s.sample_id where o.organism_id=ss.organism_id and eco.ecotype_id=ss.ecotype_id and ss.experiment_id='592' and s.sample_source_id=ss.sample_source_id and se.sample_id=s.sample_id and e.extract_id=se.extract_id order by extract_name;
#"select pro.protocol_type,pro.protocol_file,concat(e.material_value,e.material_unit) as material,e.quality_file,e.extract_name,e.molecule_type,concat(e.quantity_value,' ',e.quantity_unit) as quantity, o.organism_name, concat(s.dev_stage,'',s.age_value,'',s.age_unit,'',s.harvest_date) as \"dev stage/age/date\",CONCAT(eco.ecotype_name,'/', ss.genotype) as \"ecotype/genotype\", s.organ,ss.mutant,(select treatment_name from chips.treatment where treatment_id=t.treatment_id), substr(ss.growth_conditions,1,2000) from chips.sample_source ss, chips.organism o, chips.ecotype eco, chips.protocol pro,chips.sample_extract se,chips.extract e, chips.sample s LEFT OUTER JOIN chips.sample_treated t ON t.sample_id=s.sample_id where e.protocol_id=pro.protocol_id and o.organism_id=ss.organism_id and eco.ecotype_id=ss.ecotype_id and ss.experiment_id='"+str(key)+"' and s.sample_source_id=ss.sample_source_id and se.sample_id=s.sample_id and e.extract_id=se.extract_id order by extract_name;"

#"select s.sample_name,e.extract_name, o.organism_name, s.organ,concat(s.dev_stage,'/',s.age_value,'',s.age_unit,' /',s.harvest_date) as "dev stage/age/date",CONCAT(eco.ecotype_name,'', ss.genotype) as "ecotype/genotype", s.note as "growth condition" from chips.sample_source ss, chips.organism o, chips.ecotype eco, chips.sample s, chips.sample_extract se, chips.extract e where o.organism_id=ss.organism_id and eco.ecotype_id=ss.ecotype_id and ss.experiment_id=562 and s.sample_source_id=ss.sample_source_id and se.sample_id=s.sample_id and e.extract_id=se.extract_id;"
#select *,(select treatment_name from treatment where treatment_id=t.treatment_id) from (select s.sample_id,s.sample_name, o.organism_name, s.organ,concat(s.dev_stage,'/',s.age_value,'',s.age_unit,' /',s.harvest_date) as "dev stage/age/date",CONCAT(eco.ecotype_name,'', ss.genotype) as "ecotype/genotype", s.note as "growth condition" from chips.sample_source ss, chips.organism o, chips.ecotype eco, chips.sample s, chips.sample_extract se, chips.extract e   where o.organism_id=ss.organism_id and eco.ecotype_id=ss.ecotype_id and ss.experiment_id=462 and s.sample_source_id=ss.sample_source_id and se.sample_id=s.sample_id and e.extract_id=se.extract_id) as td left outer join sample_treated t on t.sample_id=td.sample_id ;



#treatement
#SELECT * FROM chips.treatment where project_id='365'
#colnames1,memory1=getdata(requete)
