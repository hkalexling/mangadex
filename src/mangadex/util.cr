macro use_client
  @[JSON::Field(ignore: true)]
  property client : Client?

  def client!
    client.not_nil!
  end
end

LANG_CODES = {
  "sa" => "Arabic",
  "bd" => "Bengali",
  "bg" => "Bulgarian",
  "mm" => "Burmese",
  "ct" => "Catalan",
  "cn" => "Chinese (Simp)",
  "hk" => "Chinese (Trad)",
  "cz" => "Czech",
  "dk" => "Danish",
  "nl" => "Dutch",
  "gb" => "English",
  "ph" => "Filipino",
  "fi" => "Finnish",
  "fr" => "French",
  "de" => "German",
  "gr" => "Greek",
  "il" => "Hebrew",
  "in" => "Hindi",
  "hu" => "Hungarian",
  "id" => "Indonesian",
  "it" => "Italian",
  "jp" => "Japanese",
  "kr" => "Korean",
  "lt" => "Lithuanian",
  "my" => "Malay",
  "mn" => "Mongolian",
  "ir" => "Persian",
  "pl" => "Polish",
  "br" => "Portuguese (Br)",
  "pt" => "Portuguese (Pt)",
  "ro" => "Romanian",
  "ru" => "Russian",
  "rs" => "Serbo-Croatian",
  "es" => "Spanish (Es)",
  "mx" => "Spanish (LATAM)",
  "se" => "Swedish",
  "th" => "Thai",
  "tr" => "Turkish",
  "ua" => "Ukrainian",
  "vn" => "Vietnames",
}
