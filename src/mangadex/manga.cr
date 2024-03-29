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

    def chapters : Array(Chapter)
      json = JSON.parse client!.get "/manga/#{id}/chapters"
      groups = {} of Int64 => Group
      json["groups"].as_a.each do |obj|
        group = Group.from_json obj.to_json
        groups[group.id] = group
      end
      json["chapters"].as_a.map do |c|
        chp = Chapter.from_json c.to_json
        chp.groups = chp.raw_groups.map { |gid| groups[gid] }
        chp.client = client
        chp.manga = self
        chp
      end
    end
  end

  struct PartialManga
    include JSON::Serializable

    getter id : Int64
    getter title : String
    getter description : String?
    @[JSON::Field(key: "mainCover")]
    getter cover : String

    use_client

    def initialize(@id, @client, *, title : String? = nil,
                   description : String? = nil,
                   cover : String? = nil)
      if title && cover
        @title = title
        @description = description
        @cover = cover
      else
        manga = client!.manga @id
        @title = manga.title
        @description = manga.description
        @cover = manga.cover
      end
    end
  end
end
