require 'spec_helper'

class MarkdownHelperUser
  include ContentfulRails::MarkdownHelper
end

describe ContentfulRails::MarkdownHelper do
  subject { MarkdownHelperUser.new }

  describe 'parses markdown' do
    it 'renders just a string' do
      expect(subject.parse_markdown('foobar'))
        .to eq "<p>foobar</p>\n"
    end

    it 'renders with markdown markup' do
      expect(subject.parse_markdown('foo *bar*'))
        .to eq "<p>foo <em>bar</em></p>\n"
    end

    it 'renders fenced code blocks' do
      expect(subject.parse_markdown('foo ```bar```'))
        .to eq "<p>foo <code>bar</code></p>\n"
    end

    it 'supports inline html' do
      expect(subject.parse_markdown('foo <b>bar</b>'))
        .to eq "<p>foo <b>bar</b></p>\n"
    end

    it 'can add image API parameters - &amp; is a correct separator' do
      # for more info on &amp; versus &, please read here: http://htmlhelp.com/tools/validator/problems.html#amp

      expect(subject.parse_markdown('foo ![Image](https://images.contentful.com/asd/foo/bar.jpg)', image_options: { width: 100, focus: :face, fit: :thumb }))
        .to eq "<p>foo <img src=\"https://images.contentful.com/asd/foo/bar.jpg?f=face&amp;fit=thumb&amp;w=100\" alt=\"Image\"></img></p>\n"
    end
  end
end
