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
    " WHERE "+conditionpublic+filtrerequete+" ;"
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
    
    requete="""select distinct dt.array_type_name,dt.array_type_id,dt.experiment_id,dt.project_id from (SELECT 
      array_type.array_type_id, 
      "array".array_type_name, 
      experiment.experiment_id, 
      project.project_id
    FROM 
      chips.hybridization, 
      chips.array_batch, 
      chips."array", 
      chips.project, 
      chips.array_type, 
      chips.experiment
    WHERE 
      hybridization.array_id = "array".array_id AND
      array_batch.array_type_id = array_type.array_type_id AND
      "array".array_batch_id = array_batch.array_batch_id AND
      experiment.experiment_id = hybridization.experiment_id and
    project.project_id=experiment.project_id ) as dt  order by dt.project_id  ;
    """
    r,data=getdata(requete)
    dat6=pd.DataFrame(data,columns=r).drop_duplicates()
    
    
    
    return dat0,dat1,dat2,dat3,dat4,dat5,dat6

  

def formatage_affichage(dat0,dat1,dat2,dat3,dat4,dat5,dat6):
    # par cour une seule fois la boucle
    afficheall="""
    <script>
    var open_pop="false";
    function information_get_element(element,$Tablename){
    var Data=[];
    if ($Tablename='contact'){$ListDataCond='contact_id='+element}
    
    if ($ListDataCond!=''){var instruction={'data_requete_element':$Tablename,'value_search':$ListDataCond}}
	else{var instruction={'data_requete_element':$Tablename}};
	$.ajax({
	    type:"GET",
	    data:instruction,
	    dataType: "json",
	    async: false,
	    url:"/CATdb/data/getinformation",
	    success: function(data) {
		Data=data;
		console.log(data[1]._value);
        $('#popinfor_corps').empty();
        $('#popinformation').attr("style","position: absolute;top:"+0+";z-index: 3;background-color: white;min-width: 500px;");
        $('#popinfor_corps').append("<div> First name:"+data[1]._value['first_name']+"</div>");
        $('#popinfor_corps').append("<div> Last name: "+data[1]._value['last_name']+" </div>");
        //$('#popinformation').append("<div> Phone: "+data[1]._value['phone']+" </div>");
        $('#popinfor_corps').append("<div>  Email:"+data[1]._value['email']+" </div>");
        $('#popinfor_corps').append("<div>  Instistution:"+data[1]._value['institution']+" </div>");
        //$('#popinformation').append("<div>  Laboratory: "+data[1]._value['laboratory']+" </div>");
        open_pop="true";
         

	    },
	error:function(err) { console.clear();console.log('error'+$Tablename);}
	});
    
    
    
    
    };
    
    
    $("#first").ready(function(){
    $("#first").on("click",function(){
    try{
    if (open_pop=="false"){
    console.log(open_pop);
    //$('#popinformation').hide();
    //open_pop="false";
    } else{
    console.log(open_pop);
    }
    }catch{}
    
    
    
    });
    });
    
    </script>
    <style> #list_element{margin-bottom:2px;text-align:center;font-size: 12px;background: #b6a6a6;border-left: 5px solid #007bff;border-right: 5px solid #007bff;border-bottom: 2px solid;border-top: 1px solid;} #list_element a {margin: 2px; text-decoration:underline;cursor:pointer;font-size:10px;}   #first{ font-size: 10px;   border: 1px solid #e2e2e2;}  #first tr:nth-child(2n) {background: #dfedf1;}</style> <div style="display:flex;justify-content: space-around;font-size: 12px;background: #b6a6a6;border-left: 5px solid #007bff;border-right: 5px solid #007bff;border-bottom: 2px solid;border-top: 1px solid;"><div> Totals Projects: """+str(len(list(dat0.index)))+""" </div><div>Search:<input type="text" id="name_table"></div> <select onchange="runscript_action_list(this.value);"><option value="10">10</option><option value="20">20</option> <option value="30">30</option><option value="50">50</option></select>  </div> <table id="first"> """ 
    afficheall+="""<thead style="border-bottom: 2px solid;">"""
    affichealhed="<tr>"
    affichealhed+="<th>Project</th>"
    affichealhed+="<th>Title</th>"
    affichealhed+="<th>Ref Bibiolgraph</th>"
    affichealhed+="<th>Coord</th>"
    affichealhed+="<th>Organ</th>"
    affichealhed+="<th>Experiment Type</th>"
    affichealhed+="<th>Materiel Type</th>"
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
                        contact+="<tr><td><a  onclick='information_get_element("+str(var1[kv])+",\"contact\");' style='cursor:pointer;text-decoration:underline;'>"+str(var2[kv])+"</a></td></tr>"
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
            var31a=""
            var31=""
            try:    
                if len(var2)>0:
                    download="<table>"
                    experimen="<table>"
                    strexperiment="<table>"
                    materiel="<table>"
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
                        var31a=var31
                        try:
                            var31=list(set(list(dat6[dat6['project_id']==int(key)][dat6['experiment_id']==int(var4[kv])].array_type_name)))
                            var32=list(set(list(dat6[dat6['project_id']==int(key)][dat6['experiment_id']==int(var4[kv])].array_type_id)))
                        except:
                            var31=""
                            var32=""
                            pass
                        if var31a==var31:
                            try:
                                materiel+="<tr><td><a href='/donwload="+str(var32[0])+"'>"+"."+"</a></td></tr>"
                            except:
                                pass
                        else:
                            try:
                                materiel+="<tr><td><a href='/donwload="+str(var32[0])+"'>"+str(var31[0])+"</a></td></tr>"
                            except:
                                pass
                        download+="<tr><td><a href='/donwload="+str(var2[kv])+"'>"+"fichier"+"</a></td></tr>"
                        strexperiment+="<tr><td>"+valpus+"</td></tr>"
                                                                                                                                                                                                                                                                                                                                
                    experimen+="</table>"
                    materiel+="</table>"
                    download+="</table>"
                    strexperiment+="</table>"
                elif len(var2)==1:
                    experimen=experimen.replace('<table>','').replace('</table>','')
                    materiel=materiel.replace('<table>','').replace('</table>','')
                    download=download.replace('<table>','').replace('</table>','')
                    strexperiment=strexperiment.replace('<table>','').replace('</table>','')
                else:
                    experimen=""
                    strexperiment=""
                    materiel=""
                    download=""
            except:
                experimen=""
                strexperiment=""
                download=""
                materiel=""
                pass
            affiche+="<td>"+strexperiment+"</td>\n"
            affiche+="<td>"+materiel+"</td>\n"
            affiche+="<td>"+experimen+"</td>\n"
            affiche+="<td>"+download+"</td>\n"
    
            affiche+="</tr>"    
        except:
            affiche=""
            pass
    
        afficheall+=affiche    
    afficheall+="</tbody>"
    afficheall+="<tfoot   style='border-top: 2px solid;'>"
    afficheall+=affichealhed
    afficheall+="</tfoot>"
    afficheall+="""</table><div id='list_element'></div>
    
    <div id="popinformation">
    
    <div class="modal-header">
        <h5 class="modal-title" id="popinformationLabel">Title</h5>
        <button type="button" class="close" onclick='$("#popinformation").hide();' data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">×</span>
        </button>
    </div>
    <div id="popinfor_corps" class="modal-body">
    
    
    </div>
    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick='$("#popinformation").hide();'>Close</button>
    </div>
    
    </div>
    
    
    
    """
    
    
    java="""<script>
       
    
    
    var action="false";
    function runscript_action_list(element){
    
    for (var i=element-1;i<"""+str(cptage)+""";i++){
    var text='first tbody .tablerow'+i
    try{
    $("#"+text).hide();
    }catch{};
    };
    action="true";
    return action;
    };
    
    var element=[];
    var comptage_element=10;
    var total="""+str(cptage)+""";
    for (var i=0;i<=(total/comptage_element);i++){
        element.push(i*comptage_element);    
    }
    
    for (var i=1;i<element.length;i++){  
    $("#list_element").append("<a onclick='change("+i+","+total+","+comptage_element+");'>"+i+'</a>');
    
    }
    function change(i,total,comptage_element){
    
    for (var j=0;j<=total;j++){
    var text='first tbody .tablerow'+j
    
    if (j<=comptage_element*(i-1) || j>=i*comptage_element){
    $("#"+text).hide();
    }else{
    $("#"+text).show();
    }
    
    }
    }
    </script>
    
    
    
    
    
    
    
    """
    return afficheall+java


def creat_table_liste(conditionpublic,filtrerequete):
    dat0,dat1,dat2,dat3,dat4,dat5,dat6=run_script_complete_data(conditionpublic,filtrerequete)
    afficheall=formatage_affichage(dat0,dat1,dat2,dat3,dat4,dat5,dat6)
    return afficheall



