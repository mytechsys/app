SELECT 
    papf.person_number,
    ppnf.full_name AS person_name,
    paam.assignment_number,
    ppg.group_name AS people_group_name
FROM 
    per_all_people_f papf,
    per_person_names_f ppnf,
    per_all_assignments_m paam,
    pay_people_groups ppg
WHERE 
    papf.person_id = ppnf.person_id
    AND papf.person_id = paam.person_id
    AND paam.people_group_id = ppg.people_group_id (+)
    -- Ensure Global Name type is fetched
    AND ppnf.name_type = 'GLOBAL'
    -- Date effective filters for current snapshot
    AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
    AND TRUNC(SYSDATE) BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
    AND TRUNC(SYSDATE) BETWEEN paam.effective_start_date AND paam.effective_end_date
    -- Restrict to current latest changes and primary assignments
    AND paam.effective_latest_change = 'Y'
    AND paam.primary_flag = 'Y'
    -- Flexible parameter filter (handles wildcards like %Group% if entered, or pulls all if empty)
    AND (
         (:p_people_group_name IS NULL) 
         OR (UPPER(ppg.group_name) LIKE UPPER('%' || :p_people_group_name || '%'))
        )
ORDER BY 
    papf.person_number
