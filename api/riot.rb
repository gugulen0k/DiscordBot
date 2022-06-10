require "rest-client"
require "json"
require "uri"

class RiotApi
  def initialize(api_token)
    @token = api_token
  end

  def get_summoner_data(name, region)
    url      = URI.escape("https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{name}")
    get_riot(url)
  end

  def get_champions_stats(summoner_id, region)
    url      = "https://#{region}.api.riotgames.com/lol/champion-mastery/v4/champion-masteries/by-summoner/#{summoner_id}" 
    get_riot(url)
  end

  def get_champions_data
    version  = get_latest_api_version
    get_ddragon("http://ddragon.leagueoflegends.com/cdn/#{version}/data/en_US/champion.json")[:data]
  end

  def get_latest_api_version
    get_ddragon("https://ddragon.leagueoflegends.com/api/versions.json")[0]
  end


  private 

  def get_ddragon(url)
    begin 
      response = RestClient::Request.execute(
        method: :get,
        url:    url,
        headers: {
          "accept":       :json,
          "content_type": :json
        }
      )

      JSON.parse(response, { symbolize_names: true })
    rescue => error
      JSON.parse(error, { symbolize_names: true })
    end
  end

  def get_riot(url)
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
