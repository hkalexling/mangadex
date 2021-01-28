module MangaDex
  struct Group
    include JSON::Serializable

    getter id : Int64
    getter name : String
    getter description : String
    @[JSON::Field(key: "language")]
    getter lang_code : String

    use_client

    def language : String
      LANG_CODES[lang_code]? || "Other"
    end
  end
end
