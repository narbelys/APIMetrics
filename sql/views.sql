ALTER TABLE "Irregularity_dispensed_drug" ADD COLUMN max_approved_quantity bigint NOT NULL;

--SAVINGS
CREATE OR REPLACE VIEW "Savings" AS
SELECT
	"Request".identity as request_identity,
	"Request".status as request_status,
	"Request".date as request_date,
	"Type_of_request".code as type_request_code,
	"Type_of_request".description as type_request_description,
	"Requested_medication".identity as requested_medication_identity,
	"Requested_medication".quantity as requested_medication_quantity,
	COALESCE("Requested_medication".reference_price,0) as requested_medication_reference_price,
	"Irregularity_prescribed_drug".identity as i_presc_drug_identity,
	"Irregularity_prescribed_drug".max_approved_quantity as i_presc_drug_quantity,
	"Irregularity_prescribed_drug".ignored_irregularity as i_presc_drug_ignored,
	"Irregularity_prescribed_drug".active as i_presc_drug_active,
	"Irregularity_prescribed_drug".enabled as i_presc_drug_enabled,
	ID1.description as i_presc_drug_description,
	"Irregularity_dispensed_drug".identity as i_disp_drug_identity,
	"Irregularity_dispensed_drug".max_approved_unit_price as i_disp_drug_unit_price,
	"Irregularity_dispensed_drug".ignored_irregularity as i_disp_drug_ignored,
	"Irregularity_dispensed_drug".active as i_disp_drug_active,
	"Irregularity_dispensed_drug".enabled as i_disp_drug_enabled,
	ID2.description as i_disp_drug_description,
    "Irregularity_dispensed_drug".max_approved_quantity as i_disp_drug_quantity
FROM
	"Request"
INNER JOIN "Type_of_request" ON "Type_of_request".code = "Request".type_request_code
INNER JOIN "Requested_medication" ON "Requested_medication".request_identity = "Request".identity
INNER JOIN "Related_medication" ON "Related_medication".rm_identity = "Requested_medication".identity
LEFT JOIN "Irregularity_prescribed_drug" ON "Irregularity_prescribed_drug".rm_code = "Related_medication".code
	LEFT JOIN "Irregularity_description" ID1 ON "Irregularity_prescribed_drug".id_identity = ID1.identity
LEFT JOIN "Irregularity_dispensed_drug" ON "Irregularity_dispensed_drug".rm_identity = "Requested_medication".identity
	LEFT JOIN "Irregularity_description" ID2 ON "Irregularity_dispensed_drug".id_identity = ID2.identity
ORDER BY "Request".identity;


--SAVINGS TOTAL VIEW
DROP VIEW "Savings_total";
CREATE OR REPLACE VIEW "Savings_total" AS
SELECT
	SUM("Requested_medication".quantity*COALESCE("Requested_medication".reference_price,0)) AS accident,
	COALESCE(SUM(("Requested_medication".quantity-IP1.max_approved_quantity)*("Requested_medication".reference_price-COALESCE(ID1.max_approved_unit_price,0))),0) as saving,
	"Request".date
FROM
	"Request"
INNER JOIN "Requested_medication" ON "Requested_medication".request_identity = "Request".identity
INNER JOIN "Related_medication" ON "Related_medication".rm_identity = "Requested_medication".identity
LEFT JOIN "Irregularity_prescribed_drug" AS IP1 ON IP1.rm_code = "Related_medication".code
AND ((IP1.active AND IP1.enabled AND NOT IP1.ignored_irregularity) OR (NOT EXISTS (SELECT 1 FROM "Irregularity_prescribed_drug" AS IP2 WHERE IP2.id_identity=IP1.id_identity AND IP2.rm_code=IP1.rm_code AND IP2.rd_code=IP1.rd_code AND IP2.request_identity=IP1.request_identity AND IP2.enabled) AND IP1.active AND NOT IP1.ignored_irregularity AND NOT IP1.enabled))
LEFT JOIN "Irregularity_dispensed_drug" AS ID1 ON ID1.rm_identity = "Requested_medication".identity
AND ((ID1.active AND ID1.enabled AND NOT ID1.ignored_irregularity) OR (NOT EXISTS (SELECT 1 FROM "Irregularity_dispensed_drug" AS ID2 WHERE ID2.id_identity=ID1.id_identity AND ID2.rm_identity=ID1.rm_identity AND ID2.request_identity=ID1.request_identity AND ID2.enabled) AND ID1.active AND NOT ID1.ignored_irregularity AND NOT ID1.enabled))
GROUP BY "Request".date;
-- IP2.max_approved_quantity=IP1.max_approved_quantity
-- ID2.max_approved_unit_price=ID1.max_approved_unit_price


--SUBSTITUTE
DROP VIEW "Substitute";
CREATE OR REPLACE VIEW "Substitute" AS
SELECT
	DP1.identity as presc_presentation_id,
	DP1.name as presc_presentation_name,
	DP1.dose as presc_presentation_dose,
	DB1.name as presc_presentation_drugbrand,
	DP2.identity as req_presentation_id,
	DP2.name as req_presentation_name,
	DP2.dose as req_presentation_dose,
	DB2.name as req_presentation_drugbrand
FROM
	"Prescribed_drug"
INNER JOIN "Drug_presentation" DP1 ON "Prescribed_drug".dp_identity = DP1.identity
INNER JOIN "Medication" M1 ON DP1.medication_identity = M1.identity
INNER JOIN "Drug_brand" DB1 ON M1.db_identity = DB1.identity
INNER JOIN "Related_medication" ON "Prescribed_drug".identity = "Related_medication".pd_identity
INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity
INNER JOIN "Drug_presentation" DP2 ON "Requested_medication".dp_identity = DP2.identity
INNER JOIN "Medication" M2 ON DP2.medication_identity = M2.identity
INNER JOIN "Drug_brand" DB2 ON M2.db_identity = DB2.identity
AND ((M1.identity <> M2.identity) OR ((M1.identity = M2.identity) AND (DP1.dose <> DP2.dose)))
GROUP BY DP1.identity, DB1.name, DP2.identity, DB2.name;


--DRUG PRESENTATION REQUEST VIEW 
DROP VIEW "Presentation_req_view";
CREATE OR REPLACE VIEW "Presentation_req_view" AS
SELECT
	"Drug_presentation".identity as presentation_identity,
	"Drug_presentation".name as presentation_name,
	COALESCE("Drug_presentation".reference_price,0) as presentation_price,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_presentation"
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Drug_presentation".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--DRUG PRESENTATION PRESCRIBED VIEW
DROP VIEW "Presentation_presc_view";
CREATE OR REPLACE VIEW "Presentation_presc_view" AS
SELECT
	"Drug_presentation".identity as presentation_identity,
	"Drug_presentation".name as presentation_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_presentation"
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Drug_presentation".identity, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--MEDICATION REQUEST VIEW
DROP VIEW "Medication_req_view";
CREATE OR REPLACE VIEW "Medication_req_view" AS
SELECT
	"Medication".identity as medication_identity,
	"Medication".name as medication_name,
	AVG(COALESCE("Drug_presentation".reference_price,0)) as reference_price,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Medication"
LEFT JOIN "Drug_presentation" ON "Drug_presentation".medication_identity = "Medication".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Medication".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--MEDICATION PRESCRIBED VIEW
DROP VIEW "Medication_presc_view";
CREATE OR REPLACE VIEW "Medication_presc_view" AS
SELECT
	"Medication".identity as medication_identity,
	"Medication".name as medication_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Medication"
LEFT JOIN "Drug_presentation" ON "Drug_presentation".medication_identity = "Medication".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Medication".identity, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--DRUG BRAND REQUEST VIEW
DROP VIEW "Drug_brand_req_view";
CREATE OR REPLACE VIEW "Drug_brand_req_view" AS
SELECT
	"Drug_brand".identity as drug_brand_identity,
	"Drug_brand".name as drug_brand_name,
	AVG(COALESCE("Drug_presentation".reference_price,0)) as reference_price,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_brand"
LEFT JOIN "Medication" ON "Medication".db_identity = "Drug_brand".identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".medication_identity = "Medication".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Drug_brand".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--DRUG BRAND PRESCRIBED VIEW
DROP VIEW "Drug_brand_presc_view";
CREATE OR REPLACE VIEW "Drug_brand_presc_view" AS
SELECT
	"Drug_brand".identity as drug_brand_identity,
	"Drug_brand".name as drug_brand_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_brand"
LEFT JOIN "Medication" ON "Medication".db_identity = "Drug_brand".identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".medication_identity = "Medication".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Drug_brand".identity, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--PHARMACEUTICAL REQUEST VIEW
DROP VIEW "Pharmaceutical_req_view";
CREATE OR REPLACE VIEW "Pharmaceutical_req_view" AS
SELECT
	"Pharmaceutical_company".identity as phar_comp_identity,
	"Pharmaceutical_company".name as phar_comp_name,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Pharmaceutical_company"
LEFT JOIN "Drug_presentation" ON "Drug_presentation".pc_identity = "Pharmaceutical_company".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Pharmaceutical_company".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--PHARMACEUTICAL PRESCRIBED VIEW
DROP VIEW "Pharmaceutical_presc_view";
CREATE OR REPLACE VIEW "Pharmaceutical_presc_view" AS
SELECT
	"Pharmaceutical_company".identity as phar_comp_identity,
	"Pharmaceutical_company".name as phar_comp_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Pharmaceutical_company"
LEFT JOIN "Drug_presentation" ON "Drug_presentation".pc_identity = "Pharmaceutical_company".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Pharmaceutical_company".identity, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--ACTIVE INGREDIENT REQUEST VIEW
DROP VIEW "Act_ingredient_req_view";
CREATE OR REPLACE VIEW "Act_ingredient_req_view" AS
SELECT
	"Active_ingredient".identity as act_ingredient_identity,
	"Active_ingredient".name as act_ingredient_name,
	AVG(COALESCE("Drug_presentation".reference_price,0)) as reference_price,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Active_ingredient"
LEFT JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.ai_identity = "Active_ingredient".identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Active_ingredient".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--ACTIVE INGREDIENT PRESCRIBED VIEW
DROP VIEW "Act_ingredient_presc_view";
CREATE OR REPLACE VIEW "Act_ingredient_presc_view" AS
SELECT
	"Active_ingredient".identity as act_ingredient_identity,
	"Active_ingredient".name as act_ingredient_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Active_ingredient"
LEFT JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.ai_identity = "Active_ingredient".identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Active_ingredient".identity, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;

--MEDICATION VIEW
-- CREATE VIEW "Medication_view" AS
-- SELECT
-- 	"Drug_presentation".identity as presentation_identity,
-- 	"Drug_presentation".name as presentation_name,
-- 	"Drug_presentation".units as presentation_units,
-- 	"Drug_presentation".dose as presentation_dose,
-- 	"Drug_presentation".max_daily_dosage as presentation_max_dosage,
-- 	"Drug_presentation".max_daily_frequency as presentation_max_frequency,
-- 	"Drug_presentation".reference_price as presentation_price,
-- 	"Drug_presentation".dispensing_form as presentation_dispensing_form,
-- 	"Drug_presentation".association_of_sex as presentation_sex,
-- 	"Drug_presentation".generic_or_drug_band as presentation_gen_or_brand,
-- 	"Pharmaceutical_company".identity as phar_comp_identity,
-- 	"Pharmaceutical_company".name as phar_comp_name,
-- 	"Pharmaceutical_company".address as phar_comp_address,
-- 	"Pharmaceutical_company".phone_number as phar_comp_phone,
-- 	"Medication".identity as medication_identity,
-- 	"Medication".name as medication_name,
-- 	"Medication".keywords as medication_keywords,
-- 	"Medication".drug_indications as medication_indications,
-- 	"Medication".contraindications as medication_contraindications,
-- 	"Medication".dosage as medication_dosage,
-- 	"Medication".adverse_reactions as medication_adverse,
-- 	"Drug_brand".identity as drug_brand_identity,
-- 	"Drug_brand".name as drug_brand_name,
-- 	"Dosage".identity as dosage_identity,
-- 	"Dosage".name as dosage_name,
-- 	"Dosage".dose as dosage_dose,
-- 	"Dosage".association_of_sex as dosage_sex,
-- 	"Dosage".vehicle as dosage_vehicle,
-- 	AITC.identity as aitc_identity,
-- 	AITC.name as aitc_name,
-- 	AITC.max_daily_dosage as aitc_max_dosage,
-- 	"Active_ingredient".identity as act_ingredient_identity,
-- 	"Active_ingredient".name as act_ingredient_name,
-- 	"Prescribed_drug".identity as presc_drug_identity,
-- 	"Prescribed_drug".quantity as presc_drug_quantity,
-- 	"Prescribed_drug".frequency as presc_drug_frequency,
-- 	"Prescribed_drug".duration_of_treatment as presc_drug_duration,
-- 	"Medical_report".identity as medreport_identity,
-- 	"Medical_report".date_of_issue as medreport_issue,
-- 	"Medical_report".due_date as medreport_due,
-- 	Case1.identity as presc_case_identity,
-- 	Case1.due_date as presc_case_date,
-- 	Affiliation1.identity as presc_affiliation_identity,
-- 	Id_patient1.identity as presc_patient_id,
-- 	Id_patient1.type_id_name as presc_patient_type_id,
-- 	Patient_data1.identity as presc_patient_identity,
-- 	Patient_data1.first_name as presc_patient_first_name,
-- 	Patient_data1.last_name as presc_patient_last_name,
-- 	Patient_data1.sex as presc_patient_sex,
-- 	Patient_data1.date_of_birth as presc_patient_birth,
-- 	Plan1.identity as presc_plan_identity,
-- 	Plan1.description as presc_plan_description,
-- 	Policy1.identity as presc_policy_identity,
-- 	Collective1.identity as presc_collective_identity,
-- 	Insurer1.identity as presc_insurer_identity,
-- 	Insurer1.name as presc_insurer_name,
-- 	Insurer1.insurer_type as presc_insurer_type,
-- 	"Requested_medication".identity as req_med_identity,
-- 	"Requested_medication".quantity as req_med_quantity,
-- 	"Requested_medication".reference_price as req_med_price,
-- 	"Request".identity as request_identity,
-- 	"Request".status as request_status,
-- 	"Request".date as request_date,
-- 	"Type_of_request".code as type_request_code,
-- 	"Type_of_request".description as type_request_description,
-- 	Case2.identity as req_case_identity,
-- 	Case2.due_date as req_case_date,
-- 	Affiliation2.identity as req_affiliation_identity,
-- 	Id_patient2.identity as req_patient_id,
-- 	Id_patient2.type_id_name as req_patient_type_id,
-- 	Patient_data2.identity as req_patient_identity,
-- 	Patient_data2.first_name as req_patient_first_name,
-- 	Patient_data2.last_name as req_patient_last_name,
-- 	Patient_data2.sex as req_patient_sex,
-- 	Patient_data2.date_of_birth as req_patient_birth,
-- 	Plan2.identity as req_plan_identity,
-- 	Plan2.description as req_plan_description,
-- 	Policy2.identity as req_policy_identity,
-- 	Collective2.identity as req_collective_identity,
-- 	Insurer2.identity as req_insurer_identity,
-- 	Insurer2.name as req_insurer_name,
-- 	Insurer2.insurer_type as req_insurer_type

-- FROM
-- 	"Drug_presentation"
-- INNER JOIN "Pharmaceutical_company" ON "Pharmaceutical_company".identity = "Drug_presentation".pc_identity
-- INNER JOIN "Medication" ON "Medication".identity = "Drug_presentation".medication_identity
-- INNER JOIN "Drug_brand" ON "Drug_brand".identity = "Medication".db_identity
-- INNER JOIN "Dosage" ON "Dosage".identity = "Drug_presentation".dosage_identity
-- INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Dosage".aitc_identity
-- INNER JOIN "Active_ingredient" ON "Active_ingredient".identity = AITC.ai_identity
-- LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
-- 	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
-- 	LEFT JOIN "Case" Case1 ON Case1.identity = "Medical_report".case_identity
-- 	LEFT JOIN "Affiliation" Affiliation1 ON Affiliation1.identity = Case1.affiliation_identity
-- 	LEFT JOIN "Id_patient" Id_patient1 ON Id_patient1.identity = Affiliation1.id_patient_identity
-- 	LEFT JOIN "Patient_data" Patient_data1 ON Patient_data1.identity = 	Id_patient1.patient_data_identity
-- 	LEFT JOIN "Plan" Plan1 ON Plan1.identity = Affiliation1.plan_identity
-- 	LEFT JOIN "Policy" Policy1 ON Policy1.identity = Plan1.policy_identity
-- 	LEFT JOIN "Collective" Collective1 ON Collective1.identity = Policy1.collective_identity
-- 	LEFT JOIN "Insurer" Insurer1 ON Insurer1.identity = Collective1.insurer_identity
-- LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
-- 	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
-- 	LEFT JOIN "Type_of_request" ON "Type_of_request".code = "Request".type_request_code
-- 	LEFT JOIN "Case" Case2 ON Case2.identity = "Request".case_identity
-- 	LEFT JOIN "Affiliation" Affiliation2 ON Affiliation2.identity = Case2.affiliation_identity
-- 	LEFT JOIN "Id_patient" Id_patient2 ON Id_patient2.identity = Affiliation2.id_patient_identity
-- 	LEFT JOIN "Patient_data" Patient_data2 ON Patient_data2.identity = 	Id_patient2.patient_data_identity
-- 	LEFT JOIN "Plan" Plan2 ON Plan2.identity = Affiliation2.plan_identity
-- 	LEFT JOIN "Policy" Policy2 ON Policy2.identity = Plan2.policy_identity
-- 	LEFT JOIN "Collective" Collective2 ON Collective2.identity = Policy2.collective_identity
-- 	LEFT JOIN "Insurer" Insurer2 ON Insurer2.identity = Collective2.insurer_identity
-- ORDER BY "Drug_presentation".identity;


--THERAPEUTIC CLASS REQUEST VIEW
DROP VIEW "Therapeutic_class_req_view";
CREATE OR REPLACE VIEW "Therapeutic_class_req_view" AS
SELECT
	"Therapeutic_class".code as therapeutic_code,
	"Therapeutic_class".name as therapeutic_name,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_class"
INNER JOIN "Therapeutic_subclass" ON "Therapeutic_subclass".tc_code = "Therapeutic_class".code
INNER JOIN "Therapeutic_subclass_2" ON "Therapeutic_subclass_2".ts_code = "Therapeutic_subclass".code
INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Therapeutic_class".code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC CLASS PRESCRIBED VIEW
DROP VIEW "Therapeutic_class_presc_view";
CREATE OR REPLACE VIEW "Therapeutic_class_presc_view" AS
SELECT
	"Therapeutic_class".code as therapeutic_code,
	"Therapeutic_class".name as therapeutic_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_class"
INNER JOIN "Therapeutic_subclass" ON "Therapeutic_subclass".tc_code = "Therapeutic_class".code
INNER JOIN "Therapeutic_subclass_2" ON "Therapeutic_subclass_2".ts_code = "Therapeutic_subclass".code
INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Therapeutic_class".code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC SUBCLASS REQUEST VIEW
DROP VIEW "Therapeutic_sub_req_view";
CREATE OR REPLACE VIEW "Therapeutic_sub_req_view" AS
SELECT
	"Therapeutic_subclass".code as therapeuticsub_code,
	"Therapeutic_subclass".name as therapeuticsub_name,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_subclass"
INNER JOIN "Therapeutic_subclass_2" ON "Therapeutic_subclass_2".ts_code = "Therapeutic_subclass".code
INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Therapeutic_subclass".code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC SUBCLASS PRESCRIBED VIEW
DROP VIEW "Therapeutic_sub_presc_view";
CREATE OR REPLACE VIEW "Therapeutic_sub_presc_view" AS
SELECT
	"Therapeutic_subclass".code as therapeuticsub_code,
	"Therapeutic_subclass".name as therapeuticsub_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_subclass"
INNER JOIN "Therapeutic_subclass_2" ON "Therapeutic_subclass_2".ts_code = "Therapeutic_subclass".code
INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Therapeutic_subclass".code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC SUBCLASS 2 REQUEST VIEW
DROP VIEW "Therapeutic_sub2_req_view";
CREATE OR REPLACE VIEW "Therapeutic_sub2_req_view" AS
SELECT
	"Therapeutic_subclass_2".code as therapeuticsub2_code,
	"Therapeutic_subclass_2".name as therapeuticsub2_name,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_subclass_2"
INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Therapeutic_subclass_2".code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC SUBCLASS 2 PRESCRIBED VIEW
DROP VIEW "Therapeutic_sub2_presc_view";
CREATE OR REPLACE VIEW "Therapeutic_sub2_presc_view" AS
SELECT
	"Therapeutic_subclass_2".code as therapeuticsub2_code,
	"Therapeutic_subclass_2".name as therapeuticsub2_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_subclass_2"
INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Therapeutic_subclass_2".code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC SUBCLASS 3 REQUEST VIEW
DROP VIEW "Therapeutic_sub3_req_view";
CREATE OR REPLACE VIEW "Therapeutic_sub3_req_view" AS
SELECT
	"Therapeutic_subclass_3".code as therapeuticsub3_code,
	"Therapeutic_subclass_3".name as therapeuticsub3_name,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_subclass_3"
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Therapeutic_subclass_3".code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC SUBCLASS 3 PRESCRIBED VIEW
DROP VIEW "Therapeutic_sub3_presc_view";
CREATE OR REPLACE VIEW "Therapeutic_sub3_presc_view" AS
SELECT
	"Therapeutic_subclass_3".code as therapeuticsub3_code,
	"Therapeutic_subclass_3".name as therapeuticsub3_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Therapeutic_subclass_3"
INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
LEFT JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
LEFT JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Therapeutic_subclass_3".code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--THERAPEUTIC CLASS VIEW
-- CREATE OR REPLACE VIEW "Therapeutic_view" AS
-- SELECT
-- 	"Therapeutic_class".code as therapeutic_code,
-- 	"Therapeutic_class".name as therapeutic_name,
-- 	"Therapeutic_subclass".code as therapeuticsub_code,
-- 	"Therapeutic_subclass".name as therapeuticsub_name,
-- 	"Therapeutic_subclass_2".code as therapeuticsub2_code,
-- 	"Therapeutic_subclass_2".name as therapeuticsub2_name,
-- 	"Therapeutic_subclass_3".code as therapeuticsub3_code,
-- 	"Therapeutic_subclass_3".name as therapeuticsub3_name,
-- 	AITC.identity as aitc_identity,
-- 	AITC.name as aitc_name,
-- 	AITC.max_daily_dosage as aitc_max_dosage,
-- 	"Dosage".identity as dosage_identity,
-- 	"Dosage".name as dosage_name,
-- 	"Dosage".dose as dosage_dose,
-- 	"Dosage".association_of_sex as dosage_sex,
-- 	"Dosage".vehicle as dosage_vehicle,
-- 	"Drug_presentation".identity as presentation_identity,
-- 	"Drug_presentation".name as presentation_name,
-- 	"Drug_presentation".units as presentation_units,
-- 	"Drug_presentation".dose as presentation_dose,
-- 	"Drug_presentation".max_daily_dosage as presentation_max_dosage,
-- 	"Drug_presentation".max_daily_frequency as presentation_max_frequency,
-- 	"Drug_presentation".reference_price as presentation_price,
-- 	-- "Drug_presentation".dispensing_form as presentation_dispensing_form,
-- 	"Drug_presentation".association_of_sex as presentation_sex,
-- 	"Drug_presentation".generic_or_drug_band as presentation_gen_or_brand,
-- 	"Prescribed_drug".identity as presc_drug_identity,
-- 	"Prescribed_drug".quantity as presc_drug_quantity,
-- 	"Prescribed_drug".frequency as presc_drug_frequency,
-- 	"Prescribed_drug".duration_of_treatment as presc_drug_duration,
-- 	"Medical_report".identity as medreport_identity,
-- 	"Medical_report".date_of_issue as medreport_issue,
-- 	"Medical_report".due_date as medreport_due,
-- 	Case1.identity as presc_case_identity,
-- 	Case1.due_date as presc_case_date,
-- 	Affiliation1.identity as presc_affiliation_identity,
-- 	Id_patient1.identity as presc_patient_id,
-- 	Id_patient1.type_id_name as presc_patient_type_id,
-- 	Patient_data1.identity as presc_patient_identity,
-- 	Patient_data1.first_name as presc_patient_first_name,
-- 	Patient_data1.last_name as presc_patient_last_name,
-- 	Patient_data1.sex as presc_patient_sex,
-- 	Patient_data1.date_of_birth as presc_patient_birth,
-- 	Plan1.identity as presc_plan_identity,
-- 	Plan1.description as presc_plan_description,
-- 	Policy1.identity as presc_policy_identity,
-- 	Collective1.identity as presc_collective_identity,
-- 	Insurer1.identity as presc_insurer_identity,
-- 	Insurer1.name as presc_insurer_name,
-- 	Insurer1.insurer_type as presc_insurer_type,
-- 	"Requested_medication".identity as req_med_identity,
-- 	"Requested_medication".quantity as req_med_quantity,
-- 	"Requested_medication".reference_price as req_med_price,
-- 	"Request".identity as request_identity,
-- 	"Request".status as request_status,
-- 	"Request".date as request_date,
-- 	"Type_of_request".code as type_request_code,
-- 	"Type_of_request".description as type_request_description,
-- 	Case2.identity as req_case_identity,
-- 	Case2.due_date as req_case_date,
-- 	Affiliation2.identity as req_affiliation_identity,
-- 	Id_patient2.identity as req_patient_id,
-- 	Id_patient2.type_id_name as req_patient_type_id,
-- 	Patient_data2.identity as req_patient_identity,
-- 	Patient_data2.first_name as req_patient_first_name,
-- 	Patient_data2.last_name as req_patient_last_name,
-- 	Patient_data2.sex as req_patient_sex,
-- 	Patient_data2.date_of_birth as req_patient_birth,
-- 	Plan2.identity as req_plan_identity,
-- 	Plan2.description as req_plan_description,
-- 	Policy2.identity as req_policy_identity,
-- 	Collective2.identity as req_collective_identity,
-- 	Insurer2.identity as req_insurer_identity,
-- 	Insurer2.name as req_insurer_name,
-- 	Insurer2.insurer_type as req_insurer_type

-- FROM
-- 	"Therapeutic_class"
-- INNER JOIN "Therapeutic_subclass" ON "Therapeutic_subclass".tc_code = "Therapeutic_class".code
-- INNER JOIN "Therapeutic_subclass_2" ON "Therapeutic_subclass_2".ts_code = "Therapeutic_subclass".code
-- INNER JOIN "Therapeutic_subclass_3" ON "Therapeutic_subclass_3".ts2_code = "Therapeutic_subclass_2".code
-- INNER JOIN "Relation_TS3_AITC" ON "Relation_TS3_AITC".ts3_code = "Therapeutic_subclass_3".code
-- INNER JOIN "Active_ingredient_Therapeutic_class" AITC ON AITC.identity = "Relation_TS3_AITC".aitc_identity
-- INNER JOIN "Dosage" ON "Dosage".aitc_identity = AITC.identity
-- INNER JOIN "Drug_presentation" ON "Drug_presentation".dosage_identity = "Dosage".identity
-- LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
-- 	LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
-- 	LEFT JOIN "Case" Case1 ON Case1.identity = "Medical_report".case_identity
-- 	LEFT JOIN "Affiliation" Affiliation1 ON Affiliation1.identity = Case1.affiliation_identity
-- 	LEFT JOIN "Id_patient" Id_patient1 ON Id_patient1.identity = Affiliation1.id_patient_identity
-- 	LEFT JOIN "Patient_data" Patient_data1 ON Patient_data1.identity = 	Id_patient1.patient_data_identity
-- 	LEFT JOIN "Plan" Plan1 ON Plan1.identity = Affiliation1.plan_identity
-- 	LEFT JOIN "Policy" Policy1 ON Policy1.identity = Plan1.policy_identity
-- 	LEFT JOIN "Collective" Collective1 ON Collective1.identity = Policy1.collective_identity
-- 	LEFT JOIN "Insurer" Insurer1 ON Insurer1.identity = Collective1.insurer_identity
-- LEFT JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
-- 	LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
-- 	LEFT JOIN "Type_of_request" ON "Type_of_request".code = "Request".type_request_code
-- 	LEFT JOIN "Case" Case2 ON Case2.identity = "Request".case_identity
-- 	LEFT JOIN "Affiliation" Affiliation2 ON Affiliation2.identity = Case2.affiliation_identity
-- 	LEFT JOIN "Id_patient" Id_patient2 ON Id_patient2.identity = Affiliation2.id_patient_identity
-- 	LEFT JOIN "Patient_data" Patient_data2 ON Patient_data2.identity = 	Id_patient2.patient_data_identity
-- 	LEFT JOIN "Plan" Plan2 ON Plan2.identity = Affiliation2.plan_identity
-- 	LEFT JOIN "Policy" Policy2 ON Policy2.identity = Plan2.policy_identity
-- 	LEFT JOIN "Collective" Collective2 ON Collective2.identity = Policy2.collective_identity
-- 	LEFT JOIN "Insurer" Insurer2 ON Insurer2.identity = Collective2.insurer_identity
-- ORDER BY "Therapeutic_class".code;


DROP VIEW "Diagnosis_view";
DROP VIEW "Diagnosis_req_view";
DROP VIEW "Diagnosis_presc_view";
DROP VIEW "Diagnosis_sub_req_view";
DROP VIEW "Diagnosis_sub_presc_view";
DROP VIEW "Diagnosis_type_req_view";
DROP VIEW "Diagnosis_type_presc_view";
DROP VIEW "Demographics_req_view";
DROP VIEW "Demographics_presc_view";


--DIAGNOSIS REQUEST VIEW
-- DROP MATERIALIZED VIEW "Diagnosis_req_view";
CREATE MATERIALIZED VIEW "Diagnosis_req_view" AS
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Diagnosis"
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity
	INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	INNER JOIN "Case" ON "Case".identity = "Request".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Diagnosis".code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	0 as req_med_quantity,
	0 as trans,
	0 AS total,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Diagnosis"
WHERE "Diagnosis".code NOT IN (SELECT DISTINCT("Diagnosis".code) FROM "Diagnosis"INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity INNER JOIN "Case" ON "Case".identity = "Request".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--DIAGNOSIS PRESCRIBED VIEW
-- DROP MATERIALIZED VIEW "Diagnosis_presc_view";
CREATE MATERIALIZED VIEW "Diagnosis_presc_view" AS
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Diagnosis"
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity
	INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Diagnosis".code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	0 as presc_drug_quantity,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Diagnosis"
WHERE "Diagnosis".code NOT IN (SELECT DISTINCT("Diagnosis".code) FROM "Diagnosis" INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--SUBTYPE OF DIAGNOSIS REQUEST VIEW
-- DROP MATERIALIZED VIEW "Diagnosis_sub_req_view";
CREATE MATERIALIZED VIEW "Diagnosis_sub_req_view" AS
SELECT
	SD.code as subtype_code,
	SD.description as subtype_description,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Subtype_of_diagnosis" SD
INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code
INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code	
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity
	INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	INNER JOIN "Case" ON "Case".identity = "Request".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY SD.code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	SD.code as subtype_code,
	SD.description as subtype_description,
	0 as req_med_quantity,
	0 as trans,
	0 AS total,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Subtype_of_diagnosis" SD
WHERE SD.code NOT IN (SELECT DISTINCT(SD.code) FROM "Subtype_of_diagnosis" SD INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity INNER JOIN "Case" ON "Case".identity = "Request".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--SUBTYPE OF DIAGNOSIS PRESCRIBED VIEW
-- DROP MATERIALIZED VIEW "Diagnosis_sub_presc_view";
CREATE MATERIALIZED VIEW "Diagnosis_sub_presc_view" AS
SELECT
	SD.code as subtype_code,
	SD.description as subtype_description,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Subtype_of_diagnosis" SD
INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code
INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code	
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity
	INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY SD.code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	SD.code as subtype_code,
	SD.description as subtype_description,
	0 as presc_drug_quantity,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Subtype_of_diagnosis" SD
WHERE SD.code NOT IN (SELECT DISTINCT(SD.code) FROM "Subtype_of_diagnosis" SD INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--TYPE OF DIAGNOSIS REQUEST VIEW
-- DROP MATERIALIZED VIEW "Diagnosis_type_req_view";
CREATE MATERIALIZED VIEW "Diagnosis_type_req_view" AS
SELECT
	TD.code as type_code,
	TD.description as type_description,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Type_of_diagnosis" TD
INNER JOIN "Subtype_of_diagnosis" SD ON SD.td_code = TD.code
INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code
INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code	
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity
	INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	INNER JOIN "Case" ON "Case".identity = "Request".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY TD.code, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	TD.code as type_code,
	TD.description as type_description,
	0 as req_med_quantity,
	0 as trans,
	0 AS total,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Type_of_diagnosis" TD
WHERE TD.code NOT IN (SELECT DISTINCT(TD.code) FROM "Type_of_diagnosis" TD INNER JOIN "Subtype_of_diagnosis" SD ON SD.td_code = TD.code INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity INNER JOIN "Case" ON "Case".identity = "Request".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--TYPE OF DIAGNOSIS PRESCRIBED VIEW
-- DROP MATERIALIZED VIEW "Diagnosis_type_presc_view";
CREATE MATERIALIZED VIEW "Diagnosis_type_presc_view" AS
SELECT
	TD.code as type_code,
	TD.description as type_description,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Type_of_diagnosis" TD
INNER JOIN "Subtype_of_diagnosis" SD ON SD.td_code = TD.code
INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code
INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code	
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity
	INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY TD.code, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	TD.code as type_code,
	TD.description as type_description,
	0 as presc_drug_quantity,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Type_of_diagnosis" TD
WHERE TD.code NOT IN (SELECT DISTINCT(TD.code) FROM "Type_of_diagnosis" TD INNER JOIN "Subtype_of_diagnosis" SD ON SD.td_code = TD.code INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".sd_code = SD.code INNER JOIN "Diagnosis" ON "Diagnosis".code = "Relation_SD_Diagnosis".diagnosis_code INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--DIAGNOSIS VIEW
-- CREATE OR REPLACE VIEW "Diagnosis_view" AS
-- SELECT
-- 	"Diagnosis".code as diagnosis_code,
-- 	"Diagnosis".name as diagnosis_name,
-- 	"Diagnosis".description as diagnosis_description,
-- 	"Diagnosis".keywords as diagnosis_keywords,
-- 	"Diagnosis".cie10 as diagnosis_cie10,
-- 	SD.code as subtype_code,
-- 	SD.description as subtype_description,
-- 	TD.code as type_code,
-- 	TD.description as type_description,
-- 	"Diagnostic".code as diagnostic_code,
-- 	"Prescribed_drug".identity as presc_drug_identity,
-- 	"Prescribed_drug".quantity as presc_drug_quantity,
-- 	"Prescribed_drug".frequency as presc_drug_frequency,
-- 	"Prescribed_drug".duration_of_treatment as presc_drug_duration,
-- 	DP1.identity as presc_presentation_id,
-- 	DP1.name as presc_presentation_name,
-- 	DP1.dose as presc_presentation_dose,
-- 	"Medical_report".identity as medreport_identity,
-- 	"Medical_report".date_of_issue as medreport_issue,
-- 	"Medical_report".due_date as medreport_due,
-- 	Case1.identity as presc_case_identity,
-- 	Case1.due_date as presc_case_date,
-- 	Affiliation1.identity as presc_affiliation_identity,
-- 	Id_patient1.identity as presc_patient_id,
-- 	Id_patient1.type_id_name as presc_patient_type_id,
-- 	Patient_data1.identity as presc_patient_identity,
-- 	Patient_data1.first_name as presc_patient_first_name,
-- 	Patient_data1.last_name as presc_patient_last_name,
-- 	Patient_data1.sex as presc_patient_sex,
-- 	Patient_data1.date_of_birth as presc_patient_birth,
-- 	Plan1.identity as presc_plan_identity,
-- 	Plan1.description as presc_plan_description,
-- 	Policy1.identity as presc_policy_identity,
-- 	Collective1.identity as presc_collective_identity,
-- 	Insurer1.identity as presc_insurer_identity,
-- 	Insurer1.name as presc_insurer_name,
-- 	Insurer1.insurer_type as presc_insurer_type,
-- 	"Requested_medication".identity as req_med_identity,
-- 	"Requested_medication".quantity as req_med_quantity,
-- 	"Requested_medication".reference_price as req_med_price,
-- 	DP2.identity as req_presentation_id,
-- 	DP2.name as req_presentation_name,
-- 	DP2.dose as req_presentation_dose,
-- 	"Request".identity as request_identity,
-- 	"Request".status as request_status,
-- 	"Request".date as request_date,
-- 	"Type_of_request".code as type_request_code,
-- 	"Type_of_request".description as type_request_description,
-- 	Case2.identity as req_case_identity,
-- 	Case2.due_date as req_case_date,
-- 	Affiliation2.identity as req_affiliation_identity,
-- 	Id_patient2.identity as req_patient_id,
-- 	Id_patient2.type_id_name as req_patient_type_id,
-- 	Patient_data2.identity as req_patient_identity,
-- 	Patient_data2.first_name as req_patient_first_name,
-- 	Patient_data2.last_name as req_patient_last_name,
-- 	Patient_data2.sex as req_patient_sex,
-- 	Patient_data2.date_of_birth as req_patient_birth,
-- 	Plan2.identity as req_plan_identity,
-- 	Plan2.description as req_plan_description,
-- 	Policy2.identity as req_policy_identity,
-- 	Collective2.identity as req_collective_identity,
-- 	Insurer2.identity as req_insurer_identity,
-- 	Insurer2.name as req_insurer_name,
-- 	Insurer2.insurer_type as req_insurer_type

-- FROM
-- 	"Diagnosis"
-- INNER JOIN "Relation_SD_Diagnosis" ON "Relation_SD_Diagnosis".diagnosis_code = "Diagnosis".code
-- INNER JOIN "Subtype_of_diagnosis" SD ON SD.code = "Relation_SD_Diagnosis".sd_code
-- INNER JOIN "Type_of_diagnosis" TD ON TD.code = SD.td_code
-- LEFT JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
-- 	LEFT JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
-- 		LEFT JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
-- 		LEFT JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity
-- 			LEFT JOIN "Drug_presentation" DP1 ON DP1.identity = "Prescribed_drug".dp_identity
-- 			LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
-- 			LEFT JOIN "Case" Case1 ON Case1.identity = "Medical_report".case_identity
-- 			LEFT JOIN "Affiliation" Affiliation1 ON Affiliation1.identity = Case1.affiliation_identity
-- 			LEFT JOIN "Id_patient" Id_patient1 ON Id_patient1.identity = Affiliation1.id_patient_identity
-- 			LEFT JOIN "Patient_data" Patient_data1 ON Patient_data1.identity = 	Id_patient1.patient_data_identity
-- 			LEFT JOIN "Plan" Plan1 ON Plan1.identity = Affiliation1.plan_identity
-- 			LEFT JOIN "Policy" Policy1 ON Policy1.identity = Plan1.policy_identity
-- 			LEFT JOIN "Collective" Collective1 ON Collective1.identity = Policy1.collective_identity
-- 			LEFT JOIN "Insurer" Insurer1 ON Insurer1.identity = Collective1.insurer_identity
-- 		LEFT JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity
-- 			LEFT JOIN "Drug_presentation" DP2 ON DP2.identity = "Requested_medication".dp_identity
-- 	 		LEFT JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
-- 	 		LEFT JOIN "Type_of_request" ON "Type_of_request".code = "Request".type_request_code
-- 	 		LEFT JOIN "Case" Case2 ON Case2.identity = "Request".case_identity
-- 			LEFT JOIN "Affiliation" Affiliation2 ON Affiliation2.identity = Case2.affiliation_identity
-- 			LEFT JOIN "Id_patient" Id_patient2 ON Id_patient2.identity = Affiliation2.id_patient_identity
-- 			LEFT JOIN "Patient_data" Patient_data2 ON Patient_data2.identity = 	Id_patient2.patient_data_identity
-- 			LEFT JOIN "Plan" Plan2 ON Plan2.identity = Affiliation2.plan_identity
-- 			LEFT JOIN "Policy" Policy2 ON Policy2.identity = Plan2.policy_identity
-- 			LEFT JOIN "Collective" Collective2 ON Collective2.identity = Policy2.collective_identity
-- 			LEFT JOIN "Insurer" Insurer2 ON Insurer2.identity = Collective2.insurer_identity
-- ORDER BY "Diagnosis".code;

--PATIENT VIEW
-- CREATE OR REPLACE VIEW "Patient_view" AS
-- SELECT
-- 	"Id_patient".identity as patient_id,
-- 	"Id_patient".type_id_name as patient_type_id,
-- 	"Patient_data".identity as patient_identity,
-- 	"Patient_data".first_name as patient_first_name,
-- 	"Patient_data".last_name as patient_last_name,
-- 	"Patient_data".sex as patient_sex,
-- 	"Patient_data".date_of_birth as patient_birth,
-- 	"Patient_data".cell_phone as patient_cell_phone,
-- 	"Patient_data".home_phone as patient_home_phone,
-- 	"Patient_data".email as patient_email,
-- 	"Patient_data".address as patient_address,
-- 	"Patient_data".reminder as patient_reminder,
-- 	"Pharmacy".identity as pharmacy_identity,
-- 	"Pharmacy".name as pharmacy_name,
-- 	"Pharmacy".company_name as pharmacy_company_name,
-- 	"Pharmacy".rif as pharmacy_rif,
-- 	"Pharmacy".address as pharmacy_address,
-- 	"Pharmacy".phone_number as pharmacy_number,
-- 	"Pharmacy".logo as pharmacy_logo,
-- 	"Pharmacy".status as pharmacy_status,
-- 	"Pharmacy".callcenter as pharmacy_callcenter,
-- 	"Pharmacy".web as pharmacy_web,
-- 	"Pharmacy_chain".identity as chain_identity,
-- 	"Pharmacy_chain".name as chain_name,
-- 	"Affiliation".identity as affiliation_identity,
-- 	"Plan".identity as plan_identity,
-- 	"Plan".description as plan_description,
-- 	"Policy".identity as policy_identity,
-- 	"Collective".identity as collective_identity,
-- 	"Insurer".identity as insurer_identity,
-- 	"Insurer".name as insurer_name,
-- 	"Insurer".insurer_type as insurer_type,
-- 	"Case".identity as case_identity,
-- 	"Case".due_date as case_date,
-- 	"Request".identity as request_identity,
-- 	"Request".status as request_status,
-- 	"Request".date as request_date,
-- 	"Request".age as request_age,
-- 	"Request".type_of_age as request_type_age,
-- 	"Type_of_request".code as type_request_code,
-- 	"Type_of_request".description as type_request_description,
-- 	"Requested_medication".identity as requested_medication_identity,
-- 	"Requested_medication".quantity as requested_medication_quantity,
-- 	"Requested_medication".reference_price as requested_medication_reference_price,
-- 	"Drug_presentation".identity as presentation_identity,
-- 	"Drug_presentation".name as presentation_name,
-- 	"Drug_presentation".units as presentation_units,
-- 	"Drug_presentation".dose as presentation_dose,
-- 	"Drug_presentation".max_daily_dosage as presentation_max_dosage,
-- 	"Drug_presentation".max_daily_frequency as presentation_max_frequency,
-- 	"Drug_presentation".reference_price as presentation_price,
-- 	-- "Drug_presentation".dispensing_form as presentation_dispensing_form,
-- 	"Drug_presentation".association_of_sex as presentation_sex,
-- 	"Drug_presentation".generic_or_drug_band as presentation_gen_or_brand

-- FROM
-- 	"Id_patient"

-- INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
-- INNER JOIN "Affiliation" ON "Affiliation".id_patient_identity = "Id_patient".identity
-- 	INNER JOIN "Plan" ON "Plan".identity = "Affiliation".plan_identity
-- 	INNER JOIN "Policy" ON "Policy".identity = "Plan".policy_identity
-- 	INNER JOIN "Collective" ON "Collective".identity = "Policy".collective_identity
-- 	INNER JOIN "Insurer" ON "Insurer".identity = "Collective".insurer_identity
-- INNER JOIN "Case" ON "Case".affiliation_identity = "Affiliation".identity
-- INNER JOIN "Request" ON "Request".case_identity = "Case".identity
-- INNER JOIN "Type_of_request" ON "Type_of_request".code = "Request".type_request_code
-- INNER JOIN "Requested_medication" ON "Requested_medication".request_identity = "Request".identity
-- INNER JOIN "Drug_presentation" ON "Drug_presentation".identity = "Requested_medication".dp_identity
-- LEFT JOIN "Pharmacy" ON "Pharmacy".identity = "Id_patient".pharmacy_identity
-- 	LEFT JOIN "Pharmacy_chain" ON "Pharmacy_chain".identity = "Pharmacy".chain_identity
-- ORDER BY "Id_patient".identity;
DROP VIEW "Patient_view";
DROP VIEW "Demographics_view";


--DEMOGRAPHICS DATA REQUEST VIEW
-- DROP MATERIALIZED VIEW "Demographics_req_view";
CREATE MATERIALIZED VIEW "Demographics_req_view" AS
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	"Drug_presentation".identity as req_presentation_id,
	"Drug_presentation".name as req_presentation_name,
	"Drug_presentation".dose as req_presentation_dose,
	SUM(COALESCE("Requested_medication".quantity,0)) as req_med_quantity,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	SUM(COALESCE("Requested_medication".quantity,0)*COALESCE("Requested_medication".reference_price,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Diagnosis"
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity
INNER JOIN "Drug_presentation" ON "Drug_presentation".identity = "Requested_medication".dp_identity
	INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	INNER JOIN "Case" ON "Case".identity = "Request".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Diagnosis".code, "Drug_presentation".identity,"Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	NULL as req_presentation_id,
	NULL as req_presentation_name,
	NULL as req_presentation_dose,
	0 as req_med_quantity,
	0 as trans,
	0 AS total,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Diagnosis"
WHERE "Diagnosis".code NOT IN (SELECT DISTINCT("Diagnosis".code) FROM "Diagnosis" INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Requested_medication" ON "Requested_medication".identity = "Related_medication".rm_identity INNER JOIN "Drug_presentation" ON "Drug_presentation".identity = "Requested_medication".dp_identity INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity INNER JOIN "Case" ON "Case".identity = "Request".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


-- DEMOGRAPHICS DATA PRESCRIBED VIEW
-- DROP MATERIALIZED VIEW "Demographics_presc_view";
CREATE MATERIALIZED VIEW "Demographics_presc_view" AS
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	"Drug_presentation".identity as req_presentation_id,
	"Drug_presentation".name as req_presentation_name,
	"Drug_presentation".dose as req_presentation_dose,
	SUM(COALESCE("Prescribed_drug".quantity,0)) as presc_drug_quantity,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Diagnosis"
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code
INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity
INNER JOIN "Drug_presentation" ON "Drug_presentation".identity = "Prescribed_drug".dp_identity
	INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Diagnosis".code, "Drug_presentation".identity,"Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	NULL as req_presentation_id,
	NULL as req_presentation_name,
	NULL as req_presentation_dose,
	0 as presc_drug_quantity,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Diagnosis"
WHERE "Diagnosis".code NOT IN (SELECT DISTINCT("Diagnosis".code) FROM "Diagnosis" INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code INNER JOIN "Related_diagnosis" ON "Related_diagnosis".diagnostic_code = "Diagnostic".code INNER JOIN "Related_medication" ON "Related_medication".code = "Related_diagnosis".rm_code INNER JOIN "Prescribed_drug" ON "Prescribed_drug".identity = "Related_medication".pd_identity INNER JOIN "Drug_presentation" ON "Drug_presentation".identity = "Prescribed_drug".dp_identity INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity);


--PHARMACY VIEW
DROP VIEW "Pharmacy_view";
CREATE OR REPLACE VIEW "Pharmacy_view" AS
SELECT
	"Pharmacy".identity as identity,
	"Pharmacy".name as name,
	"Pharmacy".callcenter as callcenter,
	"Pharmacy".address as address,
	COUNT(DISTINCT "Invoice".identity) as trans,
	SUM(COALESCE("Invoice".total_amount,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Pharmacy"
LEFT JOIN "Id_patient" ON "Id_patient".pharmacy_identity = "Pharmacy".identity
LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
LEFT JOIN "Affiliation" ON "Affiliation".id_patient_identity = "Id_patient".identity
LEFT JOIN "Case" ON "Case".affiliation_identity = "Affiliation".identity
LEFT JOIN "Request" ON "Request".case_identity = "Case".identity
LEFT JOIN "Invoice" ON "Invoice".request_identity = "Request".identity
GROUP BY "Pharmacy".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--PHARMACY CHAIN VIEW
DROP VIEW "Pharmacy_chain_view";
CREATE OR REPLACE VIEW "Pharmacy_chain_view" AS
SELECT
	"Pharmacy_chain".identity as identity,
	"Pharmacy_chain".name as name,
	COUNT(DISTINCT "Invoice".identity) as trans,
	SUM(COALESCE("Invoice".total_amount,0)) AS total,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Pharmacy_chain"
LEFT JOIN "Pharmacy" ON "Pharmacy".chain_identity = "Pharmacy_chain".identity
LEFT JOIN "Id_patient" ON "Id_patient".pharmacy_identity = "Pharmacy".identity
LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
LEFT JOIN "Affiliation" ON "Affiliation".id_patient_identity = "Id_patient".identity
LEFT JOIN "Case" ON "Case".affiliation_identity = "Affiliation".identity
LEFT JOIN "Request" ON "Request".case_identity = "Case".identity
LEFT JOIN "Invoice" ON "Invoice".request_identity = "Request".identity
GROUP BY "Pharmacy_chain".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--SPECIALITY VIEW
DROP VIEW "Speciality_view";
CREATE OR REPLACE VIEW "Speciality_view" AS
SELECT
	"Speciality".identity as speciality_identity,
	"Speciality".name as speciality_name,
	COUNT(DISTINCT "Requested_medication".request_identity) as trans,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Speciality"
LEFT JOIN "Relation_MR_Speciality" ON "Relation_MR_Speciality".speciality_identity = "Speciality".identity
LEFT JOIN "Medical_report" ON "Medical_report".identity = "Relation_MR_Speciality".mr_identity
LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
	LEFT JOIN "Requested_medication" ON "Requested_medication".request_identity = "Request".identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Speciality".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--IRREGULARITY VIEW 
DROP VIEW "Irregularity_view";
CREATE OR REPLACE VIEW "Irregularity_view" AS
SELECT
	"Irregularity_description".identity as irregularity_identity,
	"Irregularity_description".description as irregularity_description,
	COUNT(DISTINCT "Request".identity) as trans,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Irregularity_description"
INNER JOIN "Irregularity_prescribed_drug" ON "Irregularity_prescribed_drug".id_identity = "Irregularity_description".identity
	LEFT JOIN "Request" ON "Request".identity = "Irregularity_prescribed_drug".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Irregularity_description".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	"Irregularity_description".identity as irregularity_identity,
	"Irregularity_description".description as irregularity_description,
	COUNT(DISTINCT "Request".identity) as trans,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Irregularity_description"
INNER JOIN "Irregularity_dispensed_drug" ON "Irregularity_dispensed_drug".id_identity = "Irregularity_description".identity
	LEFT JOIN "Request" ON "Request".identity = "Irregularity_dispensed_drug".request_identity
	LEFT JOIN "Case" ON "Case".identity = "Request".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Irregularity_description".identity, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex
UNION
SELECT
	"Irregularity_description".identity as irregularity_identity,
	"Irregularity_description".description as irregularity_description,
	0 as trans,
	NULL as date,
	NULL as age,
	NULL as type_of_age,
	NULL as sex
FROM
	"Irregularity_description"
WHERE "Irregularity_description".identity NOT IN (SELECT "Irregularity_description".identity FROM "Irregularity_description" INNER JOIN "Irregularity_dispensed_drug" ON "Irregularity_dispensed_drug".id_identity = "Irregularity_description".identity UNION SELECT "Irregularity_description".identity FROM "Irregularity_description" INNER JOIN "Irregularity_prescribed_drug" ON "Irregularity_prescribed_drug".id_identity = "Irregularity_description".identity);


DROP VIEW "Other_dispensations_view";
DROP VIEW "Other_prescriptions_view";


--OTHER DISPENSATIONS DRUG PRESENTATION VIEW
DROP VIEW "Other_dispensations_drug_view";
CREATE OR REPLACE VIEW "Other_dispensations_drug_view" AS
SELECT
	"Drug_presentation".identity as presentation_identity,
	"Drug_presentation".name as presentation_name,
	DP1.name as other,
	COUNT(DP1.name) as trans,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_presentation"
INNER JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
INNER JOIN "Requested_medication" AS RM1 ON RM1.request_identity = "Requested_medication".request_identity
INNER JOIN "Drug_presentation" AS DP1 ON DP1.identity = RM1.dp_identity
AND "Drug_presentation".identity <> DP1.identity
	INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	INNER JOIN "Case" ON "Case".identity = "Request".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Drug_presentation".identity, DP1.name, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--OTHER DISPENSATIONS MEDICATION VIEW
DROP VIEW "Other_dispensations_med_view";
CREATE OR REPLACE VIEW "Other_dispensations_med_view" AS
SELECT
	"Medication".identity as medication_identity,
	"Medication".name as medication_name,
	M1.name as other,
	COUNT(M1.name) as trans,
	"Request".date as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Medication"
INNER JOIN "Drug_presentation" ON "Drug_presentation".medication_identity = "Medication".identity
INNER JOIN "Requested_medication" ON "Requested_medication".dp_identity = "Drug_presentation".identity
INNER JOIN "Requested_medication" AS RM1 ON RM1.request_identity = "Requested_medication".request_identity
INNER JOIN "Drug_presentation" AS DP1 ON DP1.identity = RM1.dp_identity
INNER JOIN "Medication" AS M1 ON M1.identity = DP1.medication_identity
AND "Medication".identity <> M1.identity
	INNER JOIN "Request" ON "Request".identity = "Requested_medication".request_identity
	INNER JOIN "Case" ON "Case".identity = "Request".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Medication".identity, M1.name, "Request".date, "Request".age, "Request".type_of_age, "Patient_data".sex;


--OTHER PRESCRIPTIONS DRUG PRESENTATION VIEW
DROP VIEW "Other_prescriptions_drug_view";
CREATE OR REPLACE VIEW "Other_prescriptions_drug_view" AS
SELECT
	"Drug_presentation".identity as presentation_identity,
	"Drug_presentation".name as presentation_name,
	DP1.name as other,
	COUNT(DP1.name) as trans,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_presentation"
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
INNER JOIN "Prescribed_drug" AS PD1 ON PD1.mr_identity = "Prescribed_drug".mr_identity
INNER JOIN "Drug_presentation" AS DP1 ON DP1.identity = PD1.dp_identity
AND "Drug_presentation".identity <> DP1.identity
INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Drug_presentation".identity, DP1.name, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--OTHER PRESCRIPTIONS MEDICATION VIEW
DROP VIEW "Other_prescriptions_med_view";
CREATE OR REPLACE VIEW "Other_prescriptions_med_view" AS
SELECT
	"Medication".identity as medication_identity,
	"Medication".name as medication_name,
	M1.name as other,
	COUNT(M1.name) as trans,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Medication"
INNER JOIN "Drug_presentation" ON "Drug_presentation".medication_identity = "Medication".identity
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
INNER JOIN "Prescribed_drug" AS PD1 ON PD1.mr_identity = "Prescribed_drug".mr_identity
INNER JOIN "Drug_presentation" AS DP1 ON DP1.identity = PD1.dp_identity
INNER JOIN "Medication" AS M1 ON M1.identity = DP1.medication_identity
AND "Medication".identity <> M1.identity
INNER JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
GROUP BY "Medication".identity, M1.name, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--OTHER DIAGNOSIS VIEW 
DROP VIEW "Other_diagnosis_view";
CREATE OR REPLACE VIEW "Other_diagnosis_view" AS
SELECT
	"Diagnosis".code as diagnosis_code,
	"Diagnosis".name as diagnosis_name,
	D1.name as other,
	COUNT(D1.name) as trans,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Diagnosis"
INNER JOIN "Diagnostic" ON "Diagnostic".diagnosis_code = "Diagnosis".code
INNER JOIN "Diagnostic" AS DC1 ON DC1.mr_identity = "Diagnostic".mr_identity
INNER JOIN "Diagnosis" AS D1 ON D1.code = DC1.diagnosis_code
AND "Diagnosis".code <> D1.code
INNER JOIN "Medical_report" ON "Medical_report".identity = "Diagnostic".mr_identity
	INNER JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	INNER JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
	INNER JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	INNER JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	INNER JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	INNER JOIN "Patient_data" ON "Patient_data".identity = "Id_patient".patient_data_identity
GROUP BY "Diagnosis".code, D1.name, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;


--POSOLOGY VIEW 
DROP VIEW "Posology_view";
CREATE OR REPLACE VIEW "Posology_view" AS
SELECT
	"Drug_presentation".identity as presentation_identity,
	"Drug_presentation".name as presentation_name,
	SUM(DISTINCT("Posology".quantity)*COALESCE("Posology".measure,1)) as quantity,
	SUM(DISTINCT("Posology".frequency)) as frequency,
	SUM(DISTINCT("Posology".duration)) as duration,
	COUNT(DISTINCT(MR1.identity)) as total,
	"Medical_report".date_of_issue as date,
	"Request".age as age,
	"Request".type_of_age as type_of_age,
	"Patient_data".sex as sex
FROM
	"Drug_presentation"
INNER JOIN "Prescribed_drug" ON "Prescribed_drug".dp_identity = "Drug_presentation".identity
INNER JOIN "Posology" ON "Posology".identity = "Prescribed_drug".posology_identity
LEFT JOIN "Medical_report" ON "Medical_report".identity = "Prescribed_drug".mr_identity
	LEFT JOIN "Case" ON "Case".identity = "Medical_report".case_identity
	LEFT JOIN "Affiliation" ON "Affiliation".identity = "Case".affiliation_identity
	LEFT JOIN "Id_patient" ON "Id_patient".identity = "Affiliation".id_patient_identity
	LEFT JOIN "Patient_data" ON "Patient_data".identity = 	"Id_patient".patient_data_identity
	LEFT JOIN "Relation_MR_Request" ON "Relation_MR_Request".mr_identity = "Medical_report".identity
	LEFT JOIN "Request" ON "Request".identity = "Relation_MR_Request".request_identity
LEFT JOIN "Posology" AS P1 ON (P1.quantity="Posology".quantity AND P1.frequency="Posology".frequency AND P1.duration="Posology".duration AND ((P1.measure="Posology".measure)OR(P1.measure IS NULL AND "Posology".measure IS NULL)))
LEFT JOIN "Prescribed_drug" AS PD1 ON (PD1.posology_identity = P1.identity)
AND PD1.dp_identity = "Drug_presentation".identity
LEFT JOIN "Medical_report" AS MR1 ON (MR1.identity = PD1.mr_identity AND MR1.date_of_issue="Medical_report".date_of_issue)
LEFT JOIN "Case" AS C1 ON C1.identity = MR1.case_identity
	LEFT JOIN "Affiliation" AS A1 ON A1.identity = C1.affiliation_identity
	LEFT JOIN "Id_patient" AS ID1 ON ID1.identity = A1.id_patient_identity
	LEFT JOIN "Patient_data" AS PAD1 ON (PAD1.identity = ID1.patient_data_identity AND PAD1.sex="Patient_data".sex)
	LEFT JOIN "Relation_MR_Request" AS RM1 ON RM1.mr_identity = MR1.identity
	LEFT JOIN "Request" AS R1 ON (R1.identity = RM1.request_identity AND R1.age="Request".age AND R1.type_of_age="Request".type_of_age)
GROUP BY "Drug_presentation".identity, "Medical_report".date_of_issue, "Request".age, "Request".type_of_age, "Patient_data".sex;