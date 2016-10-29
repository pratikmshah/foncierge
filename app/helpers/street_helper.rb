module StreetHelper

# ---------------------------------THE STREET NEWS
STREET_NEWS = "https://www.thestreet.com/latest-news"

NEWS = "ul.news-ticker__list"


def get_street_news
  data = []

  doc = get_url_data(STREET_NEWS)
  doc = doc.at_css(NEWS)
  data = parse_street_news(doc)

  return data.reject { |e| e.empty? }
end

private

  # ----------------------------STREET NEWS HELPER

  # create a nokogiri object without any empty objects
  def get_url_data(url)
    Nokogiri::HTML(open(url))
  end

  # parse news information
  def parse_street_news(arr)
    result = []

    arr.children.each do |el|
      tmp = []

      if el.at_css("a")
        tmp << "https://www.thestreet.com/" + el.at_css("a").attributes["href"].value
        tmp << el.at_css("a").text.gsub("\n", "").strip
      end

      result << tmp
    end

    return result
  end

end