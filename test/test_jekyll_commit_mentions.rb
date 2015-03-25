require 'helper'

class TestJekyllCommitMentions < Minitest::Test
  include CommitMentionsTestHelpers

  def setup
    @site = fixture_site
    @site.read
    @site.config['jekyll-commit-mentions'] = {"base_url" => "https://github.com/usr1/repo1/commit"}
    @mentions = Jekyll::IssueMentions.new(@site.config)
    @mention = "1234 <a href='https://github.com/usr1/repo1/commit/aa4892d89' class='commit-mention'>4892d89</a> 1234"
  end

  def content page
    page.content.gsub(/\n\z/, '')
  end

  should "replace #mention with link" do
    page = page_with_name(@site, "index.md")

    @mentions.mentionify page
    assert_equal @mention, content(page)
  end

  should "replace @mention with link in collections" do
    page = document("file.md")

    @mentions.mentionify page
    assert_equal @mention, content(page)
  end

  should "replace page content on generate" do
    @mentions.generate(@site)
    assert_equal @mention, content(@site.pages.first)
  end

  should "not mangle liquid templating" do
    page = page_with_name(@site, "leave-liquid-alone.md")

    @mentions.mentionify page
    assert_equal "#{@mention}<a href=\"{{ foo }}\">1234</a>", content(page)
  end

  should "not mangle markdown" do
    page = page_with_name(@site, "mentioned-markdown.md")

    @mentions.mentionify page
    assert_equal "#{@mention}\n> 1234", content(page)
  end

  should "not mangle non-mentioned content" do
    page = page_with_name(@site, "non-mentioned.md")

    @mentions.mentionify page
    assert_equal "1234 1234 1234\n> 1234", content(page)
  end

  should "not touch non-HTML pages" do
    @mentions.generate(@site)
    assert_equal "aa4892d89 1234 1234", content(page_with_name(@site, "test.json"))
  end

  should "also convert pages with permalinks ending in /" do
    page = page_with_name(@site, "parkr.txt")

    @mentions.mentionify page
    assert_equal "Parker <a href='https://github.com/usr1/repo1/commit/aa4892d89' class='commit-mention'>4892d89</a> Moore", content(page)
  end


  context "reading custom base urls" do
    def setup
      @mentions = Jekyll::IssueMentions.new(Hash.new)
    end

    should "handle a raw string" do
      assert_equal "https://twitter.com", @mentions.base_url("https://twitter.com")
    end

    should "handle a hash config" do
      assert_equal "https://twitter.com", @mentions.base_url({"base_url" => "https://twitter.com"})
    end

    should "should raise exception when not configured" do
      assert_raises(ArgumentError) { @mentions.base_url(nil) }
      assert_raises(ArgumentError) { @mentions.base_url({}) }
    end

    should "should raise exception when invalid value is passed" do
      assert_raises(ArgumentError) { @mentions.base_url(12) }
    end
  end

end
