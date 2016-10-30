module ZingaHelper

# ---------------------------------BENZINGA NEWS
ZINGA_NEWS = "http://www.benzinga.com/best-of-benzinga?page=1"

NEWS = "div.benzinga-articles ul"

BENZINGA = "http://www.benzinga.com"

def get_benzinga_news
  data = []
  doc = get_url_data(ZINGA_NEWS)
  doc = info_to_array(doc.at_css(NEWS))
  doc.pop
  data = parse_benzinga_news(doc)

  return data.transpose
end

private

  # ----------------------------BENZINGA NEWS HELPER

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

  # parse news information get the title, date, excerpt, image src and link
  def parse_benzinga_news(arr)
    result = []
    for i in 1..5 do
      tmp = []                                    # temp data to hold each loop
      arr.each do |data|
        if i == 1
          tmp << data.at_css("h3 a").text.gsub("\n", "")            # title
        elsif i == 2
          tmp << BENZINGA + data.at_css("a").first.last             # url
        elsif i == 3
          tmp << data.at_css("span.date").text.gsub("\n", "")       # date
        elsif i == 4
          tmp << data.at_css("div a img").first.last                # pic src
        else
          tmp << data.at_css("div p").text.gsub("\n", "").strip     # excerpt
        end
      end
      result << tmp
    end
    return result
  end

end