#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

  # Dutch dates
  class Arabic < WikipediaDate
    REMAP = {
      'في المنصب'  => '',
      'يناير'      => 'January',
      'فبرير'      => 'February',
      'فبراير'     => 'February',
      'مارس'       => 'March',
      'أبريل'      => 'April',
      'مايو'       => 'May',
      'يونيو'      => 'June',
      'يوليو'      => 'July',
      'أغسطس'      => 'August',
      'سبتمبر'     => 'September',
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

  def header_column
    'الصورة'
  end

  # No header row in table
  def holder_entries
    noko.xpath("//table[.//td[contains(.,'#{header_column}')]][#{table_number}]//tr[td]").drop(1)
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[no name img title start end].freeze
    end

    def date_class
      Arabic
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
