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
    getter raw_groups : Array(Int64 | JSON::Any)
    @[JSON::Field(key: "mangaId")]
    getter manga_id : Int64
    @[JSON::Field(key: "mangaTitle")]
    getter manga_title : String

    @[JSON::Field(ignore: true)]
    setter manga : Manga?

    @[JSON::Field(ignore: true)]
    @pages : Array(String)?
    @[JSON::Field(ignore: true)]
    @server : String?
    @[JSON::Field(ignore: true)]
    @fallback_server : String?

    use_client

    def language : String
      LANG_CODES[lang_code]? || "Other"
    end

    def groups : Array(Group)
      raw_groups.map do |group|
        case group
        when Int64
          gid = group
        else
          gid = group.as_h["id"].as_i64
        end

        gname = manga.groups_hash[gid]?
        if gname
          group = Group.new gid, gname
        else
          group = client!.group gid
        end

        group
      end
    end

    def manga : Manga
      @manga ||= client!.manga manga_id
      @manga.not_nil!
    end

    private def get_details
      json = JSON.parse client!.get "/chapter/#{id}?mark_read=false"
      if json["status"]? == "external"
        raise APIError.new("This chapter is hosted on an external site " \
                           "#{json["pages"]?}.", 404)
      end
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
