require 'helper'


class HTML::Pipeline::TestCommitMentionFilter < Minitest::Test
  include CommitMentionsTestHelpers

  def filter(html, base_url='/', commitid_pattern=nil)
    HTML::Pipeline::CommitMentionFilter.call(html, :base_url => base_url, :commitid_pattern => commitid_pattern)
  end

  def commitid
    "665d43f96ef1018e66d294ccc433fefadd236090"
  end

  def commitid1
    "665d43f96ef1018e66d294ccc433fefadd236091"
  end

  def commitid2
    "665d43f96ef1018e66d294ccc433fefadd236092"
  end

  def short_commitid
    commitid[-7..-1]
  end

  def test_filtering_a_documentfragment
    body = "<p>#{commitid}: check it out.</p>"
    doc  = Nokogiri::HTML::DocumentFragment.parse(body)

    res  = filter(doc, '/')
    assert_same doc, res

    link = "<a href=\"/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a>"
    assert_equal "<p>#{link}: check it out.</p>", res.to_html
  end

  def test_filtering_plain_text
    body = "<p>#{commitid}: check it out.</p>"
    res  = filter(body, '/')

    link = "<a href=\"/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a>"
    assert_equal "<p>#{link}: check it out.</p>", res.to_html
  end

  def test_not_replacing_mentions_in_pre_tags
    body = "<pre>#{commitid}: okay</pre>"
    assert_equal body, filter(body).to_html
  end

  def test_not_replacing_mentions_in_code_tags
    body = "<p><code>#{commitid}:</code> okay</p>"
    assert_equal body, filter(body).to_html
  end

  def test_not_replacing_mentions_in_style_tags
    body = "<style>@media (min-width: 768px) { color: red; }</style>"
    assert_equal body, filter(body).to_html
  end

  def test_not_replacing_mentions_in_links
    body = "<p><a>#{short_commitid}</a> okay</p>"
    assert_equal body, filter(body).to_html
  end

  def test_html_injection
    body = "<p>#{commitid} &lt;script>alert(0)&lt;/script></p>"
    link = "<a href=\"/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a>"
    assert_equal "<p>#{link} &lt;script&gt;alert(0)&lt;/script&gt;</p>",
      filter(body, '/').to_html
  end

  def test_base_url_slash
    body = "<p>Hi, #{commitid}!</p>"
    link = "<a href=\"/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a>"
    assert_equal "<p>Hi, #{link}!</p>", filter(body, '/').to_html
  end

  def test_base_url_under_custom_route
    body = "<p>Hi, #{commitid}!</p>"
    link = "<a href=\"/commits/#{commitid}\" class=\"commit-mention\">#{short_commitid}</a>"
    assert_equal "<p>Hi, #{link}!</p>",
      filter(body, '/commits').to_html
  end

  def test_base_url_slash_with_tilde
    body = "<p>Hi, #{commitid}!</p>"
    link = "<a href=\"/~#{commitid}\" class=\"commit-mention\">#{short_commitid}</a>"
    assert_equal "<p>Hi, #{link}!</p>",
      filter(body, '/~').to_html
  end

  MarkdownPipeline =
    HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::CommitMentionFilter
    ]

  def mentioned_commitids
    result = {}
    MarkdownPipeline.call(@body, {}, result)
    result[:mentioned_commitids]
  end

  def test_matches_commitids_in_body
    @body = "#{commitid} how are you?"
    assert_equal [commitid], mentioned_commitids
  end

  def test_matches_commitids_followed_by_a_single_dot
    @body = "okay #{commitid}."
    assert_equal [commitid], mentioned_commitids
  end

  def test_matches_commitids_followed_by_multiple_dots
    @body = "okay #{commitid}..."
    assert_equal [commitid], mentioned_commitids
  end

  def test_matches_colon_suffixed_names
    @body = "#{commitid}: what do you think?"
    assert_equal [commitid], mentioned_commitids
  end

  def test_matches_list_of_names
    @body = "#{commitid} #{commitid1} #{commitid2}"
    assert_equal [commitid, commitid1, commitid2], mentioned_commitids
  end

  def test_matches_list_of_names_with_commas
    @body = "#{commitid}, #{commitid1}, #{commitid2}"
    assert_equal [commitid, commitid1, commitid2], mentioned_commitids
  end

  def test_matches_inside_brackets
    @body = "(#{commitid}) [#{commitid1}] {#{commitid2}}"
    assert_equal [commitid, commitid1, commitid2], mentioned_commitids
  end

  def test_returns_distinct_set
    @body = "#{commitid} #{commitid1} #{commitid2} #{commitid} #{commitid1} #{commitid2}"
    assert_equal [commitid, commitid1, commitid2], mentioned_commitids
  end

  def test_does_not_match_inline_code_block_with_multiple_code_blocks
    @body = "something\n\n`#{commitid} #{commitid1} #{commitid2}`"
    assert_equal [], mentioned_commitids
  end

  def test_mention_at_end_of_parenthetical_sentence
    @body = "(We're talking 'bout ##{commitid}.)"
    assert_equal [commitid], mentioned_commitids
  end

  def test_commitid_pattern_can_be_customized
    new_commitid = commitid[0...30]
    new_short_commitid = new_commitid[-7..-1]
    custom_commitid_pattern = /[0-9a-f]{30}/

    body = "<p>#{new_commitid}: commit.</p>"
    doc  = Nokogiri::HTML::DocumentFragment.parse(body)
    res  = filter(doc, '/', custom_commitid_pattern)

    link = "<a href=\"/#{new_commitid}\" class=\"commit-mention\">#{new_short_commitid}</a>"
    assert_equal "<p>#{link}: commit.</p>", res.to_html
  end

  def test_filter_does_not_create_a_new_object_for_default_commitid_pattern
    body = "<div>#{commitid}</div>"
    doc = Nokogiri::HTML::DocumentFragment.parse(body)

    filter(doc.clone, '/', nil)
    pattern_count = HTML::Pipeline::CommitMentionFilter::MentionPatterns.length
    filter(doc.clone, '/', nil)

    assert_equal pattern_count, HTML::Pipeline::CommitMentionFilter::MentionPatterns.length
    filter(doc.clone, '/', /#{commitid}/)
    assert_equal pattern_count + 1, HTML::Pipeline::CommitMentionFilter::MentionPatterns.length
  end
end
