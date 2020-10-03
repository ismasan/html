# frozen_string_literal: true

RSpec.describe HTML::Tag do
  specify do
    tag = HTML::Tag.new(:br)
    expect(tag.to_s).to eq(%(<br />))

    tag = HTML::Tag.new(:h1, 'Hello', id: 'title', class: ['c1', 'c2'])
    expect(tag.to_s).to eq(%(<h1 id="title" class="c1 c2">Hello</h1>))

    tag = HTML::Tag.new(:div, class: 'box') do |c|
      c.tag(:h1, 'Title')
      c.tag(:p, 'Paragraph')
    end

    expect(tag.to_s).to eq(%(<div class="box">\n<h1>Title</h1>\n<p>Paragraph</p>\n</div>))
  end
end
