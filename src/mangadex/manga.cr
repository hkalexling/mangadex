module MangaDex
  struct Manga
    include JSON::Serializable

    getter id : Int64
    getter title : String
    getter description : String
    getter artist : Array(String)
    getter author : Array(String)
    @[JSON::Field(key: "mainCover")]
    getter cover : String

    use_client

    def self.get(id : String) : Manga
      self.from_json client.get "/manga/#{id}"
    end

    def chapters : Array(Chapter)
      json = JSON.parse client!.get "/manga/#{id}/chapters"
      json["chapters"].as_a.map do |c|
        chp = Chapter.from_json c.to_json
        chp.client = client
        chp
      end
    end
  end
end
