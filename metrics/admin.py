from django.contrib import admin
from models import Therapeutic_class, Therapeutic_subclass, Therapeutic_subclass_2, Therapeutic_subclass_3, Type_of_diagnosis, Subtype_of_diagnosis, Diagnosis, Subdiagnosis, Relation_SD_TS2, Relation_SD_Diagnosis, Active_ingredient, Active_ingredient_Therapeutic_class, Relation_TS3_AITC, Dosage, Dosage_form_group, Dosage_form, Pharmaceutical_company, Drug_brand, Medication, Drug_presentation, Type_of_id_patient, Patient_data,  Id_patient, Insurer, Collective,Policy, Plan,  Affiliation, Case, Status, Type_of_request, Request, Medical_report, Relation_MR_Request, Diagnostic, Prescribed_drug, Requested_medication, Related_medication, Related_diagnosis, Invoice, Dispensed_drug, Irregularity_description, Business_rule, Irregularity_prescribed_drug, Irregularity_dispensed_drug


class Therapeutic_classAdmin(admin.ModelAdmin):
    list_display = ('code', 'name')
    
class Therapeutic_subclassAdmin(admin.ModelAdmin):
    list_display = ('code', 'name')    
    
class Therapeutic_subclass_2Admin(admin.ModelAdmin):
    list_display = ('code', 'name')  
    
class Therapeutic_subclass_3Admin(admin.ModelAdmin):
    list_display = ('code', 'name')
    
class Type_of_diagnosisAdmin(admin.ModelAdmin):
    list_display = ('code', 'description')   
    
class Subtype_of_diagnosisAdmin(admin.ModelAdmin):
    list_display = ('code', 'description')   
    
class DiagnosisAdmin(admin.ModelAdmin):
    list_display = ('code', 'name', 'description', 'cie10') 
    
class SubdiagnosisAdmin(admin.ModelAdmin):
    list_display = ('code', 'name', 'description', 'cie10', 'cie9') 
    
class Active_ingredientAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name') 
    
class Active_ingredient_Therapeutic_classAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'max_daily_dosage')  
    
class DosageAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'dose', 'association_of_sex', 'vehicle')    
    
class Dosage_form_groupAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name')    
    
class Dosage_formAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name')
    
class Pharmaceutical_companyAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'address', 'phone_number') 
    
class Drug_brandAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name') 
    
class MedicationAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'drug_indications', 'contraindications', 'dosage', 'adverse_reactions')   
    
class Drug_presentationAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'units', 'dose', 'max_daily_dosage', 'max_daily_frequency', 'reference_price', 'association_of_sex', 'generic_or_drug_band')
    
class Type_of_id_patientAdmin(admin.ModelAdmin):
    list_display = ('name')  
    
class Patient_dataAdmin(admin.ModelAdmin):
    list_display = ('identity', 'first_name', 'last_name', 'sex', 'date_of_birth')  
        
class InsurerAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'insurer_type')   
    
class PlanAdmin(admin.ModelAdmin):
    list_display = ('identity', 'description')  
        
class CaseAdmin(admin.ModelAdmin):
    list_display = ('identity', 'due_date')    
    
class StatusAdmin(admin.ModelAdmin):
    list_display = ('code', 'status')     
    
class Type_of_requestAdmin(admin.ModelAdmin):
    list_display = ('code', 'description')  
    
class RequestAdmin(admin.ModelAdmin):
    list_display = ('identity', 'status', 'date') 
    
class Medical_reportAdmin(admin.ModelAdmin):
    list_display = ('identity', 'date_of_issue', 'due_date')
    
    
class Business_ruleAdmin(admin.ModelAdmin):
    list_display = ('identity', 'name', 'description', 'condition')     
    
class InvoiceAdmin(admin.ModelAdmin):
    list_display = ('identity', 'date', 'total_amount', 'number') 
    


admin.site.register(Therapeutic_class, Therapeutic_classAdmin)
admin.site.register(Therapeutic_subclass, Therapeutic_subclassAdmin)
admin.site.register(Therapeutic_subclass_2, Therapeutic_subclass_2Admin)
admin.site.register(Therapeutic_subclass_3, Therapeutic_subclass_3Admin)
admin.site.register(Type_of_diagnosis, Type_of_diagnosisAdmin)
admin.site.register(Subtype_of_diagnosis, Subtype_of_diagnosisAdmin)
admin.site.register(Diagnosis, DiagnosisAdmin)
admin.site.register(Subdiagnosis, SubdiagnosisAdmin)
admin.site.register(Relation_SD_TS2)
admin.site.register(Relation_SD_Diagnosis)
admin.site.register(Active_ingredient, Active_ingredientAdmin)
admin.site.register(Active_ingredient_Therapeutic_class, Active_ingredient_Therapeutic_classAdmin)
admin.site.register(Relation_TS3_AITC)
admin.site.register(Dosage, DosageAdmin)
admin.site.register(Dosage_form_group, Dosage_form_groupAdmin)
admin.site.register(Dosage_form, Dosage_formAdmin)
admin.site.register(Pharmaceutical_company, Pharmaceutical_companyAdmin)
admin.site.register(Drug_brand, Drug_brandAdmin)
admin.site.register(Medication, MedicationAdmin)
admin.site.register(Drug_presentation, Drug_presentationAdmin)
admin.site.register(Type_of_id_patient)
admin.site.register(Patient_data, Patient_dataAdmin)
admin.site.register(Id_patient)
admin.site.register(Insurer, InsurerAdmin)
admin.site.register(Collective)
admin.site.register(Policy)
admin.site.register(Plan, PlanAdmin)
admin.site.register(Affiliation)
admin.site.register(Case, CaseAdmin)
admin.site.register(Status, StatusAdmin)
admin.site.register(Type_of_request, Type_of_requestAdmin)
admin.site.register(Request, RequestAdmin)
admin.site.register(Medical_report, Medical_reportAdmin)
admin.site.register(Relation_MR_Request)
admin.site.register(Diagnostic)
admin.site.register(Prescribed_drug)
admin.site.register(Requested_medication)
admin.site.register(Related_medication)
admin.site.register(Related_diagnosis)
admin.site.register(Invoice, InvoiceAdmin)
admin.site.register(Dispensed_drug)
admin.site.register(Irregularity_description)
admin.site.register(Business_rule, Business_ruleAdmin)
#admin.site.register(Irregularity_diagnosis)
admin.site.register(Irregularity_prescribed_drug)
admin.site.register(Irregularity_dispensed_drug)

#admin.site.register(Irregularity_prescription) 
# Register your models here.
