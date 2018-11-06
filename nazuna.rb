# frozen_string_literal: true

require 'httparty'
require 'logger'

SearchResult = Struct.new(:query, :count)

# calls github api and returns count of the query
class Nazuna
  def initialize(access_token)
    @logger = Logger.new('nazuna.log')
    @access_token = access_token
  end

  def fetch_count(query_word)
    parse_result(fetch(query_word))[:total_count]
  end

  def fetch_many(query_words)
    query_words.map do |query|
      SearchResult.new(query, fetch_count(query))
    end
  end

  private

  # search word and returns parsed response JSON
  def parse_result(response)
    response_code = response.code
    query = response.request.options[:query]
    unless response_code == 200
      @logger.error("returned status code : #{response_code} query : #{query} response : #{response.body[(0..1000)]}")
      raise "returned status code : #{response_code}, query is #{query}"
    end
    @logger.info("query succeeded with: #{response_code}, query is #{query}")
    JSON.parse(response.body, symbolize_names: true)
  end

  def fetch(query_word)
    HTTParty.get(
      'https://api.github.com/search/code',
      headers: {
        'Authorization' => "token #{@access_token}",
        'User-Agent' => 'something original message'
      },
      query: {
        'q' => query_word
      }
    )
  end
end

