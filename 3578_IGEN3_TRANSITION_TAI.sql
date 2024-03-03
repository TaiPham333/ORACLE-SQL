CREATE TABLE tbl_IGEN3_CON1 AS 
WITH omni1 as
(SELECT to_char(a.DATE_COB,'yyyy-mm-dd') AS date_cob,a.CUSTOMER_ID, 
sum(a.BALANCE_LCY_AMT) AS tktk,
count(a.CUSTOMER_ID) no_trans
FROM tcimport.fact_deposit a
WHERE (a.DATE_COB BETWEEN TRUNC(ADD_MONTHS(sysdate, -3), 'MM') /*lay ngay dau thang CUA 3 THANG TRUOC*/
AND LAST_DAY(ADD_MONTHS(TRUNC(sysdate), -1))) /*ngay cuoi thang truoc*/
AND a.CATEGORY_CODE IN 
(6603,6604,6605,6606,6601, 6602,6615,6618,
6704,6701,6702,6620,6661,6662,6663
,6664,6665,6666,6716,6650,21002)
GROUP BY a.CUSTOMER_ID, to_char(a.DATE_COB,'yyyy-mm-dd'))
, omni1_maxday_data AS 
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(no_trans) max_data 
FROM omni1  
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
, omni1_maxdate AS 
(SELECT data_date, max(max_data) max_date FROM omni1_maxday_data GROUP BY data_date)
, omni1_condition1 AS  
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(CUSTOMER_ID) count1
FROM omni1 WHERE tktk < 50000000 
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
, omni1_condition12 AS  
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(CUSTOMER_ID) count1
FROM omni1 WHERE tktk >= 50000000
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
,omni1_condition2 AS 
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(CUSTOMER_ID) count1
FROM omni1
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
, omni1_final_condition AS 
(SELECT a.CUSTOMER_ID,count(*) as count1
FROM omni1_condition1 a 
JOIN omni1_condition2 b ON a.CUSTOMER_ID = b.CUSTOMER_ID AND a.DATA_DATE = b.DATA_DATE
JOIN omni1_maxdate c ON a.data_date = c.data_date
WHERE ((a.count1 + c.max_date - b.count1)<11) 
GROUP BY a.CUSTOMER_ID)
, omni1_final_condition2 AS 
(SELECT a.CUSTOMER_ID, count(CUSTOMER_ID) count1 
FROM omni1_condition12 a 
JOIN omni1_maxdate c 
ON a.data_date = c.data_date
WHERE a.count1 = c.max_date
GROUP BY a.CUSTOMER_ID)
, omni1_final_condition3 AS 
(SELECT a.CUSTOMER_ID, count(CUSTOMER_ID) count1 
FROM omni1_condition12 a 
JOIN omni1_maxdate c 
ON a.data_date = c.data_date
WHERE a.count1 = c.max_date
GROUP BY a.CUSTOMER_ID
HAVING count(*)=3)
,omni1_final_condition4 AS 
(SELECT a.CUSTOMER_ID
FROM omni1_final_condition a WHERE a.count1=3)
, final_data3 AS 
(SELECT a.CUSTOMER_ID, (a.count1 + b.count1) AS tot_count
FROM omni1_final_condition a JOIN omni1_final_condition2 b
ON a.CUSTOMER_ID = b.CUSTOMER_ID
WHERE (a.count1 + b.count1) >= 3)
SELECT DISTINCT CUSTOMER_ID FROM 
(SELECT CUSTOMER_ID FROM FINAL_DATA3
UNION ALL 
SELECT CUSTOMER_ID FROM omni1_final_condition3
UNION ALL 
SELECT CUSTOMER_ID FROM omni1_final_condition4)
;

CREATE TABLE tbl_igen3_con2 AS
WITH omni2 AS 
(SELECT to_char(a.DATE_COB,'yyyy-mm-dd') AS date_cob,a.CUSTOMER_ID, 
sum(a.BALANCE_LCY_AMT) AS tktk,
count(a.CUSTOMER_ID) no_trans
FROM tcimport.fact_deposit a
WHERE (a.DATE_COB BETWEEN TRUNC(ADD_MONTHS(sysdate, -3), 'MM') /*lay ngay dau thang CUA 3 THANG TRUOC*/
AND LAST_DAY(ADD_MONTHS(TRUNC(sysdate), -1)))
AND a.CATEGORY_CODE IN 
(1001,1003,1004,1005,1006,1007,
1020,1021,1024,1025,1032,1034,
1035,1036,1038,1037,1057,
1058,1059,1072,1066,1070,1094,1071,1073)
GROUP BY a.CUSTOMER_ID, to_char(a.DATE_COB,'yyyy-mm-dd'))
, omni2_maxday_data AS 
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(no_trans) max_data 
FROM omni2  
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
, omni2_maxdate AS 
(SELECT data_date, max(max_data) max_date FROM omni2_maxday_data GROUP BY data_date)
, omni2_condition1 AS  
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(CUSTOMER_ID) count1
FROM omni2 WHERE tktk < 5000000 
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
, omni2_condition12 AS  
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(CUSTOMER_ID) count1
FROM omni2 WHERE tktk >= 5000000
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
,omni2_condition2 AS 
(SELECT to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm') data_date, CUSTOMER_ID, count(CUSTOMER_ID) count1
FROM omni2
GROUP BY CUSTOMER_ID, to_char(to_date(DATE_COB,'yyyy-mm-dd'),'yyyy-mm'))
, omni2_final_condition AS 
(SELECT a.CUSTOMER_ID, count(*) as count1
FROM omni2_condition1 a 
JOIN omni2_condition2 b ON a.CUSTOMER_ID = b.CUSTOMER_ID AND a.DATA_DATE = b.DATA_DATE
JOIN omni2_maxdate c ON a.data_date = c.data_date
WHERE ((a.count1 + c.max_date - b.count1)<11) 
GROUP BY a.CUSTOMER_ID)
, omni2_final_condition2 AS 
(SELECT a.CUSTOMER_ID, count(CUSTOMER_ID) count1 
FROM omni2_condition12 a 
JOIN omni2_maxdate c 
ON a.data_date = c.data_date
WHERE a.count1 = c.max_date
GROUP BY a.CUSTOMER_ID)
, omni2_final_condition3 AS 
(SELECT a.CUSTOMER_ID, count(CUSTOMER_ID) count1 
FROM omni2_condition12 a 
JOIN omni2_maxdate c 
ON a.data_date = c.data_date
WHERE a.count1 = c.max_date
GROUP BY a.CUSTOMER_ID
HAVING count(*)=3)
,omni2_final_condition4 AS 
(SELECT a.CUSTOMER_ID
FROM omni2_final_condition a WHERE a.count1=3)
, final_data3 AS 
(SELECT a.CUSTOMER_ID, (a.count1 + b.count1) AS tot_count
FROM omni2_final_condition a JOIN omni2_final_condition2 b
ON a.CUSTOMER_ID = b.CUSTOMER_ID
WHERE (a.count1 + b.count1) >= 3)
SELECT DISTINCT CUSTOMER_ID FROM 
(SELECT CUSTOMER_ID FROM FINAL_DATA3
UNION ALL 
SELECT CUSTOMER_ID FROM omni2_final_condition3
UNION ALL 
SELECT CUSTOMER_ID FROM omni2_final_condition4)
;
-----
--omni1 tableau
WITH omni1 AS
(SELECT DISTINCT a.CUSTOMER_ID AS MA_CIF
, a.MANAGING_BRANCH AS MA_CN
, b.BRANCH_NAME AS TEN_CN 
,a.CUSTOMER_NAME AS HO_TEN
, a.IDENTITY_NO AS ID_KHACH_HANG
, trunc(sysdate/*ALTER*/) as DATA_DATE
,floor((months_between(SYSDATE/*ALTER*/,a.DATE_OF_BIRTH)/12)) AS TUOI
, a.DATE_START_PRIO AS NGAY_HIEU_LUC_DINH_DANH
, a.DATE_END_PROMO AS NGAY_HET_HIEU_LUC_DINH_DANH
, a.SEGMENTATION AS PHAN_HANG_KHUT
, a.CRITERIA AS TIEU_CHI_DINH_DANH
, 'Tiền gửi có kỳ hạn' as LOAI_TIEN_GUI
, CASE
WHEN SEGMENTATION = 'SILVER' THEN 20000000
WHEN SEGMENTATION = 'GOLD' THEN 30000000
WHEN SEGMENTATION = 'DIAMOND' THEN 40000000
WHEN SEGMENTATION = 'DIAMOND ELITE' THEN 50000000
ELSE 0
END AS HM_CAP_THE_IGEN_OMNI_3
from tcimport.DIM_CUSTOMER a 
JOIN tcimport.DIM_BRANCH b 
ON a.MANAGING_BRANCH = b.BRANCH_CODE
WHERE 
a.MANAGING_BRANCH <> 'VN0010133'
AND a.SECTOR_CODE = 1001
AND a.NATIONALITY ='VN'
AND a.LEGAL_DOC_NAME IN ('CCCD', 'CMND')
AND ((months_between(SYSDATE/*ALTER*/,a.DATE_OF_BIRTH)/12) BETWEEN 18 AND (64+(11/12)))
AND ((months_between(sysdate/*ALTER*/, a.CIF_OPEN_DATE) >= 3) OR a.CIF_OPEN_DATE is NULL)
--
AND (trunc(sysdate/*ALTER*/) BETWEEN a.EFF_FROM_DATE  AND nvl(a.EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
AND (trunc(sysdate/*ALTER*/) BETWEEN b.EFF_FROM_DATE  AND nvl(b.EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
--
AND a.SEGMENTATION IN ('SILVER', 'GOLD', 'DIAMOND', 'DIAMOND ELITE')
AND (trunc(SYSDATE/*ALTER*/) BETWEEN a.DATE_START_PRIO AND trunc(a.DATE_END_PROMO-30))
AND a.CRITERIA in 
(
'Nhóm 1 - SDBQ FD 03 tháng',
'Nhóm 1 - Tổng số dư FD kỳ hạn 01 tháng'
)
AND a.CUSTOMER_ID IN
(SELECT CUSTOMER_ID FROM PPTTT.TBL_IGEN3_CON1))
, omni2 AS
(SELECT DISTINCT a.CUSTOMER_ID AS MA_CIF 
, a.MANAGING_BRANCH AS MA_CN
, b.BRANCH_NAME AS TEN_CN 
,a.CUSTOMER_NAME AS HO_TEN
, a.IDENTITY_NO AS ID_KHACH_HANG 
, trunc(sysdate/*ALTER*/) as DATA_DATE
,floor(months_between(SYSDATE/*ALTER*/,a.DATE_OF_BIRTH)/12) AS TUOI
, a.DATE_START_PRIO AS NGAY_HIEU_LUC_DINH_DANH
, a.DATE_END_PROMO AS NGAY_HET_HIEU_LUC_DINH_DANH
, a.SEGMENTATION AS PHAN_HANG_KHUT
, a.CRITERIA AS TIEU_CHI_DINH_DANH
, 'Tiền gửi không kỳ hạn' as LOAI_TIEN_GUI
, CASE
WHEN SEGMENTATION = 'SILVER' THEN 20000000
WHEN SEGMENTATION = 'GOLD' THEN 30000000
WHEN SEGMENTATION = 'DIAMOND' THEN 40000000
WHEN SEGMENTATION = 'DIAMOND ELITE' THEN 50000000
ELSE 0
END AS HM_CAP_THE_IGEN_OMNI_3
from tcimport.DIM_CUSTOMER a 
JOIN tcimport.DIM_BRANCH b 
ON a.MANAGING_BRANCH = b.BRANCH_CODE
WHERE 
a.MANAGING_BRANCH <> 'VN0010133'
AND a.SECTOR_CODE = 1001
AND a.NATIONALITY ='VN'
AND a.LEGAL_DOC_NAME IN ('CCCD', 'CMND')
AND ((months_between(SYSDATE/*ALTER*/,a.DATE_OF_BIRTH)/12) BETWEEN 18 AND (64+(11/12)))
AND ((months_between(sysdate/*ALTER*/, a.CIF_OPEN_DATE) >= 3) OR a.CIF_OPEN_DATE is NULL)
--
AND (trunc(sysdate/*ALTER*/) BETWEEN a.EFF_FROM_DATE  AND nvl(a.EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
AND (trunc(sysdate/*ALTER*/) BETWEEN b.EFF_FROM_DATE  AND nvl(b.EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
--
AND a.SEGMENTATION IN ('SILVER', 'GOLD', 'DIAMOND', 'DIAMOND ELITE')
AND (trunc(SYSDATE/*ALTER*/) BETWEEN a.DATE_START_PRIO AND trunc(a.DATE_END_PROMO-30))
AND a.CRITERIA in 
(
'Nhóm 1 - SDBQ CASA 03 tháng',
'Nhóm 1 - SDBQ CASA 12 tháng'
)
AND a.CUSTOMER_ID IN
(SELECT CUSTOMER_ID FROM PPTTT.TBL_IGEN3_CON2))
SELECT * FROM omni1 
UNION ALL 
SELECT * FROM omni2;