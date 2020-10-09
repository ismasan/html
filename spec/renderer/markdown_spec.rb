# frozen_string_literal: true

require 'spec_helper'
require 'html/renderer/markdown'

RSpec.describe HTML::Renderer::Markdown do
  let(:tag) do
    HTML.tag(:div) do |div|
      div.tag!(:h1, 'heading 1')
      div.tag!(:p, 'para 1')
      div.tag!(:div) do |d2|
        d2.tag!(:p) do |p|
          p.tag!(:strong, 'This is a link: ')
          p.tag!(:a, 'click', href: 'https://google.com')
          '<- click that'
        end
      end
    end
  end

  specify 'rendering markdown' do
    output = described_class.render(tag)
    expect(output).to eq(%(# heading 1\n\npara 1\n\n**This is a link: **(click)[[\"https://google.com\"]]<- click that\n\n\n\n\n\n))
  end
end
