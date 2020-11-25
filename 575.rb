require "twitter"
require "natto"
require "net/http"

#todo
#文章の漢字をmecabで変換
#gooのapiでひらがなに変換
#ブロックを作って読み仮名の長さを取得
class NattoParser
  def initialize()
    @nm = Natto::MeCab.new()
  end

  def get_hiragana_sentence(sentence)
    uri = URI.parse("https://labs.goo.ne.jp/api/hiragana")
    params = {
        app_id: ENV["goo_apikey"],
        sentence: sentence,
        output_type: "hiragana"
    }
    response = Net::HTTP.post_form(uri, params)
    return JSON.parse(response.body)
  end

  def parse(timeline_tweet)
    @analyzed_tweets = Array.new
    kana_tweet = String.new

    @nm.parse(timeline_tweet) do |n|
      if n.surface.match?(/[一-龠々]/) then #漢字の検知
        kana_tweet += n.feature.gsub(/.*,/, "") #漢字の読みを抽出
      else
        kana_tweet += n.surface
      end
    end

    hiragana_tweet = get_hiragana_sentence(kana_tweet)
    @nm.parse(hiragana_tweet["converted"]) do |n|
      @analyzed_tweets.push({"kana": n.surface, "phrase": n.surface})
    end
    return @analyzed_tweets[0..-2] #EOSのブロックを除去
  end
end
def number_of_notes(block)
  kana_lengths = []
  abandoned_kana = ["ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ"] #捨て仮名を格納
  block.each do |phrase|
    abandoned_kana.each{ |kana| phrase[:phrase].delete!(kana)}
    kana_lengths.push(phrase[:phrase].length)
  end
  return kana_lengths
end
def chain_notes(length_list)
  sum = 0
  five_sentence = []
  length_list.each do |length|
    sum += length
    if 5 <= sum then
      five_sentence.push(sum)
      sum = 0
    end
  end
  puts five_sentence
end
natto_parser = NattoParser.new()
kana_block = natto_parser.parse("")
kana_length = number_of_notes(kana_block)
puts kana_block
puts chain_notes(kana_length)
=begin
client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV
  config.consumer_secret = ENV
  config.access_token    = ENV
  config.access_token_secret = ENV
end
timeline_tweet = []
client.home_timeline({count: 100}).each do |tweet|
    timeline_tweet.push(tweet.text)    
end
p timeline_tweet
=end