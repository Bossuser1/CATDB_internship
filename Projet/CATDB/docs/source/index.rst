.. CATDB_django documentation master file, created by
   sphinx-quickstart on Thu Feb 14 09:40:56 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to CATDB_django's documentation!
========================================

Contents:

.. toctree::
   :maxdepth: 2

* Installation de django
* creation du projet

  * avec une liste imbriquée
  * et un sous-item

* mise a jour

* Django sphinx ecriture 
::
	make html
	sphinx-build -b rinoh source _build/rinoh
	
Connection a la base de données
======

pip install psycopg2

======


Mise a jour des modifications
==================	
pour les mises a jour du fichier static

*- assurer vous que le fichier setting.py du projet sois en absolue tels que ci dessous
STATIC_ROOT =os.path.join(BASE_DIR,'static')
/static/'# os.path.join(BASE_DIR,'static')
STATIC_URL = '/static/'

*- aller dans le dossier principal et faite 

python manage.py collectstatic	
	
lancer le server	
===	
python manage.py runserver jacob.ips2.u-psud.fr:8080
	
Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

