#!/usr/bin/env python3
"""
의성어/의태어 카테고리 재분류 및 다국어 번역 추가
"""

import json
import re

def recategorize_onomatopoeia(onomatopoeia_list):
    """더 세분화된 카테고리로 재분류"""
    
    category_keywords = {
        # 소리 (의성어)
        "소리 - 충격/타격": ['bang', 'crash', 'thud', 'slam', 'knock', 'hit', 'strike', 'clash', 'bump', 'thump', 'smack', 'slap', 'punch', 'pound'],
        "소리 - 물/액체": ['splash', 'drip', 'bubble', 'gurgle', 'flow', 'pour', 'squish', 'splatter', 'squelch'],
        "소리 - 바람/공기": ['whoosh', 'whistle', 'blow', 'gust', 'breeze', 'hiss', 'sizzle'],
        "소리 - 기계/전자": ['click', 'beep', 'buzz', 'hum', 'ring', 'tick', 'clatter', 'rattle'],
        "소리 - 동물": ['bark', 'meow', 'chirp', 'tweet', 'growl', 'howl', 'squeak', 'roar', 'crow', 'moo', 'oink', 'quack', 'neigh', 'bleat', 'animal', 'dog', 'cat', 'bird', 'insect', 'frog'],
        "소리 - 사람": ['laugh', 'cry', 'scream', 'whisper', 'shout', 'yell', 'giggle', 'chuckle', 'sob', 'sigh', 'snore', 'cough', 'sneeze', 'hiccup', 'voice', 'speak'],
        
        # 움직임 (의태어)
        "움직임 - 걷기/달리기": ['walk', 'run', 'dash', 'rush', 'trudge', 'trot', 'pace', 'stride', 'stagger', 'limp', 'waddle', 'strut', 'stomp'],
        "움직임 - 흔들림": ['shake', 'wobble', 'sway', 'swing', 'rock', 'tremble', 'shiver', 'quiver', 'vibrate', 'flutter', 'waver'],
        "움직임 - 회전/구르기": ['roll', 'spin', 'turn', 'twist', 'rotate', 'whirl', 'tumble', 'revolve'],
        "움직임 - 점프/튀기": ['jump', 'bounce', 'hop', 'leap', 'spring', 'skip'],
        "움직임 - 미끄러짐": ['slip', 'slide', 'glide', 'skid', 'slither'],
        
        # 감정/심리
        "감정 - 긍정적": ['happy', 'joy', 'excite', 'thrill', 'delight', 'cheerful', 'elat', 'bliss', 'content', 'satisf'],
        "감정 - 부정적": ['sad', 'angry', 'irritat', 'frustrat', 'annoy', 'upset', 'depress', 'gloomy', 'sulk', 'grumpy', 'furious'],
        "감정 - 불안/긴장": ['nervous', 'anxious', 'worry', 'tense', 'uneasy', 'restless', 'fidget', 'agitat', 'fret', 'panic'],
        "감정 - 두근거림": ['heart', 'pound', 'throb', 'beat', 'flutter', 'palpitat', 'pulse', 'racing'],
        
        # 상태/모양
        "상태 - 빛/광택": ['shiny', 'sparkle', 'glitter', 'gleam', 'glow', 'shimmer', 'twinkle', 'bright', 'dazzl', 'glisten', 'flash', 'flicker'],
        "상태 - 젖음/건조": ['wet', 'damp', 'moist', 'soggy', 'dry', 'parched', 'drenched', 'soaked'],
        "상태 - 부드러움/딱딱함": ['soft', 'fluffy', 'fuzzy', 'smooth', 'hard', 'rigid', 'stiff', 'firm', 'rough', 'coarse'],
        "상태 - 끈적임/미끌거림": ['sticky', 'gooey', 'slimy', 'slippery', 'greasy', 'oily', 'viscous'],
        "상태 - 깔끔/지저분": ['clean', 'neat', 'tidy', 'messy', 'dirty', 'dusty', 'grimy', 'cluttered'],
        
        # 먹기/맛
        "먹기 - 씹기": ['chew', 'munch', 'crunch', 'bite', 'gnaw', 'nibble'],
        "먹기 - 마시기": ['gulp', 'sip', 'slurp', 'drink', 'swallow', 'guzzle'],
        "먹기 - 맛/식감": ['crisp', 'chewy', 'tender', 'tough', 'juicy', 'savory', 'bland'],
        
        # 신체 상태
        "신체 - 피로/졸림": ['tired', 'sleepy', 'drowsy', 'exhaust', 'weary', 'fatigu', 'drows', 'yawn'],
        "신체 - 아픔/불편": ['pain', 'ache', 'hurt', 'sting', 'throb', 'itch', 'tingle', 'numb', 'sore'],
        "신체 - 배고픔/배부름": ['hungry', 'starv', 'full', 'stuff', 'bloat', 'appetite'],
        
        # 날씨/자연
        "날씨 - 비/눈": ['rain', 'drizzle', 'pour', 'snow', 'hail', 'sleet', 'storm'],
        "날씨 - 바람": ['wind', 'breeze', 'gust', 'gale', 'blow'],
        "날씨 - 온도": ['hot', 'cold', 'warm', 'cool', 'chill', 'freeze', 'swelter'],
        
        # 시간/속도
        "속도 - 빠름": ['quick', 'fast', 'rapid', 'swift', 'instant', 'sudden', 'abrupt', 'hasty'],
        "속도 - 느림": ['slow', 'gradual', 'leisur', 'unhurried', 'sluggish'],
        
        # 양/밀도
        "양 - 많음": ['many', 'much', 'plenty', 'abundance', 'swarm', 'crowd', 'pile', 'heap', 'lots'],
        "양 - 적음/희소": ['few', 'little', 'scarce', 'sparse', 'rare', 'thin'],
        
        # 외형/사이즈
        "외형 - 크기": ['big', 'large', 'huge', 'small', 'tiny', 'enormous', 'massive', 'puffy', 'plump', 'swell'],
        "외형 - 모양": ['round', 'flat', 'pointed', 'sharp', 'bulging', 'curved'],
        
        # 성격/태도  
        "태도 - 자신감": ['confident', 'bold', 'proud', 'arrogant', 'boast', 'strut', 'swagger'],
        "태도 - 겸손/소극적": ['shy', 'timid', 'hesitant', 'meek', 'humble', 'modest', 'reserved'],
        "태도 - 불성실": ['lazy', 'idle', 'slack', 'careless', 'sloppy', 'negligent'],
    }
    
    for item in onomatopoeia_list:
        definition_lower = item['definition'].lower()
        matched = False
        
        for category, keywords in category_keywords.items():
            for keyword in keywords:
                if keyword in definition_lower:
                    item['category'] = category
                    matched = True
                    break
            if matched:
                break
        
        if not matched:
            # 기존 카테고리 유지 또는 기타로 분류
            if 'category' not in item or item['category'].startswith('기타'):
                item['category'] = '기타'
    
    return onomatopoeia_list

def add_korean_translations(onomatopoeia_list):
    """한국어 번역 사전 (일부 주요 단어)"""
    
    korean_dict = {
        # 감정 관련
        "ドキドキ": "두근두근",
        "ワクワク": "설레는, 두근두근",
        "イライラ": "짜증나는, 초조한",
        "ムカムカ": "울렁거리는, 화나는",
        "ビクビク": "벌벌 떨리는",
        "ソワソワ": "안절부절못하는",
        "ウキウキ": "들뜬, 신나는",
        "メソメソ": "훌쩍훌쩍 우는",
        "シクシク": "흐느끼는",
        "ゲラゲラ": "껄껄 웃는",
        "ニコニコ": "싱글벙글, 방긋방긋",
        "ニヤニヤ": "히죽히죽",
        "プンプン": "뿌리뿌리 화난",
        "ガミガミ": "잔소리하는",
        
        # 상태/외형
        "ピカピカ": "반짝반짝",
        "キラキラ": "반짝반짝, 빛나는",
        "ツルツル": "매끈매끈",
        "ザラザラ": "까끌까끌, 거친",
        "フワフワ": "푹신푹신, 폭신폭신",
        "モチモチ": "쫄깃쫄깃",
        "サラサラ": "보슬보슬, 술술",
        "ベタベタ": "끈적끈적",
        "ネバネバ": "끈적끈적, 찐득찐득",
        "カチカチ": "딱딱한",
        "グニャグニャ": "물렁물렁",
        "ボロボロ": "너덜너덜",
        "ビショビショ": "흠뻑 젖은",
        "カラカラ": "바싹 마른",
        
        # 움직임
        "ゆっくり": "천천히",
        "のろのろ": "느릿느릿",
        "テキパキ": "척척, 재빠르게",
        "バタバタ": "바쁘게 뛰어다니는",
        "ウロウロ": "어슬렁어슬렁",
        "ブラブラ": "빈둥빈둥, 어슬렁",
        "グルグル": "빙글빙글",
        "クルクル": "빙글빙글",
        "ヨロヨロ": "비틀비틀",
        "フラフラ": "휘청휘청",
        "ドタバタ": "쿵쿵 뛰어다니는",
        
        # 소리
        "ザーザー": "쏴아쏴아 (비)",
        "シトシト": "부슬부슬 (비)",
        "ポツポツ": "뚝뚝 (빗방울)",
        "ゴロゴロ": "우르릉 (천둥), 데굴데굴",
        "ガタガタ": "덜컹덜컹",
        "カタカタ": "달그락달그락",
        "ドンドン": "쿵쿵, 둥둥",
        "バンバン": "탕탕, 빵빵",
        "パチパチ": "짝짝 (박수)",
        "ガチャガチャ": "철커덕철커덕",
        "チリンチリン": "딸랑딸랑",
        "ピンポン": "띵동",
        "ワンワン": "멍멍",
        "ニャーニャー": "야옹야옹",
        "コケコッコー": "꼬끼오",
        "ブーブー": "부릉부릉, 꿀꿀",
        "モーモー": "음메",
        "チュンチュン": "짹짹",
        
        # 먹기
        "パクパク": "냠냠, 야금야금",
        "モグモグ": "오물오물, 냠냠",
        "ガツガツ": "게걸스럽게",
        "ゴクゴク": "꿀꺽꿀꺽",
        "チビチビ": "조금씩 홀짝",
        "バリバリ": "바삭바삭, 우적우적",
        "サクサク": "바삭바삭",
        "カリカリ": "바삭바삭, 아삭아삭",
        
        # 신체 상태
        "グッスリ": "푹, 깊이 (잠)",
        "ウトウト": "꾸벅꾸벅 (졸림)",
        "クタクタ": "녹초가 된",
        "ヘトヘト": "기진맥진",
        "ペコペコ": "배고픈, 꾸벅꾸벅",
        "ムシムシ": "후덥지근한",
        "ジメジメ": "눅눅한, 축축한",
        "ポカポカ": "따스한, 포근한",
        "ヒンヤリ": "서늘한",
        "ゾクゾク": "오싹오싹, 소름끼치는",
        "ガクガク": "덜덜 떨리는",
        "ブルブル": "부들부들 떨리는",
        
        # 일반
        "あっさり": "담백한, 싱거운, 쉽게",
        "こってり": "진한, 기름진",
        "さっぱり": "산뜻한, 깔끔한",
        "しっかり": "확실히, 단단히",
        "すっきり": "상쾌한, 개운한",
        "はっきり": "확실히, 분명히",
        "ぼんやり": "멍하니, 희미하게",
        "うっかり": "깜빡, 무심코",
        "がっかり": "실망한",
        "びっくり": "깜짝 놀란",
        "うんざり": "질린, 지겨운",
        "げっそり": "수척해진",
        "ぐっすり": "푹 (잠)",
        "こっそり": "몰래, 슬쩍",
        "そっくり": "꼭 닮은, 그대로",
        "たっぷり": "듬뿍, 충분히",
        "ぴったり": "딱 맞는",
        "ゆったり": "여유로운, 느긋한",
    }
    
    for item in onomatopoeia_list:
        word = item['word']
        reading = item['reading']
        
        # 카타카나/히라가나 버전 모두 체크
        if word in korean_dict:
            item['korean'] = korean_dict[word]
        elif reading in korean_dict:
            item['korean'] = korean_dict[reading]
        # 카타카나 <-> 히라가나 변환 체크
        elif hiragana_to_katakana(word) in korean_dict:
            item['korean'] = korean_dict[hiragana_to_katakana(word)]
        elif katakana_to_hiragana(word) in korean_dict:
            item['korean'] = korean_dict[katakana_to_hiragana(word)]
    
    return onomatopoeia_list

def hiragana_to_katakana(text):
    """히라가나를 카타카나로 변환"""
    return ''.join(
        chr(ord(c) + 96) if '\u3041' <= c <= '\u3096' else c
        for c in text
    )

def katakana_to_hiragana(text):
    """카타카나를 히라가나로 변환"""
    return ''.join(
        chr(ord(c) - 96) if '\u30A1' <= c <= '\u30F6' else c
        for c in text
    )

def main():
    # 데이터 로드
    with open('onomatopoeia_with_examples.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"Loaded {len(data)} words")
    
    # 카테고리 재분류
    print("\nRecategorizing...")
    data = recategorize_onomatopoeia(data)
    
    # 한국어 번역 추가
    print("Adding Korean translations...")
    data = add_korean_translations(data)
    
    # 카테고리 통계
    categories = {}
    for item in data:
        cat = item['category']
        categories[cat] = categories.get(cat, 0) + 1
    
    print("\nCategory distribution:")
    for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count}")
    
    # 한국어 번역 통계
    korean_count = sum(1 for item in data if item.get('korean'))
    print(f"\nKorean translations: {korean_count}/{len(data)} ({korean_count*100//len(data)}%)")
    
    # 예문 통계
    example_count = sum(1 for item in data if item.get('example'))
    print(f"Examples: {example_count}/{len(data)} ({example_count*100//len(data)}%)")
    
    # 저장
    output_file = 'onomatopoeia_final.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\nSaved to {output_file}")
    
    # 샘플 출력
    print("\n=== 샘플 데이터 ===")
    for item in data[:5]:
        print(f"\n{item['word']} ({item['reading']})")
        print(f"  카테고리: {item['category']}")
        print(f"  영어: {item['definition']}")
        if item.get('korean'):
            print(f"  한국어: {item['korean']}")
        if item.get('example'):
            print(f"  예문: {item['example']}")
        if item.get('example_meaning'):
            print(f"  예문 영어: {item['example_meaning']}")

if __name__ == "__main__":
    main()
