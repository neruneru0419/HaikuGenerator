require 'twitter'
require 'natto'

class NattoParser
  def initialize
    @nm = Natto::MeCab.new
  end

  def parse(timeline_tweet)
    clause_list = []
    kana_tweet = ''
    cnt = 0
    @nm.parse(timeline_tweet) do |n|
      if n.surface != '' && n.feature[0..1] != '記号' && n.feature[0..3] != 'フィラー'
        clause_list.push({ "clause": n.surface }) # 文節を格納
        kana_tweet = if n.surface.match?(/[一-龠々]/) # 漢字の検知
                       n.feature.gsub(/.*,/, '') # 漢字の読みを抽出
                     else
                       n.surface
                     end
        hiragana_tweet = kana_tweet.tr('ァ-ン', 'ぁ-ん')
        puts hiragana_tweet
        clause_list[cnt][:clause_length] = get_number_of_notes(hiragana_tweet) # 文節の長さを格納
        clause_list[cnt][:part_of_speech] = n.feature.match(/.{1,2}詞/)[0]
        cnt += 1
      end
    end
    return clause_list
  end
end

def get_number_of_notes(sentence)
  abandoned_kana = %w[ぁ ぃ ぅ ぇ ぉ ゃ ゅ ょ] # 捨て仮名を格納
  abandoned_kana.each { |kana| sentence.delete!(kana) }
  sentence.length
end

def chain_notes(sentence_block)
  sum = 0
  five_sentence = []
  seven_sentence = []
  sentence = ''
  start_part_of_speech = ''
  end_part_of_speech = ''

  while sentence_block.empty? == false
    sentence_block.each do |clause_information|
      sum += clause_information[:clause_length]
      sentence += clause_information[:clause]
      start_part_of_speech = clause_information[:part_of_speech] if start_part_of_speech == ''
      next unless (5 == sum) || (7 == sum)

      # print sentence, sum, clause_information[:part_of_speech]
      # puts ''
      if sum == 7
        end_part_of_speech = clause_information[:part_of_speech]
        #print sentence + " " + start_part_of_speech + " " + end_part_of_speech
        #puts ""
        seven_sentence.push(sentence) if start_part_of_speech == '名詞' && (end_part_of_speech == '名詞' || end_part_of_speech == '助詞')
        start_part_of_speech = ''

      elsif sum == 5
        end_part_of_speech = clause_information[:part_of_speech]
        #print sentence + " " + start_part_of_speech + " " + end_part_of_speech
        #puts ""
        five_sentence.push(sentence) if start_part_of_speech == '名詞' && (end_part_of_speech == '名詞' || end_part_of_speech == '助詞')
      end
    end
    sentence_block.delete_at(0)
    sentence = ''
    sum = 0
    start_part_of_speech = ''
  end
  [five_sentence, seven_sentence]
end


def genarate_haiku(notes_length)
  puts notes_length[0].sample
  puts notes_length[1].sample
  puts notes_length[0].sample
end
=begin
natto_parser = NattoParser.new
sentence_block = natto_parser.parse("銀座　8代目けいすけふぐだし潮らーめんお茶漬けめっちゃうまかった٩(๑òωó๑)۶ラーメンって言うよりかは(価格やお茶漬けのクオリティも相まって)日本料理って感じでした……(や、ラーメン自体そうなんだけど、そうじゃなくて)。")
notes_length = chain_notes(sentence_block)
p notes_length
genarate_haiku(notes_length) unless notes_length[0].empty? && notes_length[1].empty?
=end
natto_parser = NattoParser.new
five_sentence = []
seven_sentence = []
client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV['consumer_key']
  config.consumer_secret = ENV['consumer_secret']
  config.access_token    = ENV['access_token']
  config.access_token_secret = ENV['access_token_secret']
end
client.home_timeline({ count: 100, exclude_replies: true, include_rts: false, include_entities: false }).each do |tweet|
  next if tweet.text.include?('http')

  puts tweet.text
  sentence_block = natto_parser.parse(tweet.text)
  notes_length = chain_notes(sentence_block)
  p notes_length
  five_sentence += notes_length[0]
  seven_sentence += notes_length[1] 
end
p five_sentence
p seven_sentence
genarate_haiku([five_sentence, seven_sentence])
