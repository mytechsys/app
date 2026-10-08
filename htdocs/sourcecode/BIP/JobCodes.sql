SELECT 
    pj.job_id,
    pj.job_code,
    pj.name                         AS job_name,
    pj.active_status,
    pj.effective_start_date,
    pj.effective_end_date,
    pj.set_id                       AS set_id
FROM per_jobs_f_vl pj
WHERE TRUNC(SYSDATE) BETWEEN pj.effective_start_date AND pj.effective_end_date
  AND pj.active_status = 'A'
ORDER BY pj.job_code