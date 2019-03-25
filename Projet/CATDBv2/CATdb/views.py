from django.shortcuts import render

# Create your views here.
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
from django.http import HttpResponse

from CATdb.modules.requete import getdata 
from CATdb.modules.scarted_plot import analyis_arra_type

def index(request):
    requete="SELECT project.project_name,experiment.experiment_name, project.public_date, project.is_public FROM chips.experiment,chips.project WHERE experiment.project_id = project.project_id and project.is_public='yes' order by project.public_date desc,project.project_name,experiment.experiment_name;"
    #print(getdata(requete))
    labelbael,color,data_time,value_tampon,label1=analyis_arra_type()
    data=getdata(requete)
    url1="CATdb/fichexperiments/"
    url2="CATdb/exp"
    return render(request, 'CATdb/experiment.html',{'labelbael':labelbael,'color':color,'data_time':data_time,'value_tampon':value_tampon,'label1':label1,'titre_graph':'Analysis by Year','data':data,'url1':url1,'url2':url2})

def ajax_check_email_fields(request):
    """
    requete ajax pour envoyer des données
    contient des conditions en fonction des varaibles get ou post envoyer par le naviagteur
    """
    requete="select ds.project_name,ex.experiment_name,ex.experiment_type,ex.analysis_type,ex.array_type,ds.project_id,ex.experiment_id from (SELECT project.project_name,project.project_id, project.is_public, project.public_date FROM chips.project WHERE project.is_public='yes' order by public_date desc limit 5) as ds, chips.experiment as ex where ds.project_id=ex.project_id;"
    colnames,memory=getdata(requete)
    cpt=0
    data=dict()
    for ele in range(len(memory)):
        cpt=cpt+1
        col=[]
        for ele1 in memory[ele]:
            col.append(str(ele1))
        dictionary ={'_key':cpt,"_value":dict(zip(colnames,col))}
        data[cpt]=dictionary
    return HttpResponse(json.dumps(data), content_type="application/json") 
