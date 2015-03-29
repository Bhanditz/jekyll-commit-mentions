require 'jekyll'
require 'html/pipeline'
require 'commit_mention_filter'

module Jekyll
  class CommitMentions < Jekyll::Generator
    safe true

    def initialize(config = Hash.new)
      @base_url = base_url(config['jekyll-commit-mentions'])
    end

    def generate(site)
      site.pages.each { |page| mentionify page if html_page?(page) }
      site.posts.each { |post| mentionify post }
      site.docs_to_write.each { |doc| mentionify doc }
    end

    def mentionify(page)
      @filter = HTML::Pipeline::CommitMentionFilter.new(page.content, {:base_url => @base_url})
      page.content = @filter.call.to_s
    end

    def html_page?(page)
      page.html? || page.url.end_with?('/')
    end

    def base_url(configs)
      case configs
      when nil, NilClass
        raise ArgumentError.new("Your jekyll-issue-mentions config has to configured.")
      when String
        configs.to_s
      when Hash
        base_url = configs['base_url']
        if base_url.nil?
          raise ArgumentError.new("Your jekyll-issue-mentions is missing base_url configuration.")
        else
          base_url
        end
      else
        raise ArgumentError.new("Your jekyll-issue-mentions config has to either be a string or a hash! It's a #{configs.class} right now.")
      end
    end
  end
end
