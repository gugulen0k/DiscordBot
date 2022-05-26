require "discordrb"
require "dotenv"

config          = Dotenv.parse(".env")
discord_api_key = config["DISCORD_API_KEY"]
riot_api_key    = config["RIOT_API_KEY"]
bot             = Discordrb::Bot.new(token: discord_api_key) 

bot.run 
