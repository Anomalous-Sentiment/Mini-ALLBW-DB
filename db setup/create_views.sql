DROP VIEW IF EXISTS memoria_skills;
CREATE OR REPLACE VIEW memoria_skills AS
    SELECT u_mem.en_name, mem.rarity, quest_sk.en_name AS "HUGE Skill", quest_sk.en_description AS "quest_desc", gvg_sk.en_name AS "Legion Skill", gvg_sk.en_description AS "gvg_desc", auto_sk.en_name AS "Support Skill", auto_sk.en_description AS "support_desc"
    FROM memoria mem 
    INNER JOIN unique_memoria u_mem ON mem.unique_id = u_mem.unique_id
    INNER JOIN skills quest_sk ON quest_sk.skill_mst_id = mem.quest_skill_mst_id
    INNER JOIN skills gvg_sk ON gvg_sk.skill_mst_id = mem.gvg_skill_mst_id
    INNER JOIN skills auto_sk ON auto_sk.skill_mst_id = mem.gvg_auto_skill_mst_id;