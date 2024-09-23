require "httparty"
require "fileutils"
require "digest"
require "set"
require "concurrent"

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
download_folder = "./emoji_pngs"
downloaded_images = {}
not_found_combinations = Set.new

# Thread pool for concurrent HTTP requests
thread_pool = Concurrent::FixedThreadPool.new(10)

def download_emoji_image(emoji1, emoji2, size, download_folder, downloaded_images, not_found_combinations, not_found_image_hash)
  # Skip if this combination or its reverse has been processed
  return if not_found_combinations.include?([emoji1, emoji2]) || not_found_combinations.include?([emoji2, emoji1])

  encoded_emoji1 = URI.encode_www_form_component(emoji1)
  encoded_emoji2 = URI.encode_www_form_component(emoji2)
  url = "https://emojik.vercel.app/s/#{encoded_emoji1}_#{encoded_emoji2}?size=#{size}"
  response = HTTParty.get(url)

  if response.code == 200
    file_name = "#{emoji1}_#{emoji2}.png"
    file_path = "#{download_folder}/#{file_name}"

    image_hash = Digest::SHA256.hexdigest(response.body)

    if image_hash == not_found_image_hash
      not_found_combinations << [emoji1, emoji2]
      not_found_combinations << [emoji2, emoji1]
      puts "Invalid emoji combo: #{file_name}, status: #{response.code}"
    elsif downloaded_images[image_hash].nil?
      File.open(file_path, "wb") { |file| file.write(response.body) }
      downloaded_images[image_hash] = file_name
      puts "Downloaded: #{file_name}, code: #{response.code}"
    else
      puts "Already downloaded: #{file_name}, code: #{response.code}"
    end
  else
    puts "Failed to download: #{emoji1}_#{emoji2}"
    not_found_combinations << [emoji1, emoji2]
    not_found_combinations << [emoji2, emoji1]
  end
end

# Load or compute the 'not found' image hash
def load_not_found_image_hash(sample_image_path)
  File.open(sample_image_path, "rb") { |file| Digest::SHA256.hexdigest(file.read) }
end

not_found_image_hash = load_not_found_image_hash("/home/calvin/rails-7-template/downloaded_pngs/❤️_😄.png")

# Prepare the directory
FileUtils.mkdir_p(download_folder) unless Dir.exist?(download_folder)

# Process emoji pairs concurrently
emoji_list.combination(2).each do |emoji1, emoji2|
  thread_pool.post do
    download_emoji_image(emoji1, emoji2, 128, download_folder, downloaded_images, not_found_combinations, not_found_image_hash)
  end
end

# Shutdown thread pool and wait for all tasks to complete
thread_pool.shutdown
thread_pool.wait_for_termination