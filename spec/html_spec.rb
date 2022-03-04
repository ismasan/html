# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HTML::Tag do
  specify 'simple self-closing tag' do
    tag = HTML.tag(:br)
    expect(tag.to_s).to eq(%(<br />))
  end

  specify 'tag with content and attributes' do
    tag = HTML.tag(:h1, 'Hello', id: 'title', class: ['c1', 'c2'])
    expect(tag.to_s).to eq(%(<h1 id="title" class="c1 c2">Hello</h1>))
  end

  specify 'nested tags' do
    tag = HTML.tag(:div, class: 'box') do |c|
      c.tag(:h1, 'Title')
      c.tag(:p, 'Paragraph')
    end

    expect(tag.to_s).to eq(%(<div class="box"><h1>Title</h1><p>Paragraph</p></div>))
  end

  specify 'handling extra trailing content in block' do
    tag = HTML.tag(:div, class: 'box') do |c|
      c.tag(:p, 'para')
      "free text"
    end

    expect(tag.to_s).to eq(%(<div class="box"><p>para</p>free text</div>))
  end
end
