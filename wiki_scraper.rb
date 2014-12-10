require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sanitize'
require 'pry'

DATA_DIR = "data-hold/nobel"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

BASE_WIKIPEDIA_URL = "http://en.wikipedia.org"
LIST_URL = "#{BASE_WIKIPEDIA_URL}/wiki/List_of_Nobel_laureates"

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

page = Nokogiri::HTML(open(LIST_URL))
rows = page.css('div.mw-content-ltr table.wikitable tr')

rows[1..-2].each do |row|

  hrefs = row.css("td a").map{ |a|
    a['href'] if a['href'] =~ /^\/wiki\//
  }.compact.uniq

  hrefs.each do |href|
    remote_url = BASE_WIKIPEDIA_URL + href
    local_fname = "#{DATA_DIR}/#{File.basename(href)}.dat"
    unless File.exists?(local_fname)
      puts "Fetching #{remote_url}..."
      begin
        wiki_content = open(remote_url, HEADERS_HASH).read
      rescue Exception=>e
        puts "Error: #{e}"
        sleep 5
      else
        text = Sanitize.clean(wiki_content, :remove_contents => ['style','script'])
        text = Sanitize.clean(text)
        text = text.strip
        text.delete!("\t")
        text.delete!("\"")
        lst = text.split(/\n/)
        text = ""
        lst.each do |x|
          if x.to_s != ""
            text << x
          end
        end
        File.open(local_fname, 'w'){|file| file.write(text)}
        puts "\t...Success, saved to #{local_fname}"
      ensure
        sleep 1.0 + rand
      end  # done: begin/rescue
    end # done: unless File.exists?

  end # done: hrefs.each
end # done: rows.each
