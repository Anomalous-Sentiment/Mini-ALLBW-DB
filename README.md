# Mini-ALLBW-DB
This repository contains files for setting up a database for ALLBW, storing memoria and order data.

## Prerequisites

- Requires the `TWLangR` folder extracted from the ALLBW game APK, and the mst lists obtained from the game API.
- Requires [Supabase](https://supabase.com/)

## Usage

1. Create the database on [Supabase](https://supabase.com/) by running the SQL commands in the `db setup` folder in the following order:
    1. `create_tables.sql`
    2. `create_views.sql`
2. Create a `.env` file containing the database variables. Use `example.env` as reference
3. From the root directory, run `python ./scripts/populate_db.py` and select the `TWLangR` folder and the folder containing the mst lists to populate your database