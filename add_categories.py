import json
import os
from openai import OpenAI

client = OpenAI()

# New categories to add
NEW_CATEGORIES = [
    {
        "id": "hospital",
        "name_en": "Hospital & Pharmacy",
        "name_ko": "병원/약국",
        "name_zh": "医院/药店",
        "name_es": "Hospital/Farmacia",
        "name_vi": "Bệnh viện/Nhà thuốc",
        "icon": "local_hospital",
        "description": "Medical terms, symptoms, pharmacy conversations"
    },
    {
        "id": "school",
        "name_en": "School & Education",
        "name_ko": "학교/교육",
        "name_zh": "学校/教育",
        "name_es": "Escuela/Educación",
        "name_vi": "Trường học/Giáo dục",
        "icon": "school",
        "description": "School life, classroom, studying, exams"
    },
    {
        "id": "business",
        "name_en": "Work & Business",
        "name_ko": "직장/비즈니스",
        "name_zh": "工作/商务",
        "name_es": "Trabajo/Negocios",
        "name_vi": "Công việc/Kinh doanh",
        "icon": "business_center",
        "description": "Office life, meetings, business Japanese"
    },
    {
        "id": "bank",
        "name_en": "Bank & Post Office",
        "name_ko": "은행/우체국",
        "name_zh": "银行/邮局",
        "name_es": "Banco/Correos",
        "name_vi": "Ngân hàng/Bưu điện",
        "icon": "account_balance",
        "description": "Banking, postal services, money transactions"
    },
    {
        "id": "salon",
        "name_en": "Salon & Services",
        "name_ko": "미용실/서비스",
        "name_zh": "美容院/服务",
        "name_es": "Salón/Servicios",
        "name_vi": "Tiệm làm đẹp/Dịch vụ",
        "icon": "content_cut",
        "description": "Hair salon, spa, cleaning, repair services"
    },
    {
        "id": "home",
        "name_en": "Home & Living",
        "name_ko": "집/생활",
        "name_zh": "家庭/生活",
        "name_es": "Hogar/Vida",
        "name_vi": "Nhà ở/Sinh hoạt",
        "icon": "home",
        "description": "Household items, chores, apartment living"
    },
    {
        "id": "weather",
        "name_en": "Weather & Seasons",
        "name_ko": "날씨/계절",
        "name_zh": "天气/季节",
        "name_es": "Clima/Estaciones",
        "name_vi": "Thời tiết/Mùa",
        "icon": "wb_sunny",
        "description": "Weather expressions, seasons, climate"
    },
    {
        "id": "party",
        "name_en": "Party & Events",
        "name_ko": "파티/이벤트",
        "name_zh": "派对/活动",
        "name_es": "Fiesta/Eventos",
        "name_vi": "Tiệc/Sự kiện",
        "icon": "celebration",
        "description": "Celebrations, holidays, social events"
    }
]

def generate_words_for_category(category, count=120):
    """Generate words for a category using GPT-4o mini"""
    
    prompt = f"""Generate exactly {count} practical Japanese vocabulary words/phrases for the category: {category['name_en']} ({category['description']}).

For each word, provide:
1. word: Japanese word/phrase (kanji if applicable)
2. reading: Hiragana reading
3. meaning_en: English meaning
4. meaning_ko: Korean meaning  
5. meaning_zh: Chinese meaning (Simplified)
6. meaning_es: Spanish meaning
7. meaning_vi: Vietnamese meaning
8. example_ja: Example sentence in Japanese
9. example_reading: Hiragana reading of the example
10. example_en: English translation of example

Requirements:
- Focus on practical, commonly used vocabulary for daily life in Japan
- Include a mix of nouns, verbs, adjectives, and useful phrases
- Examples should be natural and practical
- Avoid duplicate words
- Make sure readings are accurate hiragana

Return as JSON array with exactly {count} objects. No markdown, just pure JSON."""

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a Japanese language expert. Generate accurate, practical vocabulary with correct readings and translations. Return only valid JSON."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7,
        max_tokens=16000
    )
    
    content = response.choices[0].message.content.strip()
    # Remove markdown if present
    if content.startswith("```"):
        content = content.split("\n", 1)[1]
        content = content.rsplit("```", 1)[0]
    
    return json.loads(content)

def main():
    # Load existing words
    words_file = "assets/data/words.json"
    with open(words_file, "r", encoding="utf-8") as f:
        existing_data = json.load(f)
    
    # Handle both list and dict formats
    if isinstance(existing_data, list):
        existing_words = existing_data
    else:
        existing_words = existing_data.get("words", [])
    print(f"Existing words: {len(existing_words)}")
    
    # Find max ID
    max_id = max(w.get("id", 0) for w in existing_words) if existing_words else 0
    
    all_new_words = []
    
    for category in NEW_CATEGORIES:
        print(f"\n{'='*50}")
        print(f"Generating words for: {category['name_en']}")
        print(f"{'='*50}")
        
        try:
            words = generate_words_for_category(category, count=120)
            
            # Add category and ID to each word
            for word in words:
                max_id += 1
                word["id"] = max_id
                word["category"] = category["id"]
            
            all_new_words.extend(words)
            print(f"✓ Generated {len(words)} words for {category['id']}")
            
            # Save progress after each category
            progress_file = f"new_words_{category['id']}.json"
            with open(progress_file, "w", encoding="utf-8") as f:
                json.dump(words, f, ensure_ascii=False, indent=2)
            print(f"  Saved to {progress_file}")
            
        except Exception as e:
            print(f"✗ Error generating {category['id']}: {e}")
            continue
    
    print(f"\n{'='*50}")
    print(f"Total new words generated: {len(all_new_words)}")
    print(f"{'='*50}")
    
    # Merge with existing
    all_words = existing_words + all_new_words
    
    # Save merged file (as array)
    with open(words_file, "w", encoding="utf-8") as f:
        json.dump(all_words, f, ensure_ascii=False, indent=2)
    
    print(f"\nTotal words in app: {len(all_words)}")
    
    # Update categories.json
    categories_file = "assets/data/categories.json"
    with open(categories_file, "r", encoding="utf-8") as f:
        categories_data = json.load(f)
    
    existing_categories = categories_data.get("categories", [])
    
    # Add new categories
    for cat in NEW_CATEGORIES:
        new_cat = {
            "id": cat["id"],
            "name_en": cat["name_en"],
            "name_ko": cat["name_ko"],
            "name_zh": cat["name_zh"],
            "name_es": cat["name_es"],
            "name_vi": cat["name_vi"],
            "icon": cat["icon"]
        }
        existing_categories.append(new_cat)
    
    categories_data["categories"] = existing_categories
    with open(categories_file, "w", encoding="utf-8") as f:
        json.dump(categories_data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated categories: {len(existing_categories)}")
    
    # Print summary by category
    print("\n--- Summary by Category ---")
    category_counts = {}
    for w in all_words:
        cat = w.get("category", "unknown")
        category_counts[cat] = category_counts.get(cat, 0) + 1
    
    for cat, count in sorted(category_counts.items()):
        print(f"  {cat}: {count} words")

if __name__ == "__main__":
    main()
