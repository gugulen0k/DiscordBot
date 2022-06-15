class EmbedMessage
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
end
