class WelcomeController < ApplicationController

  # import helper files
  include GfinanceHelper
  include FoolHelper
  include InsiderHelper
  include StreetHelper
  include ZingaHelper

  def index
    @google_markets = get_world_markets
    @google_currencies = get_currencies
    @google_bonds = get_bonds
    @google_sector = get_sector_summary
    @google_price = get_price_trends
    @google_marketcap = get_marketcap_trends
    @google_volume = get_volume_trends
    @google_price = get_price_trends
    @google_news = get_google_news
    @fool_news = get_fool_news
    @insider_news = get_insider_news
    @street_news = get_street_news
    @zinga_news = get_benzinga_news
  end

end
