# -*- coding: utf-8 -*-
#import sqlalchemy
#import datetime
#import pytz
from datetime import timedelta, datetime, date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Table, MetaData, Column, ForeignKey, Integer, String, Float, UniqueConstraint, Date, DateTime, \
	UnicodeText, Unicode, BigInteger, Boolean
from sqlalchemy.orm import mapper, relationship, backref
from sqlalchemy.orm.collections import attribute_mapped_collection

Base = declarative_base()

#Therapeutic Class
class Therapeutic_class(Base):
	__tablename__ = 'Therapeutic_class'
	code=Column('code', Unicode(1), primary_key=True)
	name=Column('name', Unicode(150))

	class Meta:
		db_table = 'Therapeutic_class'

#Therapeutic Subclass
class Therapeutic_subclass(Base):
	__tablename__ = 'Therapeutic_subclass'
	code=Column('code', Unicode(3), primary_key=True)
	name=Column('name', Unicode(150))
	therapeutic_class_code=Column('tc_code', Unicode(1), ForeignKey("Therapeutic_class.code"), nullable=False)
	
	therapeutic_class= relationship("Therapeutic_class", backref=backref('Therapeutic_subclass'))

	class Meta:
		db_table = 'Therapeutic_subclass'

#Auxiliary for relationship n-m Subtype of Diagnosis - Therapeutic Subclass 2
class Relation_SD_TS2(Base):
	__tablename__ = 'Relation_SD_TS2'
	identity=Column('identity', BigInteger, primary_key=True)
	priority=Column('priority', Integer)
	subtype_of_diagnosis_code=Column('sd_code', Unicode(12), ForeignKey("Subype_of_diagnosis.code"), nullable=False)
	therapeutic_subclass_2_code=Column('ts2_code', Unicode(4), ForeignKey("Therapeutic_subclass_2.code"), nullable=False)

	class Meta:
		db_table = 'Relation_SD_TS2'

#Therapeutic Subclass 2
class Therapeutic_subclass_2(Base):
	__tablename__ = 'Therapeutic_subclass_2'
	code=Column('code', Unicode(4), primary_key=True)
	name=Column('name', Unicode(150))
	therapeutic_subclass_code=Column('ts_code', Unicode(3), ForeignKey("Therapeutic_subclass.code"), nullable=False)
	
	therapeutic_subclass= relationship("Therapeutic_subclass", backref=backref('Therapeutic_subclass_2'))
	subtype_of_diagnosis= relationship("Subtype_of_diagnosis",secondary=Relation_SD_TS2, backref='Therapeutic_subclass_2')

	class Meta:
		db_table = 'Therapeutic_subclass_2'

#Auxiliary for relationship n-m Therapeutic Subclass 3 - Active Ingredient discriminated by Therapeutic Class
class Relation_TS3_AITC(Base):
	__tablename__ = 'Relation_TS3_AITC'
	identity=Column('identity', BigInteger, primary_key=True)
	priority=Column('priority', Integer)
	active_ingredient_therapeutic_class_identity=Column('aitc_identity', Integer, ForeignKey("Active_ingredient_Therapeutic_class.identity"), nullable=False)
	therapeutic_subclass_3_code=Column('ts3_code', Unicode(5), ForeignKey("Therapeutic_subclass_3.code"), nullable=False)

	class Meta:
		db_table = 'Relation_TS3_AITC'

#Therapeutic Subclass 3
class Therapeutic_subclass_3(Base):
	__tablename__ = 'Therapeutic_subclass_3'
	code=Column('code', Unicode(5), primary_key=True)
	name=Column('name', Unicode(150))
	therapeutic_subclass_2_code=Column('ts2_code', Unicode(4), ForeignKey("Therapeutic_subclass_2.code"), nullable=False)
	
	therapeutic_subclass_2= relationship("Therapeutic_subclass_2", backref=backref('Therapeutic_subclass_3'))
	active_ingredient_therapeutic_class= relationship("Active_ingredient_Therapeutic_class",secondary=Relation_TS3_AITC, backref='Therapeutic_subclass_3')

	class Meta:
		db_table = 'Therapeutic_subclass_3'

#Type of Diagnosis
class Type_of_diagnosis(Base):
	__tablename__ = 'Type_of_diagnosis'
	code=Column('code', Unicode(9), primary_key=True)
	description=Column('description', Unicode(600))
	
	class Meta:
		db_table = 'Type_of_diagnosis'

#Subtype of Diagnosis
class Subtype_of_diagnosis(Base):
	__tablename__ = 'Subtype_of_diagnosis'
	code=Column('code', Unicode(12), primary_key=True)
	description=Column('description', Unicode(600))
	type_of_diagnosis_code=Column('td_code', Unicode(9), ForeignKey("Type_of_diagnosis.code"), nullable=False)

	type_of_diagnosis= relationship("Type_of_diagnosis", backref=backref('Subtype_of_diagnosis'))
	
	class Meta:
		db_table = 'Subtype_of_diagnosis'

#Auxiliary for relationship n-m Subtype of Diagnosis - Diagnosis
class Relation_SD_Diagnosis(Base):
	__tablename__ = 'Relation_SD_Diagnosis'
	identity=Column('identity', BigInteger, primary_key=True)
	subtype_of_diagnosis_code=Column('sd_code', Unicode(12), ForeignKey("Subype_of_diagnosis.code"), nullable=False)
	diagnosis_code=Column('diagnosis_code', Integer, ForeignKey("Diagnosis.code"), nullable=False)

	class Meta:
		db_table = 'Relation_SD_Diagnosis'

#Diagnosis
class Diagnosis(Base):
	__tablename__ = 'Diagnosis'
	code=Column('code', Integer, primary_key=True)
	name=Column('name', Unicode(600))
	description=Column('description', Unicode(1500))
	keywords=Column('keywords', Unicode(1500))
	cie10=Column('cie10', Unicode(9))

	subtype_of_diagnosis= relationship("Subtype_of_diagnosis",secondary=Relation_SD_Diagnosis, backref='Diagnosis')
	
	class Meta:
		db_table = 'Diagnosis'

#Subdiagnosis
class Subdiagnosis(Base):
	__tablename__ = 'Subdiagnosis'
	code=Column('code', Integer, primary_key=True)
	name=Column('name', Unicode(600))
	description=Column('description', Unicode(1500))
	cie9=Column('cie9', Unicode(9))
	cie10=Column('cie10', Unicode(9))
	status=Column('status', Integer)
	diagnosis_code=Column('diagnosis_code', Integer, ForeignKey("Diagnosis.code"))

	diagnosis= relationship("Diagnosis", backref=backref('Subdiagnosis'))

	class Meta:
		db_table = 'Subdiagnosis'

#Active Ingredient
class Active_ingredient(Base):
	__tablename__ = 'Active_ingredient'
	identity=Column('identity', Integer, primary_key=True)
	name=Column('name', Unicode(300))
	
	class Meta:
		db_table = 'Active_ingredient'

#Active Ingredient discriminated by Therapeutic Class
class Active_ingredient_Therapeutic_class(Base):
	__tablename__ = 'Active_ingredient_Therapeutic_class'
	identity=Column('identity', Integer, primary_key=True)
	name=Column('name', Unicode(300))
	max_daily_dosage=Column('max_daily_dosage', Float)
	active_ingredient_identity=Column('ai_identity', Integer, ForeignKey("Active_ingredient.identity"), nullable=False)
	
	active_ingredient= relationship("Active_ingredient", backref=backref('Active_ingredient_Therapeutic_class'))

	class Meta:
		db_table = 'Active_ingredient_Therapeutic_class'

#Dosage
class Dosage(Base):
	__tablename__ = 'Dosage'
	identity=Column('identity', BigInteger, primary_key=True)
	name=Column('name', Unicode(300))
	dose=Column('dose', Float)
	association_of_sex=Column('association_of_sex', Unicode(10))
	vehicle=Column('vehicle', Float)
	active_ingredient_therapeutic_class_identity=Column('aitc_identity', Integer, ForeignKey("Active_ingredient_Therapeutic_class.identity"), nullable=False)

	active_ingredient_therapeutic_class= relationship("Active_ingredient_Therapeutic_class", backref=backref('Dosage'))
	
	class Meta:
		db_table = 'Dosage'

#Dosage form Group
class Dosage_form_group(Base):
	__tablename__ = 'Dosage_form_group'
	identity=Column('identity', Integer, primary_key=True)
	name=Column('name', Unicode(240))
	
	class Meta:
		db_table = 'Dosage_form_group'

#Dosage form
class Dosage_form(Base):
	__tablename__ = 'Dosage_form'
	identity=Column('identity', Integer, primary_key=True)
	name=Column('name', Unicode(300))
	dosage_form_group_name=Column('dfg_identity', Integer, ForeignKey("Dosage_form_group.identity"), nullable=False)

	dosage_form_group= relationship("Dosage_form_group", backref=backref('Dosage_form'))

	class Meta:
		db_table = 'Dosage_form'

#Pharmaceutical Company
class Pharmaceutical_company(Base):
	__tablename__ = 'Pharmaceutical_company'
	identity=Column('identity', Unicode(9), primary_key=True)
	name=Column('name', Unicode(300))
	address=Column('address', Unicode(750))
	phone_number=Column('phone_number', Unicode(300))
	image=Column('image', Unicode(1500))

	class Meta:
		db_table = 'Pharmaceutical_company'

#Drug Brand
class Drug_brand(Base):
	__tablename__ = 'Drug_brand'
	identity=Column('identity', Integer, primary_key=True)
	name=Column('name', Unicode(300))
	
	class Meta:
		db_table = 'Dosage_form_group'

#Medication
class Medication(Base):
	__tablename__ = 'Medication'
	identity=Column('identity', BigInteger, primary_key=True)
	name=Column('name', Unicode(300))
	keywords=Column('keywords', Unicode(1500))
	drug_indications=Column('drug_indications', Unicode(1500))
	contraindications=Column('contraindications', Unicode(1500))
	dosage=Column('dosage', Unicode(1500))
	adverse_reactions=Column('adverse_reactions', Unicode(1500))
	drug_brand_identity=Column('db_identity', Integer, ForeignKey("Drug_brand.identity"), nullable=False)

	drug_brand= relationship("Drug_brand", backref=backref('Medication'))

	class Meta:
		db_table = 'Medication'

#Drug Presentation
class Drug_presentation(Base):
	__tablename__ = 'Drug_presentation'
	identity=Column('identity', BigInteger, primary_key=True)
	name=Column('name', Unicode(300))
	units=Column('units', Float)
	dose=Column('dose', Float)
	max_daily_dosage=Column('max_daily_dosage', Float)
	max_daily_frequency=Column('max_daily_frequency', Float)
	reference_price=Column('reference_price', Float)
	dispensing_form=Column('dispensing_form', Unicode(1500))
	association_of_sex=Column('association_of_sex', Unicode(10))
	image=Column('image', Unicode(1500))
	generic_or_drug_band=Column('generic_or_drug_band', Unicode(10))
	pharmaceutical_company_identity=Column('pc_identity', BigInteger, ForeignKey("Pharmaceutical_company.identity"), nullable=False)
	medication_identity=Column('medication_identity', BigInteger, ForeignKey("Medication.identity"), nullable=False)
	dosage_identity=Column('dosage_identity', Float, ForeignKey("Dosage.identity"), nullable=False)
	dosage_form_identity=Column('dosage_form_identity', Integer, ForeignKey("Dosage_form.name"), nullable=False)

	pharmaceutical_company= relationship("Pharmaceutical_company", backref=backref('Drug_presentation'))
	medication= relationship("Medication", backref=backref('Drug_presentation'))
	dosage= relationship("Dosage", backref=backref('Drug_presentation'))
	dosage_form= relationship("Dosage_form", backref=backref('Drug_presentation'))

	class Meta:
		db_table = 'Drug_presentation'

#Type of ID Patient
class Type_of_id_patient(Base):
	__tablename__ = 'Type_of_id_patient'
	name=Column('name', Unicode(50), primary_key=True)
	
	class Meta:
		db_table = 'Type_of_id_patient'

#Patient Data
class Patient_data(Base):
	__tablename__ = 'Patient_data'
	identity=Column('identity', BigInteger, primary_key=True)
	first_name=Column('first_name', Unicode(100))
	last_name=Column('last_name', Unicode(100))
	sex=Column('sex', Unicode(10))
	date_of_birth=Column('date_of_birth', Date)
	cell_phone=Column('cell_phone', Unicode(35))
    home_phone=Column('home_phone', Unicode(35))
    email=Column('email', Unicode(1500))
    address=Column('address', Unicode(1500))
    reminder=Column('reminder', Integer)

	class Meta:
		db_table = 'Patient_data'

#ID Patient
class Id_patient(Base):
	__tablename__ = 'Id_patient'
	identity=Column('identity', BigInteger, primary_key=True)
	type_of_id_name=Column('type_id_name', Unicode(50), ForeignKey("Type_of_id_patient.name"), nullable=False)
	patient_data_identity=Column('patient_data_identity', BigInteger, ForeignKey("Patient_data.identity"), nullable=False)
    pharmacy_identity =Column('pharmacy_identity', BigInteger, ForeignKey("Pharmacy.identity"), nullable=True)

	type_of_id= relationship("Type_of_id_patient", backref=backref('Id_patient'))
	patient_data= relationship("Patient_data", backref=backref('Id_patient'))
	pharmacy= relationship("Pharmacy". backref=backref('Id_patient'))

	class Meta:
		db_table = 'Id_patient'

#Insurer
class Insurer(Base):
	__tablename__ = 'Insurer'
	identity=Column('identity', BigInteger, primary_key=True)
	name=Column('name', Unicode(300))
	insurer_type=Column('type', Unicode(100))
	logo=Column('logo', Unicode(1500))

	class Meta:
		db_table = 'Insurer'

#Collective
class Collective(Base):
	__tablename__ = 'Collective'
	identity=Column('identity', Unicode(50), primary_key=True)
	insurer_identity=Column('insurer_identity', BigInteger, ForeignKey("Insurer.identity"), nullable=False)

	insurer= relationship("Insurer", backref=backref('Collective'))

	class Meta:
		db_table = 'Collective'

#Policy
class Policy(Base):
	__tablename__ = 'Policy'
	identity=Column('identity', Unicode(50), primary_key=True)
	collective_identity=Column('collective_identity', Unicode(50), ForeignKey("Collective.identity"), nullable=False)

	collective= relationship("Collective", backref=backref('Policy'))

	class Meta:
		db_table = 'Policy'

#Plan
class Plan(Base):
	__tablename__ = 'Plan'
	identity=Column('identity', Unicode(50), primary_key=True)
	description=Column('description', Unicode(300))
	policy_identity=Column('policy_identity', Unicode(50), ForeignKey("Policy.identity"), nullable=False)

	collective= relationship("Policy", backref=backref('Plan'))

	class Meta:
		db_table = 'Plan'

#Affiliation
class Affiliation(Base):
	__tablename__ = 'Affiliation'
	identity=Column('identity', Unicode(50), primary_key=True)
	plan_identity=Column('plan_identity', Unicode(50), ForeignKey("Plan.identity"), nullable=False)
	id_patient_identity=Column('id_patient_identity', BigInteger, ForeignKey("Id_patient.identity"), nullable=False)

	plan= relationship("Plan", backref=backref('Affiliation'))
	id_patient= relationship("Id_patient", backref=backref('Affiliation'))

	class Meta:
		db_table = 'Affiliation'

#Case
class Case(Base):
	__tablename__ = 'Case'
	identity=Column('identity', BigInteger, primary_key=True)
	due_date=Column('due_date', Date, null=True)
	affiliation_identity=Column('affiliation_identity', Unicode(50), ForeignKey("Affiliation.identity"), nullable=False)

	affiliation= relationship("Affiliation", backref=backref('Case'))

	class Meta:
		db_table = 'Case'

#Status
class Status(Base):
	__tablename__ = 'Status'
	code=Column('code', Integer, primary_key=True)
	status=Column('status', Unicode(50))
	
	class Meta:
		db_table = 'Status'

#Type of Request
class Type_of_request(Base):
	__tablename__ = 'Type_of_request'
	code=Column('code', Integer, primary_key=True)
	description=Column('description', Unicode(50))

	class Meta:
		db_table = 'Type_of_request'

#Auxiliary for relationship n-m Medical Report - Request
class Relation_MR_Request(Base):
	__tablename__ = 'Relation_MR_Request'
	identity=Column('identity', BigInteger, primary_key=True)
	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)
	medical_report_identity=Column('mr_identity', BigInteger, ForeignKey("Medical_report.identity"), nullable=False)

	class Meta:
		db_table = 'Relation_MR_Request'

#Request
class Request(Base):
	__tablename__ = 'Request'
	identity=Column('identity', BigInteger, primary_key=True)
	number=Column('number', BigInteger)
	status=Column('status', Unicode(50))
	date=Column('date', Date)
	age=Column('age', Integer)
	type_of_age=Column('type_of_age', Unicode(1))
	case_identity=Column('case_identity', BigInteger, ForeignKey("Case.identity"), nullable=False)
	type_of_request_code=Column('type_request_code', Integer, ForeignKey("Type_of_request.code"), nullable=False)

	case= relationship("Case", backref=backref('Request'))
	type_of_request= relationship("Type_of_request", backref=backref('Request'))
	medical_report= relationship("Medical_report",secondary=Relation_Medical_report_Request, backref='Request')

	class Meta:
		db_table = 'Request'

#Medical Report
class Medical_report(Base):
	__tablename__ = 'Medical_report'
	identity=Column('identity', BigInteger, primary_key=True)
	number+Column('number', BigInteger)
	date_of_issue=Column('date_of_issue', Date)
	due_date=Column('due_date', Date)
	case_identity=Column('case_identity', BigInteger, ForeignKey("Case.identity"), nullable=False)

	case= relationship("Case", backref=backref('Medical_report'))

	class Meta:
		db_table = 'Medical_report'

#Diagnostic
class Diagnostic(Base):
	__tablename__ = 'Diagnostic'
	code=Column('code', Unicode(50), primary_key=True)
	diagnosis_code=Column('diagnosis_code', Integer, ForeignKey("Diagnosis.code"), nullable=False)
	medical_report_identity=Column('mr_identity', BigInteger, ForeignKey("Medical_report.identity"), nullable=False)

	diagnosis= relationship("Diagnosis", backref=backref('Diagnostic'))
	medical_report= relationship("Medical_report", backref=backref('Diagnostic'))

	class Meta:
		db_table = 'Diagnostic'

#Prescribed Drug
class Prescribed_drug(Base):
	__tablename__ = 'Prescribed_drug'
	identity=Column('identity', BigInteger, primary_key=True)
	quantity=Column('quantity', Integer)
	frequency=Column('frequency', Integer)
	duration_of_treatment=Column('duration_of_treatment', Integer)
	medical_report_identity=Column('mr_identity', BigInteger, ForeignKey("Medical_report.identity"), nullable=False)
	drug_presentation_identity=Column('dp_identity', BigInteger, ForeignKey("Drug_presentation.identity"), nullable=False)

	medical_report= relationship("Medical_report", backref=backref('Prescribed_drug'))
	drug_presentation= relationship("Drug_presentation", backref=backref('Prescribed_drug'))

	class Meta:
		db_table = 'Prescribed_drug'

#Requested Medication
class Requested_medication(Base):
	__tablename__ = 'Requested_medication'
	identity=Column('identity', BigInteger, primary_key=True)
	quantity=Column('quantity', Integer)
	reference_price=Column('reference_price', Float)
	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)
	drug_presentation_identity=Column('dp_identity', BigInteger, ForeignKey("Drug_presentation.identity"), nullable=False)
	
	request= relationship("Request", backref=backref('Requested_medication'))
	drug_presentation= relationship("Drug_presentation", backref=backref('Requested_medication'))

	class Meta:
		db_table = 'Requested_medication'

#Related Medication
class Related_medication(Base):
	__tablename__ = 'Related_medication'
	code=Column('code', BigInteger, primary_key=True)
	requested_medication_identity=Column('rm_identity', BigInteger, ForeignKey("Requested_medication.identity"), nullable=False)
	prescribed_drug_identity=Column('pd_identity', BigInteger, ForeignKey("Prescribed_drug.identity"), nullable=False)

	requested_medication= relationship("Requested_medication", backref=backref('Related_medication'))
	prescribed_drug= relationship("Prescribed_drug", backref=backref('Related_medication'))

	class Meta:
		db_table = 'Related_medication'

#Related Diagnosis
class Related_diagnosis(Base):
	__tablename__ = 'Related_diagnosis'
	code=Column('code', BigInteger, primary_key=True)
	diagnostic_code=Column('diagnostic_code', BigInteger, ForeignKey("Diagnostic.code"), nullable=False)
	related_medication_code=Column('rm_code', BigInteger, ForeignKey("Related_medication.code"), nullable=False)

	diagnostic= relationship("Diagnostic", backref=backref('Related_diagnosis'))
	related_medication= relationship("Related_medication", backref=backref('Related_diagnosis'))

	class Meta:
		db_table = 'Related_diagnosis'

#Invoice
class Invoice(Base):
	__tablename__ = 'Invoice'
	identity=Column('identity', BigInteger, primary_key=True)
	date=Column('date', Date)
	total_amount=Column('total_amount', Float)
	number=Column('number', BigInteger)
	duration=Column('duration', Integer)
    survey=Column('survey', Unicode(1500))
    tracing=Column('tracing', Unicode(1500))
	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)

	request= relationship("Request", backref=backref('Invoice'))

	class Meta:
		db_table = 'Invoice'

#Dispensed Drug
class Dispensed_drug(Base):
	__tablename__ = 'Dispensed_drug'
	identity=Column('identity', BigInteger, primary_key=True)
	unit_price=Column('unit_price', Float)
	requested_medication_identity=Column('rm_identity', BigInteger, ForeignKey("Requested_medication.identity"), nullable=False)
	invoice_identity=Column('invoice_identity', BigInteger, ForeignKey("Invoice.identity"), nullable=False)

	requested_medication= relationship("Requested_medication", backref=backref('Dispensed_drug'))
	invoice= relationship("Invoice", backref=backref('Dispensed_drug'))

	class Meta:
		db_table = 'Dispensed_drug'

#Irregularity Description
class Irregularity_description(Base):
	__tablename__ = 'Irregularity_description'
	identity=Column('identity', BigInteger, primary_key=True)
	description=Column('description', Unicode(600))
	
	class Meta:
		db_table = 'Irregularity_description'

#Business Rule
class Business_rule(Base):
	__tablename__ = 'Business_rule'
	identity=Column('identity', BigInteger, primary_key=True)
	name=Column('name', Unicode(300))
	description=Column('description', Unicode(1500))
	condition=Column('condition', Unicode(1500))
	irregularity_description_identity=Column('id_identity', BigInteger, ForeignKey("Irregularity_description.identity"), nullable=False)

	irregularity_description= relationship("Irregularity_description", backref=backref('Business_rule'))

	class Meta:
		db_table = 'Business_rule'

#Irregularity Diagnosis
#class Irregularity_diagnosis(Base):
#	__tablename__ = 'Irregularity_diagnosis'
#	identity=Column('identity', BigInteger, primary_key=True)
#	ignored_irregularity=Column('ignored_irregularity', Boolean)
#	irregularity_description_identity=Column('id_identity', BigInteger, ForeignKey("Irregularity_description.identity"), nullable=False)
#	related_diagnosis_code=Column('rd_code', BigInteger, ForeignKey("Related_diagnosis.code"), nullable=False)
#	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)
#
#	irregularity_description= relationship("Irregularity_description", backref=backref('Irregularity_diagnosis'))
#	related_diagnosis= relationship("Related_diagnosis", backref=backref('Irregularity_diagnosis'))
#	request= relationship("Request", backref=backref('Irregularity_prescription'))
#
#	class Meta:
#		db_table = 'Irregularity_diagnosis'

#Irregularity Prescribed Drug
class Irregularity_prescribed_drug(Base):
	__tablename__ = 'Irregularity_prescribed_drug'
	identity=Column('identity', BigInteger, primary_key=True)
	max_approved_quantity=Column('max_approved_quantity', Integer)
	ignored_irregularity=Column('ignored_irregularity', Boolean)
	irregularity_description_identity=Column('id_identity', BigInteger, ForeignKey("Irregularity_description.identity"), nullable=False)
	related_medication_code=Column('rm_code', BigInteger, ForeignKey("Related_medication.code"), nullable=False)
	related_diagnosis_code=Column('rd_code', BigInteger, ForeignKey("Related_diagnosis.code"), nullable=False)
	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)
	active=Column('active', Boolean)
	enabled=Column('enabled', Boolean)

	irregularity_description= relationship("Irregularity_description", backref=backref('Irregularity_prescribed_drug'))
	related_medication= relationship("Related_medication", backref=backref('Irregularity_prescribed_drug'))
	related_diagnosis= relationship("Related_diagnosis", backref=backref('Irregularity_prescribed_drug'))
	request= relationship("Request", backref=backref('Irregularity_prescription'))

	class Meta:
		db_table = 'Irregularity_prescribed_drug'

#Irregularity Dispensed Drug
class Irregularity_dispensed_drug(Base):
	__tablename__ = 'Irregularity_dispensed_drug'
	identity=Column('identity', BigInteger, primary_key=True)
	max_approved_unit_price=Column('max_approved_unit_price', Float)
	ignored_irregularity=Column('ignored_irregularity', Boolean)
	irregularity_description_identity=Column('id_identity', BigInteger, ForeignKey("Irregularity_description.identity"), nullable=False)
	requested_medication_identity=Column('rm_identity', BigInteger, ForeignKey("Requested_medication.identity"), nullable=False)
	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)
	active=Column('active', Boolean)
	enabled=Column('enabled', Boolean)

	irregularity_description= relationship("Irregularity_description", backref=backref('Irregularity_dispensed_drug'))
	requested_medication= relationship("Requested_medication", backref=backref('Irregularity_dispensed_drug'))
	request= relationship("Request", backref=backref('Irregularity_prescription'))

	class Meta:
		db_table = 'Irregularity_dispensed_drug'

#Irregularity Prescription
#class Irregularity_prescription(Base):
#	__tablename__ = 'Irregularity_prescription'
#	identity=Column('identity', BigInteger, primary_key=True)
#	max_approved_amount=Column('max_approved_amount', Float)
#	ignored_irregularity=Column('ignored_irregularity', Boolean)
#	irregularity_description_identity=Column('id_identity', BigInteger, ForeignKey("Irregularity_description.identity"), nullable=False)
#	request_identity=Column('request_identity', BigInteger, ForeignKey("Request.identity"), nullable=False)
#
#	irregularity_description= relationship("Irregularity_description", backref=backref('Irregularity_prescription'))
#	request= relationship("Request", backref=backref('Irregularity_prescription'))
#
#	class Meta:
#		db_table = 'Irregularity_prescription'

#Pharmacy chain
class Pharmacy_chain(Base):
	__tablename__ = 'Pharmacy_chain'
    identity=Column('identity', Integer, primary_key=True)
    name=Column('name', Unicode(50))

    class Meta:
        db_table = 'Pharmacy_chain'

#Pharmacy
class Pharmacy(Base):
	__tablename__ = 'Pharmacy'
    identity=Column('identity', Biginteger, primary_key=True)
    name=Column('name', Unicode(1500))
    company_name=Column('company_name', Unicode(1500))
    rif=Column('rif', Unicode(45))
    address=Column('address', Unicode(1500))
    phone_number=Column('phone_number', Unicode(35))
    logo=Column('logo', Unicode(20))
    status=Column('status', Integer)
    callcenter=Column('callcenter', Boolean)
    web=Column('web', Unicode(50))
    chain_identity=Column('chain_identity', Integer, ForeignKey("Pharmacy_chain.identity"), nullable=False)

    pharmacy_chain= relationship("Pharmacy_chain", backref=backref('Pharmacy'))

    class Meta:
        db_table = 'Pharmacy'

#SMS
class SMS(Base):
	__tablename__ = 'SMS'
    identity=Column('identity', Biginteger, primary_key=True)
    date=Column('date', Date)
    type=Column('type', Integer)
    message=Column('message', Unicode(1500))
    id_patient_identity=Column('id_patient_identity', Biginteger, ForeignKey("Id_patient.identity"), nullable=False)

    id_patient= relationship("Id_patient", backref=backref('SMS'))

    class Meta:
        db_table = 'SMS'

#Country
class Country(Base):
	__tablename__ = 'Country'
    identity=Column('identity', Biginteger, primary_key=True)
    name=Column('name', Unicode(100))

    class Meta:
        db_table = 'Country'
    