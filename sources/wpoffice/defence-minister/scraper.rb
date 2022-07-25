#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

  # Dutch dates
  class Arabic < WikipediaDate
    REMAP = {
      'في المنصب'  => '',
      'يناير'      => 'January',
      'فبراير'     => 'February',
      'مارس'       => 'March',
      'أبريل'      => 'April',
      'MAY'        => 'May',
      'JUNE'       => 'June',
      'JULY'       => 'July',
      'أغسطس'      => 'August',
      'SEPTEMBER'  => 'September',
      'أكتوبر'     => 'October',
      'نوفمبر'     => 'November',
      'ديسمبر'     => 'December',
    }.freeze

    def remap
      REMAP.merge(super)
    end
  end


class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def holder_entries
    # No header row in table
    noko.css('#بعد_التأسيس').xpath('following::table[1]//tr[td]').drop(1)
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[no name img title dates].freeze
    end

    def date_class
      Arabic
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
