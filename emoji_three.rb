require "async"
require "async/http/endpoint"
require "async/http/client"
require "fileutils"
require "digest"
require "uri"
require "set"

# Define the list of emoji code points you want to combine
emoji_list = [
  "❤️", "🧡", "💛", "💚", "🩵", "💙", "💜", "🩷", "🤎", "🩶", "🖤", "🤍",
  "🪄", "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "🫠",
  "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "☺️", "😚", "😙", "🥲",
  "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🫢", "🫣", "🤫", "🤔",
  "🫡", "🤐", "🤨", "😐", "😑", "😶", "🫥", "😶‍🌫️", "😏", "😒", "🙄",
  "😬", "😮‍💨", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕",
  "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎",
  "🤓", "🧐", "😕", "🫤", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳",
  "🥺", "🥹", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖",
  "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈",
  "👿", "💀", "💩", "🤡", "👹", "👺", "👻", "👽", "🤖", "🙈", "💌",
  "💘", "💝", "💖", "💗", "💓", "💞", "💕", "❣️", "💔", "❤️‍🩹", "💋",
  "💯", "💥", "💫", "🕳️", "💬", "🗯️", "👍", "🧠", "🫀", "🫁", "🦷",
  "🦴", "👀", "👁️", "👄", "🫦", "🤷", "🗣️", "👤", "👥", "🫂", "👣",
  "🐵", "🐶", "🐩", "🐺", "🦊", "🦝", "🐱", "🦁", "🐯", "🦄", "🦌",
  "🐮", "🐷", "🐐", "🦙", "🐭", "🐰", "🦔", "🦇", "🐻", "🐨", "🐼",
  "🦥", "🐾", "🐔", "🐦", "🐧", "🕊️", "🦉", "🦩", "🪿", "🐸", "🐢",
  "🐉", "🐳", "🐟", "🦈", "🐙", "🐚", "🪸", "🐌", "🦋", "🐝", "🪲",
  "🐞", "🦗", "🪳", "🕷️", "🦂", "🦠", "💐", "🌸", "💮", "🪷", "🏵️",
  "🌹", "🥀", "🌺", "🌻", "🌼", "🌷", "🪻", "🌱", "🪴", "🌲", "🌳",
  "🌴", "🌵", "🌾", "🌿", "🍀", "🍁", "🍂", "🍃", "🪹", "🍄", "🍇",
  "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍐", "🍒", "🍓",
  "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🥔", "🥕", "🌽", "🌶️", "🫑",
  "🥒", "🥬", "🥦", "🧄", "🧅", "🥜", "🫘", "🌰", "🫚", "🫛", "🍞",
  "🥐", "🫓", "🥨", "🥯", "🥞", "🧇", "🧀", "🍖", "🍗", "🥩", "🥓",
  "🍔", "🍟", "🌭", "🥪", "🌮", "🌯", "🫔", "🥙", "🧆", "🍳", "🥘",
  "🍲", "🫕", "🥣", "🥗", "🍿", "🧈", "🧂", "🥫", "🍱", "🍘", "🍙",
  "🍚", "🍛", "🍜", "🍝", "🍠", "🍢", "🍣", "🍤", "🍥", "🍡", "🥟",
  "🥠", "🥡", "🦀", "🦞", "🦪", "🍦", "🍧", "🍨", "🍩", "🍪", "🎂",
  "🍰", "🧁", "🥧", "🍫", "🍬", "🍭", "🍮", "🍯", "🍼", "🥛", "☕",
  "🫖", "🍵", "🍶", "🍾", "🍷", "🍹", "🥂", "🫗", "🥤", "🧋", "🧃",
  "🧉", "🧊", "🥢", "🍽️", "🏺", "🌍", "🏔️", "⛰️", "🌋", "🏕️",
  "🏖️", "🏝️", "🏞️", "🏟️", "🏛️", "🧱", "🪨", "🪵", "🏚️", "🏠",
  "🏰", "🗼", "🌄", "🌇", "♨️", "🎠", "🎡", "🎢", "🎪", "🚂", "🚇",
  "🚌", "🚕", "🚗", "🚚", "🚛", "🚜", "🏎️", "🏍️", "🚲", "🛴",
  "🛹", "🛼", "🛣️", "⛽", "🚨", "🚦", "🛑", "🚧", "⚓", "🛟",
  "🛶", "✈️", "🪂", "🚠", "🚡", "🚀", "🛸", "🧳", "⌛", "⏳", "⌚",
  "⏰", "🕰️", "🌚", "🌛", "🌜", "🌡️", "🌝", "🌞", "🪐", "⭐",
  "🌟", "🌌", "☁️", "⛅", "🌧️", "🌩️", "🌪️", "🌬️", "🌀", "🌈",
  "☂️", "⚡", "⛄", "☄️", "🔥", "💧", "🌊", "🎃", "🎆", "🎈",
  "🎊", "🎀", "🎁", "🎗️", "🎟️", "🎖️", "🏆", "🏅", "🥇", "🥈",
  "🥉", "⚽", "⚾", "🥎", "🏀", "🏐", "🏈", "🏉", "🎾", "🥏",
  "🎳", "🏏", "🏑", "🏒", "🥍", "🏓", "🏸", "🥊", "🥋", "🥅",
  "⛳", "⛸️", "🎣", "🤿", "🎽", "🎿", "🛷", "🥌", "🎯", "🪀",
  "🪁", "🎱", "🔮", "🎮", "🎰", "🎲", "🧩", "🪩", "♠️", "♥️",
  "♟️", "🃏", "🀄", "🎴", "🎭", "🖼️", "🎨", "🧵", "🪡", "🧶",
  "👕", "🧦", "👗", "🪭", "👜", "🛍️", "👟", "🥿", "👠", "🩰",
  "🪮", "👑", "👒", "🎓", "💍", "💎", "🔈", "📣", "🔔", "🎶",
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

download_folder = "./thripper"
downloaded_images = {}
not_found_combinations = Set.new

endpoint = Async::HTTP::Endpoint.parse("https://emojik.vercel.app")
client = Async::HTTP::Client.new(endpoint)

def download_emoji_image(emoji1, emoji2, size, client, download_folder, downloaded_images, not_found_combinations, not_found_image_hash)
  return if not_found_combinations.include?("#{emoji1}-#{emoji2}") || not_found_combinations.include?("#{emoji2}-#{emoji1}")

  encoded_emoji1 = URI.encode_www_form_component(emoji1)
  encoded_emoji2 = URI.encode_www_form_component(emoji2)
  url = "https://emojik.vercel.app/s/#{encoded_emoji1}_#{encoded_emoji2}?size=#{size}"

  response = client.get(url)
  image_data = response.read # Read the response body once

  if response.status == 200
    file_name = "#{emoji1}_#{emoji2}.png"
    file_path = "#{download_folder}/#{file_name}"

    image_hash = Digest::SHA256.hexdigest(image_data)

    if image_hash == not_found_image_hash
      not_found_combinations.add("#{emoji1}-#{emoji2}")
      not_found_combinations.add("#{emoji2}-#{emoji1}")
      puts "Invalid emoji combo: #{file_name}"
    elsif downloaded_images[image_hash].nil?
      File.open(file_path, "wb") { |file| file.write(image_data) }
      downloaded_images[image_hash] = file_path
      puts "Downloaded: #{file_name}"
    end
  else
    puts "Failed to download #{emoji1} + #{emoji2}"
  end
end

def load_not_found_image_hash(sample_image_path)
  File.open(sample_image_path, "rb") { |file| Digest::SHA256.hexdigest(file.read) }
end

not_found_image_hash = load_not_found_image_hash("/home/calvin/rails-7-template/downloaded_pngs/❤️_😄.png")

Async do
  FileUtils.mkdir_p(download_folder)

  tasks = emoji_list.combination(2).map do |emoji1, emoji2|
    Async do
      download_emoji_image(emoji1, emoji2, 128, client, download_folder, downloaded_images, not_found_combinations, not_found_image_hash)
    end
  end

  tasks.each(&:wait) # Wait for all tasks to complete
end