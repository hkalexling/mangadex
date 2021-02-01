require "http/client"
require "myhtml"

module MangaDex
  class APIError < Exception
    getter code : Int32

    def initialize(msg : String, @code)
      super "#{msg} [#{code}]"
    end
  end

  struct Client
    BOUNDARY = "__X_MDCR_BOUNDARY__"

    property token : String?
    property token_expires = Time.utc
    property user_id : Int64?

    def initialize(*, @base_url = "https://mangadex.org",
                   @api_url = "https://mangadex.org/api/v2")
      @base_url = @base_url.rstrip "/"
      @api_url = @api_url.rstrip "/"
    end

    def auth(username, password)
      url = "#{@base_url}/ajax/actions.ajax.php?function=login"
      headers = HTTP::Headers{
        "User-Agent"       => "mangadex.cr",
        "X-Requested-With" => "XMLHttpRequest",
        "Content-Type"     => "multipart/form-data; charset=utf-8; " \
                          "boundary=#{BOUNDARY}",
      }
      body = form_data({
        "login_username" => username,
        "login_password" => password,
        "remember_me"    => "1",
      })
      res = HTTP::Client.post url, headers: headers, body: body do |res|
        cookies = HTTP::Cookies.from_headers res.headers
        @token = cookies["mangadex_rememberme_token"].value
        @token_expires = cookies["mangadex_rememberme_token"].expires ||
                         Time.utc
      end
    end

    def auth?
      token && token_expires > Time.utc
    end

    private def form_data(hash : Hash(String, String))
      ary = hash.map do |k, v|
        "Content-Disposition: form-data; name=\"#{k}\"\n\n#{v}\n"
      end
      "--#{BOUNDARY}\n#{ary.join "--#{BOUNDARY}\n"}--#{BOUNDARY}--"
    end

    def get_headers : HTTP::Headers
      headers = HTTP::Headers{
        "User-Agent"       => "mangadex.cr",
        "X-Requested-With" => "XMLHttpRequest",
      }
      cookies = HTTP::Cookies.new
      if auth?
        cookies << HTTP::Cookie.new "mangadex_rememberme_token",
          @token.not_nil!
      end
      cookies.add_request_headers headers
    end

    private macro handle_error
      unless res.success?
        begin
          json = JSON.parse res.body
          msg = json["message"].as_s
        rescue
          msg = res.status_message
        end
        raise APIError.new "Failed to get #{url}. #{msg}", res.status_code
      end
    end

    def get(url, *, api = true)
      unless url =~ /https?:\/\//
        url = "#{api ? @api_url : @base_url}/#{url.lstrip "/"}"
      end
      res = HTTP::Client.get url, headers: get_headers
      handle_error

      return res.body unless api
      JSON.parse(res.body)["data"].to_json
    end

    def post(url, body)
      unless url =~ /https?:\/\//
        url = "#{@api_url}/#{url.lstrip "/"}"
      end
      headers = get_headers
      headers["Content-Type"] = "application/json"
      res = HTTP::Client.post url, headers: headers, body: body
      handle_error

      JSON.parse(res.body)["data"].to_json
    end

    def manga(id : String | Int64) : Manga
      manga = Manga.from_json get "/manga/#{id}"
      manga.client = self
      manga
    end

    def chapter(id : String | Int64) : Chapter
      chapter = Chapter.from_json get "/chapter/#{id}?mark_read=false"
      chapter.client = self
      chapter
    end

    def group(id : String | Int64) : Group
      Group.from_json get "/group/#{id}"
    end

    def user(id : String | Int64) : User
      user = User.from_json get "/user/#{id}"
      user.client = self
      user
    end

    def search_manga(query : String) : Array(Manga)
      params = HTTP::Params.new
      params.add "title", query
      html = get "/search?#{params.to_s}", api: false
      parser = Myhtml::Parser.new html
      ary = [] of Manga
      parser.css("a.manga_title").each do |node|
        href = node.attribute_by "href"
        next if href.nil?
        match = /(?:title|manga)\/([0-9]+)/.match href
        next if match.nil?
        ary << manga match[1]
      end
      ary
    end
  end
end
