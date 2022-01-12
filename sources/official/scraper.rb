#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      # Rana Abd Allah Abd Al-Rahman Al-Faris has an unclosed <h4>
      Name.new(
        full: noko.css('h4').children.first.text.tidy,
        prefixes: %w[His Her Highness Excellency Sheikh Advisor Mr. Dr.],
      ).short
    end

    def position
      noko.css('h5').map(&:text).map(&:tidy).reject { |txt| txt[/^Ministry/] }.flat_map { |posn| posn.split(/ and (?=Minister)/i) }.map(&:tidy)
    end
  end

  class Members
    def member_container
      noko.css('.ms-rtestate-field .BoxContainer')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv if file.exist? && !file.empty?
