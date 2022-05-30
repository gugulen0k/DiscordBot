require "discordrb"
require 'discordrb/webhooks'
require "dotenv"
require "json"
require_relative "api/riot"

config  = Dotenv.parse(".env")
discord_api_key = config["DISCORD_API_KEY"]
riot_api_key = config["RIOT_API_KEY"]
bot     = Discordrb::Commands::CommandBot.new(token: discord_api_key, prefix: ">")

bot.command(:get_info, min_args: 2, max_args: 2, description: "Shows base information about LoL player", usage: "get_info [regions(look at the line 'Platform' in table on top)] [summoner_name]") do |event, region, summoner_name|
  begin
    riot     = RiotApi.new(riot_api_key)
    response = riot.get_summoner_data(summoner_name, region.downcase)
    data     = JSON.parse(response, {symbolize_names: true})
    icon     = data[:profileIconId]
    name     = data[:name]
    level    = data[:summonerLevel]
    summoner_data = "Name: #{name}\nLevel: #{level}"

    event.channel.send_embed do |embed|
      embed.title = "```Samira```"

      embed.image = Discordrb::Webhooks::EmbedImage.new(url: "http://ddragon.leagueoflegends.com/cdn/img/champion/splash/Samira_0.jpg")
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://raw.githubusercontent.com/RiotAPI/Riot-Games-API-Developer-Assets/master/champion-mastery-icons/mastery-7.png")

      embed.add_field(name: "Spen time", value: "> 41.7 hours", inline: true)
      embed.add_field(name: "Mastery points", value: "> 412323", inline: true)
      embed.add_field(name: "Mastery level", value: "> 7", inline: true)
    end

    response
  rescue => error
    response = JSON.parse(error, {:symbolize_names => true})
    response[:status][:message]
  end
end

bot.run
