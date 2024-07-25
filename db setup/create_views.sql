DROP VIEW IF EXISTS memoria_list;
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
        mem.max_mag_def,
    FROM memoria mem 
    INNER JOIN unique_memoria u_mem ON mem.unique_id = u_mem.unique_id
    INNER JOIN skills quest_sk ON quest_sk.skill_mst_id = mem.quest_skill_mst_id
    INNER JOIN skills gvg_sk ON gvg_sk.skill_mst_id = mem.gvg_skill_mst_id
    INNER JOIN skills auto_sk ON auto_sk.skill_mst_id = mem.gvg_auto_skill_mst_id;

DROP VIEW IF EXISTS gvg_magnification;
CREATE OR REPLACE VIEW gvg_magnification AS
    SELECT 
        gvg_sk.skill_mst_id,
        gvg_sk.ATTACK_MAGNIFICATION AS "atk_mag",
        gvg_sk.BUFFER_MAGICAL_ATTACK_MAGNIFICATION AS "matk_buff_mag",
        gvg_sk.BUFFER_MAGICAL_DEFENSE_MAGNIFICATION AS "mdef_buff_mag",
        gvg_sk.BUFFER_PHYSICAL_ATTACK_MAGNIFICATION AS "patk_buff_mag",
        gvg_sk.BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION AS "pdef_buff_mag",
        gvg_sk.DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION AS "matk_debuff_mag",
        gvg_sk.DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION AS "mdef_debuff_mag",
        gvg_sk.DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION AS "patk_debuff_mag",
        gvg_sk.DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION AS "pdef_debuff_mag",
        gvg_sk.RECOVERY_MAGNIFICATION AS "heal_mag"
    FROM skills gvg_sk;

DROP VIEW IF EXISTS gvg_support_magnification;
CREATE OR REPLACE VIEW gvg_support_magnification AS
    SELECT 
        gvg_sk.skill_mst_id,
        gvg_sk.BUFFER_MAGICAL_ATTACK_MAGNIFICATION AS "matk_buff_mag",
        gvg_sk.BUFFER_MAGICAL_DEFENSE_MAGNIFICATION AS "mdef_buff_mag",
        gvg_sk.BUFFER_PHYSICAL_ATTACK_MAGNIFICATION AS "patk_buff_mag",
        gvg_sk.BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION AS "pdef_buff_mag",
        gvg_sk.DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION AS "matk_debuff_mag",
        gvg_sk.DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION AS "mdef_debuff_mag",
        gvg_sk.DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION AS "patk_debuff_mag",
        gvg_sk.DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION AS "pdef_debuff_mag",
        gvg_sk.ATTACK_UP_MAGNIFICATION AS "atk_up_mag",
        gvg_sk.BUFFER_UP_MAGNIFICATION AS "supp_up_mag",
        gvg_sk.RECOVERY_UP_MAGNIFICATION AS "heal_up_mag",
        gvg_sk.USE_SP_REDUCE_MAGNIFICATION AS "sp_reduce_mag"
    FROM skills gvg_sk;