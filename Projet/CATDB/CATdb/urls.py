from  django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path,include
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from . import views
from django.urls import re_path
from django.conf.urls import url
from django.conf.urls import handler404, handler500

urlpatterns = [
    path('', views.index,name='index'),
    url('^ajax/chekEmail$',views.ajax_check_email_fields),
    url('^index$',views.view_data),
    
    url('^index$',views.view_data),
    url('^explore.html$',views.view_table),
    #url('^ajax/special$',views.ajax_check_email_fields1),
    url('^table.html$',views.prise_main),
    url('^project.html$',views.project),
    url('^technologies.html$',views.technologies),
    url('^listproject.html$',views.list_project),
    url('^graph/treatment_1.html$',views.graph),
    url('^description.html$',views.description),
    url('^requete.html$',views.requete),

        
]+static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)


urlpatterns += staticfiles_urlpatterns()

handler404 = views.error_404
handler500 = views.error_500
