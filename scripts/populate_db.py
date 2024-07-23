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

        new_row['name'] = card['name']

        parsed_card_list.append(new_row)

    return parsed_card_list

def parse_skill_mst_list(target_dir):
    parsed_skill_list = []
    return parsed_skill_list

def upsert_into_table(table_name, rows):
    response = (
        supabase.table(table_name)
        .upsert(rows)
        .execute()
    )
    return response

def parse_skill_mst_list(target_dir, filename, dict_of_dicts):
    parsed_skill_list = []
    # Get the card mst list
    skill_list = read_json(target_dir, filename)
    longest_name = ''
    longest_desc = ''

    for skill in skill_list:
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

        parsed_skill_list.append(new_row)

    return parsed_skill_list

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

# remove the name key form dicts in the parsed card list
parsed_card_list = [{k: v for k, v in d.items() if k != 'name'} for d in parsed_card_list]

# Insert into database
response = upsert_into_table('unique_memoria', unique_card_list)
response = upsert_into_table('skills', parsed_skill_list)
response = upsert_into_table('memoria', parsed_card_list)
