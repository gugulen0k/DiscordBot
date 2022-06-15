require "rest-client"
require "json"

class DdragonApi
  def get_champions_data
    version  = get_latest_api_version
    get("http://ddragon.leagueoflegends.com/cdn/#{version}/data/en_US/champion.json")[:data]
  end

  def get_latest_api_version
    get("https://ddragon.leagueoflegends.com/api/versions.json")[0]
  end

  private 

  def get(url)
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
end
