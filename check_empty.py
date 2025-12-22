import json

with open('assets/data/words.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Total words: {len(data)}")

# Find empty definitions
empty = [w for w in data if not w.get('definition') or not w.get('definition').strip()]
print(f"Empty definition count: {len(empty)}")

for w in empty:
    print(f"ID:{w['id']}, Word:{w['word']}")

# Remove empty definitions and save
if empty:
    cleaned = [w for w in data if w.get('definition') and w.get('definition').strip()]
    print(f"\nAfter cleaning: {len(cleaned)} words")
    
    # Reassign IDs
    for i, w in enumerate(cleaned, 1):
        w['id'] = i
    
    with open('assets/data/words.json', 'w', encoding='utf-8') as f:
        json.dump(cleaned, f, ensure_ascii=False, indent=2)
    
    print("Saved cleaned words.json")
