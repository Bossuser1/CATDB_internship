#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
from decimal import Decimal
from django.shortcuts import render
import decimal
# Create your views here.
from django.shortcuts import redirect
from django.http import Http404
from django.http import HttpResponse
from django.template.context_processors import request
import json
from CATdb.connection import *



def index(request):

    context_dict = {'boldmessage': "I am bold font from the context"}

    return render(request, 'CATdb/main.html', context_dict)


def ajax_check_email_fields(request):
    """
    requete ajax pour envoyer des données
    contient des conditions en fonction des varaibles get ou post envoyer par le naviagteur
    """
    answer_send=request.GET.get('data_requete_element', None)
    value_send=request.GET.get('value_search',None)
    colname_send=request.GET.get('colname_search',None)
    
    order_element=request.GET.get('order_by',None)
    #memory=execution_requete_new(answer_send,value_send,colname_send,order_element)
    if order_element!=None:
       memory=execution_requete(answer_send,value_send,colname_send,order_element) 
       #memory=execution_requete_new(answer_send,value_send,colname_send,order_element)
    else: 
        memory=execution_requete(answer_send,value_send,colname_send)

    return HttpResponse(json.dumps(memory), content_type="application/json") 


def reconnaissance_project(request):
    """
    reconnait les filtres
    """
    answer_send=request.GET.get('data_requete_element', None)
    value_send=request.GET.get('value_search',None)
    colname_send=request.GET.get('colname_search',None)
    memory=execution_requete(answer_send,value_send,colname_send)
    out_dat=dict()
    out_main_data=dict()
    for elm in memory.keys():
        key_current=memory[elm]['_value']['organ']
        if key_current not in out_dat.keys():
            out_dat[key_current]=[memory[elm]['_value']['project_id']]
        else:
            current_data=out_dat[key_current]
            current_data.append(memory[elm]['_value']['project_id'])
            out_dat[key_current]=list(set(current_data))
    for element in range(len(out_dat.keys())):
        out_main_data[element]={'_key':element,'_value':{'organ':list(out_dat.keys())[element],'project_id':out_dat[list(out_dat.keys())[element]]}}

    return HttpResponse(json.dumps(out_main_data), content_type="application/json") 





def view_data(request):
    return render(request,'CATdb/table.html',{})   

def view_table(request):
    return render(request,'CATdb/view_table.html',{})

def ajax_check_email_fields1(request):
    """
    requete ajax pour envoyer des données
    contient des conditions en fonction des varaibles get ou post envoyer par le naviagteur
    """
    answer_send=request.GET.get('data_requete_element', None)
    value_send=request.GET.get('value_search',None)
    colname_send=request.GET.get('colname_search',None)
    
    order_element=request.GET.get('order_by',None)
    if order_element!=None:
        memory=execution_requete_main_A(answer_send,value_send,order_element)
    else: 
        memory=execution_requete_main_A(answer_send,value_send,colname_send)
    return HttpResponse(json.dumps(memory), content_type="application/json") 



def prise_main(request):
    return render(request,'CATdb/table_prise_main.html',{})

def project(request):
    return render(request,'CATdb/project.html',{})

def list_project(request):
    " sert a visualiser la liste des projets dans la base de données ainsi que celle recement passer en publics"
    return render(request,'CATdb/list_project.html',{})

def graph(request):
    " sert a visualiser les graphs D3js"
    return render(request,'CATdb/graph/treatment_1.html',{})



def technologies(request):
    return render(request,'CATdb/technologies.html',{})

def description(request):
    return render(request,'CATdb/description.html',{})


def requete(request):
    return render(request,'CATdb/requete.html',{})


def redirect_view(request):
    response = redirect('/redirect-success/')
    return response

  
  
def myView(request, param):  
  if not param:  
    raise Http404  
  return render_to_response('CATdb/index.html') 
  
def error_404(request):
        data = {}
        return render(request,'CATdb/main.html', data)

def error_500(request):
        data = {}
        return render(request,'CATdb/main.html', data)  

