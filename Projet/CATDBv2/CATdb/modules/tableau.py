#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 20:23:16 2019

@author: traore
"""


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



def tableau_treatment():    
    requete="SELECT experiment.project_id,experiment.experiment_id,treatment.treatment_type,experiment.experiment_name ,project.title,project.project_name FROM chips.treatment,chips.experiment,chips.project"\
    " WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id and project.project_id=treatment.project_id ;"
    sep='#'
    colname,data=getdata(requete)
    #dat=pd.DataFrame(data,columns=colname)
    
    dat1=dict()
    for i in range(len(data)):
        if data[i][2] not in dat1.keys():
            dat1[data[i][2]]=[str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep]
        else:
            cpt=dat1[data[i][2]]
            cpt.append(str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep)
            dat1[data[i][2]]=list(set(cpt))
    #print("=========new======")
    html="<script> function gotolink(key){ window.location='project.html?project='+key;}; </script>"
    html+="<table><thead><th>Treatment</th><th>Project</th></thead><tbody>" #<th>Experiment</th>
    for key in dat1.keys():
        try:
            text="<tr>"+"<td>"+key+"</td>"
            row1=""
            row2=""
            for el in range(len(dat1[key])):
                row1+='<div onclick="gotolink(\''+dat1[key][el].split(sep)[0]+'\');">'+dat1[key][el].split(sep)[4]+"</div>"
                #row2+="<div>"+dat1[key][el].split(sep)[2]+"</div>"
            text+="<td>"+row1+"</td>"+"</tr>"#+"<td>"+row2+"</td>"
            html+=text
        except:
            pass
    html+="</tbody></table>"
    return html

def tableau_treatment_specifique(key):    
    requete="SELECT experiment.project_id,experiment.experiment_id,treatment.treatment_type,experiment.experiment_name ,project.title,project.project_name FROM chips.treatment,chips.experiment,chips.project"\
    " WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id and project.project_id=treatment.project_id and treatment.treatment_type='"+key+"';"
    sep='#'
    colname,data=getdata(requete)
    #dat=pd.DataFrame(data,columns=colname)
    
    dat1=dict()
    for i in range(len(data)):
        if data[i][2] not in dat1.keys():
            dat1[data[i][2]]=[str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep]
        else:
            cpt=dat1[data[i][2]]
            cpt.append(str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep)
            dat1[data[i][2]]=list(set(cpt))
    #print("=========new======")
    html="<script> function gotolink(key){ window.location='project.html?project='+key;}; </script>"
    html+="<table><thead><th>Treatment</th><th>Project</th></thead><tbody>" #<th>Experiment</th>
    for key in dat1.keys():
        try:
            text="<tr>"+"<td>"+key+"</td>"
            row1=""
            row2=""
            for el in range(len(dat1[key])):
                row1+='<div onclick="gotolink(\''+dat1[key][el].split(sep)[0]+'\');">'+dat1[key][el].split(sep)[4]+"</div>"
                #row2+="<div>"+dat1[key][el].split(sep)[2]+"</div>"
            text+="<td>"+row1+"</td>"+"</tr>"#+"<td>"+row2+"</td>"
            html+=text
        except:
            pass
    html+="</tbody></table>"
    return html

def count_effectif():
    datafin={}
    requete="SELECT count(project.project_id) FROM  chips.project where project.is_public='yes';"
    r,data=getdata(requete)
    datafin['effectifs_projects']=int(data[0][0])
    requete="SELECT count(experiment.experiment_id),count(distinct experiment.experiment_id) FROM chips.project, chips.experiment WHERE project.project_id = experiment.project_id and project.is_public='yes';"
    r,data=getdata(requete)
    datafin['effectifs_experiments']=int(data[0][0])
    #datafin['effectifs_distinct_experiments']=int(data[0][1])
    
    requete="SELECT count(distinct treatment.treatment_type) as distinct_ex,count(treatment.treatment_type) Total_ex FROM chips.treatment,chips.experiment,chips.project "\
    "WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id and project.project_id=treatment.project_id and project.is_public='yes';"
    r,data=getdata(requete)
    datafin['effectifs_Total_treatments']=int(data[0][1])
    datafin['effectifs_distinct_treatments']=int(data[0][0])    
    
    requete="SELECT count(distinct(experiment.analysis_type)) FROM chips.project, chips.experiment WHERE project.project_id = experiment.project_id and project.is_public='yes';"
    r,data=getdata(requete)
    datafin['effectifs_technologis']=int(data[0][0])
    requete="select count(*) from (SELECT distinct(experiment.analysis_type),experiment.array_type FROM chips.project,chips.experiment WHERE project.project_id = experiment.project_id and project.is_public='yes') as df;"
    r,data=getdata(requete)
    datafin['effectifs_type_technologie']=int(data[0][0])
    
    requete="SELECT project.public_date as dat, project.project_id FROM chips.project where project.is_public='yes';"
    r,data=getdata(requete)
    data=pd.DataFrame(data)
    datafin['moyenne_projects_by_year']=14    
    return datafin

def get_tableau_format_special(requete):
    r,memory=getdata(requete)
    data=pd.DataFrame(memory,columns=r)
    affiche=['Nbs of Experiments','Nbs of Mutants','Nbs of Organs','Nbs of Genotypes']
    list_column=['experiment_name','mutant_type','organ','genotype']
    data3=None
    for k in range(int(len(list_column)/2)):
        data1=data[['project_name',list_column[2*k]]]
        data1=data1.groupby('project_name')[list_column[2*k]].nunique()
        data2=data[['project_name',list_column[2*k+1]]].loc[data[list_column[2*k+1]]!=None]
        data2=data2.groupby('project_name')[list_column[2*k+1]].nunique()
        try:
            data3=pd.concat([data3,data1],axis=1).fillna(0)
        except:
            pass
        try:
            data3=pd.concat([data3,data2],axis=1).fillna(0)
        except:
            data3=pd.concat([data1,data2],axis=1).fillna(0)
            pass
    data3=data3.reset_index(level=0)        

    data=data3

    
    corps_table=data.to_html().split('<tbody>')[1].split('</tbody>')[0]
    columm_name=""" <tr><th>N°</th>"""
    for element in affiche:
        columm_name+="<th>"+element+"</th>"
    columm_name+="""</tr>"""
    tableau_id="example"
    tableau="""
    <table id='"""+tableau_id+"""' class="display" style="width:100%">
            <thead>
            """+columm_name+"""
            </thead>
            <tbody>"""+corps_table+"""
            </tbody>
            <tfoot>
            """+columm_name+"""
            </tfoot>
        </table>
    
    <script>
    $(document).ready(function() {
        $('#"""+tableau_id+"""').DataTable( {
            "scrollY":        "400px",
            "scrollCollapse": true,
            "paging":         false
        } );
    } );
    </script>
    """
    return tableau 

   

def expression_regulier(var1):
    var1=var1.replace('  ','').replace('\n','').replace('	','')
    return var1

def run_script_complete_data(conditionpublic,filtrerequete):
    ###nom_project
    requete="SELECT project.project_id,project.title,project.project_name FROM chips.project"\
    " WHERE "+conditionpublic+filtrerequete+";"
    r,data=getdata(requete)
    dat1=pd.DataFrame(data,columns=r).drop_duplicates()
    ####bibliographie
    requete="SELECT project.project_id,project_biblio.pubmed_id FROM chips.project, chips.project_biblio WHERE  project_biblio.project_id = project.project_id and "\
    ""+conditionpublic+filtrerequete+";"
    r,data=getdata(requete)
    dat2=pd.DataFrame(data,columns=r).drop_duplicates()
    
    ##section corrdianteur
    requete="SELECT project.project_id,contact.contact_id,"\
    "  contact.last_name FROM chips.project, chips.contact, "\
    "  chips.project_coordinator WHERE project_coordinator.contact_id = contact.contact_id AND "\
    "  project_coordinator.project_id=project.project_id and "+conditionpublic+filtrerequete+"; "
    r,data=getdata(requete)
    dat3=pd.DataFrame(data,columns=r).drop_duplicates()
    
    #experiement organ
    requete="SELECT distinct sample.project_id,sample.experiment_id,sample.organ,experiment.experiment_name,experiment.analysis_type FROM chips.project, chips.sample,chips.experiment "\
    " WHERE sample.project_id = experiment.project_id AND "\
    " experiment.experiment_id = sample.experiment_id and project.project_id=sample.project_id and "+conditionpublic+filtrerequete+"; "
    r,data=getdata(requete)
    dat4=pd.DataFrame(data,columns=r).drop_duplicates()
    
    dat5=dat4[[u'project_id',u'experiment_id',u'experiment_name',u'analysis_type']].drop_duplicates()
    dat0=dat1
    dat0=dat0.set_index(['project_id'])
    return dat0,dat1,dat2,dat3,dat4,dat5

  

def formatage_affichage(dat0,dat1,dat2,dat3,dat4,dat5):
    # par cour une seule fois la boucle
    afficheall="""<style>  #first{ font-size: 10px;   border: 1px solid #e2e2e2;}  #first tr:nth-child(2n) {background: #dfedf1;}</style> <div style="display:flex;justify-content: space-around;font-size: 12px;background: #b6a6a6;border-left: 5px solid #007bff;border-right: 5px solid #007bff;border-bottom: 2px solid;border-top: 1px solid;"><div> Totals Projects: """+str(len(list(dat0.index)))+""" </div><div>Search:<input type="text" id="name_table"></div> <select onchange="runscript_action_list(this.value);"><option value="10">10</option><option value="20">20</option> <option value="30">30</option><option value="50">50</option></select>  </div> <table id="first"> """ 
    afficheall+="""<thead style="border-bottom: 2px solid;">"""
    affichealhed="<tr>"
    affichealhed+="<th>Project</th>"
    affichealhed+="<th>Title</th>"
    affichealhed+="<th>Ref Bibiolgraph</th>"
    affichealhed+="<th>Coord</th>"
    affichealhed+="<th>Organ</th>"
    affichealhed+="<th>Experiment Type</th>"
    affichealhed+="<th>Experiment</th>"
    affichealhed+="<th>File</th>"
    affichealhed+="</tr>"
    
    afficheall+=affichealhed+"""</thead><tbody>"""
    
    cptage=0
    for key in list(dat0.index):
        cptage+=1
        try:
            affiche="<tr class='tablerow"+str(cptage)+"'>"
            var1=expression_regulier(str(dat0.loc[key,'title']))
            affiche+="<td><a href='/project="+dat0.loc[key,'project_name']+"'>"+dat0.loc[key,'project_name']+"</a></td>\n" #nom project
            var1=expression_regulier(str(dat0.loc[key,'title']))
            affiche+="<td>"+var1+"</td> \n" #titre +pubimed
            try:
                var2=list(dat2[dat2['project_id']==int(key)].pubmed_id)
                publmed=""
                if len(var2)>0:
                    publmed="<table>"
                    for elemnt in var2:
                        publmed+="<tr><td><a href='http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term="+str(elemnt)+"'>"+expression_regulier(str(elemnt))+"</a></td></tr>"
                    publmed+="</table>"
                elif len(var2)==1:
                    publmed=publmed.replace('<table>','').replace('</table>','')
                    publmed=publmed.replace('</table>','')
                else:
                    publmed=""
            except:
                publmed=""
                pass
                
            affiche+="<td>"+publmed+"</td>\n" #publimed
            
            var1=list(dat3[dat3['project_id']==int(key)].contact_id)
            var2=list(dat3[dat3['project_id']==int(key)].last_name)
            try:    
                if len(var2)>0:
                    contact="<table>"
                    for kv in range(len(var2)):
                        contact+="<tr><td><a href='/contact_id="+str(var1[kv])+"'>"+str(var2[kv])+"</a></td></tr>"
                    contact+="</table>"
                elif len(var2)==1:
                    contact=contact.replace('<table>','').replace('</table>','')
                    contact=contact.replace('</table>','')
                else:
                    contact=""
            except:
                print("attention")
                contact=""
                pass
            affiche+="<td>"+contact+"</td>\n" #publimed
        
            #organ
            var2=list(set(list(dat4[dat4['project_id']==int(key)].organ)))
            try:    
                if len(var2)>0:
                    organ="<table>"
                    for kv in range(len(var2)):
                        organ+="<tr><td><a href='/organ="+str(var2[kv])+"'>"+var2[kv]+"</a></td></tr>"
                    organ+="</table>"
                elif len(var2)==1:
                    organ=organ.replace('<table>','').replace('</table>','')
                else:
                    organ=""
            except:
                print("attention")
                organ=""
                pass
            affiche+="<td>"+organ+"</td>\n" 
            
            #experiment_name(erreur)
            var2=list(dat5[dat5['project_id']==int(key)].experiment_name)
            var4=list(dat5[dat5['project_id']==int(key)].experiment_id)
            var3=list(dat5[dat5['project_id']==int(key)].analysis_type)
            try:    
                if len(var2)>0:
                    download="<table>"
                    experimen="<table>"
                    strexperiment="<table>"
                    act=var3[0]
                    for kv in range(len(var2)):
                        act=var3[kv]
                        if kv>0:
                            bf=var3[kv-1]
                        else:
                            bf=""
                        try:    
                            if bf==act:
                                valpus="<br>"
                            else:
                                valpus=act
                        except:
                            valpus=act
                            pass
                        #var4[kv]
                        if act=='RNA-Seq':
                            urlget="/CATdb/ficheexperiment.html?experiment="
                        else:
                            urlget="http://tools.ips2.u-psud.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id="
                            
                        experimen+="<tr><td><a href='"+urlget+str(var4[kv])+"'>"+var2[kv]+"</a></td></tr>"
                        download+="<tr><td><a href='/donwload="+str(var2[kv])+"'>"+"fichier"+"</a></td></tr>"
                        strexperiment+="<tr><td>"+valpus+"</td></tr>"
                    
                    experimen+="</table>"
                    download+="</table>"
                    strexperiment+="</table>"
                elif len(var2)==1:
                    experimen=experimen.replace('<table>','').replace('</table>','')
                    download=download.replace('<table>','').replace('</table>','')
                    strexperiment=strexperiment.replace('<table>','').replace('</table>','')
                else:
                    experimen=""
                    strexperiment=""
                    download=""
            except:
                experimen=""
                strexperiment=""
                download=""
                pass
            affiche+="<td>"+strexperiment+"</td>\n"
            affiche+="<td>"+experimen+"</td>\n"
            affiche+="<td>"+download+"</td>\n"
    
            affiche+="</tr>"    
        except:
            affiche=""
            pass
    
        afficheall+=affiche    
    afficheall+="</tbody>"
    afficheall+="<tfoot>"
    afficheall+=affichealhed
    afficheall+="</tfoot>"
    afficheall+="</table>"
    java="""<script>
    
    function runscript_action_list(element){
    for (var i=element;i<440;i++){
    var text='first tbody .tablerow'+i
    try{
    $("#"+text).hide();
    }catch{};
    };
    };  
    </script>"""
    
    return afficheall+java


def creat_table_liste(conditionpublic,filtrerequete):
    dat0,dat1,dat2,dat3,dat4,dat5=run_script_complete_data(conditionpublic,filtrerequete)
    afficheall=formatage_affichage(dat0,dat1,dat2,dat3,dat4,dat5)
    return afficheall



