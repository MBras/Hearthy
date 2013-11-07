require 'cinch'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'cgi'
require 'net/http'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "Hearthy"  
    c.server          = "irc.sandcat.nl"
    c.channels        = ["#hstest"]
  end

  helpers do
    def hs(m, query)
      # get the id
      url = "http://hearthhead.com/search?q=#{CGI.escape(query)}"
      debug url
      id = Net::HTTP.get_response(URI.parse(url))['location'].match('\d+$')
      debug id

      # get the tooltip
      url = "http://hearthhead.com/card=#{id.to_s}&power"
      debug url
      tooltip = Nokogiri::HTML(open(url))

      # name
      name = tooltip.at_css(".q").content
      debug name
      
      # type
      type = tooltip.at_css("th").content
      debug type

      # cost
      cost = tooltip.at_css(".hearthstone-cost").content
      debug cost

      # attack
      attack = tooltip.at_css(".hearthstone-attack").content
      debug attack

      # health
      health = tooltip.at_css(".hearthstone-health").content
      debug health

      # description
      desc = tooltip.at_css(".hearthstone-desc").content.to_s
      debug desc

      m.reply "#{name} - #{type} (#{cost} mana, #{attack} attack, #{health} health)"
      m.reply desc

    rescue
      m.reply "\001ACTION heeft niets kunnen vinden\001"
    else
      CGI.unescape_html "Gevonden: #{title}"
    end
  end

  on :message, /\[(.+)\]/ do |m, query|
    #m.reply "\001ACTION is op zoek naar #{query}\001"
    hs(m, query)
  end

  trap "SIGINT" do
    bot.quit
  end
end

bot.start