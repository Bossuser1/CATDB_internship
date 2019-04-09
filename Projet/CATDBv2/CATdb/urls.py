from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls import url

from django.contrib.staticfiles.urls import staticfiles_urlpatterns

from . import views

urlpatterns = [
    path('', views.accueil),
    url('^experiment.html$', views.experiment),
    url('^treatment.html$', views.treatment),
    url('^project.html$', views.project_all),
    url('^explore.html$', views.explorationgraph),
    url('^ajax/chekEmail$',views.ajax_check_email_fields),
    url('^ficheexperiment.html$',views.ficheexperiment),
    url('^technologies.html$',views.technologies_page),
    url('^download',views.download),
    url('^ecotype.html$', views.treatment),
    url('^protocol.html$', views.treatment),
    url('^analysis.html$', views.treatment),
    url('^Organism.html$', views.organism),
    url('^data/getinformation$', views.get_information_pop),
]+static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)+static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
