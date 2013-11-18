require 'cinch'
require 'csv'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "Hearthy"  
    c.server          = "irc.sandcat.nl"
    c.channels        = ["#hs"]
  end

  helpers do
    def hs(m, query)
      colors = Hash.new
      colors["Druid"] = :orange
      colors["Mage"] = :royal
      colors["Warlock"] = :purple
      colors["Shaman"] = :blue
      colors["Warrior"] = :red
      colors["Priest"] = :white
      colors["Rogue"] = :yellow
      colors["Hunter"] = :green
      colors["Paladin"] = :pink
      
      # I should perhaps load the list once instead of every query XXX
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
        m.reply "\001ACTION heeft niets kunnen vinden voor [#{query}] :/\001"
      when 1 # one card found
        p found_cards[0]
        card = found_cards[0]

        # first line - name type
        m.reply Format(:bold, "%s - #{card["Type"]}" % [Format(:yellow, card["Name"])])

        # race if applicable
        m.reply Format(:bold, "#{card["Race"]}") if card["Race"] != nil

        # class if applicable
        if card["Class"] != nil and card["Class"] != "All" then 
          m.reply Format(colors[card["Class"]], "#{card["Class"]}")
        end

        # mana and if available, attack and health
        reply = "M:#{card["Mana"]}"
        reply += " A:#{card["Attack"]}" if card["Attack"] != nil
        reply += " H:#{card["Health"]}" if card["Health"] != nil
        m.reply Format(:bold, reply)

        # description if applicable
        m.reply Format(:lime, "#{card["Description"]}") if card["Description"] != nil
      else # when multiple cards look like the search query
        # stick all cardnames together
        card_array = Array.new
        found_cards.each { |card| card_array.push("[" + card["Name"] + "]") }
        card_array_string = card_array.join(", ")

        # and print them
        m.reply "\001ACTION heeft #{found_cards.length} kaarten gevonden: #{card_array_string}"
      end
    end
  end

  on :message, /\[(.+)\]/ do |m, query|
    #m.reply "\001ACTION zoekt naar [#{query}]\001"
    hs(m, query)
  end

  trap "SIGINT" do
    bot.quit
  end
end

bot.start