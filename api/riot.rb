require "rest-client"
require "json"
require "uri"

class RiotApi
  def initialize(api_token)
    @token = api_token
  end

  def get_summoner_data(name, region)
    url      = URI.escape("https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{name}")
    get(url)
  end

  def get_champions_stats(summoner_id, region)
    url      = "https://#{region}.api.riotgames.com/lol/champion-mastery/v4/champion-masteries/by-summoner/#{summoner_id}" 
    get(url)
  end

  private 

  def get(url)
    begin 
      response = RestClient::Request.execute(
        method: :get,
        url:    url,
        headers: {
          "X-Riot-Token": @token,
          "accept":       :json,
          "content_type": :json
        }
      )

      JSON.parse(response, { symbolize_names: true })
    rescue => error
      JSON.parse(error.response, { symbolize_names: true })[:status][:message]
    end
  end
end
