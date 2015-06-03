
; Purpose:  display pharmacy orders, ordersentence with a PRN Reason of Fever(CS4005) and Order Comment
; thanks to scott hoch for help writing this query
; by lewis schmidt
select ;distinct  distinct will create a CLOB ora error https://connect.ucern.com/message/308733#308733
 primary_syn = substring(1, 45, oc.primary_mnemonic) ; primary order
, OCS_MNEMONIC = substring(1, 50, ocs.mnemonic) ; order
, mnemonic_type = uar_get_code_display(ocs.mnemonic_type_cd); mnemonic type
, os.order_sentence_display_line; OS displayed
, PRN_REASON = cv.display
;, os.order_sentence_id;
, lt.long_text
;, os.usage_flag;
;, ofm.oe_field_meaning;
;, oe_detail_value = osd.oe_field_display_value
;, osd.oe_field_display_value
 
 
from
	order_catalog oc
	, order_catalog_synonym ocs
	, ord_cat_sent_r ocsr
	, order_sentence os
	, LONG_TEXT   lt
	, order_sentence_detail osd
	, oe_field_meaning ofm
    , code_value cv
    , order_sentence_detail osd2
 
 
Plan oc
	where oc.catalog_type_cd = 2516.00
;	and oc.catalog_cd = 643041.00 ; acetaminophen
	and oc.active_ind = 1
	and oc.activity_type_cd = 705.00; pharmacy
 
Join ocs
	where oc.catalog_cd = ocs.catalog_cd
	and ocs.synonym_id > 0
 
Join ocsr
	where ocs.synonym_id = ocsr.synonym_id
 
Join os
	where os.order_sentence_id = ocsr.order_sentence_id
;	and cnvtlower(os.order_sentence_display_line) = VALUE(cnvtlower(CONCAT("*","FEVER","*"))) ; remove b/c the cs4005 is now incuded
 
Join lt
    where os.ord_comment_long_text_id = lt.long_text_id
;    and lt.active_ind = 1  ; if you want to filter out those ordersentences WITH order comments
 
Join osd
	where osd.order_sentence_id = os.order_sentence_id
	and osd.oe_field_value = 1
 
Join ofm
	where ofm.oe_field_meaning_id = osd.oe_field_meaning_id
	and ofm.oe_field_meaning = "SCH/PRN"
 
Join cv
	where cv.code_set = 4005
	and cv.display = "fever"
	or cv.display = "pain/fever"
	or cv.display = "fever/discompfort"
	or cv.display = "mild pain or fever"
 
join osd2                               ;
        where osd2.order_sentence_id=os.order_sentence_id
        and osd2.default_parent_entity_name = "CODE_VALUE"
        and osd2.default_parent_entity_id = cv.code_value
 
order by oc.primary_mnemonic, ocs.mnemonic, ocsr.display_seq, os.order_sentence_id, osd.sequence
 