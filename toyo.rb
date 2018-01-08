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
    File.open("public/toyo/" + i.to_s + ".png","wb") do |file|
      file.puts image.read
    end
  }
end

def insert(name, img_url, i)
  sql = %{ INSERT INTO cap.cap (id, company_id, name, img_url) VALUES (?, 2, ?, ?) }
  stmt = @db.prepare(sql)
  res = stmt.execute(i, name, img_url)
end

def main(index)
  page = Nokogiri::HTML(open("http://www.maruchan.co.jp/products/category/index.html?action_search_list=true&c_id=0103&p="+index.to_s))
  page.css('.rConWrap01').css('.setL').map { |t, i| 
    title = t.css('.txtFloat').css('dt').text
    img = "http://www.maruchan.co.jp/" + t.css('img').attribute("src").value 
    [title, img]
  }
end

if __FILE__ == $0
    p "start"
    (1..7).map { |index| main(index) }.flatten(1).each_with_index { |c, index| 
      id = index + 144 + 1
      title, img = c[0], c[1]
      insert(title, img, id)
      download(img, id)
    }
    p "done"
end

