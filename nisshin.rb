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
    File.open("public/nisshin/" + i.to_s + ".png","wb") do |file|
      file.puts image.read
    end
  }
end

def insert(name, img_url, i)
  sql = %{ INSERT INTO cap.cap (id, company_id, name, img_url) VALUES (?, 1, ?, ?) }
  stmt = @db.prepare(sql)
  res = stmt.execute(i, name, img_url)
end

def main
  page = Nokogiri::HTML(open("https://www.nissin.com/jp/products/items/index.html"))
  list = page.css('.ns-items-list').css('ul')[1..4].css('li').map { |li| [li.css('img').attribute("src").value, li.css('strong').children.text] }
  list.each_with_index { |t, i| 
    download(t[0], i)
    insert(t[1], t[0], i + 1)
  }
end

if __FILE__ == $0
    p "start"
    main()
    p "done"
end

