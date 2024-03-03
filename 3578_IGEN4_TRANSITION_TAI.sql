--IGEN4 
-------
WITH tbl_IGEN4_SALARY AS
(
SELECT to_char(b.DATE_COB,'yyyy-mm') MONTH_CHECK, b.CUSTOMER_ID, sum(b.CR_AMT_LCY) AS Thu_Nhap
FROM TCIMPORT.FACT_ACCT_ENTRY b 
INNER JOIN TCIMPORT.FACT_FUND_TRANS a 
ON REGEXP_SUBSTR(a.FT_NO,'[^;]+',1,1) = b.TRANSACTION_NO
WHERE b.PRODUCT_CATEGORY in (1038, 1070)
AND a.DR_ACCOUNT LIKE 'VND175001%'
AND (a.DATE_COB BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -3), 'MM') /*lay ngay dau thang CUA 3 THANG TRUOC*/
AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), -1)))
AND (b.DATE_COB BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -3), 'MM') /*lay ngay dau thang CUA 3 THANG TRUOC*/
AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), -1)))/*ngay cuoi thang truoc*/
GROUP BY b.CUSTOMER_ID, to_char(b.DATE_COB,'yyyy-mm')
)
, tn_final AS 
(
SELECT DISTINCT a.CUSTOMER_ID,
                Max(CASE WHEN a.MONTH_CHECK = to_char(add_months(SYSDATE,-1),'yyyy-mm') THEN a.Thu_Nhap ELSE 0 end) THU_NHAP_T1, 
                Max(CASE WHEN a.MONTH_CHECK = to_char(add_months(SYSDATE,-2),'yyyy-mm') THEN a.Thu_Nhap ELSE 0 end) THU_NHAP_T2,
                Max(CASE WHEN a.MONTH_CHECK = to_char(add_months(SYSDATE,-3),'yyyy-mm') THEN a.Thu_Nhap ELSE 0 end) THU_NHAP_T3
FROM tbl_IGEN4_SALARY a
GROUP BY a.CUSTOMER_ID
HAVING Max(CASE WHEN a.MONTH_CHECK = to_char(add_months(SYSDATE,-1),'yyyy-mm') THEN a.Thu_Nhap ELSE 0 end) > 0 
AND Max(CASE WHEN a.MONTH_CHECK = to_char(add_months(SYSDATE,-2),'yyyy-mm') THEN a.Thu_Nhap ELSE 0 end) > 0
AND Max(CASE WHEN a.MONTH_CHECK = to_char(add_months(SYSDATE,-3),'yyyy-mm') THEN a.Thu_Nhap ELSE 0 end) > 0
)
,cust_branch AS 
(
SELECT a.CUSTOMER_ID
from TCIMPORT.DIM_CUSTOMER a 
WHERE MANAGING_BRANCH <> 'VN0010133'
AND SECTOR_CODE = 1001
AND NATIONALITY ='VN'
AND LEGAL_DOC_NAME IN ('CCCD', 'CMND')
AND ((months_between(SYSDATE/*ALTER*/,a.DATE_OF_BIRTH)/12) BETWEEN 18 AND (64+(11/12)))
AND ((months_between(sysdate/*ALTER*/, a.CIF_OPEN_DATE) >= 3) OR (a.CIF_OPEN_DATE IS NULL))
AND (trunc(sysdate/*ALTER*/) BETWEEN a.EFF_FROM_DATE  AND nvl(a.EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
)
,Final_data AS 
(
SELECT  a.CUSTOMER_ID,
b.THU_NHAP_T1, b.THU_NHAP_T2, b.THU_NHAP_T3,
(b.THU_NHAP_T1 + b.THU_NHAP_T2 + b.THU_NHAP_T3)/3 AS THU_NHAP_TB
FROM CUST_branch a 
INNER JOIN tn_final b ON a.CUSTOMER_ID = b.CUSTOMER_ID
)
SELECT trunc(sysdate/*ALTER*/) Data_date, CUSTOMER_ID, 
THU_NHAP_T3 SD_BQ_T3,  THU_NHAP_T2 SD_BQ_T2,
 THU_NHAP_T1 SD_BQ_T1,
'IGEN4' AS Report 
FROM Final_data 
WHERE THU_NHAP_TB >= 10000000
AND THU_NHAP_T3 IS NOT NULL 
AND THU_NHAP_T2 IS NOT NULL
AND THU_NHAP_T1 IS NOT NULL;