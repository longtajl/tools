require 'nokogiri'         
require 'open-uri'
require 'pry'
require 'json'
require 'uri'
require 'net/http'

def main

  wday = Date.today.wday
  today = Date.today.day
  if wday == 0 || wday == 6
    p "done"
    exit
  end

  page = Nokogiri::HTML(open("http://obentou.tv/lunch/obentou/201711/"))
  day_menu = page.css('.a_lunch').css('.calendar').css("td").map { |td|
    day = td.css("div[class='date']").text 
    if !day.empty? then
      title = td.css("li").text
      img = td.css("img")
      img_url = img.attribute("src").value unless img.empty?
      [day, title, img_url]
    end
  }.compact.select { |m| m[0].chop.to_i == today }.first
  
  day_of_week = page.css(".weekmenu").css(".calendar_data").css(".calendar").map { |table| table.css("td")[wday] }
  menus = day_of_week.map { |td|
    title = td.css("li").text
    img = td.css("img")
    img_url = img.attribute("src").value unless img.empty?
    ["", title, img_url]
  }

  uri = URI.parse("https://hooks.slack.com/services/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")

  attachments = ([day_menu] + menus).map { |menu| 
    color = menu[0].empty? ? "#36a64f" : "#ff6347"
    text = menu[0].empty? ? "曜日別メニュー" : "日替わりメニュー"
    {
      color: color,
      title: "#{menu[1]}",
      title_link: "http://obentou.tv/lunch/obentou/",
      text: text,
      thumb_url: "#{menu[2]}"
    }  
  }

  day_text = Date.today.strftime("%m月%d日")
  payload = {
    text: "*#{day_text} 弁当TVメニューだよ*",
    channel: "#dev",
    username: "bot",
    icon_emoji: ":ghost:",
    attachments: attachments
  }

  Net::HTTP.post_form(uri, { payload: payload.to_json })

end

if __FILE__ == $0
    p "start"
    main()
    p "done"
end

