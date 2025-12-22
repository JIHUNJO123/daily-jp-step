import json

# Load existing categories
with open('assets/data/categories.json', 'r', encoding='utf-8-sig') as f:
    categories = json.load(f)

# New categories to add
new_cats = [
    {'id': 'hospital', 'name_en': 'Hospital & Pharmacy', 'name_ko': '병원/약국', 'name_zh': '医院/药店', 'name_es': 'Hospital/Farmacia', 'name_vi': 'Bệnh viện/Nhà thuốc', 'word_count': 92},
    {'id': 'school', 'name_en': 'School & Education', 'name_ko': '학교/교육', 'name_zh': '学校/教育', 'name_es': 'Escuela/Educación', 'name_vi': 'Trường học/Giáo dục', 'word_count': 85},
    {'id': 'business', 'name_en': 'Work & Business', 'name_ko': '직장/비즈니스', 'name_zh': '工作/商务', 'name_es': 'Trabajo/Negocios', 'name_vi': 'Công việc/Kinh doanh', 'word_count': 71},
    {'id': 'bank', 'name_en': 'Bank & Post Office', 'name_ko': '은행/우체국', 'name_zh': '银行/邮局', 'name_es': 'Banco/Correos', 'name_vi': 'Ngân hàng/Bưu điện', 'word_count': 74},
    {'id': 'salon', 'name_en': 'Salon & Services', 'name_ko': '미용실/서비스', 'name_zh': '美容院/服务', 'name_es': 'Salón/Servicios', 'name_vi': 'Tiệm làm đẹp/Dịch vụ', 'word_count': 71},
    {'id': 'home', 'name_en': 'Home & Living', 'name_ko': '집/생활', 'name_zh': '家庭/生活', 'name_es': 'Hogar/Vida', 'name_vi': 'Nhà ở/Sinh hoạt', 'word_count': 94},
    {'id': 'weather', 'name_en': 'Weather & Seasons', 'name_ko': '날씨/계절', 'name_zh': '天气/季节', 'name_es': 'Clima/Estaciones', 'name_vi': 'Thời tiết/Mùa', 'word_count': 66},
    {'id': 'party', 'name_en': 'Party & Events', 'name_ko': '파티/이벤트', 'name_zh': '派对/活动', 'name_es': 'Fiesta/Eventos', 'name_vi': 'Tiệc/Sự kiện', 'word_count': 86}
]

categories.extend(new_cats)

with open('assets/data/categories.json', 'w', encoding='utf-8') as f:
    json.dump(categories, f, ensure_ascii=False, indent=2)

print(f'Total categories: {len(categories)}')
for c in categories:
    print(f"  {c['id']}: {c.get('word_count', 0)} words")
