require 'open-uri'
require 'nokogiri'
require 'yaml'

memo = []
active_player = []
deactive_player = []
dead_player = []
YAML.load_file("complement.yml").each do |info|
  name = info['name']
  master = info['master']
  dead_player << name

  # 師匠
  if master
    memo << (info['uncertain'] ? "#{master} ..> #{name} : uncertain" : "#{master} --> #{name}")
  end
  # 称号
  memo << "#{name} : #{info['title']}"
  # 生没
  memo << "#{name} : #{info['birth'] || '????'} - #{info['death'] || '????'}"
  # 出身地
  memo << "#{name} : #{info['from']}出身" unless info['from'].nil?
end

# 名前から削除する文字一覧
delete_words = ['　', '（故）', '\(故）', '\(故\)',
                '十三世名人', '十四世名人', '十五世名人', '十六世名人', '名人', '王将', '棋聖',
                '実力制第四代', '十段', '九段', '八段', '七段', '六段', '永世', '名誉', '・']
# thの文字列を元にtdの文字列を取得
def node_string(doc, th_text)
  nodes = doc.xpath('//table/tbody/tr').select {|n| n.xpath('th').text == th_text }
  nodes.empty? ? nil : nodes.first.xpath('td').text
end

(1..314).each do |index|
  next if index == 139 # 139は欠番
  url = "https://www.shogi.or.jp/player/pro/#{index}.html"

  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, 'utf8')

  # 名前
  name = index == 32 ? '廣津久雄' : doc.title.split('｜')[0] # 広津の表記となっているため廣津に強制

  # 現役・引退・没後
  rank_dragon = node_string(doc, '竜王戦')
  rank_class = node_string(doc, '順位戦')
  death = node_string(doc, '没年月日')
  if death
    dead_player << name
  elsif !rank_class # 順位戦の記載があれば現役
    deactive_player << name
  else
    active_player << name
  end

  # 称号
  title = doc.css('p').css('.headingElementsA01').text
  memo << "#{name} : #{title}"

  # 棋士番号
  memo << "#{name} : 棋士番号：#{node_string(doc, '棋士番号')}"

  # 生年月日・没年月日
  birth_death = node_string(doc, '生年月日')
  birth_death += "- #{death}" if death
  memo << "#{name} : #{birth_death}"

  # 出身地
  from = node_string(doc, '出身地')
  memo << "#{name} : #{from}出身" if from

  # 所属クラス
  memo << "#{name} : 竜王戦：#{rank_dragon}" if rank_dragon
  memo << "#{name} : 順位戦：#{rank_class}" if rank_class

  # 師匠
  master = node_string(doc, '師匠')
  delete_words.each {|word| master = master.gsub(Regexp.new(word), '') }
  memo << "#{master} --> #{name}"
  sleep(1)
end

active_player.each {|name| puts "object #{name}" } # 現役
deactive_player.each {|name| puts "object #{name} #cccccc" } # 引退
dead_player.each {|name| puts "object #{name} #999999" } # 没後
memo.each {|m| puts m }
