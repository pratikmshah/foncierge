module ZingaHelper

# ---------------------------------BENZINGA NEWS
ZINGA_NEWS = "http://www.benzinga.com/best-of-benzinga?page=1"

NEWS = "div.benzinga-articles ul"

def get_benzinga_news
  data = []
  doc = get_url_data(ZINGA_NEWS)

  return doc
end

end