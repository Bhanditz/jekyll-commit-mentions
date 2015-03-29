require 'jekyll'
require 'html/pipeline'
require 'commit_mention_filter'

module Jekyll
  class CommitMentions < Jekyll::Generator
    safe true
    attr_reader :base_url

    def initialize(config = Hash.new)
      validate_config!(config)
    end

    def generate(site)
      site.pages.each { |page| mentionify page if html_page?(page) }
      site.posts.each { |post| mentionify post }
      site.docs_to_write.each { |doc| mentionify doc }
    end

    def mentionify(page)
      @filter = HTML::Pipeline::CommitMentionFilter.new(page.content, {:base_url => base_url})
      page.content = @filter.call.to_s.
        gsub("&gt;", ">").
        gsub("&lt;", "<").
        gsub("%7B", "{").
        gsub("%20", " ").
        gsub("%7D", "}")
    end

    def html_page?(page)
      page.html? || page.url.end_with?('/')
    end

  private
    def validate_config!(configs)
      configs = configs['jekyll-commit-mentions']
      base_url = nil
      case configs
      when String
        base_url = configs
      when Hash
        base_url = configs['base_url']
      end
      error_prefix = "jekyll-commit-mentions"
      raise ArgumentError.new("#{error_prefix}.base_url is missing/empty") if (base_url.nil? || base_url.empty?)

      @base_url = base_url
    end

  end
end
