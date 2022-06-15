require "discordrb"
require 'discordrb/webhooks'
require "dotenv"
require_relative "api/riot"
require_relative "api/ddragon"

config          = Dotenv.parse(".env")
discord_api_key = config["DISCORD_API_KEY"]
riot_api_key    = config["RIOT_API_KEY"]
bot             = Discordrb::Commands::CommandBot.new(token: discord_api_key, prefix: "!")
$riot           = RiotApi.new(riot_api_key)
$ddragon        = DdragonApi.new




bot.run
