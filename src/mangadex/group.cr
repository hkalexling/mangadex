module MangaDex
  struct Group
    include JSON::Serializable

    getter id : Int64
    getter name : String

    def initialize(@id, @name)
    end
  end
end
