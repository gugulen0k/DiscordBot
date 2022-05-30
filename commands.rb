require "discordrb"
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
    data = JSON.parse(response, {symbolize_names: true})
    pp data
    icon = data[:profileIconId]
    event.channel.send_embed do |embed|
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: "http://ddragon.leagueoflegends.com/cdn/12.10.1/img/profileicon/#{icon}.png")
    end

  rescue => error
    puts error
    response = JSON.parse(error, {:symbolize_names => true})
    response.status.message
  end
end

bot.run
