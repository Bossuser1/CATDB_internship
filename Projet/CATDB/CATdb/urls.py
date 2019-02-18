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

urlpatterns = [
    path('', views.index,name='index'),
    url('^ajax/chekEmail$',views.ajax_check_email_fields),
    url('^index$',views.view_data),
]+static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)


urlpatterns += staticfiles_urlpatterns()


