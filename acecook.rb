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
    File.open("public/acecook/" + i.to_s + ".png","wb") do |file|
      file.puts image.read
    end
  }
end

def insert(name, img_url, i)
  sql = %{ INSERT INTO cap.cap (id, company_id, name, img_url) VALUES (?, 5, ?, ?) }
  stmt = @db.prepare(sql)
  res = stmt.execute(i, name, img_url)
end

def main(index)
  page = Nokogiri::HTML(open("http://www.acecook.co.jp/products/list.php?p="+index.to_s))
  page.css('.itemList').css('li').map { |li| 
    [li.css('a').text, li.css('img').attribute('src').text]
  }
end

if __FILE__ == $0
    p "start"
    (0..11).map { |i| main(i*10) }.flatten(1).each_with_index { |c, index| 
      id = index + 331 + 1
      title, img = c[0], c[1]
      insert(title, img, id)
      download(img, id)
    }
    p "done"
end

