import pandas as pd
from sqlalchemy import create_engine

engine = create_engine(
    "mssql+pyodbc://@localhost/testdb"
    "?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
)

df = pd.read_csv("Agri_Data_Cleaned.csv", encoding="utf-8-sig")

df.to_sql("Data", engine, if_exists="replace", index=False)

print("Xong")