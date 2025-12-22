#!/usr/bin/env python3
"""
JMdict에서 의성어/의태어(on-mim) 추출
License: CC-BY-SA 4.0 (JMdict)
"""

import xml.etree.ElementTree as ET
import json
import re

def extract_onomatopoeia(xml_file):
    print("Parsing JMdict XML...")
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    onomatopoeia_list = []
    word_id = 0
    
    for entry in root.findall('entry'):
        # Check if it's onomatopoeia (on-mim)
        is_onomatopoeia = False
        pos_tags = []
        
        for sense in entry.findall('sense'):
            for pos in sense.findall('pos'):
                if pos.text:
                    pos_tags.append(pos.text)
                    if 'onomatopoeic' in pos.text.lower() or 'mimetic' in pos.text.lower():
                        is_onomatopoeia = True
            
            for misc in sense.findall('misc'):
                if misc.text and ('onomatopoeic' in misc.text.lower() or 'mimetic' in misc.text.lower()):
                    is_onomatopoeia = True
        
        if not is_onomatopoeia:
            continue
        
        word_id += 1
        
        # Get kanji/kana forms
        kanji_elements = entry.findall('k_ele/keb')
        reading_elements = entry.findall('r_ele/reb')
        
        word = kanji_elements[0].text if kanji_elements else (reading_elements[0].text if reading_elements else "")
        reading = reading_elements[0].text if reading_elements else ""
        
        # If word is same as reading (kana-only), use reading as word
        if not kanji_elements and reading_elements:
            word = reading
        
        # Get definitions
        definitions = []
        examples = []
        
        for sense in entry.findall('sense'):
            for gloss in sense.findall('gloss'):
                if gloss.text and gloss.get('{http://www.w3.org/XML/1998/namespace}lang', 'eng') == 'eng':
                    definitions.append(gloss.text)
        
        if not definitions:
            continue
        
        definition = "; ".join(definitions[:3])  # Limit to first 3 definitions
        
        # Categorize based on content
        category = categorize_onomatopoeia(word, reading, definition)
        
        onomatopoeia_list.append({
            "id": word_id,
            "word": word,
            "reading": reading,
            "definition": definition,
            "category": category,
            "korean": "",
            "chinese": "",
            "example": "",
            "example_reading": "",
            "example_meaning": "",
            "source": "JMdict (CC-BY-SA 4.0)"
        })
    
    return onomatopoeia_list

def categorize_onomatopoeia(word, reading, definition):
    """카테고리 분류"""
    definition_lower = definition.lower()
    
    # 소리 관련 (의성어)
    sound_keywords = ['sound', 'noise', 'cry', 'bang', 'crash', 'ring', 'splash', 'thud', 
                      'knock', 'click', 'crackle', 'rumble', 'roar', 'buzz', 'hum']
    
    # 움직임/동작
    motion_keywords = ['walk', 'run', 'move', 'roll', 'spin', 'shake', 'wobble', 'sway',
                       'jump', 'bounce', 'tumble', 'slip', 'slide', 'rush', 'dash']
    
    # 감정/심리
    emotion_keywords = ['feel', 'nervous', 'anxious', 'excited', 'happy', 'sad', 'angry',
                        'worry', 'thrill', 'flutter', 'pound', 'heart', 'irritat', 'frustrat']
    
    # 상태/모양
    state_keywords = ['shiny', 'sparkle', 'glitter', 'smooth', 'rough', 'soft', 'hard',
                      'wet', 'dry', 'sticky', 'slippery', 'fluffy', 'crisp', 'damp']
    
    # 먹기/맛
    eating_keywords = ['eat', 'chew', 'gulp', 'sip', 'bite', 'munch', 'crunch', 'slurp',
                       'taste', 'delicious', 'chewy']
    
    # 날씨/자연
    weather_keywords = ['rain', 'wind', 'thunder', 'lightning', 'snow', 'sun', 'cloud',
                        'storm', 'drizzle', 'pour']
    
    # 동물 소리
    animal_keywords = ['bark', 'meow', 'chirp', 'tweet', 'growl', 'howl', 'squeak',
                       'animal', 'dog', 'cat', 'bird', 'crow', 'cock']
    
    for keyword in sound_keywords:
        if keyword in definition_lower:
            return "소리 (Sound)"
    
    for keyword in animal_keywords:
        if keyword in definition_lower:
            return "동물 소리 (Animal Sounds)"
    
    for keyword in motion_keywords:
        if keyword in definition_lower:
            return "움직임 (Motion)"
    
    for keyword in emotion_keywords:
        if keyword in definition_lower:
            return "감정 (Emotion)"
    
    for keyword in state_keywords:
        if keyword in definition_lower:
            return "상태/모양 (State/Appearance)"
    
    for keyword in eating_keywords:
        if keyword in definition_lower:
            return "먹기/맛 (Eating/Taste)"
    
    for keyword in weather_keywords:
        if keyword in definition_lower:
            return "날씨/자연 (Weather/Nature)"
    
    return "기타 (Others)"

def main():
    xml_file = "JMdict_e.xml"
    
    onomatopoeia_list = extract_onomatopoeia(xml_file)
    
    print(f"\nTotal onomatopoeia found: {len(onomatopoeia_list)}")
    
    # Category statistics
    categories = {}
    for item in onomatopoeia_list:
        cat = item['category']
        categories[cat] = categories.get(cat, 0) + 1
    
    print("\nCategory distribution:")
    for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count}")
    
    # Save to JSON
    output_file = "onomatopoeia_data.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(onomatopoeia_list, f, ensure_ascii=False, indent=2)
    
    print(f"\nData saved to {output_file}")
    
    # Print sample
    print("\nSample data:")
    for item in onomatopoeia_list[:5]:
        print(f"  {item['word']} ({item['reading']}): {item['definition'][:50]}...")

if __name__ == "__main__":
    main()
