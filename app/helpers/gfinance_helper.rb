module GfinanceHelper

# ---------------------------------GOOGLE FINANCE NEWS
G_NEWS = "https://www.google.com/finance/market_news"             # google finance news top 10 stories url
NEWS_SECTION_SELECTOR = 'div#news-main'                           # returns news section html
NEWS_HEADLINE = 'span.name'                                       # returns title headline
NEWS_LINK = 'span.name a'                                         # returns title url
NEWS_SRC = 'div.byline'                                           # returns source of article
NEWS_EXCERPT = 'div.g-c div'                                      # returns article except

# ---------------------------------GOOGLE FINANCE WORLD MARKETS
G_FINANCE_HOMEPAGE = "https://www.google.com/finance"             # google finance world markets
WORLD_MARKET_SELECTOR = 'div#markets div.sfe-section table tbody' # grab table body and list of world markets

#----------------------------------GOOGLE FINANCE CURRENCIES
WORLD_CURRENCIES = 'div#currencies div.sfe-section table tbody'   # grab table body and list of world currencies

#----------------------------------GOOGLE FINANCE BONDS
WORLD_BONDS = 'div#bonds div.sfe-section table tbody'             # grab table body and list of world currencies

#----------------------------------GOOGLE FINANCE SECTOR SUMMARY
SECTOR_SUMMARY = 'div#country-widget'    # grab table body of sector changes

#----------------------------------GOOGLE FINANCE TRENDS
TOP_MOVERS = 'div#topmovers'        # grab trends section
PRICE_MOVER = "div#tm_price_0"      # grab price movers data
MKTCAP_MOVER = "div#tm_mcap_0"   # grab market cap movers

# get top stories from google finance news
def get_google_news
  data = []                                                             # compiled data to return
  doc = get_url_data(G_NEWS)                                            # retrieve html from google finance via nokogiri
  doc = remove_empty(info_to_array(doc.at_css(NEWS_SECTION_SELECTOR)))  # parse and retrieve all of main news and remove "\n" and then ""
  doc.pop # remove more news at the end
  data << parse_data_array(doc, NEWS_HEADLINE, 1)
  data << parse_data_array(doc, NEWS_SRC, 1)
  data << parse_data_array(doc, NEWS_EXCERPT, 1)
  data << parse_data_array(doc, NEWS_LINK, 2)

  return data.transpose
end

# returns list of stock market exchanges
def get_world_markets
  data = []
  doc = get_url_data(G_FINANCE_HOMEPAGE)                               # retrieve html from google finance
  doc = remove_empty(info_to_array(doc.at_css(WORLD_MARKET_SELECTOR))) # parse and retrieve all markets data
  doc.delete_at(11)                                                    # remove empty tr cell
  doc = parse_markets_to_array(doc)                                    # parse the document and return data
  return doc
end

# returns list of currencies
def get_currencies
  data = []
  doc = get_url_data(G_FINANCE_HOMEPAGE)                               # retrieve html from google finance
  doc = remove_empty(info_to_array(doc.at_css(WORLD_CURRENCIES)))      # parse and retrieve all of currencies
  doc = parse_markets_to_array(doc)                                    # parse the document and return data
  return doc
end

# returns bond interest rates
def get_bonds
  data = []
  doc = get_url_data(G_FINANCE_HOMEPAGE)                               # retrieve html from google finance
  doc = remove_empty(info_to_array(doc.at_css(WORLD_BONDS)))           # parse and retrieve all of bond data
  doc.delete_at(2)
  doc = parse_markets_to_array(doc)                                    # parse the document and return data
  return doc
end

# returns the sector changes for the day
def get_sector_summary
  data = []
  doc = get_url_data(G_FINANCE_HOMEPAGE)                               # retrieve html from google finance
  doc = doc.at_css(SECTOR_SUMMARY)                                     # parse and retrieve sector changes
  doc = format_sector_summary(doc)
  return doc
end

# returns top movers in price, market cap and volume
def get_price_trends
  doc = get_url_data(G_FINANCE_HOMEPAGE)
  doc = doc.at_css(TOP_MOVERS)
  doc = parse_trends(doc, PRICE_MOVER)
  return doc
end

# returns top movers in price, market cap and volume
def get_marketcap_trends
  doc = get_url_data(G_FINANCE_HOMEPAGE)
  doc = doc.at_css(TOP_MOVERS)
  doc = parse_trends(doc, MKTCAP_MOVER)
  return doc
end

private

  # ----------------------------GOOGLE FINANCE NEWS HELPER

  # create a nokogiri object without any empty objects
  def get_url_data(url)
    Nokogiri::HTML(open(url))
  end

  # parse information
  def info_to_array(obj)
    arr = obj.children.map do |data|
      if data.text == "\n"
        data = ""
      else
        data
      end
    end
  end

  # remove new line (\n) escape character
  def remove_escape(arr)
    arr.each do |str|
      check = ''
      while check != nil do
       check = str.slice!("\n")
      end
    end
  end

  def remove_empty(arr)
    arr.delete_if { |d| d == "" }
  end

  # parse data and put into array. arr of data to parse and css selector for nokogiri
  def parse_data_array(arr, css, access)
    if access == 1
      arr.map { |el| el.children.at_css("#{css}").text }
    elsif access == 2
      arr.map { |el| el.children.at_css("#{css}").first[1] }
    end
  end

  # parse world markets data to array format
  def parse_markets_to_array(arr)
    result = []
    for i in 1..3 do                              # loop through data 3 times
      tmp = []                                    # temp data to hold each loop
      arr.each do |data|
        if i == 1
          tmp << data.at_css(".symbol").text
                                       .gsub("\n", "")   # first round gather all symbols
        elsif i == 2
          tmp << data.at_css(".price").text
                                      .gsub("\n", "")    # second round gather the price
        else
          tmp << data.at_css(".change").text
                                       .gsub("\n", "")   # third round get the price change
        end
      end
      result << tmp                               # send to results
    end
    return result.transpose
  end

  # sector summary format
  def format_sector_summary(doc)
    doc = doc.children[3].children[1].text.gsub("\n", "").split("%")     # get text and convert to array
    doc.delete_at(0)                                                     # remove first element
    doc.first.gsub!(" down / up", "")                                    # get rid of up/down text

    doc.each do |str|
      if str.include? "+"
        str.gsub!("+", " +")
      elsif str.include? "-"
        str.gsub!("-", " -")
      end

      str << "%"
    end
  end

  # format price trend
  def parse_trends(doc, path)
    # Price Movers formatting
    arr = doc.children.at_css(path).children[1].text        # get data for price movers
    arr = arr.split("\n")                                   # split string into array
    arr.reject! { |e| e.to_s.empty? }                       # remove empty elements

    # modify losers
    arr[arr.index("LosersChange")] = "Change"
    arr[arr.index("Change") - 1] = "Losers"
    arr[arr.index("Losers") - 1] = "Symbol"

    # modify gainers
    arr[0] = "Change"
    arr.unshift("Gainers")
    arr.unshift("Symbol")

    return arr
  end

end