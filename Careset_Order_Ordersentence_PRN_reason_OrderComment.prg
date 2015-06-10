; Careset in a Favorite Folder, find a prn comment in a careset
; it appears like there are many duplicates but that is because each order comment is unique.
; by lewis schmidt, 7/2/2015
 
Select

; Products Built and active in the pharmacy formulary
	Order_Folder_Description = a.long_description
	, CareSet_Description = ocs.mnemonic
	, CareSet_description_2 = uar_get_code_display(ocs.catalog_cd)
	, order_sentence_clinical_display = os.order_sentence_display_line
	, PRN_REASON = cv.display
	, L.long_text

; Multum Products corresponding to the products in the active formulary
 	Outer_NDC = md.ndc_code
	, outer2_ndc = mnoi.outer_ndc_code
	, Inner_NDC = mnoi.inner_ndc_code
	, M.drug_name
	, brand = MB.BRAND_DESCRIPTION
	, STRENGTH = MP.product_strength_description
	, DOSEFORM = MDF.dose_form_description
	, MD.inner_PACKAGE_SIZE
	, INNER_UNIT = MU.unit_abbr
	, MFG = MNS.source_desc
	, md.obsolete_date
 
from

;active pharmacy formulary item tables
	alt_sel_cat a
	, alt_sel_list asl
	, order_catalog_synonym ocs
	, order_sentence os ; os.order_sentence_id = asl.order_sentence_id  DISPLAY O
	, cs_component csc ; stores components that make up a Careset or Careplan DISPLAY OS IN A CARESET
	, LONG_TEXT L ; DISPLAY COMMENTS
	, order_sentence_detail osd ; TIE INTO PRN REASON
	, oe_field_meaning ofm ; IDENTIFY OS WITH PRN/SCH
	, code_value cv ; TIE INTO THE SPECIFIC PRN REASON
	, order_sentence_detail osd2 ; WORK AROUND TO FILTER PRN REASON

;mutum tables
	MLTM_NDC_CORE_DESCRIPTION   MD
	, MLTM_NDC_BRAND_NAME   MB
	, MLTM_MMDC_NAME_MAP   MMN
	, MLTM_DRUG_NAME   M
	, MLTM_DOSE_FORM   MDF
	, MLTM_PRODUCT_STRENGTH   MP
	, MLTM_NDC_MAIN_DRUG_CODE   MNM
	, MLTM_UNITS   MU
	, MLTM_NDC_SOURCE   MNS
	,MLTM_NDC_OUTER_INNER_MAP   MNOI

Plan a
 
Join asl
	where asl.alt_sel_category_id = a.alt_sel_category_id
 
Join ocs
	where ocs.synonym_id = asl.synonym_id
		and ocs.mnemonic_type_cd = 2583.00 ; primary
		and ocs.active_ind = 1
		and ocs.orderable_type_flag = 6.00 ; careset flag
		and ocs.catalog_type_cd ; KIND OF CARESET

		;;;;;;;;;optional Facility Specific Codevalues for Careset;;;;;;;;;
		
			in(	409375569.00 ; Medication CareSet
				,432851836.00 ; ED Medication CareSet
				,2515.00) ; Patient Care
 
		and ocs.activity_type_cd ; CORRESPONDING CARESET TYPE PER ACTIVITY TYPE

		;;;;;;;;;optional Facility Specific codevalue;;;;;;;;;;

			in(	351952132.00 ; Care Set Physician
				,341712425.00 ; activity type, Non Kardex
				,341711998.00 ; Admission Orders
				,49215316.00 ; Peds/Neo
				,650592.00 ; Patient Care
				,667.00 ; not found????  it's listed in queries based on the catalog type
				                         ;but not in the table when directly asked
				,410369405.00 ; Surgery Acuity Level
				,669.00 ; AFC DEFAULT BILL ITEM ADD-ON
				,432853357.00 ; ED Care Set Physician
				,703.00) ; Patient Activity
 
Join csc ; TABLE WHERE ALL CARESET CONTENT IS REFERENCED
	where csc.catalog_cd = ocs.catalog_cd
 
Join os ;
    where os.order_sentence_id = csc.order_sentence_id
 
Join osd
	where osd.order_sentence_id = os.order_sentence_id
		and osd.oe_field_value = 1
 
Join ofm
	where ofm.oe_field_meaning_id = osd.oe_field_meaning_id
		and ofm.oe_field_meaning = "SCH/PRN"
 
 ;;;please note:  each long_text id is unique and although the content is the same... we are pulling text id's not content.
JOIN L
	where L.long_text_id = os.ord_comment_long_text_id
		and L.active_ind = 1
 
;;;;;;;;;;;;;Join CV_to_ORDERSENTENCE_DETAIL;;;;;;;;
 
Join cv
	where cv.code_set = 4005
		and cv.display = "fever"
			or cv.display = "pain/fever"
			or cv.display = "fever/discomfort"
			or cv.display = "mild pain or fever"
 
Join osd2
    where osd2.order_sentence_id = os.order_sentence_id
    	and osd2.default_parent_entity_name = "CODE_VALUE"
    	and osd2.default_parent_entity_id = cv.code_value
 
order by
        a.long_description, ocs.catalog_cd
 
with time = 300