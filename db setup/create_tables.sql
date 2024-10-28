DROP TABLE IF EXISTS unique_memoria;
CREATE TABLE unique_memoria
(
    unique_id INT,
    jp_name VARCHAR(100),
    en_name VARCHAR(100),
    cn_name VARCHAR(100),
    kr_name VARCHAR(100),
    tw_name VARCHAR(100),
    PRIMARY KEY (unique_id)
);

DROP TABLE IF EXISTS memoria;
CREATE TABLE memoria
(
    card_mst_id INT,
    unique_id INT,
    card_type SMALLINT,
    rarity SMALLINT,
    attribute SMALLINT,
    quest_skill_mst_id INT,
    gvg_skill_mst_id INT,
    gvg_auto_skill_mst_id INT,
    limit_break_bonus_mst_id INT,
    base_phys_atk INT,
    base_phys_def INT,
    base_mag_atk INT,
    base_mag_def INT,
    max_phys_atk INT,
    max_phys_def INT,
    max_mag_atk INT,
    max_mag_def INT,
    deck_cost SMALLINT,
    is_emoria BOOLEAN,
    awakened_card_type INT,
    awaken_add_phys_atk INT,
    awaken_add_mag_atk INT,
    awaken_add_phys_def INT,
    awaken_add_mag_def INT,
    awaken_quest_skill_mst_id INT,
    awaken_gvg_skill_mst_id INT,
    awaken_gvg_auto_skill_mst_id INT,
    new_awaken_quest_skill_mst_id INT,
    new_awaken_gvg_skill_mst_id INT,
    new_awaken_gvg_auto_skill_mst_id INT,
    PRIMARY KEY (card_mst_id)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders
(
    tactic_mst_id INT,
    unique_id INT,
    rarity SMALLINT,
    tactic_name VARCHAR,
    tactic_desc VARCHAR,
    quest_skill_mst_id INT,
    gvg_skill_mst_id INT,
    limit_break_bonus_mst_id INT,
    base_phys_atk INT,
    base_phys_def INT,
    base_mag_atk INT,
    base_mag_def INT,
    max_phys_atk INT,
    max_phys_def INT,
    max_mag_atk INT,
    max_mag_def INT,
    PRIMARY KEY (tactic_mst_id)
);

DROP TABLE IF EXISTS skills;
CREATE TABLE skills
(
    skill_mst_id INT,
    jp_name VARCHAR,
    en_name VARCHAR,
    cn_name VARCHAR,
    kr_name VARCHAR,
    tw_name VARCHAR,
    jp_description VARCHAR,
    en_description VARCHAR,
    cn_description VARCHAR,
    kr_description VARCHAR,
    tw_description VARCHAR,
    sp SMALLINT,
    min_range SMALLINT,
    max_range SMALLINT,
    skill_type SMALLINT,
    effect_time SMALLINT,
    /* Note: all column names are automatically converted to lowercase in practice. 
    It has been left in ALL CAPS here purely for copy & paste convenience */
    ATTACK_TYPE SMALLINT,
    TARGET_NUM_MIN SMALLINT,
    TARGET_NUM_MAX SMALLINT,
    ATTACK_MAGNIFICATION REAL,
    ATTACK_UP_MAGNIFICATION REAL,
    BUFFER_MAGICAL_ATTACK_MAGNIFICATION REAL,
    BUFFER_MAGICAL_DEFENSE_MAGNIFICATION REAL,
    BUFFER_PHYSICAL_ATTACK_MAGNIFICATION REAL,
    BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION REAL,
    DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION REAL,
    DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION REAL,
    DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION REAL,
    DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION REAL,
    RECOVERY_MAGNIFICATION REAL,
    /* BUFFER_UP_MAGNIFICATION is for both buffs and debuffs */
    BUFFER_UP_MAGNIFICATION REAL,
    RECOVERY_UP_MAGNIFICATION REAL,
    USE_SP_REDUCE_MAGNIFICATION REAL,
    json_params JSONB,
    PRIMARY KEY (skill_mst_id)
);

DROP TABLE IF EXISTS super_awakened_memoria;
CREATE TABLE super_awakened_memoria
(
    card_mst_id INT,
    card_type SMALLINT,
    quest_skill_mst_id INT,
    gvg_skill_mst_id INT,
    gvg_auto_skill_mst_id INT,
    limit_break_bonus_mst_id INT,
    base_phys_atk INT,
    base_phys_def INT,
    base_mag_atk INT,
    base_mag_def INT,
    max_phys_atk INT,
    max_phys_def INT,
    max_mag_atk INT,
    max_mag_def INT,  
    PRIMARY KEY (card_mst_id, card_type)
);


-- DROP TABLE IF EXISTS skill_types;
-- CREATE TABLE skill_types
-- (
--     skill_type SMALLINT,
--     skill_type_desc VARCHAR,    
--     PRIMARY KEY (skill_type)
-- );


-- DROP TABLE IF EXISTS card_types;
-- CREATE TABLE card_types
-- (
--     card_type SMALLINT,
--     card_type_name VARCHAR,    
--     PRIMARY KEY (card_type)
-- );
