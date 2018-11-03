require "httparty"
require "logger"

SearchResult = Struct.new(:query, :count)

# calls github api and returns count of the query
class Search

  def initialize(access_token)
    @logger = Logger.new("nazuna.log")
    @access_token = access_token
  end

  def fetch_count(query_word)
    fetch(query_word)[:total_count]
  end

  def fetch_many(query_words)
    query_words.map{|query| SearchResult.new(query, fetch_count(query))}
  end

private
  # search word and returns parsed response JSON
  def fetch(query_word)
    response = HTTParty.get(
      "https://api.github.com/search/code",
      headers: { 
        "Authorization" => "token #{@access_token}",
        "User-Agent" => "something original message"
      },
      query: {
        "q" => query_word
      }
    )
    if response.code == 200
      @logger.info("query succeeded with: #{response.code}, query is #{query_word}")
      return JSON.parse(response.body, symbolize_names: true)
    else
      @logger.error("returned status code: #{response.code}, query is #{query_word}")
      @logger.error("response : #{response.body[(0..1000)]}")
      raise RuntimeError, "returned status code: #{response.code}, query is #{query_word}"
    end
  end
end

# interpret input
class CLI
  def main
    return if ARGV.length == 0
    token = get_access_token
    search_result = Search.new(token).fetch_many(ARGV)
    pretty_print_search_result(search_result)
  end

  private
  def pretty_print_search_result(search_result)
    top_to_bottom = search_result.sort_by{|result| -result.count}
    max_query_length = [search_result.map{|result| result.query.length}.max, "KEYWORD".length].max
    max_digits_of_result = [search_result.map{|result| result.count.to_s.length}.max, "TOTAL".length].max

    puts("| #{"RANK"} | #{"KEYWORD".center(max_query_length)} | #{"TOTAL".center(max_digits_of_result)} |")
    puts("|------|-#{"-"*max_query_length}-|-#{"-"*max_digits_of_result}-|")
    top_to_bottom.each_with_index{|result, index|
      puts("| #{(index+1).to_s.rjust(4)} | #{result.query.rjust(max_query_length)} | #{result.count.to_s.rjust(max_digits_of_result)} |")
    }
  end

  def get_access_token
    token = ENV['GITHUB_TOKEN']
    if !token
      raise RuntimeError, "Failed to get access token. Make sure to put access token in Environental Variable 'GITHUB_TOKEN'."
    end
    return token
  end
end

CLI.new().main