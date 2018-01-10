# Table 1 (display_text_frequency)

SELECT ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
(
	 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
	 dd.fk_customer_map_id AS cust_map_id_ded,
	 mcar.display_text AS ded_display_text,
	 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
	 mcar.fk_parent_customer_map_id, c.name,
	 dd.deduction_created_date, dd.customer_claim_date 
	 FROM ded_deduction AS dd
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id

	 LEFT JOIN ded_deduction_resolution AS ddr
	 ON dd.pk_deduction_id = ddr.fk_deduction_id
	 LEFT JOIN lu_reason_code_rad AS reasoncode
	 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
	 LEFT JOIN lu_reason_category_rad AS reasoncode_category
	 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
	 LEFT JOIN map_reason_code_account_rad AS map_account 
	 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

	 LEFT JOIN lu_deduction_status_rad AS deductionstatus
	 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
	 LEFT JOIN lu_deduction_status_system AS systemstatus
	 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

	 WHERE 
	 #dd.fiscal_year=2016
	 systemstatus.pk_deduction_status_system_id = 4
	 AND pk_reason_category_rad_id IN (126)
	 AND ddr.fk_resolution_type_id = 4
	 AND ddr.fk_resolution_status_id = 1
	 AND dd.fk_deduction_type_id = 0
	 AND dd.pk_deduction_id IN 
	 (
		SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
	 )
 GROUP BY dd.pk_deduction_id
)AS ded_data

LEFT JOIN
(
	 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
	 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
	 mcar.display_text AS prom_display_text,
	 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
	 mcar.fk_parent_customer_map_id, c.name, 
	 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
	 ddri.fk_deduction_id AS ded_id_ddri
	  
	 FROM ded_deduction_resolution AS ddr
	 LEFT JOIN ded_deduction_resolution_item AS ddri
	 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
	 
	 LEFT JOIN tpm_commit AS tc
	 ON ddri.fk_commitment_id = tc.commit_id
	 
	 LEFT JOIN tpm_promotion AS tp
	 ON tp.promotion_id = tc.promotion_id
	   
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN map_payment_term_account_rad AS mptar
	 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id
	 
	 WHERE tc.commit_id IN 
	 (
		  SELECT DISTINCT fk_commitment_id
		  FROM ded_deduction_resolution_item AS ddri
		  LEFT JOIN ded_deduction_resolution AS ddr 
		  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
		  LEFT JOIN ded_deduction AS ded
		  ON ddr.fk_deduction_id = ded.pk_deduction_id
		  LEFT JOIN tpm_commit AS tc 
		  ON ddri.fk_commitment_id = tc.commit_id
		  LEFT JOIN tpm_lu_commit_status AS tlcs
		  ON tc.commit_status_id = tlcs.commit_status_id
		  WHERE ded.pk_deduction_id IN 
		  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
		  AND ddr.fk_resolution_status_id = 1
	)
 
) AS prom_data

ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
HAVING COUNT(*) > 500






#Table 3 (ded_deduction_data with filters)


SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
 dd.fk_customer_map_id AS cust_map_id_ded,
 mcar.display_text AS ded_display_text,
 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
 mcar.fk_parent_customer_map_id, c.name,
 dd.deduction_created_date, dd.customer_claim_date 
 FROM ded_deduction AS dd
 LEFT JOIN map_customer_account_rad AS mcar
 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
 LEFT JOIN customer AS c
 ON c.customer_id = mcar.fk_customer_id

 LEFT JOIN ded_deduction_resolution AS ddr
 ON dd.pk_deduction_id = ddr.fk_deduction_id
 LEFT JOIN lu_reason_code_rad AS reasoncode
 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
 LEFT JOIN lu_reason_category_rad AS reasoncode_category
 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
 LEFT JOIN map_reason_code_account_rad AS map_account 
 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

 LEFT JOIN lu_deduction_status_rad AS deductionstatus
 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
 LEFT JOIN lu_deduction_status_system AS systemstatus
 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

 WHERE 
 dd.fiscal_year=2016
 AND systemstatus.pk_deduction_status_system_id = 4
 AND pk_reason_category_rad_id IN (126)
 AND ddr.fk_resolution_type_id = 4
 AND ddr.fk_resolution_status_id = 1
 AND dd.fk_deduction_type_id = 0
 AND dd.pk_deduction_id IN 
 (
	SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
 )
 GROUP BY dd.pk_deduction_id
 
 
 
 
 
 
 

# Table 4 (tpm_promotion with all the filters)

SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
	 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
	 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
	 mcar.fk_parent_customer_map_id, c.name, 
	 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
	 ddri.fk_deduction_id AS ded_id_ddri
	  
	 FROM ded_deduction_resolution AS ddr
	 LEFT JOIN ded_deduction_resolution_item AS ddri
	 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
	 
	 LEFT JOIN tpm_commit AS tc
	 ON ddri.fk_commitment_id = tc.commit_id
	 
	 LEFT JOIN tpm_promotion AS tp
	 ON tp.promotion_id = tc.promotion_id
	   
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN map_payment_term_account_rad AS mptar
	 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id
	 
	 WHERE tc.commit_id IN 
	 (
		  SELECT DISTINCT fk_commitment_id
		  FROM ded_deduction_resolution_item AS ddri
		  LEFT JOIN ded_deduction_resolution AS ddr 
		  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
		  LEFT JOIN ded_deduction AS ded
		  ON ddr.fk_deduction_id = ded.pk_deduction_id
		  LEFT JOIN tpm_commit AS tc 
		  ON ddri.fk_commitment_id = tc.commit_id
		  LEFT JOIN tpm_lu_commit_status AS tlcs
		  ON tc.commit_status_id = tlcs.commit_status_id
		  WHERE ded.pk_deduction_id IN 
		  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
		  AND ddr.fk_resolution_status_id = 1
	)
	
	AND tp.promotion_status_id = 6
	
	

# Table 5 (tpm_commit with filters)

SELECT *
FROM ded_deduction_resolution_item AS ddri
LEFT JOIN ded_deduction_resolution AS ddr 
ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id

LEFT JOIN tpm_commit AS tc 
ON ddri.fk_commitment_id = tc.commit_id

WHERE tc.commit_status_id = 6
AND ddr.fk_resolution_status_id = 1
AND ddr.fk_resolution_type_id = 4


#Table 6 (promotion_commit)


 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
 mcar.fk_parent_customer_map_id, c.name, 
 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
 ddri.fk_deduction_id AS ded_id_ddri
   
 FROM ded_deduction_resolution AS ddr
 LEFT JOIN ded_deduction_resolution_item AS ddri
 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
 
 LEFT JOIN tpm_commit AS tc
 ON ddri.fk_commitment_id = tc.commit_id
 
 LEFT JOIN tpm_promotion AS tp
 ON tp.promotion_id = tc.promotion_id
   
 LEFT JOIN map_customer_account_rad AS mcar
 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
 LEFT JOIN map_payment_term_account_rad AS mptar
 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
 LEFT JOIN customer AS c
 ON c.customer_id = mcar.fk_customer_id
 
 WHERE tc.commit_id IN 
 (
	  SELECT DISTINCT fk_commitment_id
	  FROM ded_deduction_resolution_item AS ddri
	  LEFT JOIN ded_deduction_resolution AS ddr 
	  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
	  LEFT JOIN ded_deduction AS ded
	  ON ddr.fk_deduction_id = ded.pk_deduction_id
	  LEFT JOIN tpm_commit AS tc 
	  ON ddri.fk_commitment_id = tc.commit_id
	  LEFT JOIN tpm_lu_commit_status AS tlcs
	  ON tc.commit_status_id = tlcs.commit_status_id
	  WHERE ded.pk_deduction_id IN 
	  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
	  AND ddr.fk_resolution_status_id = 1
)








# display_text join ded_deduction (step 1)


SELECT COUNT(*) FROM
(
	SELECT ded_data.ded_display_text, COUNT(*) FROM
	(
		 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
		 dd.fk_customer_map_id AS cust_map_id_ded,
		 mcar.display_text AS ded_display_text,
		 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
		 mcar.fk_parent_customer_map_id, c.name,
		 dd.deduction_created_date, dd.customer_claim_date 
		 FROM ded_deduction AS dd
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id

		 LEFT JOIN ded_deduction_resolution AS ddr
		 ON dd.pk_deduction_id = ddr.fk_deduction_id
		 LEFT JOIN lu_reason_code_rad AS reasoncode
		 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 LEFT JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 LEFT JOIN map_reason_code_account_rad AS map_account 
		 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

		 LEFT JOIN lu_deduction_status_rad AS deductionstatus
		 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 LEFT JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 WHERE 
		 #dd.fiscal_year=2016
		 systemstatus.pk_deduction_status_system_id = 4
		 AND pk_reason_category_rad_id IN (126)
		 AND ddr.fk_resolution_type_id = 4
		 AND ddr.fk_resolution_status_id = 1
		 AND dd.fk_deduction_type_id = 0
		 AND dd.pk_deduction_id IN 
		 (
			SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
		 )
	 GROUP BY dd.pk_deduction_id
	)AS ded_data

	LEFT JOIN
	(
		 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
		 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
		 mcar.display_text AS prom_display_text,
		 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
		 mcar.fk_parent_customer_map_id, c.name, 
		 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
		 ddri.fk_deduction_id AS ded_id_ddri
		  
		 FROM ded_deduction_resolution AS ddr
		 LEFT JOIN ded_deduction_resolution_item AS ddri
		 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
		 
		 LEFT JOIN tpm_commit AS tc
		 ON ddri.fk_commitment_id = tc.commit_id
		 
		 LEFT JOIN tpm_promotion AS tp
		 ON tp.promotion_id = tc.promotion_id
		   
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN map_payment_term_account_rad AS mptar
		 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id
		 
		 WHERE tc.commit_id IN 
		 (
			  SELECT DISTINCT fk_commitment_id
			  FROM ded_deduction_resolution_item AS ddri
			  LEFT JOIN ded_deduction_resolution AS ddr 
			  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
			  LEFT JOIN ded_deduction AS ded
			  ON ddr.fk_deduction_id = ded.pk_deduction_id
			  LEFT JOIN tpm_commit AS tc 
			  ON ddri.fk_commitment_id = tc.commit_id
			  LEFT JOIN tpm_lu_commit_status AS tlcs
			  ON tc.commit_status_id = tlcs.commit_status_id
			  WHERE ded.pk_deduction_id IN 
			  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
			  AND ddr.fk_resolution_status_id = 1
		)
	 
	) AS prom_data

	ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
	GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
	HAVING COUNT(*) >= 500
) AS table_1_display_text

LEFT JOIN
(
	 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
	 dd.fk_customer_map_id AS cust_map_id_ded,
	 mcar.display_text AS ded_display_text,
	 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
	 mcar.fk_parent_customer_map_id, c.name,
	 dd.deduction_created_date, dd.customer_claim_date 
	 FROM ded_deduction AS dd
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id

	 LEFT JOIN ded_deduction_resolution AS ddr
	 ON dd.pk_deduction_id = ddr.fk_deduction_id
	 LEFT JOIN lu_reason_code_rad AS reasoncode
	 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
	 LEFT JOIN lu_reason_category_rad AS reasoncode_category
	 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
	 LEFT JOIN map_reason_code_account_rad AS map_account 
	 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

	 LEFT JOIN lu_deduction_status_rad AS deductionstatus
	 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
	 LEFT JOIN lu_deduction_status_system AS systemstatus
	 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

	 WHERE 
	 dd.fiscal_year=2016
	 AND systemstatus.pk_deduction_status_system_id = 4
	 AND pk_reason_category_rad_id IN (126)
	 AND ddr.fk_resolution_type_id = 4
	 AND ddr.fk_resolution_status_id = 1
	 AND dd.fk_deduction_type_id = 0
	 AND dd.pk_deduction_id IN 
	 (
		SELECT * FROM
		(
			SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
			
			INNER JOIN lu_reason_code_rad AS reasoncode
			ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			INNER JOIN lu_reason_category_rad AS reasoncode_category
			ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



			INNER JOIN lu_deduction_status_rad AS deductionstatus
			ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			INNER JOIN lu_deduction_status_system AS systemstatus
			ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			INNER JOIN map_deduction_item_rollup_header AS header
			ON deduction.pk_deduction_id = header.fk_deduction_id
			INNER JOIN map_deduction_item_rollup AS map_item
			ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
			INNER JOIN ded_deduction_resolution AS resolution
			ON header.fk_deduction_id = resolution.fk_deduction_id
			 
			WHERE 

			deduction.fk_reason_code_map_id != -1

			AND pk_reason_category_rad_id IN (126) 

			AND systemstatus.pk_deduction_status_system_id = 4

			AND deduction.fk_deduction_type_id=0

			AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
			AND deduction.fiscal_year=2016

			AND header.fk_resolution_type_id = 4
			AND resolution.fk_resolution_type_id = 4
			AND deduction.fk_deduction_type_id = 0
			
			 LIMIT 1000
		 ) AS suggest_sol		
	 )
	GROUP BY dd.pk_deduction_id
	
) AS table3_ded_data 
 
 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text









# step 2 (step 1 join tpm promotion based on C1 & C2 joining condition)



SELECT COUNT(*) FROM
(
	SELECT table3_ded_data.payterms_desc_new, table_1_display_text.ded_display_text,
	table_1_display_text.prom_display_text,
	table3_ded_data.pk_deduction_id,
	table3_ded_data.deduction_created_date_min,
	table3_ded_data.deduction_created_date_max,
	table3_ded_data.customer_claim_date_min,
	table3_ded_data.customer_claim_date_max,
	table3_ded_data.invoice_date_min,
	table3_ded_data.invoice_date_max,
	
	table3_ded_data.promortion_execution_from_date_min,
	table3_ded_data.promortion_execution_from_date_max,
	
	table3_ded_data.promotion_execution_to_date_min,
	table3_ded_data.promotion_execution_to_date_min
	
	FROM
	(
		SELECT ded_data.payterms_desc,  ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
		(
			 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
			 dd.fk_customer_map_id AS cust_map_id_ded,
			 mcar.display_text AS ded_display_text,
			 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
			 mcar.fk_parent_customer_map_id, c.name,
			 dd.deduction_created_date, dd.customer_claim_date 
			 FROM ded_deduction AS dd
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id

			 LEFT JOIN ded_deduction_resolution AS ddr
			 ON dd.pk_deduction_id = ddr.fk_deduction_id
			 LEFT JOIN lu_reason_code_rad AS reasoncode
			 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			 LEFT JOIN lu_reason_category_rad AS reasoncode_category
			 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			 LEFT JOIN map_reason_code_account_rad AS map_account 
			 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

			 LEFT JOIN lu_deduction_status_rad AS deductionstatus
			 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			 LEFT JOIN lu_deduction_status_system AS systemstatus
			 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			 WHERE 
			 #dd.fiscal_year=2016
			 systemstatus.pk_deduction_status_system_id = 4
			 AND pk_reason_category_rad_id IN (126)
			 AND ddr.fk_resolution_type_id = 4
			 AND ddr.fk_resolution_status_id = 1
			 AND dd.fk_deduction_type_id = 0
			 AND dd.pk_deduction_id IN 
			 (
				SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
			 )
		 GROUP BY dd.pk_deduction_id
		)AS ded_data

		LEFT JOIN
		(
			 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
			 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
			 mcar.display_text AS prom_display_text,
			 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
			 mcar.fk_parent_customer_map_id, c.name, 
			 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
			 ddri.fk_deduction_id AS ded_id_ddri
			  
			 FROM ded_deduction_resolution AS ddr
			 LEFT JOIN ded_deduction_resolution_item AS ddri
			 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
			 
			 LEFT JOIN tpm_commit AS tc
			 ON ddri.fk_commitment_id = tc.commit_id
			 
			 LEFT JOIN tpm_promotion AS tp
			 ON tp.promotion_id = tc.promotion_id
			   
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN map_payment_term_account_rad AS mptar
			 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id
			 
			 WHERE tc.commit_id IN 
			 (
				  SELECT DISTINCT fk_commitment_id
				  FROM ded_deduction_resolution_item AS ddri
				  LEFT JOIN ded_deduction_resolution AS ddr 
				  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
				  LEFT JOIN ded_deduction AS ded
				  ON ddr.fk_deduction_id = ded.pk_deduction_id
				  LEFT JOIN tpm_commit AS tc 
				  ON ddri.fk_commitment_id = tc.commit_id
				  LEFT JOIN tpm_lu_commit_status AS tlcs
				  ON tc.commit_status_id = tlcs.commit_status_id
				  WHERE ded.pk_deduction_id IN 
				  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
				  AND ddr.fk_resolution_status_id = 1
			)
		 
		) AS prom_data

		ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
		GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
		HAVING COUNT(*) >= 500
	) AS table_1_display_text

	LEFT JOIN
	(
		 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
		 
		 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
		 
		 dd.fk_customer_map_id AS cust_map_id_ded,
		 mcar.display_text AS ded_display_text,
		 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
		 mcar.fk_parent_customer_map_id, c.name,
		 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
		 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
		 
		 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
	         (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2000-01-01' ELSE dd.deduction_created_date END) AS deduction_created_date_max,
	         (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
	         (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2000-01-01' ELSE dd.customer_claim_date END) AS customer_claim_date_max,
	         (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
	         (CASE WHEN ISNULL(dd.invoice_date) THEN '2000-01-01' ELSE dd.invoice_date END) AS invoice_date_max
 
		 		 
		 FROM ded_deduction AS dd
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id

		 LEFT JOIN ded_deduction_resolution AS ddr
		 ON dd.pk_deduction_id = ddr.fk_deduction_id
		 LEFT JOIN lu_reason_code_rad AS reasoncode
		 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 LEFT JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 LEFT JOIN map_reason_code_account_rad AS map_account 
		 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

		 LEFT JOIN lu_deduction_status_rad AS deductionstatus
		 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 LEFT JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 WHERE 
		 dd.fiscal_year=2016
		 AND systemstatus.pk_deduction_status_system_id = 4
		 AND pk_reason_category_rad_id IN (126)
		 AND ddr.fk_resolution_type_id = 4
		 AND ddr.fk_resolution_status_id = 1
		 AND dd.fk_deduction_type_id = 0
		 AND dd.pk_deduction_id IN 
		 (
			SELECT * FROM
			(
				SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
				
				INNER JOIN lu_reason_code_rad AS reasoncode
				ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				INNER JOIN lu_reason_category_rad AS reasoncode_category
				ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



				INNER JOIN lu_deduction_status_rad AS deductionstatus
				ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				INNER JOIN lu_deduction_status_system AS systemstatus
				ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				INNER JOIN map_deduction_item_rollup_header AS header
				ON deduction.pk_deduction_id = header.fk_deduction_id
				INNER JOIN map_deduction_item_rollup AS map_item
				ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
				INNER JOIN ded_deduction_resolution AS resolution
				ON header.fk_deduction_id = resolution.fk_deduction_id
				 
				WHERE 

				deduction.fk_reason_code_map_id != -1

				AND pk_reason_category_rad_id IN (126) 

				AND systemstatus.pk_deduction_status_system_id = 4

				AND deduction.fk_deduction_type_id=0

				AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
				AND deduction.fiscal_year=2016

				AND header.fk_resolution_type_id = 4
				AND resolution.fk_resolution_type_id = 4
				AND deduction.fk_deduction_type_id = 0
				
				LIMIT 1000
			) AS suggest_sol		
		 )
		GROUP BY dd.pk_deduction_id
	) AS table3_ded_data
	 
	 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text

)AS step1_join_data

LEFT JOIN 
(
	 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
	 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
	 
	 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,

	 
	 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
	 mcar.fk_parent_customer_map_id, c.name, 
	 tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, 
	 ddr.fk_deduction_id AS ded_id_ddr,
	 ddri.fk_deduction_id AS ded_id_ddri,
	 
	 
	 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
	 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2000-01-01' ELSE tp.ship_start_date END) AS ship_start_date_max,
	 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
	 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2000-01-01' ELSE tp.consumption_start_date END) AS consumption_start_date_max,
	 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2017-12-31' ELSE tp.ship_end_date END) AS ship_end_date_min,
	 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
	 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2017-12-31' ELSE tp.consumption_end_date END) AS consumption_end_date_min,
	 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
	 
	  
	 FROM ded_deduction_resolution AS ddr
	 LEFT JOIN ded_deduction_resolution_item AS ddri
	 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
	 
	 LEFT JOIN tpm_commit AS tc
	 ON ddri.fk_commitment_id = tc.commit_id
	 
	 LEFT JOIN tpm_promotion AS tp
	 ON tp.promotion_id = tc.promotion_id
	   
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN map_payment_term_account_rad AS mptar
	 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id
	 
	 WHERE tc.commit_id IN 
	 (
		  SELECT DISTINCT fk_commitment_id
		  FROM ded_deduction_resolution_item AS ddri
		  LEFT JOIN ded_deduction_resolution AS ddr 
		  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
		  LEFT JOIN ded_deduction AS ded
		  ON ddr.fk_deduction_id = ded.pk_deduction_id
		  LEFT JOIN tpm_commit AS tc 
		  ON ddri.fk_commitment_id = tc.commit_id
		  LEFT JOIN tpm_lu_commit_status AS tlcs
		  ON tc.commit_status_id = tlcs.commit_status_id
		  WHERE ded.pk_deduction_id IN 
		  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
		  AND ddr.fk_resolution_status_id = 1
	)
	
	AND tp.promotion_status_id = 6
	GROUP BY tp.promotion_id
) AS table4_prom_data

ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
AND step1_join_data.prom_display_text = table4_prom_data.display_text






# step 2 (step 1 join tpm promotion based on C1, C2 & C3 joining condition)



SELECT COUNT(*) FROM
(
	SELECT
	table3_ded_data.pk_deduction_id,
	table3_ded_data.payterms_desc_new,
	table_1_display_text.ded_display_text,
	table_1_display_text.prom_display_text,
	table3_ded_data.deduction_created_date_min,
	table3_ded_data.deduction_created_date_max,
	table3_ded_data.customer_claim_date_min,
	table3_ded_data.customer_claim_date_max,
	table3_ded_data.invoice_date_min,
	table3_ded_data.invoice_date_max,
	
	table3_ded_data.promortion_execution_from_date_max,
	table3_ded_data.promortion_execution_from_date_min,
	table3_ded_data.promotion_execution_to_date_max,
	table3_ded_data.promotion_execution_to_date_min
	
	FROM
	(
		SELECT ded_data.payterms_desc,  ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
		(
			 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
			 dd.fk_customer_map_id AS cust_map_id_ded,
			 mcar.display_text AS ded_display_text,
			 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
			 mcar.fk_parent_customer_map_id, c.name,
			 dd.deduction_created_date, dd.customer_claim_date 
			 FROM ded_deduction AS dd
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id

			 LEFT JOIN ded_deduction_resolution AS ddr
			 ON dd.pk_deduction_id = ddr.fk_deduction_id
			 LEFT JOIN lu_reason_code_rad AS reasoncode
			 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			 LEFT JOIN lu_reason_category_rad AS reasoncode_category
			 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			 LEFT JOIN map_reason_code_account_rad AS map_account 
			 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

			 LEFT JOIN lu_deduction_status_rad AS deductionstatus
			 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			 LEFT JOIN lu_deduction_status_system AS systemstatus
			 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			 WHERE 
			 #dd.fiscal_year=2016
			 systemstatus.pk_deduction_status_system_id = 4
			 AND pk_reason_category_rad_id IN (126)
			 AND ddr.fk_resolution_type_id = 4
			 AND ddr.fk_resolution_status_id = 1
			 AND dd.fk_deduction_type_id = 0
			 AND dd.pk_deduction_id IN 
			 (
				SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
			 )
		 GROUP BY dd.pk_deduction_id
		)AS ded_data

		LEFT JOIN
		(
			 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
			 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
			 mcar.display_text AS prom_display_text,
			 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
			 mcar.fk_parent_customer_map_id, c.name, 
			 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
			 ddri.fk_deduction_id AS ded_id_ddri
			  
			 FROM ded_deduction_resolution AS ddr
			 LEFT JOIN ded_deduction_resolution_item AS ddri
			 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
			 
			 LEFT JOIN tpm_commit AS tc
			 ON ddri.fk_commitment_id = tc.commit_id
			 
			 LEFT JOIN tpm_promotion AS tp
			 ON tp.promotion_id = tc.promotion_id
			   
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN map_payment_term_account_rad AS mptar
			 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id
			 
			 WHERE tc.commit_id IN 
			 (
				  SELECT DISTINCT fk_commitment_id
				  FROM ded_deduction_resolution_item AS ddri
				  LEFT JOIN ded_deduction_resolution AS ddr 
				  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
				  LEFT JOIN ded_deduction AS ded
				  ON ddr.fk_deduction_id = ded.pk_deduction_id
				  LEFT JOIN tpm_commit AS tc 
				  ON ddri.fk_commitment_id = tc.commit_id
				  LEFT JOIN tpm_lu_commit_status AS tlcs
				  ON tc.commit_status_id = tlcs.commit_status_id
				  WHERE ded.pk_deduction_id IN 
				  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
				  AND ddr.fk_resolution_status_id = 1
			)
		 
		) AS prom_data

		ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
		GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
		HAVING COUNT(*) >= 500
	) AS table_1_display_text

	LEFT JOIN
	(
		 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
		 
		 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
		 
		 dd.fk_customer_map_id AS cust_map_id_ded,
		 mcar.display_text AS ded_display_text,
		 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
		 mcar.fk_parent_customer_map_id, c.name,
		 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
		 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
		 
		 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
	         (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2000-01-01' ELSE dd.deduction_created_date END) AS deduction_created_date_max,
	         (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
	         (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2000-01-01' ELSE dd.customer_claim_date END) AS customer_claim_date_max,
	         (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
	         (CASE WHEN ISNULL(dd.invoice_date) THEN '2000-01-01' ELSE dd.invoice_date END) AS invoice_date_max,
	         (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
	         (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2000-01-01' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_max,
	         (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2017-12-31' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_min,
	         (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
 
		 		 
		 FROM ded_deduction AS dd
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id

		 LEFT JOIN ded_deduction_resolution AS ddr
		 ON dd.pk_deduction_id = ddr.fk_deduction_id
		 LEFT JOIN lu_reason_code_rad AS reasoncode
		 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 LEFT JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 LEFT JOIN map_reason_code_account_rad AS map_account 
		 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

		 LEFT JOIN lu_deduction_status_rad AS deductionstatus
		 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 LEFT JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 WHERE 
		 dd.fiscal_year=2016
		 AND systemstatus.pk_deduction_status_system_id = 4		
		 AND pk_reason_category_rad_id IN (126)
		 AND ddr.fk_resolution_type_id = 4
		 AND ddr.fk_resolution_status_id = 1
		 AND dd.fk_deduction_type_id = 0
		 AND dd.pk_deduction_id IN 
		 (
			SELECT * FROM
			(
				SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
				
				INNER JOIN lu_reason_code_rad AS reasoncode
				ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				INNER JOIN lu_reason_category_rad AS reasoncode_category
				ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



				INNER JOIN lu_deduction_status_rad AS deductionstatus
				ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				INNER JOIN lu_deduction_status_system AS systemstatus
				ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				INNER JOIN map_deduction_item_rollup_header AS header
				ON deduction.pk_deduction_id = header.fk_deduction_id
				INNER JOIN map_deduction_item_rollup AS map_item
				ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
				INNER JOIN ded_deduction_resolution AS resolution
				ON header.fk_deduction_id = resolution.fk_deduction_id
				 
				WHERE 

				deduction.fk_reason_code_map_id != -1

				AND pk_reason_category_rad_id IN (126) 

				AND systemstatus.pk_deduction_status_system_id = 4

				AND deduction.fk_deduction_type_id=0

				AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
				AND deduction.fiscal_year=2016

				AND header.fk_resolution_type_id = 4
				AND resolution.fk_resolution_type_id = 4
				AND deduction.fk_deduction_type_id = 0
				
				LIMIT 1000
			) AS suggest_sol		
		 )
		GROUP BY dd.pk_deduction_id
	) AS table3_ded_data
	 
	 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text

)AS step1_join_data

INNER JOIN 
(
	 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
	 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
	 
	 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,

	 
	 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
	 mcar.fk_parent_customer_map_id, c.name, 
	 tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, 
	 ddr.fk_deduction_id AS ded_id_ddr,
	 ddri.fk_deduction_id AS ded_id_ddri,
	 
	 
	 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
	 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2000-01-01' ELSE tp.ship_start_date END) AS ship_start_date_max,
	 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
	 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2000-01-01' ELSE tp.consumption_start_date END) AS consumption_start_date_max,
	 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2017-12-31' ELSE tp.ship_end_date END) AS ship_end_date_min,
	 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
	 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2017-12-31' ELSE tp.consumption_end_date END) AS consumption_end_date_min,
	 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
	 
	  
	 FROM ded_deduction_resolution AS ddr
	 LEFT JOIN ded_deduction_resolution_item AS ddri
	 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
	 
	 LEFT JOIN tpm_commit AS tc
	 ON ddri.fk_commitment_id = tc.commit_id
	 
	 LEFT JOIN tpm_promotion AS tp
	 ON tp.promotion_id = tc.promotion_id
	   
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN map_payment_term_account_rad AS mptar
	 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id
	 
	 WHERE tc.commit_id IN 
	 (
		  SELECT DISTINCT fk_commitment_id
		  FROM ded_deduction_resolution_item AS ddri
		  LEFT JOIN ded_deduction_resolution AS ddr 
		  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
		  LEFT JOIN ded_deduction AS ded
		  ON ddr.fk_deduction_id = ded.pk_deduction_id
		  LEFT JOIN tpm_commit AS tc 
		  ON ddri.fk_commitment_id = tc.commit_id
		  LEFT JOIN tpm_lu_commit_status AS tlcs
		  ON tc.commit_status_id = tlcs.commit_status_id
		  WHERE ded.pk_deduction_id IN 
		  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
		  AND ddr.fk_resolution_status_id = 1
	)
	
	AND tp.promotion_status_id = 6
	GROUP BY tp.promotion_id
) AS table4_prom_data

ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
AND step1_join_data.prom_display_text = table4_prom_data.display_text

AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
, LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
 >= -14
AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
>= -14 
	
	
	
	
	
	

#ded_deduction_item containing only 1000 resolved deduction

SELECT * 
FROM ded_deduction_item AS ddi
WHERE ddi.fk_deduction_id IN 
(
	SELECT * FROM
		(
			SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
			
			INNER JOIN lu_reason_code_rad AS reasoncode
			ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			INNER JOIN lu_reason_category_rad AS reasoncode_category
			ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



			INNER JOIN lu_deduction_status_rad AS deductionstatus
			ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			INNER JOIN lu_deduction_status_system AS systemstatus
			ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			INNER JOIN map_deduction_item_rollup_header AS header
			ON deduction.pk_deduction_id = header.fk_deduction_id
			INNER JOIN map_deduction_item_rollup AS map_item
			ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
			INNER JOIN ded_deduction_resolution AS resolution
			ON header.fk_deduction_id = resolution.fk_deduction_id
			 
			WHERE 

			deduction.fk_reason_code_map_id != -1

			AND pk_reason_category_rad_id IN (126) 

			AND systemstatus.pk_deduction_status_system_id = 4

			AND deduction.fk_deduction_type_id=0

			AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
			AND deduction.fiscal_year=2016

			AND header.fk_resolution_type_id = 4
			AND resolution.fk_resolution_type_id = 4
			AND deduction.fk_deduction_type_id = 0
			
			LIMIT 1000
		) AS suggest_sol		
)





#item_description with their frequencies > 1000 from ddi and tpm_commit




SELECT 
hierarchynode.description AS description_from_tpm_commit,
luitem.description AS lu_item_description, COUNT(*)

FROM ded_deduction AS deduction
#INNER JOIN customer_claim AS claiminfo
#ON deduction.customer_claim_number = claiminfo.claim_number
LEFT JOIN acct_doc_header AS acctdoc
ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
INNER JOIN lu_reason_code_rad AS reasoncode
ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
INNER JOIN lu_reason_category_rad AS reasoncode_category
ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
#Inner join
#INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
INNER JOIN lu_deduction_status_rad AS deductionstatus
ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
INNER JOIN lu_deduction_status_system AS systemstatus
ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

INNER JOIN ded_deduction_item AS item
ON deduction.pk_deduction_id = item.fk_deduction_id
INNER JOIN ded_deduction_resolution AS resolution
ON resolution.fk_deduction_id = deduction.pk_deduction_id
INNER JOIN ded_deduction_resolution_item AS resolveditem
ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
#JOIN WITH commited resolutions
INNER JOIN tpm_commit AS committable
ON committable.commit_id = resolveditem.fk_commitment_id

#inner join product hierarchy master data
INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

#deduction_item_product_hierarchy's description
INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

INNER JOIN tpm_lu_item AS luitem
ON luitem.item_id = item.fk_lu_item_id

#join with resolved promotions
INNER JOIN tpm_promotion AS promotion
ON promotion.promotion_id = committable.promotion_id

WHERE deduction.fk_account_id = 16
AND deduction.fk_reason_code_map_id != -1 AND
resolution.fk_resolution_type_id = 4
AND resolution.fk_resolution_status_id = 1 AND 
reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
AND deduction.fiscal_year = 2016

GROUP BY description_from_tpm_commit,lu_item_description
HAVING COUNT(*) >=1000






#joining item_description with ded_deduction_item based on lu_item_description



SELECT COUNT(*) FROM
(
	SELECT lu_item.description AS ddi_lu_item_desc FROM
	ded_deduction_item AS ddi
	LEFT JOIN tpm_lu_item AS lu_item
	ON lu_item.item_id = ddi.fk_lu_item_id
	
	WHERE ddi.fk_deduction_id IN 
	(
		SELECT * FROM
		(
			SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
			
			INNER JOIN lu_reason_code_rad AS reasoncode
			ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			INNER JOIN lu_reason_category_rad AS reasoncode_category
			ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



			INNER JOIN lu_deduction_status_rad AS deductionstatus
			ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			INNER JOIN lu_deduction_status_system AS systemstatus
			ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			INNER JOIN map_deduction_item_rollup_header AS header
			ON deduction.pk_deduction_id = header.fk_deduction_id
			INNER JOIN map_deduction_item_rollup AS map_item
			ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
			INNER JOIN ded_deduction_resolution AS resolution
			ON header.fk_deduction_id = resolution.fk_deduction_id
			 
			WHERE 

			deduction.fk_reason_code_map_id != -1

			AND pk_reason_category_rad_id IN (126) 

			AND systemstatus.pk_deduction_status_system_id = 4

			AND deduction.fk_deduction_type_id=0

			AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
			AND deduction.fiscal_year=2016

			AND header.fk_resolution_type_id = 4
			AND resolution.fk_resolution_type_id = 4
			AND deduction.fk_deduction_type_id = 0
			
			LIMIT 1000
		) AS suggest_sol		
	)	
) AS ddi_data

INNER JOIN

(
	
	SELECT 
	hierarchynode.description AS description_from_tpm_commit,
	luitem.description AS lu_item_description, COUNT(*) 
	
	FROM ded_deduction AS deduction
	#INNER JOIN customer_claim AS claiminfo
	#ON deduction.customer_claim_number = claiminfo.claim_number
	LEFT JOIN acct_doc_header AS acctdoc
	ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
	INNER JOIN lu_reason_code_rad AS reasoncode
	ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
	INNER JOIN lu_reason_category_rad AS reasoncode_category
	ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
	INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
	#Inner join
	#INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
	INNER JOIN lu_deduction_status_rad AS deductionstatus
	ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
	INNER JOIN lu_deduction_status_system AS systemstatus
	ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

	INNER JOIN ded_deduction_item AS item
	ON deduction.pk_deduction_id = item.fk_deduction_id
	INNER JOIN ded_deduction_resolution AS resolution
	ON resolution.fk_deduction_id = deduction.pk_deduction_id
	INNER JOIN ded_deduction_resolution_item AS resolveditem
	ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
	#JOIN WITH commited resolutions
	INNER JOIN tpm_commit AS committable
	ON committable.commit_id = resolveditem.fk_commitment_id

	#inner join product hierarchy master data
	INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
	ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

	#deduction_item_product_hierarchy's description
	INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
	ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

	INNER JOIN tpm_lu_item AS luitem
	ON luitem.item_id = item.fk_lu_item_id

	#join with resolved promotions
	INNER JOIN tpm_promotion AS promotion
	ON promotion.promotion_id = committable.promotion_id

	WHERE deduction.fk_account_id = 16
	AND deduction.fk_reason_code_map_id != -1 AND
	resolution.fk_resolution_type_id = 4
	AND resolution.fk_resolution_status_id = 1 AND 
	reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
	AND deduction.fiscal_year = 2016

	GROUP BY description_from_tpm_commit,lu_item_description
	HAVING COUNT(*) >=1000

) AS item_desc_data

ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description




#joining item_description(with unit_cost_norm) with ded_deduction_item based on lu_item_description



SELECT * FROM
(
	SELECT ddi.fk_deduction_id AS ddi_ded_id, ddi.unit_cost_norm AS ddi_unit_cost_norm,
	lu_item.description AS ddi_lu_item_desc FROM
	ded_deduction_item AS ddi
	LEFT JOIN tpm_lu_item AS lu_item
	ON lu_item.item_id = ddi.fk_lu_item_id
	
	WHERE ddi.fk_deduction_id IN 
	(
		SELECT * FROM
		(
			SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
			
			INNER JOIN lu_reason_code_rad AS reasoncode
			ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			INNER JOIN lu_reason_category_rad AS reasoncode_category
			ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



			INNER JOIN lu_deduction_status_rad AS deductionstatus
			ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			INNER JOIN lu_deduction_status_system AS systemstatus
			ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			INNER JOIN map_deduction_item_rollup_header AS header
			ON deduction.pk_deduction_id = header.fk_deduction_id
			INNER JOIN map_deduction_item_rollup AS map_item
			ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
			INNER JOIN ded_deduction_resolution AS resolution
			ON header.fk_deduction_id = resolution.fk_deduction_id
			 
			WHERE 

			deduction.fk_reason_code_map_id != -1

			AND pk_reason_category_rad_id IN (126) 

			AND systemstatus.pk_deduction_status_system_id = 4

			AND deduction.fk_deduction_type_id=0

			AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
			AND deduction.fiscal_year=2016

			AND header.fk_resolution_type_id = 4
			AND resolution.fk_resolution_type_id = 4
			AND deduction.fk_deduction_type_id = 0
			
			LIMIT 1000
		) AS suggest_sol		
	)	
) AS ddi_data

INNER JOIN

(
	
	SELECT 
	hierarchynode.description AS description_from_tpm_commit,
	luitem.description AS lu_item_description, COUNT(*) 
	
	FROM ded_deduction AS deduction
	INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
	INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
	INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
	INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
	INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
	INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
	INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
	INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id AND resolveditem.used_per_unit_rate = item.unit_cost_norm
	INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
	INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
	INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
	INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id
	INNER JOIN tpm_promotion AS promotion ON promotion.promotion_id = committable.promotion_id

	WHERE deduction.fk_account_id = 16
	AND deduction.fk_reason_code_map_id != -1 AND
	resolution.fk_resolution_type_id = 4
	AND resolution.fk_resolution_status_id = 1 AND 
	reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
	AND deduction.fiscal_year = 2016

	GROUP BY description_from_tpm_commit,lu_item_description
	HAVING COUNT(*) >= 150

) AS item_desc_data

ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description





#Intermediate Table by joining deal_reference and commit_id

SELECT mdir.deal_reference, tc.commit_id, tlphn.description AS commit_description,
luitem.description AS lu_item_description , ddi.product_hierarchy1_id AS ddi_product_hierarchy,
tc.product_hierarchy_id AS commit_hierarchy_id,
COUNT(*)

FROM map_deduction_item_rollup AS mdir
INNER JOIN ded_deduction_item AS ddi
ON mdir.fk_deduction_item_id = ddi.pk_deduction_item_id

INNER JOIN ded_deduction AS dd
ON dd.pk_deduction_id = ddi.fk_deduction_id

INNER JOIN ded_deduction_resolution AS ddr
ON ddr.fk_deduction_id = dd.pk_deduction_id

INNER JOIN ded_deduction_resolution_item AS ddri
ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id

INNER JOIN tpm_commit AS tc 
ON 
#tc.commit_id = ddri.fk_commitment_id and 
mdir.deal_reference = tc.commit_id

INNER JOIN tpm_lu_product_hierarchy_node AS tlphn
ON tc.product_hierarchy_id = tlphn.product_hierarchy_node_id

INNER JOIN tpm_lu_item AS luitem
ON luitem.item_id = ddi.fk_lu_item_id

INNER JOIN lu_reason_code_rad AS reasoncode
ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
INNER JOIN lu_reason_category_rad AS reasoncode_category
ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
INNER JOIN map_reason_code_account_rad AS map_account 
ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
INNER JOIN lu_deduction_status_rad AS deductionstatus
ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
INNER JOIN lu_deduction_status_system AS systemstatus
ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id


WHERE 
dd.fk_reason_code_map_id != -1 
AND reasoncode_category.shortname = "Trade"  
AND systemstatus.pk_deduction_status_system_id = 4 
AND dd.fk_deduction_type_id=0
AND ddr.fk_resolution_type_id = 4 
AND ddr.fk_resolution_status_id = 1
AND ddi.product_hierarchy1_id = tc.product_hierarchy_id
AND dd.fiscal_year=2016
 
GROUP BY commit_description, lu_item_description
HAVING COUNT(*) >= 1






#tpm_commit_description and lu_item_description from ddi where product_hierarhy_node = commit_hierarchy_node


SELECT 
 hierarchynode.description AS description_from_tpm_commit,
 luitem.description AS lu_item_description,
  
 COUNT(*) 
 
 FROM ded_deduction AS deduction
 #INNER JOIN customer_claim AS claiminfo
 #ON deduction.customer_claim_number = claiminfo.claim_number
 LEFT JOIN acct_doc_header AS acctdoc
 ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
 INNER JOIN lu_reason_code_rad AS reasoncode
 ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
 INNER JOIN lu_reason_category_rad AS reasoncode_category
 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
 INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
 #Inner join
 #INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
 INNER JOIN lu_deduction_status_rad AS deductionstatus
 ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
 INNER JOIN lu_deduction_status_system AS systemstatus
 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

 INNER JOIN ded_deduction_item AS item
 ON deduction.pk_deduction_id = item.fk_deduction_id
 INNER JOIN ded_deduction_resolution AS resolution
 ON resolution.fk_deduction_id = deduction.pk_deduction_id
 INNER JOIN ded_deduction_resolution_item AS resolveditem
 ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
 #JOIN WITH commited resolutions
 INNER JOIN tpm_commit AS committable
 ON committable.commit_id = resolveditem.fk_commitment_id

 #inner join product hierarchy master data
 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
 ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

 #deduction_item_product_hierarchy's description
 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
 ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

 INNER JOIN tpm_lu_item AS luitem
 ON luitem.item_id = item.fk_lu_item_id

 #join with resolved promotions
 INNER JOIN tpm_promotion AS promotion
 ON promotion.promotion_id = committable.promotion_id

 WHERE deduction.fk_account_id = 16
 AND deduction.fk_reason_code_map_id != -1 AND
 resolution.fk_resolution_type_id = 4
 AND resolution.fk_resolution_status_id = 1 AND 
 reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
 AND deduction.fiscal_year = 2016
 AND committable.product_hierarchy_id = item.product_hierarchy1_id
 
 GROUP BY 1, 2







#joining ddi and description table (description table is retreived by matching ddi.product_hier1=commit.hierarchy_id)



SELECT * FROM
(
	SELECT lu_item.description AS ddi_lu_item_desc FROM
	ded_deduction_item AS ddi
	LEFT JOIN tpm_lu_item AS lu_item
	ON lu_item.item_id = ddi.fk_lu_item_id
	
	WHERE ddi.fk_deduction_id IN 
	(
		SELECT * FROM
		(
			SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
			
			INNER JOIN lu_reason_code_rad AS reasoncode
			ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			INNER JOIN lu_reason_category_rad AS reasoncode_category
			ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



			INNER JOIN lu_deduction_status_rad AS deductionstatus
			ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			INNER JOIN lu_deduction_status_system AS systemstatus
			ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			INNER JOIN map_deduction_item_rollup_header AS header
			ON deduction.pk_deduction_id = header.fk_deduction_id
			INNER JOIN map_deduction_item_rollup AS map_item
			ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
			INNER JOIN ded_deduction_resolution AS resolution
			ON header.fk_deduction_id = resolution.fk_deduction_id
			 
			WHERE 

			deduction.fk_reason_code_map_id != -1

			AND pk_reason_category_rad_id IN (126) 

			AND systemstatus.pk_deduction_status_system_id = 4

			AND deduction.fk_deduction_type_id=0

			AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
			AND deduction.fiscal_year=2016

			AND header.fk_resolution_type_id = 4
			AND resolution.fk_resolution_type_id = 4
			AND deduction.fk_deduction_type_id = 0
			
			LIMIT 1000
		) AS suggest_sol		
	)	
) AS ddi_data

LEFT JOIN

(	
	 SELECT 
	 hierarchynode.description AS description_from_tpm_commit,
	 luitem.description AS lu_item_description,
	 COUNT(*) 
	 
	 FROM ded_deduction AS deduction
	 #INNER JOIN customer_claim AS claiminfo
	 #ON deduction.customer_claim_number = claiminfo.claim_number
	 LEFT JOIN acct_doc_header AS acctdoc
	 ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
	 INNER JOIN lu_reason_code_rad AS reasoncode
	 ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
	 INNER JOIN lu_reason_category_rad AS reasoncode_category
	 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
	 INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
	 #Inner join
	 #INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
	 INNER JOIN lu_deduction_status_rad AS deductionstatus
	 ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
	 INNER JOIN lu_deduction_status_system AS systemstatus
	 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

	 INNER JOIN ded_deduction_item AS item
	 ON deduction.pk_deduction_id = item.fk_deduction_id
	 INNER JOIN ded_deduction_resolution AS resolution
	 ON resolution.fk_deduction_id = deduction.pk_deduction_id
	 INNER JOIN ded_deduction_resolution_item AS resolveditem
	 ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
	 #JOIN WITH commited resolutions
	 INNER JOIN tpm_commit AS committable
	 ON committable.commit_id = resolveditem.fk_commitment_id

	 #inner join product hierarchy master data
	 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
	 ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

	 #deduction_item_product_hierarchy's description
	 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
	 ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

	 INNER JOIN tpm_lu_item AS luitem
	 ON luitem.item_id = item.fk_lu_item_id

	 #join with resolved promotions
	 INNER JOIN tpm_promotion AS promotion
	 ON promotion.promotion_id = committable.promotion_id

	 WHERE deduction.fk_account_id = 16
	 AND deduction.fk_reason_code_map_id != -1 AND
	 resolution.fk_resolution_type_id = 4
	 AND resolution.fk_resolution_status_id = 1 AND 
	 reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
	 AND deduction.fiscal_year = 2016
	 AND committable.product_hierarchy_id = item.product_hierarchy1_id
	 
	 GROUP BY 1, 2

) AS item_desc_data

ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description






#big_table join with ddi_join_desc


SELECT COUNT(*) FROM

(

	SELECT * FROM
	(
		SELECT
		table3_ded_data.pk_deduction_id,
		table3_ded_data.payterms_desc_new,
		table_1_display_text.ded_display_text,
		table_1_display_text.prom_display_text,
		table3_ded_data.deduction_created_date_min,
		table3_ded_data.deduction_created_date_max,
		table3_ded_data.customer_claim_date_min,
		table3_ded_data.customer_claim_date_max,
		table3_ded_data.invoice_date_min,
		table3_ded_data.invoice_date_max,
		
		table3_ded_data.promortion_execution_from_date_max,
		table3_ded_data.promortion_execution_from_date_min,
		table3_ded_data.promotion_execution_to_date_max,
		table3_ded_data.promotion_execution_to_date_min
		
		FROM
		(
			SELECT ded_data.payterms_desc,  ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
			(
				 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
				 dd.fk_customer_map_id AS cust_map_id_ded,
				 mcar.display_text AS ded_display_text,
				 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
				 mcar.fk_parent_customer_map_id, c.name,
				 dd.deduction_created_date, dd.customer_claim_date 
				 FROM ded_deduction AS dd
				 LEFT JOIN map_customer_account_rad AS mcar
				 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
				 LEFT JOIN customer AS c
				 ON c.customer_id = mcar.fk_customer_id

				 LEFT JOIN ded_deduction_resolution AS ddr
				 ON dd.pk_deduction_id = ddr.fk_deduction_id
				 LEFT JOIN lu_reason_code_rad AS reasoncode
				 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				 LEFT JOIN lu_reason_category_rad AS reasoncode_category
				 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				 LEFT JOIN map_reason_code_account_rad AS map_account 
				 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

				 LEFT JOIN lu_deduction_status_rad AS deductionstatus
				 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				 LEFT JOIN lu_deduction_status_system AS systemstatus
				 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				 WHERE 
				 #dd.fiscal_year=2016
				 systemstatus.pk_deduction_status_system_id = 4
				 AND pk_reason_category_rad_id IN (126)
				 AND ddr.fk_resolution_type_id = 4
				 AND ddr.fk_resolution_status_id = 1
				 AND dd.fk_deduction_type_id = 0
				 AND dd.pk_deduction_id IN 
				 (
					SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
				 )
			 GROUP BY dd.pk_deduction_id
			)AS ded_data

			LEFT JOIN
			(
				 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
				 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
				 mcar.display_text AS prom_display_text,
				 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
				 mcar.fk_parent_customer_map_id, c.name, 
				 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
				 ddri.fk_deduction_id AS ded_id_ddri
				  
				 FROM ded_deduction_resolution AS ddr
				 LEFT JOIN ded_deduction_resolution_item AS ddri
				 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
				 
				 LEFT JOIN tpm_commit AS tc
				 ON ddri.fk_commitment_id = tc.commit_id
				 
				 LEFT JOIN tpm_promotion AS tp
				 ON tp.promotion_id = tc.promotion_id
				   
				 LEFT JOIN map_customer_account_rad AS mcar
				 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
				 LEFT JOIN map_payment_term_account_rad AS mptar
				 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
				 LEFT JOIN customer AS c
				 ON c.customer_id = mcar.fk_customer_id
				 
				 WHERE tc.commit_id IN 
				 (
					  SELECT DISTINCT fk_commitment_id
					  FROM ded_deduction_resolution_item AS ddri
					  LEFT JOIN ded_deduction_resolution AS ddr 
					  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
					  LEFT JOIN ded_deduction AS ded
					  ON ddr.fk_deduction_id = ded.pk_deduction_id
					  LEFT JOIN tpm_commit AS tc 
					  ON ddri.fk_commitment_id = tc.commit_id
					  LEFT JOIN tpm_lu_commit_status AS tlcs
					  ON tc.commit_status_id = tlcs.commit_status_id
					  WHERE ded.pk_deduction_id IN 
					  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
					  AND ddr.fk_resolution_status_id = 1
				)
			 
			) AS prom_data

			ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
			GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
			HAVING COUNT(*) >= 500
		) AS table_1_display_text

		LEFT JOIN
		(
			 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
			 
			 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
			 
			 dd.fk_customer_map_id AS cust_map_id_ded,
			 mcar.display_text AS ded_display_text,
			 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
			 mcar.fk_parent_customer_map_id, c.name,
			 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
			 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
			 
			 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
			 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2000-01-01' ELSE dd.deduction_created_date END) AS deduction_created_date_max,
			 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
			 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2000-01-01' ELSE dd.customer_claim_date END) AS customer_claim_date_max,
			 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
			 (CASE WHEN ISNULL(dd.invoice_date) THEN '2000-01-01' ELSE dd.invoice_date END) AS invoice_date_max,
			 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
			 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2000-01-01' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_max,
			 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2017-12-31' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_min,
			 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
	 
					 
			 FROM ded_deduction AS dd
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id

			 LEFT JOIN ded_deduction_resolution AS ddr
			 ON dd.pk_deduction_id = ddr.fk_deduction_id
			 LEFT JOIN lu_reason_code_rad AS reasoncode
			 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			 LEFT JOIN lu_reason_category_rad AS reasoncode_category
			 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			 LEFT JOIN map_reason_code_account_rad AS map_account 
			 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

			 LEFT JOIN lu_deduction_status_rad AS deductionstatus
			 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			 LEFT JOIN lu_deduction_status_system AS systemstatus
			 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			 WHERE 
			 dd.fiscal_year=2016
			 AND systemstatus.pk_deduction_status_system_id = 4		
			 AND pk_reason_category_rad_id IN (126)
			 AND ddr.fk_resolution_type_id = 4
			 AND ddr.fk_resolution_status_id = 1
			 AND dd.fk_deduction_type_id = 0
			 AND dd.pk_deduction_id IN 
			 (
				SELECT * FROM
				(
					SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
					
					INNER JOIN lu_reason_code_rad AS reasoncode
					ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
					INNER JOIN lu_reason_category_rad AS reasoncode_category
					ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
					INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



					INNER JOIN lu_deduction_status_rad AS deductionstatus
					ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
					INNER JOIN lu_deduction_status_system AS systemstatus
					ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

					INNER JOIN map_deduction_item_rollup_header AS header
					ON deduction.pk_deduction_id = header.fk_deduction_id
					INNER JOIN map_deduction_item_rollup AS map_item
					ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
					INNER JOIN ded_deduction_resolution AS resolution
					ON header.fk_deduction_id = resolution.fk_deduction_id
					 
					WHERE 

					deduction.fk_reason_code_map_id != -1

					AND pk_reason_category_rad_id IN (126) 

					AND systemstatus.pk_deduction_status_system_id = 4

					AND deduction.fk_deduction_type_id=0

					AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
					AND deduction.fiscal_year=2016

					AND header.fk_resolution_type_id = 4
					AND resolution.fk_resolution_type_id = 4
					AND deduction.fk_deduction_type_id = 0
					
					LIMIT 1000
				) AS suggest_sol		
			 )
			GROUP BY dd.pk_deduction_id
		) AS table3_ded_data
		 
		 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text

	)AS step1_join_data

	INNER JOIN 
	(
		 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
		 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
		 
		 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,

		 
		 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
		 mcar.fk_parent_customer_map_id, c.name, 
		 tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, 
		 ddr.fk_deduction_id AS ded_id_ddr,
		 ddri.fk_deduction_id AS ded_id_ddri,
		 
		 
		 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
		 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2000-01-01' ELSE tp.ship_start_date END) AS ship_start_date_max,
		 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
		 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2000-01-01' ELSE tp.consumption_start_date END) AS consumption_start_date_max,
		 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2017-12-31' ELSE tp.ship_end_date END) AS ship_end_date_min,
		 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
		 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2017-12-31' ELSE tp.consumption_end_date END) AS consumption_end_date_min,
		 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
		 
		  
		 FROM ded_deduction_resolution AS ddr
		 LEFT JOIN ded_deduction_resolution_item AS ddri
		 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
		 
		 LEFT JOIN tpm_commit AS tc
		 ON ddri.fk_commitment_id = tc.commit_id
		 
		 LEFT JOIN tpm_promotion AS tp
		 ON tp.promotion_id = tc.promotion_id
		   
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN map_payment_term_account_rad AS mptar
		 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id
		 
		 WHERE tc.commit_id IN 
		 (
			  SELECT DISTINCT fk_commitment_id
			  FROM ded_deduction_resolution_item AS ddri
			  LEFT JOIN ded_deduction_resolution AS ddr 
			  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
			  LEFT JOIN ded_deduction AS ded
			  ON ddr.fk_deduction_id = ded.pk_deduction_id
			  LEFT JOIN tpm_commit AS tc 
			  ON ddri.fk_commitment_id = tc.commit_id
			  LEFT JOIN tpm_lu_commit_status AS tlcs
			  ON tc.commit_status_id = tlcs.commit_status_id
			  WHERE ded.pk_deduction_id IN 
			  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
			  AND ddr.fk_resolution_status_id = 1
		)
		
		AND tp.promotion_status_id = 6
		GROUP BY tp.promotion_id
	) AS table4_prom_data

	ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
	AND step1_join_data.prom_display_text = table4_prom_data.display_text

	AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
	, LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
	 >= -14
	AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
	,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
	>= -14 
		
)AS big_table




LEFT JOIN

#ddi_with_desc

(
	
	SELECT * FROM
	(
		SELECT ddi.fk_deduction_id, lu_item.description AS ddi_lu_item_desc FROM
		ded_deduction_item AS ddi
		LEFT JOIN tpm_lu_item AS lu_item
		ON lu_item.item_id = ddi.fk_lu_item_id
		
		WHERE ddi.fk_deduction_id IN 
		(
			SELECT * FROM
			(
				SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
				
				INNER JOIN lu_reason_code_rad AS reasoncode
				ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				INNER JOIN lu_reason_category_rad AS reasoncode_category
				ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



				INNER JOIN lu_deduction_status_rad AS deductionstatus
				ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				INNER JOIN lu_deduction_status_system AS systemstatus
				ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				INNER JOIN map_deduction_item_rollup_header AS header
				ON deduction.pk_deduction_id = header.fk_deduction_id
				INNER JOIN map_deduction_item_rollup AS map_item
				ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
				INNER JOIN ded_deduction_resolution AS resolution
				ON header.fk_deduction_id = resolution.fk_deduction_id
				 
				WHERE 

				deduction.fk_reason_code_map_id != -1

				AND pk_reason_category_rad_id IN (126) 

				AND systemstatus.pk_deduction_status_system_id = 4

				AND deduction.fk_deduction_type_id=0

				AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
				AND deduction.fiscal_year=2016

				AND header.fk_resolution_type_id = 4
				AND resolution.fk_resolution_type_id = 4
				AND deduction.fk_deduction_type_id = 0
				
				LIMIT 1000
			) AS suggest_sol		
		)	
	) AS ddi_data

	LEFT JOIN

	(	
		 SELECT 
		 hierarchynode.description AS description_from_tpm_commit,
		 luitem.description AS lu_item_description,
		 COUNT(*) 
		 
		 FROM ded_deduction AS deduction
		 #INNER JOIN customer_claim AS claiminfo
		 #ON deduction.customer_claim_number = claiminfo.claim_number
		 LEFT JOIN acct_doc_header AS acctdoc
		 ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
		 INNER JOIN lu_reason_code_rad AS reasoncode
		 ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 INNER JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
		 #Inner join
		 #INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
		 INNER JOIN lu_deduction_status_rad AS deductionstatus
		 ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 INNER JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 INNER JOIN ded_deduction_item AS item
		 ON deduction.pk_deduction_id = item.fk_deduction_id
		 INNER JOIN ded_deduction_resolution AS resolution
		 ON resolution.fk_deduction_id = deduction.pk_deduction_id
		 INNER JOIN ded_deduction_resolution_item AS resolveditem
		 ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
		 #JOIN WITH commited resolutions
		 INNER JOIN tpm_commit AS committable
		 ON committable.commit_id = resolveditem.fk_commitment_id

		 #inner join product hierarchy master data
		 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
		 ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

		 #deduction_item_product_hierarchy's description
		 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
		 ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

		 INNER JOIN tpm_lu_item AS luitem
		 ON luitem.item_id = item.fk_lu_item_id

		 #join with resolved promotions
		 INNER JOIN tpm_promotion AS promotion
		 ON promotion.promotion_id = committable.promotion_id

		 WHERE deduction.fk_account_id = 16
		 AND deduction.fk_reason_code_map_id != -1 AND
		 resolution.fk_resolution_type_id = 4
		 AND resolution.fk_resolution_status_id = 1 AND 
		 reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
		 AND deduction.fiscal_year = 2016
		 AND committable.product_hierarchy_id = item.product_hierarchy1_id
		 
		 GROUP BY 1, 2

	) AS item_desc_data

	ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description


) AS ddi_with_desc

ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
		




#ddi+desc+commit


SELECT COUNT(*) FROM
(
	SELECT * FROM
	(
		SELECT lu_item.description AS ddi_lu_item_desc ,ddi.product_hierarchy1_id AS ddi_prod_hier1  
		FROM
		ded_deduction_item AS ddi
		LEFT JOIN tpm_lu_item AS lu_item
		ON lu_item.item_id = ddi.fk_lu_item_id
		
		WHERE ddi.fk_deduction_id IN 
		(
			SELECT * FROM
			(
				SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
				
				INNER JOIN lu_reason_code_rad AS reasoncode
				ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				INNER JOIN lu_reason_category_rad AS reasoncode_category
				ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



				INNER JOIN lu_deduction_status_rad AS deductionstatus
				ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				INNER JOIN lu_deduction_status_system AS systemstatus
				ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				INNER JOIN map_deduction_item_rollup_header AS header
				ON deduction.pk_deduction_id = header.fk_deduction_id
				INNER JOIN map_deduction_item_rollup AS map_item
				ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
				INNER JOIN ded_deduction_resolution AS resolution
				ON header.fk_deduction_id = resolution.fk_deduction_id
				 
				WHERE 

				deduction.fk_reason_code_map_id != -1

				AND pk_reason_category_rad_id IN (126) 

				AND systemstatus.pk_deduction_status_system_id = 4

				AND deduction.fk_deduction_type_id=0

				AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
				AND deduction.fiscal_year=2016

				AND header.fk_resolution_type_id = 4
				AND resolution.fk_resolution_type_id = 4
				AND deduction.fk_deduction_type_id = 0
				
				LIMIT 1000
			) AS suggest_sol		
		)	
	) AS ddi_data

	INNER JOIN

	(	
		 SELECT 
		 hierarchynode.description AS description_from_tpm_commit,
		 luitem.description AS lu_item_description,
		 COUNT(*) 
		 
		 FROM ded_deduction AS deduction
		 #INNER JOIN customer_claim AS claiminfo
		 #ON deduction.customer_claim_number = claiminfo.claim_number
		 LEFT JOIN acct_doc_header AS acctdoc
		 ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
		 INNER JOIN lu_reason_code_rad AS reasoncode
		 ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 INNER JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
		 #Inner join
		 #INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
		 INNER JOIN lu_deduction_status_rad AS deductionstatus
		 ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 INNER JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 INNER JOIN ded_deduction_item AS item
		 ON deduction.pk_deduction_id = item.fk_deduction_id
		 INNER JOIN ded_deduction_resolution AS resolution
		 ON resolution.fk_deduction_id = deduction.pk_deduction_id
		 INNER JOIN ded_deduction_resolution_item AS resolveditem
		 ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
		 #JOIN WITH commited resolutions
		 INNER JOIN tpm_commit AS committable
		 ON committable.commit_id = resolveditem.fk_commitment_id

		 #inner join product hierarchy master data
		 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
		 ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

		 #deduction_item_product_hierarchy's description
		 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
		 ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

		 INNER JOIN tpm_lu_item AS luitem
		 ON luitem.item_id = item.fk_lu_item_id

		 #join with resolved promotions
		 INNER JOIN tpm_promotion AS promotion
		 ON promotion.promotion_id = committable.promotion_id

		 WHERE deduction.fk_account_id = 16
		 AND deduction.fk_reason_code_map_id != -1 AND
		 resolution.fk_resolution_type_id = 4
		 AND resolution.fk_resolution_status_id = 1 AND 
		 reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
		 AND deduction.fiscal_year = 2016
		 AND committable.product_hierarchy_id = item.product_hierarchy1_id
		 
		 GROUP BY 1, 2

	) AS item_desc_data

	ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description


) AS ddi_join_desc

INNER JOIN
(

	SELECT tc.commit_id AS commit_id1, tc.product_hierarchy_id AS prod_hier_id_commit1,
	hierarchynode.description AS commit_desc1 
	FROM ded_deduction_resolution_item AS ddri
	LEFT JOIN ded_deduction_resolution AS ddr 
	ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id

	LEFT JOIN tpm_commit AS tc 
	ON ddri.fk_commitment_id = tc.commit_id

	LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode
	ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

	LEFT JOIN tpm_promotion AS tp
	ON tp.promotion_id = tc.promotion_id

	WHERE tc.commit_status_id = 6
	AND ddr.fk_resolution_status_id = 1
	AND ddr.fk_resolution_type_id = 4

	AND tp.promotion_id IN 
	(
		865002, 847050, 896930, 692727, 896927, 862092, 865005, 865233, 628134, 864549, 646173, 1070903, 862419, 1176481, 902774, 847059, 957122, 578967, 646227, 862842, 1224288, 947696, 946721, 1062686, 986090, 897068, 696369, 846444, 579171, 645570, 579429, 864210, 646143, 1227323, 862401, 948401, 1062722, 1109096, 1428659, 897212, 696276, 846546, 955880, 845964, 864564, 1359452, 626904, 646197, 862443, 1119359, 990587, 718374, 964901, 870396, 1189877, 697254, 897023, 696891, 957941, 846420, 579042, 645546, 862860, 1224303, 947681, 679182, 862920, 949622, 948323, 903257, 946760, 1077431, 628488, 579357, 846357, 626802, 1404515, 897170, 1050065, 579588, 864267, 646221, 1224285, 947693, 946709, 1062680, 964928, 1077164, 986087, 846612, 1186538, 628440, 579156, 864138, 1224315, 864528, 579408, 880259, 947735, 1062719, 989954, 897857, 896969, 846378, 628170, 864012, 1062782, 1119356, 990485, 718416, 898007, 897017, 846183, 627417, 579003, 646254, 1224300, 947678, 949616, 709071, 579255, 646116, 645840, 864705, 579498, 864225, 646164, 645921, 1062731, 1338776, 896843, 897236, 846393, 846156, 579582, 646218, 646017, 645732, 862452, 1224282, 966653, 897059, 627870, 579138, 1224312, 579393, 646131, 949178, 862392, 947732, 989933, 887873, 1293542, 628500, 897191, 626892, 579522, 646182, 1070927, 1062779, 1119338, 1272602, 628284, 578994, 645771, 1224294, 986099, 897080, 846456, 579231, 579486, 646155, 1070891, 645633, 1062728, 944823, 1404494, 865425, 846888, 1049249, 957767, 864570, 626937, 579561, 645729, 1224222, 964910, 846948, 1049408, 846432, 846201, 627681, 864465, 579132, 1224309, 904001, 645861, 1122716, 946778, 897104, 1293539, 955817, 628497, 897182, 847065, 696687, 628149, 626886, 645951, 1070915, 862422, 948779, 1119335, 990479, 897845, 696879, 846909, 957125, 846579, 846174, 1272584, 864741, 628278, 578991, 645765, 862467, 1224291, 679053, 946727, 847005, 627924, 579195, 703824, 626652, 579453, 953348, 862938, 1062725, 944820, 896834, 897227, 896984, 864408, 645999, 880379, 846936, 1049399, 846759, 846429, 864606, 579054, 645780, 1224306, 645846, 946775, 989927, 1077440, 579372, 740397, 1216545, 1109306, 858210, 1212956, 1130012, 740391, 776535, 1213742, 1052858, 1263740, 1041068, 1174133, 858204, 1130027, 740709, 644109, 776070, 984347, 1355936, 646443, 1038230, 776532, 1052852, 1123235, 1178180, 1175285, 1072613, 1355933, 688173, 776124, 1212965, 1129892, 1041053, 644124, 1029202, 646641, 643908, 988538, 1070003, 858213, 1129889, 646434, 1026395, 1123229, 858375, 1034720, 644412, 986156, 696873, 1104770, 734694, 690720, 1034912, 880160, 878699, 690762, 1050365, 880976, 992882, 897824, 734691, 964832, 880175, 1130498, 897536, 880358, 734313, 697248, 690756, 879044, 1038365, 1036676, 992318, 934757, 880496, 881237, 697035, 734703, 878693, 1120232, 897551, 697083, 696198, 1027019, 879008, 697269, 934754, 880169, 690774, 992276, 696516, 967349, 718401, 734697, 967412, 880187, 881333, 1120229, 1027013, 879251, 690768, 878786, 697020, 1043081, 944105, 966140, 677970, 1020656, 678153, 713412, 678306, 678453, 678048, 728190, 715878, 973064, 1040006, 678303, 714408, 678441, 713430, 714783, 678243, 677958, 973145, 678435, 714468, 1047491, 776346, 858180, 1036694, 1034894, 1112126, 1112303, 716469, 727356, 716496, 1111832, 660141, 955034, 1112669, 1112360, 698577, 636648, 1043942, 1112399, 1112114, 683898, 1112174, 984185, 935417, 1112381, 684219, 699504, 1111898, 697917, 983834, 639660, 1112660, 1112342, 1112396, 1111871, 698133, 684234, 984254, 683724, 983939, 953726, 641166, 1111949, 955043, 953645, 1112378, 698217, 983888, 954956, 1112414, 1111889, 697914, 984266, 683502, 935234, 699012, 1112639, 1112336, 953777, 974345, 1112102, 1112156, 1111856, 636804, 947453, 974456, 640011, 1112684, 661134, 1043783, 974483, 1112411, 1112129, 1111886, 1112609, 1112315, 983858, 983714, 1112423, 1043780, 974480, 1112177, 1111883, 684246, 1111982, 1111700, 983894, 1112420, 1112147, 1112498, 1112246, 698505, 947444, 639987, 1112015, 661113, 683592, 983723, 1112462, 698136, 984257, 983852, 698226, 636708, 683847, 716466, 1112417, 1112144, 1112495, 660138, 935237, 639267, 699018, 1112012, 974447, 1111718, 1112447, 639678, 1112261, 699498, 1112477, 641205, 1111994, 636639, 947534, 1112393, 1111712, 683628, 983936, 1112252, 984176, 955040, 1112375, 1112036, 935438, 954953, 727341, 1112471, 697911, 697746, 984263, 955025, 1111985, 983987, 953774, 974342, 1112390, 1111703, 716499, 953720, 1112150, 1112501, 1112249, 953639, 1112372, 1043945, 953705, 1113218, 684210, 1112912, 639933, 684498, 953654, 974306, 974465, 1113485, 1113182, 698394, 637191, 1026764, 984065, 955001, 639111, 1113248, 1112954, 1113215, 984230, 636630, 697566, 983981, 726993, 955103, 716148, 1113650, 1113233, 1112942, 974525, 1113416, 1113089, 698025, 935282, 698253, 660054, 1043813, 1113680, 1113296, 699186, 983849, 983705, 1113140, 684375, 1113635, 1113224, 1112927, 698727, 716475, 683718, 955010, 639621, 1113272, 697560, 1043915, 953681, 641457, 984209, 1113221, 1112918, 661077, 684156, 685125, 935819, 983777, 983933, 947405, 1113659, 1112867, 953756, 947288, 1113440, 1113122, 1112402, 1111751, 1113314, 1112465, 983945, 974516, 1112579, 698541, 1043927, 953771, 1112387, 984245, 1043798, 953717, 683517, 699030, 698355, 955118, 974351, 641103, 1111748, 1111880, 984119, 1113308, 1113368, 1112567, 697770, 935270, 1112084, 698046, 683616, 954959, 983798, 1111811, 1113338, 683514, 955031, 953633, 639903, 636645, 983864, 716271, 974474, 1112111, 1113362, 661047, 983978, 1112060, 1112132, 1111799, 697689, 1113332, 1112231, 984128, 716430, 1113674, 1112444, 1113359, 935252, 639567, 984236, 1113632, 1111760, 1113317, 1112213, 636609, 947486, 639375, 1112096, 1111835, 1113347, 660153, 684135, 727449, 698736, 1112030, 1113563, 636606, 1113014, 698721, 641136, 1112846, 661029, 984134, 1113422, 684363, 984077, 1113500, 1112774, 660111, 983942, 639630, 947480, 1112999, 1113143, 683685, 935678, 698280, 983960, 684360, 953780, 983783, 716478, 1113497, 1113212, 955013, 1112993, 697563, 684144, 727455, 953684, 984212, 984239, 1043792, 953711, 974522, 699207, 935279, 1043933, 955112, 1113491, 1113194, 697644, 716157, 1112981, 983846, 698034, 974357, 1112786, 637245, 1113398, 974468, 955004, 639867, 1113257, 698367, 716484, 1114409, 1112777, 641412, 1114541, 1114307, 1114094, 1113887, 984218, 683850, 983801, 947390, 1114280, 684264, 659910, 1113110, 935801, 983867, 954986, 1113905, 661353, 684102, 1114535, 1114295, 697953, 640344, 1113884, 698745, 1112801, 1114265, 1114568, 1114331, 1113866, 953672, 1113902, 1112768, 1114616, 955100, 984098, 983924, 1112789, 698439, 698097, 698310, 637092, 953747, 974405, 1114325, 1113077, 716220, 955067, 974315, 1113896, 1112753, 684231, 974498, 638997, 699267, 1113827, 1113065, 984191, 726999, 953693, 1113893, 684093, 640206, 1114286, 697923, 983696, 1043912, 637170, 935288, 716136, 1081124, 698262, 1080929, 683736, 947417, 1083854, 1082729, 1084457, 955106, 1083572, 1083008, 726996, 697506, 983930, 1084010, 1081202, 661413, 983840, 953753, 974528, 1084391, 1083464, 698028, 935285, 1083617, 639597, 1109156, 955019, 1083122, 639927, 1081352, 983708, 974462, 1081421, 984215, 935813, 697503, 954998, 1082660, 1081181, 1083779, 1083449, 1119515, 1084475, 1083260, 1082969, 684168, 1083596, 1082801, 1081067, 984227, 1083113, 1082684, 1043918, 1084451, 698382, 660078, 1083674, 1083395, 1082372, 1080863, 1083140, 1084166, 684450, 684096, 1043810, 1082393, 639120, 1081517, 1082204, 1084436, 1083923, 1083548, 1083299, 1082990, 699231, 953708, 1083059, 1082642, 1083440, 1083245, 1082237, 636918, 974309, 716472, 1084235, 1083344, 698754, 984068, 983810, 1080896, 636621, 983966, 1084493, 641445, 1083296, 1080998, 953678, 1083989, 1083632, 1083056, 1082633, 697527, 1083437, 640263, 1083125, 1084157, 1083233, 1081355, 983711, 1199543, 1084232, 1083329, 639009, 1081424, 698748, 684090, 1083683, 1083413, 1080890, 983963, 1084478, 1083893, 1083272, 1082984, 699219, 953675, 727017, 953702, 1083044, 1082804, 1082342, 1081088, 683733, 1083845, 698328, 636912, 1043921, 1084454, 685119, 1026758, 684087, 983927, 1082375, 698445, 684126, 953750, 1084382, 1083884, 1082339, 1083485, 1105046, 974459, 684216, 684084, 716142, 954995, 1083068, 639606, 1081178, 1080935, 660126, 1083764, 641427, 697989, 1083359, 1081475, 1109105, 984224, 984071, 935822, 953612, 947408, 636624, 1084496, 1081004, 935291, 955097, 716487, 1083389, 1081154, 661365, 1199555, 1109099, 984221, 1043804, 1084013, 1082669, 1082387, 1119521, 983843, 974531, 1083545, 698031, 905762, 887918, 870405, 887852, 905720, 887417, 870582, 1218389, 955667, 955943, 847017, 864738, 864270, 847002, 846786, 1131302, 953345, 862935, 865413, 864405, 864015, 846756, 864228, 864207, 846915, 1186520, 862917, 948320, 865215, 864573, 905804, 953285, 847068, 846876, 864702, 1129838, 864609, 864132, 948338, 847026, 864522, 1176490, 953222, 846885, 845967, 1173392, 864462, 1218287, 776097, 776073, 1176682, 1218284, 1070831, 776331, 1218653, 1218305, 858771, 972527, 1070852, 1218161, 1212959, 1296011, 1227338, 858030, 1226201, 1026881, 753891, 753783, 753486, 753621, 753309, 753720, 1168301, 753771, 1026512, 753669, 1131230, 1131215, 1131509, 1083101, 1082522, 1083089, 1082702, 1083539, 1186403, 1181738, 1187990, 1175225, 1083836, 1083311, 1186667, 1082165, 1083590, 1081217, 1080962, 1121075, 1083476, 1187999, 1120499, 1083734, 1082168, 1083530, 1186391, 1121090, 1083827, 1186658, 1082894, 1180397, 1081205, 1080953, 846771, 955865, 1227110, 1131170, 887510, 955673, 1131776, 887756, 955874, 1173383, 949229, 955931, 955928, 948332, 1212947, 1040165, 776109, 1201601, 881282, 1036628, 1195907, 1184783, 1083746, 1184732, 1083713, 864447, 1040222, 1130039, 887885, 846882, 1293617, 864723, 1040201, 1040237, 1173386, 1040336, 1040381, 902762, 1040219, 862932, 956609, 847074, 1295660, 864243, 846750, 1040231, 946736, 864651, 863970, 846729, 1293197, 1040216, 953339, 1040348, 864396, 1298810, 1293227, 864594, 953225, 1040228, 946733, 847008, 862914, 1040372, 1293194, 864255, 953276, 1040345, 949172, 846873, 864552, 1171055, 864078, 1040225, 864213, 1040366, 865416, 865209, 864726, 1040204, 1040339, 1195658, 847023, 864657, 1408007, 1296740, 1218479, 1407191, 1195628, 1218476, 1459079, 1219154, 1395485, 1459058, 1272722, 1219151, 1376873, 1336469, 1353992, 1072607, 1266455, 1219142, 1217528, 1195565, 1212920, 1213757, 1293650, 1213727, 1293647, 754461, 1213061, 1293644, 753897, 1213763, 1293635, 753477, 897524, 861984, 865149, 862863, 740580, 858033, 1201817, 1388807, 1209086, 1129847, 1334618, 1131074, 948422, 1173356, 905735, 1173380, 870585, 1334630, 870366, 1338191, 948404, 1110497, 858039, 858738, 740451, 776460, 1122713, 1110389, 992447, 1293545, 1026995, 1026983, 897275, 879083, 1200101, 849765, 863136, 1106876, 850377, 861729, 1105082, 849963, 861315, 1106873, 861801, 994202, 1106885, 862803, 849870, 849606, 1106939, 820104, 818610, 1074209, 1106882, 862800, 850203, 1104986, 850137, 850380, 825045, 824361, 855654, 824544, 823962, 823728, 855699, 1041482, 956630, 963179, 825186, 1106921, 823755, 824751, 825027, 824298, 933608, 963131, 1110179, 891617, 823866, 824475, 982346, 1106918, 1168637, 936914, 824721, 824277, 1168565, 957788, 825123, 819492, 823662, 985727, 982325, 1106915, 820338, 824709, 825021, 820140, 855186, 823701, 820392, 1106930, 955448, 891566, 963080, 824415, 891710, 959138, 1106912, 981246, 823740, 1168298, 855570, 854925, 962966, 1106927, 824646, 892073, 963065, 1168643, 823836, 823557, 1201811, 1186820, 1123388, 1122275, 1083785, 1187828, 1084034, 1120859, 1083317, 1083677, 1224795, 1081382, 1123397, 1082882, 1082216, 1191143, 1084004, 1084355, 1083443, 1082744, 1083974, 1184822, 1084016, 1083107, 1083188, 1084196, 1082945, 1080974, 1084538, 1170938, 1083377, 1084037, 1104980, 1083965, 1083098, 1082756, 1080992, 1082888, 1082930, 1084526, 1084181, 1082258, 1083248, 1081373, 1224711, 1084307, 1123367, 1084145, 1083482, 1187834, 1186826, 1123391, 1191155, 1082852, 1122278, 1084409, 1083791, 1368860, 846627, 846870, 846363, 1398620, 862461, 897134, 865203, 896981, 1042016, 1367495, 1186523, 846012, 864654, 1131077, 897242, 897002, 845991, 864579, 864444, 862455, 897062, 865353, 953342, 1363655, 897203, 846879, 864720, 864558, 846417, 864597, 953228, 897083, 847014, 897167, 846894, 864258, 846438, 862929, 847029, 1363652, 864525, 897014, 864495, 864216, 862407, 948413, 887906, 847044, 896837, 897230, 896993, 864729, 864066, 1363646, 864660, 865449, 864393, 1216611, 1215554, 846744, 1131236, 862329, 1383950, 956516, 846453, 1042172, 862911, 862404, 846723, 955889, 1131185, 864252, 1042019, 862446, 897026, 897101, 1396301, 1040168, 1061813, 1061750, 858717, 776244, 880637, 897833, 1178222, 934790, 880367, 1038392, 880709, 992345, 1337825, 1338068, 878696, 992234, 880172, 1178228, 880190, 878765, 1178174, 1178225, 992459, 1026815, 897548, 934748, 880163, 1207193, 1207202, 862941, 846789, 1356212, 955925, 904184, 1395581, 955505, 1396292, 1395578, 1396262, 1395563, 903800, 1540058, 1042082, 1396373, 1380563, 1299029, 947687, 1396232, 1355918, 903509, 1396307, 1395584, 1380776, 880526, 972344, 1027010, 992252, 1353710, 1353830, 1353734, 1353713, 1110647, 1359284, 1379123, 1359422, 1359257, 1359443, 1379081, 1457717, 992267, 850356, 849972, 861714, 849876, 994190, 861318, 850134, 1074149, 849609, 1105061, 850374, 850206, 861426, 819927, 849627, 820101, 1105016, 982307, 823536, 891620, 824529, 962960, 820374, 1297088, 959132, 855651, 825138, 823956, 963191, 855696, 823620, 891941, 1122995, 820167, 963086, 891713, 981249, 892097, 963125, 855573, 956645, 854928, 823764, 892076, 824757, 1359362, 891506, 824250, 963122, 825006, 825096, 823698, 1359164, 753336, 1130804, 1460156, 1460150, 1211573, 1460147, 753912, 1460174, 1080836, 1186499, 1186553, 1084532, 1191152, 1120688, 1191800, 1082174, 1351808, 1222740, 1081391, 1178087, 1222779, 1191770, 1301705, 1351433, 1082219, 1351841, 1351952, 1221777, 1084007, 1351415, 1170932, 1191200, 1122272, 1083977, 1191026, 1186811, 1084022, 1350023, 1082765, 1191731, 1191548, 1191191, 1082255, 1222128, 1191632, 1120448, 1082762, 1082531, 1083659, 1191572, 1120739, 1081358, 1191749, 1351424, 1083416, 1191080, 1120436, 1221969, 1187831, 1301708, 1351436, 1082159, 1351853, 1120472, 1221783, 1104995, 1080833, 1191182, 1186817, 1120469, 1350026, 1083410, 1080830, 1186487, 1351838, 1084514, 1222788, 1351394, 1191785, 1122266, 1191755, 1191161, 1191209, 1191023, 1351427, 1221972, 1351832, 1191728, 1191545, 1222185, 1301717, 1082162, 1186559, 1083968, 1120691, 1191809, 1191626, 1084139, 1222743, 1082759, 1178402, 1394249, 1400945, 1398650, 1384856, 1176523, 1359305, 1176460, 1359254, 1391753, 880343, 1384859, 878921, 1176526, 902756, 1173401, 887891, 1129829, 753906, 753489, 754680, 753666, 970133, 1190963, 753774, 1074110, 753483, 753618, 754668, 753480, 753252, 753615, 753294, 1295624, 1222524, 1376048, 1359749, 1199243, 1379072, 1193384, 1359704, 1189946, 1359767, 1222758, 1193357, 1221960, 1361888, 1193288, 1184564, 1222515, 1359728, 1359293, 1359635, 1359314, 1359092, 1295651, 1359437, 1379078, 1221945, 1359458, 1359089, 1359425, 1379075, 1193390, 1222764, 1193360, 1221903, 1359086, 1189841, 1184567, 1222521, 1376045, 1359743, 1359296, 1359116, 1379069, 1359440, 1221948, 1359698, 1359719, 1359521, 1361414, 1359755, 1384712, 1384688, 1384727, 1384769, 1384658, 1081232, 1384748, 1384790, 1383848, 1082438, 1222737, 1384763, 1384799, 1384649, 1383860, 1384739, 1384841, 1384733, 1384793, 1384838, 1383854, 1384835, 1384679, 1384766, 1384655, 1081220, 1384745, 1408526, 1222731, 1384670, 1384760, 846804, 1395374, 956519, 1220126, 858042, 858396, 776505, 865446, 864711, 864231, 953360, 846906, 846741, 864582, 862908, 846720, 846918, 864459, 953357, 870591, 846867, 1383257, 846954, 864360, 847035, 865200, 846003, 864732, 864453, 864537, 955898, 862926, 864714, 847041, 864120, 1355765, 1215545, 1382468, 1382465, 1269149, 1191575, 955952, 897668, 1373318, 1373315, 1396982, 1110698, 740376, 740301, 896915, 1195868, 1353680, 1402868, 1353401, 879194, 1176400, 897287, 896561, 1353845, 1335887, 1353683, 1105064, 1353455, 850353, 861429, 994187, 820107, 850131, 1393439, 1353374, 819933, 849630, 1074146, 849684, 850332, 1293302, 1293389, 850371, 1353371, 1121879, 1293404, 1122776, 849975, 1293416, 861717, 849897, 854940, 1227386, 825147, 1353362, 823623, 824247, 1400012, 1032463, 1368872, 1227377, 855579, 982304, 1227107, 823770, 1041476, 963089, 892100, 1368869, 963128, 823953, 963188, 1119536, 962972, 855687, 1032484, 854910, 824772, 963140, 1227356, 892166, 1399856, 825066, 823539, 1131050, 855630, 824532, 891737, 1213778, 959162, 1221855, 1082345, 1222644, 1081322, 1222152, 1114598, 1113878, 1221867, 1222266, 1408487, 1114433, 1221849, 1114565, 1082360, 1081331, 1395290, 1209113, 870363, 880184, 880415, 1076045, 1405142, 903212, 870414, 1405139, 1404482, 1405136, 1410165, 776328, 1410162, 776154, 1428602, 896756, 1222251, 1376840, 1082456, 1082453, 1376843, 1222242
	)
) AS commit_data

ON commit_data.prod_hier_id_commit1 = ddi_join_desc.ddi_prod_hier1
OR commit_data.commit_desc1 = ddi_join_desc.description_from_tpm_commit






#big_table + ddi_join_desc



SELECT * FROM

(

	SELECT * FROM
	(
		SELECT
		table3_ded_data.pk_deduction_id,
		table3_ded_data.payterms_desc_new,
		table_1_display_text.ded_display_text,
		table_1_display_text.prom_display_text,
		table3_ded_data.deduction_created_date_min,
		table3_ded_data.deduction_created_date_max,
		table3_ded_data.customer_claim_date_min,
		table3_ded_data.customer_claim_date_max,
		table3_ded_data.invoice_date_min,
		table3_ded_data.invoice_date_max,
		
		table3_ded_data.promortion_execution_from_date_max,
		table3_ded_data.promortion_execution_from_date_min,
		table3_ded_data.promotion_execution_to_date_max,
		table3_ded_data.promotion_execution_to_date_min
		
		FROM
		(
			SELECT ded_data.payterms_desc,  ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
			(
				 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
				 dd.fk_customer_map_id AS cust_map_id_ded,
				 mcar.display_text AS ded_display_text,
				 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
				 mcar.fk_parent_customer_map_id, c.name,
				 dd.deduction_created_date, dd.customer_claim_date 
				 FROM ded_deduction AS dd
				 LEFT JOIN map_customer_account_rad AS mcar
				 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
				 LEFT JOIN customer AS c
				 ON c.customer_id = mcar.fk_customer_id

				 LEFT JOIN ded_deduction_resolution AS ddr
				 ON dd.pk_deduction_id = ddr.fk_deduction_id
				 LEFT JOIN lu_reason_code_rad AS reasoncode
				 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				 LEFT JOIN lu_reason_category_rad AS reasoncode_category
				 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				 LEFT JOIN map_reason_code_account_rad AS map_account 
				 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

				 LEFT JOIN lu_deduction_status_rad AS deductionstatus
				 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				 LEFT JOIN lu_deduction_status_system AS systemstatus
				 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				 WHERE 
				 #dd.fiscal_year=2016
				 systemstatus.pk_deduction_status_system_id = 4
				 AND pk_reason_category_rad_id IN (126)
				 AND ddr.fk_resolution_type_id = 4
				 AND ddr.fk_resolution_status_id = 1
				 AND dd.fk_deduction_type_id = 0
				 AND dd.pk_deduction_id IN 
				 (
					SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
				 )
			 GROUP BY dd.pk_deduction_id
			)AS ded_data

			LEFT JOIN
			(
				 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
				 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
				 mcar.display_text AS prom_display_text,
				 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
				 mcar.fk_parent_customer_map_id, c.name, 
				 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
				 ddri.fk_deduction_id AS ded_id_ddri
				  
				 FROM ded_deduction_resolution AS ddr
				 LEFT JOIN ded_deduction_resolution_item AS ddri
				 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
				 
				 LEFT JOIN tpm_commit AS tc
				 ON ddri.fk_commitment_id = tc.commit_id
				 
				 LEFT JOIN tpm_promotion AS tp
				 ON tp.promotion_id = tc.promotion_id
				   
				 LEFT JOIN map_customer_account_rad AS mcar
				 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
				 LEFT JOIN map_payment_term_account_rad AS mptar
				 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
				 LEFT JOIN customer AS c
				 ON c.customer_id = mcar.fk_customer_id
				 
				 WHERE tc.commit_id IN 
				 (
					  SELECT DISTINCT fk_commitment_id
					  FROM ded_deduction_resolution_item AS ddri
					  LEFT JOIN ded_deduction_resolution AS ddr 
					  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
					  LEFT JOIN ded_deduction AS ded
					  ON ddr.fk_deduction_id = ded.pk_deduction_id
					  LEFT JOIN tpm_commit AS tc 
					  ON ddri.fk_commitment_id = tc.commit_id
					  LEFT JOIN tpm_lu_commit_status AS tlcs
					  ON tc.commit_status_id = tlcs.commit_status_id
					  WHERE ded.pk_deduction_id IN 
					  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
					  AND ddr.fk_resolution_status_id = 1
				)
			 
			) AS prom_data

			ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
			GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
			HAVING COUNT(*) >= 500
		) AS table_1_display_text

		LEFT JOIN
		(
			 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
			 
			 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
			 
			 dd.fk_customer_map_id AS cust_map_id_ded,
			 mcar.display_text AS ded_display_text,
			 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
			 mcar.fk_parent_customer_map_id, c.name,
			 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
			 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
			 
			 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
			 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2000-01-01' ELSE dd.deduction_created_date END) AS deduction_created_date_max,
			 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
			 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2000-01-01' ELSE dd.customer_claim_date END) AS customer_claim_date_max,
			 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
			 (CASE WHEN ISNULL(dd.invoice_date) THEN '2000-01-01' ELSE dd.invoice_date END) AS invoice_date_max,
			 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
			 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2000-01-01' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_max,
			 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2017-12-31' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_min,
			 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
	 
					 
			 FROM ded_deduction AS dd
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id

			 LEFT JOIN ded_deduction_resolution AS ddr
			 ON dd.pk_deduction_id = ddr.fk_deduction_id
			 LEFT JOIN lu_reason_code_rad AS reasoncode
			 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			 LEFT JOIN lu_reason_category_rad AS reasoncode_category
			 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			 LEFT JOIN map_reason_code_account_rad AS map_account 
			 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

			 LEFT JOIN lu_deduction_status_rad AS deductionstatus
			 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			 LEFT JOIN lu_deduction_status_system AS systemstatus
			 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			 WHERE 
			 dd.fiscal_year=2016
			 AND systemstatus.pk_deduction_status_system_id = 4		
			 AND pk_reason_category_rad_id IN (126)
			 AND ddr.fk_resolution_type_id = 4
			 AND ddr.fk_resolution_status_id = 1
			 AND dd.fk_deduction_type_id = 0
			 AND dd.pk_deduction_id IN 
			 (
				SELECT * FROM
				(
					SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
					
					INNER JOIN lu_reason_code_rad AS reasoncode
					ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
					INNER JOIN lu_reason_category_rad AS reasoncode_category
					ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
					INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



					INNER JOIN lu_deduction_status_rad AS deductionstatus
					ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
					INNER JOIN lu_deduction_status_system AS systemstatus
					ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

					INNER JOIN map_deduction_item_rollup_header AS header
					ON deduction.pk_deduction_id = header.fk_deduction_id
					INNER JOIN map_deduction_item_rollup AS map_item
					ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
					INNER JOIN ded_deduction_resolution AS resolution
					ON header.fk_deduction_id = resolution.fk_deduction_id
					 
					WHERE 

					deduction.fk_reason_code_map_id != -1

					AND pk_reason_category_rad_id IN (126) 

					AND systemstatus.pk_deduction_status_system_id = 4

					AND deduction.fk_deduction_type_id=0

					AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
					AND deduction.fiscal_year=2016

					AND header.fk_resolution_type_id = 4
					AND resolution.fk_resolution_type_id = 4
					AND deduction.fk_deduction_type_id = 0
					
					LIMIT 1000
				) AS suggest_sol		
			 )
			GROUP BY dd.pk_deduction_id
		) AS table3_ded_data
		 
		 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text

	)AS step1_join_data

	INNER JOIN 
	(
		 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
		 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
		 
		 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,

		 
		 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
		 mcar.fk_parent_customer_map_id, c.name, 
		 tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, 
		 ddr.fk_deduction_id AS ded_id_ddr,
		 ddri.fk_deduction_id AS ded_id_ddri,
		 
		 
		 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
		 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2000-01-01' ELSE tp.ship_start_date END) AS ship_start_date_max,
		 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
		 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2000-01-01' ELSE tp.consumption_start_date END) AS consumption_start_date_max,
		 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2017-12-31' ELSE tp.ship_end_date END) AS ship_end_date_min,
		 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
		 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2017-12-31' ELSE tp.consumption_end_date END) AS consumption_end_date_min,
		 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
		 
		  
		 FROM ded_deduction_resolution AS ddr
		 LEFT JOIN ded_deduction_resolution_item AS ddri
		 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
		 
		 LEFT JOIN tpm_commit AS tc
		 ON ddri.fk_commitment_id = tc.commit_id
		 
		 LEFT JOIN tpm_promotion AS tp
		 ON tp.promotion_id = tc.promotion_id
		   
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN map_payment_term_account_rad AS mptar
		 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id
		 
		 WHERE tc.commit_id IN 
		 (
			  SELECT DISTINCT fk_commitment_id
			  FROM ded_deduction_resolution_item AS ddri
			  LEFT JOIN ded_deduction_resolution AS ddr 
			  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
			  LEFT JOIN ded_deduction AS ded
			  ON ddr.fk_deduction_id = ded.pk_deduction_id
			  LEFT JOIN tpm_commit AS tc 
			  ON ddri.fk_commitment_id = tc.commit_id
			  LEFT JOIN tpm_lu_commit_status AS tlcs
			  ON tc.commit_status_id = tlcs.commit_status_id
			  WHERE ded.pk_deduction_id IN 
			  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
			  AND ddr.fk_resolution_status_id = 1
		)
		
		AND tp.promotion_status_id = 6
		GROUP BY tp.promotion_id
	) AS table4_prom_data

	ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
	AND step1_join_data.prom_display_text = table4_prom_data.display_text

	AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
	, LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
	 >= -14
	AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
	,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
	>= -14 
		
)AS big_table




LEFT JOIN

#ddi_with_desc

(
	
	SELECT * FROM
	(
		SELECT ddi.fk_deduction_id, lu_item.description AS ddi_lu_item_desc FROM
		ded_deduction_item AS ddi
		LEFT JOIN tpm_lu_item AS lu_item
		ON lu_item.item_id = ddi.fk_lu_item_id
		
		WHERE ddi.fk_deduction_id IN 
		(
			SELECT * FROM
			(
				SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
				
				INNER JOIN lu_reason_code_rad AS reasoncode
				ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				INNER JOIN lu_reason_category_rad AS reasoncode_category
				ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



				INNER JOIN lu_deduction_status_rad AS deductionstatus
				ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				INNER JOIN lu_deduction_status_system AS systemstatus
				ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				INNER JOIN map_deduction_item_rollup_header AS header
				ON deduction.pk_deduction_id = header.fk_deduction_id
				INNER JOIN map_deduction_item_rollup AS map_item
				ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
				INNER JOIN ded_deduction_resolution AS resolution
				ON header.fk_deduction_id = resolution.fk_deduction_id
				 
				WHERE 

				deduction.fk_reason_code_map_id != -1

				AND pk_reason_category_rad_id IN (126) 

				AND systemstatus.pk_deduction_status_system_id = 4

				AND deduction.fk_deduction_type_id=0

				AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
				AND deduction.fiscal_year=2016

				AND header.fk_resolution_type_id = 4
				AND resolution.fk_resolution_type_id = 4
				AND deduction.fk_deduction_type_id = 0
				
				LIMIT 1000
			) AS suggest_sol		
		)	
	) AS ddi_data

	LEFT JOIN

	(	
		 SELECT 
		 hierarchynode.description AS description_from_tpm_commit,
		 luitem.description AS lu_item_description,
		 COUNT(*) 
		 
		 FROM ded_deduction AS deduction
		 #INNER JOIN customer_claim AS claiminfo
		 #ON deduction.customer_claim_number = claiminfo.claim_number
		 LEFT JOIN acct_doc_header AS acctdoc
		 ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
		 INNER JOIN lu_reason_code_rad AS reasoncode
		 ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 INNER JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
		 #Inner join
		 #INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
		 INNER JOIN lu_deduction_status_rad AS deductionstatus
		 ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 INNER JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 INNER JOIN ded_deduction_item AS item
		 ON deduction.pk_deduction_id = item.fk_deduction_id
		 INNER JOIN ded_deduction_resolution AS resolution
		 ON resolution.fk_deduction_id = deduction.pk_deduction_id
		 INNER JOIN ded_deduction_resolution_item AS resolveditem
		 ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
		 #JOIN WITH commited resolutions
		 INNER JOIN tpm_commit AS committable
		 ON committable.commit_id = resolveditem.fk_commitment_id

		 #inner join product hierarchy master data
		 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
		 ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

		 #deduction_item_product_hierarchy's description
		 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
		 ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

		 INNER JOIN tpm_lu_item AS luitem
		 ON luitem.item_id = item.fk_lu_item_id

		 #join with resolved promotions
		 INNER JOIN tpm_promotion AS promotion
		 ON promotion.promotion_id = committable.promotion_id

		 WHERE deduction.fk_account_id = 16
		 AND deduction.fk_reason_code_map_id != -1 AND
		 resolution.fk_resolution_type_id = 4
		 AND resolution.fk_resolution_status_id = 1 AND 
		 reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
		 AND deduction.fiscal_year = 2016
		 AND committable.product_hierarchy_id = item.product_hierarchy1_id
		 
		 GROUP BY 1, 2

	) AS item_desc_data

	ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description


) AS ddi_with_desc

ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
		





# Final Table for 1000 deductions( did not execute completly)







SELECT COUNT(*) FROM

(

	SELECT * FROM

	(

		SELECT * FROM
		(
			SELECT
			table3_ded_data.pk_deduction_id,
			table3_ded_data.payterms_desc_new,
			table_1_display_text.ded_display_text,
			table_1_display_text.prom_display_text,
			table3_ded_data.deduction_created_date_min,
			table3_ded_data.deduction_created_date_max,
			table3_ded_data.customer_claim_date_min,
			table3_ded_data.customer_claim_date_max,
			table3_ded_data.invoice_date_min,
			table3_ded_data.invoice_date_max,
			
			table3_ded_data.promortion_execution_from_date_max,
			table3_ded_data.promortion_execution_from_date_min,
			table3_ded_data.promotion_execution_to_date_max,
			table3_ded_data.promotion_execution_to_date_min
			
			FROM
			(
				SELECT ded_data.payterms_desc,  ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
				(
					 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
					 dd.fk_customer_map_id AS cust_map_id_ded,
					 mcar.display_text AS ded_display_text,
					 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
					 mcar.fk_parent_customer_map_id, c.name,
					 dd.deduction_created_date, dd.customer_claim_date 
					 FROM ded_deduction AS dd
					 LEFT JOIN map_customer_account_rad AS mcar
					 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
					 LEFT JOIN customer AS c
					 ON c.customer_id = mcar.fk_customer_id

					 LEFT JOIN ded_deduction_resolution AS ddr
					 ON dd.pk_deduction_id = ddr.fk_deduction_id
					 LEFT JOIN lu_reason_code_rad AS reasoncode
					 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
					 LEFT JOIN lu_reason_category_rad AS reasoncode_category
					 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
					 LEFT JOIN map_reason_code_account_rad AS map_account 
					 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

					 LEFT JOIN lu_deduction_status_rad AS deductionstatus
					 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
					 LEFT JOIN lu_deduction_status_system AS systemstatus
					 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

					 WHERE 
					 #dd.fiscal_year=2016
					 systemstatus.pk_deduction_status_system_id = 4
					 AND pk_reason_category_rad_id IN (126)
					 AND ddr.fk_resolution_type_id = 4
					 AND ddr.fk_resolution_status_id = 1
					 AND dd.fk_deduction_type_id = 0
					 AND dd.pk_deduction_id IN 
					 (
						SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
					 )
				 GROUP BY dd.pk_deduction_id
				)AS ded_data

				LEFT JOIN
				(
					 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
					 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
					 mcar.display_text AS prom_display_text,
					 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
					 mcar.fk_parent_customer_map_id, c.name, 
					 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
					 ddri.fk_deduction_id AS ded_id_ddri
					  
					 FROM ded_deduction_resolution AS ddr
					 LEFT JOIN ded_deduction_resolution_item AS ddri
					 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
					 
					 LEFT JOIN tpm_commit AS tc
					 ON ddri.fk_commitment_id = tc.commit_id
					 
					 LEFT JOIN tpm_promotion AS tp
					 ON tp.promotion_id = tc.promotion_id
					   
					 LEFT JOIN map_customer_account_rad AS mcar
					 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
					 LEFT JOIN map_payment_term_account_rad AS mptar
					 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
					 LEFT JOIN customer AS c
					 ON c.customer_id = mcar.fk_customer_id
					 
					 WHERE tc.commit_id IN 
					 (
						  SELECT DISTINCT fk_commitment_id
						  FROM ded_deduction_resolution_item AS ddri
						  LEFT JOIN ded_deduction_resolution AS ddr 
						  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
						  LEFT JOIN ded_deduction AS ded
						  ON ddr.fk_deduction_id = ded.pk_deduction_id
						  LEFT JOIN tpm_commit AS tc 
						  ON ddri.fk_commitment_id = tc.commit_id
						  LEFT JOIN tpm_lu_commit_status AS tlcs
						  ON tc.commit_status_id = tlcs.commit_status_id
						  WHERE ded.pk_deduction_id IN 
						  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
						  AND ddr.fk_resolution_status_id = 1
					)
				 
				) AS prom_data

				ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
				GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
				HAVING COUNT(*) >= 500
			) AS table_1_display_text

			LEFT JOIN
			(
				 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
				 
				 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
				 
				 dd.fk_customer_map_id AS cust_map_id_ded,
				 mcar.display_text AS ded_display_text,
				 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
				 mcar.fk_parent_customer_map_id, c.name,
				 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
				 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
				 
				 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
				 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2000-01-01' ELSE dd.deduction_created_date END) AS deduction_created_date_max,
				 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
				 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2000-01-01' ELSE dd.customer_claim_date END) AS customer_claim_date_max,
				 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
				 (CASE WHEN ISNULL(dd.invoice_date) THEN '2000-01-01' ELSE dd.invoice_date END) AS invoice_date_max,
				 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
				 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2000-01-01' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_max,
				 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2017-12-31' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_min,
				 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
		 
						 
				 FROM ded_deduction AS dd
				 LEFT JOIN map_customer_account_rad AS mcar
				 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
				 LEFT JOIN customer AS c
				 ON c.customer_id = mcar.fk_customer_id

				 LEFT JOIN ded_deduction_resolution AS ddr
				 ON dd.pk_deduction_id = ddr.fk_deduction_id
				 LEFT JOIN lu_reason_code_rad AS reasoncode
				 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
				 LEFT JOIN lu_reason_category_rad AS reasoncode_category
				 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
				 LEFT JOIN map_reason_code_account_rad AS map_account 
				 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

				 LEFT JOIN lu_deduction_status_rad AS deductionstatus
				 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
				 LEFT JOIN lu_deduction_status_system AS systemstatus
				 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

				 WHERE 
				 dd.fiscal_year=2016
				 AND systemstatus.pk_deduction_status_system_id = 4		
				 AND pk_reason_category_rad_id IN (126)
				 AND ddr.fk_resolution_type_id = 4
				 AND ddr.fk_resolution_status_id = 1
				 AND dd.fk_deduction_type_id = 0
				 AND dd.pk_deduction_id IN 
				 (
					SELECT * FROM
					(
						SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
						
						INNER JOIN lu_reason_code_rad AS reasoncode
						ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
						INNER JOIN lu_reason_category_rad AS reasoncode_category
						ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
						INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



						INNER JOIN lu_deduction_status_rad AS deductionstatus
						ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
						INNER JOIN lu_deduction_status_system AS systemstatus
						ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

						INNER JOIN map_deduction_item_rollup_header AS header
						ON deduction.pk_deduction_id = header.fk_deduction_id
						INNER JOIN map_deduction_item_rollup AS map_item
						ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
						INNER JOIN ded_deduction_resolution AS resolution
						ON header.fk_deduction_id = resolution.fk_deduction_id
						 
						WHERE 

						deduction.fk_reason_code_map_id != -1

						AND pk_reason_category_rad_id IN (126) 

						AND systemstatus.pk_deduction_status_system_id = 4

						AND deduction.fk_deduction_type_id=0

						AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
						AND deduction.fiscal_year=2016

						AND header.fk_resolution_type_id = 4
						AND resolution.fk_resolution_type_id = 4
						AND deduction.fk_deduction_type_id = 0
						
						LIMIT 1000
					) AS suggest_sol		
				 )
				GROUP BY dd.pk_deduction_id
			) AS table3_ded_data
			 
			 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text

		)AS step1_join_data

		INNER JOIN 
		(
			 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
			 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
			 
			 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,

			 
			 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
			 mcar.fk_parent_customer_map_id, c.name, 
			 tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, 
			 ddr.fk_deduction_id AS ded_id_ddr,
			 ddri.fk_deduction_id AS ded_id_ddri,
			 
			 
			 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
			 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2000-01-01' ELSE tp.ship_start_date END) AS ship_start_date_max,
			 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
			 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2000-01-01' ELSE tp.consumption_start_date END) AS consumption_start_date_max,
			 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2017-12-31' ELSE tp.ship_end_date END) AS ship_end_date_min,
			 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
			 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2017-12-31' ELSE tp.consumption_end_date END) AS consumption_end_date_min,
			 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
			 
			  
			 FROM ded_deduction_resolution AS ddr
			 LEFT JOIN ded_deduction_resolution_item AS ddri
			 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
			 
			 LEFT JOIN tpm_commit AS tc
			 ON ddri.fk_commitment_id = tc.commit_id
			 
			 LEFT JOIN tpm_promotion AS tp
			 ON tp.promotion_id = tc.promotion_id
			   
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN map_payment_term_account_rad AS mptar
			 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id
			 
			 WHERE tc.commit_id IN 
			 (
				  SELECT DISTINCT fk_commitment_id
				  FROM ded_deduction_resolution_item AS ddri
				  LEFT JOIN ded_deduction_resolution AS ddr 
				  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
				  LEFT JOIN ded_deduction AS ded
				  ON ddr.fk_deduction_id = ded.pk_deduction_id
				  LEFT JOIN tpm_commit AS tc 
				  ON ddri.fk_commitment_id = tc.commit_id
				  LEFT JOIN tpm_lu_commit_status AS tlcs
				  ON tc.commit_status_id = tlcs.commit_status_id
				  WHERE ded.pk_deduction_id IN 
				  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
				  AND ddr.fk_resolution_status_id = 1
			)
			
			AND tp.promotion_status_id = 6
			GROUP BY tp.promotion_id
		) AS table4_prom_data

		ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
		AND step1_join_data.prom_display_text = table4_prom_data.display_text

		AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
		, LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
		 >= -14
		AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
		,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
		>= -14 
			
	)AS big_table




	LEFT JOIN

	#ddi_with_desc

	(
		
		SELECT * FROM
		(
			SELECT ddi.fk_deduction_id, lu_item.description AS ddi_lu_item_desc,
			ddi.product_hierarchy1_id AS ddi_prod_hier1
			FROM
			ded_deduction_item AS ddi
			LEFT JOIN tpm_lu_item AS lu_item
			ON lu_item.item_id = ddi.fk_lu_item_id
			
			WHERE ddi.fk_deduction_id IN 
			(
				SELECT * FROM
				(
					SELECT DISTINCT deduction.pk_deduction_id  FROM ded_deduction AS deduction 
					
					INNER JOIN lu_reason_code_rad AS reasoncode
					ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
					INNER JOIN lu_reason_category_rad AS reasoncode_category
					ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
					INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id



					INNER JOIN lu_deduction_status_rad AS deductionstatus
					ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
					INNER JOIN lu_deduction_status_system AS systemstatus
					ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

					INNER JOIN map_deduction_item_rollup_header AS header
					ON deduction.pk_deduction_id = header.fk_deduction_id
					INNER JOIN map_deduction_item_rollup AS map_item
					ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id
					INNER JOIN ded_deduction_resolution AS resolution
					ON header.fk_deduction_id = resolution.fk_deduction_id
					 
					WHERE 

					deduction.fk_reason_code_map_id != -1

					AND pk_reason_category_rad_id IN (126) 

					AND systemstatus.pk_deduction_status_system_id = 4

					AND deduction.fk_deduction_type_id=0

					AND deduction.auto_matched_commit_status IN ('Partial Match','Total Match') 
					AND deduction.fiscal_year=2016

					AND header.fk_resolution_type_id = 4
					AND resolution.fk_resolution_type_id = 4
					AND deduction.fk_deduction_type_id = 0
					
					LIMIT 1000
				) AS suggest_sol		
			)	
		) AS ddi_data

		LEFT JOIN

		(	
			 SELECT 
			 hierarchynode.description AS description_from_tpm_commit,
			 luitem.description AS lu_item_description,
			 COUNT(*) 
			 
			 FROM ded_deduction AS deduction
			 #INNER JOIN customer_claim AS claiminfo
			 #ON deduction.customer_claim_number = claiminfo.claim_number
			 LEFT JOIN acct_doc_header AS acctdoc
			 ON deduction.fk_acct_doc_header_id = acctdoc.acct_doc_header_id
			 INNER JOIN lu_reason_code_rad AS reasoncode
			 ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			 INNER JOIN lu_reason_category_rad AS reasoncode_category
			 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			 INNER JOIN map_reason_code_account_rad AS map_account ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id
			 #Inner join
			 #INNER JOIN ded_deduction_resolution AS dedresolution ON deduction.pk_deduction_id = dedresolution.fk_deduction_id
			 INNER JOIN lu_deduction_status_rad AS deductionstatus
			 ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			 INNER JOIN lu_deduction_status_system AS systemstatus
			 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			 INNER JOIN ded_deduction_item AS item
			 ON deduction.pk_deduction_id = item.fk_deduction_id
			 INNER JOIN ded_deduction_resolution AS resolution
			 ON resolution.fk_deduction_id = deduction.pk_deduction_id
			 INNER JOIN ded_deduction_resolution_item AS resolveditem
			 ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
			 #JOIN WITH commited resolutions
			 INNER JOIN tpm_commit AS committable
			 ON committable.commit_id = resolveditem.fk_commitment_id

			 #inner join product hierarchy master data
			 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode
			 ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

			 #deduction_item_product_hierarchy's description
			 INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc
			 ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id

			 INNER JOIN tpm_lu_item AS luitem
			 ON luitem.item_id = item.fk_lu_item_id

			 #join with resolved promotions
			 INNER JOIN tpm_promotion AS promotion
			 ON promotion.promotion_id = committable.promotion_id

			 WHERE deduction.fk_account_id = 16
			 AND deduction.fk_reason_code_map_id != -1 AND
			 resolution.fk_resolution_type_id = 4
			 AND resolution.fk_resolution_status_id = 1 AND 
			 reasoncode_category.shortname = "Trade"  AND systemstatus.pk_deduction_status_system_id = 4 AND deduction.fk_deduction_type_id=0
			 AND deduction.fiscal_year = 2016
			 AND committable.product_hierarchy_id = item.product_hierarchy1_id
			 
			 GROUP BY 1, 2

		) AS item_desc_data

		ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description


	) AS ddi_with_desc

	ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
			
) AS everything_except_commit



# joining with the commit

INNER JOIN


(

	SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1,
	tc.product_hierarchy_id AS prod_hier_id_commit1,
	hierarchynode.description AS commit_desc1 
	 
	FROM tpm_commit AS tc 
	LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode
	ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id

	WHERE tc.commit_status_id = 6
	 
	AND tc.promotion_id IN 
	(
	  578967, 578991, 578994, 579003, 579042, 579054, 579132, 579138, 579156, 579171, 579195...
	)
	
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit




# date condition checking





SELECT 
( 
DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
, LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))

) AS condition1, 

(
 DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
 
) AS condition2,


step1_join_data.pk_deduction_id,
step1_join_data.deduction_created_date_min,
step1_join_data.deduction_created_date_max,
step1_join_data.customer_claim_date_min,
step1_join_data.customer_claim_date_max,
step1_join_data.invoice_date_min,
step1_join_data.invoice_date_max,

step1_join_data.promortion_execution_from_date_max,
step1_join_data.promortion_execution_from_date_min,
step1_join_data.promotion_execution_to_date_max,
step1_join_data.promotion_execution_to_date_min,

table4_prom_data.promotion_id,


table4_prom_data.ship_start_date_min,
table4_prom_data.ship_start_date_max,
table4_prom_data.consumption_start_date_min,
table4_prom_data.consumption_start_date_max,
table4_prom_data.ship_end_date_min,
table4_prom_data.ship_end_date_max,
table4_prom_data.consumption_end_date_min,
table4_prom_data.consumption_end_date_max
	 

 FROM
(
	SELECT
	table3_ded_data.pk_deduction_id,
	table3_ded_data.payterms_desc_new,
	table_1_display_text.ded_display_text,
	table_1_display_text.prom_display_text,
	table3_ded_data.deduction_created_date_min,
	table3_ded_data.deduction_created_date_max,
	table3_ded_data.customer_claim_date_min,
	table3_ded_data.customer_claim_date_max,
	table3_ded_data.invoice_date_min,
	table3_ded_data.invoice_date_max,
	
	table3_ded_data.promortion_execution_from_date_max,
	table3_ded_data.promortion_execution_from_date_min,
	table3_ded_data.promotion_execution_to_date_max,
	table3_ded_data.promotion_execution_to_date_min
	
	FROM
	(
		SELECT ded_data.payterms_desc,  ded_data.ded_display_text, prom_data.prom_display_text, COUNT(*) FROM
		(
			 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
			 dd.fk_customer_map_id AS cust_map_id_ded,
			 mcar.display_text AS ded_display_text,
			 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
			 mcar.fk_parent_customer_map_id, c.name,
			 dd.deduction_created_date, dd.customer_claim_date 
			 FROM ded_deduction AS dd
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id

			 LEFT JOIN ded_deduction_resolution AS ddr
			 ON dd.pk_deduction_id = ddr.fk_deduction_id
			 LEFT JOIN lu_reason_code_rad AS reasoncode
			 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
			 LEFT JOIN lu_reason_category_rad AS reasoncode_category
			 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
			 LEFT JOIN map_reason_code_account_rad AS map_account 
			 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

			 LEFT JOIN lu_deduction_status_rad AS deductionstatus
			 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
			 LEFT JOIN lu_deduction_status_system AS systemstatus
			 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

			 WHERE 
			 #dd.fiscal_year=2016
			 systemstatus.pk_deduction_status_system_id = 4
			 AND pk_reason_category_rad_id IN (126)
			 AND ddr.fk_resolution_type_id = 4
			 AND ddr.fk_resolution_status_id = 1
			 AND dd.fk_deduction_type_id = 0
			 AND dd.pk_deduction_id IN 
			 (
				SELECT DISTINCT fk_deduction_id FROM ded_deduction_item
			 )
		 GROUP BY dd.pk_deduction_id
		)AS ded_data

		LEFT JOIN
		(
			 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
			 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, 
			 mcar.display_text AS prom_display_text,
			 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
			 mcar.fk_parent_customer_map_id, c.name, 
			 tp.ship_start_date, tp.ship_end_date, ddr.fk_deduction_id AS ded_id_ddr,
			 ddri.fk_deduction_id AS ded_id_ddri
			  
			 FROM ded_deduction_resolution AS ddr
			 LEFT JOIN ded_deduction_resolution_item AS ddri
			 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
			 
			 LEFT JOIN tpm_commit AS tc
			 ON ddri.fk_commitment_id = tc.commit_id
			 
			 LEFT JOIN tpm_promotion AS tp
			 ON tp.promotion_id = tc.promotion_id
			   
			 LEFT JOIN map_customer_account_rad AS mcar
			 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
			 LEFT JOIN map_payment_term_account_rad AS mptar
			 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
			 LEFT JOIN customer AS c
			 ON c.customer_id = mcar.fk_customer_id
			 
			 WHERE tc.commit_id IN 
			 (
				  SELECT DISTINCT fk_commitment_id
				  FROM ded_deduction_resolution_item AS ddri
				  LEFT JOIN ded_deduction_resolution AS ddr 
				  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
				  LEFT JOIN ded_deduction AS ded
				  ON ddr.fk_deduction_id = ded.pk_deduction_id
				  LEFT JOIN tpm_commit AS tc 
				  ON ddri.fk_commitment_id = tc.commit_id
				  LEFT JOIN tpm_lu_commit_status AS tlcs
				  ON tc.commit_status_id = tlcs.commit_status_id
				  WHERE ded.pk_deduction_id IN 
				  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
				  AND ddr.fk_resolution_status_id = 1
			)
		 
		) AS prom_data

		ON ded_data.pk_deduction_id = prom_data.ded_id_ddr
		GROUP BY ded_data.ded_display_text, prom_data.prom_display_text
		HAVING COUNT(*) >= 500
	) AS table_1_display_text

	LEFT JOIN
	(
		 SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
		 
		 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
		 
		 dd.fk_customer_map_id AS cust_map_id_ded,
		 mcar.display_text AS ded_display_text,
		 mcar.fk_customer_id, dd.payer, mcar.account_customer_number_norm, 
		 mcar.fk_parent_customer_map_id, c.name,
		 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
		 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
		 
		 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
	         (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2000-01-01' ELSE dd.deduction_created_date END) AS deduction_created_date_max,
	         (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
	         (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2000-01-01' ELSE dd.customer_claim_date END) AS customer_claim_date_max,
	         (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
	         (CASE WHEN ISNULL(dd.invoice_date) THEN '2000-01-01' ELSE dd.invoice_date END) AS invoice_date_max,
	         (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
	         (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2000-01-01' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_max,
	         (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2017-12-31' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_min,
	         (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
 
		 		 
		 FROM ded_deduction AS dd
		 LEFT JOIN map_customer_account_rad AS mcar
		 ON dd.fk_customer_map_id = mcar.pk_customer_map_id
		 LEFT JOIN customer AS c
		 ON c.customer_id = mcar.fk_customer_id

		 LEFT JOIN ded_deduction_resolution AS ddr
		 ON dd.pk_deduction_id = ddr.fk_deduction_id
		 LEFT JOIN lu_reason_code_rad AS reasoncode
		 ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
		 LEFT JOIN lu_reason_category_rad AS reasoncode_category
		 ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
		 LEFT JOIN map_reason_code_account_rad AS map_account 
		 ON map_account.fk_reason_code_rad_id = reasoncode.pk_reason_code_rad_id

		 LEFT JOIN lu_deduction_status_rad AS deductionstatus
		 ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
		 LEFT JOIN lu_deduction_status_system AS systemstatus
		 ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

		 WHERE 
		 dd.fiscal_year=2016
		 AND systemstatus.pk_deduction_status_system_id = 4		
		 AND pk_reason_category_rad_id IN (126)
		 AND ddr.fk_resolution_type_id = 4
		 AND ddr.fk_resolution_status_id = 1
		 AND dd.fk_deduction_type_id = 0
		 AND dd.pk_deduction_id IN 
		 (
			 11674751, 11674634, 11674790, 11870843, 11874530, 11827652, 12031658, 12154640, 12261467, 12526759, 12262112, 12570755, 12704867, 12704861, 12570896, 12570908, 12704663, 12570950, 12678977, 12704849, 12704879, 12827315, 12908411, 12908774, 12908855, 13136537, 13136507, 13136519, 13136534, 12908867, 12908936, 12909083, 12909152, 12909161, 12909248, 12909260, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 14369673, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13676051, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14622927, 14567807, 14567855, 14567867, 14567888, 15079352, 15079355, 14567897, 14567903, 14567909, 14567930, 14568005, 15283361, 14568014, 14568023, 14568203, 14568227, 14568293, 14745755, 13217450, 14745860, 16915436, 16915403, 16318868, 14893181, 15202226, 15202406, 15202529, 15203843, 15203990, 15473246, 15859529, 15920192, 16026308, 16026458, 16147913, 16148975, 16915268, 14745659, 16915388, 16920107, 16915400, 16915409, 16915427, 16915433, 16915448, 16915454, 16915616, 16915880, 16916297, 16916408, 16919972, 16920773, 17066660, 16920809, 16920815, 17066606, 16920821, 17070362, 17066480, 17066483, 17066591, 17066609, 17066612, 17066639, 17066657, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066783, 17066786, 17066789, 17066798, 17066801, 17066804, 17066816, 17066819, 17066822, 17066843, 17066846, 17066849, 17066852, 17066858, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17067044, 17067467, 17067470, 17067101, 17070170, 17070182, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070308, 17070311, 17070317, 17070320, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070458, 17204444, 17070461, 17070464, 17070467, 17206502, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280797, 17280833, 17280836, 17280842, 17280851, 17280854, 17280857, 17280860, 17280866, 17280884, 17280893, 17280896, 17280899, 17280911, 17280914, 17280917, 17280920, 17280932, 17280950, 17280953, 17280959, 17280986, 17280989, 17280995, 17280998, 17281109, 17281112, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17067716, 17281241, 17281337, 17281505, 17281586, 17281736, 17281769, 17281847, 17282105, 17282249, 17282282, 17282318, 17282354, 17329241, 17281547, 17067065, 17329361, 17467385, 17467415, 17467331, 17467328, 17467274, 17507774, 17507783, 17507786, 17507792, 17507807, 17507813, 17507816, 17507819, 17507822, 17507828, 17507831, 17507879, 17507951, 17507960, 17508011, 17508014, 17508029, 17508032, 17508056, 17508059, 17508083, 17508176, 17508230, 17508236, 17508239, 17508263, 17509586, 17509784, 17509850, 17510120, 17510177, 17510402, 17510459, 17510627
		 )
		GROUP BY dd.pk_deduction_id
	) AS table3_ded_data
	 
	 ON table_1_display_text.ded_display_text = table3_ded_data.ded_display_text

)AS step1_join_data

INNER JOIN 
(
	 SELECT tp.promotion_id, tc.commit_id, tp.sales_org, tc.currency_id, 
	 mcar.payterms_desc AS Payment_term_Prom, tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text,
	 
	 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,

	 
	 mcar.fk_customer_id, tp.sold_to, mcar.account_customer_number_norm,
	 mcar.fk_parent_customer_map_id, c.name, 
	 tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, 
	 ddr.fk_deduction_id AS ded_id_ddr,
	 ddri.fk_deduction_id AS ded_id_ddri,
	 
	 
	 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
	 (CASE WHEN ISNULL(tp.ship_start_date) THEN '2000-01-01' ELSE tp.ship_start_date END) AS ship_start_date_max,
	 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
	 (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2000-01-01' ELSE tp.consumption_start_date END) AS consumption_start_date_max,
	 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2017-12-31' ELSE tp.ship_end_date END) AS ship_end_date_min,
	 (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
	 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2017-12-31' ELSE tp.consumption_end_date END) AS consumption_end_date_min,
	 (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
	 
	  
	 FROM ded_deduction_resolution AS ddr
	 LEFT JOIN ded_deduction_resolution_item AS ddri
	 ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
	 
	 LEFT JOIN tpm_commit AS tc
	 ON ddri.fk_commitment_id = tc.commit_id
	 
	 LEFT JOIN tpm_promotion AS tp
	 ON tp.promotion_id = tc.promotion_id
	   
	 LEFT JOIN map_customer_account_rad AS mcar
	 ON tp.fk_customer_map_id = mcar.pk_customer_map_id
	 LEFT JOIN map_payment_term_account_rad AS mptar
	 ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
	 LEFT JOIN customer AS c
	 ON c.customer_id = mcar.fk_customer_id
	 
	 WHERE tc.commit_id IN 
	 (
		  SELECT DISTINCT fk_commitment_id
		  FROM ded_deduction_resolution_item AS ddri
		  LEFT JOIN ded_deduction_resolution AS ddr 
		  ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
		  LEFT JOIN ded_deduction AS ded
		  ON ddr.fk_deduction_id = ded.pk_deduction_id
		  LEFT JOIN tpm_commit AS tc 
		  ON ddri.fk_commitment_id = tc.commit_id
		  LEFT JOIN tpm_lu_commit_status AS tlcs
		  ON tc.commit_status_id = tlcs.commit_status_id
		  WHERE ded.pk_deduction_id IN 
		  (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
		  AND ddr.fk_resolution_status_id = 1
	)
	
	AND tp.promotion_id IN 
	(
		1070072, 1070069, 535086, 1109147, 1039994, 696897, 645885, 717654, 643908, 1052852, 988538, 1037522, 685797, 533817, 1040348, 1040372, 1040225, 1040366, 1040243, 1040207, 944823, 684126, 684090, 1176490, 1043912, 1083545, 1083485, 1040201, 1040219, 1040222, 1040231, 1040204, 1040345, 1796049, 1198472, 1199543, 1174037, 1130900, 1123229, 718182, 1178180, 776070, 573627, 1198451, 1122902, 862422, 1081355, 1070417, 1070168, 1123154, 858213, 1026395, 776124, 876599, 855663, 854922, 602250, 855618, 854913, 956633, 602253, 855714, 1062695, 1070024, 1351424, 602460, 601626, 823809, 529194, 528966, 529182, 1206464, 823722, 1073348, 936716, 824268, 824754, 823761, 1106879, 1034687, 825171, 601437, 1073342, 825111, 962981, 824430, 1106888, 527805, 527493, 734541, 703347, 528183, 517479, 517566, 517188, 517455, 517191, 518901, 517392, 861714, 861318, 1074149, 948404, 948422, 846174, 846393, 846378, 846546, 949178, 846156, 1176682, 824751, 823755, 825069, 824415, 823728, 1131047, 823866, 823932, 528945, 602256, 529158, 892073, 982319, 892070, 891545, 891707, 891635, 891710, 819492, 823662, 825027, 824298, 823557, 1122890, 824475, 825045, 824646, 963065, 824361, 823740, 957788, 962966, 529155, 963179, 982346, 1041482, 963080, 936914, 963131, 1121879, 1293395, 1293305, 1293380, 1293296, 1293410, 862860, 1070012, 697548, 602886, 700626, 1070015, 623997, 1070030, 700611, 820341, 820134, 1080842, 1351427, 1361414, 1351841, 1221969, 776244, 1351838, 1221972, 740451, 903800, 864537, 864360, 953360, 1383257, 864582, 864459, 864444, 964901, 776460, 949622, 846183, 862929, 847014, 847044, 847029, 846879, 865203, 865449, 862911, 846723, 846744, 846894, 904184, 903509, 880526, 947687, 864558, 864216, 846012, 1356845, 865353, 864729, 953228, 864066, 864597, 864720, 864654, 864258, 864252, 953342, 846870, 845991, 1363652, 1070831, 776109, 1211573, 880367, 1178228, 1178174, 1178225, 1178222, 1379123, 1359422, 1359443, 1359284, 1359257, 897548, 947696, 1380563, 846804, 878696, 878765, 880190, 880163, 880172, 934748, 934790, 896756, 864453, 1394600, 864732, 864714, 864711, 864120, 864231, 953357, 846954, 847041, 846867, 846906, 865200, 865446, 846720, 846003, 846918, 846741, 862926, 847035, 862908, 825096, 824757, 823536, 823764, 825138, 824709, 950354, 854925, 855696, 854928, 1106921, 956645, 855651, 602889, 1106927, 603153, 623901, 1110179, 697545, 891941, 1168643, 700614, 1168565, 1168637, 624498, 602562, 719541, 522903, 1168298, 522804, 820140, 1020647, 820167, 955952, 992345, 1395290, 1293539, 1293542, 1119695, 1034699, 601215, 528510, 528525, 988034, 529008, 528918, 1206431, 528411, 528495, 1034678, 528762, 963122, 959132, 962960, 963191, 602457, 963086, 963125, 1062692, 963035, 963134, 685524, 858210, 846771, 862863, 858033, 1110389, 972344, 992267
	)
	AND tp.promotion_status_id = 6
	GROUP BY tp.promotion_id
) AS table4_prom_data

ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
AND step1_join_data.prom_display_text = table4_prom_data.display_text

#WHERE step1_join_data.pk_deduction_id = 12261467

#AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
#, LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
# >= -14
#AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
#,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
#>= -14 
	
	
	
	

#to get resolved commits and promotions for given deductions




SELECT dd.pk_deduction_id, tc.commit_id, tp.promotion_id

FROM ded_deduction AS dd
LEFT JOIN  ded_deduction_resolution AS ddr
ON dd.pk_deduction_id = ddr.fk_deduction_id
LEFT JOIN ded_deduction_resolution_item AS ddri
ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
LEFT JOIN tpm_commit AS tc
ON tc.commit_id = ddri.fk_commitment_id
LEFT JOIN tpm_promotion AS tp
ON tp.promotion_id = tc.promotion_id

WHERE dd.pk_deduction_id IN
(
			13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352
)







# Modified Final Query






SELECT DISTINCT everything_except_commit.pk_deduction_id, commit_data.promotion_id1, commit_data.commit_id1 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            table1_display_text.ded_display_text,
            table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max
            
            FROM
                 (SELECT dd.pk_deduction_id, dd.company_code, dd.currency, mcar.payterms_desc,
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                 dd.fiscal_year=2016
                 AND systemstatus.pk_deduction_status_system_id = 4        
                 AND pk_reason_category_rad_id IN (126)
                 AND ddr.fk_resolution_type_id = 4
                 AND ddr.fk_resolution_status_id = 1
                 AND dd.fk_deduction_type_id = 0
                 AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                 GROUP BY dd.pk_deduction_id
                  LIMIT 100
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.ded_display_text, ded_data.prom_display_text, COUNT(*)
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id,
                    mcar.display_text AS ded_display_text, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promoiton_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
                           
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, 
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     dd.fiscal_year=2016
                     AND systemstatus.pk_deduction_status_system_id = 4        
                     AND pk_reason_category_rad_id IN (126)
                     AND ddr.fk_resolution_type_id = 4
                     AND ddr.fk_resolution_status_id = 1
                     AND dd.fk_deduction_type_id = 0
                     AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                     GROUP BY dd.pk_deduction_id
                     LIMIT 100
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
            (    
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description 
            
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
	    # union those deduction which have only 1 item descriptions
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2

            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1,
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
     
    AND tc.promotion_id IN 
    (
      865005, 692727, 896927, 697206, 896930, 675420, 862092, 865002, 847050, 864207, 646197, 864528, 579393, 846183, 896984, 579588, 947732, 949178, 986150, 957122, 862467, 1224294, 626904, 897227, 578967, 864741, 1049399, 1272584, 1062731, 579231, 846156, 846888, 955880, 897059, 1224222, 902774, 846393, 626802, 989954, 864408, 862917, 627681, 645765, 1071383, 864549, 1119359, 628278, 862419, 847059, 1404494, 865233, 1224315, 846444, 579132, 964910, 718374, 864210, 579408, 865413, 846915, 645840, 953222, 862401, 947735, 599961, 645999, 957125, 1227323, 1224300, 846420, 696879, 646116, 578991, 1189877, 1049408, 862935, 903257, 1272602, 579255, 955667, 628134, 905720, 864570, 949616, 709071, 1224282, 1359452, 897182, 946736, 897845, 862920, 627870, 1062719, 646173, 966653, 846876, 645771, 1071386, 896834, 697281, 628284, 897017, 862422, 846378, 847065, 846786, 864138, 646143, 579138, 898007, 645729, 870582, 579429, 986087, 628488, 953345, 1224303, 846429, 626937, 846756, 990479, 1070903, 897236, 578994, 862938, 948401, 579357, 1428659, 628149, 864573, 579561, 949622, 628440, 645951, 897068, 862452, 1224285, 626886, 897191, 946760, 1109096, 948323, 1062722, 957767, 948779, 846546, 645774, 646254, 947693, 847002, 897023, 1077431, 845964, 696687, 626652, 989927, 847068, 1404515, 946709, 1049249, 846456, 627417, 579156, 964928, 645732, 646218, 579453, 947678, 865425, 846201, 1176481, 1119335, 986090, 645846, 1077164, 679182, 846357, 646017, 953348, 897104, 864702, 862860, 1224306, 846432, 626958, 846759, 1062680, 870396, 1070915, 944820, 579003, 864522, 579372, 846174, 718416, 846579, 1293539, 864267, 905762, 896969, 847026, 1224288, 626892, 645570, 946775, 887852, 897857, 1062725, 646182, 896843, 579522, 947696, 696369, 847005, 1077440, 845967, 645546, 864012, 946721, 645633, 646155, 579171, 679053, 1062779, 864225, 646221, 957941, 579486, 947681, 1119338, 1186538, 697254, 846936, 645861, 864606, 628497, 864705, 1338776, 865215, 1224309, 696891, 626970, 1062686, 990485, 1070927, 944823, 864462, 579042, 887918, 964901, 955817, 628170, 846909, 1293542, 864270, 862392, 579582, 880259, 897080, 887417, 862842, 1224291, 1070891, 897212, 946778, 864738, 887873, 627924, 1062728, 696276, 846885, 645780, 864564, 1122716, 1050065, 1043081, 645921, 862443, 880379, 989933, 864015, 864405, 897170, 946727, 904001, 646164, 703824, 579195, 674616, 1062782, 864228, 646227, 579498, 846612, 1119356, 986099, 846948, 864609, 955943, 628500, 1224312, 990587, 870405, 864132, 646131, 864465, 579054, 740391, 776535, 1130012, 1029202, 776331, 1109306, 858375, 1174133, 988538, 721035, 1072613, 1129889, 1026395, 740397, 776346, 1070003, 1129892, 1212956, 1123229, 858204, 1176682, 644124, 646641, 984347, 1218389, 776070, 643908, 646434, 858210, 1041053, 1355933, 1175285, 1263740, 1296011, 1212965, 1123235, 858213, 1052852, 740709, 1355936, 1213742, 1130027, 776532, 1038230, 1034720, 644109, 1041068, 644412, 1178180, 1047515, 646443, 688173, 1052858, 1216545, 858180, 776124, 992276, 878693, 992882, 696873, 697035, 880976, 879008, 1104770, 967376, 1027013, 934757, 880175, 697269, 734691, 992318, 881333, 986156, 735042, 967412, 718401, 878786, 879044, 1034912, 735015, 1027019, 1029730, 734694, 979767, 878699, 880160, 690756, 735045, 697398, 1130498, 713388, 897551, 880187, 1038365, 734697, 1050365, 1034894, 880358, 1036676, 967349, 697248, 879251, 690762, 696198, 979749, 1120229, 881237, 714093, 697020, 713520, 734703, 1036694, 697083, 880169, 690768, 1120232, 696516, 690720, 734313, 964832, 696438, 897824, 934754, 897536, 880496, 690774, 692889, 675597, 692910, 645981, 646209, 703938, 703365, 696882, 703614, 645540, 696885, 704115, 718449, 718125, 646611, 1041902, 718182, 718161, 646464, 646587, 1080812, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 494949, 659181, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 843948, 497457, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 728190, 1026512, 1168301, 715878, 944105, 753486, 678303, 753669, 753720, 678243, 714783, 713412, 678306, 973145, 678435, 966140, 714408, 677970, 678441, 753891, 1040006, 753771, 1020656, 1047491, 678453, 753309, 973064, 713430, 678153, 677958, 678048, 714468, 1173392, 953285, 905804, 1129838, 948338, 1131302, 858030, 1227338, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 586647, 1109147, 1037522, 1043774, 956366, 534753, 869019, 1039988, 534906, 533859, 535050, 1075967, 642138, 534861, 533616, 995063, 534630, 717873, 1071038, 868593, 869058, 1039646, 817464, 868752, 534963, 615513, 535170, 534717, 1043777, 632178, 632778, 593211, 868800, 535086, 868995, 632601, 868638, 533817, 688986, 659055, 534735, 868599, 869064, 868755, 534597, 868866, 1186862, 1044800, 1039769, 534720, 959867, 535323, 697056, 697185, 1039994, 1044014, 579990, 586614, 534702, 579510, 642144, 534885, 628605, 1075955, 534651, 1021019, 868518, 944210, 817479, 868758, 535212, 1039775, 868578, 534780, 869034, 697188, 1044017, 959669, 1043768, 959957, 869007, 535401, 868647, 593199, 533844, 868779, 1110773, 1075958, 717708, 638910, 685797, 1039532, 995054, 534603, 586800, 959885, 868968, 868581, 817443, 1069202, 868824, 956225, 720345, 868392, 534711, 1043771, 868530, 959960, 534903, 868788, 1075964, 1021025, 535284, 1039535, 868623, 944219, 535002, 1122902, 717858, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 684156, 1113440, 1113635, 716475, 1113224, 641457, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 1114295, 726999, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 1114319, 727008, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 1083068, 983927, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362
     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)

	
	
#modified Final Query after adding original dispute amount



SELECT DISTINCT everything_except_commit.pk_deduction_id, everything_except_commit.original_dispute_amount, commit_data.promotion_id1, commit_data.commit_id1 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            table1_display_text.ded_display_text,
            table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            table3_ded_data.original_dispute_amount,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max
            
            FROM
                 (SELECT dd.pk_deduction_id, dd.original_dispute_amount, dd.company_code, dd.currency, mcar.payterms_desc,
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                 dd.fiscal_year=2016
                 AND systemstatus.pk_deduction_status_system_id = 4        
                 AND pk_reason_category_rad_id IN (126)
                 AND ddr.fk_resolution_type_id = 4
                 AND ddr.fk_resolution_status_id = 1
                 AND dd.fk_deduction_type_id = 0
                 AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                 GROUP BY dd.pk_deduction_id
                  LIMIT 100
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.ded_display_text, ded_data.prom_display_text, COUNT(*)
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id,
                    mcar.display_text AS ded_display_text, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promoiton_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
                           
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, 
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     dd.fiscal_year=2016
                     AND systemstatus.pk_deduction_status_system_id = 4        
                     AND pk_reason_category_rad_id IN (126)
                     AND ddr.fk_resolution_type_id = 4
                     AND ddr.fk_resolution_status_id = 1
                     AND dd.fk_deduction_type_id = 0
                     AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                     GROUP BY dd.pk_deduction_id
                     LIMIT 100
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
            (    
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description 
            
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2

            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1, tc.cal_planned_amount, 
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
     
    AND tc.promotion_id IN 
    (
      865005, 692727, 896927, 697206, 896930, 675420, 862092, 865002, 847050, 864207, 646197, 864528, 579393, 846183, 896984, 579588, 947732, 949178, 986150, 957122, 862467, 1224294, 626904, 897227, 578967, 864741, 1049399, 1272584, 1062731, 579231, 846156, 846888, 955880, 897059, 1224222, 902774, 846393, 626802, 989954, 864408, 862917, 627681, 645765, 1071383, 864549, 1119359, 628278, 862419, 847059, 1404494, 865233, 1224315, 846444, 579132, 964910, 718374, 864210, 579408, 865413, 846915, 645840, 953222, 862401, 947735, 599961, 645999, 957125, 1227323, 1224300, 846420, 696879, 646116, 578991, 1189877, 1049408, 862935, 903257, 1272602, 579255, 955667, 628134, 905720, 864570, 949616, 709071, 1224282, 1359452, 897182, 946736, 897845, 862920, 627870, 1062719, 646173, 966653, 846876, 645771, 1071386, 896834, 697281, 628284, 897017, 862422, 846378, 847065, 846786, 864138, 646143, 579138, 898007, 645729, 870582, 579429, 986087, 628488, 953345, 1224303, 846429, 626937, 846756, 990479, 1070903, 897236, 578994, 862938, 948401, 579357, 1428659, 628149, 864573, 579561, 949622, 628440, 645951, 897068, 862452, 1224285, 626886, 897191, 946760, 1109096, 948323, 1062722, 957767, 948779, 846546, 645774, 646254, 947693, 847002, 897023, 1077431, 845964, 696687, 626652, 989927, 847068, 1404515, 946709, 1049249, 846456, 627417, 579156, 964928, 645732, 646218, 579453, 947678, 865425, 846201, 1176481, 1119335, 986090, 645846, 1077164, 679182, 846357, 646017, 953348, 897104, 864702, 862860, 1224306, 846432, 626958, 846759, 1062680, 870396, 1070915, 944820, 579003, 864522, 579372, 846174, 718416, 846579, 1293539, 864267, 905762, 896969, 847026, 1224288, 626892, 645570, 946775, 887852, 897857, 1062725, 646182, 896843, 579522, 947696, 696369, 847005, 1077440, 845967, 645546, 864012, 946721, 645633, 646155, 579171, 679053, 1062779, 864225, 646221, 957941, 579486, 947681, 1119338, 1186538, 697254, 846936, 645861, 864606, 628497, 864705, 1338776, 865215, 1224309, 696891, 626970, 1062686, 990485, 1070927, 944823, 864462, 579042, 887918, 964901, 955817, 628170, 846909, 1293542, 864270, 862392, 579582, 880259, 897080, 887417, 862842, 1224291, 1070891, 897212, 946778, 864738, 887873, 627924, 1062728, 696276, 846885, 645780, 864564, 1122716, 1050065, 1043081, 645921, 862443, 880379, 989933, 864015, 864405, 897170, 946727, 904001, 646164, 703824, 579195, 674616, 1062782, 864228, 646227, 579498, 846612, 1119356, 986099, 846948, 864609, 955943, 628500, 1224312, 990587, 870405, 864132, 646131, 864465, 579054, 740391, 776535, 1130012, 1029202, 776331, 1109306, 858375, 1174133, 988538, 721035, 1072613, 1129889, 1026395, 740397, 776346, 1070003, 1129892, 1212956, 1123229, 858204, 1176682, 644124, 646641, 984347, 1218389, 776070, 643908, 646434, 858210, 1041053, 1355933, 1175285, 1263740, 1296011, 1212965, 1123235, 858213, 1052852, 740709, 1355936, 1213742, 1130027, 776532, 1038230, 1034720, 644109, 1041068, 644412, 1178180, 1047515, 646443, 688173, 1052858, 1216545, 858180, 776124, 992276, 878693, 992882, 696873, 697035, 880976, 879008, 1104770, 967376, 1027013, 934757, 880175, 697269, 734691, 992318, 881333, 986156, 735042, 967412, 718401, 878786, 879044, 1034912, 735015, 1027019, 1029730, 734694, 979767, 878699, 880160, 690756, 735045, 697398, 1130498, 713388, 897551, 880187, 1038365, 734697, 1050365, 1034894, 880358, 1036676, 967349, 697248, 879251, 690762, 696198, 979749, 1120229, 881237, 714093, 697020, 713520, 734703, 1036694, 697083, 880169, 690768, 1120232, 696516, 690720, 734313, 964832, 696438, 897824, 934754, 897536, 880496, 690774, 692889, 675597, 692910, 645981, 646209, 703938, 703365, 696882, 703614, 645540, 696885, 704115, 718449, 718125, 646611, 1041902, 718182, 718161, 646464, 646587, 1080812, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 494949, 659181, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 843948, 497457, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 728190, 1026512, 1168301, 715878, 944105, 753486, 678303, 753669, 753720, 678243, 714783, 713412, 678306, 973145, 678435, 966140, 714408, 677970, 678441, 753891, 1040006, 753771, 1020656, 1047491, 678453, 753309, 973064, 713430, 678153, 677958, 678048, 714468, 1173392, 953285, 905804, 1129838, 948338, 1131302, 858030, 1227338, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 586647, 1109147, 1037522, 1043774, 956366, 534753, 869019, 1039988, 534906, 533859, 535050, 1075967, 642138, 534861, 533616, 995063, 534630, 717873, 1071038, 868593, 869058, 1039646, 817464, 868752, 534963, 615513, 535170, 534717, 1043777, 632178, 632778, 593211, 868800, 535086, 868995, 632601, 868638, 533817, 688986, 659055, 534735, 868599, 869064, 868755, 534597, 868866, 1186862, 1044800, 1039769, 534720, 959867, 535323, 697056, 697185, 1039994, 1044014, 579990, 586614, 534702, 579510, 642144, 534885, 628605, 1075955, 534651, 1021019, 868518, 944210, 817479, 868758, 535212, 1039775, 868578, 534780, 869034, 697188, 1044017, 959669, 1043768, 959957, 869007, 535401, 868647, 593199, 533844, 868779, 1110773, 1075958, 717708, 638910, 685797, 1039532, 995054, 534603, 586800, 959885, 868968, 868581, 817443, 1069202, 868824, 956225, 720345, 868392, 534711, 1043771, 868530, 959960, 534903, 868788, 1075964, 1021025, 535284, 1039535, 868623, 944219, 535002, 1122902, 717858, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 684156, 1113440, 1113635, 716475, 1113224, 641457, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 1114295, 726999, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 1114319, 727008, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 1083068, 983927, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362
     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND everything_except_commit.original_dispute_amount <= ( commit_data.cal_planned_amount + 200)
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)









# modified final query ...using 1.5 on both the condition





SELECT DISTINCT everything_except_commit.pk_deduction_id, everything_except_commit.original_dispute_amount, commit_data.promotion_id1, commit_data.commit_id1 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            table1_display_text.ded_display_text,
            table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            table3_ded_data.original_dispute_amount,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max
            
            FROM
                 (SELECT dd.pk_deduction_id, dd.original_dispute_amount, dd.company_code, dd.currency, mcar.payterms_desc,
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                 dd.fiscal_year=2016
                 AND systemstatus.pk_deduction_status_system_id = 4        
                 AND pk_reason_category_rad_id IN (126)
                 AND ddr.fk_resolution_type_id = 4
                 AND ddr.fk_resolution_status_id = 1
                 AND dd.fk_deduction_type_id = 0
                 AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                 GROUP BY dd.pk_deduction_id
                  LIMIT 100
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.ded_display_text, ded_data.prom_display_text, COUNT(*)
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id,
                    mcar.display_text AS ded_display_text, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promoiton_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, ddi.extended_cost_norm, 
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     dd.fiscal_year=2016
                     AND systemstatus.pk_deduction_status_system_id = 4        
                     AND pk_reason_category_rad_id IN (126)
                     AND ddr.fk_resolution_type_id = 4
                     AND ddr.fk_resolution_status_id = 1
                     AND dd.fk_deduction_type_id = 0
                     AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                     GROUP BY dd.pk_deduction_id
                     LIMIT 100
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
            (    
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description 
            
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2

            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1, tc.cal_planned_amount, 
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
     
    AND tc.promotion_id IN 
    (
      865005, 692727, 896927, 697206, 896930, 675420, 862092, 865002, 847050, 864207, 646197, 864528, 579393, 846183, 896984, 579588, 947732, 949178, 986150, 957122, 862467, 1224294, 626904, 897227, 578967, 864741, 1049399, 1272584, 1062731, 579231, 846156, 846888, 955880, 897059, 1224222, 902774, 846393, 626802, 989954, 864408, 862917, 627681, 645765, 1071383, 864549, 1119359, 628278, 862419, 847059, 1404494, 865233, 1224315, 846444, 579132, 964910, 718374, 864210, 579408, 865413, 846915, 645840, 953222, 862401, 947735, 599961, 645999, 957125, 1227323, 1224300, 846420, 696879, 646116, 578991, 1189877, 1049408, 862935, 903257, 1272602, 579255, 955667, 628134, 905720, 864570, 949616, 709071, 1224282, 1359452, 897182, 946736, 897845, 862920, 627870, 1062719, 646173, 966653, 846876, 645771, 1071386, 896834, 697281, 628284, 897017, 862422, 846378, 847065, 846786, 864138, 646143, 579138, 898007, 645729, 870582, 579429, 986087, 628488, 953345, 1224303, 846429, 626937, 846756, 990479, 1070903, 897236, 578994, 862938, 948401, 579357, 1428659, 628149, 864573, 579561, 949622, 628440, 645951, 897068, 862452, 1224285, 626886, 897191, 946760, 1109096, 948323, 1062722, 957767, 948779, 846546, 645774, 646254, 947693, 847002, 897023, 1077431, 845964, 696687, 626652, 989927, 847068, 1404515, 946709, 1049249, 846456, 627417, 579156, 964928, 645732, 646218, 579453, 947678, 865425, 846201, 1176481, 1119335, 986090, 645846, 1077164, 679182, 846357, 646017, 953348, 897104, 864702, 862860, 1224306, 846432, 626958, 846759, 1062680, 870396, 1070915, 944820, 579003, 864522, 579372, 846174, 718416, 846579, 1293539, 864267, 905762, 896969, 847026, 1224288, 626892, 645570, 946775, 887852, 897857, 1062725, 646182, 896843, 579522, 947696, 696369, 847005, 1077440, 845967, 645546, 864012, 946721, 645633, 646155, 579171, 679053, 1062779, 864225, 646221, 957941, 579486, 947681, 1119338, 1186538, 697254, 846936, 645861, 864606, 628497, 864705, 1338776, 865215, 1224309, 696891, 626970, 1062686, 990485, 1070927, 944823, 864462, 579042, 887918, 964901, 955817, 628170, 846909, 1293542, 864270, 862392, 579582, 880259, 897080, 887417, 862842, 1224291, 1070891, 897212, 946778, 864738, 887873, 627924, 1062728, 696276, 846885, 645780, 864564, 1122716, 1050065, 1043081, 645921, 862443, 880379, 989933, 864015, 864405, 897170, 946727, 904001, 646164, 703824, 579195, 674616, 1062782, 864228, 646227, 579498, 846612, 1119356, 986099, 846948, 864609, 955943, 628500, 1224312, 990587, 870405, 864132, 646131, 864465, 579054, 740391, 776535, 1130012, 1029202, 776331, 1109306, 858375, 1174133, 988538, 721035, 1072613, 1129889, 1026395, 740397, 776346, 1070003, 1129892, 1212956, 1123229, 858204, 1176682, 644124, 646641, 984347, 1218389, 776070, 643908, 646434, 858210, 1041053, 1355933, 1175285, 1263740, 1296011, 1212965, 1123235, 858213, 1052852, 740709, 1355936, 1213742, 1130027, 776532, 1038230, 1034720, 644109, 1041068, 644412, 1178180, 1047515, 646443, 688173, 1052858, 1216545, 858180, 776124, 992276, 878693, 992882, 696873, 697035, 880976, 879008, 1104770, 967376, 1027013, 934757, 880175, 697269, 734691, 992318, 881333, 986156, 735042, 967412, 718401, 878786, 879044, 1034912, 735015, 1027019, 1029730, 734694, 979767, 878699, 880160, 690756, 735045, 697398, 1130498, 713388, 897551, 880187, 1038365, 734697, 1050365, 1034894, 880358, 1036676, 967349, 697248, 879251, 690762, 696198, 979749, 1120229, 881237, 714093, 697020, 713520, 734703, 1036694, 697083, 880169, 690768, 1120232, 696516, 690720, 734313, 964832, 696438, 897824, 934754, 897536, 880496, 690774, 692889, 675597, 692910, 645981, 646209, 703938, 703365, 696882, 703614, 645540, 696885, 704115, 718449, 718125, 646611, 1041902, 718182, 718161, 646464, 646587, 1080812, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 494949, 659181, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 843948, 497457, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 728190, 1026512, 1168301, 715878, 944105, 753486, 678303, 753669, 753720, 678243, 714783, 713412, 678306, 973145, 678435, 966140, 714408, 677970, 678441, 753891, 1040006, 753771, 1020656, 1047491, 678453, 753309, 973064, 713430, 678153, 677958, 678048, 714468, 1173392, 953285, 905804, 1129838, 948338, 1131302, 858030, 1227338, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 586647, 1109147, 1037522, 1043774, 956366, 534753, 869019, 1039988, 534906, 533859, 535050, 1075967, 642138, 534861, 533616, 995063, 534630, 717873, 1071038, 868593, 869058, 1039646, 817464, 868752, 534963, 615513, 535170, 534717, 1043777, 632178, 632778, 593211, 868800, 535086, 868995, 632601, 868638, 533817, 688986, 659055, 534735, 868599, 869064, 868755, 534597, 868866, 1186862, 1044800, 1039769, 534720, 959867, 535323, 697056, 697185, 1039994, 1044014, 579990, 586614, 534702, 579510, 642144, 534885, 628605, 1075955, 534651, 1021019, 868518, 944210, 817479, 868758, 535212, 1039775, 868578, 534780, 869034, 697188, 1044017, 959669, 1043768, 959957, 869007, 535401, 868647, 593199, 533844, 868779, 1110773, 1075958, 717708, 638910, 685797, 1039532, 995054, 534603, 586800, 959885, 868968, 868581, 817443, 1069202, 868824, 956225, 720345, 868392, 534711, 1043771, 868530, 959960, 534903, 868788, 1075964, 1021025, 535284, 1039535, 868623, 944219, 535002, 1122902, 717858, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 684156, 1113440, 1113635, 716475, 1113224, 641457, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 1114295, 726999, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 1114319, 727008, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 1083068, 983927, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362
     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)

AND ( 
(NOT ISNULL(everything_except_commit.extended_cost_norm)  AND (everything_except_commit.extended_cost_norm <= (1.5 * commit_data.cal_planned_amount)))
OR
(( everything_except_commit.original_dispute_amount <= ( 1.5 * commit_data.cal_planned_amount )))
)





#final query using LEAST


SELECT COUNT(*) FROM
(
SELECT DISTINCT everything_except_commit.pk_deduction_id, everything_except_commit.original_dispute_amount, commit_data.promotion_id1, commit_data.commit_id1 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            table1_display_text.ded_display_text,
            table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            table3_ded_data.original_dispute_amount,
            table3_ded_data.original_dispute_amount_not_null,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max
            
            FROM
                 (SELECT dd.pk_deduction_id, dd.original_dispute_amount, dd.company_code, dd.currency, mcar.payterms_desc,
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 (CASE WHEN ISNULL(dd.original_dispute_amount) THEN 1000000 ELSE dd.original_dispute_amount END) AS original_dispute_amount_not_null,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                 #dd.fiscal_year=2016 AND
                 systemstatus.pk_deduction_status_system_id = 4        
                 AND pk_reason_category_rad_id IN (126)
                 AND ddr.fk_resolution_type_id = 4
                 AND ddr.fk_resolution_status_id = 1
                 AND dd.fk_deduction_type_id = 0
                 AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                 GROUP BY dd.pk_deduction_id
                  LIMIT 1000
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.ded_display_text, ded_data.prom_display_text, COUNT(*)
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id,
                    mcar.display_text AS ded_display_text, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promoiton_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, ddi.extended_cost_norm, 
            
	    (CASE WHEN ISNULL(ddi.extended_cost_norm) THEN 1000000 ELSE ddi.extended_cost_norm END) AS extended_cost_norm_not_null,
                 
            
            
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     #dd.fiscal_year=2016 AND 
                     systemstatus.pk_deduction_status_system_id = 4        
                     AND pk_reason_category_rad_id IN (126)
                     AND ddr.fk_resolution_type_id = 4
                     AND ddr.fk_resolution_status_id = 1
                     AND dd.fk_deduction_type_id = 0
                     AND dd.auto_matched_commit_status IN ('Partial Match','Total Match') 
                     GROUP BY dd.pk_deduction_id
                     LIMIT 1000
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
            (    
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description 
            
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2

            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1, tc.cal_planned_amount, 
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
    AND tc.cal_planned_amount > 0     
     
    AND tc.promotion_id IN 
    (
	522570, 720417, 532161, 599154, 522213, 599124, 522270, 956381, 523797, 532083, 598809, 522273, 522576, 523800, 701448, 532176, 718593, 599109, 532089, 726492, 623832, 523734, 702033, 522588, 523809, 532197, 523617, 522639, 623844, 532158, 523752, 522207, 522591, 532203, 523620, 531837, 532098, 523629, 522552, 523761, 702024, 632382, 522657, 598812, 623802, 532149, 718596, 522513, 599112, 717669, 523812, 523788, 523758, 623796, 531840, 522651, 523533, 522555, 532143, 522510, 598815, 599085, 522231, 718314, 532095, 728190, 715878, 944105, 678156, 678303, 702798, 678243, 688701, 714783, 678306, 973145, 678462, 702834, 944066, 713295, 678246, 725748, 677946, 715890, 1040006, 955154, 677982, 1020656, 678453, 678264, 973064, 678546, 728187, 714420, 703131, 678456, 678048, 714468, 678420, 702795, 678552, 678435, 966140, 714408, 677970, 677958, 688470, 697197, 964505, 586647, 1043774, 733479, 534753, 534906, 533859, 535050, 936713, 642138, 534861, 533616, 534630, 717873, 688473, 534963, 615513, 964508, 717654, 535170, 534717, 1043777, 632178, 697176, 632778, 593211, 936716, 632601, 688986, 659055, 534735, 951362, 618132, 534597, 534720, 535323, 697056, 579990, 586614, 720339, 534702, 579510, 642144, 534885, 628605, 534651, 944210, 982037, 535212, 534780, 936725, 1043768, 535401, 593199, 533844, 535035, 638910, 534603, 586800, 534726, 613689, 534711, 936728, 1043771, 534903, 717711, 535284, 936710, 944219, 535002, 717858, 697173, 688524, 688485, 535038, 692727, 692889, 697206, 675306, 697017, 675420, 675597, 692910, 675732, 646197, 579393, 628182, 579588, 696537, 599952, 628470, 986150, 645981, 957122, 626904, 978293, 578967, 627930, 1062731, 579231, 628113, 626802, 989954, 627681, 645765, 1071383, 1119359, 628278, 696900, 627405, 579132, 718374, 645726, 646209, 703938, 579408, 697203, 628188, 645840, 599961, 645999, 957125, 703365, 626910, 646116, 578991, 679017, 579255, 628134, 709071, 626880, 627870, 1062719, 646173, 645771, 1071386, 628284, 696678, 645627, 646143, 579138, 645729, 579429, 986087, 645843, 628488, 646002, 696882, 626937, 990479, 703614, 578994, 579357, 628149, 579561, 628440, 645951, 626886, 978284, 1109096, 627876, 1062722, 630072, 948779, 645774, 646254, 599805, 645888, 696687, 626652, 645540, 989927, 627417, 579156, 679050, 645732, 646218, 678696, 579453, 1119335, 986090, 645846, 679182, 628491, 646017, 696885, 626958, 1062680, 579003, 579372, 718416, 1043903, 628152, 645831, 628443, 645954, 978287, 627921, 645708, 1062725, 646182, 696267, 646257, 579522, 697335, 1077440, 696759, 626655, 645546, 674490, 645633, 646155, 579171, 646221, 957941, 704115, 579486, 1119338, 986096, 645861, 628497, 646020, 626970, 1062686, 990485, 579042, 628170, 579582, 674922, 626895, 645573, 627924, 1062728, 645780, 1043081, 986117, 645921, 626790, 989933, 904001, 627678, 1062713, 646164, 703824, 579195, 674616, 628008, 645750, 646227, 579498, 1119356, 986099, 645864, 628500, 696897, 990587, 646131, 579054, 647577, 1029202, 988538, 721035, 644373, 647472, 718449, 718125, 644115, 646611, 1070003, 647544, 1041902, 643872, 718182, 647583, 1040663, 644124, 646641, 643908, 644400, 720966, 646434, 1041053, 718161, 644127, 646464, 644409, 989930, 1052852, 646587, 644130, 1038230, 1080812, 1034720, 1047563, 1029199, 644109, 1041068, 644412, 1047515, 646443, 688173, 1052858, 991643, 696873, 697035, 1030405, 1104770, 967376, 697269, 734691, 986156, 735042, 967412, 718401, 735015, 1029730, 734694, 957923, 979767, 690756, 735045, 697398, 967385, 713388, 734697, 1050365, 967349, 957929, 697248, 690762, 696198, 979749, 714093, 697020, 690930, 713520, 734703, 690768, 696294, 696516, 690720, 734313, 1029766, 696438, 696636, 690774, 696879, 696369, 696276, 697083, 535245, 988490, 936698, 936701, 534741, 936704, 720345, 697281, 697254, 1120232, 1109147, 1039994, 956366, 995063, 717708, 956225, 957767, 1077431, 626892, 645570, 679053, 696891, 1130498, 1120229, 865005, 896927, 896930, 865002, 864528, 846183, 896984, 947732, 949178, 862467, 1224294, 897227, 864741, 1049399, 1272584, 846156, 846888, 955880, 897059, 1224222, 902774, 846393, 864408, 864549, 862419, 847059, 1404494, 865233, 1224315, 846444, 964910, 864210, 862401, 947735, 1227323, 1224300, 846420, 1189877, 1049408, 903257, 1272602, 864570, 1224282, 1359452, 897182, 946736, 897845, 862920, 966653, 896834, 897017, 862422, 846378, 847065, 864138, 898007, 1224303, 846429, 1070903, 897236, 862938, 948401, 1428659, 949622, 897068, 862452, 1224285, 897191, 946760, 846546, 947693, 897023, 845964, 1404515, 946709, 1049249, 846456, 964928, 947678, 865425, 846201, 846357, 953348, 897104, 862860, 1224306, 846432, 846759, 1070915, 944820, 846174, 846579, 1293539, 864267, 896969, 1224288, 946775, 897857, 896843, 947696, 847005, 864012, 946721, 1062779, 864225, 947681, 846936, 864606, 1338776, 864705, 1224309, 1070927, 944823, 964901, 955817, 846909, 1293542, 862392, 880259, 897080, 862842, 1224291, 1070891, 897212, 946778, 887873, 864564, 1122716, 1050065, 862443, 880379, 897170, 946727, 1062782, 846612, 846948, 1224312, 864465, 740391, 776535, 1130012, 1174133, 1072613, 1129889, 1026395, 740397, 1129892, 1212956, 1123229, 858204, 984347, 776070, 858210, 1355933, 1175285, 1263740, 1212965, 1123235, 858213, 740709, 1355936, 1213742, 1130027, 776532, 1178180, 1216545, 776124, 992276, 878693, 880976, 1027013, 934757, 880175, 992318, 878786, 879044, 1027019, 878699, 880160, 897551, 880187, 1038365, 880358, 1036676, 879251, 881237, 880169, 964832, 897824, 934754, 897536, 880496, 1039988, 535086, 697185, 697188, 713412, 678441, 713430, 678153, 862092, 847050, 870396, 1075967, 1075955, 1075958, 995054, 1075964, 864207, 862917, 865413, 846915, 953222, 862935, 955667, 905720, 949616, 846876, 846786, 870582, 953345, 846756, 864573, 948323, 847002, 847068, 1176481, 1077164, 864702, 864522, 905762, 847026, 887852, 845967, 1186538, 865215, 864462, 887918, 864270, 887417, 864738, 846885, 864015, 864405, 864228, 864609, 955943, 870405, 864132, 776331, 1109306, 858375, 776346, 1176682, 1218389, 1296011, 858180, 992882, 879008, 881333, 1034912, 1034894, 1036694, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 494949, 659181, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 497457, 843948, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 1026512, 1168301, 753486, 753669, 753720, 753891, 753771, 1047491, 753309, 1173392, 953285, 905804, 1129838, 948338, 1131302, 1227338, 858030, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 1037522, 869019, 1071038, 868593, 869058, 1039646, 817464, 868752, 868800, 868995, 868638, 533817, 868599, 869064, 868755, 868866, 1186862, 1044800, 1039769, 959867, 1044014, 1021019, 868518, 817479, 868758, 1039775, 868578, 869034, 1044017, 959669, 959957, 869007, 868647, 868779, 1110773, 685797, 1039532, 959885, 868968, 868581, 817443, 1069202, 868824, 868392, 868530, 959960, 868788, 1021025, 1039535, 868623, 1122902, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 1113440, 684156, 1113635, 716475, 1113224, 641457, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 726999, 1114295, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 727008, 1114319, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 1083068, 983927, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362, 1195697, 1195628, 897524, 1084049, 1084079, 1082945, 1082930, 876131, 1223319, 837270, 876365, 837486, 876266, 837321, 854538, 1222905, 876134, 837282, 1222857, 1190123, 876368, 1223034, 837426, 854544, 1072871, 1190039, 876143, 876518, 837285, 871776, 1222866, 1190126, 876380, 837519, 1223391, 837459, 854463, 854550, 1190042, 837288, 871779, 876392, 933893, 1223043, 837474, 854466, 854178, 876248, 1223349, 837303, 1072862, 876122, 837558, 876362, 1110779, 837483, 854469, 854181, 876251, 876599, 837318, 846627, 862863, 865149, 861984, 870366, 1129847, 1334618, 905735, 1131074, 870585, 948404, 1173380, 1334630, 1338191, 1209086, 1173356, 948422, 740451, 858738, 776244, 740580, 858033, 1122713, 1110389, 858039, 1110497, 1293545, 1200101, 992447, 1026983, 1026995, 879083, 897275, 1201817, 1388807, 1367495, 1061750, 858717, 1061813, 992234, 880637, 1361495, 1362134, 1070267, 1070417, 1070588, 1193027, 1193351, 1070276, 1069211, 1033204, 1361513, 1196531, 1362143, 1270346, 1193261, 1070540, 1074665, 1193264, 1193618, 1113815, 1053200, 1033225, 1186883, 1033243, 868851, 1212977, 959894, 959864, 868563, 959975, 1190240, 1123154, 1190222, 1070225, 1217816, 1074662, 1190225, 959900, 1039781, 1070168, 1121357, 1217822, 1190231, 1460147, 1460150, 1211573, 1201811, 1460156, 1460174, 1130804, 753336, 753912, 1368860, 1207193, 1207202, 862329, 1186523, 897083, 846417, 864252, 847014, 862446, 1042016, 1215554, 897014, 897134, 1216611, 1363646, 896993, 953342, 865203, 846012, 897230, 846894, 955889, 897062, 864654, 845991, 864066, 864729, 1383950, 1042019, 865449, 864393, 846453, 865353, 1363652, 864597, 862404, 897101, 1042082, 864258, 1131236, 846879, 896837, 1131185, 864216, 1363655, 953228, 897002, 862407, 847044, 897242, 887906, 864579, 864660, 862455, 846744, 864444, 897203, 864558, 1131077, 897026, 1398620, 846723, 897167, 864720, 862911, 846363, 846438, 948413, 864525, 896981, 847029, 862461, 862929, 956516, 864495, 846870, 1042172, 1396301, 776460, 1040168, 897833, 878696, 1353710, 1178222, 897548, 992345, 1338068, 880709, 1178225, 1026815, 934790, 880163, 992252, 1038392, 1178228, 1337825, 878765, 880190, 1178174, 1353830, 880367, 934748, 992459, 880172, 1027010, 861315, 850380, 861801, 849870, 1106876, 849972, 850356, 861426, 849606, 849765, 1105082, 861318, 850134, 1105061, 994190, 862800, 820101, 850203, 849609, 1106939, 850137, 862803, 820104, 850206, 849876, 863136, 1106882, 818610, 1074149, 861729, 1105016, 1106885, 850374, 994202, 861714, 819927, 1074209, 850377, 849627, 1106873, 849963, 1104986, 963086, 825006, 1359362, 1106927, 824250, 1122995, 823836, 963179, 1224612, 936914, 825123, 981246, 823557, 955448, 963131, 891620, 1224588, 825069, 823536, 823662, 1226576, 820374, 959138, 825021, 825186, 1106930, 820140, 823755, 982325, 824757, 985727, 891710, 823956, 1224618, 825138, 1106912, 855186, 981249, 1226489, 855696, 824475, 956630, 855570, 1224663, 824277, 820167, 854925, 824646, 982346, 1359164, 891713, 823962, 1106915, 823728, 824544, 824709, 1224594, 1226405, 855699, 1168637, 824529, 820392, 963122, 891566, 825027, 855573, 824298, 854928, 823764, 957788, 963065, 891506, 823866, 1106918, 855651, 823620, 891941, 823740, 892073, 824721, 1224600, 825096, 823698, 819492, 963125, 825045, 956645, 1041482, 824361, 962960, 820338, 963080, 959132, 892097, 963191, 1106921, 855654, 1168298, 892076, 824751, 1168565, 1110179, 823701, 1168643, 982307, 891617, 824415, 933608, 1226573, 962966, 1122329, 1224870, 1193372, 1122335, 1190264, 1193123, 1224762, 1051865, 1122350, 1083977, 1120436, 1191749, 1351952, 1082693, 1082765, 1351424, 1221915, 1082891, 1186811, 1222740, 1191026, 1187831, 1350023, 1170932, 1361888, 1082255, 1082744, 1191191, 1120688, 1120448, 1224795, 1186499, 1221933, 1120739, 1081382, 1191200, 1083416, 1351841, 1123397, 1080836, 1178087, 1222128, 1191080, 1191548, 1084532, 1221936, 1191731, 1120634, 1170938, 1081391, 1084016, 1191800, 1082219, 1351808, 1221969, 1191770, 1083659, 1301705, 1351433, 1084538, 1122272, 1082900, 1184822, 1351415, 1222566, 1084022, 1221990, 1084004, 1123388, 1222779, 1082174, 1191152, 1083785, 1221777, 1083974, 1122275, 1082762, 1191632, 1084034, 1082531, 1084196, 1187828, 1081358, 1186553, 1191572, 1084007, 1080974, 1083791, 1080830, 1301717, 1221783, 1122278, 1084139, 1084514, 1224711, 1084037, 1082159, 1081373, 1186559, 1351838, 1191785, 1222185, 1191161, 1080833, 1082918, 1123367, 1084145, 1191755, 1191545, 1351427, 1084526, 1186817, 1191728, 1222743, 1187834, 1082162, 1350026, 1082852, 1084181, 1120691, 1222788, 1221846, 1120652, 1083965, 1122266, 1082897, 1104995, 1082756, 1351394, 1222560, 1080992, 1351853, 1221987, 1191182, 1120469, 1083968, 1221939, 1082759, 1191626, 1191809, 1120472, 1361414, 1221972, 1104980, 1082705, 1301708, 1351436, 1186487, 1191209, 1221912, 1191023, 1083410, 1351832, 1123391, 846789, 862941, 955925, 1395581, 947687, 1396373, 1396307, 1395584, 880526, 903800, 1355918, 904184, 1540058, 955505, 1356212, 1380563, 1396232, 903509, 1396292, 1395578, 1380776, 1396262, 1299029, 1395563, 1110647, 972344, 1359257, 1379081, 1359443, 1359284, 1359422, 1353713, 1379123, 1457717, 992267, 1353734, 847035, 864360, 865200, 846003, 956519, 1398650, 864231, 865446, 953357, 864711, 864453, 846954, 953360, 864714, 846918, 1400945, 847041, 887891, 955898, 846741, 864732, 1129829, 846720, 862908, 864537, 1395374, 864459, 1173401, 846906, 1394249, 862926, 902756, 846867, 1178402, 864120, 864582, 1383257, 870591, 776505, 858396, 1220126, 858042, 880343, 878921, 1176523, 1176460, 1384856, 1176526, 1384859, 1359254, 1391753, 1359305, 1269149, 1382468, 1382465, 1293305, 1121879, 1293296, 1122776, 1293410, 1293395, 1293380, 1297013, 1122890, 1297010, 1131047, 1297088, 970133, 753489, 753615, 1074110, 1190963, 753906, 753618, 754668, 753480, 753252, 753774, 753483, 753666, 754680, 1222524, 1221960, 1376048, 1359293, 1184564, 1222515, 1221945, 1222758, 1189946, 1221948, 1222764, 1376045, 1189841, 1221903, 1359296, 1184567, 1222521, 1373315, 1373318, 1355765, 1215545, 896915, 896561, 1335887, 1402868, 897668, 955952, 1396982, 1110698, 740301, 740376, 897287, 879194, 1353845, 1195868, 1353401, 1176400, 1353680, 1353683, 1191575, 753294, 1269815, 860907, 1107680, 860769, 1070405, 867243, 1340594, 860892, 1272803, 860724, 860772, 1122584, 860805, 1122737, 860895, 1070693, 865101, 860922, 860808, 860898, 1123067, 1070537, 1382144, 1107653, 860949, 1070309, 860925, 1070240, 860778, 1269737, 860763, 1108697, 1382147, 1107656, 860967, 822972, 1359110, 1070243, 823002, 1396202, 1193735, 1270793, 1070402, 867237, 1396118, 1070582, 1107659, 1193681, 822975, 1070684, 1032295, 1359704, 1359092, 1193288, 1199243, 1384799, 1221867, 1384649, 1295624, 1384727, 1383848, 1359314, 1222644, 1295651, 1384733, 1082345, 1384712, 1384763, 1359458, 1384688, 1379072, 1384658, 1384739, 1384790, 1359728, 1222152, 1193384, 1384841, 1082438, 1193357, 1081322, 1359767, 1359437, 1384769, 1383860, 1359089, 1114598, 1113878, 1379078, 1222737, 1081232, 1384748, 1359635, 1359749, 1221855, 1081331, 1114565, 1359116, 1359755, 1408487, 1384760, 1384835, 1384679, 1379069, 1384655, 1359719, 1359521, 1384838, 1383854, 1359425, 1221849, 1082360, 1384766, 1222266, 1359698, 1359086, 1408526, 1379075, 1222731, 1081220, 1384745, 1384793, 1359743, 1193390, 1193360, 1359440, 1384670, 1114433, 1082456, 1376840, 1222251, 1395290, 1222242, 1376843, 1082453, 846804, 1405142, 903212, 870414, 880184, 880415, 1209113, 1076045, 1405136, 870363, 1405139, 1404482, 776154, 1410162, 1410165, 776328, 1428602, 896756, 754629, 753723, 753903, 753894, 1180292, 868590, 1679132, 817458, 868749, 1191275, 1121363, 1339391, 868548, 959966, 1191212, 1189739, 868791, 1190234, 1189829, 868989, 868635, 1190219, 1122353, 1224819, 1192931, 1679135, 868857, 1070222, 1039763, 869022, 1044011, 1121330, 868773, 1356863, 959897, 1074626, 1191179, 817473, 1122332, 868956, 868566, 959993, 869025, 868806, 868998, 868641, 868776, 1039529, 868602, 1113812, 1053197, 868965, 868821, 1374899, 1217819, 868527, 1193018, 1190228, 1356923, 1021022, 868620, 817515, 868761, 1356845, 1224669, 1122338, 1021007, 1044809, 1180247, 869040, 1191257, 1044020, 959849, 1071032, 1192922, 869010, 1193093, 1373369, 1189826, 959888, 846630, 861999, 846912, 864585, 887456, 1040243, 864450, 887876, 1428518, 870594, 846951, 846711, 847038, 846738, 864237, 1437224, 862905, 1447571, 1359383, 864456, 846900, 862923, 953363, 864717, 846864, 955934, 864108, 864735, 864540, 1447775, 865434, 1359395, 847047, 864357, 864666, 865194, 846000, 1437218, 953354, 864708, 1211183, 1428650, 1465412, 1455929, 1476764, 1527020, 1552241, 1552205, 858177, 1428638, 1448459, 1449209, 881279, 850335, 861717, 819933, 850131, 1293416, 994187, 849630, 1293401, 1074137, 1293383, 849924, 861720, 1353371, 861291, 1353455, 1293404, 849975, 850368, 861429, 1074146, 1353374, 849675, 1105064, 849897, 850371, 1293389, 820203, 1105067, 1293299, 820107, 849879, 849615, 820410, 850350, 849684, 994454, 850332, 1293302, 850128, 1293413, 850353, 1393439, 892100, 891737, 823626, 823953, 855630, 1032490, 1646069, 963035, 824697, 1131050, 1227386, 855687, 854940, 962969, 823773, 963089, 963197, 1119533, 1399856, 892085, 855633, 1368863, 1654718, 1646078, 1133855, 1032463, 823539, 1646057, 854943, 962972, 963107, 1131032, 1646183, 1702028, 1119536, 962954, 963041, 1400012, 824772, 963185, 825147, 981267, 1654721, 892166, 825093, 1032466, 823542, 1041497, 1646060, 1646186, 1227356, 1041476, 1227107, 963188, 825153, 1368869, 854907, 963140, 892169, 823938, 1213775, 824532, 1646063, 982304, 959156, 1119695, 1353362, 823623, 824247, 1368872, 854910, 891947, 823950, 936908, 1032484, 1213778, 824535, 819501, 963128, 959162, 825066, 855579, 1227377, 855681, 823770, 1383974, 1211825, 1211828, 1211798, 1383971, 1211801, 1211822, 956522, 955937, 1445033, 1352051, 858636, 776064, 1435697, 1464125, 1355492, 1409306
     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)

AND (LEAST(everything_except_commit.extended_cost_norm_not_null, everything_except_commit.original_dispute_amount_not_null) <= (1.5 * commit_data.cal_planned_amount))


) AS temp






#manually providing 1000 ded using least function



SELECT COUNT(*) FROM
(

SELECT DISTINCT everything_except_commit.pk_deduction_id, everything_except_commit.original_dispute_amount, commit_data.promotion_id1, commit_data.commit_id1 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            table1_display_text.ded_display_text,
            table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            table3_ded_data.original_dispute_amount,
            table3_ded_data.original_dispute_amount_not_null,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max
            
            FROM
                 (SELECT dd.pk_deduction_id, dd.original_dispute_amount, dd.company_code, dd.currency, mcar.payterms_desc,
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 (CASE WHEN ISNULL(dd.original_dispute_amount) THEN 1000000 ELSE dd.original_dispute_amount END) AS original_dispute_amount_not_null,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                  dd.pk_deduction_id IN 
                 (
			11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
                 )
                 GROUP BY dd.pk_deduction_id
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.ded_display_text, ded_data.prom_display_text, COUNT(*)
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id,
                    mcar.display_text AS ded_display_text, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promoiton_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, ddi.extended_cost_norm, 
            
	    (CASE WHEN ISNULL(ddi.extended_cost_norm) THEN 1000000 ELSE ddi.extended_cost_norm END) AS extended_cost_norm_not_null,
                 
            
            
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     dd.pk_deduction_id IN 
		     (
				11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
		     )
                     GROUP BY dd.pk_deduction_id
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
            (    
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description 
            
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2

            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1, tc.cal_planned_amount, 
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
    AND tc.cal_planned_amount > 0     
     
    AND tc.promotion_id IN 
    (
		865005, 692727, 896927, 697206, 896930, 675420, 862092, 865002, 847050, 864207, 646197, 864528, 579393, 846183, 896984, 579588, 947732, 949178, 986150, 957122, 862467, 1224294, 626904, 897227, 578967, 864741, 1049399, 1272584, 1062731, 579231, 846156, 846888, 955880, 897059, 902774, 1224222, 846393, 626802, 989954, 864408, 862917, 627681, 645765, 1071383, 864549, 1119359, 628278, 862419, 847059, 1404494, 865233, 1224315, 846444, 579132, 964910, 718374, 864210, 579408, 865413, 846915, 645840, 953222, 862401, 947735, 599961, 645999, 957125, 1227323, 1224300, 846420, 696879, 646116, 578991, 1189877, 1049408, 862935, 903257, 1272602, 579255, 955667, 628134, 905720, 864570, 949616, 709071, 1224282, 1359452, 897182, 946736, 897845, 862920, 627870, 1062719, 646173, 966653, 846876, 645771, 1071386, 896834, 697281, 628284, 897017, 862422, 846378, 847065, 846786, 864138, 646143, 579138, 898007, 645729, 870582, 579429, 986087, 628488, 953345, 1224303, 846429, 626937, 846756, 990479, 1070903, 897236, 578994, 862938, 948401, 579357, 1428659, 628149, 864573, 579561, 949622, 628440, 645951, 897068, 862452, 1224285, 626886, 897191, 946760, 1109096, 948323, 1062722, 957767, 948779, 846546, 645774, 646254, 947693, 847002, 897023, 1077431, 845964, 696687, 626652, 989927, 847068, 1404515, 946709, 1049249, 846456, 627417, 579156, 964928, 645732, 646218, 579453, 947678, 865425, 846201, 1176481, 1119335, 986090, 645846, 1077164, 679182, 846357, 646017, 953348, 897104, 864702, 862860, 1224306, 846432, 626958, 846759, 1062680, 870396, 1070915, 944820, 579003, 864522, 579372, 846174, 718416, 846579, 1293539, 864267, 905762, 896969, 847026, 1224288, 626892, 645570, 946775, 887852, 897857, 1062725, 646182, 896843, 579522, 947696, 696369, 847005, 1077440, 845967, 645546, 864012, 946721, 645633, 646155, 579171, 679053, 1062779, 864225, 646221, 957941, 579486, 947681, 1119338, 1186538, 697254, 846936, 645861, 864606, 628497, 864705, 1338776, 865215, 1224309, 696891, 626970, 1062686, 990485, 1070927, 944823, 864462, 579042, 887918, 964901, 955817, 628170, 846909, 1293542, 864270, 862392, 579582, 880259, 897080, 887417, 862842, 1224291, 1070891, 897212, 946778, 864738, 887873, 627924, 1062728, 696276, 846885, 645780, 864564, 1122716, 1050065, 1043081, 645921, 862443, 880379, 989933, 864015, 864405, 897170, 946727, 904001, 646164, 703824, 579195, 674616, 1062782, 864228, 646227, 579498, 846612, 1119356, 986099, 846948, 864609, 955943, 628500, 1224312, 990587, 870405, 864132, 646131, 864465, 579054, 740391, 776535, 1130012, 1029202, 776331, 1109306, 858375, 1174133, 988538, 721035, 1072613, 1129889, 1026395, 740397, 776346, 1070003, 1129892, 1212956, 1123229, 858204, 1176682, 644124, 646641, 984347, 1218389, 776070, 643908, 646434, 858210, 1041053, 1355933, 1175285, 1263740, 1296011, 1212965, 1123235, 858213, 1052852, 740709, 1355936, 1213742, 1130027, 776532, 1038230, 1034720, 644109, 1041068, 644412, 1178180, 1047515, 646443, 688173, 1052858, 1216545, 858180, 776124, 992276, 878693, 992882, 696873, 697035, 880976, 879008, 1104770, 967376, 1027013, 934757, 880175, 697269, 734691, 992318, 881333, 986156, 735042, 967412, 718401, 878786, 879044, 1034912, 735015, 1027019, 1029730, 734694, 979767, 878699, 880160, 690756, 735045, 697398, 1130498, 713388, 897551, 880187, 1038365, 734697, 1050365, 1034894, 880358, 1036676, 967349, 697248, 879251, 690762, 696198, 979749, 1120229, 881237, 714093, 697020, 713520, 734703, 1036694, 697083, 880169, 690768, 1120232, 696516, 690720, 734313, 964832, 696438, 897824, 934754, 897536, 880496, 690774, 692889, 675597, 692910, 645981, 646209, 703938, 703365, 696882, 703614, 645540, 696885, 704115, 718449, 718125, 646611, 1041902, 718182, 718161, 646464, 646587, 1080812, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 659181, 494949, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 843948, 497457, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 728190, 1026512, 1168301, 715878, 944105, 753486, 678303, 753669, 753720, 678243, 714783, 713412, 678306, 973145, 678435, 966140, 714408, 677970, 678441, 753891, 1040006, 753771, 1020656, 1047491, 678453, 753309, 973064, 713430, 678153, 677958, 678048, 714468, 1173392, 953285, 905804, 1129838, 948338, 1131302, 858030, 1227338, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 586647, 1109147, 1037522, 1043774, 956366, 534753, 869019, 1039988, 534906, 533859, 535050, 1075967, 642138, 534861, 533616, 995063, 534630, 717873, 1071038, 868593, 869058, 1039646, 817464, 868752, 534963, 615513, 535170, 534717, 1043777, 632178, 632778, 593211, 868800, 535086, 868995, 632601, 868638, 533817, 688986, 659055, 534735, 868599, 869064, 868755, 534597, 868866, 1186862, 1044800, 1039769, 534720, 959867, 535323, 697056, 697185, 1039994, 1044014, 579990, 586614, 534702, 579510, 642144, 534885, 628605, 1075955, 534651, 1021019, 868518, 944210, 817479, 868758, 535212, 1039775, 868578, 534780, 869034, 697188, 1044017, 959669, 1043768, 959957, 869007, 535401, 868647, 593199, 533844, 868779, 1110773, 1075958, 717708, 638910, 685797, 1039532, 995054, 534603, 586800, 959885, 868968, 868581, 817443, 1069202, 868824, 956225, 720345, 868392, 534711, 1043771, 868530, 959960, 534903, 868788, 1075964, 1021025, 535284, 1039535, 868623, 944219, 535002, 1122902, 717858, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 684156, 1113440, 1113635, 716475, 641457, 1113224, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 726999, 1114295, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 727008, 1114319, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 983927, 1083068, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362, 1195697, 1195628, 897524, 1084049, 1084079, 1082945, 1082930, 876131, 1223319, 837270, 876365, 837486, 876266, 837321, 854538, 1222905, 876134, 837282, 1222857, 1190123, 876368, 1223034, 837426, 854544, 1072871, 1190039, 876143, 876518, 837285, 871776, 1222866, 1190126, 876380, 837519, 1223391, 837459, 854463, 854550, 1190042, 837288, 871779, 876392, 933893, 1223043, 837474, 854466, 854178, 876248, 1223349, 837303, 1072862, 876122, 837558, 876362, 1110779, 837483, 854469, 854181, 876251, 876599, 837318, 846627, 862863, 865149, 861984, 870366, 1129847, 1334618, 905735, 1131074, 870585, 948404, 1173380, 1334630, 1338191, 1209086, 1173356, 948422, 740451, 858738, 776244, 740580, 858033, 1122713, 1110389, 858039, 1110497, 1293545, 1200101, 992447, 1026983, 1026995, 879083, 897275, 1201817, 1388807, 1367495, 1061750, 858717, 1061813, 992234, 880637, 1361495, 1362134, 1070267, 1070417, 1070588, 1193027, 1193351, 1070276, 1069211, 1033204, 1361513, 1196531, 1362143, 1270346, 1193261, 1070540, 1074665, 1193264, 1193618, 1113815, 1053200, 1033225, 1186883, 1033243, 868851, 1212977, 959894, 959864, 868563, 959975, 1190240, 1123154, 1190222, 1070225, 1217816, 1074662, 1190225, 959900, 1039781, 1070168, 1121357, 1217822, 1190231, 1460147, 1460150, 1211573, 1201811, 1460156, 1460174, 1130804, 753336, 753912, 1368860, 1207193, 1207202, 862329, 1186523, 897083, 846417, 864252, 847014, 862446, 1042016, 1215554, 897014, 897134, 1216611, 1363646, 896993, 953342, 865203, 846012, 897230, 846894, 955889, 897062, 864654, 845991, 864066, 864729, 1383950, 1042019, 865449, 864393, 846453, 865353, 1363652, 864597, 862404, 897101, 1042082, 864258, 1131236, 846879, 896837, 1131185, 864216, 1363655, 953228, 897002, 862407, 847044, 897242, 887906, 864579, 864660, 862455, 846744, 864444, 897203, 864558, 1131077, 897026, 1398620, 846723, 897167, 864720, 862911, 846363, 846438, 948413, 864525, 896981, 847029, 862461, 862929, 956516, 864495, 846870, 1042172, 1396301, 776460, 1040168, 897833, 878696, 1353710, 1178222, 897548, 992345, 1338068, 880709, 1178225, 1026815, 934790, 880163, 992252, 1038392, 1178228, 1337825, 878765, 880190, 1178174, 1353830, 880367, 934748, 992459, 880172, 1027010, 861315, 850380, 861801, 849870, 1106876, 849972, 850356, 861426, 849606, 849765, 1105082, 861318, 850134, 1105061, 994190, 862800, 820101, 850203, 849609, 1106939, 850137, 862803, 820104, 850206, 849876, 863136, 1106882, 818610, 1074149, 861729, 1105016, 1106885, 850374, 994202, 861714, 819927, 1074209, 850377, 849627, 1106873, 849963, 1104986, 963086, 825006, 1359362, 1106927, 824250, 1122995, 823836, 963179, 1224612, 936914, 825123, 981246, 823557, 955448, 963131, 891620, 1224588, 825069, 823536, 823662, 1226576, 820374, 959138, 825021, 825186, 1106930, 820140, 823755, 982325, 824757, 985727, 891710, 823956, 1224618, 825138, 1106912, 855186, 981249, 1226489, 855696, 824475, 956630, 855570, 1224663, 824277, 820167, 854925, 824646, 982346, 1359164, 891713, 823962, 1106915, 823728, 824544, 824709, 1224594, 1226405, 855699, 1168637, 824529, 820392, 963122, 891566, 825027, 855573, 824298, 854928, 823764, 957788, 963065, 891506, 823866, 1106918, 855651, 823620, 891941, 823740, 892073, 824721, 1224600, 825096, 823698, 819492, 963125, 825045, 956645, 1041482, 824361, 962960, 820338, 963080, 959132, 892097, 963191, 1106921, 855654, 1168298, 892076, 824751, 1168565, 1110179, 823701, 1168643, 982307, 891617, 824415, 933608, 1226573, 962966, 1122329, 1224870, 1193372, 1122335, 1190264, 1193123, 1224762, 1051865, 1122350, 1083977, 1120436, 1191749, 1351952, 1082693, 1082765, 1351424, 1221915, 1082891, 1186811, 1222740, 1191026, 1187831, 1350023, 1170932, 1361888, 1082255, 1082744, 1191191, 1120688, 1120448, 1224795, 1186499, 1221933, 1120739, 1081382, 1191200, 1083416, 1351841, 1123397, 1080836, 1178087, 1222128, 1191080, 1191548, 1084532, 1221936, 1191731, 1120634, 1170938, 1081391, 1084016, 1191800, 1082219, 1351808, 1221969, 1191770, 1083659, 1301705, 1351433, 1084538, 1122272, 1082900, 1184822, 1351415, 1222566, 1084022, 1221990, 1084004, 1123388, 1222779, 1082174, 1191152, 1083785, 1221777, 1083974, 1122275, 1082762, 1191632, 1084034, 1082531, 1084196, 1187828, 1081358, 1186553, 1191572, 1084007, 1080974, 1083791, 1080830, 1301717, 1221783, 1122278, 1084139, 1084514, 1224711, 1084037, 1082159, 1081373, 1186559, 1351838, 1191785, 1222185, 1191161, 1080833, 1082918, 1123367, 1084145, 1191755, 1191545, 1351427, 1084526, 1186817, 1191728, 1222743, 1187834, 1082162, 1350026, 1082852, 1084181, 1120691, 1222788, 1221846, 1120652, 1083965, 1122266, 1082897, 1104995, 1082756, 1351394, 1222560, 1080992, 1351853, 1221987, 1191182, 1120469, 1083968, 1221939, 1082759, 1191626, 1191809, 1120472, 1361414, 1221972, 1104980, 1082705, 1301708, 1351436, 1186487, 1191209, 1221912, 1191023, 1083410, 1351832, 1123391, 846789, 862941, 955925, 1395581, 947687, 1396373, 1396307, 1395584, 880526, 903800, 1355918, 1540058, 904184, 955505, 1356212, 1380563, 1396232, 903509, 1396292, 1395578, 1380776, 1396262, 1299029, 1395563, 1110647, 972344, 1359257, 1379081, 1359443, 1359284, 1359422, 1353713, 1379123, 1457717, 992267, 1353734, 847035, 864360, 865200, 846003, 956519, 1398650, 864231, 865446, 953357, 864711, 864453, 846954, 953360, 864714, 846918, 1400945, 847041, 887891, 955898, 846741, 864732, 1129829, 846720, 862908, 864537, 1395374, 864459, 1173401, 846906, 1394249, 862926, 902756, 846867, 1178402, 864120, 864582, 1383257, 870591, 776505, 858396, 1220126, 858042, 880343, 878921, 1176523, 1176460, 1384856, 1176526, 1384859, 1359254, 1391753, 1359305, 1269149, 1382468, 1382465, 1293305, 1121879, 1293296, 1122776, 1293410, 1293395, 1293380, 1297013, 1122890, 1297010, 1131047, 1297088, 970133, 753489, 753615, 1074110, 1190963, 753906, 753618, 754668, 753480, 753252, 753774, 753483, 753666, 754680, 1222524, 1221960, 1376048, 1359293, 1184564, 1222515, 1221945, 1222758, 1189946, 1221948, 1222764, 1376045, 1189841, 1221903, 1359296, 1184567, 1222521, 1373315, 1373318, 1355765, 1215545, 896915, 896561, 1335887, 1402868, 897668, 955952, 1396982, 1110698, 740301, 740376, 897287, 879194, 1353845, 1195868, 1353401, 1176400, 1353680, 1353683, 1191575, 753294, 1269815, 860907, 1107680, 860769, 1070405, 867243, 1340594, 860892, 1272803, 860724, 860772, 1122584, 860805, 1122737, 860895, 1070693, 865101, 860922, 860808, 860898, 1123067, 1070537, 1382144, 1107653, 860949, 1070309, 860925, 1070240, 860778, 1269737, 860763, 1108697, 1382147, 1107656, 860967, 822972, 1359110, 1070243, 823002, 1396202, 1193735, 1270793, 1070402, 867237, 1396118, 1070582, 1107659, 1193681, 822975, 1070684, 1032295, 1359704, 1359092, 1193288, 1199243, 1384799, 1221867, 1384649, 1295624, 1384727, 1383848, 1359314, 1222644, 1295651, 1384733, 1082345, 1384712, 1384763, 1359458, 1384688, 1379072, 1384658, 1384739, 1384790, 1359728, 1222152, 1193384, 1384841, 1082438, 1193357, 1081322, 1359767, 1359437, 1384769, 1383860, 1359089, 1114598, 1113878, 1379078, 1222737, 1081232, 1384748, 1359635, 1359749, 1221855, 1081331, 1114565, 1359116, 1359755, 1408487, 1384760, 1384835, 1384679, 1379069, 1384655, 1359719, 1359521, 1384838, 1383854, 1359425, 1221849, 1082360, 1384766, 1222266, 1359698, 1359086, 1408526, 1379075, 1222731, 1081220, 1384745, 1384793, 1359743, 1193390, 1193360, 1359440, 1384670, 1114433, 1082456, 1376840, 1222251, 1395290, 1222242, 1376843, 1082453, 846804, 1405142, 903212, 870414, 880184, 880415, 1209113, 1405136, 1076045, 870363, 1405139, 1404482, 776154, 1410162, 1410165, 776328, 1428602, 896756, 754629, 753723, 753903, 753894, 1180292, 868590, 817458, 868749, 1191275, 1121363, 1339391, 868548, 959966, 1191212, 1189739, 868791, 1190234, 1189829, 868989, 868635, 1190219, 1122353, 1224819, 1192931, 1679132, 868857, 1070222, 1039763, 869022, 1044011, 1121330, 868773, 1356863, 959897, 1679135, 1074626, 1191179, 817473, 1122332, 868956, 868566, 959993, 869025, 868806, 868998, 868641, 868776, 1039529, 868602, 1113812, 1053197, 868965, 868821, 1374899, 1217819, 868527, 1193018, 1190228, 1356923, 1021022, 868620, 817515, 868761, 1356845, 1224669, 1122338, 1021007, 1044809, 1180247, 869040, 1191257, 1044020, 959849, 1071032, 1192922, 869010, 1193093, 1373369, 1189826, 959888, 846630, 861999, 846912, 864585, 887456, 1040243, 864450, 887876, 1428518, 870594, 846951, 846711, 847038, 846738, 864237, 1437224, 862905, 1447571, 1359383, 864456, 846900, 862923, 953363, 864717, 846864, 955934, 864108, 864735, 864540, 1447775, 865434, 1359395, 847047, 864357, 864666, 865194, 846000, 1437218, 953354, 864708, 1211183, 1428650, 1455929, 1552241, 1527020, 1552205, 1476764, 858177, 1428638, 1465412, 1448459, 1449209, 881279, 850335, 861717, 819933, 850131, 1293416, 994187, 849630, 1293401, 1074137, 1293383, 849924, 861720, 1353371, 861291, 1353455, 1293404, 849975, 850368, 861429, 1074146, 1353374, 849675, 1105064, 849897, 850371, 1293389, 820203, 1105067, 1293299, 820107, 849879, 849615, 820410, 850350, 849684, 994454, 850332, 1293302, 850128, 1293413, 850353, 1393439, 892100, 891737, 1646183, 823626, 823953, 855630, 1032490, 963035, 824697, 1131050, 1227386, 855687, 1654721, 854940, 962969, 1646060, 823773, 963089, 1702028, 963197, 1646186, 1119533, 1399856, 892085, 855633, 1368863, 1133855, 1032463, 823539, 854943, 962972, 1646063, 963107, 1131032, 1119536, 962954, 963041, 1400012, 824772, 963185, 825147, 981267, 892166, 825093, 1032466, 823542, 1041497, 1227356, 1041476, 1227107, 963188, 825153, 1368869, 854907, 963140, 892169, 823938, 1213775, 824532, 982304, 1646069, 959156, 1119695, 1353362, 823623, 824247, 1368872, 854910, 891947, 1646078, 823950, 936908, 1032484, 1213778, 824535, 819501, 963128, 959162, 825066, 855579, 1227377, 855681, 1654718, 1646057, 823770, 1383974, 1211825, 1211828, 1211798, 1383971, 1211801, 1211822, 956522, 955937, 1445033, 1464125, 1352051, 858636, 776064, 1435697, 1355492, 1409306, 1470323, 1220096, 1263824, 1220099, 1263827

     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)

AND (LEAST(everything_except_commit.extended_cost_norm_not_null, everything_except_commit.original_dispute_amount_not_null) <= (1.3 * commit_data.cal_planned_amount))


) AS temp





#MODELLING PART BEGINS


# QUERY TO GET TOTAL NUMBER OF DEDUCTION BETWEEN 01 JAN 2017 - 01 JUN 2017
# OUTPUT = 2541


SELECT COUNT(DISTINCT pk_deduction_id) FROM 
ded_deduction AS dd
LEFT JOIN ded_deduction_item AS ddi ON dd.pk_deduction_id = ddi.fk_deduction_id
LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id


WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-06-30'

AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND ddr.fk_resolution_type_id = 4
AND ddr.fk_resolution_status_id = 1
AND dd.fk_deduction_type_id = 0
AND dd.auto_matched_commit_status IN ('Partial Match','Total Match')





# To get the count of records for deduction in ddi


SELECT COUNT(*) FROM 
ded_deduction AS dd
LEFT JOIN ded_deduction_item AS ddi 
ON dd.pk_deduction_id = ddi.fk_deduction_id

WHERE dd.pk_deduction_id IN
(
	28620391, 28627506, 28627507, 28627508, 28627509, 28627510, 28627511, 28627512, 28627513, 28627514, 28627516, 28627517, 28627518, 28627519, 28627521, 28627536, 28627537, 28627538, 28627540, 28627541, 28627542, 28627543, 28627545, 28627548, 28627549, 28627550, 28627551, 28627555, 28627558, 28627561, 28627562, 28627563, 28627570, 28627571, 28627572, 28627573, 28627574, 28627575, 28627576, 28627581, 28627586, 28627590, 28627593, 28627594, 28627595, 28627596, 28627597, 28627598, 28627599, 28627604, 28627606, 28627608, 28627609, 28627611, 28627614, 28627619, 28627620, 28627622, 28627624, 28627625, 28627626, 28627627, 28627632, 28627633, 28627634, 28627635, 28627636, 28627637, 28627638, 28627639, 28627641, 28627642, 28627644, 28627645, 28627650, 28627651, 28627653, 28627654, 28627655, 28627656, 28627657, 28627658, 28627660, 28627663, 28627664, 28627665, 28627666, 28627667, 28627668, 28627669, 28627670, 28627681, 28627689, 28627690, 28627691, 28627692, 28627699, 28627702, 28627708, 28627710, 28627711, 28627712, 28627714, 28627715, 28627716, 28627717, 28627718, 28627719, 28627720, 28627721, 28627737, 28627738, 28627739, 28627740, 28627741, 28627743, 28635126, 28635176, 28635183, 28635184, 28635203, 28635204, 28635205, 28635206, 28635209, 28635220, 28635225, 28635233, 28649321, 28655674, 28655675, 28655676, 28655678, 28655681, 28655683, 28655685, 28655687, 28655689, 28655694, 28655695, 28655696, 28655697, 28655698, 28655700, 28655704, 28655705, 28655706, 28655709, 28655710, 28655720, 28655721, 28655723, 28655724, 28655725, 28655726, 28655729, 28655730, 28655732, 28655734, 28655735, 28655736, 28655737, 28655740, 28655741, 28655742, 28655743, 28655744, 28655745, 28655746, 28655747, 28655749, 28655750, 28655751, 28655752, 28655753, 28655755, 28655756, 28655757, 28655758, 28655759, 28655760, 28655761, 28655772, 28655773, 28655775, 28655776, 28655777, 28655778, 28655783, 28655784, 28655785, 28655786, 28655787, 28655790, 28655791, 28655792, 28655793, 28655794, 28655799, 28655800, 28655801, 28655802, 28655804, 28655805, 28655806, 28655807, 28655808, 28655809, 28655810, 28655811, 28655812, 28655813, 28655817, 28655818, 28655819, 28655820, 28655821, 28655822, 28655823, 28655825, 28655826, 28655827, 28655832, 28655833, 28655834, 28655835, 28655836, 28655837, 28655838, 28655839, 28655840, 28655841, 28655842, 28655848, 28655850, 28655851, 28655852, 28661918, 28661920, 28661990, 28667486, 28667696, 28667724, 28674585, 28681413, 28688609, 28688610, 28688611, 28695577, 28695893, 28704955, 28704956, 28704957, 28704958, 28704959, 28704963, 28704965, 28704966, 28704967, 28704968, 28704969, 28704970, 28704971, 28704975, 28704976, 28704977, 28704978, 28704979, 28704980, 28704981, 28704982, 28704983, 28704984, 28704985, 28704986, 28704988, 28704989, 28704990, 28704994, 28704995, 28704996, 28704997, 28704999, 28705004, 28705005, 28705010, 28705016, 28705017, 28705021, 28705022, 28705026, 28705027, 28705028, 28705030, 28705038, 28705039, 28705040, 28705041, 28705042, 28705043, 28705044, 28705045, 28705049, 28705050, 28705051, 28705052, 28705058, 28705059, 28705060, 28705061, 28705062, 28705064, 28705066, 28705067, 28705068, 28705070, 28705071, 28705072, 28705080, 28705081, 28705082, 28705083, 28705084, 28705092, 28705093, 28705095, 28705096, 28705101, 28705102, 28705103, 28705109, 28705110, 28705111, 28705114, 28705115, 28705116, 28705117, 28705118, 28705119, 28705121, 28705124, 28705125, 28705126, 28705128, 28705130, 28705131, 28705133, 28705135, 28705136, 28705139, 28705140, 28705142, 28705143, 28705144, 28705146, 28705147, 28705148, 28705149, 28705150, 28705151, 28705152, 28705154, 28705155, 28705156, 28705157, 28705159, 28705160, 28705164, 28705165, 28705166, 28705167, 28705168, 28705169, 28705171, 28705172, 28705176, 28721761, 28721803, 28721804, 28726939, 28726940, 28726942, 28726943, 28726946, 28726949, 28726951, 28726952, 28726953, 28726954, 28726955, 28726957, 28726958, 28726959, 28726961, 28726963, 28726964, 28726965, 28726966, 28726970, 28726971, 28726972, 28726973, 28726979, 28726980, 28726981, 28726982, 28726983, 28726984, 28726985, 28726986, 28726988, 28726989, 28726993, 28726994, 28726995, 28726996, 28726997, 28727004, 28727005, 28727006, 28727007, 28727008, 28727010, 28727011, 28727012, 28727013, 28727014, 28727015, 28727016, 28727017, 28727018, 28727019, 28727020, 28727021, 28727022, 28727023, 28727024, 28727025, 28727026, 28727027, 28727029, 28727030, 28727031, 28727032, 28727033, 28727034, 28727035, 28727036, 28727037, 28727038, 28727039, 28727040, 28727041, 28727042, 28727043, 28727044, 28727045, 28727046, 28727047, 28727049, 28727050, 28727051, 28727052, 28727053, 28727054, 28727055, 28727057, 28727058, 28727061, 28727062, 28727072, 28727075, 28727076, 28727079, 28727080, 28727082, 28727083, 28727084, 28727086, 28727087, 28727088, 28727089, 28727090, 28727091, 28727092, 28727094, 28727095, 28727096, 28727097, 28727098, 28727100, 28727101, 28727104, 28727105, 28727106, 28727107, 28727108, 28727109, 28727110, 28727111, 28727112, 28738238, 28738249, 28738258, 28738268, 28738272, 28738288, 28738289, 28738298, 28738307, 28738317, 28738325, 28738333, 28738357, 28738387, 28738394, 28738397, 28738402, 28738465, 28738467, 28738471, 28753506, 28753528, 28753529, 28753534, 28753535, 28753536, 28753569, 28753599, 28763596, 28763597, 28763598, 28763599, 28763607, 28763608, 28763610, 28763611, 28763612, 28763613, 28763614, 28763615, 28763617, 28763618, 28763619, 28763623, 28763624, 28763625, 28763626, 28763628, 28763629, 28763631, 28763632, 28763633, 28763634, 28763636, 28763637, 28763638, 28763641, 28763642, 28763643, 28763644, 28763645, 28763646, 28763647, 28763650, 28763652, 28763653, 28763654, 28763657, 28763658, 28763659, 28763660, 28763661, 28763668, 28763675, 28763678, 28763679, 28763680, 28763681, 28763684, 28763687, 28763688, 28763689, 28763690, 28763691, 28763692, 28763693, 28763694, 28763695, 28763696, 28763698, 28763700, 28763701, 28763703, 28763705, 28763706, 28763707, 28763708, 28763709, 28763710, 28763711, 28763712, 28763713, 28763714, 28763715, 28763716, 28763717, 28763718, 28763719, 28763720, 28763721, 28763722, 28763723, 28763724, 28763725, 28763726, 28763727, 28763728, 28763729, 28763730, 28763731, 28763735, 28763736, 28763737, 28763738, 28763739, 28763740, 28763741, 28763745, 28763746, 28763747, 28763749, 28763750, 28763753, 28763754, 28763755, 28763756, 28763757, 28763760, 28763762, 28763764, 28763766, 28763767, 28763769, 28763770, 28763773, 28763774, 28763777, 28763778, 28763781, 28763782, 28763783, 28763784, 28763786, 28763787, 28763788, 28763789, 28763790, 28763791, 28763793, 28763794, 28763795, 28763797, 28768873, 28778174, 28778175, 28778186, 28778187, 28778213, 28792501, 28797432, 28797433, 28797434, 28797435, 28797436, 28797437, 28797438, 28797439, 28797441, 28797442, 28797444, 28797445, 28797446, 28797447, 28797449, 28797450, 28797451, 28797453, 28797455, 28797464, 28797465, 28797466, 28797470, 28797471, 28797472, 28797474, 28797475, 28797477, 28797478, 28797479, 28797481, 28797482, 28797483, 28797484, 28797496, 28797501, 28797502, 28797503, 28797504, 28797506, 28797507, 28797508, 28797509, 28797514, 28797515, 28797516, 28797517, 28797518, 28797524, 28797525, 28797527, 28797528, 28797529, 28797538, 28797540, 28797541, 28797542, 28797543, 28797544, 28797546, 28797547, 28797549, 28797550, 28797551, 28797552, 28797553, 28797554, 28797560, 28797563, 28797564, 28797567, 28797568, 28797569, 28797570, 28797572, 28797573, 28797574, 28797575, 28797576, 28797577, 28797578, 28797579, 28797580, 28797583, 28797584, 28797585, 28797586, 28797587, 28797591, 28797592, 28797593, 28797594, 28797597, 28797598, 28797599, 28797600, 28797601, 28797603, 28797605, 28797606, 28797613, 28797614, 28797615, 28797616, 28797619, 28797620, 28797621, 28797626, 28797627, 28797628, 28797629, 28797630, 28797631, 28797632, 28802718, 28802755, 28802775, 28802785, 28802788, 28802796, 28802804, 28802805, 28802809, 28802819, 28802826, 28802836, 28802844, 28802847, 28802851, 28802876, 28802877, 28802878, 28802884, 28802890, 28802908, 28802912, 28802919, 28802922, 28802935, 28802966, 28807273, 28807283, 28807295, 28807304, 28807310, 28807311, 28807330, 28807353, 28807362, 28807368, 28807407, 28807412, 28807427, 28807435, 28807449, 28807468, 28807485, 28807491, 28807502, 28807505, 28807508, 28807532, 28821558, 28821570, 28821579, 28821625, 28821640, 28821649, 28825965, 28825966, 28825967, 28825968, 28825969, 28825970, 28825971, 28825972, 28825973, 28825974, 28825977, 28825979, 28825980, 28825981, 28825982, 28825984, 28825985, 28825986, 28825987, 28825988, 28825989, 28825990, 28825991, 28825992, 28825993, 28825994, 28825995, 28825996, 28825997, 28825998, 28826003, 28826007, 28826008, 28826009, 28826010, 28826011, 28826012, 28826015, 28826016, 28826018, 28826019, 28826020, 28826021, 28826022, 28826024, 28826026, 28826039, 28826040, 28826042, 28826043, 28826045, 28826046, 28826049, 28826050, 28826051, 28826052, 28826053, 28826054, 28826055, 28826057, 28826058, 28826061, 28826062, 28826063, 28826064, 28826065, 28826066, 28826067, 28826068, 28826069, 28826070, 28826071, 28826072, 28826073, 28826074, 28826075, 28826082, 28826083, 28826084, 28826085, 28826086, 28826087, 28826088, 28826091, 28826092, 28826093, 28826094, 28826095, 28826096, 28826097, 28826116, 28826117, 28826120, 28826121, 28826123, 28826125, 28826126, 28826127, 28826128, 28826137, 28826138, 28826139, 28826143, 28826148, 28834904, 28834905, 28839788, 28839836, 28839844, 28839856, 28839864, 28839870, 28839881, 28839887, 28839897, 28839903, 28839906, 28839915, 28839926, 28839943, 28839976, 28839989, 28839994, 28866742, 28866745, 28871610, 28877868, 28877885, 28877886, 28877888, 28877890, 28877894, 28877907, 28877911, 28877913, 28877917, 28877919, 28877920, 28877924, 28877928, 28877929, 28877933, 28877938, 28877940, 28877941, 28877942, 28877945, 28877948, 28877949, 28877953, 28877954, 28877955, 28877959, 28877960, 28877962, 28877976, 28877979, 28877986, 28877987, 28877992, 28877993, 28877994, 28877995, 28877996, 28877997, 28877998, 28877999, 28878000, 28878001, 28878016, 28878017, 28878021, 28878022, 28878023, 28878028, 28878035, 28878036, 28878051, 28878052, 28878053, 28878054, 28878055, 28878072, 28878073, 28878074, 28878075, 28878077, 28878079, 28878080, 28878081, 28878083, 28878084, 28878085, 28878086, 28878087, 28878088, 28878089, 28878102, 28878103, 28878112, 28878118, 28878119, 28878120, 28878121, 28878122, 28878132, 28878135, 28878136, 28878143, 28878179, 28878186, 28878187, 28878191, 28878197, 28878200, 28878201, 28878202, 28878203, 28878204, 28878207, 28878214, 28878218, 28878221, 28878225, 28878226, 28878227, 28878228, 28878230, 28878256, 28878257, 28878263, 28878264, 28878267, 28878268, 28878269, 28878278, 28878286, 28878287, 28878288, 28878291, 28892347, 28892351, 28892355, 28892357, 28892359, 28892360, 28892427, 28892446, 28897925, 28897927, 28897928, 28897935, 28897938, 28897939, 28897940, 28897941, 28897942, 28897943, 28897944, 28897945, 28897946, 28897952, 28897953, 28897955, 28897956, 28897957, 28897958, 28897959, 28897960, 28897961, 28897962, 28897964, 28897965, 28897973, 28897983, 28897985, 28897988, 28897991, 28897992, 28897993, 28898004, 28898005, 28898011, 28898012, 28898016, 28898020, 28898022, 28898030, 28898031, 28898034, 28898035, 28898036, 28898038, 28898039, 28898040, 28898041, 28898042, 28898043, 28898044, 28898045, 28898052, 28898053, 28898054, 28898055, 28898059, 28898060, 28898061, 28898064, 28898065, 28898066, 28898067, 28898068, 28898069, 28898070, 28898089, 28898090, 28898091, 28898092, 28898093, 28898094, 28898095, 28898097, 28898098, 28898099, 28898100, 28898101, 28898102, 28898105, 28898106, 28898109, 28898112, 28898116, 28898117, 28898119, 28898120, 28898122, 28903214, 28903268, 28903269, 28903270, 28903272, 28903273, 28934700, 28934790, 28934791, 28934792, 28934793, 28934799, 28934800, 28934801, 28934802, 28934803, 28934805, 28934806, 28934823, 28934827, 28934829, 28934836, 28934841, 28934846, 28934857, 28934863, 28934864, 28934865, 28934866, 28934869, 28934870, 28934886, 28934888, 28934893, 28934899, 28934902, 28934903, 28934912, 28934913, 28934914, 28934916, 28934918, 28934919, 28934927, 28934932, 28934939, 28934940, 28934941, 28934942, 28934944, 28934947, 28934962, 28934970, 28934976, 28934977, 28934982, 28934985, 28934988, 28934992, 28934993, 28934994, 28934995, 28934997, 28935000, 28935001, 28935003, 28935006, 28935007, 28935008, 28935010, 28935015, 28935017, 28935018, 28935019, 28935020, 28935021, 28935022, 28935025, 28935028, 28935030, 28935033, 28935035, 28935036, 28935037, 28935038, 28935042, 28935043, 28935044, 28935045, 28935047, 28935048, 28935057, 28935058, 28935059, 28935060, 28935063, 28935069, 28935072, 28935073, 28935074, 28935075, 28935076, 28935077, 28935078, 28935084, 28935085, 28945202, 28945293, 28945294, 28950106, 28950122, 28950201, 28950202, 28960669, 28966695, 28966696, 28966773, 28966775, 28966778, 28966785, 28966786, 28966788, 28966791, 28966792, 28966798, 28966799, 28966800, 28966801, 28966802, 28966803, 28966804, 28966805, 28966806, 28966808, 28966809, 28966810, 28966811, 28966813, 28966814, 28966815, 28966817, 28966818, 28966819, 28966821, 28966826, 28966831, 28966832, 28966845, 28966847, 28966851, 28966852, 28966858, 28966859, 28966860, 28966861, 28966862, 28966863, 28966864, 28966871, 28966874, 28966875, 28966876, 28966881, 28966882, 28966883, 28966884, 28966885, 28966886, 28966887, 28966888, 28966889, 28966890, 28966891, 28966893, 28966894, 28966895, 28966896, 28966897, 28966898, 28966902, 28966903, 28966904, 28966905, 28966908, 28966914, 28966915, 28966916, 28966917, 28966918, 28966919, 28966920, 28966921, 28966923, 28966924, 28966925, 28966926, 28966927, 28966929, 28966930, 28966932, 29000051, 29000061, 29007109, 29007110, 29007111, 29007112, 29007113, 29007116, 29007117, 29007118, 29007119, 29007120, 29007121, 29007125, 29007126, 29007130, 29007153, 29007154, 29007160, 29007166, 29007169, 29007174, 29007178, 29007179, 29007180, 29007181, 29007182, 29007185, 29007187, 29007192, 29007193, 29007194, 29007195, 29007196, 29007197, 29007198, 29007200, 29007202, 29007203, 29007204, 29007205, 29007206, 29007207, 29007208, 29007209, 29007210, 29007211, 29007213, 29007215, 29007216, 29007217, 29007218, 29007219, 29007220, 29007221, 29007222, 29007223, 29007224, 29007225, 29007227, 29007228, 29007231, 29007236, 29007237, 29007238, 29007239, 29007240, 29007246, 29007247, 29007248, 29007252, 29007254, 29007255, 29007256, 29007260, 29007263, 29007264, 29007265, 29007266, 29007267, 29007269, 29007270, 29007275, 29007277, 29007278, 29007280, 29007282, 29007283, 29007289, 29007290, 29007291, 29007298, 29007303, 29007304, 29007305, 29007306, 29007307, 29007309, 29007311, 29007312, 29007313, 29007314, 29007315, 29007316, 29007318, 29007319, 29007320, 29013538, 29019886, 29020074, 29051471, 29051472, 29051473, 29051479, 29051480, 29051481, 29051482, 29051484, 29051485, 29051487, 29051489, 29051491, 29051493, 29051494, 29051495, 29051496, 29051497, 29051498, 29051499, 29051500, 29051501, 29051503, 29051504, 29051505, 29051507, 29051508, 29051509, 29051511, 29051516, 29051517, 29051520, 29051522, 29051523, 29051524, 29051525, 29051527, 29051528, 29051529, 29051530, 29051531, 29051532, 29051533, 29051534, 29051535, 29051536, 29051538, 29051539, 29051540, 29051541, 29051542, 29051543, 29051544, 29051545, 29051549, 29051550, 29051551, 29051552, 29051554, 29051555, 29051556, 29051557, 29051559, 29051560, 29051563, 29051564, 29051565, 29051571, 29051572, 29051576, 29051577, 29051578, 29051581, 29051582, 29051585, 29051588, 29051589, 29051590, 29051591, 29051592, 29051593, 29051594, 29051595, 29051597, 29051599, 29051600, 29051601, 29051602, 29051603, 29051604, 29051606, 29051607, 29051608, 29051614, 29051615, 29051616, 29051617, 29051618, 29051619, 29051626, 29051627, 29051628, 29051629, 29051630, 29051631, 29051633, 29051634, 29051637, 29051643, 29051644, 29051645, 29051646, 29051647, 29051648, 29057373, 29076108, 29082314, 29082341, 29082342, 29082344, 29082347, 29082348, 29082360, 29082376, 29082378, 29082379, 29082390, 29082391, 29082394, 29082407, 29082414, 29082418, 29082419, 29082420, 29082426, 29082427, 29082428, 29082429, 29082456, 29082463, 29082472, 29082474, 29082495, 29082502, 29082543, 29082544, 29082546, 29082547, 29082548, 29082552, 29082555, 29082560, 29082563, 29082583, 29082601, 29082604, 29082605, 29082608, 29082610, 29082611, 29082612, 29082613, 29082623, 29082625, 29082626, 29082627, 29082628, 29082629, 29082630, 29082631, 29082639, 29082659, 29082660, 29082669, 29082672, 29082673, 29082674, 29082675, 29082683, 29082686, 29082687, 29082688, 29082689, 29082696, 29082697, 29082698, 29082699, 29082700, 29082706, 29082707, 29082708, 29082709, 29082710, 29082711, 29082717, 29082718, 29082719, 29082720, 29082722, 29082723, 29082725, 29082726, 29082727, 29082728, 29082729, 29082730, 29082732, 29082733, 29082734, 29082735, 29082745, 29082747, 29082748, 29082761, 29082762, 29082778, 29082789, 29082791, 29088409, 29088431, 29088435, 29088438, 29088582, 29088595, 29088601, 29116082, 29116134, 29116142, 29116148, 29122007, 29122008, 29122010, 29122019, 29122024, 29122025, 29122027, 29122029, 29122034, 29122041, 29122042, 29122044, 29122055, 29122056, 29122057, 29122058, 29122065, 29122068, 29122069, 29122070, 29122072, 29122074, 29122075, 29122076, 29122077, 29122078, 29122079, 29122080, 29122081, 29122082, 29122083, 29122084, 29122085, 29122088, 29122089, 29122090, 29122091, 29122092, 29122093, 29122094, 29122095, 29122096, 29122097, 29122099, 29122121, 29122122, 29122123, 29122124, 29122125, 29122129, 29122139, 29122141, 29122142, 29122143, 29122145, 29122146, 29122147, 29122149, 29122150, 29122151, 29122152, 29122153, 29122154, 29122155, 29122173, 29122174, 29122175, 29122176, 29122177, 29122179, 29122182, 29122188, 29122193, 29122194, 29122195, 29122196, 29122197, 29122198, 29122199, 29122200, 29128209, 29128489, 29128490, 29135118, 29135160, 29135161, 29140263, 29144463, 29148914, 29148918, 29154740, 29159643, 29159644, 29159645, 29159646, 29159649, 29159650, 29159653, 29159654, 29159655, 29159658, 29159659, 29159665, 29159666, 29159669, 29159670, 29159671, 29159673, 29159674, 29159675, 29159678, 29159679, 29159680, 29159681, 29159691, 29159693, 29159694, 29159696, 29159704, 29159705, 29159706, 29159707, 29159708, 29159709, 29159710, 29159711, 29159712, 29159713, 29159714, 29159718, 29159719, 29159721, 29159728, 29159730, 29159731, 29159732, 29159733, 29159734, 29159737, 29159738, 29159740, 29159743, 29159744, 29159745, 29159746, 29159747, 29159759, 29159761, 29159762, 29159764, 29159765, 29159766, 29159767, 29159769, 29159770, 29159774, 29159775, 29159776, 29159777, 29159778, 29159779, 29159780, 29159781, 29159782, 29159783, 29159784, 29159785, 29159786, 29159788, 29159790, 29159791, 29159793, 29159794, 29159795, 29159796, 29159797, 29159798, 29159800, 29159801, 29159803, 29159805, 29159807, 29159808, 29159809, 29159811, 29159812, 29159813, 29159814, 29159817, 29159820, 29159821, 29159823, 29159825, 29159826, 29159827, 29159828, 29159829, 29159830, 29159831, 29159832, 29166102, 29184429, 29184431, 29199809, 29199811, 29199812, 29199815, 29199817, 29199818, 29199821, 29199822, 29199823, 29199824, 29199825, 29199827, 29199829, 29199830, 29199836, 29199837, 29199838, 29199840, 29199841, 29199843, 29199846, 29199847, 29199848, 29199849, 29199850, 29199851, 29199854, 29199856, 29199858, 29199859, 29199861, 29199862, 29199863, 29199865, 29199869, 29199873, 29199874, 29199877, 29199878, 29199880, 29199881, 29199883, 29199884, 29199893, 29199895, 29199896, 29199897, 29199900, 29199901, 29199902, 29199905, 29199909, 29199910, 29199911, 29199913, 29199916, 29199918, 29199920, 29199921, 29199922, 29199925, 29199926, 29199927, 29199928, 29199929, 29199932, 29199934, 29199935, 29199939, 29199940, 29199941, 29199943, 29199945, 29199946, 29199949, 29199951, 29199954, 29199955, 29199958, 29199959, 29199960, 29199961, 29199962, 29199968, 29199969, 29199970, 29199971, 29199973, 29199976, 29199977, 29199979, 29199980, 29199981, 29199983, 29199985, 29199986, 29199989, 29199990, 29199991, 29199992, 29199993, 29199994, 29199995, 29199999, 29200001, 29200002, 29200003, 29200004, 29200005, 29200006, 29200011, 29200012, 29200017, 29200019, 29213754, 29213814, 29213866, 29213897, 29221012, 29221013, 29221015, 29221016, 29221017, 29221018, 29221019, 29221020, 29221022, 29221030, 29221031, 29221032, 29221033, 29221034, 29221037, 29221039, 29221040, 29221041, 29221046, 29221050, 29221051, 29221059, 29221060, 29221061, 29221062, 29221063, 29221064, 29221065, 29221067, 29221068, 29221069, 29221070, 29221071, 29221072, 29221073, 29221074, 29221075, 29221076, 29221077, 29221078, 29221080, 29221081, 29221082, 29221084, 29221085, 29221093, 29221095, 29221096, 29221097, 29221098, 29221099, 29221105, 29221106, 29221116, 29221119, 29221124, 29221125, 29221126, 29221147, 29221158, 29221161, 29221164, 29221166, 29221171, 29221172, 29221173, 29221174, 29221177, 29221178, 29221183, 29221188, 29221189, 29221190, 29221194, 29221198, 29221201, 29228988, 29238796, 29238816, 29238820, 29259741, 29259744, 29259745, 29259758, 29259760, 29259761, 29259762, 29259763, 29259764, 29259773, 29259774, 29259775, 29259782, 29259783, 29259784, 29259799, 29259801, 29259803, 29259806, 29259815, 29259820, 29259821, 29259822, 29259823, 29259824, 29259825, 29259826, 29259827, 29259828, 29259836, 29259838, 29259839, 29259840, 29259847, 29259848, 29259856, 29259858, 29259859, 29259861, 29259862, 29259863, 29259864, 29259876, 29259877, 29259878, 29259880, 29259906, 29259907, 29259908, 29259909, 29259910, 29259911, 29259912, 29259913, 29259914, 29259915, 29259917, 29259918, 29259920, 29259927, 29259928, 29259934, 29259935, 29259936, 29259937, 29259938, 29259942, 29265885, 29265888, 29265893, 29265896, 29265903, 29265908, 29265927, 29265950, 29265970, 29265973, 29265981, 29265992, 29266001, 29266021, 29266042, 29266052, 29266056, 29266075, 29266080, 29266097, 29286019, 29286174, 29286179, 29286184, 29286205, 29286206, 29286211, 29286219, 29286221, 29299342, 29299343, 29299344, 29299345, 29299347, 29299348, 29299349, 29299351, 29299352, 29299353, 29299355, 29299361, 29299362, 29299383, 29299413, 29299417, 29299418, 29299430, 29299440, 29299441, 29299442, 29299443, 29299444, 29299452, 29299453, 29299454, 29299455, 29299456, 29299457, 29299459, 29299461, 29299462, 29299467, 29299468, 29299469, 29299477, 29299480, 29299516, 29299518, 29299519, 29299520, 29299529, 29299549, 29299554, 29299556, 29299557, 29299561, 29299564, 29299565, 29299567, 29299574, 29299575, 29299576, 29299577, 29299589, 29299597, 29299604, 29299605, 29299607, 29299609, 29299610, 29299612, 29299613, 29299614, 29299631, 29299633, 29299634, 29299635, 29299647, 29299656, 29299657, 29299659, 29299660, 29299661, 29299662, 29299663, 29299666, 29299667, 29299673, 29299676, 29299678, 29299680, 29299682, 29299683, 29299685, 29299690, 29299708, 29299709, 29299711, 29299712, 29299713, 29299714, 29299715, 29320877, 29320880, 29331907, 29331911, 29331912, 29331913, 29331914, 29331917, 29331918, 29331920, 29331921, 29331922, 29331923, 29331924, 29331925, 29331934, 29331935, 29331936, 29331937, 29331938, 29331941, 29331943, 29331946, 29331947, 29331948, 29331951, 29331953, 29331956, 29331957, 29331958, 29331959, 29331966, 29331968, 29331969, 29331970, 29331972, 29331974, 29331975, 29331976, 29331977, 29331978, 29331979, 29331980, 29331983, 29331984, 29331985, 29331986, 29331988, 29331989, 29331991, 29331992, 29331993, 29331996, 29331997, 29332000, 29332002, 29332003, 29332008, 29332009, 29332012, 29332013, 29332014, 29332016, 29332018, 29332019, 29332020, 29332021, 29332022, 29332023, 29332024, 29332025, 29332026, 29332027, 29332033, 29332036, 29332037, 29332041, 29332042, 29332045, 29332046, 29332047, 29332049, 29332050, 29332051, 29332052, 29332053, 29332054, 29332055, 29332058, 29332059, 29332061, 29332063, 29332064, 29332065, 29332072, 29332080, 29332081, 29332084, 29332085, 29332088, 29332089, 29332090, 29332091, 29332093, 29332094, 29332099, 29332100, 29332101, 29332102, 29364757, 29364758, 29364759, 29364760, 29364761, 29364763, 29364764, 29364765, 29364768, 29364769, 29364770, 29364771, 29364772, 29364773, 29364774, 29364775, 29364779, 29364788, 29364791, 29364792, 29364793, 29364794, 29364795, 29364800, 29364802, 29364804, 29364806, 29364807, 29364808, 29364819, 29364820, 29364822, 29364824, 29364825, 29364827, 29364828, 29364829, 29364831, 29364832, 29364833, 29364834, 29364835, 29364836, 29364837, 29364838, 29364839, 29364841, 29364842, 29364843, 29364844, 29364847, 29364849, 29364850, 29364851, 29364852, 29364853, 29364854, 29364855, 29364856, 29364857, 29364858, 29364861, 29364862, 29364863, 29364864, 29364865, 29364866, 29364867, 29364868, 29364869, 29364870, 29364871, 29364872, 29364873, 29364874, 29364876, 29364877, 29364878, 29364879, 29364881, 29364882, 29364883, 29364885, 29364886, 29364895, 29364896, 29364897, 29364898, 29364901, 29364904, 29364914, 29364917, 29364919, 29364920, 29364921, 29364926, 29364932, 29364933, 29364939, 29364940, 29364941, 29364942, 29364949, 29364950, 29364954, 29364956, 29364957, 29364958, 29364959, 29364961, 29364962, 29364963, 29364965, 29364967, 29364968, 29364971, 29364973, 29364975, 29364977, 29364978, 29371094, 29371120, 29371125, 29371134, 29371234, 29371250, 29371345, 29371373, 29371388, 29371401
)








#Jami : number of deduction in ded_deduction in year 2017
#Output = 30775


SELECT COUNT(DISTINCT pk_deduction_id) FROM 

ded_deduction AS dd
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0




#Jami: percentage of ded_ids in ddi from dd
#Output = 17211



SELECT COUNT(DISTINCT ddi.fk_deduction_id) FROM 

ded_deduction AS dd
LEFT JOIN ded_deduction_item AS ddi ON ddi.fk_deduction_id = dd.pk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0



#ded_id in ddri
#output = 22881



SELECT COUNT(DISTINCT ddr.fk_deduction_id) FROM 

ded_deduction_resolution AS ddr 
LEFT JOIN ded_deduction AS dd ON ddr.fk_deduction_id = dd.pk_deduction_id
LEFT JOIN ded_deduction_resolution_item AS ddri ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0
 

# common ded_id in dd and ddri
#output = 22881




SELECT COUNT(DISTINCT ddr.fk_deduction_id) 

FROM ded_deduction AS dd 
LEFT JOIN ded_deduction_resolution AS ddr ON ddr.fk_deduction_id = dd.pk_deduction_id
LEFT JOIN ded_deduction_resolution_item AS ddri ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0








# common ded_id in ddi and ddri
#Output = 9317


SELECT COUNT(DISTINCT ddr.fk_deduction_id) FROM 

ded_deduction_item AS ddi 
INNER JOIN ded_deduction_resolution AS ddr ON ddr.fk_deduction_id = ddi.fk_deduction_id
LEFT JOIN ded_deduction_resolution_item AS ddri ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddi.fk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0




#common ded_id in dd and mdirh
#Output = 14383


SELECT COUNT(DISTINCT mdirh.fk_deduction_id) FROM 

ded_deduction AS dd 
LEFT JOIN map_deduction_item_rollup_header AS mdirh ON dd.pk_deduction_id = mdirh.fk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0




#common ded_id in mdir and dd
#14383



SELECT COUNT(DISTINCT mdirh.fk_deduction_id) FROM 

ded_deduction AS dd 
LEFT JOIN map_deduction_item_rollup_header AS mdirh ON dd.pk_deduction_id = mdirh.fk_deduction_id
LEFT JOIN map_deduction_item_rollup AS mdir ON mdir.fk_map_deduction_item_rollup_header_id = mdirh.pk_map_deduction_item_rollup_header_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0





#common ded_id in mdirh and ddr
#output 6489



SELECT COUNT(DISTINCT mdirh.fk_deduction_id) FROM 

ded_deduction_resolution AS ddr 
INNER JOIN map_deduction_item_rollup_header AS mdirh ON ddr.fk_deduction_id = mdirh.fk_deduction_id
LEFT JOIN map_deduction_item_rollup AS mdir ON mdir.fk_map_deduction_item_rollup_header_id = mdirh.pk_map_deduction_item_rollup_header_id
LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id  = ddr.fk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id

WHERE
dd.deduction_created_date BETWEEN '2017-01-01' AND '2017-12-31'
AND systemstatus.pk_deduction_status_system_id = 4        
AND pk_reason_category_rad_id IN (126)
AND dd.fk_deduction_type_id = 0





#common ded_id in mdirh and dd for 1000 deduction
#Output = 1000


SELECT COUNT(DISTINCT mdirh.fk_deduction_id) FROM 

WHERE mdirh.fk_deduction_id IN
(
11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
)









# where user is system



SELECT DISTINCT mdirh.fk_deduction_id, mdir.deal_reference FROM 
map_deduction_item_rollup_header AS mdirh
LEFT JOIN map_deduction_item_rollup AS mdir
ON mdirh.pk_map_deduction_item_rollup_header_id = mdir.fk_map_deduction_item_rollup_header_id
WHERE mdirh.fk_deduction_id IN
(
11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
)
AND mdir.deal_reference IS NOT NULL
AND mdir.update_user = "System" 
 
 
 
 
 
#From 1000 ded_ids , how many ded_ids have deal_referenece as not null
#102 unique_deduction_ids
#192 rows
 
 
 
SELECT DISTINCT mdirh.fk_deduction_id, mdir.deal_reference
FROM map_deduction_item_rollup_header AS mdirh
LEFT JOIN map_deduction_item_rollup AS mdir
ON mdirh.pk_map_deduction_item_rollup_header_id = mdir.fk_map_deduction_item_rollup_header_id

WHERE mdirh.fk_deduction_id IN
(
11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
)

AND mdir.deal_reference IS NOT NULL
 
 
 
 
#commit_ids for 102 deductions
#465 rows



SELECT DISTINCT dd.pk_deduction_id, tc.commit_id
FROM ded_deduction AS dd
LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
LEFT JOIN ded_deduction_resolution_item AS ddri ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
LEFT JOIN tpm_commit AS tc ON tc.commit_id = ddri.fk_commitment_id

WHERE dd.pk_deduction_id IN 
(
	12678977, 13217450, 16026344, 16449446, 16915616, 17066585, 17066690, 17066798, 17066831, 17067017, 17067020, 17067044, 17067725, 17070167, 17070173, 17070206, 17070212, 17070326, 17070344, 17070419, 17070422, 17070428, 17070437, 17070455, 17206067, 17206538, 17280767, 17280773, 17280776, 17280797, 17280842, 17280845, 17280893, 17280896, 17280899, 17280917, 17280920, 17280932, 17280947, 17281004, 17281007, 17281010, 17281109, 17281118, 17281127, 17281136, 17281202, 17281208, 17281211, 17281241, 17281268, 17281277, 17281307, 17281373, 17281406, 17281586, 17282282, 17282354, 17328956, 17329385, 17329445, 17329451, 17467415, 17507807, 17507813, 17507819, 17507822, 17507825, 17507831, 17507849, 17507858, 17507870, 17507906, 17507918, 17507972, 17507987, 17507990, 17508011, 17508014, 17508038, 17508041, 17508056, 17508059, 17508083, 17508113, 17508125, 17508137, 17508146, 17508149, 17508176, 17508179, 17508194, 17508224, 17508239, 17508263, 17508935, 17509124, 17510120, 17510177, 17510342, 17510402, 17510459
)





#data for 22 deduction - deal reference pair


SELECT * FROM
map_deduction_item_rollup_header AS mdirh
LEFT JOIN map_deduction_item_rollup AS mdir ON mdirh.pk_map_deduction_item_rollup_header_id = mdir.fk_map_deduction_item_rollup_header_id

WHERE mdirh.fk_deduction_id IN
(
	13217450, 16449446, 16449446, 16915616, 17066585, 17070326, 17070437, 17070437, 17070455, 17206067, 17280917, 17280920, 17280920, 17280920, 17280920, 17281136, 17281202, 17282354, 17467415, 17507825, 17508176, 17508194
)

AND mdir.deal_reference IN
(
	9040559, 8284439, 8284346, 8953007, 6488690, 8918594, 6542951, 6542954, 8918594, 8253809, 6542954, 6542951, 6547508, 9053423, 6546161, 8918594, 6547508, 6542951, 8987690, 8918594, 7519481, 6488690
)





#100 deduction_ids which are invalid





SELECT 
DISTINCT 
dd.pk_deduction_id, dd.fk_action_code_id
#ddr.fk_deduction_id, tc.commit_id, dd.fk_action_code_id

FROM 
ded_deduction AS dd
LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
#left join ded_deduction_resolution_item as ddri on ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
#left join tpm_commit as tc on ddri.fk_commitment_id = tc.commit_id

WHERE
dd.fiscal_year = 2016
AND systemstatus.pk_deduction_status_system_id = 4  #closed
AND ddr.fk_resolution_type_id = 4  #promotion_settlement
AND ddr.fk_resolution_status_id = 1  #Posted
      
AND pk_reason_category_rad_id IN (126) #Trade
AND dd.fk_deduction_type_id = 0  #Deduction
AND ( (dd.fk_action_code_id IN (341,419,422,425,240,243,246,428,300)) OR (dd.correspondence_flag IN (1)) )

#LIMIT 100
 
 
 
 
 
 
 
#to get complete invalid deduction i.e. fk_resolution_type_id != 4 and no fiscal year
 


SELECT 
DISTINCT dd.pk_deduction_id 
#ddr.fk_deduction_id, tc.commit_id, dd.fk_action_code_id

FROM 
ded_deduction AS dd
LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
#left join ded_deduction_resolution_item as ddri on ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
#left join tpm_commit as tc on ddri.fk_commitment_id = tc.commit_id

WHERE
#dd.fiscal_year = 2016
systemstatus.pk_deduction_status_system_id = 4  #closed
AND ddr.fk_resolution_type_id != 4  #promotion_settlement
AND ddr.fk_resolution_status_id = 1  #Posted
      
AND pk_reason_category_rad_id IN (126) #Trade
AND dd.fk_deduction_type_id = 0  #Deduction
AND dd.fk_action_code_id IN (341,419,422,425,240,243,246,428,300) 







#extracting all the features fro training






SELECT COUNT(*) FROM
(

SELECT DISTINCT 
#ded_deduction
everything_except_commit.pk_deduction_id,
everything_except_commit.original_dispute_amount,
everything_except_commit.cum_days_out_standing,
everything_except_commit.payer,
everything_except_commit.posting_date,
everything_except_commit.merge_status,

#display_text

everything_except_commit.cust_map_id_ded,
everything_except_commit.ded_display_text,

everything_except_commit.prom_customer_map_id1,
everything_except_commit.prom_display_text, 
everything_except_commit.display_text_count,


#dates
everything_except_commit.deduction_created_date,
everything_except_commit.customer_claim_date, 
everything_except_commit.invoice_date,
everything_except_commit.promortion_execution_from_date,
everything_except_commit.promotion_execution_to_date,
everything_except_commit.ship_start_date, 
everything_except_commit.ship_end_date, 
everything_except_commit.consumption_start_date, 
everything_except_commit.consumption_end_date,

#ddi
everything_except_commit.extended_cost_norm,      
everything_except_commit.unit_cost_norm,
everything_except_commit.deduction_item_quantity, 
everything_except_commit.status_code,
everything_except_commit.status_shortname,


#item_desc
everything_except_commit.ddi_prod_hier1, 
everything_except_commit.ddi_lu_item_desc,

everything_except_commit.lu_item_description,
everything_except_commit.description_from_tpm_commit,
everything_except_commit.item_desc_count,


#commit_data
commit_data.promotion_id1,
commit_data.commit_id1,
commit_data.planned_qty,
commit_data.paid_qty,
commit_data.variable_planned_amount, 
commit_data.fixed_planned_amount,
commit_data.fk_commit_payment_type_id, 
commit_data.payment_type_longname,
commit_data.promotion_type_id,
commit_data.promotion_type_longname


 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            #table1_display_text.ded_display_text,
            #table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            table3_ded_data.original_dispute_amount,
            table3_ded_data.original_dispute_amount_not_null,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max,
            
            table3_ded_data.cum_days_out_standing,
            table3_ded_data.payer,
            table3_ded_data.posting_date,
            table3_ded_data.deduction_created_date,
            table3_ded_data.customer_claim_date, 
            table3_ded_data.invoice_date,
            table3_ded_data.promortion_execution_from_date, 
            table3_ded_data.promotion_execution_to_date,
            table3_ded_data.merge_status,
            
            table1_display_text.prom_customer_map_id1,
            table1_display_text.ded_display_text1,
            table1_display_text.prom_display_text, 
            table1_display_text.display_text_count,
            
            table3_ded_data.cust_map_id_ded,
            table3_ded_data.ded_display_text
            
                                       
            FROM
                 (SELECT dd.pk_deduction_id, dd.original_dispute_amount, dd.company_code, dd.currency, mcar.payterms_desc,
                 
		 dd.cum_days_out_standing, dd.payer, dd.posting_date, dd.merge_status,
                 
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 (CASE WHEN ISNULL(dd.original_dispute_amount) THEN 1000000 ELSE dd.original_dispute_amount END) AS original_dispute_amount_not_null,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                  dd.pk_deduction_id IN 
                 (
			11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
		
                 )
                 GROUP BY dd.pk_deduction_id
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.prom_customer_map_id1, ded_data.ded_display_text1,
                ded_data.prom_display_text, COUNT(*) AS display_text_count
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id1,
                    mcar.display_text AS ded_display_text1, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text1, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text1 = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promotion_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, ddi.extended_cost_norm, 
            
            ddi.unit_cost_norm, ddi.deduction_item_quantity, ddi.status_code, ldimsr.shortname AS status_shortname,
            
	    (CASE WHEN ISNULL(ddi.extended_cost_norm) THEN 1000000 ELSE ddi.extended_cost_norm END) AS extended_cost_norm_not_null,
                 
            
            
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            LEFT JOIN lu_deduction_item_mapping_status_rad AS ldimsr ON ldimsr.pk_deduction_item_mapping_status_id = ddi.status_code
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     dd.pk_deduction_id IN 
		     (
				11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
		
		     )
                     GROUP BY dd.pk_deduction_id
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
	(SELECT 
            C.description_from_tpm_commit AS description_from_tpm_commit,
            C.lu_item_description AS lu_item_description, SUM(C.counter) AS item_desc_count
            
            FROM
            (
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description, COUNT(*) AS counter
                        
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
            UNION
            
            SELECT hierarchynode.description AS description_from_tpm_commit,luitem.description, COUNT(*) AS counter
		FROM map_deduction_item_rollup mdir
		LEFT JOIN map_deduction_item_rollup_header mdirh ON mdir.fk_map_deduction_item_rollup_header_id = mdirh.pk_map_deduction_item_rollup_header_id
		LEFT JOIN tpm_commit tc ON tc.commit_id = mdir.deal_reference
		LEFT JOIN ded_deduction_item item ON item.pk_deduction_item_id = mdir.fk_deduction_item_id
		INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
		INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
		INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

		WHERE mdir.deal_reference IS NOT NULL
		AND mdir.update_user != "System"
		GROUP BY 1, 2
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description, COUNT(*) AS counter
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            AND committable.product_hierarchy_id != item.product_hierarchy1_id
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2
	) C
	GROUP BY 1, 2
            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1, tc.cal_planned_amount,
    
    tc.planned_qty, tc.paid_qty, tc.variable_planned_amount, tc.fixed_planned_amount,
    tc.fk_commit_payment_type_id, tlcpt.longname AS payment_type_longname, 
    tp.promotion_type_id, tlpt.longname AS promotion_type_longname,
     
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    LEFT JOIN tpm_lu_commit_payment_type AS tlcpt ON tlcpt.commit_payment_type_id = tc.fk_commit_payment_type_id    
    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
    LEFT JOIN tpm_lu_promotion_type AS tlpt ON tlpt.promotion_type_id = tp.promotion_type_id
    
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
    AND tc.cal_planned_amount > 0     
     
    AND tc.promotion_id IN 
    (
		865005, 692727, 896927, 697206, 896930, 675420, 862092, 865002, 847050, 864207, 646197, 864528, 579393, 846183, 896984, 579588, 947732, 949178, 986150, 957122, 862467, 1224294, 626904, 897227, 578967, 864741, 1049399, 1272584, 1062731, 579231, 846156, 846888, 955880, 897059, 902774, 1224222, 846393, 626802, 989954, 864408, 862917, 627681, 645765, 1071383, 864549, 1119359, 628278, 862419, 847059, 1404494, 865233, 1224315, 846444, 579132, 964910, 718374, 864210, 579408, 865413, 846915, 645840, 953222, 862401, 947735, 599961, 645999, 957125, 1227323, 1224300, 846420, 696879, 646116, 578991, 1189877, 1049408, 862935, 903257, 1272602, 579255, 955667, 628134, 905720, 864570, 949616, 709071, 1224282, 1359452, 897182, 946736, 897845, 862920, 627870, 1062719, 646173, 966653, 846876, 645771, 1071386, 896834, 697281, 628284, 897017, 862422, 846378, 847065, 846786, 864138, 646143, 579138, 898007, 645729, 870582, 579429, 986087, 628488, 953345, 1224303, 846429, 626937, 846756, 990479, 1070903, 897236, 578994, 862938, 948401, 579357, 1428659, 628149, 864573, 579561, 949622, 628440, 645951, 897068, 862452, 1224285, 626886, 897191, 946760, 1109096, 948323, 1062722, 957767, 948779, 846546, 645774, 646254, 947693, 847002, 897023, 1077431, 845964, 696687, 626652, 989927, 847068, 1404515, 946709, 1049249, 846456, 627417, 579156, 964928, 645732, 646218, 579453, 947678, 865425, 846201, 1176481, 1119335, 986090, 645846, 1077164, 679182, 846357, 646017, 953348, 897104, 864702, 862860, 1224306, 846432, 626958, 846759, 1062680, 870396, 1070915, 944820, 579003, 864522, 579372, 846174, 718416, 846579, 1293539, 864267, 905762, 896969, 847026, 1224288, 626892, 645570, 946775, 887852, 897857, 1062725, 646182, 896843, 579522, 947696, 696369, 847005, 1077440, 845967, 645546, 864012, 946721, 645633, 646155, 579171, 679053, 1062779, 864225, 646221, 957941, 579486, 947681, 1119338, 1186538, 697254, 846936, 645861, 864606, 628497, 864705, 1338776, 865215, 1224309, 696891, 626970, 1062686, 990485, 1070927, 944823, 864462, 579042, 887918, 964901, 955817, 628170, 846909, 1293542, 864270, 862392, 579582, 880259, 897080, 887417, 862842, 1224291, 1070891, 897212, 946778, 864738, 887873, 627924, 1062728, 696276, 846885, 645780, 864564, 1122716, 1050065, 1043081, 645921, 862443, 880379, 989933, 864015, 864405, 897170, 946727, 904001, 646164, 703824, 579195, 674616, 1062782, 864228, 646227, 579498, 846612, 1119356, 986099, 846948, 864609, 955943, 628500, 1224312, 990587, 870405, 864132, 646131, 864465, 579054, 740391, 776535, 1130012, 1029202, 776331, 1109306, 858375, 1174133, 988538, 721035, 1072613, 1129889, 1026395, 740397, 776346, 1070003, 1129892, 1212956, 1123229, 858204, 1176682, 644124, 646641, 984347, 1218389, 776070, 643908, 646434, 858210, 1041053, 1355933, 1175285, 1263740, 1296011, 1212965, 1123235, 858213, 1052852, 740709, 1355936, 1213742, 1130027, 776532, 1038230, 1034720, 644109, 1041068, 644412, 1178180, 1047515, 646443, 688173, 1052858, 1216545, 858180, 776124, 992276, 878693, 992882, 696873, 697035, 880976, 879008, 1104770, 967376, 1027013, 934757, 880175, 697269, 734691, 992318, 881333, 986156, 735042, 967412, 718401, 878786, 879044, 1034912, 735015, 1027019, 1029730, 734694, 979767, 878699, 880160, 690756, 735045, 697398, 1130498, 713388, 897551, 880187, 1038365, 734697, 1050365, 1034894, 880358, 1036676, 967349, 697248, 879251, 690762, 696198, 979749, 1120229, 881237, 714093, 697020, 713520, 734703, 1036694, 697083, 880169, 690768, 1120232, 696516, 690720, 734313, 964832, 696438, 897824, 934754, 897536, 880496, 690774, 692889, 675597, 692910, 645981, 646209, 703938, 703365, 696882, 703614, 645540, 696885, 704115, 718449, 718125, 646611, 1041902, 718182, 718161, 646464, 646587, 1080812, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 659181, 494949, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 843948, 497457, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 728190, 1026512, 1168301, 715878, 944105, 753486, 678303, 753669, 753720, 678243, 714783, 713412, 678306, 973145, 678435, 966140, 714408, 677970, 678441, 753891, 1040006, 753771, 1020656, 1047491, 678453, 753309, 973064, 713430, 678153, 677958, 678048, 714468, 1173392, 953285, 905804, 1129838, 948338, 1131302, 858030, 1227338, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 586647, 1109147, 1037522, 1043774, 956366, 534753, 869019, 1039988, 534906, 533859, 535050, 1075967, 642138, 534861, 533616, 995063, 534630, 717873, 1071038, 868593, 869058, 1039646, 817464, 868752, 534963, 615513, 535170, 534717, 1043777, 632178, 632778, 593211, 868800, 535086, 868995, 632601, 868638, 533817, 688986, 659055, 534735, 868599, 869064, 868755, 534597, 868866, 1186862, 1044800, 1039769, 534720, 959867, 535323, 697056, 697185, 1039994, 1044014, 579990, 586614, 534702, 579510, 642144, 534885, 628605, 1075955, 534651, 1021019, 868518, 944210, 817479, 868758, 535212, 1039775, 868578, 534780, 869034, 697188, 1044017, 959669, 1043768, 959957, 869007, 535401, 868647, 593199, 533844, 868779, 1110773, 1075958, 717708, 638910, 685797, 1039532, 995054, 534603, 586800, 959885, 868968, 868581, 817443, 1069202, 868824, 956225, 720345, 868392, 534711, 1043771, 868530, 959960, 534903, 868788, 1075964, 1021025, 535284, 1039535, 868623, 944219, 535002, 1122902, 717858, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 684156, 1113440, 1113635, 716475, 641457, 1113224, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 726999, 1114295, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 727008, 1114319, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 983927, 1083068, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362, 1195697, 1195628, 897524, 1084049, 1084079, 1082945, 1082930, 876131, 1223319, 837270, 876365, 837486, 876266, 837321, 854538, 1222905, 876134, 837282, 1222857, 1190123, 876368, 1223034, 837426, 854544, 1072871, 1190039, 876143, 876518, 837285, 871776, 1222866, 1190126, 876380, 837519, 1223391, 837459, 854463, 854550, 1190042, 837288, 871779, 876392, 933893, 1223043, 837474, 854466, 854178, 876248, 1223349, 837303, 1072862, 876122, 837558, 876362, 1110779, 837483, 854469, 854181, 876251, 876599, 837318, 846627, 862863, 865149, 861984, 870366, 1129847, 1334618, 905735, 1131074, 870585, 948404, 1173380, 1334630, 1338191, 1209086, 1173356, 948422, 740451, 858738, 776244, 740580, 858033, 1122713, 1110389, 858039, 1110497, 1293545, 1200101, 992447, 1026983, 1026995, 879083, 897275, 1201817, 1388807, 1367495, 1061750, 858717, 1061813, 992234, 880637, 1361495, 1362134, 1070267, 1070417, 1070588, 1193027, 1193351, 1070276, 1069211, 1033204, 1361513, 1196531, 1362143, 1270346, 1193261, 1070540, 1074665, 1193264, 1193618, 1113815, 1053200, 1033225, 1186883, 1033243, 868851, 1212977, 959894, 959864, 868563, 959975, 1190240, 1123154, 1190222, 1070225, 1217816, 1074662, 1190225, 959900, 1039781, 1070168, 1121357, 1217822, 1190231, 1460147, 1460150, 1211573, 1201811, 1460156, 1460174, 1130804, 753336, 753912, 1368860, 1207193, 1207202, 862329, 1186523, 897083, 846417, 864252, 847014, 862446, 1042016, 1215554, 897014, 897134, 1216611, 1363646, 896993, 953342, 865203, 846012, 897230, 846894, 955889, 897062, 864654, 845991, 864066, 864729, 1383950, 1042019, 865449, 864393, 846453, 865353, 1363652, 864597, 862404, 897101, 1042082, 864258, 1131236, 846879, 896837, 1131185, 864216, 1363655, 953228, 897002, 862407, 847044, 897242, 887906, 864579, 864660, 862455, 846744, 864444, 897203, 864558, 1131077, 897026, 1398620, 846723, 897167, 864720, 862911, 846363, 846438, 948413, 864525, 896981, 847029, 862461, 862929, 956516, 864495, 846870, 1042172, 1396301, 776460, 1040168, 897833, 878696, 1353710, 1178222, 897548, 992345, 1338068, 880709, 1178225, 1026815, 934790, 880163, 992252, 1038392, 1178228, 1337825, 878765, 880190, 1178174, 1353830, 880367, 934748, 992459, 880172, 1027010, 861315, 850380, 861801, 849870, 1106876, 849972, 850356, 861426, 849606, 849765, 1105082, 861318, 850134, 1105061, 994190, 862800, 820101, 850203, 849609, 1106939, 850137, 862803, 820104, 850206, 849876, 863136, 1106882, 818610, 1074149, 861729, 1105016, 1106885, 850374, 994202, 861714, 819927, 1074209, 850377, 849627, 1106873, 849963, 1104986, 963086, 825006, 1359362, 1106927, 824250, 1122995, 823836, 963179, 1224612, 936914, 825123, 981246, 823557, 955448, 963131, 891620, 1224588, 825069, 823536, 823662, 1226576, 820374, 959138, 825021, 825186, 1106930, 820140, 823755, 982325, 824757, 985727, 891710, 823956, 1224618, 825138, 1106912, 855186, 981249, 1226489, 855696, 824475, 956630, 855570, 1224663, 824277, 820167, 854925, 824646, 982346, 1359164, 891713, 823962, 1106915, 823728, 824544, 824709, 1224594, 1226405, 855699, 1168637, 824529, 820392, 963122, 891566, 825027, 855573, 824298, 854928, 823764, 957788, 963065, 891506, 823866, 1106918, 855651, 823620, 891941, 823740, 892073, 824721, 1224600, 825096, 823698, 819492, 963125, 825045, 956645, 1041482, 824361, 962960, 820338, 963080, 959132, 892097, 963191, 1106921, 855654, 1168298, 892076, 824751, 1168565, 1110179, 823701, 1168643, 982307, 891617, 824415, 933608, 1226573, 962966, 1122329, 1224870, 1193372, 1122335, 1190264, 1193123, 1224762, 1051865, 1122350, 1083977, 1120436, 1191749, 1351952, 1082693, 1082765, 1351424, 1221915, 1082891, 1186811, 1222740, 1191026, 1187831, 1350023, 1170932, 1361888, 1082255, 1082744, 1191191, 1120688, 1120448, 1224795, 1186499, 1221933, 1120739, 1081382, 1191200, 1083416, 1351841, 1123397, 1080836, 1178087, 1222128, 1191080, 1191548, 1084532, 1221936, 1191731, 1120634, 1170938, 1081391, 1084016, 1191800, 1082219, 1351808, 1221969, 1191770, 1083659, 1301705, 1351433, 1084538, 1122272, 1082900, 1184822, 1351415, 1222566, 1084022, 1221990, 1084004, 1123388, 1222779, 1082174, 1191152, 1083785, 1221777, 1083974, 1122275, 1082762, 1191632, 1084034, 1082531, 1084196, 1187828, 1081358, 1186553, 1191572, 1084007, 1080974, 1083791, 1080830, 1301717, 1221783, 1122278, 1084139, 1084514, 1224711, 1084037, 1082159, 1081373, 1186559, 1351838, 1191785, 1222185, 1191161, 1080833, 1082918, 1123367, 1084145, 1191755, 1191545, 1351427, 1084526, 1186817, 1191728, 1222743, 1187834, 1082162, 1350026, 1082852, 1084181, 1120691, 1222788, 1221846, 1120652, 1083965, 1122266, 1082897, 1104995, 1082756, 1351394, 1222560, 1080992, 1351853, 1221987, 1191182, 1120469, 1083968, 1221939, 1082759, 1191626, 1191809, 1120472, 1361414, 1221972, 1104980, 1082705, 1301708, 1351436, 1186487, 1191209, 1221912, 1191023, 1083410, 1351832, 1123391, 846789, 862941, 955925, 1395581, 947687, 1396373, 1396307, 1395584, 880526, 903800, 1355918, 1540058, 904184, 955505, 1356212, 1380563, 1396232, 903509, 1396292, 1395578, 1380776, 1396262, 1299029, 1395563, 1110647, 972344, 1359257, 1379081, 1359443, 1359284, 1359422, 1353713, 1379123, 1457717, 992267, 1353734, 847035, 864360, 865200, 846003, 956519, 1398650, 864231, 865446, 953357, 864711, 864453, 846954, 953360, 864714, 846918, 1400945, 847041, 887891, 955898, 846741, 864732, 1129829, 846720, 862908, 864537, 1395374, 864459, 1173401, 846906, 1394249, 862926, 902756, 846867, 1178402, 864120, 864582, 1383257, 870591, 776505, 858396, 1220126, 858042, 880343, 878921, 1176523, 1176460, 1384856, 1176526, 1384859, 1359254, 1391753, 1359305, 1269149, 1382468, 1382465, 1293305, 1121879, 1293296, 1122776, 1293410, 1293395, 1293380, 1297013, 1122890, 1297010, 1131047, 1297088, 970133, 753489, 753615, 1074110, 1190963, 753906, 753618, 754668, 753480, 753252, 753774, 753483, 753666, 754680, 1222524, 1221960, 1376048, 1359293, 1184564, 1222515, 1221945, 1222758, 1189946, 1221948, 1222764, 1376045, 1189841, 1221903, 1359296, 1184567, 1222521, 1373315, 1373318, 1355765, 1215545, 896915, 896561, 1335887, 1402868, 897668, 955952, 1396982, 1110698, 740301, 740376, 897287, 879194, 1353845, 1195868, 1353401, 1176400, 1353680, 1353683, 1191575, 753294, 1269815, 860907, 1107680, 860769, 1070405, 867243, 1340594, 860892, 1272803, 860724, 860772, 1122584, 860805, 1122737, 860895, 1070693, 865101, 860922, 860808, 860898, 1123067, 1070537, 1382144, 1107653, 860949, 1070309, 860925, 1070240, 860778, 1269737, 860763, 1108697, 1382147, 1107656, 860967, 822972, 1359110, 1070243, 823002, 1396202, 1193735, 1270793, 1070402, 867237, 1396118, 1070582, 1107659, 1193681, 822975, 1070684, 1032295, 1359704, 1359092, 1193288, 1199243, 1384799, 1221867, 1384649, 1295624, 1384727, 1383848, 1359314, 1222644, 1295651, 1384733, 1082345, 1384712, 1384763, 1359458, 1384688, 1379072, 1384658, 1384739, 1384790, 1359728, 1222152, 1193384, 1384841, 1082438, 1193357, 1081322, 1359767, 1359437, 1384769, 1383860, 1359089, 1114598, 1113878, 1379078, 1222737, 1081232, 1384748, 1359635, 1359749, 1221855, 1081331, 1114565, 1359116, 1359755, 1408487, 1384760, 1384835, 1384679, 1379069, 1384655, 1359719, 1359521, 1384838, 1383854, 1359425, 1221849, 1082360, 1384766, 1222266, 1359698, 1359086, 1408526, 1379075, 1222731, 1081220, 1384745, 1384793, 1359743, 1193390, 1193360, 1359440, 1384670, 1114433, 1082456, 1376840, 1222251, 1395290, 1222242, 1376843, 1082453, 846804, 1405142, 903212, 870414, 880184, 880415, 1209113, 1405136, 1076045, 870363, 1405139, 1404482, 776154, 1410162, 1410165, 776328, 1428602, 896756, 754629, 753723, 753903, 753894, 1180292, 868590, 817458, 868749, 1191275, 1121363, 1339391, 868548, 959966, 1191212, 1189739, 868791, 1190234, 1189829, 868989, 868635, 1190219, 1122353, 1224819, 1192931, 1679132, 868857, 1070222, 1039763, 869022, 1044011, 1121330, 868773, 1356863, 959897, 1679135, 1074626, 1191179, 817473, 1122332, 868956, 868566, 959993, 869025, 868806, 868998, 868641, 868776, 1039529, 868602, 1113812, 1053197, 868965, 868821, 1374899, 1217819, 868527, 1193018, 1190228, 1356923, 1021022, 868620, 817515, 868761, 1356845, 1224669, 1122338, 1021007, 1044809, 1180247, 869040, 1191257, 1044020, 959849, 1071032, 1192922, 869010, 1193093, 1373369, 1189826, 959888, 846630, 861999, 846912, 864585, 887456, 1040243, 864450, 887876, 1428518, 870594, 846951, 846711, 847038, 846738, 864237, 1437224, 862905, 1447571, 1359383, 864456, 846900, 862923, 953363, 864717, 846864, 955934, 864108, 864735, 864540, 1447775, 865434, 1359395, 847047, 864357, 864666, 865194, 846000, 1437218, 953354, 864708, 1211183, 1428650, 1455929, 1552241, 1527020, 1552205, 1476764, 858177, 1428638, 1465412, 1448459, 1449209, 881279, 850335, 861717, 819933, 850131, 1293416, 994187, 849630, 1293401, 1074137, 1293383, 849924, 861720, 1353371, 861291, 1353455, 1293404, 849975, 850368, 861429, 1074146, 1353374, 849675, 1105064, 849897, 850371, 1293389, 820203, 1105067, 1293299, 820107, 849879, 849615, 820410, 850350, 849684, 994454, 850332, 1293302, 850128, 1293413, 850353, 1393439, 892100, 891737, 1646183, 823626, 823953, 855630, 1032490, 963035, 824697, 1131050, 1227386, 855687, 1654721, 854940, 962969, 1646060, 823773, 963089, 1702028, 963197, 1646186, 1119533, 1399856, 892085, 855633, 1368863, 1133855, 1032463, 823539, 854943, 962972, 1646063, 963107, 1131032, 1119536, 962954, 963041, 1400012, 824772, 963185, 825147, 981267, 892166, 825093, 1032466, 823542, 1041497, 1227356, 1041476, 1227107, 963188, 825153, 1368869, 854907, 963140, 892169, 823938, 1213775, 824532, 982304, 1646069, 959156, 1119695, 1353362, 823623, 824247, 1368872, 854910, 891947, 1646078, 823950, 936908, 1032484, 1213778, 824535, 819501, 963128, 959162, 825066, 855579, 1227377, 855681, 1654718, 1646057, 823770, 1383974, 1211825, 1211828, 1211798, 1383971, 1211801, 1211822, 956522, 955937, 1445033, 1464125, 1352051, 858636, 776064, 1435697, 1355492, 1409306, 1470323, 1220096, 1263824, 1220099, 1263827
     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)

AND (LEAST(everything_except_commit.extended_cost_norm_not_null, everything_except_commit.original_dispute_amount_not_null) <= (1.3 * commit_data.cal_planned_amount))


) AS temp



## ddi.status_code, longname of tc.fk_commit_payment_type_id, product_hierarchy_id-description & costumer_map_id - display_text count, 
##all the dates, merge_status, longname of promotion_type_id







# Final query by adding the group by statement





#208527 #205113 #986762


SELECT COUNT(*) FROM
(

SELECT DISTINCT 
#ded_deduction
everything_except_commit.pk_deduction_id,
everything_except_commit.original_dispute_amount,
everything_except_commit.cum_days_out_standing,
everything_except_commit.payer,
everything_except_commit.posting_date,
everything_except_commit.merge_status,

#display_text

everything_except_commit.cust_map_id_ded,
everything_except_commit.ded_display_text,

everything_except_commit.prom_customer_map_id1,
everything_except_commit.prom_display_text, 
everything_except_commit.display_text_count,


#dates
everything_except_commit.deduction_created_date,
everything_except_commit.customer_claim_date, 
everything_except_commit.invoice_date,
everything_except_commit.promortion_execution_from_date,
everything_except_commit.promotion_execution_to_date,
everything_except_commit.ship_start_date, 
everything_except_commit.ship_end_date, 
everything_except_commit.consumption_start_date, 
everything_except_commit.consumption_end_date,

#ddi
everything_except_commit.extended_cost_norm,      
everything_except_commit.unit_cost_norm,
everything_except_commit.deduction_item_quantity, 
everything_except_commit.status_code,
everything_except_commit.status_shortname,


#item_desc
everything_except_commit.ddi_prod_hier1, 
#everything_except_commit.ddi_lu_item_desc,

#everything_except_commit.lu_item_description,
#everything_except_commit.description_from_tpm_commit,
MAX(everything_except_commit.item_desc_count),


#commit_data
commit_data.promotion_id1,
commit_data.commit_id1,
commit_data.planned_qty,
commit_data.paid_qty,
commit_data.variable_planned_amount, 
commit_data.fixed_planned_amount,
commit_data.fk_commit_payment_type_id, 
commit_data.payment_type_longname,
commit_data.promotion_type_id,
commit_data.promotion_type_longname


 FROM
    (
    SELECT * FROM
        (
        SELECT * FROM
            (    
            SELECT
            table3_ded_data.pk_deduction_id,
            table3_ded_data.payterms_desc_new,
            #table1_display_text.ded_display_text,
            #table1_display_text.prom_display_text,
            table3_ded_data.deduction_created_date_min,
            table3_ded_data.customer_claim_date_min,
            table3_ded_data.invoice_date_min,
            table3_ded_data.original_dispute_amount,
            table3_ded_data.original_dispute_amount_not_null,
            
            table3_ded_data.promortion_execution_from_date_min,
            table3_ded_data.promotion_execution_to_date_max,
            
            table3_ded_data.cum_days_out_standing,
            table3_ded_data.payer,
            table3_ded_data.posting_date,
            table3_ded_data.deduction_created_date,
            table3_ded_data.customer_claim_date, 
            table3_ded_data.invoice_date,
            table3_ded_data.promortion_execution_from_date, 
            table3_ded_data.promotion_execution_to_date,
            table3_ded_data.merge_status,
            
            table1_display_text.prom_customer_map_id1,
            table1_display_text.ded_display_text1,
            table1_display_text.prom_display_text, 
            table1_display_text.display_text_count,
            
            table3_ded_data.cust_map_id_ded,
            table3_ded_data.ded_display_text
            
                                       
            FROM
                 (SELECT dd.pk_deduction_id, dd.original_dispute_amount, dd.company_code, dd.currency, mcar.payterms_desc,
                 
		 dd.cum_days_out_standing, dd.payer, dd.posting_date, dd.merge_status,
                 
                 
                 (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS payterms_desc_new,
                 
                 (CASE WHEN ISNULL(dd.original_dispute_amount) THEN 1000000 ELSE dd.original_dispute_amount END) AS original_dispute_amount_not_null,
                 
                 dd.fk_customer_map_id AS cust_map_id_ded, mcar.display_text AS ded_display_text,
                 dd.deduction_created_date, dd.customer_claim_date, dd.invoice_date,
                 dd.promortion_execution_from_date, dd.promotion_execution_to_date,
                 
                 (CASE WHEN ISNULL(dd.deduction_created_date) THEN '2017-12-31' ELSE dd.deduction_created_date END) AS deduction_created_date_min,
                 (CASE WHEN ISNULL(dd.customer_claim_date) THEN '2017-12-31' ELSE dd.customer_claim_date END) AS customer_claim_date_min,
                 (CASE WHEN ISNULL(dd.invoice_date) THEN '2017-12-31' ELSE dd.invoice_date END) AS invoice_date_min,
                 (CASE WHEN ISNULL(dd.promortion_execution_from_date) THEN '2017-12-31' ELSE dd.promortion_execution_from_date END) AS promortion_execution_from_date_min,
                 (CASE WHEN ISNULL(dd.promotion_execution_to_date) THEN '2000-01-01' ELSE dd.promotion_execution_to_date END) AS promotion_execution_to_date_max
                                  
                 FROM ded_deduction AS dd
                 LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                 LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                 LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                 LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                 LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                 LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                 INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                 INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                 WHERE 
                  dd.pk_deduction_id IN 
                 (
			11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
		
                 )
                 GROUP BY dd.pk_deduction_id
                 ) AS table3_ded_data
            
            LEFT JOIN     

                (
                SELECT ded_data.prom_customer_map_id1, ded_data.ded_display_text1,
                ded_data.prom_display_text, COUNT(*) AS display_text_count
                FROM
                    (
                    SELECT dd.pk_deduction_id, tp.promotion_id,
                    dd.fk_customer_map_id AS cust_map_id_ded, tp.fk_customer_map_id AS prom_customer_map_id1,
                    mcar.display_text AS ded_display_text1, mcar1.display_text AS prom_display_text                                                 
                    FROM ded_deduction_resolution_item AS ddri
                    LEFT JOIN ded_deduction_resolution AS ddr ON ddr.pk_resolution_id = ddri.fk_deduction_resolution_id
                    LEFT JOIN ded_deduction AS dd ON dd.pk_deduction_id = ddr.fk_deduction_id                            
                    LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                    LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                    LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                    LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                    LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                    LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
                    LEFT JOIN map_customer_account_rad AS mcar1 ON tp.fk_customer_map_id = mcar1.pk_customer_map_id

                    WHERE 
                    #dd.fiscal_year=2016
                    systemstatus.pk_deduction_status_system_id = 4
                    AND pk_reason_category_rad_id IN (126)
                    AND ddr.fk_resolution_type_id = 4
                    AND ddr.fk_resolution_status_id = 1
                    AND dd.fk_deduction_type_id = 0
                                                     
                    GROUP BY dd.pk_deduction_id, tp.promotion_id
                    ) AS ded_data
                    
                GROUP BY ded_data.ded_display_text1, ded_data.prom_display_text
               # HAVING COUNT(*) >= 100 OR ded_data.ded_display_text = ded_data.prom_display_text
                ) AS table1_display_text
         
             ON table1_display_text.ded_display_text1 = table3_ded_data.ded_display_text

             ) AS step1_join_data
        
        #joining with the promotion_data(table4) based on 4 conditions
        
        INNER JOIN 
            (
             SELECT tp.promotion_id, 
             tp.fk_customer_map_id AS prom_customer_map_id, mcar.display_text AS prom_display_text1,
             
             (CASE WHEN mcar.payterms_desc = 'EF90' THEN 'RE90' ELSE mcar.payterms_desc END) AS Payment_term_Prom_new,
             
             tp.ship_start_date, tp.ship_end_date, tp.consumption_start_date, tp.consumption_end_date,
                          
             (CASE WHEN ISNULL(tp.ship_start_date) THEN '2017-12-31' ELSE tp.ship_start_date END) AS ship_start_date_min,
             (CASE WHEN ISNULL(tp.consumption_start_date) THEN '2017-12-31' ELSE tp.consumption_start_date END) AS consumption_start_date_min,
             (CASE WHEN ISNULL(tp.ship_end_date) THEN '2000-01-01' ELSE tp.ship_end_date END) AS ship_end_date_max,
             (CASE WHEN ISNULL(tp.consumption_end_date) THEN '2000-01-01' ELSE tp.consumption_end_date END) AS consumption_end_date_max
             FROM tpm_commit AS tc
             LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
             LEFT JOIN map_customer_account_rad AS mcar ON tp.fk_customer_map_id = mcar.pk_customer_map_id
             LEFT JOIN map_payment_term_account_rad AS mptar ON mcar.fk_payment_term_map_id = mptar.pk_payment_term_map_id
                     
             WHERE tc.commit_id IN 
                (
                 SELECT DISTINCT fk_commitment_id
                 FROM ded_deduction_resolution_item AS ddri 
                 LEFT JOIN ded_deduction_resolution AS ddr ON ddri.fk_deduction_resolution_id = ddr.pk_resolution_id
                 LEFT JOIN ded_deduction AS ded ON ddr.fk_deduction_id = ded.pk_deduction_id
                 LEFT JOIN tpm_commit AS tc ON ddri.fk_commitment_id = tc.commit_id
                 LEFT JOIN tpm_lu_commit_status AS tlcs ON tc.commit_status_id = tlcs.commit_status_id
                 
                 WHERE 
                 ded.pk_deduction_id IN (SELECT DISTINCT fk_deduction_id FROM ded_deduction_item)
                 AND ddr.fk_resolution_status_id = 1
                 AND NOT ISNULL(tp.fk_customer_map_id)
                )
             AND tp.promotion_status_id = 6
             GROUP BY tp.promotion_id
        ) AS table4_prom_data

        ON step1_join_data.payterms_desc_new = table4_prom_data.Payment_term_Prom_new
        AND step1_join_data.prom_display_text = table4_prom_data.prom_display_text1
        AND  DATEDIFF(LEAST(step1_join_data.deduction_created_date_min, step1_join_data.promortion_execution_from_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)
        , LEAST(table4_prom_data.ship_start_date_min, table4_prom_data.consumption_start_date_min))
         >= -30
        AND  DATEDIFF(GREATEST(table4_prom_data.ship_end_date_max, table4_prom_data.consumption_end_date_max)
        ,GREATEST(step1_join_data.promotion_execution_to_date_max, LEAST(step1_join_data.deduction_created_date_min, step1_join_data.customer_claim_date_min, step1_join_data.invoice_date_min)))
        >= -30 
            
        )AS big_table




    #ded_deduction_item

    LEFT JOIN
        (
        SELECT * FROM
            (
            SELECT ddi.fk_deduction_id, ddi.pk_deduction_item_id, ddi.extended_cost_norm, 
            
            ddi.unit_cost_norm, ddi.deduction_item_quantity, ddi.status_code, ldimsr.shortname AS status_shortname,
            
	    (CASE WHEN ISNULL(ddi.extended_cost_norm) THEN 1000000 ELSE ddi.extended_cost_norm END) AS extended_cost_norm_not_null,
                 
            
            
            ddi.product_hierarchy1_id AS ddi_prod_hier1, lu_item.description AS ddi_lu_item_desc
            FROM
            ded_deduction_item AS ddi
            LEFT JOIN tpm_lu_item AS lu_item ON lu_item.item_id = ddi.fk_lu_item_id
            LEFT JOIN lu_deduction_item_mapping_status_rad AS ldimsr ON ldimsr.pk_deduction_item_mapping_status_id = ddi.status_code
            
            WHERE ddi.fk_deduction_id IN
                (SELECT * FROM
                    (
                     SELECT DISTINCT dd.pk_deduction_id                    
                     FROM ded_deduction AS dd
                     LEFT JOIN map_customer_account_rad AS mcar ON dd.fk_customer_map_id = mcar.pk_customer_map_id
                     LEFT JOIN ded_deduction_resolution AS ddr ON dd.pk_deduction_id = ddr.fk_deduction_id
                     LEFT JOIN lu_reason_code_rad AS reasoncode ON dd.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
                     LEFT JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
                     LEFT JOIN lu_deduction_status_rad AS deductionstatus ON dd.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
                     LEFT JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
                     INNER JOIN map_deduction_item_rollup_header AS header ON dd.pk_deduction_id = header.fk_deduction_id
                     INNER JOIN map_deduction_item_rollup AS map_item ON map_item.fk_map_deduction_item_rollup_header_id = header.pk_map_deduction_item_rollup_header_id

                     WHERE 
                     dd.pk_deduction_id IN 
		     (
				11421047, 11421341, 11484113, 11674634, 11674751, 11674790, 11786519, 11790848, 11791331, 11791367, 11791379, 11791412, 11791469, 11791580, 11827571, 11827640, 11827652, 11870843, 11874530, 12031658, 12031670, 12154640, 12261443, 12261467, 12261479, 12261677, 12261752, 12261806, 12261938, 12261995, 12262094, 12262112, 12333119, 12333122, 12333158, 12333161, 12333215, 12333218, 12333221, 12333287, 12333296, 12333386, 12333389, 12526759, 12570656, 12570707, 12570755, 12570782, 12570785, 12570788, 12570797, 12570824, 12570833, 12570896, 12570902, 12570905, 12570908, 12570926, 12570950, 12570965, 12570971, 12571085, 12571094, 12571103, 12678977, 12704663, 12704669, 12704849, 12704861, 12704867, 12704873, 12704879, 12704885, 12827315, 12908375, 12908411, 12908438, 12908450, 12908774, 12908855, 12908867, 12908876, 12908906, 12908909, 12908912, 12908936, 12909080, 12909083, 12909086, 12909089, 12909119, 12909122, 12909152, 12909161, 12909248, 12909260, 12981191, 13136507, 13136519, 13136534, 13136537, 13136609, 13176422, 13176524, 13176557, 13176569, 13176584, 13176626, 13176656, 13176752, 13176803, 13176881, 13176884, 13176914, 13176947, 13177004, 13177031, 13177058, 13177070, 13177082, 13217450, 13218296, 13218578, 13218644, 13218647, 13218650, 13218692, 13260662, 13410656, 13410668, 13410725, 13410740, 13410761, 13410794, 13410836, 13410923, 13410935, 13410971, 13410992, 13411016, 13411025, 13411040, 13411079, 13411097, 13411103, 13449956, 13501190, 13623521, 13675928, 13676006, 13676051, 13676054, 13676057, 13676060, 13676063, 14369673, 14445884, 14445935, 14445974, 14446061, 14446070, 14446079, 14446142, 14446175, 14446235, 14446247, 14446262, 14446271, 14446277, 14446289, 14446301, 14446319, 14446502, 14446514, 14446544, 14567714, 14567801, 14567807, 14567855, 14567867, 14567888, 14567897, 14567903, 14567909, 14567930, 14568005, 14568014, 14568023, 14568203, 14568227, 14568293, 14622927, 14745725, 14745737, 14745755, 14745860, 14788514, 14893181, 15079298, 15079352, 15079355, 15202226, 15202400, 15202406, 15202529, 15203843, 15203990, 15283361, 15394367, 15473246, 15473333, 15473336, 15473576, 15859529, 15920192, 16026308, 16026344, 16026356, 16026458, 16026461, 16147913, 16148348, 16148975, 16318868, 16318982, 16318985, 16449446, 16449923, 16450007, 16619987, 16914971, 16914974, 16914989, 16914992, 16915019, 16915049, 16915052, 16915193, 16915211, 16915214, 16915217, 16915220, 16915226, 16915247, 16915250, 16915253, 16915259, 16915262, 16915268, 16915301, 16915304, 16915322, 16915325, 16915328, 16915388, 16915400, 16915403, 16915409, 16915415, 16915427, 16915433, 16915436, 16915448, 16915454, 16915460, 16915475, 16915478, 16915523, 16915541, 16915544, 16915550, 16915556, 16915565, 16915595, 16915601, 16915604, 16915607, 16915613, 16915616, 16915625, 16915742, 16915880, 16916006, 16916297, 16916408, 16916471, 16916999, 16917059, 16917122, 16917185, 16917248, 16917368, 16917488, 16917551, 16917614, 16918181, 16918505, 16918775, 16918835, 16918892, 16918949, 16919135, 16919204, 16919270, 16919678, 16919792, 16919852, 16919972, 16920035, 16920107, 16920287, 16920593, 16920728, 16920761, 16920773, 16920776, 16920779, 16920785, 16920791, 16920794, 16920800, 16920806, 16920809, 16920815, 16920821, 16920830, 17066474, 17066477, 17066480, 17066483, 17066486, 17066492, 17066495, 17066498, 17066501, 17066504, 17066507, 17066528, 17066531, 17066534, 17066537, 17066540, 17066543, 17066546, 17066549, 17066552, 17066555, 17066558, 17066561, 17066585, 17066588, 17066591, 17066597, 17066603, 17066606, 17066609, 17066612, 17066624, 17066627, 17066630, 17066633, 17066636, 17066639, 17066642, 17066648, 17066651, 17066654, 17066657, 17066660, 17066663, 17066666, 17066669, 17066675, 17066678, 17066681, 17066684, 17066687, 17066690, 17066693, 17066696, 17066699, 17066702, 17066705, 17066711, 17066714, 17066717, 17066720, 17066723, 17066726, 17066729, 17066732, 17066735, 17066738, 17066741, 17066744, 17066747, 17066750, 17066753, 17066756, 17066759, 17066762, 17066783, 17066786, 17066789, 17066795, 17066798, 17066801, 17066804, 17066813, 17066816, 17066819, 17066822, 17066825, 17066828, 17066831, 17066834, 17066837, 17066840, 17066843, 17066846, 17066849, 17066852, 17066855, 17066858, 17066864, 17066867, 17066870, 17066873, 17066879, 17066882, 17066885, 17066888, 17066891, 17066894, 17066897, 17066906, 17066921, 17066924, 17066927, 17066930, 17066933, 17066936, 17066939, 17066942, 17066945, 17066951, 17066954, 17066957, 17066960, 17066963, 17066966, 17066969, 17066972, 17066975, 17066978, 17066981, 17066984, 17066987, 17066990, 17066993, 17066996, 17066999, 17067002, 17067005, 17067008, 17067011, 17067014, 17067017, 17067020, 17067023, 17067026, 17067029, 17067038, 17067044, 17067065, 17067101, 17067434, 17067437, 17067440, 17067443, 17067446, 17067449, 17067452, 17067455, 17067458, 17067461, 17067464, 17067467, 17067470, 17067482, 17067485, 17067491, 17067497, 17067509, 17067512, 17067515, 17067566, 17067680, 17067683, 17067689, 17067698, 17067701, 17067704, 17067707, 17067710, 17067713, 17067716, 17067719, 17067722, 17067725, 17067728, 17067731, 17067734, 17067737, 17067740, 17067743, 17067746, 17067749, 17067755, 17069150, 17069180, 17069213, 17069318, 17069357, 17069390, 17069420, 17069456, 17069543, 17069576, 17069609, 17069678, 17069714, 17069753, 17069795, 17069876, 17069915, 17069951, 17069984, 17070086, 17070131, 17070140, 17070143, 17070152, 17070155, 17070158, 17070161, 17070164, 17070167, 17070170, 17070173, 17070182, 17070185, 17070200, 17070203, 17070206, 17070212, 17070215, 17070218, 17070221, 17070224, 17070227, 17070254, 17070257, 17070260, 17070263, 17070266, 17070269, 17070272, 17070278, 17070281, 17070284, 17070287, 17070290, 17070293, 17070296, 17070299, 17070302, 17070305, 17070308, 17070311, 17070317, 17070320, 17070323, 17070326, 17070332, 17070335, 17070338, 17070341, 17070344, 17070347, 17070350, 17070353, 17070356, 17070359, 17070362, 17070365, 17070368, 17070374, 17070377, 17070383, 17070386, 17070389, 17070392, 17070398, 17070401, 17070404, 17070407, 17070410, 17070419, 17070422, 17070425, 17070428, 17070431, 17070434, 17070437, 17070446, 17070452, 17070455, 17070458, 17070461, 17070464, 17070467, 17070470, 17070473, 17070476, 17070482, 17070485, 17070488, 17204240, 17204444, 17205224, 17205245, 17206067, 17206145, 17206502, 17206538, 17206544, 17280758, 17280764, 17280767, 17280773, 17280776, 17280779, 17280782, 17280797, 17280833, 17280836, 17280839, 17280842, 17280845, 17280851, 17280854, 17280857, 17280860, 17280863, 17280866, 17280884, 17280893, 17280896, 17280899, 17280902, 17280905, 17280908, 17280911, 17280914, 17280917, 17280920, 17280923, 17280926, 17280929, 17280932, 17280935, 17280941, 17280947, 17280950, 17280953, 17280956, 17280959, 17280962, 17280965, 17280986, 17280989, 17280992, 17280995, 17280998, 17281004, 17281007, 17281010, 17281013, 17281109, 17281112, 17281115, 17281118, 17281124, 17281127, 17281136, 17281139, 17281142, 17281145, 17281148, 17281151, 17281154, 17281157, 17281175, 17281187, 17281190, 17281202, 17281208, 17281211, 17281214, 17281217, 17281220, 17281229, 17281241, 17281244, 17281250, 17281268, 17281271, 17281274, 17281277, 17281307, 17281337, 17281373, 17281406, 17281505, 17281547, 17281586, 17281736, 17281769, 17281847, 17281883, 17281910, 17282105, 17282249, 17282282, 17282318, 17282354, 17328941, 17328944, 17328947, 17328950, 17328956, 17328962, 17328977, 17328980, 17328983, 17329007, 17329010, 17329013, 17329016, 17329019, 17329025, 17329028, 17329031, 17329034, 17329037, 17329040, 17329043, 17329046, 17329049, 17329061, 17329064, 17329067, 17329070, 17329073, 17329076, 17329079, 17329082, 17329085, 17329088, 17329091, 17329094, 17329097, 17329100, 17329103, 17329106, 17329109, 17329112, 17329115, 17329121, 17329124, 17329127, 17329130, 17329133, 17329136, 17329139, 17329142, 17329145, 17329148, 17329151, 17329154, 17329157, 17329160, 17329175, 17329178, 17329181, 17329184, 17329187, 17329193, 17329196, 17329199, 17329202, 17329205, 17329208, 17329223, 17329226, 17329229, 17329232, 17329235, 17329238, 17329241, 17329244, 17329247, 17329268, 17329271, 17329286, 17329289, 17329292, 17329295, 17329298, 17329301, 17329304, 17329319, 17329322, 17329325, 17329328, 17329331, 17329334, 17329337, 17329340, 17329343, 17329346, 17329349, 17329352, 17329355, 17329361, 17329364, 17329367, 17329385, 17329388, 17329391, 17329394, 17329397, 17329400, 17329403, 17329409, 17329418, 17329421, 17329424, 17329427, 17329430, 17329433, 17329436, 17329439, 17329442, 17329445, 17329448, 17329451, 17329454, 17329457, 17329460, 17329463, 17329466, 17329469, 17329472, 17329478, 17329481, 17329484, 17329487, 17329499, 17329502, 17329505, 17329508, 17329511, 17329514, 17329517, 17329520, 17329526, 17329529, 17329532, 17329535, 17329538, 17329541, 17402234, 17402285, 17467274, 17467328, 17467331, 17467385, 17467415, 17467478, 17507558, 17507759, 17507768, 17507774, 17507777, 17507783, 17507786, 17507792, 17507798, 17507807, 17507813, 17507816, 17507819, 17507822, 17507825, 17507828, 17507831, 17507849, 17507855, 17507858, 17507861, 17507870, 17507873, 17507879, 17507906, 17507912, 17507918, 17507942, 17507951, 17507954, 17507960, 17507963, 17507966, 17507972, 17507975, 17507981, 17507987, 17507990, 17507993, 17508011, 17508014, 17508029, 17508032, 17508035, 17508038, 17508041, 17508044, 17508047, 17508050, 17508053, 17508056, 17508059, 17508083, 17508110, 17508113, 17508116, 17508125, 17508128, 17508131, 17508137, 17508140, 17508146, 17508149, 17508176, 17508179, 17508194, 17508212, 17508224, 17508230, 17508233, 17508236, 17508239, 17508242, 17508263, 17508266, 17508269, 17508935, 17509061, 17509124, 17509187, 17509433, 17509586, 17509784, 17509850, 17510120, 17510177, 17510342, 17510402, 17510459, 17510510, 17510627, 17557577, 17557580, 17557583, 17557586, 17557589, 17557592, 17557595, 17557598, 17557601, 17557604, 17557607, 17557610, 17557613, 17557616, 17557619, 17557622, 17557625, 17557628
		
		     )
                     GROUP BY dd.pk_deduction_id
                    ) AS suggest_sol)
            AND (NOT ISNULL(ddi.product_hierarchy1_id) OR NOT ISNULL(lu_item.description))
            ) AS ddi_data

        #joining ded_deduction_item with the item_description intermediate table
        
        LEFT JOIN
	(SELECT 
            C.description_from_tpm_commit AS description_from_tpm_commit,
            C.lu_item_description AS lu_item_description, SUM(C.counter) AS item_desc_count
            
            FROM
            (
            SELECT 
            hierarchynode.description AS description_from_tpm_commit,
            luitem.description AS lu_item_description, COUNT(*) AS counter
                        
            FROM ded_deduction_resolution_item AS resolveditem
            INNER JOIN ded_deduction_resolution AS resolution ON resolveditem.fk_deduction_resolution_id = resolution.pk_resolution_id
            INNER JOIN ded_deduction AS ded ON resolution.fk_deduction_id = ded.pk_deduction_id
            INNER JOIN ded_deduction_item AS item ON ded.pk_deduction_id = item.fk_deduction_id
            INNER JOIN lu_reason_code_rad AS reasoncode ON ded.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON ded.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE ded.fk_account_id = 16
            AND ded.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND ded.fk_deduction_type_id=0
            #AND deduction.fiscal_year = 2016
            AND committable.product_hierarchy_id = item.product_hierarchy1_id
                 
            GROUP BY 1, 2
            
            UNION
            
            SELECT hierarchynode.description AS description_from_tpm_commit,luitem.description, COUNT(*) AS counter
		FROM map_deduction_item_rollup mdir
		LEFT JOIN map_deduction_item_rollup_header mdirh ON mdir.fk_map_deduction_item_rollup_header_id = mdirh.pk_map_deduction_item_rollup_header_id
		LEFT JOIN tpm_commit tc ON tc.commit_id = mdir.deal_reference
		LEFT JOIN ded_deduction_item item ON item.pk_deduction_item_id = mdir.fk_deduction_item_id
		INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
		INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
		INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

		WHERE mdir.deal_reference IS NOT NULL
		AND mdir.update_user != "System"
		GROUP BY 1, 2
            
            UNION
            
            SELECT B.description_from_tpm_commit, B.lu_item_description, COUNT(*) AS counter
            FROM (
            SELECT *
            FROM (
            SELECT 
            #, committable.commit_id, item.pk_deduction_item_id, item.item_description,  hierarchynodedesc.description AS description_from_producthierarchy,
            deduction.pk_deduction_id, hierarchynode.description AS description_from_tpm_commit, luitem.description AS lu_item_description 
            FROM ded_deduction AS deduction
            INNER JOIN lu_reason_code_rad AS reasoncode ON deduction.fk_reason_code_map_id = reasoncode.pk_reason_code_rad_id
            INNER JOIN lu_reason_category_rad AS reasoncode_category ON reasoncode.fk_reason_category_rad_id = reasoncode_category.pk_reason_category_rad_id
            INNER JOIN lu_deduction_status_rad AS deductionstatus ON deduction.fk_deduction_status_id = deductionstatus.pk_deduction_status_id
            INNER JOIN lu_deduction_status_system AS systemstatus ON systemstatus.pk_deduction_status_system_id = deductionstatus.fk_deduction_status_system_id
            INNER JOIN ded_deduction_item AS item ON deduction.pk_deduction_id = item.fk_deduction_id
            INNER JOIN ded_deduction_resolution AS resolution ON resolution.fk_deduction_id = deduction.pk_deduction_id
            INNER JOIN ded_deduction_resolution_item AS resolveditem ON resolution.pk_resolution_id = resolveditem.fk_deduction_resolution_id
            INNER JOIN tpm_commit AS committable ON committable.commit_id = resolveditem.fk_commitment_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON committable.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
            INNER JOIN tpm_lu_product_hierarchy_node AS hierarchynodedesc ON item.product_hierarchy1_id = hierarchynodedesc.product_hierarchy_node_id
            INNER JOIN tpm_lu_item AS luitem ON luitem.item_id = item.fk_lu_item_id

            WHERE deduction.fk_account_id = 16
            AND deduction.fk_reason_code_map_id != -1
            AND resolution.fk_resolution_type_id = 4
            AND resolution.fk_resolution_status_id = 1
            AND reasoncode_category.shortname = "Trade"
            AND systemstatus.pk_deduction_status_system_id = 4
            AND deduction.fk_deduction_type_id=0
            AND committable.product_hierarchy_id != item.product_hierarchy1_id
            GROUP BY luitem.description, deduction.pk_deduction_id
            ) AS A
            GROUP BY A.pk_deduction_id
            HAVING COUNT(*) = 1
            ) AS B
            GROUP BY 1,2
	) C
	GROUP BY 1, 2
            ) AS item_desc_data

        ON ddi_data.ddi_lu_item_desc = item_desc_data.lu_item_description
        ) AS ddi_with_desc

    ON big_table.pk_deduction_id = ddi_with_desc.fk_deduction_id
            
) AS everything_except_commit

# joining with the commit

INNER JOIN

    (
    SELECT tc.promotion_id AS promotion_id1, tc.commit_id AS commit_id1, tc.cal_planned_amount,
    
    tc.planned_qty, tc.paid_qty, tc.variable_planned_amount, tc.fixed_planned_amount,
    tc.fk_commit_payment_type_id, tlcpt.longname AS payment_type_longname, 
    tp.promotion_type_id, tlpt.longname AS promotion_type_longname,
     
    tc.product_hierarchy_id AS prod_hier_id_commit1, hierarchynode.description AS commit_desc1 
     
    FROM tpm_commit AS tc 
    LEFT JOIN tpm_lu_product_hierarchy_node AS hierarchynode ON tc.product_hierarchy_id = hierarchynode.product_hierarchy_node_id
    LEFT JOIN tpm_lu_commit_payment_type AS tlcpt ON tlcpt.commit_payment_type_id = tc.fk_commit_payment_type_id    
    LEFT JOIN tpm_promotion AS tp ON tp.promotion_id = tc.promotion_id
    LEFT JOIN tpm_lu_promotion_type AS tlpt ON tlpt.promotion_type_id = tp.promotion_type_id
    
    WHERE tc.commit_status_id = 6
    AND NOT ISNULL(tc.product_hierarchy_id )
    AND tc.cal_planned_amount > 0     
     
    AND tc.promotion_id IN 
    (
		865005, 692727, 896927, 697206, 896930, 675420, 862092, 865002, 847050, 864207, 646197, 864528, 579393, 846183, 896984, 579588, 947732, 949178, 986150, 957122, 862467, 1224294, 626904, 897227, 578967, 864741, 1049399, 1272584, 1062731, 579231, 846156, 846888, 955880, 897059, 902774, 1224222, 846393, 626802, 989954, 864408, 862917, 627681, 645765, 1071383, 864549, 1119359, 628278, 862419, 847059, 1404494, 865233, 1224315, 846444, 579132, 964910, 718374, 864210, 579408, 865413, 846915, 645840, 953222, 862401, 947735, 599961, 645999, 957125, 1227323, 1224300, 846420, 696879, 646116, 578991, 1189877, 1049408, 862935, 903257, 1272602, 579255, 955667, 628134, 905720, 864570, 949616, 709071, 1224282, 1359452, 897182, 946736, 897845, 862920, 627870, 1062719, 646173, 966653, 846876, 645771, 1071386, 896834, 697281, 628284, 897017, 862422, 846378, 847065, 846786, 864138, 646143, 579138, 898007, 645729, 870582, 579429, 986087, 628488, 953345, 1224303, 846429, 626937, 846756, 990479, 1070903, 897236, 578994, 862938, 948401, 579357, 1428659, 628149, 864573, 579561, 949622, 628440, 645951, 897068, 862452, 1224285, 626886, 897191, 946760, 1109096, 948323, 1062722, 957767, 948779, 846546, 645774, 646254, 947693, 847002, 897023, 1077431, 845964, 696687, 626652, 989927, 847068, 1404515, 946709, 1049249, 846456, 627417, 579156, 964928, 645732, 646218, 579453, 947678, 865425, 846201, 1176481, 1119335, 986090, 645846, 1077164, 679182, 846357, 646017, 953348, 897104, 864702, 862860, 1224306, 846432, 626958, 846759, 1062680, 870396, 1070915, 944820, 579003, 864522, 579372, 846174, 718416, 846579, 1293539, 864267, 905762, 896969, 847026, 1224288, 626892, 645570, 946775, 887852, 897857, 1062725, 646182, 896843, 579522, 947696, 696369, 847005, 1077440, 845967, 645546, 864012, 946721, 645633, 646155, 579171, 679053, 1062779, 864225, 646221, 957941, 579486, 947681, 1119338, 1186538, 697254, 846936, 645861, 864606, 628497, 864705, 1338776, 865215, 1224309, 696891, 626970, 1062686, 990485, 1070927, 944823, 864462, 579042, 887918, 964901, 955817, 628170, 846909, 1293542, 864270, 862392, 579582, 880259, 897080, 887417, 862842, 1224291, 1070891, 897212, 946778, 864738, 887873, 627924, 1062728, 696276, 846885, 645780, 864564, 1122716, 1050065, 1043081, 645921, 862443, 880379, 989933, 864015, 864405, 897170, 946727, 904001, 646164, 703824, 579195, 674616, 1062782, 864228, 646227, 579498, 846612, 1119356, 986099, 846948, 864609, 955943, 628500, 1224312, 990587, 870405, 864132, 646131, 864465, 579054, 740391, 776535, 1130012, 1029202, 776331, 1109306, 858375, 1174133, 988538, 721035, 1072613, 1129889, 1026395, 740397, 776346, 1070003, 1129892, 1212956, 1123229, 858204, 1176682, 644124, 646641, 984347, 1218389, 776070, 643908, 646434, 858210, 1041053, 1355933, 1175285, 1263740, 1296011, 1212965, 1123235, 858213, 1052852, 740709, 1355936, 1213742, 1130027, 776532, 1038230, 1034720, 644109, 1041068, 644412, 1178180, 1047515, 646443, 688173, 1052858, 1216545, 858180, 776124, 992276, 878693, 992882, 696873, 697035, 880976, 879008, 1104770, 967376, 1027013, 934757, 880175, 697269, 734691, 992318, 881333, 986156, 735042, 967412, 718401, 878786, 879044, 1034912, 735015, 1027019, 1029730, 734694, 979767, 878699, 880160, 690756, 735045, 697398, 1130498, 713388, 897551, 880187, 1038365, 734697, 1050365, 1034894, 880358, 1036676, 967349, 697248, 879251, 690762, 696198, 979749, 1120229, 881237, 714093, 697020, 713520, 734703, 1036694, 697083, 880169, 690768, 1120232, 696516, 690720, 734313, 964832, 696438, 897824, 934754, 897536, 880496, 690774, 692889, 675597, 692910, 645981, 646209, 703938, 703365, 696882, 703614, 645540, 696885, 704115, 718449, 718125, 646611, 1041902, 718182, 718161, 646464, 646587, 1080812, 1131020, 1020689, 502425, 496281, 839190, 718326, 782205, 781476, 492906, 729504, 839583, 496242, 1070075, 494217, 839376, 729219, 492594, 781458, 496461, 496497, 731823, 496284, 838887, 496770, 803838, 496542, 839100, 839667, 496257, 496638, 978248, 492651, 496347, 496752, 725373, 496464, 824187, 839151, 496326, 496737, 839250, 496110, 496500, 839019, 502674, 495252, 729189, 839421, 502728, 731826, 725376, 659181, 494949, 496080, 492927, 496485, 496809, 501807, 496545, 502710, 492546, 496641, 724518, 502764, 838866, 496755, 823788, 978236, 496329, 496740, 839487, 803403, 588132, 839310, 724566, 496047, 838905, 728271, 501810, 782025, 724530, 838869, 718392, 496797, 839064, 494226, 496743, 839793, 496065, 803136, 839637, 728298, 492585, 496725, 724572, 502785, 496491, 502662, 1020686, 803757, 496800, 839850, 494238, 502464, 978242, 839739, 781368, 496785, 839562, 496512, 823533, 824115, 496053, 502668, 1030057, 844710, 502722, 727608, 497223, 494844, 783447, 830118, 496998, 843948, 497457, 599772, 497067, 502536, 502791, 497703, 659202, 599733, 844476, 497022, 844761, 502776, 497004, 844341, 494112, 844494, 600498, 843981, 497466, 497208, 494121, 844734, 497715, 720612, 497805, 1106969, 494835, 497298, 844440, 727650, 783507, 502323, 502734, 497775, 935378, 783462, 497301, 1106726, 496989, 497454, 721014, 818709, 497730, 502335, 497064, 498450, 843549, 498294, 493473, 843876, 843591, 498000, 841932, 498417, 498453, 830208, 1030060, 498063, 498759, 493374, 843105, 498513, 498006, 498237, 843084, 503667, 498696, 498420, 498456, 843903, 498066, 498768, 727614, 503322, 783849, 498708, 498213, 498801, 586836, 841971, 498465, 842052, 503340, 843330, 727620, 498444, 986135, 721170, 843807, 498492, 497991, 503388, 498720, 843360, 498216, 659163, 503349, 783660, 503700, 986138, 833187, 498288, 843153, 843531, 783621, 843513, 498471, 843564, 498780, 726549, 499365, 842571, 842769, 782631, 498810, 499659, 502806, 842517, 498945, 977075, 499062, 986240, 499590, 830985, 503595, 498843, 498903, 499485, 841881, 499119, 498828, 499704, 498870, 842283, 503511, 499662, 502809, 659178, 842067, 499068, 986255, 782619, 499149, 499593, 503598, 503649, 499371, 842049, 499122, 842160, 499101, 499539, 721161, 499308, 1030108, 842121, 499161, 499713, 498927, 842796, 1107245, 841872, 499104, 493704, 842124, 586872, 1107113, 503658, 841890, 498894, 720528, 498855, 493707, 498807, 502803, 733632, 842310, 499509, 842367, 782442, 499287, 641922, 497925, 499002, 835713, 503532, 499245, 499452, 782898, 493431, 499290, 845100, 499512, 493413, 978356, 834186, 843978, 499770, 497910, 499455, 720669, 497874, 1030105, 834342, 719328, 582555, 845868, 497913, 845667, 499458, 845793, 844086, 502881, 497877, 641529, 503601, 845091, 503652, 845157, 499494, 782607, 503016, 835731, 493395, 845271, 782538, 498990, 499464, 845544, 493326, 719160, 641532, 1071371, 498930, 845514, 493401, 845574, 499284, 641907, 499467, 499239, 845319, 641871, 499449, 497994, 493329, 844278, 659166, 499722, 725820, 641847, 493635, 500727, 982181, 845124, 500676, 500433, 502989, 500529, 503043, 845700, 503025, 502824, 725556, 493617, 721152, 845061, 783021, 493662, 845448, 500787, 978362, 641943, 500469, 830730, 982190, 783042, 500664, 641946, 499815, 659319, 493266, 845220, 659283, 833850, 845727, 500565, 982175, 500178, 986945, 500523, 982124, 845052, 733839, 659214, 499818, 659322, 844971, 503019, 782997, 500712, 845487, 500568, 982178, 726654, 500184, 986951, 503040, 1030096, 500766, 845757, 500334, 782913, 500280, 499839, 503397, 500133, 782700, 500256, 493659, 500598, 499809, 500337, 844155, 843648, 499881, 503442, 844857, 732942, 1030420, 500547, 500628, 500259, 833790, 500514, 844383, 843267, 499890, 986165, 503445, 500097, 658989, 1023164, 732951, 499848, 493911, 500082, 500553, 503523, 720522, 1107140, 500649, 500100, 1023167, 844089, 500634, 843240, 844866, 493629, 493914, 503064, 782748, 500370, 1070069, 500037, 844785, 500652, 500355, 1030093, 1107074, 1023173, 844095, 493632, 500319, 503079, 499836, 844503, 1070072, 500040, 721146, 830772, 843078, 500127, 493656, 842997, 499911, 500595, 501135, 841830, 720570, 502410, 503508, 502059, 841071, 841365, 1030099, 501990, 501141, 841128, 841524, 502215, 502413, 502761, 502062, 841074, 501180, 502977, 501921, 500910, 720783, 782379, 500859, 493929, 502284, 834162, 841545, 501930, 502458, 502746, 500913, 841488, 841758, 501162, 502677, 500862, 493932, 840045, 502290, 839928, 782421, 502884, 502983, 502461, 831663, 839964, 658995, 502926, 615993, 502407, 840240, 494214, 502683, 493878, 502443, 503022, 501984, 782670, 753783, 728190, 1026512, 1168301, 715878, 944105, 753486, 678303, 753669, 753720, 678243, 714783, 713412, 678306, 973145, 678435, 966140, 714408, 677970, 678441, 753891, 1040006, 753771, 1020656, 1047491, 678453, 753309, 973064, 713430, 678153, 677958, 678048, 714468, 1173392, 953285, 905804, 1129838, 948338, 1131302, 858030, 1227338, 1218161, 1218305, 1212959, 1218653, 1218284, 1226201, 1218287, 1026881, 1071035, 869046, 586647, 1109147, 1037522, 1043774, 956366, 534753, 869019, 1039988, 534906, 533859, 535050, 1075967, 642138, 534861, 533616, 995063, 534630, 717873, 1071038, 868593, 869058, 1039646, 817464, 868752, 534963, 615513, 535170, 534717, 1043777, 632178, 632778, 593211, 868800, 535086, 868995, 632601, 868638, 533817, 688986, 659055, 534735, 868599, 869064, 868755, 534597, 868866, 1186862, 1044800, 1039769, 534720, 959867, 535323, 697056, 697185, 1039994, 1044014, 579990, 586614, 534702, 579510, 642144, 534885, 628605, 1075955, 534651, 1021019, 868518, 944210, 817479, 868758, 535212, 1039775, 868578, 534780, 869034, 697188, 1044017, 959669, 1043768, 959957, 869007, 535401, 868647, 593199, 533844, 868779, 1110773, 1075958, 717708, 638910, 685797, 1039532, 995054, 534603, 586800, 959885, 868968, 868581, 817443, 1069202, 868824, 956225, 720345, 868392, 534711, 1043771, 868530, 959960, 534903, 868788, 1075964, 1021025, 535284, 1039535, 868623, 944219, 535002, 1122902, 717858, 868986, 753621, 847017, 948320, 1176490, 1186520, 1070852, 972527, 776097, 776073, 858771, 983975, 1112969, 983786, 1113473, 983948, 661035, 1112693, 984248, 1113653, 727452, 683526, 935255, 1113413, 947549, 683622, 660096, 974519, 698349, 1113482, 641112, 716433, 1112699, 974354, 639348, 955028, 639561, 1112705, 953783, 698733, 984131, 697686, 1112879, 954992, 984116, 698235, 983855, 955109, 636657, 1112711, 1113488, 1113188, 716160, 1112903, 935276, 947483, 953636, 974471, 636603, 1113392, 984242, 1113341, 1113455, 1112906, 947249, 1113125, 953714, 699168, 1043795, 697662, 1043930, 683523, 639888, 684141, 954956, 1112396, 698217, 953777, 727356, 1112378, 699012, 716496, 1112336, 1111832, 947453, 1112639, 1112114, 683502, 1112399, 935234, 984266, 1112381, 1111886, 935417, 1112342, 953645, 955043, 1112423, 1112660, 636804, 1112126, 716469, 984185, 636648, 1111949, 697914, 684234, 698577, 983834, 1111889, 683724, 983939, 984254, 1112156, 1043942, 639660, 1112360, 974483, 1111856, 1112669, 1112129, 641166, 1112411, 697917, 1043783, 698133, 1111898, 953726, 684219, 1111871, 660141, 661134, 640011, 983714, 1112303, 955034, 1112414, 983858, 974345, 974456, 1112102, 1112174, 639237, 983888, 699504, 1112684, 683898, 1112315, 1112609, 683847, 1112249, 1111718, 984176, 636639, 1112501, 984263, 1112177, 1111883, 1112147, 955040, 1112420, 636708, 1111994, 697746, 1112252, 955025, 639267, 716466, 698226, 697911, 974447, 639678, 683592, 699018, 1112471, 716499, 953720, 983894, 1112150, 983723, 641205, 974480, 1112012, 983936, 639987, 1112261, 947318, 935237, 983852, 661113, 1043780, 1111700, 1112477, 727341, 660138, 1112015, 683628, 974342, 935438, 1111703, 1112390, 1112495, 984257, 1043945, 1112372, 1112447, 699498, 983987, 698505, 947444, 1111982, 947534, 954953, 1112246, 698136, 684246, 1111712, 1112393, 1112498, 953774, 1112375, 1112462, 1112036, 1112144, 953639, 1112417, 1111985, 640911, 684249, 639696, 1111190, 636792, 1111496, 984053, 683589, 1111154, 1111457, 1111604, 984197, 684252, 639702, 953687, 1111199, 983915, 974333, 699543, 947585, 1111499, 1111460, 931010, 954989, 1111625, 683535, 697485, 935321, 698157, 1111211, 727365, 1111502, 931133, 698205, 660276, 983726, 1111640, 953651, 983816, 935402, 954968, 1111550, 1111505, 716454, 1111172, 974591, 984026, 1111646, 955055, 716490, 1111430, 660870, 953792, 639099, 1111508, 683481, 984152, 1111493, 640146, 1043948, 698190, 974489, 1111331, 636849, 698418, 697467, 1111262, 639111, 984230, 698727, 1112912, 955001, 1113140, 935282, 684210, 1113248, 697560, 983933, 983705, 1043915, 726993, 1113215, 983849, 955103, 1112918, 984065, 947405, 683718, 1026764, 698025, 699186, 1112867, 1113659, 1113089, 953705, 637191, 1113416, 698394, 983981, 639621, 935819, 974465, 1113218, 685125, 1113485, 1112927, 983777, 955010, 1113182, 636630, 684498, 1113272, 697566, 962816, 1113221, 974525, 1112942, 947288, 639933, 1043813, 1113680, 1113122, 953654, 1113296, 974306, 984209, 684156, 1113440, 1113635, 716475, 641457, 1113224, 1112954, 953681, 684375, 661077, 660054, 716148, 1113650, 698253, 1113233, 953756, 1111526, 683499, 935231, 953735, 983912, 1111382, 1111658, 698565, 983891, 1111349, 661146, 935414, 1111292, 660270, 1111538, 947309, 984182, 1111388, 727359, 1111664, 983831, 1111166, 1111358, 984251, 974429, 1043936, 1111313, 1111547, 953690, 974339, 1111391, 716451, 1111169, 697893, 1111361, 1111469, 640137, 683934, 955046, 697488, 1111316, 1111415, 1111250, 954947, 698208, 1111376, 1111475, 931034, 639222, 699006, 974486, 1111319, 636822, 1111559, 684267, 639711, 1111256, 636669, 639687, 698211, 1111181, 953729, 1111379, 699531, 947579, 698106, 984041, 1111655, 716493, 1111448, 983717, 1111580, 641187, 955037, 947450, 983861, 1112111, 683616, 974516, 1113347, 641103, 716430, 1112465, 1113314, 953717, 1112060, 974351, 1043798, 636609, 983864, 955118, 698046, 983978, 954959, 1111748, 636645, 1113359, 1112213, 984128, 1113317, 661047, 1112084, 716271, 1111835, 935270, 683514, 1111751, 1112402, 1113362, 984236, 698355, 1112231, 1112387, 699030, 1113332, 1113674, 697770, 639375, 1112444, 639903, 1113632, 683517, 953633, 955031, 1111760, 1112567, 1113368, 698736, 1113338, 1112096, 697689, 698541, 984119, 1112030, 953771, 639567, 1112132, 1043927, 983798, 1111799, 1112579, 684135, 983945, 1111880, 1113308, 947486, 660153, 984245, 727449, 974474, 1111811, 935252, 955022, 716463, 1111925, 974444, 984125, 983720, 953642, 698523, 974477, 1111928, 1112525, 984233, 983951, 639579, 636711, 954962, 983792, 683625, 698232, 699450, 1112537, 641118, 716505, 953723, 660207, 1112090, 935273, 953768, 983984, 1112291, 698163, 935240, 947438, 1111958, 684129, 1112237, 661068, 727344, 1112171, 947243, 697773, 636618, 1112681, 697740, 683610, 1111922, 639960, 984260, 984122, 639393, 683637, 955115, 947537, 974348, 1113497, 641136, 984077, 1113212, 953684, 983846, 699207, 684360, 1112846, 1043933, 684144, 1112774, 1113500, 639114, 1112981, 639867, 953780, 955004, 1113143, 684363, 727455, 1113257, 697563, 1113563, 1112993, 974522, 983960, 716157, 637245, 974357, 947480, 1113422, 1112786, 1112999, 974468, 984239, 698367, 955013, 984134, 698721, 983942, 935678, 683685, 953711, 661029, 1043792, 697644, 639630, 1113014, 660111, 955112, 698034, 1113491, 983783, 1113194, 698280, 935279, 984212, 636606, 716478, 1113398, 1112768, 1043912, 1114286, 1113902, 955100, 1114616, 947390, 955067, 684093, 974315, 716220, 954986, 1113077, 1114325, 640344, 683850, 698745, 640206, 1113905, 684231, 935801, 953672, 1113884, 984218, 1114568, 1113866, 1114331, 637092, 716484, 983867, 1112777, 974405, 1114409, 698310, 953747, 1114094, 1113887, 974498, 935288, 699267, 1113110, 697953, 684264, 984098, 726999, 1114295, 953693, 637170, 983924, 1114535, 1114265, 641412, 1113893, 684102, 698097, 698439, 659910, 1114541, 1112789, 661353, 1114307, 984191, 638997, 1112753, 983696, 1114280, 1113896, 1112801, 1113065, 983801, 1113827, 697923, 983702, 1114115, 697830, 1113992, 1113707, 697875, 1114151, 699261, 1113941, 1114439, 953759, 1114118, 1114289, 947519, 1113998, 638943, 1114523, 1114628, 1113710, 659922, 1114358, 1113974, 683814, 661377, 698988, 1113944, 984200, 947660, 1114121, 984086, 1114292, 983921, 1114001, 1114526, 1114634, 1113716, 684366, 1113983, 974321, 1114583, 640287, 955124, 1114136, 640224, 1114427, 1114004, 1113722, 698580, 684372, 974501, 1113986, 636774, 1114586, 1114211, 983822, 983873, 684441, 716214, 1114139, 954980, 1114430, 637173, 935309, 1043906, 935810, 716460, 1114376, 1113989, 1043816, 1113695, 953666, 947375, 1114343, 955061, 1113959, 698340, 1114562, 698073, 983990, 1114142, 974417, 727008, 1114319, 953699, 1113932, 984194, 698382, 1082801, 935813, 947417, 1081067, 1083596, 684168, 639597, 1080929, 697506, 1131215, 984215, 1175225, 983810, 1084010, 1084166, 1081202, 1082204, 1084436, 974462, 1080962, 1109156, 1083617, 1081421, 1083440, 1131230, 935285, 684096, 684450, 1170935, 1083260, 1080896, 1084475, 1174238, 716136, 698262, 1082969, 1083101, 983708, 639120, 1043918, 1084451, 726996, 955106, 1081124, 1083140, 984068, 1083008, 1083572, 639927, 698028, 1043810, 1081517, 1082393, 953708, 1081217, 1081352, 698754, 716472, 641445, 1082642, 1083059, 1083779, 1083344, 1119515, 953678, 983840, 660078, 1083449, 1084235, 1083113, 1131509, 1083296, 661413, 1084493, 1080998, 1082522, 1082684, 1082729, 1083854, 1080863, 1084457, 1082372, 1083395, 974528, 953753, 1083674, 983966, 699231, 1084391, 636918, 955019, 1083464, 683736, 984227, 1083122, 1083299, 954998, 1083923, 636621, 697503, 1082990, 974309, 1083548, 1082237, 1083245, 1081181, 1082660, 983930, 697743, 684114, 638940, 684225, 659916, 953669, 983993, 716481, 947657, 974402, 962810, 953606, 641394, 974318, 698082, 637959, 955121, 953765, 684387, 935303, 698289, 698436, 661389, 983870, 984206, 699570, 935558, 984188, 983693, 697737, 947357, 640353, 1076501, 727002, 953696, 683838, 637038, 974504, 947513, 935795, 983825, 716217, 1076510, 954983, 699255, 962831, 1082339, 974459, 1119521, 1080953, 641427, 685119, 697527, 1083125, 1105046, 1083437, 636624, 1026758, 697989, 1083683, 661365, 1080890, 1174208, 1083413, 727017, 953702, 1082342, 1082804, 1081088, 1083044, 1108856, 639009, 1043804, 1199543, 1083884, 1082387, 1084013, 660126, 1081205, 1082669, 947567, 698748, 1083989, 962813, 1083485, 1082633, 684126, 1083056, 1083632, 699219, 1083764, 636912, 1081424, 953612, 1083329, 1080935, 953675, 947408, 984221, 1084232, 1199555, 684216, 1083272, 1083893, 1084478, 1120499, 716487, 684084, 1082984, 698328, 983711, 1083845, 1043921, 1084454, 1083389, 935822, 1081154, 953750, 698031, 1082702, 983963, 639606, 1084382, 984071, 683733, 935291, 1109099, 984224, 954995, 716142, 684087, 1083545, 1081355, 1083233, 1084157, 1081178, 983927, 1083068, 1081475, 1083359, 1108874, 983843, 955097, 1109105, 698445, 1084496, 1081004, 684090, 1170857, 640263, 1082375, 974531, 1083089, 955865, 955874, 846771, 955928, 1131170, 887756, 955931, 887510, 955673, 1131776, 1227110, 1173383, 949229, 1212947, 1040165, 776109, 1201601, 1069214, 1186865, 1069172, 956609, 887885, 948332, 902762, 881282, 1195907, 1036628, 1293635, 1213763, 1293644, 1213061, 1293647, 1213727, 1293650, 1213757, 1181738, 1186667, 1121075, 1083836, 1186769, 1186484, 1186403, 1186658, 1083827, 1186757, 1186481, 1186391, 1083905, 1121090, 1180397, 1083365, 1083476, 1083740, 1083311, 1193255, 1083128, 1083698, 1082165, 1184819, 1083539, 1082813, 1083509, 1131287, 1187990, 1083425, 1082906, 1083590, 1083431, 1082909, 1083374, 1082894, 1083530, 1083704, 1083422, 1082168, 1083512, 1187999, 1083734, 953339, 846750, 864078, 1173386, 862932, 864651, 1040222, 846729, 946733, 864726, 1040348, 1195658, 846873, 953276, 1040204, 864594, 1293227, 1040381, 864255, 1293194, 1040225, 864552, 1040207, 864213, 865416, 953225, 865209, 1171055, 1293197, 847023, 864657, 1040228, 1298810, 864396, 1040336, 1040231, 1040366, 846882, 864243, 1040216, 847074, 1040339, 1295660, 863970, 949172, 1040237, 864447, 1040372, 847008, 1293617, 1040219, 864723, 1040345, 862914, 1040201, 1130039, 1395485, 1218476, 1219142, 1218479, 1266455, 1353992, 1219151, 1407191, 1272722, 1219154, 1070831, 1459058, 1408007, 1376873, 1296740, 1459079, 1072607, 1217528, 1336469, 1195565, 1212920, 1108880, 1198472, 1184783, 1083188, 1083746, 1083317, 1082216, 1191143, 1084355, 1108862, 1083443, 1186820, 1202678, 1083107, 1120859, 1082882, 1184732, 1083677, 1080884, 1191155, 1084409, 1108853, 1083248, 1083098, 1083482, 1082258, 1083377, 1084307, 1108871, 1186826, 1202690, 1083713, 1198451, 1082888, 753897, 754461, 753477, 839415, 803763, 781371, 1021028, 839499, 803835, 839568, 782142, 839784, 839625, 839133, 839196, 823779, 838959, 839835, 839043, 839730, 838890, 839589, 839103, 839670, 824217, 803436, 839154, 782223, 839367, 958232, 839313, 823527, 824097, 803682, 839607, 823746, 838872, 781473, 1168799, 839238, 781455, 783465, 1196561, 830148, 844473, 818712, 844491, 844728, 1211267, 946634, 843951, 844746, 783498, 843984, 844689, 783435, 844392, 844428, 1131638, 843318, 833190, 843102, 841980, 843828, 843597, 841935, 830217, 783648, 843540, 843888, 833295, 843147, 843528, 843075, 843510, 843894, 783855, 843813, 783663, 842043, 782427, 841896, 782445, 834399, 830964, 842772, 842082, 842268, 842709, 842580, 842352, 841869, 782622, 842163, 842556, 842022, 977063, 842307, 842106, 841875, 845322, 782544, 782595, 1110506, 845403, 844332, 834333, 845880, 845265, 845817, 845085, 1110509, 782529, 834117, 845154, 835728, 845610, 845541, 845511, 845094, 843987, 835734, 834171, 845805, 783033, 830727, 845127, 845310, 845739, 782973, 845106, 978794, 845484, 845004, 845067, 845439, 833877, 845223, 845754, 1188323, 783015, 845697, 844974, 833883, 843081, 844380, 1184966, 782916, 844080, 843006, 946643, 844158, 1107272, 843651, 844812, 1174037, 844797, 782745, 833793, 844500, 830769, 844113, 843333, 844869, 843312, 1130900, 782751, 1196627, 840051, 840246, 1168787, 1188086, 839973, 841482, 841785, 834159, 841089, 841770, 841131, 782418, 834420, 841839, 841515, 782385, 782667, 839931, 831666, 841065, 841362, 1195697, 1195628, 897524, 1084049, 1084079, 1082945, 1082930, 876131, 1223319, 837270, 876365, 837486, 876266, 837321, 854538, 1222905, 876134, 837282, 1222857, 1190123, 876368, 1223034, 837426, 854544, 1072871, 1190039, 876143, 876518, 837285, 871776, 1222866, 1190126, 876380, 837519, 1223391, 837459, 854463, 854550, 1190042, 837288, 871779, 876392, 933893, 1223043, 837474, 854466, 854178, 876248, 1223349, 837303, 1072862, 876122, 837558, 876362, 1110779, 837483, 854469, 854181, 876251, 876599, 837318, 846627, 862863, 865149, 861984, 870366, 1129847, 1334618, 905735, 1131074, 870585, 948404, 1173380, 1334630, 1338191, 1209086, 1173356, 948422, 740451, 858738, 776244, 740580, 858033, 1122713, 1110389, 858039, 1110497, 1293545, 1200101, 992447, 1026983, 1026995, 879083, 897275, 1201817, 1388807, 1367495, 1061750, 858717, 1061813, 992234, 880637, 1361495, 1362134, 1070267, 1070417, 1070588, 1193027, 1193351, 1070276, 1069211, 1033204, 1361513, 1196531, 1362143, 1270346, 1193261, 1070540, 1074665, 1193264, 1193618, 1113815, 1053200, 1033225, 1186883, 1033243, 868851, 1212977, 959894, 959864, 868563, 959975, 1190240, 1123154, 1190222, 1070225, 1217816, 1074662, 1190225, 959900, 1039781, 1070168, 1121357, 1217822, 1190231, 1460147, 1460150, 1211573, 1201811, 1460156, 1460174, 1130804, 753336, 753912, 1368860, 1207193, 1207202, 862329, 1186523, 897083, 846417, 864252, 847014, 862446, 1042016, 1215554, 897014, 897134, 1216611, 1363646, 896993, 953342, 865203, 846012, 897230, 846894, 955889, 897062, 864654, 845991, 864066, 864729, 1383950, 1042019, 865449, 864393, 846453, 865353, 1363652, 864597, 862404, 897101, 1042082, 864258, 1131236, 846879, 896837, 1131185, 864216, 1363655, 953228, 897002, 862407, 847044, 897242, 887906, 864579, 864660, 862455, 846744, 864444, 897203, 864558, 1131077, 897026, 1398620, 846723, 897167, 864720, 862911, 846363, 846438, 948413, 864525, 896981, 847029, 862461, 862929, 956516, 864495, 846870, 1042172, 1396301, 776460, 1040168, 897833, 878696, 1353710, 1178222, 897548, 992345, 1338068, 880709, 1178225, 1026815, 934790, 880163, 992252, 1038392, 1178228, 1337825, 878765, 880190, 1178174, 1353830, 880367, 934748, 992459, 880172, 1027010, 861315, 850380, 861801, 849870, 1106876, 849972, 850356, 861426, 849606, 849765, 1105082, 861318, 850134, 1105061, 994190, 862800, 820101, 850203, 849609, 1106939, 850137, 862803, 820104, 850206, 849876, 863136, 1106882, 818610, 1074149, 861729, 1105016, 1106885, 850374, 994202, 861714, 819927, 1074209, 850377, 849627, 1106873, 849963, 1104986, 963086, 825006, 1359362, 1106927, 824250, 1122995, 823836, 963179, 1224612, 936914, 825123, 981246, 823557, 955448, 963131, 891620, 1224588, 825069, 823536, 823662, 1226576, 820374, 959138, 825021, 825186, 1106930, 820140, 823755, 982325, 824757, 985727, 891710, 823956, 1224618, 825138, 1106912, 855186, 981249, 1226489, 855696, 824475, 956630, 855570, 1224663, 824277, 820167, 854925, 824646, 982346, 1359164, 891713, 823962, 1106915, 823728, 824544, 824709, 1224594, 1226405, 855699, 1168637, 824529, 820392, 963122, 891566, 825027, 855573, 824298, 854928, 823764, 957788, 963065, 891506, 823866, 1106918, 855651, 823620, 891941, 823740, 892073, 824721, 1224600, 825096, 823698, 819492, 963125, 825045, 956645, 1041482, 824361, 962960, 820338, 963080, 959132, 892097, 963191, 1106921, 855654, 1168298, 892076, 824751, 1168565, 1110179, 823701, 1168643, 982307, 891617, 824415, 933608, 1226573, 962966, 1122329, 1224870, 1193372, 1122335, 1190264, 1193123, 1224762, 1051865, 1122350, 1083977, 1120436, 1191749, 1351952, 1082693, 1082765, 1351424, 1221915, 1082891, 1186811, 1222740, 1191026, 1187831, 1350023, 1170932, 1361888, 1082255, 1082744, 1191191, 1120688, 1120448, 1224795, 1186499, 1221933, 1120739, 1081382, 1191200, 1083416, 1351841, 1123397, 1080836, 1178087, 1222128, 1191080, 1191548, 1084532, 1221936, 1191731, 1120634, 1170938, 1081391, 1084016, 1191800, 1082219, 1351808, 1221969, 1191770, 1083659, 1301705, 1351433, 1084538, 1122272, 1082900, 1184822, 1351415, 1222566, 1084022, 1221990, 1084004, 1123388, 1222779, 1082174, 1191152, 1083785, 1221777, 1083974, 1122275, 1082762, 1191632, 1084034, 1082531, 1084196, 1187828, 1081358, 1186553, 1191572, 1084007, 1080974, 1083791, 1080830, 1301717, 1221783, 1122278, 1084139, 1084514, 1224711, 1084037, 1082159, 1081373, 1186559, 1351838, 1191785, 1222185, 1191161, 1080833, 1082918, 1123367, 1084145, 1191755, 1191545, 1351427, 1084526, 1186817, 1191728, 1222743, 1187834, 1082162, 1350026, 1082852, 1084181, 1120691, 1222788, 1221846, 1120652, 1083965, 1122266, 1082897, 1104995, 1082756, 1351394, 1222560, 1080992, 1351853, 1221987, 1191182, 1120469, 1083968, 1221939, 1082759, 1191626, 1191809, 1120472, 1361414, 1221972, 1104980, 1082705, 1301708, 1351436, 1186487, 1191209, 1221912, 1191023, 1083410, 1351832, 1123391, 846789, 862941, 955925, 1395581, 947687, 1396373, 1396307, 1395584, 880526, 903800, 1355918, 1540058, 904184, 955505, 1356212, 1380563, 1396232, 903509, 1396292, 1395578, 1380776, 1396262, 1299029, 1395563, 1110647, 972344, 1359257, 1379081, 1359443, 1359284, 1359422, 1353713, 1379123, 1457717, 992267, 1353734, 847035, 864360, 865200, 846003, 956519, 1398650, 864231, 865446, 953357, 864711, 864453, 846954, 953360, 864714, 846918, 1400945, 847041, 887891, 955898, 846741, 864732, 1129829, 846720, 862908, 864537, 1395374, 864459, 1173401, 846906, 1394249, 862926, 902756, 846867, 1178402, 864120, 864582, 1383257, 870591, 776505, 858396, 1220126, 858042, 880343, 878921, 1176523, 1176460, 1384856, 1176526, 1384859, 1359254, 1391753, 1359305, 1269149, 1382468, 1382465, 1293305, 1121879, 1293296, 1122776, 1293410, 1293395, 1293380, 1297013, 1122890, 1297010, 1131047, 1297088, 970133, 753489, 753615, 1074110, 1190963, 753906, 753618, 754668, 753480, 753252, 753774, 753483, 753666, 754680, 1222524, 1221960, 1376048, 1359293, 1184564, 1222515, 1221945, 1222758, 1189946, 1221948, 1222764, 1376045, 1189841, 1221903, 1359296, 1184567, 1222521, 1373315, 1373318, 1355765, 1215545, 896915, 896561, 1335887, 1402868, 897668, 955952, 1396982, 1110698, 740301, 740376, 897287, 879194, 1353845, 1195868, 1353401, 1176400, 1353680, 1353683, 1191575, 753294, 1269815, 860907, 1107680, 860769, 1070405, 867243, 1340594, 860892, 1272803, 860724, 860772, 1122584, 860805, 1122737, 860895, 1070693, 865101, 860922, 860808, 860898, 1123067, 1070537, 1382144, 1107653, 860949, 1070309, 860925, 1070240, 860778, 1269737, 860763, 1108697, 1382147, 1107656, 860967, 822972, 1359110, 1070243, 823002, 1396202, 1193735, 1270793, 1070402, 867237, 1396118, 1070582, 1107659, 1193681, 822975, 1070684, 1032295, 1359704, 1359092, 1193288, 1199243, 1384799, 1221867, 1384649, 1295624, 1384727, 1383848, 1359314, 1222644, 1295651, 1384733, 1082345, 1384712, 1384763, 1359458, 1384688, 1379072, 1384658, 1384739, 1384790, 1359728, 1222152, 1193384, 1384841, 1082438, 1193357, 1081322, 1359767, 1359437, 1384769, 1383860, 1359089, 1114598, 1113878, 1379078, 1222737, 1081232, 1384748, 1359635, 1359749, 1221855, 1081331, 1114565, 1359116, 1359755, 1408487, 1384760, 1384835, 1384679, 1379069, 1384655, 1359719, 1359521, 1384838, 1383854, 1359425, 1221849, 1082360, 1384766, 1222266, 1359698, 1359086, 1408526, 1379075, 1222731, 1081220, 1384745, 1384793, 1359743, 1193390, 1193360, 1359440, 1384670, 1114433, 1082456, 1376840, 1222251, 1395290, 1222242, 1376843, 1082453, 846804, 1405142, 903212, 870414, 880184, 880415, 1209113, 1405136, 1076045, 870363, 1405139, 1404482, 776154, 1410162, 1410165, 776328, 1428602, 896756, 754629, 753723, 753903, 753894, 1180292, 868590, 817458, 868749, 1191275, 1121363, 1339391, 868548, 959966, 1191212, 1189739, 868791, 1190234, 1189829, 868989, 868635, 1190219, 1122353, 1224819, 1192931, 1679132, 868857, 1070222, 1039763, 869022, 1044011, 1121330, 868773, 1356863, 959897, 1679135, 1074626, 1191179, 817473, 1122332, 868956, 868566, 959993, 869025, 868806, 868998, 868641, 868776, 1039529, 868602, 1113812, 1053197, 868965, 868821, 1374899, 1217819, 868527, 1193018, 1190228, 1356923, 1021022, 868620, 817515, 868761, 1356845, 1224669, 1122338, 1021007, 1044809, 1180247, 869040, 1191257, 1044020, 959849, 1071032, 1192922, 869010, 1193093, 1373369, 1189826, 959888, 846630, 861999, 846912, 864585, 887456, 1040243, 864450, 887876, 1428518, 870594, 846951, 846711, 847038, 846738, 864237, 1437224, 862905, 1447571, 1359383, 864456, 846900, 862923, 953363, 864717, 846864, 955934, 864108, 864735, 864540, 1447775, 865434, 1359395, 847047, 864357, 864666, 865194, 846000, 1437218, 953354, 864708, 1211183, 1428650, 1455929, 1552241, 1527020, 1552205, 1476764, 858177, 1428638, 1465412, 1448459, 1449209, 881279, 850335, 861717, 819933, 850131, 1293416, 994187, 849630, 1293401, 1074137, 1293383, 849924, 861720, 1353371, 861291, 1353455, 1293404, 849975, 850368, 861429, 1074146, 1353374, 849675, 1105064, 849897, 850371, 1293389, 820203, 1105067, 1293299, 820107, 849879, 849615, 820410, 850350, 849684, 994454, 850332, 1293302, 850128, 1293413, 850353, 1393439, 892100, 891737, 1646183, 823626, 823953, 855630, 1032490, 963035, 824697, 1131050, 1227386, 855687, 1654721, 854940, 962969, 1646060, 823773, 963089, 1702028, 963197, 1646186, 1119533, 1399856, 892085, 855633, 1368863, 1133855, 1032463, 823539, 854943, 962972, 1646063, 963107, 1131032, 1119536, 962954, 963041, 1400012, 824772, 963185, 825147, 981267, 892166, 825093, 1032466, 823542, 1041497, 1227356, 1041476, 1227107, 963188, 825153, 1368869, 854907, 963140, 892169, 823938, 1213775, 824532, 982304, 1646069, 959156, 1119695, 1353362, 823623, 824247, 1368872, 854910, 891947, 1646078, 823950, 936908, 1032484, 1213778, 824535, 819501, 963128, 959162, 825066, 855579, 1227377, 855681, 1654718, 1646057, 823770, 1383974, 1211825, 1211828, 1211798, 1383971, 1211801, 1211822, 956522, 955937, 1445033, 1464125, 1352051, 858636, 776064, 1435697, 1355492, 1409306, 1470323, 1220096, 1263824, 1220099, 1263827
     )
    
) AS commit_data

ON commit_data.promotion_id1 = everything_except_commit.promotion_id
AND (commit_data.prod_hier_id_commit1 = everything_except_commit.ddi_prod_hier1
OR commit_data.commit_desc1 = everything_except_commit.description_from_tpm_commit)

AND (LEAST(everything_except_commit.extended_cost_norm_not_null, everything_except_commit.original_dispute_amount_not_null) <= (1.3 * commit_data.cal_planned_amount))


GROUP BY 

#SELECT DISTINCT 
#ded_deduction
everything_except_commit.pk_deduction_id,
everything_except_commit.original_dispute_amount,
everything_except_commit.cum_days_out_standing,
everything_except_commit.payer,
everything_except_commit.posting_date,
everything_except_commit.merge_status,

#display_text

everything_except_commit.cust_map_id_ded,
everything_except_commit.ded_display_text,

everything_except_commit.prom_customer_map_id1,
everything_except_commit.prom_display_text, 
everything_except_commit.display_text_count,


#dates
everything_except_commit.deduction_created_date,
everything_except_commit.customer_claim_date, 
everything_except_commit.invoice_date,
everything_except_commit.promortion_execution_from_date,
everything_except_commit.promotion_execution_to_date,
everything_except_commit.ship_start_date, 
everything_except_commit.ship_end_date, 
everything_except_commit.consumption_start_date, 
everything_except_commit.consumption_end_date,

#ddi
everything_except_commit.extended_cost_norm,      
everything_except_commit.unit_cost_norm,
everything_except_commit.deduction_item_quantity, 
everything_except_commit.status_code,
everything_except_commit.status_shortname,


#item_desc
everything_except_commit.ddi_prod_hier1, 
#everything_except_commit.ddi_lu_item_desc,

#everything_except_commit.lu_item_description,
#everything_except_commit.description_from_tpm_commit,
#MAX(everything_except_commit.item_desc_count),


#commit_data
commit_data.promotion_id1,
commit_data.commit_id1,
commit_data.planned_qty,
commit_data.paid_qty,
commit_data.variable_planned_amount, 
commit_data.fixed_planned_amount,
commit_data.fk_commit_payment_type_id, 
commit_data.payment_type_longname,
commit_data.promotion_type_id,
commit_data.promotion_type_longname

) AS temp


 