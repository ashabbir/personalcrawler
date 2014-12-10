require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sanitize'
require 'pry'






HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}
DATA_DIR = "data-hold/nyu"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)


f = File.open("nyu.link", "r")
  f.each_line do |remote_url|
    local_fname = "#{DATA_DIR}/#{File.basename(remote_url)}.dat"
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

  end
  f.close

