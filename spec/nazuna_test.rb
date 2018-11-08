# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../nazuna'

describe Nazuna do
  it 'SearchResultを宣言する' do
    expect{SearchResult.new}.not_to raise_error
  end

  it 'SearchResultは :query に応答する' do
    expect(SearchResult.new.respond_to?(:query)).to be true
  end

  it 'SearchResultは :count に応答する' do
    expect(SearchResult.new.respond_to?(:count)).to be true
  end

  it 'APIを叩くクラスを引数にとって成立する' do
    expect{Nazuna.new(StubAPI.new)}.not_to raise_error
  end

  it 'fetch_count()は注入されたAPIコールクラスでデータを取ってきて、カウントを返す' do
    nazuna = Nazuna.new(StubAPI.new)
    expect(Nazuna.new(StubAPI.new).fetch_count("something")).to eq 100
  end

  it 'fetch_many()は文字列の配列を引数にとり、検索結果のクラスの配列にして返す' do
    result = Nazuna.new(StubAPI.new).fetch_many(["something", "three", "words"])
    expect(result.map(&:query)).to eq ["something", "three", "words"]
    expect(result.map(&:count)).to eq [100, 100, 100]
  end
end
