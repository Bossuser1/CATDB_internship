#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 15 07:19:48 2019

@author: traore
"""
import os

from configparser import ConfigParser


def config(section='postgresql'):
    if os.getcwd()[0:12]!="/home/traore":
    	filename=os.getcwd()+'/CATdb/database.ini'
    else:
    	filename=os.getcwd()+'/CATdb/database2.ini'
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
