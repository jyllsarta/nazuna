# frozen_string_literal: true

require 'httparty'
require 'logger'

SearchResult = Struct.new(:query, :count)

# calls github api and returns count of the query
class Nazuna
  # 通信部分を外してテストしたいのでAPIDelegatorは外に逃がします
  def initialize(api_delegator)
    @api_delegator = api_delegator
  end

  def fetch_count(query_word)
    @api_delegator.fetch(query_word)[:total_count]
  end

  def fetch_many(query_words)
    query_words.map do |query|
      SearchResult.new(query, fetch_count(query))
    end
  end
end

# APIを叩いてレスポンスを得る
class GitHubAPIDelegator
  def initialize(access_token, logger)
    raise "Failed to get access token. Put ENV['GITHUB_TOKEN'] to your GitHub access token." unless access_token

    @access_token = access_token
    @logger = logger
  end

  def fetch(query_word)
    parse_result(call_search_api(query_word))
  end

  private

  def call_search_api(query_word)
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
end
