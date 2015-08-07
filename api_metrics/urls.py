from django.conf.urls import patterns, include, url
from django.conf import settings
from tastypie.api import Api
from metrics import views

from django.contrib import admin
admin.autodiscover()



from metrics.api_metrics import RequestResource, TypeResource, TherapeuticResource, TherapeuticSubclassResource, TherapeuticSubclassResource2, TherapeuticSubclassResource3, TypeDiagnosisResource, SubtypeDiagnosisResource, DiagnosisResource, SubdiagnosisResource,  ActiveIngredientResource, ActiveIngredientTherapeuticResource, DosageResource, DosageGroupResource, DosageFormResource, PharmaceuticalCompanyResource, DrugBrandResource, MedicationResource, DrugPresentationResource, TypePatientResource, PatientDataResource, IdPatientResource, InsurerResource, CollectiveResource, PolicyResource, PlanResource, AffiliationResource, CaseResource, StatusResource, MedicalReportResource, PrescribedDrugResource, RequestedMedicationResource, RelatedMedicationResource, RelatedDiagnosisResource, InvoiceResource, DispensedDrugResource, IrregularityDescriptionResource, BusinessRuleResource, IrregularityPrescribedDrugResource, IrregularityDispensedDrugResource, SavingsResource, SubstitutesResource, PresentationReqViewResource, PresentationPrescViewResource, MedicationReqViewResource, MedicationPrescViewResource, DrugBrandReqViewResource, DrugBrandPrescViewResource, PharmaceuticalReqViewResource, ActIngredientReqViewResource, TherapeuticClassViewResource, TherapeuticSubViewResource, TherapeuticSub2ViewResource, TherapeuticSub3ViewResource, DiagnosisViewResource, Diagnosis1ViewResource, Diagnosis2ViewResource, PharmacyResource, PharmacyChainResource, DemographicsSexResource, DemographicsAgeResource, SpecialityResource, IrregularityResource, PosologyResource, OtherDiagnosisResource, OtherPrescriptionsMedResource, OtherPrescriptionsDrugResource, OtherDispensationsMedResource, OtherDispensationsDrugResource, SavingsTotalResource

#
v1_api = Api(api_name='v1')
v1_api.register(RequestResource())
v1_api.register(TypeResource())
v1_api.register(TherapeuticResource())
v1_api.register(TherapeuticSubclassResource())
v1_api.register(TherapeuticSubclassResource2())
v1_api.register(TherapeuticSubclassResource3())
v1_api.register(TypeDiagnosisResource())
v1_api.register(SubtypeDiagnosisResource())
v1_api.register(DiagnosisResource())
v1_api.register(SubdiagnosisResource())
v1_api.register(ActiveIngredientResource())
v1_api.register(ActiveIngredientTherapeuticResource())
v1_api.register(DosageResource())
v1_api.register(DosageGroupResource())
v1_api.register(DosageFormResource())
v1_api.register(PharmaceuticalCompanyResource())
v1_api.register(DrugBrandResource())
v1_api.register(MedicationResource())
v1_api.register(DrugPresentationResource())
v1_api.register(TypePatientResource())
v1_api.register(PatientDataResource())
v1_api.register(IdPatientResource())
v1_api.register(InsurerResource())
v1_api.register(CollectiveResource())
v1_api.register(PolicyResource())
v1_api.register(PlanResource())
v1_api.register(AffiliationResource())
v1_api.register(CaseResource())
v1_api.register(StatusResource())
v1_api.register(MedicalReportResource())
v1_api.register(PrescribedDrugResource())
v1_api.register(RequestedMedicationResource())
v1_api.register(RelatedMedicationResource())
v1_api.register(RelatedDiagnosisResource())
v1_api.register(InvoiceResource())
v1_api.register(DispensedDrugResource())
v1_api.register(IrregularityDescriptionResource())
v1_api.register(BusinessRuleResource())
v1_api.register(IrregularityPrescribedDrugResource())
v1_api.register(IrregularityDispensedDrugResource())
v1_api.register(SavingsResource())
v1_api.register(SubstitutesResource())
v1_api.register(PresentationReqViewResource())
v1_api.register(PresentationPrescViewResource())
v1_api.register(MedicationReqViewResource())
v1_api.register(MedicationPrescViewResource())
v1_api.register(DrugBrandReqViewResource())
v1_api.register(DrugBrandPrescViewResource())
v1_api.register(PharmaceuticalReqViewResource())
v1_api.register(ActIngredientReqViewResource())
v1_api.register(TherapeuticClassViewResource())
v1_api.register(TherapeuticSubViewResource())
v1_api.register(TherapeuticSub2ViewResource())
v1_api.register(TherapeuticSub3ViewResource())
v1_api.register(DiagnosisViewResource())
v1_api.register(Diagnosis1ViewResource())
v1_api.register(Diagnosis2ViewResource())
v1_api.register(DemographicsSexResource())
v1_api.register(DemographicsAgeResource())
v1_api.register(PharmacyResource())
v1_api.register(PharmacyChainResource())
v1_api.register(SpecialityResource())
v1_api.register(IrregularityResource())
v1_api.register(PosologyResource())
v1_api.register(OtherDiagnosisResource())
v1_api.register(OtherPrescriptionsMedResource())
v1_api.register(OtherPrescriptionsDrugResource())
v1_api.register(OtherDispensationsMedResource())
v1_api.register(OtherDispensationsDrugResource())
v1_api.register(SavingsTotalResource())

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'API.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),$
  	(r'^$', views.index),
    (r'^admin/', include(admin.site.urls)),
    (r'^api/', include(v1_api.urls)),

#    (r'^api/', include(request_resource.urls)),
)

