module MangaDex
  struct User
    include JSON::Serializable

    getter id : Int64
    getter username : String

    use_client

    def followed_updates : Array(Chapter)
      json = JSON.parse client!.get "/user/#{id}/followed-updates"
      json["chapters"].as_a.map do |item|
        Chapter.from_json item.to_json
      end
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
