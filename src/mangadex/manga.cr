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

    @[JSON::Field(ignore: true)]
    getter groups_hash = {} of Int64 => String

    use_client

    def self.get(id : String) : Manga
      self.from_json client.get "/manga/#{id}"
    end

    def chapters : Array(Chapter)
      json = JSON.parse client!.get "/manga/#{id}/chapters"
      json["groups"].as_a.each do |obj|
        id = obj.as_h["id"].as_i64
        name = obj.as_h["name"].as_s
        @groups_hash[id] = name
      end
      json["chapters"].as_a.map do |c|
        chp = Chapter.from_json c.to_json
        chp.client = client
        chp.manga = self
        chp
      end
    end
  end
end
