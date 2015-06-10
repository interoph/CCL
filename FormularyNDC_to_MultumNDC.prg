;purpose:  to show the inner and outer mapping of NDC's on products active in a pharmacy formulary
;          to show the multum inner and outer NDC mapping
;          A cross walk between products active and Multum NDC
;          a framework for checking product build against multum based on NDC
 
; Date:  6/8/2015
; by Lewis Schmidt
 
select Distinct
 
; Products Built and active in the pharmacy formulary (F)
	F_O_NDC = m.value
	,F_I_NDC = mi.value
	,F_description = mi2.value                    ; not working
	,F_Item_ID = m.item_id
 
; Multum (M) Products corresponding to the products in the active formulary
 	,M_Outer_NDC = md.ndc_code
	, M_outer2_ndc = mnoi.outer_ndc_code
	, M_Inner_NDC = mnoi.inner_ndc_code
	, M_Brand = MB.BRAND_DESCRIPTION
	, M_STRENGTH = MP.product_strength_description
	, M_DOSEFORM = MDF.dose_form_description
	, M_InnerPackageSize = MD.inner_PACKAGE_SIZE
	, M_INNER_UNIT = MU.unit_abbr
	, M_MFG = MNS.source_desc
	, M_Obsolete_Date = md.obsolete_date
 
from
 
;active pharmacy formulary item tables
	med_identifier m                               ; Outer NDC
	,med_identifier mi                             ; Inner NDC
	,med_identifier mi2                            ; Description
 
;mutum tables
	, MLTM_NDC_CORE_DESCRIPTION   md
	, MLTM_NDC_BRAND_NAME         mb
	, MLTM_MMDC_NAME_MAP          MMN
	, MLTM_DRUG_NAME              MDN
	, MLTM_DOSE_FORM              MDF
	, MLTM_PRODUCT_STRENGTH       MP
	, MLTM_NDC_MAIN_DRUG_CODE     MNM
	, MLTM_UNITS                  MU
	, MLTM_NDC_SOURCE             MNS
	, MLTM_NDC_OUTER_INNER_MAP    MNOI
 
plan m
	where M.MED_IDENTIFIER_TYPE_CD = outerjoin(value(uar_get_code_by("MEANING", 11000,"NDC")))
	and m.item_id= 669469.00 ; acetaminophen 325 mg Tab
 
join mi
	where mi.med_product_id = outerjoin(m.med_product_id)
		and MI.MED_IDENTIFIER_TYPE_CD = outerjoin(value(uar_get_code_by("MEANING", 11000,"INNER_NDC")))
 
join mi2
	where m.med_product_id= outerjoin(mi2.med_product_id)
		and MI2.MED_IDENTIFIER_TYPE_CD = value(uar_get_code_by("MEANING", 11000,"DESC"))
 
;multum tables
Join MD ; MLTM_NDC_CORE_DESCRIPTION
	where md.ndc_formatted = outerjoin(m.value)
 
Join MB  ; MLTM_NDC_BRAND_NAME
	where MB.brand_code = MD.brand_code
 
Join MMN ; MLTM_MMDC_NAME_MAP
	where MMN.main_multum_drug_code = MD.main_multum_drug_code  ; dnum match
		AND mmn.function_id = 16 ;generic name
 
Join MDN ; MLTM_DRUG_NAME
	where MDN.drug_synonym_id = mmn.drug_synonym_id
 
Join MNM  ; MLTM_NDC_MAIN_DRUG_CODE
	where mnm.main_multum_drug_code = md.main_multum_drug_code  ; dnum match
 
Join MDF ; MLTM_DOSE_FORM
	where mdf.dose_form_code = MNM.dose_form_code
 
Join MP  ; MLTM_PRODUCT_STRENGTH
	where MP.product_strength_code = MNM.product_strength_code
 
Join MU
	where MU.unit_ID =  outerjoin(MD.inner_package_desc_code)
 
Join MNS
	where MNS.source_id = outerjoin(MD.source_id)
 
Join MNOI
	WHERE MNOI.outer_ndc_code = outerjoin(md.ndc_code)
 
;order by
;	,m.value
;	,mi.value
;	Form_description = mi2.value
 
with time = 30