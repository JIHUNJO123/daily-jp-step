#!/usr/bin/env python3
"""
Tatoeba 데이터 처리 및 의성어/의태어 예문 매칭
License: CC-BY 2.0 (Tatoeba)
"""

import bz2
import tarfile
import json
import os
import re
from collections import defaultdict

def extract_bz2(bz2_file, output_file):
    """bz2 파일 압축 해제"""
    print(f"Extracting {bz2_file}...")
    with bz2.open(bz2_file, 'rt', encoding='utf-8') as f:
        content = f.read()
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"  -> {output_file}")

def extract_tar_bz2(tar_file, output_dir='.'):
    """tar.bz2 파일 압축 해제"""
    print(f"Extracting {tar_file}...")
    with tarfile.open(tar_file, 'r:bz2') as tar:
        tar.extractall(output_dir)
    print(f"  -> extracted to {output_dir}")

def load_sentences(tsv_file):
    """문장 파일 로드 (id -> text)"""
    sentences = {}
    with open(tsv_file, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) >= 3:
                sent_id = parts[0]
                text = parts[2]
                sentences[sent_id] = text
    return sentences

def load_links(links_file):
    """번역 링크 파일 로드"""
    links = defaultdict(list)
    with open(links_file, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) >= 2:
                src_id, tgt_id = parts[0], parts[1]
                links[src_id].append(tgt_id)
    return links

def find_examples_for_word(word, jpn_sentences):
    """단어가 포함된 예문 찾기"""
    examples = []
    # 정확한 단어 매칭 (히라가나/카타카나 모두 검색)
    for sent_id, text in jpn_sentences.items():
        if word in text:
            examples.append((sent_id, text))
            if len(examples) >= 5:  # 최대 5개
                break
    return examples

def main():
    # 1. 압축 해제
    if not os.path.exists('jpn_sentences.tsv'):
        extract_bz2('jpn_sentences.tsv.bz2', 'jpn_sentences.tsv')
    
    if not os.path.exists('eng_sentences.tsv'):
        extract_bz2('eng_sentences.tsv.bz2', 'eng_sentences.tsv')
    
    if not os.path.exists('kor_sentences.tsv'):
        extract_bz2('kor_sentences.tsv.bz2', 'kor_sentences.tsv')
    
    if not os.path.exists('links.csv'):
        extract_tar_bz2('links.tar.bz2')
    
    # 2. 데이터 로드
    print("\nLoading sentences...")
    jpn_sentences = load_sentences('jpn_sentences.tsv')
    print(f"  Japanese sentences: {len(jpn_sentences)}")
    
    eng_sentences = load_sentences('eng_sentences.tsv')
    print(f"  English sentences: {len(eng_sentences)}")
    
    kor_sentences = load_sentences('kor_sentences.tsv')
    print(f"  Korean sentences: {len(kor_sentences)}")
    
    print("\nLoading links...")
    links = load_links('links.csv')
    print(f"  Links loaded: {len(links)}")
    
    # 3. 의성어/의태어 데이터 로드
    print("\nLoading onomatopoeia data...")
    with open('onomatopoeia_data.json', 'r', encoding='utf-8') as f:
        onomatopoeia = json.load(f)
    print(f"  Words: {len(onomatopoeia)}")
    
    # 4. 예문 매칭
    print("\nMatching examples...")
    matched_count = 0
    
    for i, word_data in enumerate(onomatopoeia):
        word = word_data['word']
        reading = word_data['reading']
        
        # 단어 또는 읽기로 예문 검색
        search_terms = [word]
        if reading and reading != word:
            search_terms.append(reading)
        
        for search_term in search_terms:
            examples = find_examples_for_word(search_term, jpn_sentences)
            
            if examples:
                sent_id, jpn_text = examples[0]
                word_data['example'] = jpn_text
                
                # 영어 번역 찾기
                if sent_id in links:
                    for linked_id in links[sent_id]:
                        if linked_id in eng_sentences:
                            word_data['example_meaning'] = eng_sentences[linked_id]
                            break
                        if linked_id in kor_sentences:
                            word_data['example_korean'] = kor_sentences[linked_id]
                
                matched_count += 1
                break
        
        if (i + 1) % 100 == 0:
            print(f"  Processed {i + 1}/{len(onomatopoeia)} words...")
    
    print(f"\n예문 매칭 완료: {matched_count}/{len(onomatopoeia)} ({matched_count*100//len(onomatopoeia)}%)")
    
    # 5. 저장
    output_file = 'onomatopoeia_with_examples.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(onomatopoeia, f, ensure_ascii=False, indent=2)
    print(f"\nSaved to {output_file}")
    
    # 샘플 출력
    print("\n샘플 데이터:")
    for item in onomatopoeia[:3]:
        print(f"\n  {item['word']} ({item['reading']})")
        print(f"    뜻: {item['definition']}")
        if item.get('example'):
            print(f"    예문: {item['example']}")
        if item.get('example_meaning'):
            print(f"    영어: {item['example_meaning']}")

if __name__ == "__main__":
    main()
