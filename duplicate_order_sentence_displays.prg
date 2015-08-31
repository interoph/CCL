/*duplicate order sentence displays*/
 
 
select 
   primary_synonym=oc.primary_mnemonic, 
   order_cat_cd = oc.CATALOG_CD,
   synonym_id = ocs.SYNONYM_ID,
   mnemonic_type_disp= uar_get_code_display(ocs.mnemonic_type_cd),
   mnemonic = ocs.MNEMONIC,
   os.order_sentence_display_line,
   os.usage_flag,
   ord_sent_count = count(os.order_sentence_id)
from
   order_catalog oc,
   order_catalog_synonym ocs,
   ord_cat_sent_r ocsr,
   order_sentence os
where oc.catalog_type_cd = 2516.00 ;Pharm
  and ocs.CATALOG_CD = oc.CATALOG_CD
  and ocs.active_ind = 1
  and ocsr.synonym_id = ocs.synonym_id
  and os.order_sentence_id = ocsr.order_sentence_id
group by  
   oc.primary_mnemonic, 
   oc.CATALOG_CD,
   ocs.SYNONYM_ID,
   ocs.mnemonic_type_cd,
   ocs.MNEMONIC,
   os.order_sentence_display_line,
   os.usage_flag
having count(os.order_sentence_id) > 1