#!/usr/bin/env python3
"""
의성어/의태어 데이터를 Onoma Step 앱 형식으로 변환
"""

import json

def convert_to_app_format():
    # 데이터 로드
    with open('onomatopoeia_final.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"Loaded {len(data)} words")
    
    # 카테고리 매핑 (한국어 제거하고 영어만)
    category_mapping = {
        "소리 - 충격/타격": "Impact Sounds",
        "소리 - 물/액체": "Water/Liquid Sounds", 
        "소리 - 바람/공기": "Wind/Air Sounds",
        "소리 - 기계/전자": "Mechanical Sounds",
        "소리 - 동물": "Animal Sounds",
        "소리 - 사람": "Human Sounds",
        "소리 (Sound)": "Other Sounds",
        
        "움직임 - 걷기/달리기": "Walking/Running",
        "움직임 - 흔들림": "Shaking/Swaying",
        "움직임 - 회전/구르기": "Spinning/Rolling",
        "움직임 - 점프/튀기": "Jumping/Bouncing",
        "움직임 - 미끄러짐": "Sliding/Slipping",
        "움직임 (Motion)": "Other Motion",
        
        "감정 - 긍정적": "Positive Emotions",
        "감정 - 부정적": "Negative Emotions", 
        "감정 - 불안/긴장": "Anxiety/Nervousness",
        "감정 - 두근거림": "Heartbeat/Excitement",
        "감정 (Emotion)": "Other Emotions",
        
        "상태 - 빛/광택": "Light/Shine",
        "상태 - 젖음/건조": "Wet/Dry",
        "상태 - 부드러움/딱딱함": "Soft/Hard",
        "상태 - 끈적임/미끌거림": "Sticky/Slippery",
        "상태 - 깔끔/지저분": "Clean/Messy",
        "상태/모양 (State/Appearance)": "Other States",
        
        "먹기 - 씹기": "Chewing",
        "먹기 - 마시기": "Drinking",
        "먹기 - 맛/식감": "Taste/Texture",
        "먹기/맛 (Eating/Taste)": "Other Eating",
        
        "신체 - 피로/졸림": "Fatigue/Sleepiness",
        "신체 - 아픔/불편": "Pain/Discomfort",
        "신체 - 배고픔/배부름": "Hunger/Fullness",
        
        "날씨 - 비/눈": "Rain/Snow",
        "날씨 - 바람": "Wind",
        "날씨 - 온도": "Temperature",
        "날씨/자연 (Weather/Nature)": "Other Weather",
        
        "속도 - 빠름": "Fast/Quick",
        "속도 - 느림": "Slow/Leisurely",
        
        "양 - 많음": "Abundance",
        "양 - 적음/희소": "Scarcity",
        
        "외형 - 크기": "Size",
        "외형 - 모양": "Shape",
        
        "태도 - 자신감": "Confident",
        "태도 - 겸손/소극적": "Shy/Hesitant",
        "태도 - 불성실": "Lazy/Careless",
        
        "동물 소리 (Animal Sounds)": "Animal Sounds",
        "기타": "Others",
        "기타 (Others)": "Others",
    }
    
    # 앱 형식으로 변환
    app_data = []
    
    for item in data:
        # 카테고리 매핑
        original_cat = item.get('category', '기타')
        category = category_mapping.get(original_cat, 'Others')
        
        # level을 카테고리로 사용 (앱 구조와 호환)
        app_item = {
            "id": item['id'],
            "word": item['word'],
            "reading": item['reading'],
            "definition": item['definition'],
            "level": category,  # 카테고리를 level로 사용
            "category": category,
            "partOfSpeech": "onomatopoeia",
            "example": item.get('example', ''),
            "example_reading": item.get('example_reading', ''),
            "example_meaning": item.get('example_meaning', ''),
            "korean": item.get('korean', ''),
            "chinese": item.get('chinese', ''),
            "source": item.get('source', 'JMdict (CC-BY-SA 4.0)')
        }
        
        app_data.append(app_item)
    
    # 카테고리별 통계
    categories = {}
    for item in app_data:
        cat = item['category']
        categories[cat] = categories.get(cat, 0) + 1
    
    print("\nCategory distribution:")
    for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count}")
    
    # 저장
    output_file = 'onomatopoeia_app.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(app_data, f, ensure_ascii=False, indent=2)
    
    print(f"\nSaved to {output_file}")
    print(f"Total categories: {len(categories)}")
    
    return app_data, list(categories.keys())

if __name__ == "__main__":
    convert_to_app_format()
