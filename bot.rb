require "discordrb"
require "dotenv"
require_relative "commands/get_info"

config          = Dotenv.parse(".env")
discord_api_key = config["DISCORD_API_KEY"]
riot_api_key    = config["RIOT_API_KEY"]
bot             = Discordrb::Commands::CommandBot.new(token: discord_api_key, prefix: "!")

GetInfo.new(riot_api_key).run(bot)

bot.run 
