from django.urls import path
from django.conf.urls import url

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    url('^ajax/chekEmail$',views.ajax_check_email_fields),
]
