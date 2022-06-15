require_relative "../messages/embed_message"
require_relative "../api/riot"
require_relative "../api/ddragon"

class GetInfo
  def initialize(riot_api_key)
    @riot    = RiotApi.new(riot_api_key)
    @ddragon = DdragonApi.new
    @message = EmbedMessage.new
  end

  def run(bot)
    bot.command(
              :get_info,
              min_args:    2,
              description: "Shows base information about LoL player",
              usage:       "get_info [regions(look at the line 'Platform' in table on top)] [summoner_name]"
      ) do |event, region, *summoner_name|

      begin
        data                 = @riot.get_summoner_data(summoner_name.join(" "), region)
        champions_data       = @riot.get_champions_stats(data[:id], region)

        icon                 = data[:profileIconId]
        name                 = data[:name]
        level                = data[:summonerLevel]
        icon_url             = profile_icon_link(icon)

        champions            = filter_champions_info(champions_data)
        final_champions_data = get_champions_image_urls(champions)

        @message.send_summoner_message(event, name, level, icon_url)
        final_champions_data.each do |champion|
          @message.send_champion_message(
                            event,
                            champion&.[](:name), 
                            champion&.[](:total_played_time),
                            champion&.[](:points), 
                            champion&.[](:level), 
                            champion&.[](:image_url) 
          )
        end

        nil

      rescue => error
        binding.pry
        @message.send_error_message(event, error)
      end
    end
  end

  private

  def get_champions_image_urls(champions)
    data = @ddragon.get_champions_data
    champions.each do |champion|
      data.each do |key, value|
        champion[:image_url] = champion_image_url(value[:id]) if value[:key] == champion[:id].to_s
        champion[:name]      = value[:name] if value[:key] == champion[:id].to_s
      end
    end
  end

  def convert_to_date(duration)
    Time.at(duration / 1000).strftime("%Y-%m-%d %H:%M:%S")
  end

  def filter_champions_info(champions)
    top_3_champions = []
    champions[0..2].each do |champion|
      champion_info = {
        id:                champion[:championId],
        level:             champion[:championLevel],
        points:            champion[:championPoints],
        total_played_time: convert_to_date(champion[:lastPlayTime])
      }
      top_3_champions.append(champion_info)
    end
    top_3_champions
  end

  def profile_icon_link(icon_id)
    latest_version = @ddragon.get_latest_api_version
    "http://ddragon.leagueoflegends.com/cdn/#{latest_version}/img/profileicon/#{icon_id}.png"
  end

  def champion_image_url(name)
    "http://ddragon.leagueoflegends.com/cdn/img/champion/splash/#{name}_0.jpg"
  end
end
