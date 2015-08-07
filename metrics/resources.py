from rest_framework.resources import ModelResource
from rest_framework import serializers
 
from metrics.modelos_sqlalchemy import Therapeutic_class
 
class Therapeutic_classResource(serializers.ModelSerializer):
    """Resource for model PointOfSale
    """
    model = Therapeutic_class
    ordering = ('-name',)
    exclude = ('code')