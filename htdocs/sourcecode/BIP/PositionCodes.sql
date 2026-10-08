SELECT 
    hap.position_id,
    hap.position_code,
    hap.name                         AS position_name,
    hap.active_status,
    pj.job_code,
    pj.name                         AS job_name,
    bu.name                         AS business_unit_name,
    hap.effective_start_date,
    hap.effective_end_date
FROM hr_all_positions_f_vl hap
LEFT JOIN per_jobs_f_vl pj
    ON  pj.job_id = hap.job_id
    AND TRUNC(SYSDATE) BETWEEN pj.effective_start_date AND pj.effective_end_date
LEFT JOIN hr_all_organization_units_f_vl bu
    ON  bu.organization_id = hap.business_unit_id
    AND TRUNC(SYSDATE) BETWEEN bu.effective_start_date AND bu.effective_end_date
WHERE TRUNC(SYSDATE) BETWEEN hap.effective_start_date AND hap.effective_end_date
  AND hap.active_status = 'A'
ORDER BY hap.position_code