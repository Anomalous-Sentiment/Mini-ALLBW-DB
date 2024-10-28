import json
import csv
from tkinter import Tk     # from tkinter import Tk for Python 3.x
from tkinter.filedialog import askdirectory
from pathlib import Path
from pprint import pprint

import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_KEY")
print(url)
print(key)
supabase: Client = create_client(url, key)

def get_directory(prompt):
    Tk().withdraw() # we don't want a full GUI, so keep the root window from appearing
    target_dir = askdirectory(title=prompt) # show an "Open" dialog box and return the path to the selected file
    if target_dir != "" and target_dir != None:
        target_dir = Path(target_dir)
    return target_dir

def get_translation_dict(target_dir, code):
    translation_dict = {}
    # Open TWLangR Folder and get the directory of the target langauge by joining code (EN, CN, JP, KR, etc)
    csv_file = target_dir.joinpath(code).joinpath('serverCSV.csv')

    # Open EN, CN, or KR translation csv files and convert to dict with JP text as key
    with open(csv_file, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=['jp_text', 'translated_text'])
        for row in reader:
            translation_dict[row['jp_text']] = row['translated_text']
    return translation_dict

# Function to read mst json file
def read_json(target_dir, filename):
    mst_list = []
    json_file = target_dir.joinpath(filename)
    with open(json_file, 'r', encoding='utf-8') as f:
        mst_list = json.load(f)["mstList"]
    return mst_list

def parse_card_mst_list(target_dir, filename):
    parsed_card_list = []
    # Get the card mst list
    card_list = read_json(target_dir, filename)

    # iterate through and convert to format suitable for inserting in DB
    for card in card_list:
        new_row = {}
        new_row['name'] = card['name']
        new_row['card_mst_id'] = card['cardMstId']
        new_row['unique_id'] = card['uniqueId']
        new_row['card_type'] = card['cardType']
        new_row['rarity'] = card['rarity']
        new_row['attribute'] = card['attribute']
        new_row['quest_skill_mst_id'] = card['questSkillMstId']
        new_row['gvg_skill_mst_id'] = card['gvgSkillMstId']
        new_row['gvg_auto_skill_mst_id'] = card['gvgAutoSkillMstId']
        new_row['limit_break_bonus_mst_id'] = card['limitBreakBonusMstId']
        new_row['base_phys_atk'] = card['basePhysicalAttack']
        new_row['base_phys_def'] = card['basePhysicalDefense']
        new_row['base_mag_atk'] = card['baseMagicalAttack']
        new_row['base_mag_def'] = card['baseMagicalDefense']
        new_row['max_phys_atk'] = card['maxPhysicalAttack']
        new_row['max_phys_def'] = card['maxPhysicalDefense']
        new_row['max_mag_atk'] = card['maxMagicalAttack']
        new_row['max_mag_def'] = card['maxMagicalDefense']
        new_row['deck_cost'] = card['deckCost']
        new_row['is_emoria'] = card['isEmoria']

        # New awakened type
        new_row['awakened_card_type'] = card['awakenedAddCardType']

        # Awakening stats
        new_row['awaken_add_phys_atk'] = card['awakenedAddPhysicalAttack']
        new_row['awaken_add_mag_atk'] = card['awakenedAddMagicalAttack']
        new_row['awaken_add_phys_def'] = card['awakenedAddPhysicalDefense']
        new_row['awaken_add_mag_def'] = card['awakenedAddMagicalDefense']

        # Enhanced base skill from awakening
        new_row['awaken_quest_skill_mst_id'] = card['awakenedQuestSkillMstId']
        new_row['awaken_gvg_skill_mst_id'] = card['awakenedGvgSkillMstId']
        new_row['awaken_gvg_auto_skill_mst_id'] = card['awakenedGvgAutoSkillMstId']

        # Newly added skill from awakening
        new_row['new_awaken_quest_skill_mst_id'] = card['awakenedAddQuestSkillMstId']
        new_row['new_awaken_gvg_skill_mst_id'] = card['awakenedAddGvgSkillMstId']
        new_row['new_awaken_gvg_auto_skill_mst_id'] = card['awakenedAddGvgAutoSkillMstId']


        parsed_card_list.append(new_row)

    return parsed_card_list

# def parse_skill_mst_list(target_dir):
#     parsed_skill_list = []
#     return parsed_skill_list

def batch(iterable, n=1):
    l = len(iterable)
    for ndx in range(0, l, n):
        yield iterable[ndx:min(ndx + n, l)]

def upsert_into_table(table_name, rows):
    response = None
    for x in batch(rows, 3000):
        response = (
            supabase.table(table_name)
            .upsert(x)
            .execute()
        )
    return response

def parse_order_mst_list(target_dir, filename, dict_of_dicts):
    parsed_order_list = []
    # Get the card mst list
    order_list = read_json(target_dir, filename)
    for order in order_list:

        new_row = {}
        new_row['tactic_mst_id'] = order['tacticsMstId']

        new_row['en_tactic_name'] = dict_of_dicts['EN'].get(order['name'])
        new_row['jp_tactic_name'] = order['name']
        new_row['cn_tactic_name'] = dict_of_dicts['CN'].get(order['name'])
        new_row['kr_tactic_name'] = dict_of_dicts['KR'].get(order['name'])
        new_row['tw_tactic_name'] = dict_of_dicts['TW'].get(order['name'])

        new_row['en_tactic_desc'] = dict_of_dicts['EN'].get(order['description'])
        new_row['jp_tactic_desc'] = order['description']
        new_row['cn_tactic_desc'] = dict_of_dicts['CN'].get(order['description'])
        new_row['kr_tactic_desc'] = dict_of_dicts['KR'].get(order['description'])
        new_row['tw_tactic_desc'] = dict_of_dicts['TW'].get(order['description'])

        new_row['unique_id'] = order['uniqueId']
        new_row['rarity'] = order['rarity']
        new_row['limit_break_bonus_mst_id'] = order['limitBreakBonusMstId']
        new_row['quest_tactic_effect_mst_id'] = order['questTacticsEffectMstId']
        new_row['gvg_tactic_effect_mst_id'] = order['gvgTacticsEffectMstId']
        new_row['base_phys_atk'] = order['basePhysicalAttack']
        new_row['base_mag_atk'] = order['baseMagicalAttack']
        new_row['base_phys_def'] = order['basePhysicalDefense']
        new_row['base_mag_def'] = order['baseMagicalDefense']
        new_row['max_phys_atk'] = order['maxPhysicalAttack']
        new_row['max_mag_atk'] = order['maxMagicalAttack']
        new_row['max_phys_def'] = order['maxPhysicalDefense']
        new_row['max_mag_def'] = order['maxMagicalDefense']

        parsed_order_list.append(new_row)
    return parsed_order_list

def parse_order_effects_mst_list(target_dir, filename, dict_of_dicts):
    parsed_order_effects_list = []
    # Get the card mst list
    order_list = read_json(target_dir, filename)
    for order in order_list:
        new_row = {}
        new_row['tactic_effect_mst_id'] = order['tacticsEffectMstId']

        new_row['en_effect_name'] = dict_of_dicts['EN'].get(order['name'])
        new_row['jp_effect_name'] = order['name']
        new_row['cn_effect_name'] = dict_of_dicts['CN'].get(order['name'])
        new_row['kr_effect_name'] = dict_of_dicts['KR'].get(order['name'])
        new_row['tw_effect_name'] = dict_of_dicts['TW'].get(order['name'])

        new_row['en_effect_desc'] = dict_of_dicts['EN'].get(order['description'])
        new_row['jp_effect_desc'] = order['description']
        new_row['cn_effect_desc'] = dict_of_dicts['CN'].get(order['description'])
        new_row['kr_effect_desc'] = dict_of_dicts['KR'].get(order['description'])
        new_row['tw_effect_desc'] = dict_of_dicts['TW'].get(order['description'])

        new_row['sp'] = order['sp']
        new_row['tactic_type'] = order['type']
        new_row['effect_group'] = order['group']
        new_row['preparation_time'] = order['preparationTime']
        new_row['effect_time'] = order['effectTime']
        new_row['duration_effect_type'] = order['durationEffectType']
        new_row['duration_effect_type_1'] = order['executeEffectType1']
        new_row['duration_effect_type_2'] = order['executeEffectType2']
        new_row['duration_effect_type_3'] = order['executeEffectType3']
        new_row['execute_effect_target'] = order['executeEffectTarget']
        new_row['execute_effect_variable'] = order['executeEffectVariable']


        if order['parameterText']:
            # Get the parameters json if it exists
            parameter_text_json = json.loads(order['parameterText'])
        else:
            parameter_text_json = {}

        new_row['json_params'] = parameter_text_json

        parsed_order_effects_list.append(new_row)
    return parsed_order_effects_list

def parse_skill_mst_list(target_dir, filename, dict_of_dicts):
    parsed_skill_list = []
    # Get the card mst list
    skill_list = read_json(target_dir, filename)

    # keys = []
    for skill in skill_list:
        # convert parameterText string to json and get all keys
        parameter_text_json = json.loads(skill['parameterText'])
        # get_keys(parameter_text_json, keys)
        # TARGET_NUM can be either an int, or a json with min and max keys

        new_row = {}
        new_row['skill_mst_id'] = skill['skillMstId']
        new_row['jp_name'] = skill['name']
        new_row['en_name'] = dict_of_dicts['EN'].get(skill['name'])
        new_row['cn_name'] = dict_of_dicts['CN'].get(skill['name'])
        new_row['kr_name'] = dict_of_dicts['KR'].get(skill['name'])
        new_row['tw_name'] = dict_of_dicts['TW'].get(skill['name'])
        new_row['jp_description'] = skill['description']
        new_row['en_description'] = dict_of_dicts['EN'].get(skill['description'])
        new_row['cn_description'] = dict_of_dicts['CN'].get(skill['description'])
        new_row['kr_description'] = dict_of_dicts['KR'].get(skill['description'])
        new_row['tw_description'] = dict_of_dicts['TW'].get(skill['description'])
        new_row['sp'] = skill['sp']
        new_row['min_range'] = skill['rangeMinIcon']
        new_row['max_range'] = skill['rangeMaxIcon']
        new_row['skill_type'] = skill['type']
        new_row['effect_time'] = skill['effectTime']

        new_row['attack_type'] = parameter_text_json.get('ATTACK_TYPE')

        # Check if TARGET_NUM is an int or json obj
        if isinstance(parameter_text_json.get('TARGET_NUM'), dict):
            new_row['target_num_min'] = parameter_text_json.get('TARGET_NUM').get('min')
            new_row['target_num_max'] = parameter_text_json.get('TARGET_NUM').get('max')
        else:
            new_row['target_num_min'] = parameter_text_json.get('TARGET_NUM')
            new_row['target_num_max'] = parameter_text_json.get('TARGET_NUM')

        new_row['attack_magnification'] = parameter_text_json.get('ATTACK_MAGNIFICATION')
        new_row['recovery_magnification'] = parameter_text_json.get('RECOVERY_MAGNIFICATION')
        new_row['buffer_magical_attack_magnification'] = parameter_text_json.get('BUFFER_MAGICAL_ATTACK_MAGNIFICATION')
        new_row['buffer_magical_defense_magnification'] = parameter_text_json.get('BUFFER_MAGICAL_DEFENSE_MAGNIFICATION')
        new_row['buffer_physical_attack_magnification'] = parameter_text_json.get('BUFFER_PHYSICAL_ATTACK_MAGNIFICATION')
        new_row['buffer_physical_defense_magnification'] = parameter_text_json.get('BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION')
        new_row['debuffer_magical_attack_magnification'] = parameter_text_json.get('DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION')
        new_row['debuffer_magical_defense_magnification'] = parameter_text_json.get('DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION')
        new_row['debuffer_physical_attack_magnification'] = parameter_text_json.get('DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION')
        new_row['debuffer_physical_defense_magnification'] = parameter_text_json.get('DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION')

        # For support skills, check if there are ATTACK, RECOVERY or BUFFER keys in the dict
        action_list = ['ATTACK', 'BUFFER', 'RECOVERY', 'COMMAND']
        parameter_text_keys = parameter_text_json.keys()
        # Initialise to all key-values to None first
        init_parameter_keys(new_row)
        for action in action_list:
            if action in parameter_text_keys:
                # NOTE: There is a possibility of overwriting previously set values if more than one action appears in the keys
                # NOTE: There is also a possibility of overwriting if same key appears in both the skill dict AND the parameter_text_json dict
                get_parameter_text_key_values(new_row, parameter_text_json, action)


        # Add the entire json obj to the row to store in db
        new_row['json_params'] = parameter_text_json

        parsed_skill_list.append(new_row)

    return parsed_skill_list

def parse_super_awakened_mst_list(target_dir, filename):
    parsed_awakened_list = []
    # Get the super awakened card mst list
    awakened_list = read_json(target_dir, filename)

    for card in awakened_list:
        new_row = {}
        new_row['card_mst_id'] = card['cardMstId']
        new_row['card_type'] = card['cardType']
        new_row['quest_skill_mst_id'] = card['questSkillMstId']
        new_row['gvg_skill_mst_id'] = card['gvgSkillMstId']
        new_row['gvg_auto_skill_mst_id'] = card['gvgAutoSkillMstId']
        new_row['limit_break_bonus_mst_id'] = card['limitBreakBonusMstId']
        new_row['base_phys_atk'] = card['basePhysicalAttack']
        new_row['base_phys_def'] = card['basePhysicalDefense']
        new_row['base_mag_atk'] = card['baseMagicalAttack']
        new_row['base_mag_def'] = card['baseMagicalDefense']
        new_row['max_phys_atk'] = card['maxPhysicalAttack']
        new_row['max_phys_def'] = card['maxPhysicalDefense']
        new_row['max_mag_atk'] = card['maxMagicalAttack']
        new_row['max_mag_def'] = card['maxMagicalDefense']
        parsed_awakened_list.append(new_row)
    return parsed_awakened_list

def init_parameter_keys(new_row):
    # These are guaranteed to be support skill effects
    possible_param_keys = [
        'attack_up_magnification',
        'buffer_up_magnification',
        'recovery_up_magnification',
        'use_sp_reduce_magnification',
        # These can be main skill OR support skill effects
        'buffer_magical_attack_magnification',
        'buffer_magical_defense_magnification',
        'buffer_physical_attack_magnification',
        'buffer_physical_defense_magnification',
        'debuffer_magical_attack_magnification',
        'debuffer_magical_defense_magnification',
        'debuffer_physical_attack_magnification',
        'debuffer_physical_defense_magnification'
    ]
    for key in possible_param_keys:
        if key not in new_row:
            new_row[key] = None
    return


def get_parameter_text_key_values(new_row, parameter_text_json, key):
    # These are guaranteed to be support skill effects
    new_row['attack_up_magnification'] = parameter_text_json.get(key).get('ATTACK_UP_MAGNIFICATION')
    new_row['buffer_up_magnification'] = parameter_text_json.get(key).get('BUFFER_UP_MAGNIFICATION')
    new_row['recovery_up_magnification'] = parameter_text_json.get(key).get('RECOVERY_UP_MAGNIFICATION')
    new_row['use_sp_reduce_magnification'] = parameter_text_json.get(key).get('USE_SP_REDUCE_MAGNIFICATION')
    # These can be main skill OR support skill effects
    new_row['buffer_magical_attack_magnification'] = parameter_text_json.get(key).get('BUFFER_MAGICAL_ATTACK_MAGNIFICATION')
    new_row['buffer_magical_defense_magnification'] = parameter_text_json.get(key).get('BUFFER_MAGICAL_DEFENSE_MAGNIFICATION')
    new_row['buffer_physical_attack_magnification'] = parameter_text_json.get(key).get('BUFFER_PHYSICAL_ATTACK_MAGNIFICATION')
    new_row['buffer_physical_defense_magnification'] = parameter_text_json.get(key).get('BUFFER_PHYSICAL_DEFENSE_MAGNIFICATION')
    new_row['debuffer_magical_attack_magnification'] = parameter_text_json.get(key).get('DEBUFFER_MAGICAL_ATTACK_MAGNIFICATION')
    new_row['debuffer_magical_defense_magnification'] = parameter_text_json.get(key).get('DEBUFFER_MAGICAL_DEFENSE_MAGNIFICATION')
    new_row['debuffer_physical_attack_magnification'] = parameter_text_json.get(key).get('DEBUFFER_PHYSICAL_ATTACK_MAGNIFICATION')
    new_row['debuffer_physical_defense_magnification'] = parameter_text_json.get(key).get('DEBUFFER_PHYSICAL_DEFENSE_MAGNIFICATION')
    return


def generate_unique_cards(parsed_card_mst_list, dict_of_dicts):
    seen_list = []
    filtered_card_list = []
    unique_card_list = []

    # Filter by unique_id
    for card in parsed_card_mst_list:
        if card['unique_id'] not in seen_list:
            filtered_card_list.append(card)
            seen_list.append(card['unique_id'])

    # Fill in translated names
    for card in filtered_card_list:
        new_unique_card = {}
        new_unique_card['unique_id'] = card['unique_id']
        new_unique_card['jp_name'] = card['name']
        new_unique_card['en_name'] = dict_of_dicts['EN'].get(card['name'])
        new_unique_card['cn_name'] = dict_of_dicts['CN'].get(card['name'])
        new_unique_card['kr_name'] = dict_of_dicts['KR'].get(card['name'])
        new_unique_card['tw_name'] = dict_of_dicts['TW'].get(card['name'])

        unique_card_list.append(new_unique_card)

    return unique_card_list

def get_keys(dl, keys=[]):
    if isinstance(dl, dict):
        keys += dl.keys()
        _ = [get_keys(x, keys) for x in dl.values()]
    elif isinstance(dl, list):
        _ = [get_keys(x, keys) for x in dl]
    return list(set(keys))


def main(supabase):
    # Get the folder where the translation CSVs are
    translation_dir = get_directory('Select the TWLangR folder')

    # Get the folder where the card mst list is
    mst_dir = get_directory('Select the folder containing the mst lists')

    # Get and parse the card mst list
    parsed_card_list = parse_card_mst_list(mst_dir, 'getCardMstList.json')

    # Get all translation dicts
    en_dict = get_translation_dict(translation_dir, 'EN')
    cn_dict = get_translation_dict(translation_dir, 'CN')
    kr_dict = get_translation_dict(translation_dir, 'KR')
    tw_dict = get_translation_dict(translation_dir, 'TW')

    dict_of_dicts = {}
    dict_of_dicts['EN'] = en_dict
    dict_of_dicts['CN'] = cn_dict
    dict_of_dicts['KR'] = kr_dict
    dict_of_dicts['TW'] = tw_dict

    # Generate unique card list
    unique_card_list = generate_unique_cards(parsed_card_list, dict_of_dicts)

    # Get parsed mst skill list
    parsed_skill_list = parse_skill_mst_list(mst_dir, 'getSkillMstList.json', dict_of_dicts)

    # remove the name key from dicts in the parsed card list
    parsed_card_list = [{k: v for k, v in d.items() if k != 'name'} for d in parsed_card_list]

    # Get the super awakened card data
    parsed_super_awakening_list = parse_super_awakened_mst_list(mst_dir, 'getCardSuperAwakeningCardTypeMstList.json')

    # Get mst tactics list (orders)
    parsed_order_list = parse_order_mst_list(mst_dir, 'getTacticsMstList.json', dict_of_dicts)

    # Get mst tactic effects list (order effects)
    parsed_order_effects_list = parse_order_effects_mst_list(mst_dir, 'getTacticsEffectMstList.json', dict_of_dicts)

    # Insert into database
    response = upsert_into_table('unique_memoria', unique_card_list)
    response = upsert_into_table('skills', parsed_skill_list)
    response = upsert_into_table('memoria', parsed_card_list)
    response = upsert_into_table('super_awakened_memoria', parsed_super_awakening_list)
    response = upsert_into_table('orders', parsed_order_list)
    response = upsert_into_table('order_effects', parsed_order_effects_list)

main(supabase)