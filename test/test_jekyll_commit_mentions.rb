require 'helper'

class TestJekyllCommitMentions < Minitest::Test
  include CommitMentionsTestHelpers

  def commitid
    "665d43f96ef1018e66d294ccc433fefadd236090"
  end

  def short_commitid
    commitid[-7..-1]
  end

  def setup
    @site = fixture_site
    @site.read
    @site.config['jekyll-commit-mentions'] = {"base_url" => "https://github.com/usr1/repo1/commit"}
    @mentions = Jekyll::CommitMentions.new(@site.config)
    @mention = "1234 <a href=\"https://github.com/usr1/repo1/commit/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a> 1234"
  end

  def content page
    # counter UTF-8 encoding https://groups.google.com/forum/#!msg/nokogiri-talk/Q2Nh1cLeQzk/dNyAwQ3vgQsJ
    page.content.gsub(/\n\z/, '')
  end

  def base_url(configs)
    Jekyll::CommitMentions.new("jekyll-commit-mentions" => configs).base_url
  end

  should "replace mention with link" do
    page = page_with_name(@site, "index.md")

    @mentions.mentionify page
    assert_equal @mention, content(page)
  end

  should "replace mention with link in collections" do
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
    assert_equal "#{commitid} 1234 1234", content(page_with_name(@site, "test.json"))
  end

  should "also convert pages with permalinks ending in /" do
    page = page_with_name(@site, "parkr.txt")

    @mentions.mentionify page
    assert_equal "Parker <a href=\"https://github.com/usr1/repo1/commit/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a> Moore", content(page)
  end


  context "config" do
    context "bad config" do
      should "should raise exception for invalid values" do
        assert_raises(ArgumentError) { base_url(nil) }
        assert_raises(ArgumentError) { base_url({})  }
        assert_raises(ArgumentError) { base_url(123) }
      end
    end

    context "base_url" do
      should "handle a raw string" do
        assert_equal "https://twitter.com", base_url("https://twitter.com")
      end

      should "handle a hash config" do
        assert_equal "https://twitter.com", base_url({"base_url" => "https://twitter.com"})
      end
    end
  end
end
