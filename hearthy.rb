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
      id = CGI.escape(query)
      # get the id
      #url = "http://hearthhead.com/search?q=#{CGI.escape(query)}"
      #debug url
      #id = Net::HTTP.get_response(URI.parse(url))['location'].match('\d+$')
      debug "Card id is #{id}"

      # get the tooltip
      url = "http://hearthhead.com/card=#{id.to_s}&power"
      debug url
      tooltip = Nokogiri::HTML(open(url))

      begin #extract name and type
        # name
        name = tooltip.at_css(".q").content
        debug name
        
        # type
        type = tooltip.at_css("th").content
        debug type

        m.reply Format(:bold, "%s - #{type}" % [Format(:bold, :yellow, name)])
      rescue
        debug "Something wrong with name or type"
      end

      begin
        # cost
        mana = tooltip.at_css(".hearthstone-cost").content
        debug mana

        # attack
        attack = tooltip.at_css(".hearthstone-attack").content
        debug attack

        # health
        health = tooltip.at_css(".hearthstone-health").content
        debug health

        # ability
        ability = tooltip.at_css(".hearthstone-desc .q2").content
        debug ability

        # flavor
        flavor = tooltip.at_css(".hearthstone-desc .q").content
        debug flavor

        m.reply Format(:bold, "M:#{mana} A:#{attack} H:#{health}")
        m.reply Format(:lime, "#{ability}")
      rescue
        debug "Something went wrong..."
      end
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