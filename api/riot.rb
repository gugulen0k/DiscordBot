require "rest-client"

class RiotApi
  def initialize(api_token)
    @token = api_token
  end

  def get_summoner_data(name, region)
    response = RestClient::Request.execute(
      method:  :get,
      url:     "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{name}",
      headers: {
        "X-Riot-Token": @token
      }
    )

    response
  end
end
