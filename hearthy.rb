require 'cinch'
require 'csv'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "Hearthy"  
    c.server          = "irc.sandcat.nl"
    c.channels        = ["#hstest"]
  end

  helpers do
    def hs(m, query)
      # dit moet nog globaler geladen worden XXX
      # cards obtained from http://hearthstonecardlist.com/
      # not complete, e.g. ironfur grizzly is missing
      # open the cards csv file for reading while maintaining column headers and converting numeric values
      cards = CSV.read('cards.csv', :headers => true, :converters=>:numeric)
    
      # search for all instances of query in the Name column
      found_cards = Array.new
      cards.each { |card|
        if (card["Name"].downcase[query.downcase] != nil) then 
          found_cards.push(card)
        end
      }      

      # act depending on the number of found cards
      case found_cards.length
      when 0
        m.reply "\001ACTION heeft niets kunnen vinden :/\001"
      when 1
        p found_cards[0]
        card = found_cards[0]
        m.reply Format(:bold, "%s - #{card["Type"]}" % [Format(:yellow, card["Name"])])

      else
        # stick all cardnames together
        card_array = Array.new
        found_cards.each { |card| card_array.push("[" + card["Name"] + "]") }
        card_array_string = card_array.join(", ")

        # and print them
        m.reply "\001ACTION heeft #{found_cards.length} kaarten gevonden: #{card_array_string}"
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
    m.reply "\001ACTION zoekt naar [#{query}]\001"
    hs(m, query)
  end

  trap "SIGINT" do
    bot.quit
  end
end

bot.start