#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath("//table[.//th[contains(.,'Incumbent')]]//tr[td]")
    end
  end

  class Member
    field :item do
      name_node.attr('wikidata')
    end

    field :name do
      name_node.text
    end

    field :position do
      tds[1].text.split(/ and (?=Minister)/).map(&:tidy)
    end

    field :startDate do
      dates[0]
    end

    field :endDate do
      dates[1].to_s.gsub('2022-05-10', '')
    end

    private

    def tds
      noko.css('td')
    end

    def name_node
      tds[0].css('a').first
    end

    def dates
      tds[3].text.split('–').map(&:tidy).map { |str| Date.parse(str) }
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
