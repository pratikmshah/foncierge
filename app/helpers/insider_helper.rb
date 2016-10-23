module InsiderHelper
  # ---------------------------------BUSINESS INSIDER NEWS
  INSIDER_NEWS = "http://mobile.businessinsider.com/clusterstock"

  # gets business insider news in array with format of title, link, pic and credits
  def get_insider_news
    data = []
    doc = get_url_data(INSIDER_NEWS)
    data << format_news(doc)

    return data
  end

  private

    # ----------------------------BUSINESS INSIDER NEWS HELPER

    # create a nokogiri object without any empty objects
    def get_url_data(url)
      Nokogiri::HTML(open(url))
    end

    def remove_empty(arr)
      arr.delete_if { |e| e.text == "\n" }
    end

    # get headline article
    def format_news(doc)
      result = []
      tmp = []
      tmp << doc.at_css("div.hero div.hero__byline h1").text.gsub("\n", "").gsub("\t", "").strip   # remove esc, tab and white spaces
      tmp << doc.at_css("div.hero div.hero__byline h1 a").attributes["href"].value                 # get url link
      tmp << doc.at_css("div.hero div.hero__image-wrapper a img").attributes["src"].value          # get image link
      result << tmp

      result = format_subnews(doc, result)

      return result
    end

    # get all subarticles
    def format_subnews(doc, result)
      doc = doc.at_css("ul#clusterstock").children

      tmp = []

      doc.each_with_index do |e, i|

        if i.odd? && i != 0 && i != 5 && i != 23                                           # get index and check if odd
          tmp << e.at_css("div.river-post__byline h2").text.strip
          tmp << e.at_css("div.river-post__image-wrapper a").attributes["href"].value
          tmp << e.at_css("div.river-post__image-wrapper a img").attributes["src"].value
          result << tmp                                                                     # transfer
          tmp = []                                                                          # reset
        end

      end

      return result
    end

end