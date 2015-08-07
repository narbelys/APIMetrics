# -*- coding: utf-8 -*-

from django import forms
from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save, pre_save, m2m_changed
from django.core.files.storage import FileSystemStorage
#from PIL import Image as img
import math

#Therapeutic Class
class Therapeutic_class(models.Model):
    code = models.CharField(max_length=1, primary_key=True)
    name = models.CharField(max_length=150)
    class Meta:
        db_table = 'Therapeutic_class'
        
    def __unicode__(self):
        return unicode(self.name)

#Therapeutic Subclass
class Therapeutic_subclass(models.Model):
    code = models.CharField(max_length=3, primary_key=True)
    name = models.CharField(max_length=150)
    therapeutic_class = models.ForeignKey(Therapeutic_class, db_column='tc_code')
    class Meta:
        db_table = 'Therapeutic_subclass'
    def __unicode__(self):
        return unicode(self.name)

#Therapeutic Subclass 2
class Therapeutic_subclass_2(models.Model):
    code = models.CharField(max_length=4, primary_key=True)
    name = models.CharField(max_length=150)
    therapeutic_subclass = models.ForeignKey(Therapeutic_subclass, db_column='ts_code')
    class Meta:
        db_table = 'Therapeutic_subclass_2'
    def __unicode__(self):
        return unicode(self.name)

#Therapeutic Subclass 3
class Therapeutic_subclass_3(models.Model):
    code = models.CharField(max_length=5, primary_key=True)
    name = models.CharField(max_length=150)
    therapeutic_subclass_2 = models.ForeignKey(Therapeutic_subclass_2, db_column='ts2_code')
    class Meta:
        db_table = 'Therapeutic_subclass_3'
    def __unicode__(self):
        return unicode(self.name)

#Type of Diagnosis
class Type_of_diagnosis(models.Model):
    code = models.CharField(max_length=9, primary_key=True)
    description = models.CharField(max_length=600)
    class Meta:
        db_table = 'Type_of_diagnosis'
        
    def __unicode__(self):
        return unicode(self.description)

#Subtype of Diagnosis
class Subtype_of_diagnosis(models.Model):
    code = models.CharField(max_length=12, primary_key=True)
    description = models.CharField(max_length=600, null=True)
    type_of_diagnosis = models.ForeignKey(Type_of_diagnosis, db_column='td_code')
    class Meta:
        db_table = 'Subtype_of_diagnosis'
        
    def __unicode__(self):
        return unicode(self.description)

#Diagnosis
class Diagnosis(models.Model):
    code = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=600)
    description = models.CharField(max_length=1500, null=True)
    keywords = models.CharField(max_length=1500, null=True)
    cie10 = models.CharField(max_length=9, null=True)
    class Meta:
        db_table = 'Diagnosis'
    def __unicode__(self):
        return unicode(self.name)

#Subdiagnosis
class Subdiagnosis(models.Model):
    code = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=600)
    description = models.CharField(max_length=1500, null=True)
    cie9 = models.CharField(max_length=9, null=True)
    cie10 = models.CharField(max_length=9, null=True)
    diagnosis = models.ForeignKey(Diagnosis, db_column='diagnosis_code')
    status = models.IntegerField()
    class Meta:
        db_table = 'Subdiagnosis'
        
    def __unicode__(self):
        return unicode(self.name)

#Auxiliary for relationship n-m Subtype of Diagnosis - Therapeutic Subclass 2
class Relation_SD_TS2(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    priority = models.IntegerField()
    subtype_of_diagnosis = models.ForeignKey(Subtype_of_diagnosis, db_column='sd_code')
    therapeutic_subclass_2 = models.ForeignKey(Therapeutic_subclass_2, db_column='ts2_code')
    class Meta:
        db_table = 'Relation_SD_TS2'
    def __unicode__(self):
        return unicode(self.identity)

#Auxiliary for relationship n-m Subtype of Diagnosis - Diagnosis
class Relation_SD_Diagnosis(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    subtype_of_diagnosis = models.ForeignKey(Subtype_of_diagnosis, db_column='sd_code')
    diagnosis = models.ForeignKey(Diagnosis, db_column='diagnosis_code')
    class Meta:
        db_table = 'Relation_SD_Diagnosis'
    def __unicode__(self):
        return unicode(self.identity)

#Active Ingredient
class Active_ingredient(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    class Meta:
        db_table = 'Active_ingredient'
    def __unicode__(self):
        return unicode(self.identity)

#Active Ingredient discriminated by Therapeutic Class
class Active_ingredient_Therapeutic_class(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    max_daily_dosage = models.FloatField()
    active_ingredient = models.ForeignKey(Active_ingredient, db_column='ai_identity')
    class Meta:
        db_table = 'Active_ingredient_Therapeutic_class'
    def __unicode__(self):
        return unicode(self.identity)

#Auxiliary for relationship n-m Therapeutic Subclass 3 - Active Ingredient discriminated by Therapeutic Class
class Relation_TS3_AITC(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    priority = models.IntegerField()
    active_ingredient_therapeutic_class = models.ForeignKey(Active_ingredient_Therapeutic_class, db_column='aitc_identity')
    therapeutic_subclass_3 = models.ForeignKey(Therapeutic_subclass_3, db_column='ts3_code')
    class Meta:
        db_table = 'Relation_TS3_AITC'
    def __unicode__(self):
        return unicode(self.identity)

#Dosage
class Dosage(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    dose = models.FloatField()
    association_of_sex = models.CharField(max_length=10)
    vehicle = models.FloatField()
    active_ingredient_therapeutic_class = models.ForeignKey(Active_ingredient_Therapeutic_class,db_column='aitc_identity')
    class Meta:
        db_table = 'Dosage'
    def __unicode__(self):
        return unicode(self.name)

#Dosage form Group
class Dosage_form_group(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=240)
    class Meta:
        db_table = 'Dosage_form_group'
    def __unicode__(self):
        return unicode(self.name)

#Dosage form
class Dosage_form(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    dosage_form_group = models.ForeignKey(Dosage_form_group, db_column='dfg_identity')
    class Meta:
        db_table = 'Dosage_form'
    def __unicode__(self):
        return unicode(self.name)

#Pharmaceutical Company
class Pharmaceutical_company(models.Model):
    identity = models.CharField(max_length=9,primary_key=True)
    name = models.CharField(max_length=300)
    address = models.CharField(max_length=750, null=True)
    phone_number = models.CharField(max_length=300, null=True)
    image = models.CharField(max_length=1500, null=True)
    class Meta:
        db_table = 'Pharmaceutical_company'
    def __unicode__(self):
        return unicode(self.name)

#Drug Brand
class Drug_brand(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    class Meta:
        db_table = 'Drug_brand'
    def __unicode__(self):
        return unicode(self.name)

#Medication
class Medication(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    keywords = models.CharField(max_length=1500, null=True)
    drug_indications = models.CharField(max_length=1500, null=True)
    contraindications = models.CharField(max_length=1500, null=True)
    dosage = models.CharField(max_length=1500, null=True)
    adverse_reactions = models.CharField(max_length=1500, null=True)
    drug_brand = models.ForeignKey(Drug_brand, db_column='db_identity')
    class Meta:
        db_table = 'Medication'
    def __unicode__(self):
        return unicode(self.name)

#Drug Presentation
class Drug_presentation(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    units = models.FloatField()
    dose = models.FloatField()
    max_daily_dosage = models.FloatField()
    max_daily_frequency = models.FloatField(null=True)
    reference_price = models.FloatField(null=True)
    # dispensing_form = models.CharField(max_length=1500)
    association_of_sex = models.CharField(max_length=10)
    image = models.CharField(max_length=1500, null=True)
    generic_or_drug_band = models.CharField(max_length=10)
    pharmaceutical_company = models.ForeignKey(Pharmaceutical_company, db_column='pc_identity')
    medication = models.ForeignKey(Medication, db_column='medication_identity')
    dosage = models.ForeignKey(Dosage, db_column='dosage_identity', null=True)
    dosage_form = models.ForeignKey(Dosage_form, db_column='dosage_form_identity')
    class Meta:
        db_table = 'Drug_presentation'
    def __unicode__(self):
        return unicode(self.name)

#Posology
class Posology(models.Model):
    identity = models.IntegerField(primary_key=True)
    quantity = models.IntegerField(null=True)
    frequency = models.FloatField(null=True)
    duration = models.IntegerField(null=True)
    measure = models.FloatField(null=True)
    class Meta:
        db_table = 'Posology'
    def __unicode__(self):
        return unicode(self.identity)

#Pharmacy chain
class Pharmacy_chain(models.Model):
    identity = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=50)
    class Meta:
        db_table = 'Pharmacy_chain'
    def __unicode__(self):
        return unicode(self.identity)

#Pharmacy
class Pharmacy(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=1500)
    company_name = models.CharField(max_length=1500)
    rif = models.CharField(max_length=45)
    address = models.CharField(max_length=1500)
    phone_number = models.CharField(max_length=35)
    logo = models.CharField(max_length=20)
    status = models.IntegerField()
    callcenter = models.BooleanField()
    web = models.CharField(max_length=50)
    pharmacy_chain = models.ForeignKey(Pharmacy_chain, db_column='chain_identity')
    class Meta:
        db_table = 'Pharmacy'
    def __unicode__(self):
        return unicode(self.identity)

#Country
class Country(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=100)
    class Meta:
        db_table = 'Country'
    def __unicode__(self):
        return unicode(self.identity)

#Type of ID Patient
class Type_of_id_patient(models.Model):
    name = models.CharField(max_length=50, primary_key=True)
    class Meta:
        db_table = 'Type_of_id_patient'
    def __unicode__(self):
        return unicode(self.name)

#Patient Data
class Patient_data(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    sex = models.CharField(max_length=10)
    date_of_birth = models.DateField(null=True)
    cell_phone = models.CharField(max_length=35, null=True)
    home_phone = models.CharField(max_length=35, null=True)
    email = models.CharField(max_length=1500, null=True)
    address = models.CharField(max_length=1500, null=True)
    reminder = models.IntegerField(null=True)
    class Meta:
        db_table = 'Patient_data'
    def __unicode__(self):
        return unicode(self.identity)

#ID Patient
class Id_patient(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    type_of_id = models.ForeignKey(Type_of_id_patient, db_column='type_id_name')
    patient_data = models.ForeignKey(Patient_data, db_column='patient_data_identity')
    pharmacy = models.ForeignKey(Pharmacy, db_column='pharmacy_identity', null=True)
    class Meta:
        db_table = 'Id_patient'
    def __unicode__(self):
        return unicode(self.identity)

#SMS
class SMS(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    date = models.DateField()
    type = models.IntegerField()
    message = models.CharField(max_length=1500)
    id_patient = models.ForeignKey(Id_patient, db_column='id_patient_identity')
    class Meta:
        db_table = 'SMS'
    def __unicode__(self):
        return unicode(self.identity)

#Insurer
class Insurer(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    insurer_type = models.CharField(max_length=100)
    logo = models.CharField(max_length=1500, null=True)
    class Meta:
        db_table = 'Insurer'
    def __unicode__(self):
        return unicode(self.identity)

#Collective
class Collective(models.Model):
    identity = models.CharField(max_length=50, primary_key=True)
    insurer = models.ForeignKey(Insurer, db_column='insurer_identity')
    class Meta:
        db_table = 'Collective'
    def __unicode__(self):
        return unicode(self.identity)

#Policy
class Policy(models.Model):
    identity = models.CharField(max_length=50, primary_key=True)
    collective = models.ForeignKey(Collective, db_column='collective_identity')
    class Meta:
        db_table = 'Policy'
    def __unicode__(self):
        return unicode(self.identity)

#Plan
class Plan(models.Model):
    identity = models.CharField(max_length=50, primary_key=True)
    description = models.CharField(max_length=300, null=True)
    policy = models.ForeignKey(Policy, db_column='policy_identity')
    class Meta:
        db_table = 'Plan'
    def __unicode__(self):
        return unicode(self.identity)

#Affiliation
class Affiliation(models.Model):
    identity = models.CharField(max_length=50, primary_key=True)
    plan = models.ForeignKey(Plan, db_column='plan_identity')
    id_patient = models.ForeignKey(Id_patient, db_column='id_patient_identity')
    class Meta:
        db_table = 'Affiliation'
    def __unicode__(self):
        return unicode(self.identity)

#Case
class Case(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    due_date = models.DateField(null=True)
    affiliation = models.ForeignKey(Affiliation, db_column='affiliation_identity')
    relationship = models.CharField(max_length=3, null=True)
    uptake = models.FloatField(null=True)
    coverage = models.FloatField(null=True)
    class Meta:
        db_table = 'Case'
    def __unicode__(self):
        return unicode(self.identity)

#Status
class Status(models.Model):
    code = models.IntegerField(primary_key=True)
    status = models.CharField(max_length=50)
    class Meta:
        db_table = 'Status'
    def __unicode__(self):
        return unicode(self.code)

#Type of Request
class Type_of_request(models.Model):
    code = models.IntegerField(primary_key=True)
    description = models.CharField(max_length=50)
    class Meta:
        db_table = 'Type_of_request'
    def __unicode__(self):
        return unicode(self.code)
        
#class RequestManager(models.Manager): 
#    def near(self, identity, status, date, case, type_of_request):
#        queryset = super(RequestManager, self).get_query_set() 
#        # [snip] take your args and build the SQL needed to locate Spots with distance_m meters 
#        # This will depend on whether you're using PostGIS, raw trig in SQL, a bounding box with geopy, etc 
#        return queryset.whatever() 
    
#Request
class Request(models.Model):
#    objects = RequestManager()
    identity = models.BigIntegerField(primary_key=True)
    status = models.IntegerField()
    date = models.DateField()
    case = models.ForeignKey(Case, db_column='case_identity', null=True)
    type_of_request = models.ForeignKey(Type_of_request, db_column='type_request_code')
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    number = models.BigIntegerField()
    insurer = models.ForeignKey(Insurer, db_column='insurer_identity', null=True)
    registration_date = models.DateField(null=True)
    closing_date = models.DateField(null=True)
    class Meta:
        db_table = 'Request'
    def __unicode__(self):
        return unicode(self.identity)

#Speciality
class Speciality(models.Model):
    identity = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=100)
    class Meta:
        db_table = 'Speciality'
    def __unicode__(self):
        return unicode(self.identity)

#Doctor
class Doctor(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    registration = models.CharField(max_length=50)
    identification = models.CharField(max_length=20)
    phone_number = models.CharField(max_length=20)
    class Meta:
        db_table = 'Doctor'
    def __unicode__(self):
        return unicode(self.identity)

#Auxiliary for relationship n-m Doctor - Speciality
class Relation_doctor_speciality(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    doctor = models.ForeignKey(Doctor, db_column='doctor_identity')
    speciality = models.ForeignKey(Speciality, db_column='speciality_identity')
    class Meta:
        db_table = 'Relation_doctor_speciality'
    def __unicode__(self):
        return unicode(self.identity)

#Doctor Barcodes
class Doctor_barcodes(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    doctor = models.ForeignKey(Doctor, db_column='doctor_identity')
    barcode = models.CharField(max_length=25)
    class Meta:
        db_table = 'Doctor_barcodes'
    def __unicode__(self):
        return unicode(self.identity)

#Medical Report
class Medical_report(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    date_of_issue = models.DateField(null=True)
    due_date = models.DateField(null=True)
    case = models.ForeignKey(Case, db_column='case_identity', null=True)
    number = models.BigIntegerField()
    doctor = models.ForeignKey(Doctor, db_column='doctor_identity', null=True)
    class Meta:
        db_table = 'Medical_report'
    def __unicode__(self):
        return unicode(self.identity)

#Auxiliary for relationship n-m Medical Report - Request
class Relation_MR_Request(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    request = models.ForeignKey(Request, db_column='request_identity')
    medical_report = models.ForeignKey(Medical_report, db_column='mr_identity')
    class Meta:
        db_table = 'Relation_MR_Request'
    def __unicode__(self):
        return unicode(self.identity)

#Auxiliary for relationship n-m Medical Report - Speciality
class Relation_MR_Speciality(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    speciality = models.ForeignKey(Speciality, db_column='speciality_identity')
    medical_report = models.ForeignKey(Medical_report, db_column='mr_identity')
    class Meta:
        db_table = 'Relation_MR_Speciality'
    def __unicode__(self):
        return unicode(self.identity)

#Diagnostic
class Diagnostic(models.Model):
    code = models.CharField(max_length=50, primary_key=True)
    diagnosis = models.ForeignKey(Diagnosis, db_column='diagnosis_code')
    medical_report = models.ForeignKey(Medical_report, db_column='mr_identity')
    class Meta:
        db_table = 'Diagnostic'
    def __unicode__(self):
        return unicode(self.code)

#Subdiagnostic
class Subdiagnostic(models.Model):
    code = models.CharField(max_length=50, primary_key=True)
    subdiagnosis = models.ForeignKey(Subdiagnosis, db_column='subdiagnosis_code')
    diagnostic = models.ForeignKey(Diagnostic, db_column='diagnostic_code')
    class Meta:
        db_table = 'Subdiagnostic'
    def __unicode__(self):
        return unicode(self.code)

#Prescribed Drug
class Prescribed_drug(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    quantity = models.IntegerField()
    frequency = models.IntegerField(null=True)
    duration_of_treatment = models.IntegerField(null=True)
    medical_report = models.ForeignKey(Medical_report, db_column='mr_identity', null=True)
    drug_presentation = models.ForeignKey(Drug_presentation, db_column='dp_identity', null=True)
    posology = models.ForeignKey(Posology, db_column='posology_identity', null=True)
    class Meta:
        db_table = 'Prescribed_drug'
    def __unicode__(self):
        return unicode(self.identity)

#Requested Medication
class Requested_medication(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    quantity = models.IntegerField()
    reference_price = models.FloatField(null=True)
    request = models.ForeignKey(Request, db_column='request_identity', null=True)
    drug_presentation = models.ForeignKey(Drug_presentation, db_column='dp_identity', null=True)
    class Meta:
        db_table = 'Requested_medication'
    def __unicode__(self):
        return unicode(self.identity)

#Related Medication
class Related_medication(models.Model):
    code = models.BigIntegerField(primary_key=True)
    requested_medication = models.ForeignKey(Requested_medication, db_column='rm_identity', null=True)
    prescribed_drug = models.ForeignKey(Prescribed_drug, db_column='pd_identity', null=True)
    class Meta:
        db_table = 'Related_medication'
    def __unicode__(self):
        return unicode(self.code)

#Related Diagnosis
class Related_diagnosis(models.Model):
    code = models.BigIntegerField(primary_key=True)
    diagnostic = models.ForeignKey(Diagnostic, db_column='diagnostic_code', null=True)
    related_medication = models.ForeignKey(Related_medication, db_column='rm_code')
    class Meta:
        db_table = 'Related_diagnosis'
    def __unicode__(self):
        return unicode(self.code)

#Invoice
class Invoice(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    date = models.DateField(null=True)
    total_amount = models.FloatField(null=True)
    number = models.BigIntegerField(null=True)
    request = models.ForeignKey(Request, db_column='request_identity')
    duration = models.IntegerField(null=True)
    survey = models.CharField(max_length=1500, null=True)
    tracing = models.CharField(max_length=1500, null=True)
    class Meta:
        db_table = 'Invoice'
    def __unicode__(self):
        return unicode(self.identity)

#Dispensed Drug
class Dispensed_drug(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    unit_price = models.FloatField()
    requested_medication = models.ForeignKey(Requested_medication, db_column='rm_identity')
    invoice = models.ForeignKey(Invoice, db_column='invoice_identity')
    class Meta:
        db_table = 'Dispensed_drug'
    def __unicode__(self):
        return unicode(self.identity)

#Irregularity Description
class Irregularity_description(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    description = models.CharField(max_length=600)
    class Meta:
        db_table = 'Irregularity_description'
    def __unicode__(self):
        return unicode(self.identity)

#Business Rule
class Business_rule(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=300)
    description = models.CharField(max_length=1500)
    condition = models.CharField(max_length=1500)
    irregularity_description = models.ForeignKey(Irregularity_description, db_column='id_identity')
    class Meta:
        db_table = 'Business_rule'
    def __unicode__(self):
        return unicode(self.name)

#Irregularity Diagnosis
#class Irregularity_diagnosis(models.Model):
#	identity = models.BigIntegerField(primary_key=True)
#	ignored_irregularity = models.BooleanField()
#	irregularity_description = models.ForeignKey(Irregularity_description, db_column='id_identity')
#	related_diagnosis = models.ForeignKey(Related_diagnosis, db_column='rd_code')
#	request = models.ForeignKey(Request, db_column='request_identity')
#	class Meta:
#		db_table = 'Irregularity_diagnosis'

#Irregularity Prescribed Drug
class Irregularity_prescribed_drug(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    max_approved_quantity = models.IntegerField()
    ignored_irregularity = models.BooleanField()	
    irregularity_description = models.ForeignKey(Irregularity_description, db_column='id_identity')
    related_medication = models.ForeignKey(Related_medication, db_column='rm_code')
    related_diagnosis = models.ForeignKey(Related_diagnosis, db_column='rd_code')
    request = models.ForeignKey(Request, db_column='request_identity')
    active = models.BooleanField()
    enabled = models.BooleanField()
    class Meta:
        db_table = 'Irregularity_prescribed_drug'
    def __unicode__(self):
        return unicode(self.identity)

#Irregularity Dispensed Drug
class Irregularity_dispensed_drug(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    max_approved_quantity = models.IntegerField()
    max_approved_unit_price = models.FloatField()
    ignored_irregularity = models.BooleanField()
    irregularity_description = models.ForeignKey(Irregularity_description, db_column='id_identity')
    requested_medication = models.ForeignKey(Requested_medication, db_column='rm_identity')
    request = models.ForeignKey(Request, db_column='request_identity')
    active = models.BooleanField()
    enabled = models.BooleanField()
    class Meta:
        db_table = 'Irregularity_dispensed_drug'
    def __unicode__(self):
        return unicode(self.identity)

#Irregularity Prescription
#class Irregularity_prescription(models.Model):
#	identity = models.BigIntegerField(primary_key=True)
#	max_approved_amount = models.FloatField()
#	ignored_irregularity = models.BooleanField()
#	irregularity_description = models.ForeignKey(Irregularity_description, db_column='id_identity')
#	request = models.ForeignKey(Request, db_column='request_identity')
#	class Meta:
#		db_table = 'Irregularity_prescription'

#----------------------------------------------------Views models-------------------------------------------
class Savings(models.Model):
    request_identity = models.BigIntegerField(primary_key=True, db_column='request_identity')
    request_status = models.IntegerField(db_column='request_status')
    date = models.DateField(db_column='request_date')
    type_request_code = models.IntegerField(db_column='type_request_code')
    type_request_description = models.CharField(max_length=50)
    requested_medication_identity = models.BigIntegerField(db_column='requested_medication_identity')
    requested_medication_quantity = models.IntegerField(db_column='requested_medication_quantity')
    requested_medication_reference_price = models.FloatField(db_column='requested_medication_reference_price')
    
    i_presc_drug_identity = models.BigIntegerField(null=True)
    i_presc_drug_quantity = models.IntegerField(null=True)
    i_presc_drug_ignored = models.BooleanField()	
    i_presc_drug_active = models.BooleanField()
    i_presc_drug_enabled = models.BooleanField()
    i_presc_drug_description = models.CharField(max_length=600, null=True)
    
    
    i_disp_drug_identity = models.BigIntegerField(null=True)
    i_disp_drug_unit_price = models.FloatField(null=True)
    i_disp_drug_ignored = models.NullBooleanField()
    i_disp_drug_active = models.NullBooleanField()
    i_disp_drug_enabled = models.NullBooleanField()
    i_disp_drug_description = models.CharField(max_length=600, null=True)
    i_disp_drug_quantity = models.IntegerField(null=True)

    
    class Meta:
        db_table = 'Savings'
        managed = False
        
        
class Substitute(models.Model):      
    presc_presentation_id = models.BigIntegerField(primary_key=True)
    presc_presentation_name = models.CharField(max_length=300)
    presc_presentation_dose = models.FloatField()
    presc_presentation_drugbrand = models.CharField(max_length=300)
    req_presentation_id = models.BigIntegerField()
    req_presentation_name = models.CharField(max_length=300)
    req_presentation_dose = models.FloatField()
    req_presentation_drugbrand = models.CharField(max_length=300)    
    
    class Meta:
        db_table = 'Substitute'
        managed = False


class Presentation_req_view(models.Model):
    presentation_identity = models.BigIntegerField(primary_key=True)
    presentation_name = models.CharField(max_length=300)
    presentation_price = models.FloatField()
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField(null=True)
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Presentation_req_view'
        managed = False


class Presentation_presc_view(models.Model):
    presentation_identity = models.BigIntegerField(primary_key=True)
    presentation_name = models.CharField(max_length=300)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Presentation_presc_view'
        managed = False


class Medication_req_view(models.Model):
    medication_identity = models.BigIntegerField(primary_key=True)
    medication_name = models.CharField(max_length=300)
    reference_price = models.FloatField()
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Medication_req_view'
        managed = False


class Medication_presc_view(models.Model):
    medication_identity = models.BigIntegerField(primary_key=True)
    medication_name = models.CharField(max_length=300)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Medication_presc_view'
        managed = False


class Drug_brand_req_view(models.Model):
    drug_brand_identity = models.IntegerField(primary_key=True)
    drug_brand_name = models.CharField(max_length=300)
    reference_price = models.FloatField()
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Drug_brand_req_view'
        managed = False


class Drug_brand_presc_view(models.Model):
    drug_brand_identity = models.IntegerField(primary_key=True)
    drug_brand_name = models.CharField(max_length=300)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Drug_brand_presc_view'
        managed = False


class Pharmaceutical_req_view(models.Model):
    phar_comp_identity = models.CharField(max_length=9,primary_key=True)
    phar_comp_name = models.CharField(max_length=300)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Pharmaceutical_req_view'
        managed = False


class Pharmaceutical_presc_view(models.Model):
    phar_comp_identity = models.CharField(max_length=9,primary_key=True)
    phar_comp_name = models.CharField(max_length=300)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Pharmaceutical_presc_view'
        managed = False


class Act_ingredient_req_view(models.Model):
    act_ingredient_identity = models.IntegerField(primary_key=True)
    act_ingredient_name = models.CharField(max_length=300)
    reference_price = models.FloatField()
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Act_ingredient_req_view'
        managed = False


class Act_ingredient_presc_view(models.Model):
    act_ingredient_identity = models.IntegerField(primary_key=True)
    act_ingredient_name = models.CharField(max_length=300)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Act_ingredient_presc_view'
        managed = False


class Therapeutic_class_req_view(models.Model):
    therapeutic_code = models.CharField(max_length=1,primary_key=True)
    therapeutic_name = models.CharField(max_length=150)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_class_req_view'
        managed = False


class Therapeutic_class_presc_view(models.Model):
    therapeutic_code = models.CharField(max_length=1,primary_key=True)
    therapeutic_name = models.CharField(max_length=150)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_class_presc_view'
        managed = False


class Therapeutic_sub_req_view(models.Model):
    therapeuticsub_code = models.CharField(max_length=3,primary_key=True)
    therapeuticsub_name = models.CharField(max_length=150)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_sub_req_view'
        managed = False


class Therapeutic_sub_presc_view(models.Model):
    therapeuticsub_code = models.CharField(max_length=3,primary_key=True)
    therapeuticsub_name = models.CharField(max_length=150)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_sub_presc_view'
        managed = False


class Therapeutic_sub2_req_view(models.Model):
    therapeuticsub2_code = models.CharField(max_length=4,primary_key=True)
    therapeuticsub2_name = models.CharField(max_length=150)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_sub2_req_view'
        managed = False


class Therapeutic_sub2_presc_view(models.Model):
    therapeuticsub2_code = models.CharField(max_length=4,primary_key=True)
    therapeuticsub2_name = models.CharField(max_length=150)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_sub2_presc_view'
        managed = False


class Therapeutic_sub3_req_view(models.Model):
    therapeuticsub3_code = models.CharField(max_length=5,primary_key=True)
    therapeuticsub3_name = models.CharField(max_length=150)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_sub3_req_view'
        managed = False


class Therapeutic_sub3_presc_view(models.Model):
    therapeuticsub3_code = models.CharField(max_length=5,primary_key=True)
    therapeuticsub3_name = models.CharField(max_length=150)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Therapeutic_sub3_presc_view'
        managed = False


class Savings_total(models.Model):
    accident = models.FloatField()
    saving = models.FloatField()
    date = models.DateField(primary_key=True)
    
    class Meta:
        db_table = 'Savings_total'
        managed = False

#tipo diagnostico
#patologia
class Diagnosis_req_view(models.Model):
    diagnosis_code = models.IntegerField(primary_key=True)
    diagnosis_name = models.CharField(max_length=600)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Diagnosis_req_view'
        managed = False


class Diagnosis_presc_view(models.Model):
    diagnosis_code = models.IntegerField(primary_key=True)
    diagnosis_name = models.CharField(max_length=600)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Diagnosis_presc_view'
        managed = False

#tipo diagnostico2
#subtipo de patologia
class Diagnosis_sub_req_view(models.Model):
    subtype_code = models.CharField(max_length=12,primary_key=True)
    subtype_description = models.CharField(max_length=600)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Diagnosis_sub_req_view'
        managed = False


class Diagnosis_sub_presc_view(models.Model):
    subtype_code = models.CharField(max_length=12,primary_key=True)
    subtype_description = models.CharField(max_length=600)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Diagnosis_sub_presc_view'
        managed = False

#tipo diagnostico 1
#tipo de patologia
class Diagnosis_type_req_view(models.Model):
    type_code = models.CharField(max_length=9,primary_key=True)
    type_description = models.CharField(max_length=600)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Diagnosis_type_req_view'
        managed = False


class Diagnosis_type_presc_view(models.Model):
    type_code = models.CharField(max_length=9,primary_key=True)
    type_description = models.CharField(max_length=600)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Diagnosis_type_presc_view'
        managed = False


class Demographics_req_view(models.Model):
    diagnosis_code = models.IntegerField(primary_key=True)
    diagnosis_name = models.CharField(max_length=600)
    req_presentation_id = models.BigIntegerField(null=True)
    req_presentation_name = models.CharField(max_length=300,null=True)
    req_presentation_dose = models.FloatField(null=True)
    req_med_quantity = models.BigIntegerField(null=True)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Demographics_req_view'
        managed = False


class Demographics_presc_view(models.Model):
    diagnosis_code = models.IntegerField(primary_key=True)
    diagnosis_name = models.CharField(max_length=600)
    req_presentation_id = models.BigIntegerField(null=True)
    req_presentation_name = models.CharField(max_length=300,null=True)
    req_presentation_dose = models.FloatField(null=True)
    req_med_quantity = models.BigIntegerField(null=True)
    presc_drug_quantity = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Demographics_presc_view'
        managed = False


class Pharmacy_view(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=1500)
    callcenter = models.BooleanField()
    address= models.CharField(max_length=1500)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Pharmacy_view'
        managed = False


class Pharmacy_chain_view(models.Model):
    identity = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=50)
    trans = models.BigIntegerField()
    total = models.FloatField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Pharmacy_chain_view'
        managed = False


class Speciality_view(models.Model):
    speciality_identity = models.IntegerField(primary_key=True)
    speciality_name = models.CharField(max_length=100)
    trans = models.BigIntegerField()
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Speciality_view'
        managed = False


class Irregularity_view(models.Model):
    irregularity_identity = models.BigIntegerField(primary_key=True)
    irregularity_description = models.CharField(max_length=600)
    trans = models.BigIntegerField()
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Irregularity_view'
        managed = False


class Other_dispensations_drug_view(models.Model):
    presentation_identity = models.BigIntegerField(primary_key=True)
    presentation_name = models.CharField(max_length=300)
    other = models.CharField(max_length=300,null=True)
    trans = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Other_dispensations_drug_view'
        managed = False


class Other_dispensations_med_view(models.Model):
    medication_identity = models.BigIntegerField(primary_key=True)
    medication_name = models.CharField(max_length=300)
    other = models.CharField(max_length=300,null=True)
    trans = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Other_dispensations_med_view'
        managed = False


class Other_prescriptions_drug_view(models.Model):
    presentation_identity = models.BigIntegerField(primary_key=True)
    presentation_name = models.CharField(max_length=300)
    other = models.CharField(max_length=300,null=True)
    trans = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Other_prescriptions_drug_view'
        managed = False


class Other_prescriptions_med_view(models.Model):
    medication_identity = models.BigIntegerField(primary_key=True)
    medication_name = models.CharField(max_length=300)
    other = models.CharField(max_length=300,null=True)
    trans = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Other_prescriptions_med_view'
        managed = False


class Other_diagnosis_view(models.Model):
    diagnosis_code = models.IntegerField(primary_key=True)
    diagnosis_name = models.CharField(max_length=600)
    other = models.CharField(max_length=600, null=True)
    trans = models.BigIntegerField()
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Other_diagnosis_view'
        managed = False


class Posology_view(models.Model):
    presentation_identity = models.BigIntegerField(primary_key=True)
    presentation_name = models.CharField(max_length=300)
    quantity = models.FloatField(null=True)
    frequency = models.FloatField(null=True)
    duration = models.BigIntegerField(null=True)
    total = models.BigIntegerField(null=True)
    date = models.DateField(null=True)
    age = models.IntegerField(null=True)
    type_of_age = models.CharField(max_length=1, null=True)
    sex = models.CharField(max_length=10, null=True)

    class Meta:
        db_table = 'Posology_view'
        managed = False


#     class Meta:
#         db_table = 'Medication_view'
#         managed = False

    # Case2.identity as req_case_identity,
    # Case2.due_date as req_case_date,
    # Affiliation2.identity as req_affiliation_identity,
    # Id_patient2.identity as req_patient_id,
    # Id_patient2.type_id_name as req_patient_type_id,
    # Patient_data2.identity as req_patient_identity,
    # Patient_data2.first_name as req_patient_first_name,
    # Patient_data2.last_name as req_patient_last_name,
    # Patient_data2.sex as req_patient_sex,
    # Patient_data2.date_of_birth as req_patient_birth,
    # Plan2.identity as req_plan_identity,
    # Plan2.description as req_plan_description,
    # Policy2.identity as req_policy_identity,
    # Collective2.identity as req_collective_identity,
    # Insurer2.identity as req_insurer_identity,
    # Insurer2.name as req_insurer_name,
    # Insurer2.insurer_type as req_insurer_type


