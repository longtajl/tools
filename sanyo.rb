# -*- coding: utf-8 -*-

require 'anemone'
require 'mysql2'
require 'pry'

REGEXP = /index_category_donburi|index_category_pokemon|index_category_wafu|index_category_capstar|index_category_other/

list = []
@db = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'rootroot', :database => 'cap')

def download(url, i)
  value = `curl '#{url}' -o 'public/sanyo/#{i}.png'`
  p value
end

def insert(name, img_url, i)
  sql = %{ INSERT INTO cap.cap (id, company_id, name, img_url) VALUES (?, 3, ?, ?) }
  stmt = @db.prepare(sql)
  res = stmt.execute(i, name, img_url)
end

URL = "http://www.sanyofoods.co.jp/products/index_category_donburi.asp"
Anemone.crawl(URL, depth_limit: 1 ) do |anemone|
  anemone.on_pages_like(REGEXP) { |page| 
    #p page.url
    doc = page.doc
    doc.css("#ContentsMainArea").css(".UL-CategoryIndex").css("li").each { |l| 
      title = l.text.chop
      next if title.empty?
      img = "http://www.sanyofoods.co.jp/" + l.css('img').attribute('src').value
      list.push([title, img])
    }
  }
end


list.each_with_index { |c, i|
  index = 209 + 1 + i
  name = c[0]
  img = c[1]
  download(img, index)
  insert(name, img, index)
}

