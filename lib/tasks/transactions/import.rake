#! /usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "monetize"

require_relative "french_date_parser"

namespace :transactions do
  desc "Import transactions from Bankin dashboard HTML export"
  task :import => :environment do
    TransactionFile.open do |file|
      document = Nokogiri::HTML(file, nil, Encoding::UTF_8.to_s)
    
      transactions = document.css("li").map do |tag|
        id = tag.attr("id")
        next unless id
    
        TransactionParser.new(id: id, tag: tag).to_model
      end

      Transaction.import transactions.compact, on_duplicate_key_ignore: true, batch_size: 1000
    end
  end
end

class TransactionFile
  FILENAME = "export-20190802.html"

  def self.open
    File.open path do |file|
      yield file
    end
  end

  private

  def self.path
    File.join(Rails.root, "tmp", FILENAME)
  end
end

class TransactionParser
  BANKIN_ID_PREFIX = "transaction_"

  TITLE_SELECTOR = ".dbl.fw6.elp"
  AMOUNT_SELECTOR = ".amount"
  DATE_SELECTOR = ".headerDate"
  CATEGORY_SELECTOR = ".dbl.fs08.fc2a.elp.text"

  DEFAULT_CURRENCY_SIGN = "€"
  DEFAULT_CURRENCY_DELEMITER = ","
  STANDARD_CURRENCY_DELEMITER = "."

  attr_reader :id

  def initialize(id:, tag:)
    @id = id
    @tag = tag
  end

  def to_model
    Transaction.new(
      bankin_id: bankin_id,
      title: title,
      date: date,
      amount: amount
    )
  end

  private

  def bankin_id
    @_bankin_id = id.remove(BANKIN_ID_PREFIX)
  end

  def title
    @_title ||= tag.css(TITLE_SELECTOR).last.text
  end

  def amount
    @_amount ||= tag
      .css(AMOUNT_SELECTOR)
      .text
      .remove(DEFAULT_CURRENCY_SIGN)
      .gsub(DEFAULT_CURRENCY_DELEMITER, STANDARD_CURRENCY_DELEMITER)
      .strip
      .to_money
  end

  def date
    @_date ||= FrenchDateParser.new(
      tag
        .css(DATE_SELECTOR)
        .last
        .text
        .strip
    ).parse
  end

  def category
    @_category = tag.css(CATEGORY_SELECTOR).last.text
  end

  attr_reader :tag
end
