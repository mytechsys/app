SELECT 
    ldg.name AS ldg_name,                         -- Name of the Legislative Data Group (LDG)
    ldg.legislation_code,                         -- ISO Country code linked to the LDG (e.g., US, GB, IN)
    et.element_name AS base_element_name,         -- Official name of the Payroll Element
    et.processing_type AS recurring_flag,         -- Processing type: 'R' for Recurring, 'N' for Non-recurring
    ec.classification_name,                       -- Primary element classification (e.g., Earnings, Voluntary Deductions)
    iv.base_name,                                 -- Base (untranslated) technical name of the input value
    iv.name AS input_value_name,                  -- Localized name of the input value (e.g., Days Traveled)
    iv.display_sequence,                          -- UI rendering order sequence number (e.g., 20)
    --iv.special_purpose,                           -- Internal special purpose categorization tag (e.g., Days, Hours)
    iv.uom AS unit_of_measure,                    -- Unit of Measure code (e.g., 'M' = Money, 'N' = Number, 'C' = Character)
    iv.effective_start_date,                      -- Date from which this input value configuration is active
    iv.effective_end_date,                        -- Date until which this input value configuration is active
    iv.mandatory_flag AS required_flag,           -- Indicates if filling out this input value is mandatory ('Y'/'N')
    iv.default_value,                             -- Default value automatically populated during entry creation
    iv.hot_default_flag AS allow_user_entry_flag, -- Governs default entry override rules ('Y'/'N')
    iv.generate_db_items_flag AS create_db_item,   -- Indicates if Fast Formula Database Items are auto-generated ('Y'/'N')
    iv.USER_DISPLAY_FLAG  ,
    iv.USER_ENTERABLE_FLAG
FROM 
    pay_element_types_vl et,                      -- Secured public view for Element Types
    per_legislative_data_groups_vl ldg,           -- Secured public view for Legislative Data Groups
    pay_ele_classifications_vl ec,                -- Secured public view for Element Classifications
    pay_input_values_vl iv                        -- Secured public view for Input Values
WHERE 
    et.legislative_data_group_id = ldg.legislative_data_group_id(+) -- Outer join matching elements to their LDG
    AND et.classification_id = ec.classification_id               -- Joins elements to their structural classification
    AND et.element_type_id = iv.element_type_id                   -- Joins elements to their associated input values children
    -- AND et.element_name = 'Regular Salary'                     -- Optional filter: uncomment to target a specific element name
    -- AND iv.name = 'Days Traveled'                              -- Optional filter: uncomment to target a specific input value name
    AND TRUNC(SYSDATE) BETWEEN et.effective_start_date AND et.effective_end_date  -- Filters for currently active element definitions
    AND TRUNC(SYSDATE) BETWEEN iv.effective_start_date AND iv.effective_end_date -- Filters for currently active input value definitions

--------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    ldg.name AS ldg_name,                                    -- Name of the Legislative Data Group (LDG)
    ldg.legislation_code,                                    -- ISO Country code linked to the LDG (e.g., US, GB, IN)
    et.element_name AS base_element_name,                    -- Official name of the Payroll Element
    et.processing_type AS recurring_flag,                    -- Processing type: 'R' for Recurring, 'N' for Non-recurring
    ec.classification_name,                                  -- Primary element classification (e.g., Earnings, Voluntary Deductions)
    iv.base_name,                                            -- Base (untranslated) technical name of the input value
    iv.name AS input_value_name,                             -- Localized name of the input value (e.g., Days Traveled)
    iv.display_sequence,                                     -- UI rendering order sequence number (e.g., 20)
    iv.uom AS unit_of_measure,                               -- Unit of Measure code (e.g., 'M' = Money, 'N' = Number, 'C' = Character)
    
    -- === VALIDATION RULES & CONSTRAINTS ===
    iv.min_value,                                            -- Minimum allowed boundary value for entry
    iv.max_value,                                            -- Maximum allowed boundary value for entry
    iv.warning_or_error,                                     -- Behavior on failure ('WARNING' or 'ERROR')
    
    -- 1. Lookup Validation Details
    iv.lookup_type,                                          -- Oracle Lookup Type restriction code (drop-down list)
    lu.meaning AS lookup_type_meaning,                       -- Meaning/Name of the Lookup Type
    
    -- 2. Value Set Validation Details
    iv.value_set_code,                                       -- Unique code of the attached Value Set
    vs.description AS value_set_description,                 -- Description of the Value Set validation source
    vs.validation_type AS value_set_validation_type,         -- Type of Value Set validation (e.g., 'T' for Table-validated)
    
    -- 3. Fast Formula Validation Details
    iv.formula_id AS iv_validation_formula_id,               -- Fast Formula ID linked directly to the input value
    iv_ff.formula_name AS iv_validation_formula_name,        -- Name of the input-level validation Fast Formula
    et.formula_id AS element_validation_formula_id,          -- Fast Formula ID linked at the parent element level
    et_ff.formula_name AS element_validation_formula_name,   -- Name of the element-level formula

    iv.effective_start_date,                                 -- Date from which this input value configuration is active
    iv.effective_end_date,                                   -- Date until which this input value configuration is active
    iv.mandatory_flag AS required_flag,                      -- Indicates if filling out this input value is mandatory ('Y'/'N')
    iv.default_value,                                        -- Default value automatically populated during entry creation
    iv.hot_default_flag AS allow_user_entry_flag,            -- Governs default entry override rules ('Y'/'N')
    iv.generate_db_items_flag AS create_db_item,             -- Indicates if Fast Formula Database Items are auto-generated ('Y'/'N')
    iv.USER_DISPLAY_FLAG,
    iv.USER_ENTERABLE_FLAG                                  
FROM 
    pay_element_types_vl et,                                 -- Secured public view for Element Types
    per_legislative_data_groups_vl ldg,                      -- Secured public view for Legislative Data Groups
    pay_ele_classifications_vl ec,                           -- Secured public view for Element Classifications
    pay_input_values_vl iv,                                  -- Secured public view for Input Values
    fnd_lookups lu,                                          -- Lookup definitions table for lookup validations
    fnd_vs_value_sets vs,                                    -- Value sets table for dynamic drop-downs
    ff_formulas_vl iv_ff,                                    -- Fast Formulas for Input Value validations
    ff_formulas_vl et_ff                                     -- Fast Formulas for Element level rules
WHERE 
    et.legislative_data_group_id = ldg.legislative_data_group_id(+) -- Outer join matching elements to their LDG
    AND et.classification_id = ec.classification_id                 -- Joins elements to their structural classification
    AND et.element_type_id = iv.element_type_id                     -- Joins elements to their associated input values children
    
    -- Outer Joins for Lookups, Value Sets, and Formulas to prevent dropping rows missing configuration properties
    AND iv.lookup_type = lu.lookup_type(+)
    AND lu.lookup_type(+) IS NOT NULL                       -- Ensures safe outer join mapping for lookups
    AND iv.value_set_code = vs.value_set_code(+)
    AND iv.formula_id = iv_ff.formula_id(+)                        
    AND et.formula_id = et_ff.formula_id(+)                        

    -- Optional filters (uncomment if targeting a specific element or input value)
    -- AND et.element_name = 'Regular Salary'                    
    -- AND iv.name = 'Days Traveled'                             

    AND TRUNC(SYSDATE) BETWEEN et.effective_start_date AND et.effective_end_date -- Filters for currently active element definitions
    AND TRUNC(SYSDATE) BETWEEN iv.effective_start_date AND iv.effective_end_date -- Filters for currently active input value definitions


-----------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    ldg.name AS ldg_name,                                    -- Legislative Data Group (LDG) Name
    ldg.legislation_code,                                    -- ISO Country Code (e.g., US, GB, IN)
    et.element_name AS base_element_name,                    -- Official Payroll Element Name
    et.processing_type AS recurring_flag,                    -- 'R' for Recurring, 'N' for Non-recurring
    ec.classification_name,                                  -- Element Classification (e.g., Earnings)
    
    iv.base_name,                                            -- Base technical name of the input value
    iv.name AS input_value_name,                             -- Localized name of the input value
    iv.display_sequence,                                     -- UI rendering order sequence number
    iv.uom AS unit_of_measure,                               -- Unit of Measure ('M'=Money, 'N'=Number, 'C'=Character)
    
    -- === 1. INPUT-VALUE-LEVEL VALIDATION RULES ===
    iv.validation_source,                                    -- Validation method ('L'=Lookup, 'F'=Formula, 'U'=Value Set, etc.)
    iv.min_value,                                            -- Minimum allowed boundary value for this input
    iv.max_value,                                            -- Maximum allowed boundary value for this input
    iv.warning_or_error,                                     -- Failure handling behavior ('WARNING' or 'ERROR')
    
    -- Lookup Validation Details (Input-Level)
    iv.lookup_type,                                          -- Lookup Type restriction code
    lu.meaning AS lookup_type_meaning,                       -- Meaning/Description of the Lookup Type
    
    -- Value Set Validation Details (Input-Level)
    iv.value_set_code,                                       -- Unique code of the assigned Value Set
    vs.description AS value_set_description,                 -- Value Set description
    
    -- Fast Formula Validation Details (Input-Level)
    iv.formula_id AS input_validation_formula_id,            -- Fast Formula ID bound directly to the input value
    iv_ff.formula_name AS input_validation_formula_name,     -- Name of the input-level validation Fast Formula

    -- === 2. ELEMENT-LEVEL VALIDATION RULES ===
    et.formula_id AS element_validation_formula_id,          -- Fast Formula ID bound at the parent element level
    et_ff.formula_name AS element_validation_formula_name,   -- Name of the element-level formula

    -- === STANDARD INPUT ATTRIBUTES ===
    iv.effective_start_date,
    iv.effective_end_date,
    iv.mandatory_flag AS required_flag,                      -- Mandatory flag ('Y'/'N')
    iv.default_value,                                        -- Default value
    iv.hot_default_flag AS allow_user_entry_flag,            -- Allow override flag ('Y'/'N')
    iv.generate_db_items_flag AS create_db_item,
    iv.USER_DISPLAY_FLAG,
    iv.USER_ENTERABLE_FLAG
FROM 
    pay_element_types_vl et,                                 -- Element Types view
    per_legislative_data_groups_vl ldg,                      -- Legislative Data Groups view
    pay_ele_classifications_vl ec,                           -- Element Classifications view
    pay_input_values_vl iv,                                  -- Input Values view
    fnd_lookups lu,                                          -- Lookup definitions table
    fnd_vs_value_sets vs,                                    -- Value Sets table
    ff_formulas_vl iv_ff,                                    -- Fast Formulas for Input Values
    ff_formulas_vl et_ff                                     -- Fast Formulas for Elements
WHERE 
    et.legislative_data_group_id = ldg.legislative_data_group_id(+) 
    AND et.classification_id = ec.classification_id                 
    AND et.element_type_id = iv.element_type_id                     
    
    -- Safe Outer Joins for Lookups, Value Sets, and Validation Formulas
    AND iv.lookup_type = lu.lookup_type(+)
    AND iv.value_set_code = vs.value_set_code(+)
    AND iv.formula_id = iv_ff.formula_id(+)                        
    AND et.formula_id = et_ff.formula_id(+)                        

    -- Optional filters (uncomment to target a specific element or input value)
    -- AND et.element_name = 'Regular Salary'                    
    -- AND iv.name = 'Days Traveled'                             

    AND TRUNC(SYSDATE) BETWEEN et.effective_start_date AND et.effective_end_date 
    AND TRUNC(SYSDATE) BETWEEN iv.effective_start_date AND iv.effective_end_date
