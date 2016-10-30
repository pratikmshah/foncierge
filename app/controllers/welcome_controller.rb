class WelcomeController < ApplicationController

  # import helper files
  include GfinanceHelper
  include FoolHelper
  include InsiderHelper
  include StreetHelper
  include ZingaHelper

  def index
    @google_news = get_google_news
    @fool_news = get_fool_news
    @insider_news = get_insider_news
    @street_news = get_street_news
    #@zinga_news = get_benzinga_news
  end

end
