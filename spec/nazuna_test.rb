# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../nazuna'

describe Nazuna do
  it 'SearchResultを宣言する'
  it 'SearchResultは :query に応答する'
  it 'SearchResultは :count に応答する'
  it 'APIコールをするクラスを引数にとる'
  it 'fetch_count()は注入されたAPIコールクラスでデータを取ってきて、カウントを返す'
  it 'fetch_many()は文字列の配列を引数にとり、検索結果のクラスの配列にして返す'
  it '成功、失敗の結果にかかわらずfetch()すると1行ログに書き込む'
end
