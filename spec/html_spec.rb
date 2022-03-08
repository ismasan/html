# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HTML::Tag do
  specify 'simple self-closing tag' do
    tag = HTML.tag(:br)
    expect(tag.to_s).to eq(%(<br />))
    tag = HTML.tag(:link, rel: 'stylesheet')
    expect(tag.to_s).to eq(%(<link rel="stylesheet" />))
  end

  specify 'tag with content and attributes' do
    tag = HTML.tag(:h1, 'Hello', id: 'title', class: ['c1', 'c2'])
    expect(tag.to_s).to eq(%(<h1 id="title" class="c1 c2">Hello</h1>))
  end

  specify 'boolean attributes' do
    tag = HTML.tag(:input, type: 'checkbox', name: 'foo', checked: true)
    expect(tag.to_s).to eq(%(<input type="checkbox" name="foo" checked />))
    tag = HTML.tag(:input, type: 'checkbox', name: 'foo', checked: false)
    expect(tag.to_s).to eq(%(<input type="checkbox" name="foo" />))
  end

  specify 'Hash attributes' do
    tag = HTML.tag(:strong, 'hello', data: { foo: 1, bar: 'lol' })
    expect(tag.to_s).to eq(%(<strong data-foo="1" data-bar="lol">hello</strong>))
  end

  specify 'Hash attributes' do
    tag = HTML.tag(:strong, 'hello', class: %w[cl1 cl2])
    expect(tag.to_s).to eq(%(<strong class="cl1 cl2">hello</strong>))
  end

  specify 'nested tags' do
    tag = HTML.tag(:div, class: 'box') do |c|
      c.h1 'Title'
      c.p 'Paragraph'
    end

    expect(tag.to_s).to eq(%(<div class="box"><h1>Title</h1><p>Paragraph</p></div>))
  end

  specify ':html5 tag' do
    tag = HTML.tag(:html5) do |c|
      c.head
      c.body id: 'box'
    end
    expect(tag.to_s).to eq(%(<!DOCTYPE html>\n<html><head></head><body id="box"></body></html>))
  end

  it 'creates methods for tags' do
    expect(HTML::Proxy.instance_methods.include?(:table)).to be(false)
    expect(HTML::Proxy.instance_methods.include?(:td)).to be(false)
    tag = HTML.tag(:div, class: 'box') do |c|
      c.table do |t|
        t.tr do |t|
          t.td 'row1'
        end
      end
    end
    expect(HTML::Proxy.instance_methods.include?(:table)).to be(true)
    expect(HTML::Proxy.instance_methods.include?(:td)).to be(true)
  end

  specify 'handling extra trailing content in block' do
    tag = HTML.tag(:div, class: 'box') do |c|
      c.tag(:p, 'para')
      "free text"
    end

    expect(tag.to_s).to eq(%(<div class="box"><p>para</p>free text</div>))
  end
end
