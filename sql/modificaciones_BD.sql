-- SINCRONIZAR MODELS PARA CREAR TABLAS DE FARMA!!!!!

ALTER TABLE "Subtype_of_diagnosis" ALTER COLUMN description DROP NOT NULL;
ALTER TABLE "Diagnosis" ALTER COLUMN description DROP NOT NULL;
ALTER TABLE "Diagnosis" ALTER COLUMN keywords DROP NOT NULL;
ALTER TABLE "Diagnosis" ALTER COLUMN cie10 DROP NOT NULL;
ALTER TABLE "Subdiagnosis" ALTER COLUMN description DROP NOT NULL;
ALTER TABLE "Subdiagnosis" ALTER COLUMN cie9 DROP NOT NULL;
ALTER TABLE "Subdiagnosis" ALTER COLUMN cie10 DROP NOT NULL;
ALTER TABLE "Pharmaceutical_company" ALTER COLUMN address DROP NOT NULL;
ALTER TABLE "Pharmaceutical_company" ALTER COLUMN phone_number DROP NOT NULL;
ALTER TABLE "Pharmaceutical_company" ALTER COLUMN image DROP NOT NULL;
ALTER TABLE "Medication" ALTER COLUMN keywords DROP NOT NULL;
ALTER TABLE "Medication" ALTER COLUMN drug_indications DROP NOT NULL;
ALTER TABLE "Medication" ALTER COLUMN contraindications DROP NOT NULL;
ALTER TABLE "Medication" ALTER COLUMN dosage DROP NOT NULL;
ALTER TABLE "Medication" ALTER COLUMN adverse_reactions DROP NOT NULL;
ALTER TABLE "Drug_presentation" DROP COLUMN dispensing_form CASCADE;
ALTER TABLE "Drug_presentation" ALTER COLUMN max_daily_frequency DROP NOT NULL;
ALTER TABLE "Drug_presentation" ALTER COLUMN reference_price DROP NOT NULL;
ALTER TABLE "Drug_presentation" ALTER COLUMN image DROP NOT NULL;
ALTER TABLE "Drug_presentation" ALTER COLUMN dosage_identity DROP NOT NULL;
ALTER TABLE "Patient_data" ALTER COLUMN date_of_birth DROP NOT NULL;
ALTER TABLE "Patient_data" ADD COLUMN "cell_phone" varchar(35);
ALTER TABLE "Patient_data" ADD COLUMN "home_phone" varchar(35);
ALTER TABLE "Patient_data" ADD COLUMN "email" varchar(1500);
ALTER TABLE "Patient_data" ADD COLUMN "address" varchar(1500);
ALTER TABLE "Patient_data" ADD COLUMN "reminder" integer;
ALTER TABLE "Id_patient" ADD COLUMN "pharmacy_identity" bigint;
ALTER TABLE "Insurer" ALTER COLUMN logo DROP NOT NULL;
ALTER TABLE "Plan" ALTER COLUMN description DROP NOT NULL;
ALTER TABLE "Case" ALTER COLUMN due_date DROP NOT NULL;
ALTER TABLE "Case" ADD COLUMN "relationship" varchar(3);
ALTER TABLE "Case" ADD COLUMN "uptake" double precision;
ALTER TABLE "Case" ADD COLUMN "coverage" double precision;
ALTER TABLE "Request" ALTER COLUMN case_identity DROP NOT NULL;
ALTER TABLE "Request" ADD COLUMN "number" bigint;
ALTER TABLE "Medical_report" ADD COLUMN "number" bigint;
ALTER TABLE "Medical_report" ALTER COLUMN date_of_issue DROP NOT NULL;
ALTER TABLE "Medical_report" ALTER COLUMN due_date DROP NOT NULL;
ALTER TABLE "Medical_report" ALTER COLUMN case_identity DROP NOT NULL;
ALTER TABLE "Prescribed_drug" ALTER COLUMN frequency DROP NOT NULL;
ALTER TABLE "Prescribed_drug" ALTER COLUMN duration_of_treatment DROP NOT NULL;
ALTER TABLE "Prescribed_drug" ALTER COLUMN dp_identity DROP NOT NULL;
ALTER TABLE "Prescribed_drug" ALTER COLUMN mr_identity DROP NOT NULL;
ALTER TABLE "Requested_medication" ALTER COLUMN reference_price DROP NOT NULL;
ALTER TABLE "Requested_medication" ALTER COLUMN dp_identity DROP NOT NULL;
ALTER TABLE "Requested_medication" ALTER COLUMN request_identity DROP NOT NULL;
ALTER TABLE "Related_medication" ALTER COLUMN pd_identity DROP NOT NULL;
ALTER TABLE "Related_medication" ALTER COLUMN rm_identity DROP NOT NULL;
ALTER TABLE "Related_diagnosis" ALTER COLUMN diagnostic_code DROP NOT NULL;
ALTER TABLE "Invoice" ADD COLUMN "duration" int;
ALTER TABLE "Invoice" ADD COLUMN "survey" varchar(1500);
ALTER TABLE "Invoice" ADD COLUMN "tracing" varchar(1500);
ALTER TABLE "Invoice" ALTER COLUMN date DROP NOT NULL;
ALTER TABLE "Invoice" ALTER COLUMN number DROP NOT NULL;
ALTER TABLE "Invoice" ALTER COLUMN total_amount DROP NOT NULL;
ALTER TABLE "Request" ADD COLUMN "insurer_identity" bigint;
ALTER TABLE "Request" ADD CONSTRAINT "Request_insurer_identity_fkey" FOREIGN KEY (insurer_identity) REFERENCES "Insurer"(identity);
UPDATE "Patient_data" SET sex='M' WHERE sex='N';
CREATE TABLE "Subdiagnostic" (
	code varchar(50) PRIMARY KEY,
	subdiagnosis_code int,
	diagnostic_code varchar(50),
	CONSTRAINT "Subdiagnostic_subdiagnosis_code_fkey" FOREIGN KEY (subdiagnosis_code) REFERENCES "Subdiagnosis"(code),
	CONSTRAINT "Subdiagnostic_diagnostic_code_fkey" FOREIGN KEY (diagnostic_code) REFERENCES "Diagnostic"(code)
);
ALTER TABLE "Request" ADD COLUMN "registration_date" date;
ALTER TABLE "Request" ADD COLUMN "closing_date" date;
--AQUI CAMBIAR RUTA DEL ARCHIVO.!
COPY "Pharmacy_chain" FROM '/home/narbe/Documentos/APImetrics/API/migracion/Pharmacy_chain.txt' DELIMITER AS '|' NULL AS '\N';
ALTER TABLE "Pharmacy" ALTER COLUMN logo DROP NOT NULL;
SET CLIENT_ENCODING TO 'LATIN1';
--AQUI CAMBIAR RUTA DEL ARCHIVO.!
COPY "Pharmacy" FROM '/home/narbe/Documentos/APImetrics/API/migracion/Pharmacy.txt' DELIMITER AS '|' NULL AS '\N';
INSERT INTO "Insurer" VALUES (0,'Generico para Farma',1,NULL);
INSERT INTO "Collective" VALUES ('Farma',0);
INSERT INTO "Policy" VALUES ('Farma','Farma');
INSERT INTO "Plan" VALUES ('Farma','Generico para Farma','Farma');
SET CLIENT_ENCODING TO 'LATIN1';
--AQUI CAMBIAR RUTA DEL ARCHIVO.!
COPY "Patient_data" FROM '/home/narbe/Documentos/APImetrics/API/migracion/Patient_dataFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Id_patient" (type_id_name,identity,patient_data_identity,pharmacy_identity) FROM '/home/narbe/Documentos/APImetrics/API/migracion/Id_patientFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Affiliation" (plan_identity,identity,id_patient_identity) FROM '/home/narbe/Documentos/APImetrics/API/migracion/AffiliationFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Case" (identity,affiliation_identity) FROM '/home/narbe/Documentos/APImetrics/API/migracion/CaseFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Request" (type_request_code,identity,case_identity,status,date,age,type_of_age,number,insurer_identity,registration_date,closing_date) FROM '/home/narbe/Documentos/APImetrics/API/migracion/RequestFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Invoice" (request_identity,identity,date,number,total_amount) FROM '/home/narbe/Documentos/APImetrics/API/migracion/InvoiceFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Requested_medication" (identity,request_identity,quantity,reference_price,dp_identity) FROM '/home/narbe/Documentos/APImetrics/API/migracion/Requested_medicationFarma.txt' DELIMITER AS '|' NULL AS '\N';
COPY "Dispensed_drug" (unit_price,identity,rm_identity,invoice_identity) FROM '/home/narbe/Documentos/APImetrics/API/migracion/Dispensed_drugFarma.txt' DELIMITER AS '|' NULL AS '\N';
CREATE TABLE "Speciality" (
	identity int PRIMARY KEY,
	name varchar(100)
);
CREATE TABLE "Doctor" (
	identity bigint PRIMARY KEY,
	first_name varchar(50),
	last_name varchar(50),
	registration varchar(50),
	identification varchar(20),
	phone_number varchar(20)
);
CREATE TABLE "Relation_doctor_speciality" (
	identity bigint PRIMARY KEY,
	doctor_identity bigint,
	speciality_identity int,
	CONSTRAINT "Relation_doctor_speciality_doctor_identity_fkey" FOREIGN KEY (doctor_identity) REFERENCES "Doctor"(identity),
	CONSTRAINT "Relation_doctor_speciality_speciality_identity_fkey" FOREIGN KEY (speciality_identity) REFERENCES "Speciality"(identity)
);
CREATE TABLE "Doctor_barcodes" (
	identity bigint PRIMARY KEY,
	doctor_identity bigint,
	barcode varchar(25),
	CONSTRAINT "Relation_doctor_speciality_doctor_identity_fkey" FOREIGN KEY (doctor_identity) REFERENCES "Doctor"(identity)
);
CREATE TABLE "Relation_MR_Speciality" (
	identity bigint PRIMARY KEY,
	speciality_identity int,
	mr_identity bigint,
	CONSTRAINT "Relation_MR_Speciality_mr_identity_fkey" FOREIGN KEY (mr_identity) REFERENCES "Medical_report"(identity),
	CONSTRAINT "Relation_MR_Speciality_speciality_identity_fkey" FOREIGN KEY (speciality_identity) REFERENCES "Speciality"(identity)
);
ALTER TABLE "Medical_report" ADD COLUMN doctor_identity bigint;
ALTER TABLE "Medical_report" ADD CONSTRAINT "Medical_report_doctor_identity_fkey" FOREIGN KEY (doctor_identity) REFERENCES "Doctor"(identity);
-- COPY "Speciality" (identity,name) FROM '/home/narbe/Documentos/APImetrics/API/migracion/SpecialityFarma.txt' DELIMITER AS '|' NULL AS '\N';
-- COPY "Doctor" FROM '/home/narbe/Documentos/APImetrics/API/migracion/DoctorFarma.txt' DELIMITER AS '|' NULL AS '\N';
-- COPY "Relation_doctor_speciality" FROM '/home/narbe/Documentos/APImetrics/API/migracion/RelationDoctorSpecialityFarma.txt' DELIMITER AS '|' NULL AS '\N';
-- COPY "Doctor_barcodes" FROM '/home/narbe/Documentos/APImetrics/API/migracion/Doctor_barcodesFarma.txt' DELIMITER AS '|' NULL AS '\N';
CREATE TABLE "Posology" (
	identity int PRIMARY KEY,
	quantity int,
	frequency double precision,
	duration int,
	measure double precision	
);
ALTER TABLE "Prescribed_drug" ADD COLUMN posology_identity int;
ALTER TABLE "Prescribed_drug" ADD CONSTRAINT "Prescribed_drug_posology_identity_fkey" FOREIGN KEY (posology_identity) REFERENCES "Posology"(identity);