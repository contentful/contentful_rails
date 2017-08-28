require 'redcarpet'
# A custom renderer for Redcarpet, which adds options for manipulating images through the URL of the image,
# and building links based on the content of the link.
#
# You can subclass this in your application, to add or manipulate specific markup to elements in the markdown.
class ContentfulRails::MarkdownRenderer < Redcarpet::Render::HTML
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  def initialize(opts)
    @options = opts
    @image_parameters = {
      w: @options[:image_options][:width], #width in px
      h: @options[:image_options][:height], #height in px
      fit: @options[:image_options][:fit], #crop, scale, pad, thumb
      f: @options[:image_options][:focus], #top, right, bottom, left, top_right, top_left, bottom_right, bottom_left, face
      fm: @options[:image_options][:format], #jpg, png
      bg: @options[:image_options][:background_colour], #no idea what the options are, but 'transparent' works for pngs
      r: @options[:image_options][:corner_radius], #corner radius in px
      q: @options[:image_options][:quality]
    }.delete_if {|k,v| v.nil?}
    super
  end

  def image(link, title, alt_text)
    # add the querystring to the image
    if @image_parameters.present?
      prefix = link.include?("?") ? "&" : "?"
      link += "#{prefix}#{@image_parameters.to_query}"
    end
    # return a content tag
    content_tag(:img, nil, src: link.to_s, alt: alt_text, title: title)
  end

end