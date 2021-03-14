require "uri/params"

module MangaDex
  struct Updates
    include JSON::Serializable

    getter groups : Array(Group)

    @[JSON::Field(key: "manga")]
    @raw_manga : Hash(String, PartialManga)
    @[JSON::Field(key: "chapters")]
    @raw_chapters : Array(Chapter)

    def manga : Array(PartialManga)
      @raw_manga.values
    end

    def chapters : Array(Chapter)
      @raw_chapters.map do |ch|
        ch.groups = ch.raw_groups.map do |gid|
          groups.find(&.id.== gid).not_nil!
        end
        ch
      end
    end
  end

  struct User
    include JSON::Serializable

    getter id : Int64
    getter username : String

    use_client

    def followed_updates(*, page : Int32 = 1) : Updates
      params = URI::Params.encode({"p" => page.to_s, "hentai" => "1"})
      Updates.from_json client!.get "/user/#{id}/followed-updates?#{params}"
    end

    def read_chapters(ids : Array(Int64))
      body = {
        "chapters" => ids,
        "read"     => true,
      }
      client!.post "/user/#{id}/marker", body.to_json
    end

    def unread_chapters(ids : Array(Int64))
      body = {
        "chapters" => ids,
        "read"     => false,
      }
      client!.post "/user/#{id}/marker", body.to_json
    end
  end
end
