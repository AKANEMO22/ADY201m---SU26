import json

with open('c:/Users/hachimi/Documents/GitHub/ADY201m-SU26/ADY201m---SU26/Data Preprocess + Train model/Data_Preprocessing.ipynb', 'r', encoding='utf-8') as f:
    nb = json.load(f)

with open('c:/Users/hachimi/Documents/GitHub/ADY201m-SU26/ADY201m---SU26/Data Preprocess + Train model/debug_nb.txt', 'w', encoding='utf-8') as out:
    for i, cell in enumerate(nb['cells']):
        if cell['cell_type'] == 'code':
            source = ''.join(cell['source'])
            out.write(f'--- Cell {i} ---\n')
            out.write(source + '\n\n')
