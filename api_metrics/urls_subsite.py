# -*- coding: utf-8 -*-
from django.conf.urls import patterns, include, url
from settings import MEDIA_ROOT
from django.conf import settings

from django.contrib import admin
admin.autodiscover()
#from audit.admin import my_admin

#Django rest test
#from metrics.viewsets import Therapeutic_classViewSet
#from rest_framework.routers import DefaultRouter
#router = DefaultRouter()
#router.register(r'asegurador', AseguradorViewSet)
#router.register(r'therapeutic_class', Therapeutic_classViewSet)

#Tastypie
#from tastypie.api import Api
#from metrics.resources import Therapeutic_classResource

#v1_api = Api(api_name='v1')
#v1_api.register(AseguradorResource())
#v1_api.register(Therapeutic_classResource())

# mostrar archivos estáticos en el error 500
#handler500 = 'audit.views.error500'

#handler403 = 'audit.views.error403'
 
#from rest_framework.views import ListOrCreateModelView
 
#from metrics.modelos_sqlalchemy import Therapeutic_class, Therapeutic_subclass
 
urlpatterns = patterns('',
   
    url(r'^api/therapeutic_class$', 'metrics.prueba_alchemy.therapeutic_class'),
    url(r'^api/therapeutic_class/add$', 'metrics.prueba_alchemy.therapeutic_class_add'),
    url(r'^api/therapeutic_class/update$', 'metrics.prueba_alchemy.therapeutic_class_update'),
    url(r'^api/therapeutic_class/delete$', 'metrics.prueba_alchemy.therapeutic_class_delete'),
    url(r'^api/therapeutic_subclass$', 'metrics.prueba_alchemy.therapeutic_subclass'),
    url(r'^api/therapeutic_subclass/add$', 'metrics.prueba_alchemy.therapeutic_subclass_add'),
    url(r'^api/therapeutic_subclass/update$', 'metrics.prueba_alchemy.therapeutic_subclass_update'),
    url(r'^api/therapeutic_subclass/delete$', 'metrics.prueba_alchemy.therapeutic_subclass_delete'),
    url(r'^pos_rest/$', 'metrics.prueba_alchemy.prueba'),
                
    #url(r'^favicon\.ico$', 'django.views.generic.simple.redirect_to', {'url': '/static/images/favicon.ico'}),
    #url(r'^$', 'metrics.prueba_alchemy.prueba'),
    #url(r'^home/$', 'metrics.views.home'),
    #url(r'^audit/$', 'audit.views.index'),
    #url(r'^orden/$', 'orden.views.index'),
    #url(r'^recuperar/$', 'audit.views.recuperar'),
    #url(r'^ingresar/$', 'audit.views.ingresar'),
    #url(r'^contacto/$', 'audit.views.contacto'),
    #url(r'^orden/', include('orden.urls')),
    #url(r'^farmacia/', include('orden_farmacia.urls')),
    #url(r'^audit/', include('audit.urls')),
    #url(r'^PRXAnalyzer/', include('PRXAnalyzer.urls')),
    #url(r'^prueba/$','common.functions.ajax_prueba'),
    #url(r'^common/asegurado/$','common.functions.ajax_asegurados'),
    #url(r'^common/medicamentos/$','common.functions.ajax_medicamentos'),
    #url(r'^common/principios_con_dosis/$','common.functions.ajax_principios_con_dosis'),
    #url(r'^common/patologias/$','common.functions.ajax_patologias'),
    #url(r'^media/(.*)$','django.views.static.serve',
	#	{'document_root':settings.MEDIA_ROOT,}
	#),
	url(r'^admin/', include(admin.site.urls)),
    #url(r'^pca_config/', include(my_admin.urls)),
    
    #url(r'^account/', include('django.contrib.auth.urls')),
    #url(r'^servicio/','web_service.views.ordenes_service'),
    #url(r'^test/','web_service.views.prueba_service'),
    #url(r'^api/?','web_service.views.api'),
    #url(r'^XML/$','orden.views.XMLO'),
    #url(r'^$', include(router.urls)),
    #url(r'^api-auth/', include('rest_framework.urls', namespace = 'rest_framework')),
#    url(r'^api/', include(v1_api.urls))
)
