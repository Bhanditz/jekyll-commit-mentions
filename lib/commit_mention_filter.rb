require 'set'

module HTML
  class Pipeline
    # HTML filter that replaces mention mentions with links to Github commit. Mentions within <pre>,
    # <code>, <style> and <a> elements are ignored.
    #
    # Context options:
    #   :base_url - Used to construct links to commit page for each mention.
    #   :commitid_pattern - Used to provide a custom regular expression to
    #                       identify commit ids
    #
    class CommitMentionFilter < Filter
      # Public: Find commit mention in text.  See
      # CommitMentionFilter#mention_link_filter.
      #
      #   CommitMentionFilter.mentioned_commits_in(text) do |match, commitid|
      #     "<a href=...>#{commitid}</a>"
      #   end
      #
      # text - String text to search.
      #
      # Yields the String match, the String commitid.  The yield's return replaces the match in
      # the original text.
      #
      # Returns a String replaced with the return of the block.
      def self.mentioned_commits_in(text, commitid_pattern=CommitidPattern)
        text.gsub MentionPatterns[commitid_pattern] do |match|
          commitid = $1
          yield match, commitid
        end
      end


      # Hash that contains all of the mention patterns used by the pipeline
      MentionPatterns = Hash.new do |hash, key|
        hash[key] = /
          (?:^|\W)                    # beginning of string or non-word char
          ((?>#{key}))                # commitid
          (?!\/)                      # without a trailing slash
          (?=
            \.+[ \t\W]|               # dots followed by space or non-word character
            \.+$|                     # dots at end of line
            [^0-9a-zA-Z_.]|           # non-word character except dot
            $                         # end of line
          )
        /ix
      end

      # Default pattern used to extract commitid from text. The value can be
      # overriden by providing the commitid_pattern variable in the context.
      CommitidPattern = /[0-9a-f]{40}/

      # Don't look for mentions in text nodes that are children of these elements
      IGNORE_PARENTS = %w(pre code a style script).to_set

      def call
        result[:mentioned_commitids] ||= []

        doc.search('text()').each do |node|
          content = node.to_html
          next if !content.match(commitid_pattern)
          next if has_ancestor?(node, IGNORE_PARENTS)
          html = mention_link_filter(content, base_url, commitid_pattern)
          next if html == content
          node.replace(html)
        end
        doc
      end

      def commitid_pattern
        context[:commitid_pattern] || CommitidPattern
      end

      # Replace commit mentions in text with links to the mentioned
      # commit's page.
      #
      # text      - String text to replace mention commitids in.
      # base_url  - The base URL used to construct commit page URLs.
      # commitid_pattern  - Regular expression used to identify commitid in
      #                     text
      #
      # Returns a string with #commitid replaced with links. All links have a
      # 'commit-mention' class name attached for styling.
      def mention_link_filter(text, base_url='/', commitid_pattern)
        self.class.mentioned_commits_in(text, commitid_pattern) do |match, commitid|
          link = link_to_mentioned_commit(commitid)
          link ? match.sub("#{commitid}", link) : match
        end
      end

      def link_to_mentioned_commit(commitid)
        result[:mentioned_commitids] |= [commitid]

        url = base_url.dup
        url << "/" unless url =~ /[\/~]\z/
        url << commitid
        shortid = commitid[-7..-1] || commitid

        "<a href='#{url}' class='commit-mention'>#{shortid}</a>"
      end
    end
  end
end
