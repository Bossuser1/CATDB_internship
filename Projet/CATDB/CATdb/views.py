#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
from decimal import Decimal
from django.shortcuts import render
import decimal
# Create your views here.

from django.http import HttpResponse
from django.template.context_processors import request
import json
from CATdb.connection import *



def index(request):

    context_dict = {'boldmessage': "I am bold font from the context"}

    return render(request, 'CATdb/index.html', context_dict)


def ajax_check_email_fields(request):
    """
    requete ajax pour envoyer des données
    contient des conditions en fonction des varaibles get ou post envoyer par le naviagteur
    """
    answer_send=request.GET.get('data_requete_element', None)
    value_send=request.GET.get('value_search',None)
    colname_send=request.GET.get('colname_search',None)
    
    order_element=request.GET.get('order_by',None)
    if order_element!=None:
        memory=execution_requete_new(answer_send,value_send,colname_send,order_element)
    else: 
        memory=execution_requete(answer_send,value_send,colname_send)

    return HttpResponse(json.dumps(memory), content_type="application/json") 




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


# def index(request):
#     _answer="""    
#     <div id="header"><div>
#     <div id="contener">
#     {% load static %}
#     <img src="{%static'/CATdb/img/logo-ips2-trans.png' %}" alt="My image">
#     testons    
#     <div>
#     <div id="foot"><div>
#     """    
#     return HttpResponse(_answer)


