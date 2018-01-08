require 'nokogiri'         
require 'open-uri'
require 'pry'
require 'json'
require 'uri'
require 'net/http'

def main
  page = Nokogiri::HTML(open("http://www.bento-shogun.jp/menu/today/index.html"))
  binding.pry
end

if __FILE__ == $0
    p "start"
    main()
    p "done"
end

