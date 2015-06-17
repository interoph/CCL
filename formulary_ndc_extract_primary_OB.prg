/***********************************************************************
Purpose:  to show the inner and outer mapping of NDC's on products active in a pharmacy formulary
          to show the multum inner and outer NDC mapping
          A cross walk between products active and Multum NDC
          a framework for checking product build against multum based on NDC
 		  Display orangebook data

Issues:	Inner NDC from cerner's row count is ~ 2500 rows.. so this query is poorly qualified as a good method for formulary audits.

 
 
Date:  6/8/2015
by Lewis Schmidt
 
*************************************************************************/
 
select distinct
 
; Products Built and active in the pharmacy formulary (F)
     F_O_NDC = m.value
	, F_I_NDC = mi.value
	, F_DESCRIPTION = mi2.value
	, F_Brand_NAME = mi3.value
	, F_ITEM_ID = m.item_id
	
; PharmNET Primary NDC in the inpatient product formulary manager (IPFM)
	, Primary_NDC = evaluate(mfoi.sequence, 1,"Primary", "")	
 
; Multum (M) Products corresponding to the products in the active formulary
;	, MD.main_multum_drug_code  ;dnum
 	, M_OUTER_NDC = md.ndc_code
	, M_INNER_NDC = mnoi.inner_ndc_code
;	, MOB_Inner_NDC = mnicd.inner_ndc_code  ; 2469 inner ndc's
	, M_BRAND = mb.brand_description
	, M_STRENGTH = mp.product_strength_description
	, M_DOSEFORM = mdf.dose_form_description
	, M_INNERPACKAGESIZE = md.inner_package_size
	, M_INNER_UNIT = mu.unit_abbr
	, M_MFG = mns.source_desc
	, M_OBSOLETE_DATE = md.obsolete_date
 
; Multum OrangeBook Reference (MOB)
	, MOB_AB = mnob.orange_book_desc_ab
	, MOB_Description = mnob.orange_book_description
	, MOB_InnerNDC = mnicd.ndc_formatted
	, MOB_InnerNDCPackage_DESC = mnicd.inner_package_desc_code
	, MOB_InnerNDCNsize = mnicd.inner_size
 
from
 
;active pharmacy formulary item tables
	 med_identifier m                              ; Outer NDC, 12901 total of outer NDC's
	, med_identifier mi                             ; Inner NDC, 901 total of inner ndc's
	, med_identifier mi2                            ; Description
	, med_identifier mi3							; Brand Name
	
; PharmNET Primary NDC in the inpatient product formulary manager (IPFM)
	, med_identifier   mi5							; primary indicator (manufacturer)
	, med_def_flex   mdff							; primary indicator
	, med_flex_object_idx   mfoi					; primary indicator
 
;multum tables
	, mltm_ndc_core_description   md				;  
	, mltm_ndc_brand_name         mb				;  
	, mltm_mmdc_name_map          mmn				;
	, mltm_drug_name              mdn				;
	, mltm_dose_form              mdf				;
	, mltm_product_strength       mp				;
	, mltm_ndc_main_drug_code     mnm				;
	, mltm_units                  mu				;
	, mltm_ndc_source             mns				;
	, mltm_ndc_outer_inner_map    mnoi				;
 
;multum tables, Orange book equivalency
	, mltm_ndc_inner_core_desc 	  mnicd				;
	, mltm_ndc_orange_book  	  mnob				;
 
plan m ; 				med_identifier -> F_O_NDC
	where m.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000,"NDC"))
	;and m.item_id= 669469.00 ; acetaminophen 325 mg Tab (USEFUL FOR TESTING)  669469.00
 		and m.active_ind = 1
 
join mi; 				med_identifier -> F_I_NDC
	where mi.med_product_id = outerjoin(m.med_product_id)
		and mi.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING", 11000,"INNER_NDC")))
 
join mi2; 				med_identifier -> F_DESCRIPTION
	where m.med_product_id= mi2.med_product_id
		and mi2.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING", 11000,"DESC")))
 
join mi3;				med_identifier -> F_Brand_Name
	where mi3.med_product_id = outerjoin(m.med_product_id)
	 and mi3.MED_IDENTIFIER_TYPE_CD = value(uar_get_code_by("MEANING", 11000,"BRAND_NAME"))
	 
	 ;PharmNET Tables Primary NDC
join mdff
	where mdff.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
;	and mdff.item_id = 669469.00 ; item id for acetaminophen 325 mg tablet
 
join mfoi  ;  ; primary NDC/Manufactuerer
 	where mfoi.med_def_flex_id = mdff.med_def_flex_id
 		and mfoi.parent_entity_name = "MED_PRODUCT"
 		and mfoi.parent_entity_id = mi.med_product_id
 
join mi5
	where mi5.med_product_id = outerjoin(m.med_product_id)
 		and mi5.med_product_id = mfoi.parent_entity_id
 		;and mi5.med_product_id > 0.0
	 	and mi5.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "NDC"))
		;and mi5.item_id = 669469.00
 
;multum tables
join md ; 				mltm_ndc_core_description -> M_OUTER_NDC, M_INNERPACKAGESIZE, M_OBSOLETE_DATE
	where md.ndc_formatted = outerjoin(m.value)
 
join mb ; 				mltm_ndc_brand_name -> M_BRAND
	where mb.brand_code = outerjoin(md.brand_code)

join mmn
	where mmn.main_multum_drug_code = outerjoin(MD.main_multum_drug_code)  ; dnum match
		and mmn.function_id = 16 ;generic name
 
join mdn
	where mdn.drug_synonym_id = outerjoin(mmn.drug_synonym_id)
 
join mnm
	where mnm.main_multum_drug_code = outerjoin(md.main_multum_drug_code)  ; dnum match
 
join mdf ; 				mltm_dose_form -> M_DOSEFORM
	where mdf.dose_form_code = MNM.dose_form_code
 
join mp  ; 				mltm_product_strength -> M_STRENGTH
	where mp.product_strength_code = MNM.product_strength_code
 
join mu ; 				mltm_units -> M_INNER_UNIT
	where mu.unit_ID =  outerjoin(MD.inner_package_desc_code)
 
join mns ;
	where mns.source_id = outerjoin(md.source_id)
 
join mnoi ;				mltm_ndc_outer_inner_map ->  M_OUTER2_NDC, M_INNER_NDC
	where mnoi.outer_ndc_code = outerjoin(md.ndc_code)
 
; inner to outer ndc map
 
;multum orange book equivalency
join mnicd  ; MLTM_NDC_INNER_CORE_DESC, why is there ~2500 innerndc's
	where mnicd.ndc_formatted = outerjoin(md.ndc_formatted)
	
;Join MNICD ; 			MLTM_NDC_INNER_CORE_DESC  
;	where (select med.value from med_identifier med where med.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000,"INNER_NDC"))) = outerjoin(mnicd.inner_ndc_code) 	
 
Join MNOB ;				MLTM_NDC_ORANGE_BOOK
	Where mnob.orange_book_id = outerjoin(mnicd.orange_book_id)
	
	
 
order by
	MD.main_multum_drug_code
	,mi2.value
	,m.value
	,mi.value
 
 
with time = 30
