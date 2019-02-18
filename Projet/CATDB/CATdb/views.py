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
    memory=execution_requete('my_req_special')
    return HttpResponse(json.dumps(memory), content_type="application/json") 

def view_data(request):
    return render(request,'CATdb/table.html',{})   


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


