require 'nokogiri'         
require 'open-uri'
require 'pry'
require 'json'
require 'uri'
require 'net/http'
require 'mysql2'

@db = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'rootroot', :database => 'cap')

def download(url, i)
  open(url) { |image|
    File.open("public/myojo/" + i.to_s + ".png","wb") do |file|
      file.puts image.read
    end
  }
end

def insert(name, img_url, i)
  sql = %{ INSERT INTO cap.cap (id, company_id, name, img_url) VALUES (?, 4, ?, ?) }
  stmt = @db.prepare(sql)
  res = stmt.execute(i, name, img_url)
end

def main(index)
  page = Nokogiri::HTML(open("https://www.myojofoods.co.jp/products/search/list.html?ref_page=srch&atr_14%5B%5D=2&x=85&y=17&p="+index.to_s))
  page.css('.search_list_box').map { |b| 
    [b.css('a').text.strip, b.css('.image').css('img').attribute('src').value]
  }
end

if __FILE__ == $0
    p "start"
    (1..8).map { |index| main(index) }.flatten(1).each_with_index { |c, index| 
      id = index + 256 + 1
      title, img = c[0], c[1]
      insert(title, img, id)
      download(img, id)
    }
    p "done"
end

