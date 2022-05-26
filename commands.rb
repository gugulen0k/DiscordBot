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
    riot      = RiotApi.new(riot_api_key)
    response  = riot.get_summoner_data(summoner_name, region.downcase)
    response
  rescue => error
    response = JSON.parse(error.response, {:symbolize_names => true})
    puts response.status
    response.status.message
  end
end

bot.run
