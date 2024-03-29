require "./spec_helper"

describe Client do
  it "gets manga by ID" do
    manga = Client.new.manga 7139
    manga.id.should eq 7139
    manga.title.should eq "One Punch-Man"
  end

  it "gets chapter by ID" do
    chapter = Client.new.chapter 1184870
    chapter.id.should eq 1184870
    chapter.manga_title.should eq "One Punch-Man"
    chapter.manga_id.should eq 7139
    chapter.groups.size.should be > 0
  end

  it "gets manga from chapter" do
    chapter = Client.new.chapter 1184870
    manga = chapter.manga
    manga.id.should eq 7139
    manga.title.should eq "One Punch-Man"
  end

  it "lists chapters" do
    chapters = Client.new.manga(7139).chapters
    chapters.size.should be > 0
    chapter = chapters.sample(1).first
    chapter.groups.size.should be > 0
    pages = chapter.pages
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

  it "raises on external chapters" do
    expect_raises APIError do
      Client.new.chapter(1226642).pages
    end
  end
end
