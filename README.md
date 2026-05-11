# ELT E-Commerce Pipeline — Snowflake & BigQuery

Pipeline ELT complet pour l'analyse de données e-commerce (dataset Olist — 100k+ commandes brésiliennes).

## Architecture

```
Kaggle CSV (9 fichiers)
       │
       ▼
  Python (pandas)
       │
  ┌────┴────┐
  │         │
  ▼         ▼
Snowflake  BigQuery
(RAW)      (RAW)
  │
  ▼
SQL Views
(Schéma en étoile)
  │
  ▼
Analytics Layer
(FCT_ORDERS, DIM_*)
```

## Stack technique

| Outil | Usage |
|---|---|
| Python 3.11 + pandas | Lecture CSV, nettoyage, chargement |
| Snowflake | Data warehouse principal |
| BigQuery | Data warehouse alternatif |
| SQL | Modélisation en étoile |

## Dataset

**Olist Brazilian E-Commerce** (Kaggle)
- 99 441 commandes · 2016–2018
- 9 fichiers CSV interconnectés
- Clients, produits, paiements, avis

## Structure du projet

```
├── data/               # CSV Kaggle (non commité)
├── scripts/
│   ├── 01_load_snowflake.py   # Ingestion → Snowflake
│   └── 02_load_bigquery.py    # Ingestion → BigQuery
├── sql/
│   ├── 00_setup_snowflake.sql # Création des tables RAW
│   └── schema_star.sql        # Modélisation en étoile
├── screenshots/               # Preuves d'exécution
├── .env.example               # Template credentials
└── README.md
```

## Résultats

- **99 441 commandes** chargées en < 2 min
- **6 tables RAW** créées dans Snowflake et BigQuery
- **Schéma en étoile** : 1 table de faits + 3 dimensions
- Taux de livraison dans les délais : ~92%
- CA moyen mensuel : ~R$ 900 000

## Lancer le projet

```bash
# Installer les dépendances
pip install -r requirements.txt

# Configurer les credentials
cp .env.example .env
# (remplir les valeurs dans .env)

# Charger les données
python scripts/01_load_snowflake.py
python scripts/02_load_bigquery.py
```

## Certifications associées

- Snowflake Hands-On Essentials: Data Warehousing Workshop
- Snowflake Hands-On Essentials: Data Engineering Workshop
- Google BigQuery Fundamentals for Snowflake Professionals
