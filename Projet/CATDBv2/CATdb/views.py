from django.shortcuts import render

# Create your views here.
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os
import datetime
from django.conf import settings
from django.http import HttpResponse, Http404
from django.http import HttpResponseRedirect

from CATdb.modules.requete import getdata 
from CATdb.modules.scarted_plot import analyis_arra_type
from CATdb.modules.sample import sampling_get
from CATdb.modules.graph import graph_treatment,graph_ecotype,graph_experiment_factors,crosstablespeciesbytechnologie
from CATdb.modules.tableau import tableau_treatment_specifique,tableau_treatment,count_effectif


def accueil(request):
    i = datetime.datetime.now()
    date_time=str(i.year)+'-'+str(i.month)+'-'+str(i.day) 
    dat=count_effectif()
    graphcross=crosstablespeciesbytechnologie()
    #{{effectis_Organism}}{{effectis_Protocols}}{{effectis_analyis}}{{effectis_Ecotype}}
    return render(request, 'CATdb/accueil.html',{'project_repatition':graphcross,'data_today':date_time,'moyenne_projects_by_year':dat['moyenne_projects_by_year'],'effectis_projects':dat['effectifs_projects'],'effectis_experiments':dat['effectifs_experiments'],'effectis_Treatments':str(dat['effectifs_Total_treatments']),'effectis_distinct_Treatments':dat['effectifs_distinct_treatments'],'effectis_Technologies':276,'effectis_Ecotype':256,'effectis_analyis':765,'effectis_Protocols':145,'effectis_Organism':278})
    


def download(request):
    #request, path
    file_path = os.path.join(settings.MEDIA_ROOT, path)
    if os.path.exists(file_path):
        with open(file_path, 'rb') as fh:
            response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
            response['Content-Disposition'] = 'inline; filename=' + os.path.basename(file_path)
            return response
    raise Http404


def explorationgraph(request):
    list_graph="<div> <ul><li>Treatment</li><li>Graph2</li></ul></div>"
    show_treatment=graph_treatment()
    show_ecotype=graph_ecotype()    
    show_experiment_factors=graph_experiment_factors()
    return render(request, 'CATdb/graph/explore_graph.html',{'list_graph':list_graph,'titre_page':'Explore Databases','show_treatment':show_treatment,'show_ecotype':show_ecotype,'show_experiment_factors':show_experiment_factors})

def technologies_page(request):
    return render(request, 'CATdb/Technologies.html',{})




def experiment(request):
    requete="SELECT project.project_name,experiment.experiment_name, project.public_date, project.is_public FROM chips.experiment,chips.project WHERE experiment.project_id = project.project_id and project.is_public='yes' order by project.public_date desc,project.project_name,experiment.experiment_name;"
    #print(getdata(requete))
    labelbael,color,data_time,value_tampon,label1=analyis_arra_type()
    data=getdata(requete)
    url1="CATdb/ficheexperiments/"
    url2="CATdb/exp/"
    return render(request, 'CATdb/experiment.html',{'titre_page':'Experiment','labelbael':labelbael,'color':color,'data_time':data_time,'value_tampon':value_tampon,'label1':label1,'titre_graph':'Analysis by Year','data':data,'url1':url1,'url2':url2})


def project(request):
    requete="SELECT project.project_name,experiment.experiment_name, project.public_date, project.is_public FROM chips.experiment,chips.project WHERE experiment.project_id = project.project_id and project.is_public='yes' order by project.public_date desc,project.project_name,experiment.experiment_name;"
    #print(getdata(requete))
    labelbael,color,data_time,value_tampon,label1=analyis_arra_type()
    data=getdata(requete)
    url1="CATdb/ficheexperiments/"
    url2="CATdb/exp/"
    return render(request, 'CATdb/experiment.html',{'titre_page':'Experiment','labelbael':labelbael,'color':color,'data_time':data_time,'value_tampon':value_tampon,'label1':label1,'titre_graph':'Analysis by Year','data':data,'url1':url1,'url2':url2})



def treatment(request):
    show_treatment=graph_treatment()
    #print(getdata(requete))
    labelbael,color,data_time,value_tampon,label1=analyis_arra_type()
    parametre=request.GET.get('treatment','')
    if parametre!='':
        data=tableau_treatment_specifique(parametre)
    else:
        data=tableau_treatment()
    url1="CATdb/ficheexperiments/"
    url2="CATdb/exp/"
    return render(request, 'CATdb/treatment.html',{'titre_page':'Treatment','data':data,'show_treatment':show_treatment})



def ajax_check_email_fields(request):
    """
    requete ajax pour envoyer des données
    contient des conditions en fonction des varaibles get ou post envoyer par le naviagteur
    """
    experiment_id,project_id='',''
    parametre=request.GET.get('data_requete_element', None)
    condition=request.GET.get('value_search', None)
    try:
        experiment_id=condition.split('#')[0].split('=')[1]
        project_id=condition.split('#')[1].split('=')[1]
    except:
        pass
    #print(experiment_id,project_id)
    requete="select ds.project_name,ds.title,ds.biological_interest,ex.experiment_name,ex.experiment_type,ex.analysis_type,ex.array_type,ds.project_id,ex.experiment_id from (SELECT project.project_name,project.project_id, project.is_public, project.public_date FROM chips.project WHERE project.is_public='yes' order by public_date desc limit 5) as ds, chips.experiment as ex where ds.project_id=ex.project_id;"
    if parametre=="rnaseqdata":
        requete="SELECT project.project_id,rnaseqdata.project_id, rnaseqdata.experiment_id,rnaseqdata.mapping_type, rnaseqdata.stranded, rnaseqdata.seq_type, rnaseqdata.multihits,  rnaseqdata.rnaseqdata_name,   rnaseqdata.resume_file, rnaseqdata.log_file,rnaseqdata.bankref_desc, rnaseqdata.project_file FROM   chips.project,   chips.rnaseqdata WHERE  project.project_id = rnaseqdata.project_id and project.project_id='"+project_id+"' and rnaseqdata.experiment_id='"+experiment_id+"';"
    if parametre=='rnaseqlibrary':
        requete="SELECT project.project_id,rnaseqdata.project_id,rnaseqdata.experiment_id,rnaseqlibrary.project_id,rnaseqlibrary.experiment_id, "\
        "rnaseqlibrary.rnaseqlibrary_name,rnaseqlibrary.library_strategy, rnaseqlibrary.rna_selection,rnaseqlibrary.sizing, rnaseqlibrary.stranded, rnaseqlibrary.seq_type, rnaseqlibrary.seq_length, rnaseqlibrary.multiplexing,rnaseqlibrary.sequencer FROM "\
        "chips.project, chips.rnaseqdata, chips.rnaseqlibrary WHERE  project.project_id = rnaseqdata.project_id AND rnaseqdata.experiment_id = rnaseqlibrary.experiment_id AND rnaseqdata.project_id = rnaseqlibrary.project_id and project.project_id='"+project_id+"' and rnaseqdata.experiment_id='"+experiment_id+"';"
    if parametre=='experiment_info_rnaseq':
       requete="SELECT experiment.array_type,experiment.analysis_type, experiment.experiment_name, experiment.experiment_factors,experiment.experiment_type, experiment.protocol_id, project.biological_interest, project.source, project.project_name, project.title "\
       " FROM chips.project, chips.experiment WHERE  experiment.project_id = project.project_id and project.project_id='"+project_id+"' and experiment.experiment_id='"+experiment_id+"' and experiment.analysis_type='RNA-Seq';" 
    
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

def ficheexperiment(request):
    experiment_id=request.GET.get('experiment','')
    project_id=''
    
    if experiment_id!='':
        #verification de CATMA ou CTMA ou RNASA
        requete="SELECT experiment.analysis_type FROM chips.experiment where experiment.experiment_id='"+experiment_id+"';"
        print(getdata(requete)[1][0][0])
        if getdata(requete)[1][0][0]=='RNA-Seq':
            if experiment_id!='':
                requete="SELECT experiment.project_id FROM chips.experiment where experiment.experiment_id='"+experiment_id+"';"
                project_id=getdata(requete)[1][0][0]
                
                echantilon=sampling_get(experiment_id)
        
            sortage_link='/CATDb/ftp/'
            return render(request,'CATdb/ficheexperiment.html',{'titre_page':'File_experiment','sortage_link':sortage_link,'experiment':experiment_id,'project':project_id,'sample':echantilon})
        else:
            return HttpResponseRedirect('http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id='+experiment_id)
    else:
        return HttpResponseRedirect('http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id='+experiment_id)
