# frozen_string_literal: true

require_relative 'nazuna'

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
    # KEYWORD 行の文字幅(クエリ文字列 と KEYWORD自身の長さの最大値)
    keyword_width = max_width(search_result.map(&:query).append('KEYWORD'))
    # TOTAL 行の文字幅(検索結果の桁数とKEYWORD自身の長さの最大値)
    result_width = max_width(search_result.map(&:count).map(&:to_s).append('TOTAL'))

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
    raise "Failed to get access token. Put ENV['GITHUB_TOKEN'] to your GitHub access token." unless token

    token
  end
end

CLI.new.main
