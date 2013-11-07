require 'cinch'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'cgi'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "Hearthy"  
    c.server          = "irc.sandcat.nl"
    c.channels        = ["#hstest"]
  end

  helpers do
    def hs(query)
      # extract the tooltip
      page    = Nokogiri::HTML(open("http://hearthhead.com/search?q=#{CGI.escape(query)}"))
      tooltip = page.at_css('.wowhead-tooltip')

      debug tooltip.to_s


      



      
    rescue
      "\001ACTION heeft niets kunnen vinden\001"
    else
      CGI.unescape_html "Gevonden: #{title}"
    end
  end

  on :message, /\[(.+)\]/ do |m, query|
    m.reply "\001ACTION is op zoek naar #{query}\001"
    m.reply hs(query)
  end

  trap "SIGINT" do
    bot.quit
  end
end

bot.start