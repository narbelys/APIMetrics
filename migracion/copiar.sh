#!/bin/bash
#################################################################################################################################
#																																#
# Script para copiar datos a POSTGRES																							#
# En los archivos las columnas se encuentran separadas por "|" y el fin de linea lo indica "*\r"								#
#																																#
#################################################################################################################################

#### PARAMETROS DE CONEXION A BD POSTGRES
echo "Configurando conexion psql"
psql_host="/var/run/postgresql"
psql_usuario="jenelin"
psql_password=""
psql_database="PRX"
psql_port="5433"
psql_args="$psql_database -p $psql_port -h $psql_host "

### Ruta en la cual se guardan los archivos de la migracion
ruta="/home/jenelin/Django Projects/sql/"

### Archivo log de la extraccion de datos de MYSQL
logfile="${ruta}copiar$(date +"%Y-%m-%d").log"

### Archivo con la instrucción sql a ejecutar
psqlfile="${ruta}psql.sql"

### AQUI EMPIEZA BORRADO DE LOS DATOS DE POSTGRES
echo -e "Inicia borrado de tablas postgres"
echo $(date +"%Y-%m-%d  %T")
echo -e "Inicia borrado de tablas postgres" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"

### Listado de las tablas
tablas="
Irregularity_prescribed_drug
Irregularity_description
Related_diagnosis
Related_medication
Requested_medication
Prescribed_drug
Subdiagnostic
Diagnostic
Relation_MR_Speciality
Relation_MR_Request
Medical_report
Request
Type_of_request
Status
Case
Doctor_barcodes
Relation_doctor_speciality
Doctor
Speciality
Affiliation
Plan
Policy
Collective
Insurer
Id_patient
Patient_data
Type_of_id_patient
Country
Posology
Drug_presentation
Medication
Drug_brand
Pharmaceutical_company
Dosage_form
Dosage_form_group
Dosage
Relation_TS3_AITC
Active_ingredient_Therapeutic_class
Active_ingredient
Relation_SD_TS2
Relation_SD_Diagnosis
Subdiagnosis
Diagnosis
Subtype_of_diagnosis
Type_of_diagnosis
Therapeutic_subclass_3
Therapeutic_subclass_2
Therapeutic_subclass
Therapeutic_class
"
### Agregar estas tablas cuando existan casos en la BD
# Invoice
# Dispensed_drug

for tabla in ${tablas} ; do
	echo "Borrando datos de la tabla ${tabla}... $(date +"%Y-%m-%d  %T")"
	echo "Borrando datos de la tabla ${tabla}... $(date +"%Y-%m-%d  %T")" >>"$logfile"
	cp /dev/null "${psqlfile}" ###Creando archivo nulo
	echo -e "DELETE FROM \"${tabla}\";" >>"$psqlfile"
	psql $psql_args -f "$psqlfile"
done

### AQUI EMPIEZA LA CARGA DE LOS DATOS DE ARCHIVOS TXT A POSTGRES
echo -e "Inicia carga de datos"
echo $(date +"%Y-%m-%d  %T")
echo -e "Inicia carga de datos" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"

### Listado de las tablas
tablas="
Therapeutic_class
Therapeutic_subclass
Therapeutic_subclass_2
Therapeutic_subclass_3
Type_of_diagnosis
Subtype_of_diagnosis
Diagnosis
Subdiagnosis
Relation_SD_Diagnosis
Relation_SD_TS2
Active_ingredient
Active_ingredient_Therapeutic_class
Relation_TS3_AITC
Dosage
Dosage_form_group
Dosage_form
Pharmaceutical_company
Drug_brand
Medication
Drug_presentation
Posology
Country
Type_of_id_patient
Patient_data
Id_patient
Insurer
Collective
Policy
Plan
Affiliation
Speciality
Doctor
Relation_doctor_speciality
Doctor_barcodes
Case
Status
Type_of_request
Request
Medical_report
Relation_MR_Request
Relation_MR_Speciality
Diagnostic
Subdiagnostic
Prescribed_drug
Requested_medication
Related_medication
Related_diagnosis
Irregularity_description
Irregularity_prescribed_drug
"
### Agregar estas tablas cuando existan casos en la BD
# Invoice
# Dispensed_drug


for tabla in ${tablas} ; do
	echo "Cargando datos en la tabla ${tabla}... $(date +"%Y-%m-%d  %T")"
	echo "Cargando datos en la tabla ${tabla}... $(date +"%Y-%m-%d  %T")" >>"$logfile"
	cp /dev/null "${psqlfile}" ###Creando archivo nulo
	echo -e "SET CLIENT_ENCODING TO 'LATIN1';" >>"$psqlfile"
	if [ "${tabla}" = "Id_patient" ]; then
		echo -e "COPY \"${tabla}\" (identity,patient_data_identity,type_id_name,pharmacy_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
		echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
	else
		if [ "${tabla}" = "Request" ]; then
			echo -e "COPY \"${tabla}\" (type_request_code,identity,status,date,case_identity,age,type_of_age,number,insurer_identity,registration_date,closing_date) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
			echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
		else
			if [ "${tabla}" = "Medical_report" ]; then
				echo -e "COPY \"${tabla}\" (identity,date_of_issue,due_date,case_identity,number) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
				echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
			else
				if [ "${tabla}" = "Relation_MR_Speciality" ]; then
					echo -e "COPY \"${tabla}\" (identity,mr_identity,speciality_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
					echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
				else
					if [ "${tabla}" = "Diagnostic" ]; then
						echo -e "COPY \"${tabla}\" (diagnosis_code,code,mr_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
						echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
					else
						if [ "${tabla}" = "Subdiagnostic" ]; then
							echo -e "COPY \"${tabla}\" (subdiagnosis_code,code,diagnostic_code) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
							echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
						else
							if [ "${tabla}" = "Prescribed_drug" ]; then
								echo -e "COPY \"${tabla}\" (identity,mr_identity,quantity,dp_identity,posology_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
								echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
							else
								if [ "${tabla}" = "Requested_medication" ]; then
									echo -e "COPY \"${tabla}\" (identity,request_identity,quantity,reference_price,dp_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
									echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
								else
									# if [ "${tabla}" = "Invoice" ];then
									# 	echo -e "COPY \"${tabla}\" (request_identity,identity,date,number,total_amount) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
									# 	echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
									# else
										# if [ "${tabla}" = "Dispensed_drug" ];then
										# 	echo -e "COPY \"${tabla}\" (unit_price,identity,rm_identity,invoice_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
										# 	echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
										# else
											if [ "${tabla}" = "Irregularity_prescribed_drug" ];then
												echo -e "COPY \"${tabla}\" (identity,rm_code,rd_code,request_identity,ignored_irregularity,active,enabled,max_approved_quantity,id_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
												echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
											else
												echo -e "COPY \"${tabla}\" FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
												echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
											fi
										# fi
									# fi
								fi
							fi
						fi
					fi
				fi
			fi
		fi
	fi
	psql $psql_args -f "$psqlfile"
	# psql "PRX" -p 5433 -h /var/run/postgresql -f "$psqlfile"
done

# REFRESH DE LAS VISTAS MATERIALIZADAS
echo "Actualizando las vistas materializadas... $(date +"%Y-%m-%d  %T")"
echo "Actualizando las vistas materializadas... $(date +"%Y-%m-%d  %T")" >>"$logfile"
psql -p $psql_port -h $psql_host $psql_database $psql_usuario << EOF
	REFRESH MATERIALIZED VIEW "Diagnosis_req_view";
    REFRESH MATERIALIZED VIEW "Diagnosis_presc_view";
    REFRESH MATERIALIZED VIEW "Diagnosis_sub_req_view";
    REFRESH MATERIALIZED VIEW "Diagnosis_sub_presc_view";
    REFRESH MATERIALIZED VIEW "Diagnosis_type_req_view";
    REFRESH MATERIALIZED VIEW "Diagnosis_type_presc_view";
    REFRESH MATERIALIZED VIEW "Demographics_req_view";
    REFRESH MATERIALIZED VIEW "Demographics_presc_view";
EOF

### AQUI TERMINA LA CARGA DE LOS DATOS DE ARCHIVOS TXT A POSTGRES
echo -e "Termina carga de datos"
echo $(date +"%Y-%m-%d  %T")
echo -e "Termina carga de datos" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"