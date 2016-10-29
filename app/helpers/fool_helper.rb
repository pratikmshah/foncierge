module FoolHelper

  # ---------------------------------MOOTLY FOOL MONEY NEWS
  FOOL_NEWS = "http://www.fool.com/investing-news/"
  FOOL = "http://www.fool.com"

  NEWS1 = "div.article-listing div.top-stories div#page-1"
  NEWS2 = "div.article-listing div.top-stories div#page-2"

  # gets business insider news in array with format of title, link, pic and credits
  def get_fool_news
    data = []
    doc = get_url_data(FOOL_NEWS)
    data = parse_fool_news(doc, NEWS1, data)
    #data = parse_fool_news(doc, NEWS2, data)

    return data.reject { |e| e.empty? }
  end

  private

    # ----------------------------MOOTLY FOOL MONEY HELPER

    # create a nokogiri object without any empty objects
    def get_url_data(url)
      Nokogiri::HTML(open(url))
    end

    # parse and get motley fool news
    def parse_fool_news(doc, link, result)
      tmp = []
      doc.at_css(link).children.each do |el|
        puts el.text
        if el.at_css("a")
          tmp << el.at_css("a").text.gsub("\n", "").gsub("\t", "").strip  # get title
          tmp << FOOL + el.at_css("a").first.last                         # get url
        end

        if el.at_css("p")
          tmp << el.at_css("p").text.gsub("\n", "").gsub("\t", "").strip  # get excerpt
          tmp << el.at_css("p.author-byline").text.gsub("\n", "").gsub("\t", "").strip # credits
        end

        result << tmp
        tmp = []

      end

      return result
    end
end