/****************************************************************************************************
          Author:            Lewis Schmidt
          Date Written:      7/28/2015
          Source File Name:  <File name in CCLUSERDIR>
          Object Name:       <Name in CCLQUERY>
          Request #:         <Optional>
 
          Product:           <Product report addresses>
          Product Team:      Pharmnet/Discern/Medication Process
          HNA Version:       500
          CCL Version:       2015.x.x.x
 
          Program Purpose:   provide details on the alert and trigger
 
          Tables Read:       eks_dlg_event, long_text, eks_dlg, eks_alert_esc_hist person, prsnl, orders
          Tables Updated:    none
 
          Executing From:    <Explorer Menu, ad hoc>
 
          Special Notes:     <Optional>
****************************************************************************************************
****************************************************************************************************
***********************************   MODIFICATION CONTROL LOG   ***********************************
****************************************************************************************************
Mod		Date		Engineer			Comment
----------------------------------------------------------------------------------------------------
000		8/13/2015	lewis schmidt		Initial idea is to pull in enough data to measure impact and understand why the rule fired.
 
****************************************************************************************************/


SELECT

/* Rule Information */
Program_Rule = edlg.program_name
, userloggedin_id = e.dlg_name
, userloggedin_name = user.NAME_FULL_FORMATTED
, userloggedin = user.username
;, e.encntr_id
, e.override_reason_cd
; override_reason = uar_get_code_display(e.override_reason_cd)
, e.trigger_entity_name
, e.trigger_order_id



/* long_text lt 
, Free_Text_Override = lt.long_text
;, lt.long_text_id
, Discern_Alert = lt2.long_text
Long text fubars it at this time because in non-prod there aren't any discern alerts

*/

/* Patient info */
, patient_id = e.person_id
, patient = p.NAME_FULL_FORMATTED
, p.PERSON_TYPE_CD 

/* clinical information */
;, weight
;, serum_creatinine
;, Body_Surface_Area
;, primary_Diagnosis
;, Secondary_diagnosis
;, Adjusted_body_weight

/* Order */
, order_id = e.trigger_order_id
;, powerplan_order = yes or no
;, favorites_order = yes or no
, o.order_mnemonic
, order_synonym_type = ocs.catalog_type_cd
, order_order_cki = ocs.cki ; will help determine if there is a 1:N Orders:Groupers relationship
, order_therapeutic class = ocs.dcp_clin_cat_cd
, order_sentence = 
, order_route
, order_PRN_reason
, order_comment

/* eks_alert_esc_hist eaeh */
, eaeh.ack_comment
, eaeh.alert_source
, eaeh.failure_reason
, eaeh.msg_long_text_id
, eaeh.msg_type_cd
, eaeh.subject_prefix_text
, eaeh.subject_text

FROM

	eks_dlg_event   e
	, long_text   lt
	, long_text   lt2
	, orders  o
	, eks_dlg   edlg
	, eks_alert_esc_hist eaeh
	, person   p
	, prsnl   user
	, order_catalog oc
	, order_synonym_catalog ocs
	, drc_group_reltn dgr ; to show what the groupers are associated with the order

plan e
;	where e.dlg_name = PHA_EKM!PHA_DRC_PROD_PC_ALL

Join lt 
	where lt.long_text_id = e.long_text_id
	and lt.active_ind = 1

Join lt2
	where lt2.long_text_id = e.alert_long_text_id
	
Join edlg
	where edlg.dlg_name = e.dlg_name  /*Unique identifier for an Insight.*/

join eaeh
	where eaeh.alert_id = e.alert_long_text_id

;join p
;	where p.person_id = e.person_id
;	and p.active_ind = 1

;join user
;	where user.person_id = e.dlg_prsnl_id
;	and user.active_ind = 1

;join o
; where o.order_id = e.trigger_order_id
; 

;join oc
;	where oc.catalog_cd = o.catalog_cd
;	and 

;join ocs
; 	where ocs.catalog_cd = oc.catalog_cd

;join dgr
;	where drg.drug_synonym_id = oc.cki ; The Multum synonym id is the number portion 
;of MUL.ORD-SYN!##### 

WITH  time = 120