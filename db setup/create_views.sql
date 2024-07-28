DROP VIEW IF EXISTS memoria_list CASCADE;
CREATE OR REPLACE VIEW memoria_list AS
    SELECT 
        u_mem.unique_id, 
        mem.card_mst_id, 
        u_mem.en_name AS "name", 
        mem.rarity, mem.card_type, 
        mem.attribute, 
        quest_sk.en_name AS "quest_sk", 
        quest_sk.en_description AS "quest_desc", 
        gvg_sk.en_name AS "gvg_sk", 
        gvg_sk.en_description AS "gvg_desc", 
        auto_sk.en_name AS "auto_sk", 
        auto_sk.en_description AS "support_desc", 
        mem.max_phys_atk, 
        mem.max_phys_def, 
        mem.max_mag_atk, 
        mem.max_mag_def
    FROM memoria mem 
    INNER JOIN unique_memoria u_mem ON mem.unique_id = u_mem.unique_id
    INNER JOIN skills quest_sk ON quest_sk.skill_mst_id = mem.quest_skill_mst_id
    INNER JOIN skills gvg_sk ON gvg_sk.skill_mst_id = mem.gvg_skill_mst_id
    INNER JOIN skills auto_sk ON auto_sk.skill_mst_id = mem.gvg_auto_skill_mst_id;

-- Gets only the evolved form of memoria
DROP VIEW IF EXISTS evolved_memoria_list CASCADE;
CREATE OR REPLACE VIEW evolved_memoria_list AS
    SELECT 
        DISTINCT ON (u_mem.unique_id)
        u_mem.unique_id,
        mem.card_mst_id, 
        mem.rarity, 
        mem.card_type, 
        mem.attribute, 
        mem.quest_skill_mst_id, 
        mem.gvg_skill_mst_id, 
        mem.gvg_auto_skill_mst_id, 
        mem.max_phys_atk, 
        mem.max_phys_def, 
        mem.max_mag_atk, 
        mem.max_mag_def,
        FALSE AS "awakened",
        FALSE AS "super_awakened"
    FROM memoria mem 
    INNER JOIN unique_memoria u_mem ON mem.unique_id = u_mem.unique_id
    ORDER BY u_mem.unique_id, mem.rarity DESC, mem.card_mst_id;

-- TODO: Create a new view to get all awakened memoria (awakened and super awakened) to union with evolved memo list

-- View to get all normal evolved awakened memoria
-- TODO: UNION with the list of awakened default skill of memoria
DROP VIEW IF EXISTS awakened_memoria_list CASCADE;
CREATE OR REPLACE VIEW awakened_memoria_list AS
    SELECT 
        DISTINCT ON (u_mem.unique_id) u_mem.unique_id,
        mem.card_mst_id, 
        mem.rarity, 
        mem.awakened_card_type AS "card_type", 
        mem.attribute, 
        mem.quest_skill_mst_id, 
        mem.gvg_skill_mst_id, 
        mem.gvg_auto_skill_mst_id, 
        mem.max_phys_atk + mem.awaken_add_phys_atk AS "max_phys_atk", 
        mem.max_phys_def + mem.awaken_add_phys_def AS "max_phys_def", 
        mem.max_mag_atk + mem.awaken_add_mag_atk AS "max_mag_atk", 
        mem.max_mag_def + mem.awaken_add_mag_def  AS "max_mag_def",
        TRUE AS "awakened",
        FALSE AS "super_awakened"
    FROM memoria mem 
    INNER JOIN unique_memoria u_mem ON mem.unique_id = u_mem.unique_id
    WHERE mem.awakened_card_type != 0
    ORDER BY u_mem.unique_id, mem.rarity DESC, mem.card_mst_id;

-- View to get all evolved super awakened memoria
DROP VIEW IF EXISTS super_awakened_memoria_list CASCADE;
CREATE OR REPLACE VIEW super_awakened_memoria_list AS
    SELECT 
        u_mem.unique_id,
        mem.card_mst_id, 
        mem.rarity, 
        mem.awakened_card_type AS "card_type", 
        mem.attribute, 
        mem.quest_skill_mst_id, 
        mem.gvg_skill_mst_id, 
        mem.gvg_auto_skill_mst_id, 
        mem.max_phys_atk + mem.awaken_add_phys_atk AS "max_phys_atk", 
        mem.max_phys_def + mem.awaken_add_phys_def AS "max_phys_def", 
        mem.max_mag_atk + mem.awaken_add_mag_atk AS "max_mag_atk", 
        mem.max_mag_def + mem.awaken_add_mag_def  AS "max_mag_def",
        TRUE AS "awakened",
        TRUE AS "super_awakened"
    FROM memoria mem 
    INNER JOIN unique_memoria u_mem ON mem.unique_id = u_mem.unique_id
    INNER JOIN super_awakened_memoria awk_mem ON awk_mem.card_mst_id = mem.card_mst_id;

-- Union of all evolved, awakened/super awakened memoria with translations
DROP VIEW IF EXISTS combined_memoria_list CASCADE;
CREATE OR REPLACE VIEW combined_memoria_list AS
    SELECT
        ROW_NUMBER() OVER () AS "row",
        merged.*,
        quest_sk.en_name AS "quest_en_name",
        quest_sk.en_description AS "quest_en_desc",
        gvg_sk.en_name AS "gvg_en_name",
        gvg_sk.en_description AS "gvg_en_desc",
        auto_sk.en_name AS "auto_en_name",
        auto_sk.en_description AS "auto_en_desc",
        quest_sk.jp_name AS "quest_jp_name",
        quest_sk.jp_description AS "quest_jp_desc",
        gvg_sk.jp_name AS "gvg_jp_name",
        gvg_sk.jp_description AS "gvg_jp_desc",
        auto_sk.jp_name AS "auto_jp_name",
        auto_sk.jp_description AS "auto_jp_desc",
        quest_sk.cn_name AS "quest_cn_name",
        quest_sk.cn_description AS "quest_cn_desc",
        gvg_sk.cn_name AS "gvg_cn_name",
        gvg_sk.cn_description AS "gvg_cn_desc",
        auto_sk.cn_name AS "auto_cn_name",
        auto_sk.cn_description AS "auto_cn_desc",
        quest_sk.kr_name AS "quest_kr_name",
        quest_sk.kr_description AS "quest_kr_desc",
        gvg_sk.kr_name AS "gvg_kr_name",
        gvg_sk.kr_description AS "gvg_kr_desc",
        auto_sk.kr_name AS "auto_kr_name",
        auto_sk.kr_description AS "auto_kr_desc",
        quest_sk.tw_name AS "quest_tw_name",
        quest_sk.tw_description AS "quest_tw_desc",
        gvg_sk.tw_name AS "gvg_tw_name",
        gvg_sk.tw_description AS "gvg_tw_desc",
        auto_sk.tw_name AS "auto_tw_name",
        auto_sk.tw_description AS "auto_tw_desc"
    FROM
    (
        SELECT 
            evo_mem.*
        FROM evolved_memoria_list evo_mem
    UNION
        SELECT 
            awk_mem.*
        FROM awakened_memoria_list awk_mem
    UNION
        SELECT 
            super_mem.*
        FROM super_awakened_memoria_list super_mem
    ) merged
    INNER JOIN skills quest_sk ON  quest_sk.skill_mst_id = merged.quest_skill_mst_id
    INNER JOIN skills gvg_sk ON  gvg_sk.skill_mst_id = merged.gvg_skill_mst_id
    INNER JOIN skills auto_sk ON  auto_sk.skill_mst_id = merged.gvg_auto_skill_mst_id;
    

DROP VIEW IF EXISTS gvg_support_magnification;
CREATE OR REPLACE VIEW gvg_support_magnification AS
    SELECT 
        gvg_sk.skill_mst_id,
        gvg_sk.BUFFER_MAGICAL_ATTACK_MAGNIFICATION,
        gvg_sk.BUFFER_MAGICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.BUFFER_PHYSICAL_ATTACK_MAGNIFICATION,
        gvg_sk.BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION,
        gvg_sk.DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION,
        gvg_sk.DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.ATTACK_UP_MAGNIFICATION,
        gvg_sk.BUFFER_UP_MAGNIFICATION,
        gvg_sk.RECOVERY_UP_MAGNIFICATION,
        gvg_sk.USE_SP_REDUCE_MAGNIFICATION
    FROM skills gvg_sk;

DROP VIEW IF EXISTS gvg_magnification;
CREATE OR REPLACE VIEW gvg_magnification AS
    SELECT 
        mem.unique_id,
        gvg_sk.skill_mst_id,
        gvg_sk.ATTACK_MAGNIFICATION,
        gvg_sk.BUFFER_MAGICAL_ATTACK_MAGNIFICATION,
        gvg_sk.BUFFER_MAGICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.BUFFER_PHYSICAL_ATTACK_MAGNIFICATION,
        gvg_sk.BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION,
        gvg_sk.DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION,
        gvg_sk.DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION,
        gvg_sk.RECOVERY_MAGNIFICATION
    FROM skills gvg_sk
    INNER JOIN memoria mem ON mem.gvg_skill_mst_id = gvg_sk.skill_mst_id
    INNER JOIN unique_memoria u_mem ON u_mem.unique_id = mem.unique_id;