module ContentfulRails
  module MarkdownHelper
    def parse_markdown(content)
      @markdown ||= Redcarpet::Markdown.new(
          Redcarpet::Render::HTML, autolink: true, space_after_headers: true, fenced_code_blocks: true
      )
      @markdown.render(content).html_safe
    end
  end
end