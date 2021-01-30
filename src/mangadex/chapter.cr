module MangaDex
  struct Chapter
    include JSON::Serializable

    getter id : Int64
    getter hash : String
    getter volume : String
    getter chapter : String
    getter title : String
    @[JSON::Field(key: "language")]
    getter lang_code : String
    getter timestamp : Int64
    @[JSON::Field(key: "groups")]
    getter raw_groups : Array(Int64)

    @pages : Array(String)?
    @server : String?
    @fallback_server : String?

    use_client

    def language : String
      LANG_CODES[lang_code]? || "Other"
    end

    def groups : Array(Group)
      raw_groups.map { |gid| client!.group gid }
    end

    private def get_details
      json = JSON.parse client!.get "/chapter/#{id}?mark_read=false"
      @server = json["server"].as_s
      if fallback = json["serverFallback"]?
        @fallback_server = fallback.as_s
      end
      @pages = json["pages"].as_a.map &.to_s
    end

    def pages(*, fallback = false)
      get_details unless @pages
      server = @server
      server = @fallback_server if fallback && @fallback_server
      @pages.not_nil!.map do |fn|
        "#{server}#{hash}/#{fn}"
      end
    end
  end
end