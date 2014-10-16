require 'pocket_api'

class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    PocketApi.configure(:client_key => ENV["POCKET_APP_ID"], :access_token => current_user.token)
    @articles = PocketApi.retrieve({:state => 'all'})
  end
end
