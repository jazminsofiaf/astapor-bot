class Emoji
  EMOJIS = {
    speak_no_evil: "\u{1F64A}",
    books: "\u{1F4DA}",
    tada: "\u{1F389}",
    no_good: "\u{1F645}",
    x: "\u{274C}"
  }.freeze

  def self.code(name)
    EMOJIS[name]
  end
end
