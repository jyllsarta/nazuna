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
      @logger.error("returned status code : #{response_code} " \
                    "query : #{query} " \
                    "response : #{response.body[(0..1000)]}")
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

# interpret input
class CLI
  def main
    return if ARGV.empty?

    search_result = Nazuna.new(access_token).fetch_many(ARGV)
    pretty_print_search_result(search_result)
  end

  private

  def pretty_print_search_result(search_result)
    sortrd_rank = search_result.sort_by { |result| -result.count }
    # KEYWORD 行の文字幅
    keyword_width = max_width(search_result.map(&:query).append('KEYWORD'))
    # TOTAL 行の文字幅
    result_width = max_width(search_result.map(&:query).map(&:to_s).append('TOTAL'))

    # 検索結果を出力する
    print_index_lines(keyword_width, result_width)
    sortrd_rank.each_with_index do |result, index|
      print_content(index + 1, result, keyword_width, result_width)
    end
  end

  # 引数のstring から 最大の文字数を返す
  def max_width(strings)
    strings.map(&:length).max
  end

  # 見出し行を出力する
  def print_index_lines(keyword_width, result_width)
    puts("| RANK | #{'KEYWORD'.center(keyword_width)} | #{'TOTAL'.center(result_width)} |")
    puts("|------|-#{'-' * keyword_width}-|-#{'-' * result_width}-|")
  end

  # 検索結果1行を出力する
  def print_content(rank, search_result, keyword_width, result_width)
    puts("| #{rank.to_s.rjust(4)} | " \
        "#{search_result.query.rjust(keyword_width)} | " \
        "#{search_result.count.to_s.rjust(result_width)} |")
  end

  def access_token
    token = ENV['GITHUB_TOKEN']
    unless token
      raise 'Failed to get access token. ' \
            "Put ENV['GITHUB_TOKEN'] to your GitHub access token."
    end

    token
  end
end

CLI.new.main
