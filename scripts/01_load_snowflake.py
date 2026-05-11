import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from dotenv import load_dotenv

load_dotenv()

# ── Connexion Snowflake ───────────────────────────────────────────────────────
def get_connection():
    return snowflake.connector.connect(
        account=os.getenv("SF_ACCOUNT"),
        user=os.getenv("SF_USER"),
        password=os.getenv("SF_PASSWORD"),
        warehouse=os.getenv("SF_WAREHOUSE"),
        database=os.getenv("SF_DATABASE"),
        schema=os.getenv("SF_SCHEMA"),
    )

# ── Mapping fichiers CSV → tables Snowflake ───────────────────────────────────
FILES = {
    "olist_orders_dataset.csv":         "RAW_ORDERS",
    "olist_customers_dataset.csv":      "RAW_CUSTOMERS",
    "olist_products_dataset.csv":       "RAW_PRODUCTS",
    "olist_order_items_dataset.csv":    "RAW_ORDER_ITEMS",
    "olist_order_payments_dataset.csv": "RAW_ORDER_PAYMENTS",
    "olist_order_reviews_dataset.csv":  "RAW_ORDER_REVIEWS",
}

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "olist_data")

# ── Chargement d'un CSV dans une table Snowflake ─────────────────────────────
def load_csv_to_snowflake(conn, csv_filename, table_name):
    filepath = os.path.join(DATA_DIR, csv_filename)

    if not os.path.exists(filepath):
        print(f"  [SKIP] Fichier introuvable : {csv_filename}")
        return

    print(f"  Lecture de {csv_filename}...")
    df = pd.read_csv(filepath, low_memory=False)

    # Snowflake préfère les colonnes en majuscules
    df.columns = [col.upper() for col in df.columns]

    # Nettoyage basique : remplacer les NaN par None
    df = df.where(pd.notnull(df), None)

    print(f"  Chargement de {len(df):,} lignes → {table_name}...")
    success, nchunks, nrows, _ = write_pandas(
        conn, df, table_name, overwrite=True
    )

    if success:
        print(f"  OK — {nrows:,} lignes insérées dans {table_name}")
    else:
        print(f"  ERREUR lors du chargement de {table_name}")

# ── Point d'entrée ────────────────────────────────────────────────────────────
def main():
    print("Connexion à Snowflake...")
    conn = get_connection()
    print("Connecté !\n")

    for csv_file, table in FILES.items():
        print(f"--- {table} ---")
        load_csv_to_snowflake(conn, csv_file, table)
        print()

    conn.close()
    print("Chargement terminé. Connexion fermée.")

if __name__ == "__main__":
    main()
