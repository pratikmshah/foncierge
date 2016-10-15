module ZingaHelper

# ---------------------------------BENZINGA NEWS
ZINGA_NEWS = "http://www.benzinga.com/best-of-benzinga?page=1"

NEWS = "div.benzinga-articles ul"

def get_benzinga_news
  data = []
  doc = get_url_data(ZINGA_NEWS)
  doc = info_to_array(doc.at_css(NEWS))
  doc.pop
  doc = remove_empty(doc)
  #data = parse_benzinga_news(doc)

  return doc
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

  def remove_empty(arr)
    arr.delete_if { |e| e.text == "\n  \n    " }
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
          tmp << data.at_css("a").first.last                        # url
        elsif i == 3
          tmp << data.at_css("h3 span.date").text.gsub("\n", "")    # date
        elsif i == 4
          tmp << data.at_css("div a img").first.last                # pic src
        else
          tmp << data.at_css("div p").text.gsub("\n", "")           # excerpt
        end
      end
      result << tmp
    end
  end

end