require "./spec_helper"

describe Client do
  it "gets manga by ID" do
    manga = Client.new.manga 7139
    manga.id.should eq 7139
    manga.title.should eq "One Punch-Man"
  end

  it "lists chapters" do
    chapters = Client.new.manga(7139).chapters
    chapters.size.should be > 0
    pages = chapters.sample(1).first.pages
    pages.size.should be > 0
    pages
      .all? do |url|
        uri = URI.parse url
        uri.scheme == "https" && uri.host =~ /mangadex/
      end
      .should be_true
  end

  it "gets user by ID" do
    user = Client.new.user 826930
    user.id.should eq 826930
    user.username.should eq "hkalexling"
  end
end
