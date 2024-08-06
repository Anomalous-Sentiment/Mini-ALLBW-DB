/*
1-8 are gvg main skills
1001 - 1008 are story/quest skills
2001 - 2002 seem to be gvg support?
2001 are general support skills
2002 are vanguard only support skills
*/

INSERT INTO skill_types (skill_type, skill_type_desc)
VALUES
    (1, 'Pure Damage'),
    (2, 'Pure Heal'),
    (3, 'Increase Max HP'),
    (4, 'Pure Debuff'),
    (5, 'Damage + Heal'),
    (6, 'Damage + Buff'),
    (7, 'Damage + Debuff'),
    (8, 'Heal + Buff')
ON CONFLICT (skill_type) DO 
    UPDATE SET 
        skill_type_desc = EXCLUDED.skill_type_desc;

INSERT INTO card_types (card_type, card_type_name)
VALUES
    (1, 'Regular Unit Attack'),
    (2, 'Regular Ranged Attack'),
    (3, 'Special Unit Attack'),
    (4, 'Special Ranged Attack'),
    (7, 'Healing'),
    (6, 'Obstruction'),
    (5, 'Assistance')
ON CONFLICT (card_type) DO 
    UPDATE SET 
        card_type_name = EXCLUDED.card_type;