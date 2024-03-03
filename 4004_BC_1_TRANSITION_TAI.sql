-------LD--------
-----------------
WITH flt AS 
	(SELECT 
		* 
		FROM TCIMPORT.FACT_LOAN_T24 flt
		WHERE 
			flt.DATE_COB = trunc(sysdate-1/*ALTER-1*/)
			AND flt.DATASOURCE = 'T24'
			AND SUBSTR(flt.CONTRACT_NO,1,2)='LD')
, dlt AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_LOAN_T24 dlt
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FROM_DATE  AND nvl(EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
			AND SUBSTR(dlt.CONTRACT_NO,1,2)='LD'
			AND dlt.START_DATE = trunc(sysdate-1/*ALTER-1*/))
, dbal AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_BPM_AP_LC dbal 
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FM_DT  AND nvl(EFF_TO_DT,TO_DATE(24000101,'yyyymmdd'))))
, dc AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_CUSTOMER dc 
		WHERE
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FROM_DATE  AND nvl(EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd'))))
, db AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_BRANCH db
		WHERE
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FROM_DATE  AND nvl(EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd'))))
, fba AS 
	(SELECT 
		AP_NBR
		, AP_ST_ID
		, ASSET_ID 
		FROM TCIMPORT.FACT_BPM_APPLICATION)
, apavy AS  
	(SELECT 
		* 
		FROM TCIMPORT.FACT_BPM_AP_AVY
		WHERE 
			REGEXP_SUBSTR(AP_AVY_CODE,'[^-]+',1) IN ('KSGNCT', 'TDTC', 'TDCN'))
, ASSET_ID_CV AS 
	(SELECT 
		src_cl_id
		, src_dsc
		FROM TCIMPORT.DIM_BPM_CV dbc 
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FM_DT  AND nvl(EFF_TO_DT,TO_DATE(24000101,'yyyymmdd'))))
, KSGN_MAJOR_CV AS 
	(SELECT 
		src_cl_id
		, src_dsc
		FROM TCIMPORT.DIM_BPM_CV dbc 
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FM_DT  AND nvl(EFF_TO_DT,TO_DATE(24000101,'yyyymmdd'))))
SELECT DISTINCT 
	DATA_DATE
	, LD_MD 
	, MA_GD_XL
	, MA_PDTD 
	, MA_HO_SO 
	, NGAY_KHOI_TAO 
	, NGAY_HOAN_THANH 
	, SAN_PHAM 
	, MA_CN 
	, TEN_CN 
	, KHOI 
	, TEN_CIF 
	, CIF 
	, TRANG_THAI_GD 
	, SO_TIEN 
	, ASSET_ID
	, LOAI_GD 
	, NGAY_GN 
	, NGAY_TAT_TOAN_KH 
	, KY_HAN
	, SRC_DSC_ASSET_ID 
	, SRC_DSC_MAJOR_ID 
	from
	(SELECT 
		trunc(sysdate/*ALTER*/) AS DATA_DATE 
		, flt.CONTRACT_NO AS LD_MD 
		, dlt.BPM_DSBR_ID AS MA_GD_XL 
		, dbal.AP1_NBR AS MA_PDTD 
		, dlt.LINK_REF AS MA_HO_SO 
		, dlt.LD_APRV_DATE AS NGAY_KHOI_TAO 
		, dlt.LD_APRV_CH_DATE AS NGAY_HOAN_THANH
		, dlt.LOAN_SUBPRODUCT_NAME AS SAN_PHAM 
		, flt.BRANCH_CODE AS MA_CN 
		, db.BRANCH_NAME AS TEN_CN 
		, dc.CUSTGROUP_NAME AS KHOI 
		, dc.CUSTOMER_NAME AS TEN_CIF
		, flt.CUSTOMER_ID AS CIF 
		, fba.AP_ST_ID AS TRANG_THAI_GD 
		, flt.BALANCE_LCY_AMT AS SO_TIEN 
		, fba.ASSET_ID 
		, apavy.DTL_TXN_TP AS LOAI_GD 
		, dlt.START_DATE AS NGAY_GN
		, dlt.MATURITY_DATE AS NGAY_TAT_TOAN_KH 
		, dlt.TERM AS KY_HAN
		, ASSET_ID_CV.SRC_DSC AS SRC_DSC_ASSET_ID 
		, KSGN_MAJOR_CV.SRC_DSC AS SRC_DSC_MAJOR_ID 
		FROM flt
		JOIN  dlt 
			ON flt.CONTRACT_NO = dlt.CONTRACT_NO 
		LEFT JOIN dbal 
			ON dlt.BPM_DSBR_ID = dbal.AP2_NBR 
		LEFT JOIN fba 
			ON dlt.BPM_DSBR_ID = fba.AP_NBR 
		LEFT JOIN dc 
			ON flt.CUSTOMER_ID = dc.CUSTOMER_ID
		LEFT JOIN db 
			ON flt.BRANCH_CODE = db.BRANCH_CODE 
		LEFT JOIN ASSET_ID_CV 
			ON fba.ASSET_ID = ASSET_ID_CV.SRC_CL_ID 
		LEFT JOIN apavy
			ON dlt.BPM_DSBR_ID = apavy.MA_GIAO_DICH
		LEFT JOIN KSGN_MAJOR_CV 
			ON apavy.DTL_BSN_TP = KSGN_MAJOR_CV.src_cl_id);
			
--MD-----------
---------------
WITH ftf AS 
	(SELECT 
		* 
		FROM TCIMPORT.FACT_TRADE_FINANCE ftf 
		WHERE 
			ftf.DATE_COB = trunc(sysdate-1/*ALTER-1*/)
			AND SUBSTR(ftf.TFMD_ID,1,2)='MD')
, dtf AS 
	(SELECT 
		* 
		FROM TCIMPORT.DIM_TRADE_FINANCE dtf
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FROM_DATE  AND nvl(EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd')))
			AND SUBSTR(dtf.TFMD_ID,1,2)='MD'
			AND dtf.VALUE_DATE = trunc(sysdate -1/*ALTER-1*/))
, dbal AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_BPM_AP_LC dbal 
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FM_DT  AND nvl(EFF_TO_DT,TO_DATE(24000101,'yyyymmdd'))))
, dc AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_CUSTOMER dc 
		WHERE
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FROM_DATE  AND nvl(EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd'))))
, db AS 
	(SELECT 
	* 
		FROM TCIMPORT.DIM_BRANCH db
		WHERE
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FROM_DATE  AND nvl(EFF_TO_DATE,TO_DATE(24000101,'yyyymmdd'))))
-----
-----
, fba AS 
	(SELECT 
		AP_NBR
		, AP_ST_ID
		, ASSET_ID 
		FROM TCIMPORT.FACT_BPM_APPLICATION)
, apavy AS  
	(SELECT 
		* 
		FROM TCIMPORT.FACT_BPM_AP_AVY 
		WHERE 
			REGEXP_SUBSTR(AP_AVY_CODE,'[^-]+',1) IN ('KSGNCT', 'TDTC', 'TDCN'))
, ASSET_ID_CV AS 
	(SELECT 
		src_cl_id
		, src_dsc
		FROM TCIMPORT.DIM_BPM_CV dbc 
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FM_DT  AND nvl(EFF_TO_DT,TO_DATE(24000101,'yyyymmdd'))))
, KSGN_MAJOR_CV AS 
	(SELECT 
		src_cl_id
		, src_dsc
		FROM TCIMPORT.DIM_BPM_CV dbc 
		WHERE 
			(trunc(sysdate-1/*ALTER-1*/) BETWEEN EFF_FM_DT  AND nvl(EFF_TO_DT,TO_DATE(24000101,'yyyymmdd'))))
SELECT DISTINCT 
	DATA_DATE
	, LD_MD 
	, MA_GD_XL
	, MA_PDTD 
	, MA_HO_SO 
	, NGAY_KHOI_TAO 
	, NGAY_HOAN_THANH 
	, SAN_PHAM 
	, MA_CN 
	, TEN_CN 
	, KHOI 
	, TEN_CIF 
	, CIF 
	, TRANG_THAI_GD 
	, SO_TIEN 
	, ASSET_ID
	, LOAI_GD 
	, NGAY_GN 
	, NGAY_TAT_TOAN_KH 
	, NULL AS KY_HAN
	, SRC_DSC_ASSET_ID 
	, SRC_DSC_MAJOR_ID 
	from
		(SELECT 
			trunc(sysdate/*ALTER*/) AS DATA_DATE 
			, ftf.TFMD_ID AS LD_MD 
			, dtf.BPM_DSBR_ID AS MA_GD_XL 
			, dbal.AP1_NBR AS MA_PDTD 
			, dtf.TFMD_NO AS MA_HO_SO 
			, dtf.ISSUE_DATE AS NGAY_KHOI_TAO 
			, dtf.EXPIRY_DATE AS NGAY_HOAN_THANH
			, dtf.LC_TYPE_NAME AS SAN_PHAM 
			, ftf.BRANCH_CODE AS MA_CN 
			, db.BRANCH_NAME AS TEN_CN 
			, dc.CUSTGROUP_NAME AS KHOI 
			, dc.CUSTOMER_NAME AS TEN_CIF
			, dtf.CUSTOMER_ID AS CIF 
			, fba.AP_ST_ID AS TRANG_THAI_GD 
			, ftf.BALANCE_AMT_LCY AS SO_TIEN 
			, fba.ASSET_ID 
			, dtf.REF AS LOAI_GD 
			, dtf.VALUE_DATE AS NGAY_GN
			, dtf.CLOSING_DATE AS NGAY_TAT_TOAN_KH 
			, ASSET_ID_CV.SRC_DSC AS SRC_DSC_ASSET_ID --LOAI_TSBD
			, KSGN_MAJOR_CV.SRC_DSC AS SRC_DSC_MAJOR_ID --NV_CHI_TIET
			FROM ftf
			JOIN dtf 
				ON ftf.TFMD_ID = dtf.TFMD_ID 
			LEFT JOIN dbal 
				ON dtf.BPM_DSBR_ID = dbal.AP2_NBR 
			LEFT JOIN fba 
				ON dtf.BPM_DSBR_ID = fba.AP_NBR 
			LEFT JOIN  dc 
				ON dtf.CUSTOMER_ID = dc.CUSTOMER_ID
			LEFT JOIN db 
				ON ftf.BRANCH_CODE = db.BRANCH_CODE 
			LEFT JOIN ASSET_ID_CV 
				ON fba.ASSET_ID = ASSET_ID_CV.SRC_CL_ID 
			LEFT JOIN apavy
				ON dtf.BPM_DSBR_ID = apavy.MA_GIAO_DICH
			LEFT JOIN KSGN_MAJOR_CV 
				ON apavy.DTL_BSN_TP = KSGN_MAJOR_CV.src_cl_id)