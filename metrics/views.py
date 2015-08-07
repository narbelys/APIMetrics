from django.shortcuts import render
from django.http import HttpResponse
import json, inspect, time
from django.utils import simplejson
from metrics.models import Request, Type_of_request, Therapeutic_class, Therapeutic_subclass, Therapeutic_subclass_2, Therapeutic_subclass_3, Type_of_diagnosis, Subtype_of_diagnosis, Diagnosis, Subdiagnosis, Active_ingredient, Active_ingredient_Therapeutic_class, Dosage, Dosage_form_group, Dosage_form, Pharmaceutical_company, Drug_brand, Medication, Drug_presentation, Type_of_id_patient, Patient_data, Id_patient, Insurer, Collective, Policy, Plan, Affiliation, Case, Status, Medical_report, Prescribed_drug, Requested_medication, Related_medication, Related_diagnosis, Invoice, Dispensed_drug, Irregularity_description, Business_rule, Irregularity_prescribed_drug, Irregularity_dispensed_drug, Savings, Substitute, Presentation_req_view, Presentation_presc_view, Medication_req_view, Medication_presc_view, Drug_brand_req_view, Drug_brand_presc_view
from django.db.models import Sum, Avg, Count

def index(request):
	# queryset = Presentation_req_view.objects.all().values("presentation_name").annotate(Count('presentation_name'), Avg('presentation_price'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))
	queryset = Presentation_req_view.objects.all().values("presentation_name").annotate(Count('presentation_name'), Avg('presentation_price'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))
	# queryset = Presentation_req_view.objects.values("presentation_name", 'trans', 'age')
	print queryset
	# values("presentation_name", 'presentation_price', 'trans', 'age', 'date')

	# .annotate(data_sum=Sum('presentation_price'))
	# return HttpResponse(json.JSONEncoder().encode(queryset), mimetype="application/json")
	return HttpResponse(queryset)

# Create your views here. 