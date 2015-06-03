/*
Author:  Lewis Schmidt
Purpose:  To help identify Orders with mismatched or inappropriately set Therapeutic Class
Changelog:  initial draft
*/
 
 
drop program lew43709_findorderclas go
create program lew43709_findorderclas
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Search ORDERs (generic)" = ""         ;* *
 
with OUTDEV, PRIMARY
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare Pharmacy_VAR = f8 with Protect
set Pharmacy_VAR = uar_get_code_by("description",6000, "Pharmacy")
/*
call echo(Pharmacy_VAR) go
2516.000000
*/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
SELECT INTO $OUTDEV
	OrderCatalog_mnemonic_name =ocs.mnemonic_key_cap
	, Order_type = uar_get_code_display(ocs.mnemonic_type_cd)
	, OrderCatalog_Therapeutic_Category = A.LONG_DESCRIPTION
    , Multum_Therapeutic_Category = M.CATEGORY_NAME
	, oef.oe_format_name

 
FROM
 
	ALT_SEL_CAT   A
	, alt_sel_list   ASL
	, order_catalog_synonym   OCS
	, person   P
	, order_catalog   oc
	, order_entry_format_parent   oef
	, MLTM_DRUG_CATEGORIES   M
	, MLTM_CATEGORY_DRUG_XREF   MC
 
Plan A where A.AHFS_IND = 1
Join ASL where asl.alt_sel_category_id = a.alt_sel_category_id
Join ocs where asl.synonym_id = ocs.synonym_id
and ocs.active_ind =1
and ocs.catalog_type_cd = Pharmacy_VAR
Join P where p.person_id = ocs.updt_id
Join OC where oc.catalog_cd = ocs.catalog_cd
 and oc.active_ind = 1
 and cnvtlower(oc.primary_mnemonic)= VALUE(cnvtlower(CONCAT("*",$PRIMARY,"*")))
Join OEF where oef.oe_format_id = oc.oe_format_id
JOIN MC WHERE substring(9,15,(OC.cki)) = MC.drug_identifier
JOIN M WHERE MC.MULTUM_CATEGORY_ID = M.MULTUM_CATEGORY_ID ; therapeutic Class
;and cnvtlower(m.category_name)= VALUE(cnvtlower(CONCAT("*",$Therapeutic,"*")))
;and cnvtlower(CONCAT("*",$Therapeutic,"*")))= VALUE(cnvtlower(m.category_name))
 
ORDER BY
	OC.Description
	, OCS.mnemonic_key_cap
 
WITH SEPARATOR=" ", FORMAT, time = 300
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 