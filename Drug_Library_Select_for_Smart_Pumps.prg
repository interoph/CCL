/* Drug Library Select for Smart Pumps */

select distinct 

	oc.catalog_cd
	, oc.primary_mnemonic
	, oc.cki

from 
	mltm_ndc_core_description ndc, 
	mltm_product_route r,
	mltm_ndc_main_drug_code mmdc, 
	mltm_mmdc_name_map mm, 
	mltm_drug_name_map n,

order_catalog oc
	where r.route_code in 
							( 2420, 2409, 2427 ) 
	and ndc.main_multum_drug_code = mmdc.main_multum_drug_code
	and mmdc.principal_route_code = r.route_code
	and mm.main_multum_drug_code = ndc.main_multum_drug_code
	and n.drug_synonym_id = mm.drug_synonym_id
	and (substring(9, 15, oc.cki) = n.drug_identifier
	or oc.cki = concat("MUL.MMDC!", trim(cnvtstring(mm.main_multum_drug_code )))
	or oc.cki = "MUL.MMDC!*") 

order by oc.primary_mnemonic go