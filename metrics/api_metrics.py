from tastypie.resources import ModelResource
from tastypie.authorization import Authorization
from tastypie import fields
from tastypie.resources import ModelResource, ALL, ALL_WITH_RELATIONS
from tastypie import fields
from tastypie.authorization import DjangoAuthorization
from datetime import datetime, time, date, timedelta
from dateutil.relativedelta import relativedelta
import calendar

from metrics.models import Request, Type_of_request, Therapeutic_class, Therapeutic_subclass, Therapeutic_subclass_2, Therapeutic_subclass_3, Type_of_diagnosis, Subtype_of_diagnosis, Diagnosis, Subdiagnosis, Active_ingredient, Active_ingredient_Therapeutic_class, Dosage, Dosage_form_group, Dosage_form, Pharmaceutical_company, Drug_brand, Medication, Drug_presentation, Type_of_id_patient, Patient_data, Id_patient, Insurer, Collective, Policy, Plan, Affiliation, Case, Status, Medical_report, Prescribed_drug, Requested_medication, Related_medication, Related_diagnosis, Invoice, Dispensed_drug, Irregularity_description, Business_rule, Irregularity_prescribed_drug, Irregularity_dispensed_drug, Savings, Substitute, Presentation_req_view, Presentation_presc_view, Medication_req_view, Medication_presc_view, Drug_brand_req_view, Drug_brand_presc_view, Pharmaceutical_req_view, Pharmaceutical_presc_view, Act_ingredient_req_view, Act_ingredient_presc_view, Therapeutic_class_req_view, Therapeutic_class_presc_view, Therapeutic_sub_req_view, Therapeutic_sub_presc_view, Therapeutic_sub2_req_view, Therapeutic_sub2_presc_view, Therapeutic_sub3_req_view, Therapeutic_sub3_presc_view, Diagnosis_req_view, Diagnosis_presc_view, Diagnosis_sub_req_view, Diagnosis_sub_presc_view, Diagnosis_type_req_view, Diagnosis_type_presc_view, Demographics_req_view, Demographics_presc_view,  Pharmacy_view, Pharmacy_chain_view, Speciality_view, Irregularity_view, Other_dispensations_drug_view, Other_dispensations_med_view, Other_prescriptions_drug_view, Other_prescriptions_med_view, Other_diagnosis_view, Posology_view, Savings_total
from django.conf.urls import *
from tastypie.authentication import BasicAuthentication

from tastypie.utils import trailing_slash

from django.db.models import Q, Sum, Avg, Count

from itertools import chain
from operator import attrgetter

import itertools
from collections import defaultdict

class TherapeuticResource(ModelResource):  
    class Meta:
        queryset = Therapeutic_class.objects.all()
        resource_name = 'therapeutic'
        
class TherapeuticSubclassResource(ModelResource):  
    class Meta:
        queryset = Therapeutic_subclass.objects.all()
        resource_name = 'therapeuticSubclass'
        
        
class TherapeuticSubclassResource2(ModelResource):  
    class Meta:
        queryset = Therapeutic_subclass_2.objects.all()
        resource_name = 'therapeuticSubclass2'
        
class TherapeuticSubclassResource3(ModelResource):  
    class Meta:
        queryset = Therapeutic_subclass_3.objects.all()
        resource_name = 'therapeuticSubclass3'
        
class TypeDiagnosisResource(ModelResource):  
    class Meta:
        queryset = Type_of_diagnosis.objects.all()
        resource_name = 'typeDiagnosis'
        
class SubtypeDiagnosisResource(ModelResource):  
    class Meta:
        queryset = Subtype_of_diagnosis.objects.all()
        resource_name = 'subtypeDiagnosis'
        
class DiagnosisResource(ModelResource):  
    class Meta:
        queryset = Diagnosis.objects.all()
        resource_name = 'diagnosis'
        
class SubdiagnosisResource(ModelResource):  
    class Meta:
        queryset = Subdiagnosis.objects.all()
        resource_name = 'subdiagnosis'
        
class ActiveIngredientResource(ModelResource):  
    class Meta:
        queryset = Active_ingredient.objects.all()
        resource_name = 'activeIngredient'
        
class ActiveIngredientTherapeuticResource(ModelResource):  
    class Meta:
        queryset = Active_ingredient_Therapeutic_class.objects.all()
        resource_name = 'activeIngredientTherapeutic'
        
class DosageResource(ModelResource):  
    class Meta:
        queryset = Dosage.objects.all()
        resource_name = 'dosage'
        
class DosageGroupResource(ModelResource):  
    class Meta:
        queryset = Dosage_form_group.objects.all()
        resource_name = 'dosageGroup'
        
class DosageFormResource(ModelResource):  
    class Meta:
        queryset = Dosage_form.objects.all()
        resource_name = 'dosageForm'
        
        
class PharmaceuticalCompanyResource(ModelResource):  
    class Meta:
        queryset = Pharmaceutical_company.objects.all()
        resource_name = 'pharmaceuticalCompany'          
        
class DrugBrandResource(ModelResource):  
    class Meta:
        queryset = Drug_brand.objects.all()
        resource_name = 'drugBrand'     
        
class MedicationResource(ModelResource):  
    class Meta:
        queryset = Medication.objects.all()
        resource_name = 'medication'   
        
class DrugPresentationResource(ModelResource):  
    class Meta:
        queryset = Drug_presentation.objects.all()
        resource_name = 'drugPresentation'  
        
class TypePatientResource(ModelResource):  
    class Meta:
        queryset = Type_of_id_patient.objects.all()
        resource_name = 'typePatient'         
        
class PatientDataResource(ModelResource):  
    class Meta:
        queryset = Patient_data.objects.all()
        resource_name = 'patientData'    
                
class IdPatientResource(ModelResource):  
    class Meta:
        queryset = Id_patient.objects.all()
        resource_name = 'idPatient'               
        
        
class InsurerResource(ModelResource):  
    class Meta:
        queryset = Insurer.objects.all()
        resource_name = 'insurer'            
        
class CollectiveResource(ModelResource):  
    class Meta:
        queryset = Collective.objects.all()
        resource_name = 'collective'        
        
class PolicyResource(ModelResource):  
    class Meta:
        queryset = Policy.objects.all()
        resource_name = 'policy'   
        
class PlanResource(ModelResource):  
    class Meta:
        queryset = Plan.objects.all()
        resource_name = 'plan'    
                
class AffiliationResource(ModelResource):  
    class Meta:
        queryset = Affiliation.objects.all()
        resource_name = 'affiliation'    
                        
class CaseResource(ModelResource):  
    class Meta:
        queryset = Case.objects.all()
        resource_name = 'case'    
                                
class StatusResource(ModelResource):  
    class Meta:
        queryset = Status.objects.all()
        resource_name = 'status'    
        
        
class TypeResource(ModelResource):  
    class Meta:
        queryset = Type_of_request.objects.all()
        resource_name = 'type'
        filtering = {
            'code': ALL,
            'description':ALL
        }


class RequestResource(ModelResource):
    type_request = fields.ForeignKey(TypeResource, 'type_of_request', full = True)
    class Meta:
        queryset = Request.objects.all()
        resource_name = 'request'
#        authentication = BasicAuthentication()
        filtering = {
                'identity': ALL_WITH_RELATIONS,
                'type_request': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte', 'gt'],
            }
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':[]}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'type_request__description':'type_of_request__description'}
        filtros2={'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 #Speciality_view.objects.filter(condiciones).values("speciality_name").annotate(Count('speciality_name'), Sum('trans'))
                
        for key in filtros2: 
            if key in request.GET:
                if key == 'date__gte':
                    start=request.GET[key]
                elif key == 'date__lte': 
                    end=request.GET[key]
                #condiciones1 = condiciones1 & Q(**{filtros[key]: request.GET[key]})
        #print condiciones
        
        start = datetime.strptime(start, "%Y-%m-%d").date()
        end = datetime.strptime(end, "%Y-%m-%d").date()
        startDay=start.day
        #print start, end
        endMonth=calendar.monthrange(start.year,start.month)
        
        start_end=start + relativedelta(day = endMonth[1])
        #print estar_end 
        object_list = Request.objects.filter(condiciones&Q(date__gte=start)&Q(date__lte=start_end))
        print "-----",start, "-", start_end
        objects['objects'].append({'month':start_end.month, 'year':start_end.year, 'transactions':object_list.count()})
        start=start_end
        #if 
        while start<end:
                tempStart=start + relativedelta(months = +1)
                if tempStart<=end:
                    startAux=tempStart
                    calendarAux=calendar.monthrange(startAux.year,startAux.month)
                    startAux=startAux+ relativedelta(day = calendarAux[1])
                else:
                    startAux=end

                print "-----",start, "-", startAux
                object_list = Request.objects.filter(condiciones&Q(date__gt=start)&Q(date__lte=startAux))
                objects['objects'].append({'month':startAux.month, 'year':startAux.year, 'transactions':object_list.count()})
                start=startAux


        filtros2={}            
            
        filtros3={}                      

        

        fin=limit+offsett
        #print 'total', object_list
        #print 'condiciones', object_list
        
        #objects['objects']['saving__sum']=object_list['saving__sum']
        #objects['objects']=object_list
        objects['meta']['total_count']=len(objects['objects'])
        return self.create_response(request, objects)
        
        
class MedicalReportResource(ModelResource):
    class Meta:
        queryset = Medical_report.objects.all()
        resource_name = 'medicalReport'
        
class PrescribedDrugResource(ModelResource):
    class Meta:
        queryset = Prescribed_drug.objects.all()
        resource_name = 'prescribedDrug'
        
class RequestedMedicationResource(ModelResource):
    class Meta:
        queryset = Requested_medication.objects.all()
        resource_name = 'requestedMedication'

class RelatedMedicationResource(ModelResource):
    class Meta:
        queryset = Related_medication.objects.all()
        resource_name = 'relatedMedication'
        
class RelatedDiagnosisResource(ModelResource):
    class Meta:
        queryset = Related_diagnosis.objects.all()
        resource_name = 'relatedDiagnosis'      
        
class InvoiceResource(ModelResource):
    class Meta:
        queryset = Invoice.objects.all()
        resource_name = 'invoice'
        
class DispensedDrugResource(ModelResource):
    class Meta:
        queryset = Dispensed_drug.objects.all()
        resource_name = 'dispensedDrug'

class IrregularityDescriptionResource(ModelResource):
    class Meta:
        queryset = Irregularity_description.objects.all()
        resource_name = 'irregularityDescription'
        
class BusinessRuleResource(ModelResource):
    class Meta:
        queryset = Business_rule.objects.all()
        resource_name = 'businessRule'   
        
#class DemographicsResource(ModelResource):
#    class Meta:
#        queryset = Demographics_view.objects.all()
#        resource_name = 'demographics' 
#        ordering={'diagnosis_name':[], 'req_presentation_name':[], 'trans':[], 'total':[]}
#        filtering = {
#            'identity': ALL_WITH_RELATIONS,
#            'diagnosis_name': ['exact', 'startswith', 'endswith', 'contains'],
#            "req_presentation_name": ['exact', 'startswith', 'endswith', 'contains'],
#            'type_of_age': ALL_WITH_RELATIONS,
#            "date": ['gte', 'lte'],
#            "trans": ['gte', 'lte'], #orden
#            "total": ['gte', 'lte'], #orden
#            "sex": ALL_WITH_RELATIONS,
#            "age": ['exact', 'gte', 'lte'],
#        }        

class PharmacyResource(ModelResource):
    class Meta:
        queryset = Pharmacy_view.objects.all()
        resource_name = 'pharmacy'  
        ordering={'name':[], 'trans':[], 'total':[]}
        filtering = {
            'identity': ALL_WITH_RELATIONS,
            'name': ['exact', 'startswith', 'endswith', 'contains'],
            'type_of_age': ALL_WITH_RELATIONS,
            "date": ['gte', 'lte'],
            "trans": ['gte', 'lte'], #orden
            "total": ['gte', 'lte'], #orden
            "callcenter": ALL_WITH_RELATIONS,
            "address": ALL_WITH_RELATIONS,
            "sex": ALL_WITH_RELATIONS,
            "age": ['exact','gte', 'lte'],
        } 


    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'name':'name', 'name__contains': 'name__contains', 'address':'address', 'address__contains':'address__contains','callcenter':'callcenter','age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Pharmacy_view.objects.filter(condiciones).values("name").annotate(Count('name'), Sum('trans'), Sum('total'))
          
        filtros2={'name__order':'name', 'trans__sum':'trans__sum', 'total__sum':'total__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)
    



class PharmacyChainResource(ModelResource):
    class Meta:
        queryset = Pharmacy_chain_view.objects.all()
        resource_name = 'pharmacyChain'  
        ordering={'name':[], 'trans':[], 'total':[]}
        filtering = {
                'identity': ALL_WITH_RELATIONS,
                'name': ['exact', 'startswith', 'endswith', 'contains'],
                'type_of_age': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
                "trans": ['gte', 'lte'], #orden
                "total": ['gte', 'lte'], #orden
                "sex": ALL_WITH_RELATIONS,
                "age":['exact','gte', 'lte'],
            } 
    

    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'name':'name', 'name__contains': 'name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Pharmacy_chain_view.objects.filter(condiciones).values("name").annotate(Count('name'), Sum('trans'), Sum('total'))
          
        filtros2={'name__order':'name', 'trans__sum':'trans__sum', 'total__sum':'total__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)
    

#class IrregularityDiagnosisResource(ModelResource):
#    class Meta:
#        queryset = Irregularity_diagnosis.objects.all()
#        resource_name = 'irregularityDiagnosis' 
        
class IrregularityPrescribedDrugResource(ModelResource):
    irregularity_description = fields.ForeignKey(IrregularityDescriptionResource, 'irregularity_description', full = True)
    related_medication = fields.ForeignKey(RelatedMedicationResource, 'related_medication', full = True)
    request = fields.ForeignKey(RequestResource, 'request', full = True)
    class Meta:
        queryset = Irregularity_prescribed_drug.objects.all()
        resource_name = 'irregularityPrescribedDrug'
        filtering = {
                'irregularity_description': ALL_WITH_RELATIONS,
                'related_medication': ALL_WITH_RELATIONS,
                'request': ALL_WITH_RELATIONS,
                'enabled': ALL,
                'active': ALL, 
                'identity': ALL,
                'ignored_irregularity':ALL
        }  
        
        
class IrregularityDispensedDrugResource(ModelResource):
    irregularity_description = fields.ForeignKey(IrregularityDescriptionResource, 'irregularity_description', full = True)
    related_medication = fields.ForeignKey(RelatedMedicationResource, 'related_medication', full = True)
    request = fields.ForeignKey(RequestResource, 'request', full = True)
    
    class Meta:
        queryset = Irregularity_dispensed_drug.objects.all()
        resource_name = 'irregularityDispensedDrug'
        filtering = {
                'irregularity_description': ALL_WITH_RELATIONS,
                'related_medication': ALL_WITH_RELATIONS,
                'request': ALL_WITH_RELATIONS,
                'enabled': ALL,
                'active': ALL


        } 
        
#http://localhost:8000/api/v1/irregularityPrescribedDrug/?request__date__gte=2012-03-01&request__date__lte=2012-03-31&limit=0&format=json
        
class SavingsResource(ModelResource):
    class Meta:
        queryset = Savings.objects.all() 
        resource_name = 'savings'
        filtering = {
                'request_identity': ALL,
                "date": ['gte', 'lte'],
                'i_presc_drug_identity': ALL,
                'i_presc_drug_description': ALL,
            } 
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]
    
    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'date':'date', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 #Speciality_view.objects.filter(condiciones).values("i_presc_drug_description").annotate(Count('speciality_name'), Sum('trans'))
                

        
        
        object_list = Savings.objects.filter(condiciones & Q(i_presc_drug_enabled=True) & Q(i_presc_drug_ignored=False) & Q(i_presc_drug_active=True)).values("i_presc_drug_description").annotate(total=Sum('i_presc_drug_description', field="(requested_medication_quantity-i_presc_drug_quantity) * requested_medication_reference_price"), cantidad=Count("i_presc_drug_description"))
        
        
             
        object_list2 = Savings.objects.filter(condiciones & Q(i_disp_drug_enabled=True) & Q(i_disp_drug_ignored=False) & Q(i_disp_drug_active=True)).values("i_disp_drug_description").annotate(total=Sum('i_disp_drug_description', field="(requested_medication_quantity-i_disp_drug_quantity) * i_disp_drug_unit_price"), cantidad=Count("i_disp_drug_description"))
                                            
                                                                                                      
        #total = Task.objects.filter(your-filter-here).aggregate(total=Sum('progress', field="progress*estimated_days"))['total']
        
        #.annotate(amount=Sum('i_presc_drug_identity', field="requested_medication_quantity-i_presc_drug_quantity * requested_medication_reference_price")#.aggregate(Sum('i_presc_drug_description'), Sum('saving'))
        #object_list = Savings_total.objects.filter(condiciones).values() 
        filtros2={}            
            
        filtros3={}                      

        

        fin=limit+offsett
        #print 'total', object_list
        print 'condiciones', object_list
        print 'condiciones2', object_list2
        
        objects['objects']=list(object_list)
        objects['meta']['total_count']=object_list.count()
        return self.create_response(request, objects)


    
class SavingsTotalResource(ModelResource):
    class Meta:
        queryset = Savings_total.objects.all() 
        resource_name = 'savingstotal'
        filtering = {
                'accident': ALL,
                "date": ['gte', 'lte'],
                'saving': ALL,
            }   
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'date':'date', 'saving': 'saving', 'accident': 'accident', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 #Speciality_view.objects.filter(condiciones).values("speciality_name").annotate(Count('speciality_name'), Sum('trans'))
        object_list = Savings_total.objects.filter(condiciones).aggregate(Sum('accident'), Sum('saving'))
        #object_list = Savings_total.objects.filter(condiciones).values() 
        filtros2={}            
            
        filtros3={}                      

        

        fin=limit+offsett
        #print 'total', object_list
        print 'condiciones', object_list
        
        objects['objects']['saving__sum']=object_list['saving__sum']
        objects['objects']['accident__sum']=object_list['accident__sum']
        objects['meta']['total_count']=1
        return self.create_response(request, objects)



class SubstitutesResource(ModelResource):
    class Meta:
        queryset = Substitute.objects.all() 
        resource_name = 'substitute'
        filtering = {
                'presc_presentation_name': ALL,
                'presc_presentation_id': ALL,
                'req_presentation_id': ALL,
                # 'presc_drug_identity': ALL,
                'presc_presentation_drugbrand': ALL,
                'req_presentation_drugbrand': ('exact', 'startswith',),
                'req_presentation_name': ('exact', 'startswith',),
                # 'requested_identity': ALL,
            }
        
class PresentationPrescViewResource(ModelResource):
    class Meta:
        queryset = Presentation_presc_view.objects.all() 
        resource_name = 'presentationPrescription'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        

class MedicationPrescViewResource(ModelResource):
    class Meta:
        queryset = Medication_presc_view.objects.all() 
        resource_name = 'medicationPrescription'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
class DrugBrandPrescViewResource(ModelResource):
    class Meta:
        queryset = Drug_brand_presc_view.objects.all() 
        resource_name = 'drugBrandPrescription'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        

class SpecialityResource(ModelResource):
    class Meta:
        queryset = Speciality_view.objects.all() 
        resource_name = 'speciality'
        ordering = {'speciality_name':[], 'trans':[]}
        filtering = {
                'speciality_name': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }


    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'speciality_name':'speciality_name', 'irregularity_description__contains': 'irregularity_description__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Speciality_view.objects.filter(condiciones).values("speciality_name").annotate(Count('speciality_name'), Sum('trans'))
          
        filtros2={'name__order':'speciality_name', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)
    



class IrregularityResource(ModelResource):
    class Meta:
        queryset = Irregularity_view.objects.all()
        resource_name = 'irregularity'
        ordering = {'irregularity_description':[], 'trans':[]}
        filtering = {
                'irregularity_description': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }

    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'irregularity_description':'irregularity_description', 'irregularity_description__contains': 'irregularity_description__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Irregularity_view.objects.filter(condiciones).values("irregularity_description").annotate(Count('irregularity_description'), Sum('trans'))
          
        filtros2={'name__order':'irregularity_description', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)

class PosologyResource(ModelResource):
    class Meta:
        queryset = Posology_view.objects.all()
        resource_name = 'posology'
        ordering = {'presentation_name':[], 'trans':[]}
        filtering = {
                'presentation_name': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }


class OtherDiagnosisResource(ModelResource):
    class Meta:
        queryset = Other_diagnosis_view.objects.all()
        resource_name = 'otherDiagnosis'
        ordering = {'diagnosis_name':[], 'trans':[], 'other':[]}
        filtering = {
                'diagnosis_name': ['exact', 'startswith', 'endswith', 'contains'],
                'other': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }

    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'diagnosis_name':'diagnosis_name', 'diagnosis_name__contains': 'diagnosis_name__contains', 'other':'other', 'other__contains': 'other__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Other_diagnosis_view.objects.filter(condiciones).values("diagnosis_name", 'other').annotate(Count('diagnosis_name'), Count('other'),  Sum('trans'))
          
        filtros2={'name__order':'other', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)


class OtherPrescriptionsMedResource(ModelResource):
    class Meta:
        queryset = Other_prescriptions_med_view.objects.all()
        resource_name = 'otherPrescriptionsMed'
        ordering = {'medication_name':[], 'trans':[], 'other':[]}
        filtering = {
                'medication_name': ['exact', 'startswith', 'endswith', 'contains'],
                'other': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'medication_name':'medication_name', 'medication_name__contains': 'medication_name__contains', 'other':'other', 'other__contains': 'other__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Other_prescriptions_med_view.objects.filter(condiciones).values("medication_name", 'other').annotate(Count('medication_name'), Count('other'),  Sum('trans'))
          
        filtros2={'name__order':'other', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)

class OtherPrescriptionsDrugResource(ModelResource):
    class Meta:
        queryset = Other_prescriptions_drug_view.objects.all()
        resource_name = 'otherPrescriptionsDrug'
        ordering = {'presentation_name':[], 'trans':[], 'other':[]}
        filtering = {
                'presentation_name': ['exact', 'startswith', 'endswith', 'contains'],
                'other': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'presentation_name':'presentation_name', 'presentation_name__contains': 'presentation_name__contains', 'other':'other', 'other__contains': 'other__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Other_prescriptions_drug_view.objects.filter(condiciones).values("presentation_name", 'other').annotate(Count('presentation_name'), Count('other'),  Sum('trans'))
          
        filtros2={'name__order':'other', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)

class OtherDispensationsMedResource(ModelResource):
    class Meta:
        queryset = Other_dispensations_med_view.objects.all()
#        queryset = Other_prescriptions_drug_view.objects.all()
        resource_name = 'otherDispensationsMed'
        ordering = {'medication_name':[], 'trans':[], 'other':[]}
        filtering = {
                'medication_name': ['exact', 'startswith', 'endswith', 'contains'],
                'other': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'medication_name':'medication_name', 'medication_name__contains': 'medication_name__contains', 'other':'other', 'other__contains': 'other__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Other_dispensations_med_view.objects.filter(condiciones).values("medication_name", 'other').annotate(Count('medication_name'), Count('other'),  Sum('trans'))
          
        filtros2={'name__order':'other', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)


class OtherDispensationsDrugResource(ModelResource):
    class Meta:
        queryset = Other_dispensations_drug_view.objects.all()
        resource_name = 'otherDispensationsDrug'
        ordering = {'presentation_name':[], 'trans':[], 'other':[]}
        filtering = {
                'presentation_name': ['exact', 'startswith', 'endswith', 'contains'],
                'other': ['exact', 'startswith', 'endswith', 'contains'],
                'trans': ['gte', 'lte'],
                'age': ['gte', 'lte'],
                'type_of_age': ALL_WITH_RELATIONS,
                'sex': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'presentation_name':'presentation_name', 'presentation_name__contains': 'presentation_name__contains', 'other':'other', 'other__contains': 'other__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Other_dispensations_drug_view.objects.filter(condiciones).values("presentation_name", 'other').annotate(Count('presentation_name'), Count('other'),  Sum('trans'))
          
        filtros2={'name__order':'other', 'trans__sum':'trans__sum'}            
            
        filtros3={'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        object_list_old=object_list.filter(condiciones1)

        

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(object_list[objects['meta']['offset']:fin])
        return self.create_response(request, objects)


    


#//--------------------------------------------------------------CUSTOM VIEWS---------------------------------------------\\         

#//--------------------------------------------------------------Presentation Requested View----------------------------------\\     
class PresentationReqViewResource(ModelResource):
    class Meta:
        queryset = Presentation_req_view.objects.all()
        resource_name = 'presentationRequested'
        detail_allowed_methods = ['get', 'post', 'put', 'delete']   
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
                'presentation_name': ALL, 
            }


    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        
        limit, offsett, objects =generalFilter(request, objects)  
        
        filtros={'presentation_name':'presentation_name', 'presentation_name__contains': 'presentation_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros)
        
        if not condiciones:
            condiciones = Q()    
                 
            
        object_list = Presentation_req_view.objects.filter(condiciones).values("presentation_name").annotate(Count('presentation_name'), Avg('presentation_price'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))
        
        object_list1 = Presentation_presc_view.objects.filter(condiciones).values("presentation_name").annotate(Count('presentation_name'), Sum('presc_drug_quantity'))
        
        filtros2={'name__order':'presentation_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','presentation_price__avg':'presentation_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'presentation_price__avg__lte':'presentation_price__avg__lte', 'presentation_price__avg__gte':'presentation_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
    
    
      
        if 'presc_drug_quantity__sum' in request.GET:
            print 'aqui------', request.GET
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(req_med_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett
        
        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 

        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Presentation_presc_view.objects.none().values("presentation_name").annotate(Count('presentation_name'), Sum('presc_drug_quantity'))
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(presentation_name=i_object['presentation_name'])))
            list_end=i_object
            if object_list1.filter(presentation_name=i_object['presentation_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(presentation_name=i_object['presentation_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        
        #fin Combinar dos modelos 

        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
        

        
#//--------------------------------------------------------------Drug Brand View----------------------------------\\ 
class MedicationReqViewResource(ModelResource):
    class Meta:
        queryset = Medication_req_view.objects.all() 
        resource_name = 'medicationRequested'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                 
        filtros={'medication_name':'medication_name', 'medication_name__contains': 'medication_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex','date__gte':'date__gte', 'date__lte':'date__lte'}
        
        condiciones=filtros_basic(request, condiciones, filtros) 
        if not condiciones:
            condiciones = Q()
          
        object_list = Medication_req_view.objects.filter(condiciones).values("medication_name").annotate(Count('medication_name'), Avg('reference_price'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))
        
        object_list1 = Medication_presc_view.objects.filter(condiciones).values("medication_name").annotate(Count('medication_name'), Sum('presc_drug_quantity'))
    
        
        filtros2={'name__order':'medication_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
      

        if 'presc_drug_quantity__sum' in request.GET:
            print 'aqui------', request.GET
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(req_med_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Medication_presc_view.objects.none().values("medication_name").annotate(Count('medication_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(medication_name=i_object['medication_name'])))
            list_end=i_object
            if object_list1.filter(medication_name=i_object['medication_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(medication_name=i_object['medication_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        
        #fin Combinar dos modelos 
        
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    



#//--------------------------------------------------------------Drug Brand Group View----------------------------------\\ 
class DrugBrandReqViewResource(ModelResource):
    class Meta:
        queryset = Drug_brand_req_view.objects.all() 
        resource_name = 'drugBrandRequested'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
       
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                     
        
        filtros={'drug_brand_name':'drug_brand_name', 'drug_brand_name__contains': 'drug_brand_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex','date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()
          
        object_list = Drug_brand_req_view.objects.filter(condiciones).values("drug_brand_name").annotate(Count('drug_brand_name'), Avg('reference_price'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))
        
        object_list1 = Drug_brand_presc_view.objects.filter(condiciones).values("drug_brand_name").annotate(Count('drug_brand_name'), Sum('presc_drug_quantity'))
        
        filtros2={'name__order':'drug_brand_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)

                
        if 'presc_drug_quantity__sum' in request.GET:
            print 'aqui------', request.GET
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Drug_brand_presc_view.objects.none().values("drug_brand_name").annotate(Count('drug_brand_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(drug_brand_name=i_object['drug_brand_name'])))
            list_end=i_object
            if object_list1.filter(drug_brand_name=i_object['drug_brand_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(drug_brand_name=i_object['drug_brand_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        
        #fin Combinar dos modelos 
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)


#//--------------------------------------------------------------Pharmaceutical View----------------------------------\\  
class PharmaceuticalReqViewResource(ModelResource):
    class Meta:
        queryset = Pharmaceutical_req_view.objects.all() 
        resource_name = 'pharmaceuticalRequested'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
       
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                 
        
        filtros={'phar_comp_name':'phar_comp_name', 'phar_comp_name__contains': 'phar_comp_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
    
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()
          
        object_list = Pharmaceutical_req_view.objects.filter(condiciones).values("phar_comp_name").annotate(Count('phar_comp_name'),   Sum('req_med_quantity'), Sum('total'), Sum('trans'))
        
        object_list1 = Pharmaceutical_presc_view.objects.filter(condiciones).values("phar_comp_name").annotate(Count('phar_comp_name'), Sum('presc_drug_quantity'))
        
        filtros2={'name__order':'phar_comp_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        

                
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Pharmaceutical_presc_view.objects.none().values("phar_comp_name").annotate(Count('phar_comp_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]:

            aux=object_list1.filter(phar_comp_name=i_object['phar_comp_name'])
            object_aux=list(chain(object_aux, aux))
            list_end=i_object

            if aux:
                list_end['presc_drug_quantity__sum']=aux[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        
        #fin Combinar dos modelos 
        
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)

    
    

    

#//--------------------------------------------------------------Active Ingredient View----------------------------------\\  
class ActIngredientReqViewResource(ModelResource):
    class Meta:
        queryset = Act_ingredient_req_view.objects.all() 
        resource_name = 'actIngredientRequested'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
       
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                 
        filtros={'act_ingredient_name':'act_ingredient_name', 'act_ingredient_name__contains': 'act_ingredient_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
    
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Act_ingredient_req_view.objects.filter(condiciones).values("act_ingredient_name").annotate(Count('act_ingredient_name'),  Avg('reference_price'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 = Act_ingredient_presc_view.objects.filter(condiciones).values("act_ingredient_name").annotate(Count('act_ingredient_name'), Sum('presc_drug_quantity'))
        
        
        filtros2={'name__order':'act_ingredient_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
            

        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Act_ingredient_presc_view.objects.none().values("act_ingredient_name").annotate(Count('act_ingredient_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(act_ingredient_name=i_object['act_ingredient_name'])))
            list_end=i_object
            if object_list1.filter(act_ingredient_name=i_object['act_ingredient_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(act_ingredient_name=i_object['act_ingredient_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        
        #fin Combinar dos modelos 
        
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    

    

#//--------------------------------------------------------------Therapeutic Class View----------------------------------\\    
class TherapeuticClassViewResource(ModelResource):
    class Meta:
        queryset = Therapeutic_class_req_view.objects.all() 
        resource_name = 'therapeuticClass'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                 
        filtros={'therapeutic_name':'therapeutic_name', 'therapeutic_name__contains': 'therapeutic_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Therapeutic_class_req_view.objects.filter(condiciones).values("therapeutic_name").annotate(Count('therapeutic_name'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 = Therapeutic_class_presc_view.objects.filter(condiciones).values("therapeutic_name").annotate(Count('therapeutic_name'), Sum('presc_drug_quantity'))
        
        
        filtros2={'name__order':'therapeutic_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
    
                

        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Therapeutic_class_presc_view.objects.none().values("therapeutic_name").annotate(Count('therapeutic_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(therapeutic_name=i_object['therapeutic_name'])))
            list_end=i_object
            if object_list1.filter(therapeutic_name=i_object['therapeutic_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(therapeutic_name=i_object['therapeutic_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
    
#//--------------------------------------------------------------Therapeutic Subclass View----------------------------------\\ 
class TherapeuticSubViewResource(ModelResource):
    class Meta:
        queryset = Therapeutic_sub_req_view.objects.all() 
        resource_name = 'therapeuticSub'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                    
        filtros={'therapeuticsub_name':'therapeuticsub_name', 'therapeuticsub_name__contains': 'therapeuticsub_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Therapeutic_sub_req_view.objects.filter(condiciones).values("therapeuticsub_name").annotate(Count('therapeuticsub_name'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Therapeutic_sub_presc_view.objects.filter(condiciones).values("therapeuticsub_name").annotate(Count('therapeuticsub_name'), Sum('presc_drug_quantity'))
        
        
        filtros2={'name__order':'therapeuticsub_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
                

        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Therapeutic_sub_presc_view.objects.none().values("therapeuticsub_name").annotate(Count('therapeuticsub_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(therapeuticsub_name=i_object['therapeuticsub_name'])))
            list_end=i_object
            if object_list1.filter(therapeuticsub_name=i_object['therapeuticsub_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(therapeuticsub_name=i_object['therapeuticsub_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
    
#//--------------------------------------------------------------Therapeutic Subclass 2 View----------------------------------\\ 
class TherapeuticSub2ViewResource(ModelResource):
    class Meta:
        queryset = Therapeutic_sub2_req_view.objects.all() 
        resource_name = 'therapeuticSub2'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                       
        filtros={'therapeuticsub2_name':'therapeuticsub2_name', 'therapeuticsub2_name__contains': 'therapeuticsub2_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Therapeutic_sub2_req_view.objects.filter(condiciones).values("therapeuticsub2_name").annotate(Count('therapeuticsub2_name'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Therapeutic_sub2_presc_view.objects.filter(condiciones).values("therapeuticsub2_name").annotate(Count('therapeuticsub2_name'), Sum('presc_drug_quantity'))
        
        
        filtros2={'name__order':'therapeuticsub2_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}                      

        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
                
                

        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Therapeutic_sub2_presc_view.objects.none().values("therapeuticsub2_name").annotate(Count('therapeuticsub2_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(therapeuticsub2_name=i_object['therapeuticsub2_name'])))
            list_end=i_object
            if object_list1.filter(therapeuticsub2_name=i_object['therapeuticsub2_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(therapeuticsub2_name=i_object['therapeuticsub2_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
#//--------------------------------------------------------------Therapeutic Subclass 3 View----------------------------------\\   
class TherapeuticSub3ViewResource(ModelResource):
    class Meta:
        queryset = Therapeutic_sub3_req_view.objects.all() 
        resource_name = 'therapeuticSub3'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                        
        filtros={'therapeuticsub3_name':'therapeuticsub3_name', 'therapeuticsub3_name__contains': 'therapeuticsub3_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Therapeutic_sub3_req_view.objects.filter(condiciones).values("therapeuticsub3_name").annotate(Count('therapeuticsub3_name'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Therapeutic_sub3_presc_view.objects.filter(condiciones).values("therapeuticsub3_name").annotate(Count('therapeuticsub3_name'), Sum('presc_drug_quantity'))
        
        
        
        filtros2={'name__order':'therapeuticsub3_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}   
        
        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Therapeutic_sub3_presc_view.objects.none().values("therapeuticsub3_name").annotate(Count('therapeuticsub3_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(therapeuticsub3_name=i_object['therapeuticsub3_name'])))
            list_end=i_object
            if object_list1.filter(therapeuticsub3_name=i_object['therapeuticsub3_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(therapeuticsub3_name=i_object['therapeuticsub3_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
    
#//--------------------------------------------------------------Diagnosis View----------------------------------\\   
class DiagnosisViewResource(ModelResource):
    class Meta:
        queryset = Diagnosis_req_view.objects.all() 
        resource_name = 'diagnosis'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                        
        filtros={'diagnosis_name':'diagnosis_name', 'diagnosis_name__contains': 'diagnosis_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Diagnosis_req_view.objects.filter(condiciones).values("diagnosis_name").annotate(Count('diagnosis_name'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Diagnosis_presc_view.objects.filter(condiciones).values("diagnosis_name").annotate(Count('diagnosis_name'), Sum('presc_drug_quantity'))
        
        print "aquiiiii"
        
        filtros2={'name__order':'diagnosis_name', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}   
        
        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Diagnosis_presc_view.objects.none().values("diagnosis_name").annotate(Count('diagnosis_name'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(diagnosis_name=i_object['diagnosis_name'])))
            list_end=i_object
            if object_list1.filter(diagnosis_name=i_object['diagnosis_name']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(diagnosis_name=i_object['diagnosis_name'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)

#Revisar filtro de sexo
#//--------------------------------------------------------------Diagnosis 2 View----------------------------------\\   
class Diagnosis2ViewResource(ModelResource):
    class Meta:
        queryset = Diagnosis_sub_req_view.objects.all() 
        resource_name = 'diagnosis2'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                        
        filtros={'subtype_description':'subtype_description', 'subtype_description__contains': 'subtype_description__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Diagnosis_sub_req_view.objects.filter(condiciones).values("subtype_description").annotate(Count('subtype_description'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Diagnosis_sub_presc_view.objects.filter(condiciones).values("subtype_description").annotate(Count('subtype_description'), Sum('presc_drug_quantity'))
        
        print "aquiiiii"
        
        filtros2={'name__order':'subtype_description', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}   
        
        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Diagnosis_sub_presc_view.objects.none().values("subtype_description").annotate(Count('subtype_description'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(subtype_description=i_object['subtype_description'])))
            list_end=i_object
            if object_list1.filter(subtype_description=i_object['subtype_description']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(subtype_description=i_object['subtype_description'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
#//--------------------------------------------------------------Diagnosis 1 View----------------------------------\\   
class Diagnosis1ViewResource(ModelResource):
    class Meta:
        queryset = Diagnosis_type_req_view.objects.all() 
        resource_name = 'diagnosis1'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                        
        filtros={'type_description':'type_description', 'type_description__contains': 'type_description__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Diagnosis_type_req_view.objects.filter(condiciones).values("type_description").annotate(Count('type_description'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Diagnosis_type_presc_view.objects.filter(condiciones).values("type_description").annotate(Count('type_description'), Sum('presc_drug_quantity'))
        
        print "aquiiiii"
        
        filtros2={'name__order':'type_description', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}   
        
        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Diagnosis_type_presc_view.objects.none().values("type_description").annotate(Count('type_description'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(type_description=i_object['type_description'])))
            list_end=i_object
            if object_list1.filter(type_description=i_object['type_description']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(type_description=i_object['type_description'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
    
#//--------------------------------------------------------------Demographics View----------------------------------\\   
class DemographicsSexResource(ModelResource):
    class Meta:
        queryset = Demographics_req_view.objects.all() 
        resource_name = 'demographics_sex'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                        
        filtros={'diagnosis_name':'diagnosis_name', 'diagnosis_name__contains': 'diagnosis_name__contains', 'req_presentation_name':'req_presentation_name', 'req_presentation_name__contains': 'req_presentation_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Demographics_req_view.objects.filter(condiciones).values("sex").annotate(Count('sex'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Demographics_presc_view.objects.filter(condiciones).values("sex").annotate(Count('sex'), Sum('presc_drug_quantity'))
        
        print "aquiiiii"
        
        filtros2={'name__order':'sex', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}   
        
        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)

        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Demographics_presc_view.objects.none().values("sex").annotate(Count('sex'), Sum('presc_drug_quantity'))
         
        print 'holaaa', object_list
               
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(diagnosis_name=i_object['sex'])))
            list_end=i_object
            if object_list1.filter(diagnosis_name=i_object['sex']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(diagnosis_name=i_object['sex'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
    
    
#//--------------------------------------------------------------Demographics View----------------------------------\\   
class DemographicsAgeResource(ModelResource):
    class Meta:
        queryset = Demographics_req_view.objects.all() 
        resource_name = 'demographics_age'
        filtering = {
                'sex': ALL,
                'age': ALL,
                "date": ['gte', 'lte'],
            }
        
    def prepend_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/custom%s$" % (self._meta.resource_name, trailing_slash()), self.wrap_view('get_custom'), name="api_get_custom"),
 
        ]

    def get_custom(self, request, **kwargs):     
        objects={'meta':{},'objects':{}}
        condiciones = Q()
        condiciones1 = Q()
        condiciones_pres = Q()
        limit, offsett, objects =generalFilter(request, objects)                        
        filtros={'diagnosis_name':'diagnosis_name', 'diagnosis_name__contains': 'diagnosis_name__contains', 'req_presentation_name':'req_presentation_name', 'req_presentation_name__contains': 'req_presentation_name__contains', 'age': 'age','age__lte':'age__lte','age__gte':'age__gte',   'type_of_age': 'type_of_age', 'sex':'sex', 'date__gte':'date__gte', 'date__lte':'date__lte'}
        condiciones=filtros_basic(request, condiciones, filtros) 
    
        if not condiciones:
            condiciones = Q()

        object_list = Demographics_req_view.objects.filter(condiciones).exclude(type_of_age='M', age__gte=2).values("age", "type_of_age").annotate(Count('age'), Count('type_of_age'), Sum('req_med_quantity'), Sum('total'), Sum('trans'))

        
        object_list1 =Demographics_presc_view.objects.filter(condiciones).exclude(type_of_age='M', age__gte=2).values("age", "type_of_age").annotate(Count('sex'), Count('type_of_age'), Sum('presc_drug_quantity'))
        
        print "aquiiiii"
        
        filtros2={'name__order':'age', 'req_med_quantity__sum': 'req_med_quantity__sum', 'total__sum': 'total__sum','reference_price__avg':'reference_price__avg','trans__sum':'trans__sum'}            
            
        filtros3={'req_med_quantity__sum__lte': 'req_med_quantity__sum__lte', 'req_med_quantity__sum__gte':'req_med_quantity__sum__gte', 'total__sum__lte':'total__sum__lte', 'total__sum__gte':'total__sum__gte', 'reference_price__avg__lte':'reference_price__avg__lte', 'reference_price__avg__gte':'reference_price__avg__gte', 'trans__sum__lte':'trans__sum__lte', 'trans__sum__gte':'trans__sum__gte'}   
        
        condiciones1, object_list=filtros_order(request, condiciones1, object_list,  filtros2)
        
        condiciones1, object_list=filtros_range(request, condiciones1, object_list,  filtros3)
        
        if 'presc_drug_quantity__sum' in request.GET:
            if request.GET['presc_drug_quantity__sum']=='asc':
                object_list1=object_list1.order_by('presc_drug_quantity__sum')
            elif request.GET['presc_drug_quantity__sum']=='desc':
                object_list1=object_list1.order_by('-presc_drug_quantity__sum')
            else:
                condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum=request.GET['presc_drug_quantity__sum'])         

        if 'presc_drug_quantity__sum__lte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__lte=request.GET['presc_drug_quantity__sum__lte'])        
        if 'presc_drug_quantity__sum__gte' in request.GET:
            condiciones_pres = condiciones_pres & Q(presc_drug_quantity__sum__gte=request.GET['presc_drug_quantity__sum__gte']) 
            
        fin=limit+offsett

        object_list=object_list.filter(condiciones1)
        
        object_list1=object_list1.filter(condiciones_pres)
        
        object_list_old=object_list.filter(condiciones1)
        

        
        #Combinar dos modelos 
        
        collector = defaultdict(dict)
        
        list_end=[]
        list_end2=[]
        object_aux=Demographics_presc_view.objects.none().values("age", "type_of_age").annotate(Count('sex'), Count('type_of_age'), Sum('presc_drug_quantity'))
        
    
        for i_object in object_list[objects['meta']['offset']:fin]: 
            object_aux=list(chain(object_aux, object_list1.filter(age=i_object['age'], type_of_age=i_object['type_of_age']).exclude(type_of_age='M', age__gte=2)))
            list_end=i_object
            if object_list1.filter(age=i_object['age'], type_of_age=i_object['type_of_age']):
                list_end['presc_drug_quantity__sum']=object_list1.filter(age=i_object['age'], type_of_age=i_object['type_of_age'])[0]['presc_drug_quantity__sum']
            else:
                list_end['presc_drug_quantity__sum']=0
            
            list_end2=list_end2+[list_end]

        
        objects['objects']=list_end2
        objects['meta']['total_count']=object_list_old.count()
        objects['objects']=list(objects['objects'])
        return self.create_response(request, objects)
    
#//----------------------------------------------------FUNTION FILTER-----------------------------------------------\\
def generalFilter(request, objects):
    if 'limit' in request.GET:
        objects['meta']['limit']=request.GET['limit']
        limit=int(request.GET['limit'])
    else:
        objects['meta']['limit']=50  
        limit=int(50)      

    if 'offset' in request.GET:
        objects['meta']['offset']=request.GET['offset']
        offsett=int(request.GET['offset'])
    else:
        objects['meta']['offset']=0
        offsett=int(0) 
        
    return limit, offsett, objects

def filtros_basic(request, condiciones, filtros):
    for key in filtros: 
        if key in request.GET:
            condiciones = condiciones & Q(**{filtros[key]: request.GET[key]})
    print condiciones
    return condiciones

def filtros_order(request, condiciones1, object_list, filtros):
    for key in filtros: 
        if key in request.GET:
            if request.GET[key]=='asc':
                orden=filtros[key]
                object_list=object_list.order_by(orden)
            elif request.GET[key]=='desc':
                orden="-"+filtros[key]
                print "1---",orden
                object_list=object_list.order_by(orden)   
            else:
                condiciones1 = condiciones1 & Q(**{filtros[key]: request.GET[key]})
    print "ej----", object_list                       
    return condiciones1, object_list

def filtros_range(request, condiciones1, object_list, filtros):
    for key in filtros: 
        if key in request.GET:
            condiciones1 = condiciones1 & Q(**{filtros[key]: request.GET[key]})
            
    return condiciones1, object_list      


  

# class MedicationViewResource(ModelResource):
#     class Meta:
#         queryset = Medication_view.objects.all() 
#         resource_name = 'medicationView'
#         filtering = {
#                 'patient_sex': ALL,
#                 'patient_birth': ALL,
#                 "case_date": ['gte', 'lte'],
#                 "request_date": ['gte', 'lte'],
#             }
        
        
#class IrregularityPrescriptionResource(ModelResource):
#    class Meta:
#        queryset = Irregularity_prescription.objects.all()
#        resource_name = 'irregularityPrescription'


#Call api       
#http://127.0.0.1:8000/api/v1/request/?type_request__description=orden&format=json
#http://127.0.0.1:8000/api/v1/request/?date__lte=2012-02-29&date__gte=2012-02-28&type_request__description=orden&format=json

#http://localhost:8000/api/v1/irregularityPrescribedDrug/?request__date__lte=2012-12-29&request__date__gte=2012-02-01&format=json
#http://localhost:8000/api/v1/irregularityDispensedDrug/?request__date__lte=2012-12-29&request__date__gte=2012-02-01&format=json


#http://localhost:8000/api/v1/irregularityDescription/?format=json
# presentation_name=3-A OFTENO SOL. 1 MG X 5 ML&
