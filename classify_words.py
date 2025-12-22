"""
JLPT N5-N4 단어를 카테고리별로 분류하는 스크립트
GPT-4o mini API 사용

카테고리:
- daily: 일상생활 (집, 시간, 숫자 등)
- food: 음식/식당
- travel: 여행/교통
- shopping: 쇼핑/가격
- people: 사람/감정/관계
- nature: 날씨/자연/계절
- work: 직장/학교
- basic: 기본 동사/형용사/부사
"""

import json
import os
from openai import OpenAI

# OpenAI API 키 설정 (환경변수 또는 직접 입력)
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    api_key = input("Enter your OpenAI API key: ").strip()

client = OpenAI(api_key=api_key)

# 카테고리 정의
CATEGORIES = {
    "daily": "일상생활 (집, 가구, 시간, 숫자, 색깔, 위치 등)",
    "food": "음식, 음료, 요리, 식당, 맛 관련",
    "travel": "여행, 교통수단, 장소, 방향, 길찾기",
    "shopping": "쇼핑, 가격, 돈, 물건 구매",
    "people": "사람, 가족, 신체, 감정, 인간관계",
    "nature": "날씨, 계절, 자연, 동물, 식물",
    "work": "직장, 학교, 공부, 업무 관련",
    "basic": "기본 동사, 형용사, 부사, 조사 (다른 카테고리에 맞지 않는 경우)"
}

def classify_words_batch(words, batch_size=50):
    """단어 배치를 GPT-4o mini로 분류"""
    
    categories_desc = "\n".join([f"- {k}: {v}" for k, v in CATEGORIES.items()])
    
    prompt = f"""다음 일본어 단어들을 카테고리로 분류해주세요.

카테고리:
{categories_desc}

각 단어에 대해 가장 적합한 카테고리 하나만 선택하세요.
JSON 형식으로 응답해주세요: {{"word": "category", ...}}

단어 목록:
"""
    
    word_list = []
    for w in words:
        word_list.append(f"{w['word']} ({w['reading']}): {w['definition']}")
    
    prompt += "\n".join(word_list)
    
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a Japanese language expert. Classify Japanese words into categories. Respond only with valid JSON."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=4000
        )
        
        result_text = response.choices[0].message.content.strip()
        
        # JSON 추출 (```json 블록이 있을 경우 처리)
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].split("```")[0].strip()
        
        return json.loads(result_text)
    
    except Exception as e:
        print(f"Error: {e}")
        return {}

def main():
    # JLPT N5-N4 데이터 로드
    input_path = r"c:\Users\hooni\Desktop\jlpt_vocab_app\assets\data\words_n5_n3.json"
    
    with open(input_path, 'r', encoding='utf-8') as f:
        all_words = json.load(f)
    
    # N5, N4만 필터링
    words = [w for w in all_words if w.get('level') in ['N5', 'N4']]
    print(f"Total words to classify: {len(words)}")
    
    # 배치로 분류
    batch_size = 40
    classified_words = []
    
    for i in range(0, len(words), batch_size):
        batch = words[i:i+batch_size]
        print(f"Processing batch {i//batch_size + 1}/{(len(words)-1)//batch_size + 1}...")
        
        classifications = classify_words_batch(batch)
        
        for w in batch:
            word_key = w['word']
            category = classifications.get(word_key, "basic")
            
            # 유효한 카테고리인지 확인
            if category not in CATEGORIES:
                category = "basic"
            
            classified_word = {
                "id": w['id'],
                "word": w['word'],
                "reading": w['reading'],
                "definition": w['definition'],
                "category": category,
                "korean": w.get('korean', ''),
                "chinese": w.get('chinese', ''),
                "spanish": "",  # 나중에 추가
                "vietnamese": "",  # 나중에 추가
                "example": w.get('example', ''),
                "example_reading": w.get('example_reading', ''),
                "example_meaning": w.get('example_meaning', ''),
                "level": w.get('level', 'N5')
            }
            classified_words.append(classified_word)
    
    # 결과 저장
    output_path = r"c:\Users\hooni\Desktop\daily_japanese_app\assets\data\words.json"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(classified_words, f, ensure_ascii=False, indent=2)
    
    # 카테고리별 통계 출력
    print("\n=== Category Statistics ===")
    category_counts = {}
    for w in classified_words:
        cat = w['category']
        category_counts[cat] = category_counts.get(cat, 0) + 1
    
    for cat, count in sorted(category_counts.items()):
        print(f"{cat}: {count} words")
    
    print(f"\nTotal: {len(classified_words)} words")
    print(f"Saved to: {output_path}")

if __name__ == "__main__":
    main()
