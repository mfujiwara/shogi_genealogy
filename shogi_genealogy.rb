require 'open-uri'
require 'nokogiri'
require 'yaml'

YAML.load_file("complement.yml").each do |info|
  puts "#{info['master']} --> #{info['name']}"
end


(1..312).each do |index|
  next if index == 139
  url = "https://www.shogi.or.jp/player/pro/#{index}.html"

  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end
  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  name = doc.title.split('｜')[0]
  menter = doc.xpath('//table/tbody/tr').select do |n|
    n.children[1].children.text == "師匠" if n.children[1]
  end.first.children[3].children.text
  delete_words = [
    '　',
    '（故）',
    '\(故）',
    '\(故\)',
    '十三世名人',
    '十四世名人',
    '十五世名人',
    '十六世名人',
    '名人',
    '王将',
    '棋聖',
    '実力制第四代',
    '十段',
    '九段',
    '八段',
    '七段',
    '六段',
    '永世',
    '名誉',
    '・'
  ]
  delete_words.each do |word|
    menter = menter.gsub(Regexp.new(word), '')
  end
  name = '廣津久雄' if index == 32
  puts "#{menter} --> #{name}"
  sleep(1)
end
