from tastypie.resources import ModelResource
from tastypie.authorization import Authorization
from tastypie import fields
from tastypie.resources import ModelResource, ALL, ALL_WITH_RELATIONS
from metrics.models import Request, Type_of_request, Therapeutic_class, Therapeutic_subclass, Therapeutic_subclass_2, Therapeutic_subclass_3, Type_of_diagnosis, Subtype_of_diagnosis, Diagnosis, Subdiagnosis, Active_ingredient, Active_ingredient_Therapeutic_class, Dosage, Dosage_form_group, Dosage_form, Pharmaceutical_company, Drug_brand, Medication, Drug_presentation, Type_of_id_patient, Patient_data, Id_patient, Insurer, Collective, Policy, Plan, Affiliation, Case, Status, Medical_report, Prescribed_drug, Requested_medication, Related_medication, Related_diagnosis, Invoice, Dispensed_drug, Irregularity_description, Business_rule, Irregularity_prescribed_drug, Irregularity_dispensed_drug

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
        filtering = {
                'identity': ALL_WITH_RELATIONS,
                'type_request': ALL_WITH_RELATIONS,
                "date": ['gte', 'lte'],
            }     
        
        
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
                'active': ALL
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
        
#class IrregularityPrescriptionResource(ModelResource):
#    class Meta:
#        queryset = Irregularity_prescription.objects.all()
#        resource_name = 'irregularityPrescription'

        
#http://127.0.0.1:8000/api/v1/request/?type_request__description=completado&format=json
#http://127.0.0.1:8000/api/v1/request/?date__lte=2012-02-29&date__gte=2012-02-28&type_request__description=orden&format=json
