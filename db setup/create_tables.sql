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
    PRIMARY KEY (card_mst_id)
);

DROP TABLE IF EXISTS skills;
CREATE TABLE skills
(
    skill_mst_id INT,
    jp_name VARCHAR(20),
    en_name VARCHAR(20),
    cn_name VARCHAR(20),
    kr_name VARCHAR(20),
    tw_name VARCHAR(20),
    jp_description VARCHAR(50),
    en_description VARCHAR(50),
    cn_description VARCHAR(50),
    kr_description VARCHAR(50),
    tw_description VARCHAR(50),
    sp SMALLINT,
    min_range SMALLINT,
    max_range SMALLINT,
    skill_type SMALLINT,
    effect_time SMALLINT,
    PRIMARY KEY (skill_mst_id)
);