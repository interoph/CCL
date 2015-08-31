/****************************************************************************************************
          Author:            <Full name>
          Date Written:      <Date>
          Source File Name:  <File name in CCLUSERDIR>
          Object Name:       <Name in CCLQUERY>
          Request #:         <Optional>
 
          Product:           <Product report addresses>
          Product Team:      <IS or Cerner Product Team>
          HNA Version:       500
          CCL Version:       2008.05.1.36
 
          Program Purpose:   <Description of the Program>
 
          Tables Read:       <List the tables accessed>
          Tables Updated:    <List any tables updated>
 
          Executing From:    <Backend, Ops, Explorer Menu, etc.>
 
          Special Notes:     <Optional>
****************************************************************************************************
****************************************************************************************************
***********************************   MODIFICATION CONTROL LOG   ***********************************
****************************************************************************************************
Mod		Date		Engineer			Comment
----------------------------------------------------------------------------------------------------
000		<Date>		<Full name>			Initial Release
 
****************************************************************************************************/
 
drop program pha_rpt_mthtn_drc_oacnt go
create program pha_rpt_mthtn_drc_oacnt
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
 
with OUTDEV, SDATE, EDATE
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare TCNT = i4 with NoConstant(0),Protect
declare ACNT = i4 with NoConstant(0),Protect
declare PCNT = i4 with NoConstant(0),Protect
declare EDATENUM = i4 with NoConstant(CNVTDATE(CNVTDATETIME($EDATE))),Protect
declare SDATENUM = i4 with NoConstant(CNVTDATE(CNVTDATETIME($SDATE))),Protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
SELECT INTO $OUTDEV
	Date1 = format (OBS.ACTION_DT_NBR,"@SHORTDATE4YR"),
	Adult = ACNT ,
	Pediatric = PCNT ,
	Total = TCNT
FROM
	PHA_ORD_ACT_OBS_ST   OBS
 
WHERE (OBS.ACTION_DT_TM >= CNVTDATETIME($SDATE))
	AND (OBS.ACTION_DT_TM <= CNVTDATETIME($EDATE))
	AND (OBS.ACTION_TYPE_CD IN (1166.00,1167.00))
	AND (obs.ord_pers_fac_cd+0 IN (5268.00,5023.00,5270.00,5042.00,1686560449.00,718469992.00,5022.00,5026.00,23553239.00))
	AND OBS.ORDER_ID+0 > 0.00
	AND OBS.PHARM_TYPE_CD IN (0.00, VALUE(UAR_GET_CODE_BY('MEANING', 4500, 'INPATIENT')))
 
ORDER BY
	OBS.ACTION_DT_NBR,
	OBS.ORD_PERS_AGE_YEARS
 
HEAD PAGE
	COL 00, "Date",
	COL 15, "Adult",
	COL 35, "Pediatric"
	COL 55, "Total"
	ROW + 1
	COL 00, "==========",
	COL 15, "==========",
	COL 35, "==========",
	COL 55, "=========="
HEAD OBS.ACTION_DT_NBR
	ACNT = 0,
	PCNT = 0,
	TCNT = 0,
	ROW + 1
DETAIL
	IF (OBS.ORD_PERS_AGE_YEARS < 18)
		PCNT = PCNT + 1
	ELSE
		ACNT = ACNT + 1
	ENDIF
	TCNT = TCNT + 1
 
FOOT OBS.ACTION_DT_NBR
	COL 00, Date1,
	COL 15, Adult,
	COL 35, Pediatric,
	COL 55, Total
 
FOOT REPORT
	ROW + 3,
	COL 00, "Total Count: ",
	COL 15, CURQUAL
 
WITH FORMAT
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
