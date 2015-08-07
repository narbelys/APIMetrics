#!/bin/bash
#################################################################################################################################
#																																#
# Script para extraer los datos de MYSQL a archivos .txt y copiarlos a POSTGRES													#
# En los archivos las columnas se encuentran separadas por "|" y el fin de linea lo indica "*\r"								#
#																																#
#################################################################################################################################

#### PARAMETROS DE CONEXION A BD MYSQL
echo "Configurando conexion mysql"
sql_host="localhost"
sql_usuario="root"
sql_password="12qwaszx"
sql_database="humanitas"
sql_args="-h $sql_host -u $sql_usuario -p$sql_password -D $sql_database -s -e"

### Ruta en la cual se guardan los archivos de la migracion
ruta="/home/jenelin/Django Projects/sql/"

### Archivo log de la extraccion de datos de MYSQL
logfile="${ruta}migracion$(date +"%Y-%m-%d").log"

### AQUI EMPIEZA EL VOLCADO DE LOS DATOS DE MYSQL A ARCHIVOS TXT
echo -e "Inicia volcado de datos"
echo $(date +"%Y-%m-%d  %T")
echo -e "Inicia volcado de datos" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"

#####################################################   FARMACOLOGICAS   ##########################################################
echo "Volcado de datos para la tabla Therapeutic_class... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Therapeutic_class... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_clase,nombre_clase FROM clase_terapeutica INTO OUTFILE '${ruta}Therapeutic_class.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Therapeutic_subclass... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Therapeutic_subclass... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_subclase,nombre_subclase,id_clase FROM subclase_terapeutica INTO OUTFILE '${ruta}Therapeutic_subclass.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Therapeutic_subclass_2... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Therapeutic_subclass_2... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT subclase_nivel2.id_subclase2,subclase_nivel2.nombre_subclase2,subclase_terapeutica.id_subclase FROM subclase_nivel2,subclase_terapeutica WHERE subclase_nivel2.id_subclase=subclase_terapeutica.sc_id INTO OUTFILE '${ruta}Therapeutic_subclass_2.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Therapeutic_subclass_3... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Therapeutic_subclass_3... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT subclase_nivel3.id_subclase3,subclase_nivel3.nombre_subclase3,subclase_nivel2.id_subclase2 FROM subclase_nivel3,subclase_nivel2 WHERE subclase_nivel3.id_subclase2=subclase_nivel2.sc2_id INTO OUTFILE '${ruta}Therapeutic_subclass_3.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

######################################################   ENFERMEDADES   ###########################################################
echo "Volcado de datos para la tabla Type_of_diagnosis... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Type_of_diagnosis... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_diagnostico1,nombre_tipo1 FROM tipo_diagnostico1 INTO OUTFILE '${ruta}Type_of_diagnosis.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Subtype_of_diagnosis... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Subtype_of_diagnosis... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_diagnostico2,nombre_tipo2,id_diagnostico1 FROM tipo_diagnostico2 INTO OUTFILE '${ruta}Subtype_of_diagnosis.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Diagnosis... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Diagnosis... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_diagnostico,nombre_diagnostico,descripcion,keywords,cie10 FROM tipo_diagnostico INTO OUTFILE '${ruta}Diagnosis.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Subdiagnosis... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Subdiagnosis... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id,nombre,descripcion,cie9,cie10,status,patologia_id FROM subpatologia INTO OUTFILE '${ruta}Subdiagnosis.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Relation_SD_Diagnosis... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Relation_SD_Diagnosis... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT tipo_diagnosticorelacion.id_relacion,tipo_diagnostico2.id_diagnostico2,tipo_diagnosticorelacion.id_diagnostico FROM tipo_diagnosticorelacion,tipo_diagnostico2 WHERE tipo_diagnosticorelacion.id_diagnostico2=tipo_diagnostico2.id INTO OUTFILE '${ruta}Relation_SD_Diagnosis.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Relation_SD_TS2... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Relation_SD_TS2... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT subclase_diagnostico.id_subdia,subclase_diagnostico.prioridad,tipo_diagnostico2.id_diagnostico2,subclase_nivel2.id_subclase2 FROM subclase_diagnostico,tipo_diagnostico2,subclase_nivel2 WHERE subclase_diagnostico.id_diagnostico2=tipo_diagnostico2.id AND subclase_diagnostico.id_subclase=subclase_nivel2.sc2_id INTO OUTFILE '${ruta}Relation_SD_TS2.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

######################################################   MEDICAMENTOS   ###########################################################
echo "Volcado de datos para la tabla Active_ingredient... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Active_ingredient... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT prigrup_id,prigrup_nombre FROM principio_grupo INTO OUTFILE '${ruta}Active_ingredient.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Active_ingredient_Therapeutic_class... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Active_ingredient_Therapeutic_class... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_principio,nombre_principio,dmd,pri_grupo FROM principio_activo INTO OUTFILE '${ruta}Active_ingredient_Therapeutic_class.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Relation_TS3_AITC... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Relation_TS3_AITC... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT principio_subclase.id_prisub,principio_subclase.prisub_prio,principio_subclase.id_principio,subclase_nivel3.id_subclase3 FROM principio_subclase,subclase_nivel3 WHERE principio_subclase.id_subclase3=subclase_nivel3.sc3_id INTO OUTFILE '${ruta}Relation_TS3_AITC.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Dosage... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Dosage... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id,nombre,dosis,mp_sexo,vehiculo,id_principio FROM principio_con_dosis INTO OUTFILE '${ruta}Dosage.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Dosage_form_group... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Dosage_form_group... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT mgrupo_id,mgrupo_nombre FROM medicamento_grupo INTO OUTFILE '${ruta}Dosage_form_group.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Dosage_form... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Dosage_form... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT mdad_id,mdad_nombre,mdad_grupo FROM medicamento_adm INTO OUTFILE '${ruta}Dosage_form.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Pharmaceutical_company... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Pharmaceutical_company... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_laboratorio,nombre_laboratorio,direccion_laboratorio,telefono_laboratorio,img_presentacion FROM laboratorio INTO OUTFILE '${ruta}Pharmaceutical_company.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Drug_brand... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Drug_brand... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT magr_id,magr_nombre FROM marca_grupo INTO OUTFILE '${ruta}Drug_brand.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Medication... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Medication... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT medicamento.id_medicamento,medicamento.nombre_medicamento,medicamento_presentacion.keywords,medicamento_presentacion.indicaciones,medicamento_presentacion.contraindicaciones,medicamento_presentacion.posologia,medicamento_presentacion.reacciones_adversas,medicamento.id_grupo FROM medicamento,medicamento_presentacion WHERE medicamento_presentacion.id_medicamento=medicamento.id_medicamento GROUP BY medicamento.id_medicamento INTO OUTFILE '${ruta}Medication.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Drug_presentation... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Drug_presentation... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_presentacion,nombre_presentacion,unidades,mp_dosis,dmd_presentacion,fmd,mp_precio,mp_sexo,img_presentacion,tipo_medicamento,id_laboratorio,id_medicamento,principio_con_dosis,forma_adm FROM medicamento_presentacion INTO OUTFILE '${ruta}Drug_presentation.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

###############################################   CLIENTES/PACIENTES/FARMACIAS ####################################################
echo "Volcado de datos para la tabla Pharmacy_chain... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Pharmacy_chain... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id_cadena,nombre_cadena FROM farmacia_cadena INTO OUTFILE '${ruta}Pharmacy_chain.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Pharmacy... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Pharmacy... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT id,nombre,razon_social,rif,direccion,telefono,logo,estado,callcenter_propio,web,cadena FROM audit_cliente_farmacia INTO OUTFILE '${ruta}Pharmacy.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Country... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Country... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT pais_id,pais_nombre FROM pais INTO OUTFILE '${ruta}Country.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Type_of_id_patient... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Type_of_id_patient... $(date +"%Y-%m-%d  %T")">>"$logfile"
echo -e "\"cedula\"\r">>"${ruta}Type_of_id_patient.txt"
echo -e "\"pasaporte\"\r">>"${ruta}Type_of_id_patient.txt"

echo "Volcado de datos para la tabla Patient_data... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Patient_data... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT paciente_ci,paciente_nombre,paciente_apellido,paciente_sexo,paciente_birthdate FROM audit_paciente GROUP BY paciente_ci INTO OUTFILE '${ruta}Patient_data.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Id_patient... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Id_patient... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT paciente_id,paciente_ci FROM audit_paciente INTO OUTFILE '${ruta}Id_patient.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Insurer... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Insurer... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT acli_id,acli_desc,acli_tipo,logo FROM audit_cliente INTO OUTFILE '${ruta}Insurer.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Collective... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Collective... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT acol_id,acol_cliente FROM audit_colectivo INTO OUTFILE '${ruta}Collective.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Policy... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Policy... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT audit_colectivo.acol_id,audit_colectivo.acol_id FROM audit_colectivo UNION SELECT poliza_aon.idmovitem,audit_paciente.paciente_colectivo FROM poliza_aon,afiliado_aon,audit_paciente WHERE poliza_aon.afiliado=afiliado_aon.id AND afiliado_aon.paciente=audit_paciente.paciente_id GROUP BY poliza_aon.idmovitem INTO OUTFILE '${ruta}Policy.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Plan... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Plan... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT audit_colectivo.acol_id,audit_colectivo.acol_desc,audit_colectivo.acol_id FROM audit_colectivo UNION SELECT poliza_aon.idplan,poliza_aon.descripcion_plan,poliza_aon.idmovitem FROM poliza_aon GROUP BY poliza_aon.idplan INTO OUTFILE '${ruta}Plan.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

# echo "Volcado de datos para la tabla Affiliation... $(date +"%Y-%m-%d  %T")"
# echo "Volcado de datos para la tabla Affiliation... $(date +"%Y-%m-%d  %T")">>"$logfile"
# read -ra pacientes <<< $(mysql $sql_args "SELECT paciente_id FROM audit_paciente")
# for p in "${pacientes[@]}"; do
# 	read -ra poliza <<< $(mysql $sql_args "SELECT afiliado_aon.afiliado,poliza_aon.idplan FROM afiliado_aon,poliza_aon WHERE poliza_aon.afiliado = afiliado_aon.id AND afiliado_aon.paciente=$p")
# 	if [ "${poliza[0]}" = "" ]; then
# 		read aux <<< $(mysql $sql_args "SELECT paciente_colectivo FROM audit_paciente WHERE paciente_id=$p")
# 		echo -e "\"A$p\"|$aux|$p\r">>"${ruta}Affiliation.txt"

# 	else
# 		echo -e "${poliza[0]}|${poliza[1]}|$p\r">>"${ruta}Affiliation.txt"
# 	fi
# done
echo "Volcado de datos para la tabla Affiliation... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Affiliation... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT afiliado_aon.afiliado,poliza_aon.idplan,audit_paciente.paciente_id FROM audit_paciente INNER JOIN afiliado_aon ON afiliado_aon.paciente=audit_paciente.paciente_id INNER JOIN poliza_aon ON poliza_aon.afiliado = afiliado_aon.id GROUP BY afiliado_aon.afiliado INTO OUTFILE '${ruta}AffiliationAon.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT audit_paciente.paciente_id,audit_paciente.paciente_colectivo,audit_paciente.paciente_id FROM audit_paciente WHERE audit_paciente.paciente_id NOT IN (SELECT audit_paciente.paciente_id FROM audit_paciente INNER JOIN afiliado_aon ON afiliado_aon.paciente=audit_paciente.paciente_id INNER JOIN poliza_aon ON poliza_aon.afiliado = afiliado_aon.id) INTO OUTFILE '${ruta}AffiliationNotAon.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# Agregar prefijo A para los que no pertenecen a Aon
sed -i 's/^/A/g' "${ruta}AffiliationNotAon.txt"
# Unir las dos consultas en un solo archivo
cat "${ruta}AffiliationAon.txt" "${ruta}AffiliationNotAon.txt" > "${ruta}Affiliation.txt"


#########################################################   SOLICITUDES   #########################################################
# echo "Volcado de datos para la tabla Case... $(date +"%Y-%m-%d  %T")"
# echo "Volcado de datos para la tabla Case... $(date +"%Y-%m-%d  %T")">>"$logfile"
# read -ra pacientes <<< $(mysql $sql_args "SELECT paciente_id FROM audit_paciente")
# for p in "${pacientes[@]}"; do
# 	read -ra poliza <<< $(mysql $sql_args "SELECT afiliado_aon.afiliado,poliza_aon.fecha_vencimiento FROM afiliado_aon,poliza_aon WHERE poliza_aon.afiliado = afiliado_aon.id AND afiliado_aon.paciente=$p")
# 	if [ "${poliza[0]}" = "" ]; then
		# echo -e "$p|\N|\"A$p\"\r">>"${ruta}Case.txt"
# 	else
# 		echo -e "$p|${poliza[1]}|${poliza[0]}\r">>"${ruta}Case.txt"
# 	fi
# done
echo "Volcado de datos para la tabla Case... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Case... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT audit_paciente.paciente_id,poliza_aon.fecha_vencimiento,afiliado_aon.afiliado,poliza_aon.parentesco,poliza_aon.consumo,poliza_aon.cobertura FROM audit_paciente INNER JOIN afiliado_aon ON afiliado_aon.paciente=audit_paciente.paciente_id INNER JOIN poliza_aon ON poliza_aon.afiliado = afiliado_aon.id GROUP BY afiliado_aon.afiliado INTO OUTFILE '${ruta}CaseAon.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT audit_paciente.paciente_id,null,audit_paciente.paciente_id,null,null,null FROM audit_paciente WHERE audit_paciente.paciente_id NOT IN (SELECT audit_paciente.paciente_id FROM audit_paciente INNER JOIN afiliado_aon ON afiliado_aon.paciente=audit_paciente.paciente_id INNER JOIN poliza_aon ON poliza_aon.afiliado = afiliado_aon.id) INTO OUTFILE '${ruta}CaseNotAon.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# Agregar prefijo A para los Case que no pertenecen a Aon
sed -i 's/\N|/\N|A/' "${ruta}CaseNotAon.txt"
# Unir las dos consultas en un solo archivo
cat "${ruta}CaseAon.txt" "${ruta}CaseNotAon.txt" > "${ruta}Case.txt"

echo "Volcado de datos para la tabla Status... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Status... $(date +"%Y-%m-%d  %T")">>"$logfile"
echo -e "0|\"Incompleta\"\r">>"${ruta}Status.txt"
echo -e "1|\"Finalizada\"\r">>"${ruta}Status.txt"
echo -e "2|\"En Espera\"\r">>"${ruta}Status.txt"
echo -e "3|\"Anulada\"\r">>"${ruta}Status.txt"

echo "Volcado de datos para la tabla Type_of_request... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Type_of_request... $(date +"%Y-%m-%d  %T")">>"$logfile"
echo -e "1|\"Orden\"\r">>"${ruta}Type_of_request.txt"
echo -e "2|\"Orden de Farmacia\"\r">>"${ruta}Type_of_request.txt"
echo -e "3|\"Reembolso\"\r">>"${ruta}Type_of_request.txt"

echo "Volcado de datos para la tabla Request... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Request... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT ac_id,ac_status,ac_fecha,ac_paciente,ac_edad,ac_tipoedad,ac_id,ac_aseguradora,ac_fecha,ac_fechacierre FROM audit_caso INTO OUTFILE '${ruta}RequestCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT orden_id,orden_status,orden_fecha,orden_paciente,orden_edad,orden_tipoedad,orden_id,orden_aseguradora,fecha_registro,orden_fechacierre FROM audit_orden INTO OUTFILE '${ruta}RequestOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo y tipo de solicitud
# sed -i 's/^/3|3/g' "${ruta}RequestCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}RequestCaso.txt"
sed -i 's/^/1|1/g' "${ruta}RequestOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}RequestOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}RequestCaso.txt" "${ruta}RequestOrden.txt" > "${ruta}Request.txt"
cp "${ruta}RequestOrden.txt" "${ruta}Request.txt"

echo "Volcado de datos para la tabla Medical_report... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Medical_report... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_informe.ai_id,audit_informe.ai_fecha,audit_informe.ai_vence,audit_caso.ac_paciente,audit_informe.ai_id FROM audit_informe,audit_caso WHERE audit_informe.ai_caso=audit_caso.ac_id INTO OUTFILE '${ruta}Medical_reportCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT audit_orden_informe.id_informe,audit_orden_informe.fecha_informe,audit_orden_informe.vence_informe,audit_orden.orden_paciente,audit_orden_informe.id_informe FROM audit_orden_informe,audit_orden WHERE audit_orden_informe.nro_orden=audit_orden.orden_id INTO OUTFILE '${ruta}Medical_reportOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
# sed -i 's/^/3/g' "${ruta}Medical_reportCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Medical_reportCaso.txt"
sed -i 's/^/1/g' "${ruta}Medical_reportOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}Medical_reportOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}Medical_reportCaso.txt" "${ruta}Medical_reportOrden.txt" > "${ruta}Medical_report.txt"
cp "${ruta}Medical_reportOrden.txt" "${ruta}Medical_report.txt"

echo "Volcado de datos para la tabla Relation_MR_Request... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Relation_MR_Request... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT ai_id,ai_caso,ai_id FROM audit_informe INTO OUTFILE '${ruta}Relation_MR_RequestCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT id_informe,nro_orden,id_informe FROM audit_orden_informe INTO OUTFILE '${ruta}Relation_MR_RequestOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
# sed -i 's/^/3/g' "${ruta}Relation_MR_RequestCaso.txt"
# sed -i 's/|/|3/g' "${ruta}Relation_MR_RequestCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Relation_MR_RequestCaso.txt"
sed -i 's/^/1/g' "${ruta}Relation_MR_RequestOrden.txt"
sed -i 's/|/|1/g' "${ruta}Relation_MR_RequestOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}Relation_MR_RequestOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}Relation_MR_RequestCaso.txt" "${ruta}Relation_MR_RequestOrden.txt" > "${ruta}Relation_MR_Request.txt"
cp "${ruta}Relation_MR_RequestOrden.txt" "${ruta}Relation_MR_Request.txt"

echo "Volcado de datos para la tabla Diagnostic... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Diagnostic... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT apat_patologia,apat_id,apat_informe FROM audit_patologia INTO OUTFILE '${ruta}DiagnosticCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT patologia,id_orden_patologia,informe FROM audit_orden_patologia INTO OUTFILE '${ruta}DiagnosticOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
# sed -i 's/|/|3/g' "${ruta}DiagnosticCaso.txt"
sed -i 's/|/|1/g' "${ruta}DiagnosticOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}DiagnosticCaso.txt" "${ruta}DiagnosticOrden.txt" > "${ruta}Diagnostic.txt"
cp "${ruta}DiagnosticOrden.txt" "${ruta}Diagnostic.txt"

echo "Volcado de datos para la tabla Subdiagnostic... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Subdiagnostic... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT subpatologia,id,diagnostico FROM subdiagnostico INTO OUTFILE '${ruta}SubdiagnosticOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
sed -i 's/|/|1/g' "${ruta}SubdiagnosticOrden.txt"
cp "${ruta}SubdiagnosticOrden.txt" "${ruta}Subdiagnostic.txt"

echo "Volcado de datos para la tabla Prescribed_drug... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Prescribed_drug... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_medicamento.amed_id,audit_informe.ai_id,audit_medicamento.amed_cantidad,audit_medicamento.amed_presentacion FROM audit_medicamento LEFT JOIN audit_informe ON audit_informe.ai_id=audit_medicamento.amed_informe INTO OUTFILE '${ruta}Prescribed_drugCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT omed_id,omed_informe,omed_cantidad,omed_presentacion FROM audit_orden_med INTO OUTFILE '${ruta}Prescribed_drugOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
# sed -i 's/^/3/g' "${ruta}Prescribed_drugCaso.txt"
# sed -i 's/|/|3/' "${ruta}Prescribed_drugCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Prescribed_drugCaso.txt"
# sed -i 's/3\\N/\\N/g' "${ruta}Prescribed_drugCaso.txt"
sed -i 's/^/1/g' "${ruta}Prescribed_drugOrden.txt"
sed -i 's/|/|1/' "${ruta}Prescribed_drugOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}Prescribed_drugOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}Prescribed_drugCaso.txt" "${ruta}Prescribed_drugOrden.txt" > "${ruta}Prescribed_drug.txt"
cp "${ruta}Prescribed_drugOrden.txt" "${ruta}Prescribed_drug.txt"

echo "Volcado de datos para la tabla Requested_medication... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Requested_medication... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_medfacturado.afmd_id,audit_facturas.afac_caso,audit_medfacturado.afmd_cantidad,audit_medfacturado.afmd_precio,audit_medfacturado.afmd_presentacion FROM audit_medfacturado,audit_facturas WHERE audit_medfacturado.afmd_factura=audit_facturas.afac_id INTO OUTFILE '${ruta}Requested_medicationCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT audit_orden_med.omed_id,audit_orden_relpatologia.aorel_orden,audit_orden_med.omed_cantidad,audit_orden_med.precio_promedio,audit_orden_med.omed_presentacion FROM audit_orden_med LEFT JOIN audit_orden_relpatologia ON audit_orden_relpatologia.aorel_medicamento=audit_orden_med.omed_id GROUP BY audit_orden_med.omed_id INTO OUTFILE '${ruta}Requested_medicationOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
# sed -i 's/^/3/g' "${ruta}Requested_medicationCaso.txt"
# sed -i 's/|/|3/' "${ruta}Requested_medicationCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Requested_medicationCaso.txt"
sed -i 's/^/1/g' "${ruta}Requested_medicationOrden.txt"
sed -i 's/|/|1/' "${ruta}Requested_medicationOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}Requested_medicationOrden.txt"
sed -i 's/1\\N/\\N/g' "${ruta}Requested_medicationOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}Requested_medicationCaso.txt" "${ruta}Requested_medicationOrden.txt" > "${ruta}Requested_medication.txt"
cp "${ruta}Requested_medicationOrden.txt" "${ruta}Requested_medication.txt"

echo "Volcado de datos para la tabla Related_medication... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Related_medication... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_relmedicamentos.arel_id,audit_medfacturado.afmd_id,audit_medicamento.amed_id FROM audit_relmedicamentos LEFT JOIN audit_medfacturado ON audit_medfacturado.afmd_id=audit_relmedicamentos.arel_facturado LEFT JOIN audit_medicamento ON audit_medicamento.amed_id=audit_relmedicamentos.arel_medicado INTO OUTFILE '${ruta}Related_medicationCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT omed_id,omed_id,omed_id FROM audit_orden_med INTO OUTFILE '${ruta}Related_medicationOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# # Agregar prefijo
# sed -i 's/^/3/g' "${ruta}Related_medicationCaso.txt"
# sed -i 's/|/|3/g' "${ruta}Related_medicationCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Related_medicationCaso.txt"
# sed -i 's/3\\N/\\N/g' "${ruta}Related_medicationCaso.txt"
sed -i 's/^/1/g' "${ruta}Related_medicationOrden.txt"
sed -i 's/|/|1/g' "${ruta}Related_medicationOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}Related_medicationOrden.txt"
# # Unir las dos consultas en un solo archivo
# cat "${ruta}Related_medicationCaso.txt" "${ruta}Related_medicationOrden.txt" > "${ruta}Related_medication.txt"
cp "${ruta}Related_medicationOrden.txt" "${ruta}Related_medication.txt"

echo "Volcado de datos para la tabla Related_diagnosis... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Related_diagnosis... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_relpatologia.arlp_id,audit_patologia.apat_id,audit_relmedicamentos.arel_id FROM audit_relpatologia,audit_patologia,audit_relmedicamentos WHERE audit_patologia.apat_patologia=audit_relpatologia.arlp_idpatologia AND audit_patologia.apat_informe=audit_relpatologia.informe AND audit_relmedicamentos.arel_medicado=audit_relpatologia.arlp_idmedicamento AND audit_relmedicamentos.arel_caso=audit_relpatologia.arlp_caso GROUP BY audit_relpatologia.arlp_id INTO OUTFILE '${ruta}Related_diagnosisCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT audit_orden_relpatologia.aorel_id,audit_orden_patologia.id_orden_patologia,audit_orden_relpatologia.aorel_medicamento FROM audit_orden_relpatologia LEFT JOIN audit_orden_patologia ON audit_orden_patologia.patologia=audit_orden_relpatologia.aorel_patologia AND audit_orden_patologia.informe=audit_orden_relpatologia.informe INTO OUTFILE '${ruta}Related_diagnosisOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# Agregar prefijo
# sed -i 's/^/3/g' "${ruta}Related_diagnosisCaso.txt"
# sed -i 's/|/|3/g' "${ruta}Related_diagnosisCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Related_diagnosisCaso.txt"
# sed -i 's/3\\N/\\N/g' "${ruta}Related_diagnosisCaso.txt"
sed -i 's/^/1/g' "${ruta}Related_diagnosisOrden.txt"
sed -i 's/|/|1/g' "${ruta}Related_diagnosisOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}Related_diagnosisOrden.txt"
sed -i 's/1\\N/\\N/g' "${ruta}Related_diagnosisOrden.txt"
# Unir las dos consultas en un solo archivo
# cat "${ruta}Related_diagnosisCaso.txt" "${ruta}Related_diagnosisOrden.txt" > "${ruta}Related_diagnosis.txt"
cp "${ruta}Related_diagnosisOrden.txt" "${ruta}Related_diagnosis.txt"

### TABLA DE CASO
# echo "Volcado de datos para la tabla Invoice... $(date +"%Y-%m-%d  %T")"
# echo "Volcado de datos para la tabla Invoice... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_facturas.afac_caso,audit_facturas.afac_id,audit_facturas.afac_date,audit_facturas.nro_factura,SUM(audit_medfacturado.afmd_cantidad*audit_medfacturado.afmd_precio) FROM audit_facturas LEFT JOIN audit_medfacturado ON audit_medfacturado.afmd_factura=audit_facturas.afac_id GROUP BY audit_facturas.afac_id INTO OUTFILE '${ruta}InvoiceCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# mysql $sql_args "SELECT orden,id,fecha_factura,nro_factura,total FROM factura_farmacia INTO OUTFILE '${ruta}InvoiceOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# Agregar prefijo
# sed -i 's/^/3/g' "${ruta}InvoiceCaso.txt"
# sed -i 's/|/|3/' "${ruta}InvoiceCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}InvoiceCaso.txt"
# sed -i 's/^/1/g' "${ruta}InvoiceOrden.txt"
# sed -i 's/|/|1/' "${ruta}InvoiceOrden.txt"
# sed -i 's/\r\n/\r/g' "${ruta}InvoiceOrden.txt"
# Unir las dos consultas en un solo archivo
# cat "${ruta}InvoiceCaso.txt" "${ruta}InvoiceOrden.txt" > "${ruta}Invoice.txt"

### TABLA DE CASO
# echo "Volcado de datos para la tabla Dispensed_drug... $(date +"%Y-%m-%d  %T")"
# echo "Volcado de datos para la tabla Dispensed_drug... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT afmd_precio,afmd_id,afmd_id,afmd_factura FROM audit_medfacturado INTO OUTFILE '${ruta}Dispensed_drugCaso.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# mysql $sql_args "SELECT precio,id,id,factura FROM farmacia_medfacturado INTO OUTFILE '${ruta}Dispensed_drugOrden.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# Agregar prefijo
# sed -i 's/|/|3/g' "${ruta}Dispensed_drugCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Dispensed_drugCaso.txt"
# sed -i 's/|/|1/g' "${ruta}Dispensed_drugOrden.txt"
# sed -i 's/\r\n/\r/g' "${ruta}Dispensed_drugOrden.txt"
# Unir las dos consultas en un solo archivo
# cat "${ruta}Dispensed_drugCaso.txt" "${ruta}Dispensed_drugOrden.txt" > "${ruta}Dispensed_drug.txt"

echo "Volcado de datos para la tabla Irregularity_description... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Irregularity_description... $(date +"%Y-%m-%d  %T")">>"$logfile"
mysql $sql_args "SELECT adev_id,adev_desc FROM audit_desviacion INTO OUTFILE '${ruta}Irregularity_description.txt' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"

echo "Volcado de datos para la tabla Irregularity_prescribed_drug... $(date +"%Y-%m-%d  %T")"
echo "Volcado de datos para la tabla Irregularity_prescribed_drug... $(date +"%Y-%m-%d  %T")">>"$logfile"
# mysql $sql_args "SELECT audit_casodesviacion.acdv_id,audit_casodesviacion.acdv_rel,audit_relpatologia.arlp_id,audit_casodesviacion.acdv_caso,NOT audit_casodesviacion.habilitado,audit_casodesviacion.is_bold,true,(audit_medfacturado.afmd_cantidad-audit_casodesviacion.acdv_cantidad),audit_casodesviacion.acdv_desviacion FROM audit_casodesviacion,audit_relmedicamentos,audit_relpatologia,audit_medfacturado,audit_medicamento WHERE audit_relmedicamentos.arel_id=audit_casodesviacion.acdv_rel AND audit_medfacturado.afmd_id=audit_relmedicamentos.arel_facturado AND audit_relpatologia.arlp_caso=audit_casodesviacion.acdv_caso AND audit_relpatologia.arlp_idmedicamento=audit_medicamento.amed_id AND audit_medicamento.amed_presentacion=audit_medfacturado.afmd_presentacion INTO OUTFILE '${ruta}IrregularityCaso.txt' FIELDS TERMINATED BY '!' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
mysql $sql_args "SELECT audit_ordendesviacion.aodv_id,audit_orden_med.omed_id,audit_orden_relpatologia.aorel_id,audit_ordendesviacion.aodv_orden,NOT audit_ordendesviacion.habilitado,audit_ordendesviacion.is_bold,audit_ordendesviacion.activa,(audit_orden_med.omed_cantidad-audit_ordendesviacion.aodv_cantidad),audit_ordendesviacion.aodv_desviacion FROM audit_ordendesviacion,audit_orden_med,audit_orden_relpatologia WHERE audit_orden_med.omed_presentacion=audit_ordendesviacion.aodv_medicamento AND audit_orden_med.omed_id=audit_orden_relpatologia.aorel_medicamento AND audit_orden_relpatologia.aorel_orden=audit_ordendesviacion.aodv_orden GROUP BY audit_ordendesviacion.aodv_id INTO OUTFILE '${ruta}IrregularityOrden.txt' FIELDS TERMINATED BY '!' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'"
# Agregar prefijo
# sed -i 's/^/3/g' "${ruta}IrregularityCaso.txt"
# sed -i 's/|/|3/' "${ruta}IrregularityCaso.txt"
# sed -i 's/\r\n/\r/g' "${ruta}IrregularityCaso.txt"
sed -i 's/^/1/g' "${ruta}IrregularityOrden.txt"
sed -i 's/!/|1/' "${ruta}IrregularityOrden.txt"
sed -i 's/!/|1/' "${ruta}IrregularityOrden.txt"
sed -i 's/!/|1/' "${ruta}IrregularityOrden.txt"
# sed -i 's/!1!/|True!/' "${ruta}IrregularityOrden.txt"
# sed -i 's/!0!/|False!/' "${ruta}IrregularityOrden.txt"
# sed -i 's/!1!/|True!/' "${ruta}IrregularityOrden.txt"
# sed -i 's/!0!/|False!/' "${ruta}IrregularityOrden.txt"
# sed -i 's/!1!/|True|/' "${ruta}IrregularityOrden.txt"
# sed -i 's/!0!/|False|/' "${ruta}IrregularityOrden.txt"
sed -i 's/!/|/g' "${ruta}IrregularityOrden.txt"
sed -i 's/\r\n/\r/g' "${ruta}IrregularityOrden.txt"
# Unir las dos consultas en un solo archivo
# cat "${ruta}IrregularityCaso.txt" "${ruta}IrregularityOrden.txt" > "${ruta}Irregularity_prescribed_drug.txt"
cp "${ruta}IrregularityOrden.txt" "${ruta}Irregularity_prescribed_drug.txt"

### AQUI TERMINA EL VOLCADO DE LOS DATOS DE MYSQL A ARCHIVOS TXT
echo -e "Termina volcado de datos"
echo $(date +"%Y-%m-%d  %T")
echo -e "Termina volcado de datos" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"

##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################

### AQUI EDITA LOS ARCHIVOS CON PROBLEMAS EN LOS DATOS
echo -e "Empieza a editar los archivos con problemas en los datos"
echo $(date +"%Y-%m-%d  %T")
echo -e "Empieza a editar los archivos con problemas en los datos" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"

echo -e "Edita Drug_presentation... $(date +"%Y-%m-%d  %T")"
echo -e "Edita Drug_presentation... $(date +"%Y-%m-%d  %T")" >>"$logfile"
sed -i 's/SUN"/SUN "/g' "${ruta}Drug_presentation.txt"

# Esto se hace porque humanitas no contiene los datos de Farma
echo -e "Edita Patient_data... $(date +"%Y-%m-%d  %T")"
echo -e "Edita Patient_data... $(date +"%Y-%m-%d  %T")" >>"$logfile"
sed -i 's/"0000-00-00"/\\N/g' "${ruta}Patient_data.txt"
sed -i 's/\r/|\\N|\\N|\\N|\\N|\\N\r/g' "${ruta}Patient_data.txt"

# Esto se hace porque humanitas no contiene los datos de Farma
echo -e "Edita Id_patient... $(date +"%Y-%m-%d  %T")"
echo -e "Edita Id_patient... $(date +"%Y-%m-%d  %T")" >>"$logfile"
sed -i 's/\r/|"cedula"|\\N\r/g' "${ruta}Id_patient.txt"

echo -e "Edita Medical_report... $(date +"%Y-%m-%d  %T")"
echo -e "Edita Medical_report... $(date +"%Y-%m-%d  %T")" >>"$logfile"
sed -i 's/"0000-00-00"/\\N/g' "${ruta}Medical_report.txt"

### Tabla de caso
# echo -e "Edita Invoice... $(date +"%Y-%m-%d  %T")"
# echo -e "Edita Invoice... $(date +"%Y-%m-%d  %T")" >>"$logfile"
# sed -i 's/"0000-00-00"/\\N/g' "${ruta}Invoice.txt"


#### PARAMETROS DE CONEXION A BD POSTGRES
echo "Configurando conexion psql"
psql_host="/var/run/postgresql"
psql_usuario="jenelin"
psql_password=""
psql_database="PRX"
psql_port="5433"
psql_args="$psql_database -p $psql_port -h $psql_host "

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
Relation_MR_Request
Medical_report
Request
Type_of_request
Status
Case
Affiliation
Plan
Policy
Collective
Insurer
Id_patient
Patient_data
Type_of_id_patient
Country
Pharmacy
Pharmacy_chain
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
Pharmacy_chain
Pharmacy
Country
Type_of_id_patient
Patient_data
Id_patient
Insurer
Collective
Policy
Plan
Affiliation
Case
Status
Type_of_request
Request
Medical_report
Relation_MR_Request
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
				if [ "${tabla}" = "Diagnostic" ]; then
					echo -e "COPY \"${tabla}\" (diagnosis_code,code,mr_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
					echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
				else
					if [ "${tabla}" = "Subdiagnostic" ]; then
						echo -e "COPY \"${tabla}\" (subdiagnosis_code,code,diagnostic_code) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
						echo "$(wc -l "${ruta}${tabla}.txt" | cut -d ' ' -f 1) datos" >>"$logfile"
					else
						if [ "${tabla}" = "Prescribed_drug" ]; then
							echo -e "COPY \"${tabla}\" (identity,mr_identity,quantity,dp_identity) FROM '${ruta}${tabla}.txt' DELIMITER AS '|' NULL AS '\N' CSV ESCAPE AS '\r';" >>"$psqlfile"
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
	psql $psql_args -f "$psqlfile"
	# psql "PRX" -p 5433 -h /var/run/postgresql -f "$psqlfile"
done

### AQUI TERMINA LA CARGA DE LOS DATOS DE ARCHIVOS TXT A POSTGRES
echo -e "Termina carga de datos"
echo $(date +"%Y-%m-%d  %T")
echo -e "Termina carga de datos" >>"$logfile"
echo $(date +"%Y-%m-%d  %T") >>"$logfile"

### Guarda los archivos.txt y el log en carpeta con la hora de la migracion
mkdir "${ruta}migracion$(date +"%Y-%m-%d")"
mkdir "${ruta}migracion$(date +"%Y-%m-%d")/$(date +"%T")"
mv "${ruta}"*.txt "${ruta}"*.log "${ruta}migracion$(date +"%Y-%m-%d")/$(date +"%T")/"
rm "${ruta}"*.sql