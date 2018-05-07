
/* 
creator:  Lewis Schmidt
purpose:  to provide detailed understanding of what a user sees in a discern alert
changelog:  draft
*/

SELECT

Program_Rule = edlg.program_name
, e.dlg_prsnl_id
, e.encntr_id
;, e.long_text_id
, e.alert_long_text_id
, e.override_reason_cd
, e.person_id
, e.trigger_entity_name
, e.trigger_order_id

/* long_text lt */
, Free_Text_Override = lt.long_text
;	, lt.long_text_id
, Discern_Alert = lt2.long_text

/*eks_alert_esc_hist eaeh */
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
	, eks_dlg   edlg
	, eks_alert_esc_hist eaeh
	;, person   p
	;, prsnl   user

plan e
	Where E.DLG_DT_TM between cnvtdate(12012017) and cnvtdate(12072017)
        and e.dlg_name = "MUL_MED!DRUGDUP"
	
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
;	where user.person_id = e.dlg_prsnl_idwith ,

WITH  time = 120
