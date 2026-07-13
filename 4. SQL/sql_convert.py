import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine

engine = create_engine(
    "mssql+pyodbc://@localhost/testdb"
    "?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
)

csv_path = Path(__file__).parent / "Agri_Data_Cleaned.csv"

df = pd.read_csv(csv_path, encoding="utf-8-sig")

# Xóa khoảng trắng thừa trong tên cột
df.columns = df.columns.str.strip()

# Xóa dòng lỗi Excel
df = df[df["Crop_Name"] != "#REF!"].copy()

# Chỉ xóa dòng trùng hoàn toàn
df = df.drop_duplicates()

# Thêm ID để phân biệt từng quan sát
df.insert(0, "Record_ID", range(1, len(df) + 1))

print("File:", csv_path.resolve())
print("Kích thước sau làm sạch:", df.shape)
print(df.columns.tolist())

df.to_sql(
    "Data",
    engine,
    schema="dbo",
    if_exists="replace",
    index=False,
    chunksize=1000
)

print("Đã nhập dữ liệu vào SQL Server")