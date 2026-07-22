import json

path = r"C:\Users\hachimi\Documents\GitHub\ADY201m-SU26\ADY201m---SU26\5. Data Preprocessing & Model\Data_Preprocessing.ipynb"

with open(path, "r", encoding="utf-8") as f:
    nb = json.load(f)

cells = nb["cells"]

def comment_source(source):
    new = []
    for line in source:
        if line.endswith("\n"):
            content, nl = line[:-1], "\n"
        else:
            content, nl = line, ""
        if content == "":
            new.append("#" + nl)
        else:
            if not content.startswith("#"):
                content = "# " + content
            new.append(content + nl)
    return new

# TASK 1: comment out cell #11 (drops columns)
for c in cells:
    if c.get("cell_type") == "code":
        joined = "".join(c["source"])
        if "drop_cols = [" in joined and "'Rain_Temp_Ratio'" in joined:
            c["source"] = comment_source(c["source"])
            c["outputs"] = []
            c["execution_count"] = None
            print("Commented out the drop-columns cell.")
            break

# TASK 2: insert PCA cells after the post-drop VIF cell (## 5. Tính toán lại VIF)
md_text = ("## 6. Giảm chiều dữ liệu bằng PCA (Principal Component Analysis)\n"
"PCA là kỹ thuật giảm chiều tuyến tính giúp biến đổi các biến gốc (có thể tương quan) thành một tập hợp các thành phần chính (Principal Components) không tương quan, đồng thời giữ lại tối đa phương sai (variance) của dữ liệu. Đây là một cách tiếp cận khác để xử lý Đa cộng tuyến bên cạnh việc loại bỏ biến thủ công.\n"
"\n"
"**Lưu ý:** PCA yêu cầu dữ liệu phải được chuẩn hóa (standardized) trước khi áp dụng để đảm bảo các biến có cùng thang đo.")

code1 = ("from sklearn.preprocessing import StandardScaler\n"
"from sklearn.decomposition import PCA\n"
"\n"
"# Chuẩn bị dữ liệu cho PCA: dùng các biến số hiện tại (đã loại bỏ Đa cộng tuyến), loại trừ biến mục tiêu\n"
"target_col = 'NDVI'\n"
"pca_features = [col for col in numeric_df_final.columns if col != target_col]\n"
"\n"
"X_pca_raw = numeric_df_final[pca_features].replace([np.inf, -np.inf], np.nan)\n"
"X_pca_raw = X_pca_raw.fillna(X_pca_raw.median())\n"
"\n"
"# PCA nhạy cảm với thang đo -> bắt buộc chuẩn hóa trước\n"
"scaler_pca = StandardScaler()\n"
"X_pca_scaled = scaler_pca.fit_transform(X_pca_raw)\n"
"\n"
"# Áp dụng PCA giữ lại toàn bộ thành phần để phân tích phương sai\n"
"pca = PCA()\n"
"X_pca = pca.fit_transform(X_pca_scaled)\n"
"\n"
"explained = pca.explained_variance_ratio_\n"
"cumulative = np.cumsum(explained)\n"
"\n"
"print(\"Tỷ lệ phương sai giải thích bởi từng thành phần chính:\")\n"
"for i, (ev, cv) in enumerate(zip(explained, cumulative), start=1):\n"
"    print(f\"  PC{i}: {ev:.4f}  |  Tích lũy: {cv:.4f}\")")

code2 = ("fig, axes = plt.subplots(1, 2, figsize=(16, 6))\n"
"\n"
"# Scree plot - phương sai giải thích của từng thành phần\n"
"axes[0].bar(range(1, len(explained) + 1), explained, alpha=0.7, color='steelblue')\n"
"axes[0].plot(range(1, len(explained) + 1), explained, marker='o', color='red')\n"
"axes[0].set_xlabel('Thành phần chính (Principal Component)')\n"
"axes[0].set_ylabel('Tỷ lệ phương sai giải thích')\n"
"axes[0].set_title('Scree Plot')\n"
"\n"
"# Cumulative explained variance\n"
"axes[1].plot(range(1, len(cumulative) + 1), cumulative, marker='o', color='green')\n"
"axes[1].axhline(y=0.95, color='red', linestyle='--', label='Ngưỡng 95% phương sai')\n"
"axes[1].set_xlabel('Số lượng thành phần chính')\n"
"axes[1].set_ylabel('Phương sai tích lũy')\n"
"axes[1].set_title('Cumulative Explained Variance')\n"
"axes[1].legend()\n"
"\n"
"plt.tight_layout()\n"
"plt.show()")

code3 = ("# Chọn số thành phần chính giữ lại 95% phương sai\n"
"n_components_95 = int(np.argmax(cumulative >= 0.95) + 1)\n"
"print(f\"Số thành phần chính cần thiết để giữ lại >= 95% phương sai: {n_components_95}\")\n"
"print(f\"Giảm chiều từ {len(pca_features)} biến xuống còn {n_components_95} thành phần chính.\")\n"
"\n"
"# Áp dụng PCA với số thành phần đã chọn\n"
"pca_final = PCA(n_components=n_components_95)\n"
"X_pca_reduced = pca_final.fit_transform(X_pca_scaled)\n"
"\n"
"df_pca = pd.DataFrame(\n"
"    X_pca_reduced,\n"
"    columns=[f'PC{i+1}' for i in range(n_components_95)]\n"
")\n"
"df_pca[target_col] = numeric_df_final[target_col].values\n"
"print(\"\\nKích thước dữ liệu sau khi giảm chiều bằng PCA:\", df_pca.shape)\n"
"df_pca.head()")

def to_source(text):
    lines = text.split("\n")
    return [l + "\n" for l in lines[:-1]] + [lines[-1]]

md_cell = {"cell_type": "markdown", "metadata": {}, "source": to_source(md_text)}
code_cells = []
for code in (code1, code2, code3):
    code_cells.append({
        "cell_type": "code",
        "execution_count": None,
        "metadata": {},
        "outputs": [],
        "source": to_source(code),
    })

# find index of post-drop VIF markdown cell
insert_idx = None
for i, c in enumerate(cells):
    if c.get("cell_type") == "markdown":
        joined = "".join(c["source"])
        if "## 5. Tính toán lại VIF" in joined:
            insert_idx = i
            break

if insert_idx is None:
    raise RuntimeError("Post-drop VIF cell not found!")

# insert after the following code cell (the VIF code cell)
# insert right after the markdown's following code cell -> insert after i where i is next code cell
code_after = insert_idx
for j in range(insert_idx + 1, len(cells)):
    if cells[j].get("cell_type") == "code":
        code_after = j
        break

new_cells = [md_cell] + code_cells
cells[code_after + 1:code_after + 1] = new_cells

with open(path, "w", encoding="utf-8") as f:
    json.dump(nb, f, indent=1, ensure_ascii=False)

# VERIFICATION
with open(path, "r", encoding="utf-8") as f:
    nb2 = json.load(f)

cells2 = nb2["cells"]
total = len(cells2)
print("Total cells:", total)

# verify cell #11 commented
found = False
for c in cells2:
    if c.get("cell_type") == "code":
        joined = "".join(c["source"])
        if "drop_cols = [" in joined and "'Rain_Temp_Ratio'" in joined:
            found = True
            non_empty = [s for s in joined.split("\n") if s.strip() != ""]
            all_commented = all(s.lstrip().startswith("#") for s in non_empty)
            print("Drop cell found. Fully commented:", all_commented)
            break

# verify PCA insertion after post-drop VIF
pca_ok = False
for i, c in enumerate(cells2):
    if c.get("cell_type") == "markdown":
        if "## 6. Giảm chiều dữ liệu bằng PCA" in "".join(c["source"]):
            # check the preceding code cell is the post-drop VIF code cell
            prev = cells2[i - 1]
            pca_ok = ("vif_data_final" in "".join(prev["source"])) or (prev.get("cell_type") == "code")
            print("PCA markdown inserted at index", i, "; preceding cell type:", prev.get("cell_type"))
            break

print("Verified count of new PCA code cells:", sum(1 for c in cells2 if c.get("cell_type")=="code" and "PCA()" in "".join(c["source"]) or ("df_pca" in "".join(c["source"]))))
