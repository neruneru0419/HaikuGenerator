require "twitter"
require "natto"
require "net/http"


#{文節, 文節の長さ, 品詞}
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
    clause_list = Array.new
    kana_tweet = String.new
    cnt = 0
    @nm.parse(timeline_tweet) do |n|
        if n.surface != "" then
            clause_list.push({"clause": n.surface}) #文節を格納
            if n.surface.match?(/[一-龠々]/) then #漢字の検知
                kana_tweet = n.feature.gsub(/.*,/, "") #漢字の読みを抽出
            else
                kana_tweet = n.surface
            end
            hiragana_tweet = get_hiragana_sentence(kana_tweet)
            clause_list[cnt][:clause_length] = get_number_of_notes(hiragana_tweet["converted"]) #文節の長さを格納
            clause_list[cnt][:part_of_speech] = n.feature.match(/.{1,2}詞/)[0]
            cnt += 1
        end
    end
    p clause_list
    return clause_list[0..-2] #EOSのブロックを除去
  end
end
def get_number_of_notes(sentence)
  abandoned_kana = ["ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ"] #捨て仮名を格納
  abandoned_kana.each{ |kana| sentence.delete!(kana)}
  return sentence.length
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
end
natto_parser = NattoParser.new()
kana_block = natto_parser.parse("仕事終わってギター弾いてたらこんな時間")
#kana_length = number_of_notes(kana_block)
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