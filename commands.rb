require "discordrb"
require 'discordrb/webhooks'
require "dotenv"
require "json"
require "uri"
require_relative "api/riot"

config          = Dotenv.parse(".env")
discord_api_key = config["DISCORD_API_KEY"]
riot_api_key    = config["RIOT_API_KEY"]
bot             = Discordrb::Commands::CommandBot.new(token: discord_api_key, prefix: "!")
$riot           = RiotApi.new(riot_api_key)

bot.command(
          :get_info,
          min_args:    2,
          description: "Shows base information about LoL player",
          usage:       "get_info [regions(look at the line 'Platform' in table on top)] [summoner_name]"
  ) do |event, region, *summoner_name|

  begin
    data                 = $riot.get_summoner_data(summoner_name.join(" "), region)
    champions_data       = $riot.get_champions_stats(data[:id], region)

    icon                 = data[:profileIconId]
    name                 = data[:name]
    level                = data[:summonerLevel]
    icon_url             = profile_icon_link(icon)

    champions            = filter_champions_info(champions_data)
    final_champions_data = get_champions_image_urls(champions)

    send_summoner_message(event, name, level, icon_url)
    final_champions_data.each do |champion|
      send_champion_message(
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
    send_error_message(event, error)
  end
end

def send_error_message(event, message)
  event.channel.send_embed do |embed|
    embed.colour = 0xf52565
    embed.add_field(name: "Error", value: message, inline: false)
  end
end

def send_summoner_message(event, name, level, thumbnail_url)
  event.channel.send_embed do |embed|
    embed.colour = 0xfff75e
    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: thumbnail_url)
    
    embed.add_field(name: "Name",  value: "> #{name}",  inline: false)
    embed.add_field(name: "Level", value: "> #{level}", inline: false)
  end
end

def get_champions_image_urls(champions)
  data = $riot.get_champions_data
  champions.each do |champion|
    data.each do |key, value|
      champion[:image_url] = champion_image_url(value[:id]) if value[:key] == champion[:id].to_s
      champion[:name]      = value[:name] if value[:key] == champion[:id].to_s
    end
  end
end

def convert_time_to_hrs_and_min(duration)
  days    = duration / (1000 * 60 * 60 * 60)
  hours   = duration / (1000 * 60 * 60)
  "#{days}d #{hours}h" 
end

def filter_champions_info(champions)
  top_3_champions = []
  champions[0..2].each do |champion|
    current_time  = Time.now.strftime("%s%L")
    total_time    = current_time.to_i - champion[:lastPlayTime].to_i
    champion_info = {
      id:                champion[:championId],
      level:             champion[:championLevel],
      points:            champion[:championPoints],
      total_played_time: convert_time_to_hrs_and_min(total_time)
    }
    top_3_champions.append(champion_info)
  end
  top_3_champions
end

def profile_icon_link(icon_id)
  latest_version = $riot.get_latest_api_version
  "http://ddragon.leagueoflegends.com/cdn/#{latest_version}/img/profileicon/#{icon_id}.png"
end

def champion_image_url(name)
  "http://ddragon.leagueoflegends.com/cdn/img/champion/splash/#{name}_0.jpg"
end

def send_champion_message( 
                        event,
                        champion_name, 
                        spent_time, 
                        mastery_points, 
                        mastery_level, 
                        image_url 
    )

    event.channel.send_embed do |embed|
      embed.colour = 0xfff75e
      embed.title     = "`*#{champion_name}*`"
      embed.image     = Discordrb::Webhooks::EmbedImage.new(url: image_url)
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://raw.githubusercontent.com/RiotAPI/Riot-Games-API-Developer-Assets/master/champion-mastery-icons/mastery-#{mastery_level}.png")

      embed.add_field(name: "Last play time", value: "> #{spent_time}",     inline: true)
      embed.add_field(name: "Mastery points", value: "> #{mastery_points}", inline: true)
      embed.add_field(name: "Mastery level",  value: "> #{mastery_level}",  inline: true)
    end
end

bot.run
