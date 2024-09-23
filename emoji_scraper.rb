require 'httparty'
require 'fileutils'


emoji_list = [
"💍", "💎", "🔈", "📣", "🔔", "🎶",
  "🎙️", "🎚️", "🎛️", "🎤", "🎧", "📻", "🎷", "🪗", "🎸", "🎹",
  "🎺", "🎻", "🪕", "🥁", "🪘", "🪇", "🪈", "📱", "☎️", "📟",
  "📠", "🔋", "🪫", "🔌", "💻", "🖨️", "💾", "💿", "🎞️", "🎬",
  "📺", "📷", "📼", "🔎", "💡", "🪔", "📚", "📰", "💸", "📦",
  "🗳️", "✏️", "✒️", "🖊️", "🖌️", "🖍️", "📈", "📉", "📊",
  "🖇️", "📏", "✂️", "🗃️", "🗑️", "🔒", "🗝️", "⛏️", "🛠️",
  "🪃", "🏹", "⚙️", "⚖️", "⛓️", "🧲", "🧪", "🧬", "🔬",
  "🔭", "🩸", "🩺", "🛋️", "🪤", "🪒", "🧹", "🧺", "🧼", "🫧",
  "🛒", "🧿", "🗿", "🚮", "⚠️", "☢️", "☣️", "☯️", "☮️",
  "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑",
  "♒", "♓", "⛎", "📴", "✖️", "➕", "➖", "➗", "♾️", "⁉️",
  "❓", "❗", "〰️", "♻️", "✅", "➰", "➿", "©️", "®️", "™️",
  "🔢", "🆒", "🆓", "🆕", "🆗", "🆘", "🆙", "🐍", "🐎", "👾"
]

# Function to download a combined emoji PNG
def download_emoji_image(emoji1, emoji2, size, download_folder, downloaded_images)
  encoded_emoji1 = URI.encode_www_form_component(emoji1)
  encoded_emoji2 = URI.encode_www_form_component(emoji2)
  url = "https://emojik.vercel.app/s/#{encoded_emoji1}_#{encoded_emoji2}?size=#{size}"
  response = HTTParty.get(url)

  if response.code == 200
    file_name = "#{emoji1}_#{emoji2}.png"
    file_path = "#{download_folder}/#{file_name}"

    # Check if the content has already been downloaded
    if downloaded_images[response.body].nil?
      File.open(file_path, 'wb') do |file|
        file.write(response.body)
      end
      downloaded_images[response.body] = file_name
      puts "Downloaded: #{file_name}"
    else
      puts "Already downloaded: #{file_name}"
    end
  else
    puts "Failed to download: #{emoji1}_#{emoji2}"
  end
end

download_folder = "./emoji_kitchen_images"
FileUtils.mkdir_p(download_folder) unless Dir.exist?(download_folder)

# Hash to store already downloaded images by their content
downloaded_images = {}

# Loop through each combination of emojis and download
emoji_list.each do |emoji1|
  emoji_list.each do |emoji2|
    download_emoji_image(emoji1, emoji2, 128, download_folder, downloaded_images)
  end
end