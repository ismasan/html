# frozen_string_literal: true

RSpec.describe HTML::Component do
  specify do
    Input = Class.new(described_class) do
      prop :name
      prop :value

      def render
        tag :div, class: 'input' do |c|
          c.tag :input, type: 'text', name: props[:name], value: props[:value]
        end
      end
    end

    row = Class.new(described_class) do
      def render
        tag :div, class: 'row' do |c|
          c.tag Input.new(name: 'email', value: 'lol@ca.cl')
        end
      end
    end

    expect(Input.render(name: 'email', value: 'email@me.cl')).to eq(%(<div class="input">\n<input type="text" name="email" value="email@me.cl" />\n</div>))
    expect(row.render).to eq(%(<div class="row">\n<div class="input">\n<input type="text" name="email" value="lol@ca.cl" />\n</div>\n</div>))
  end

  specify 'nested content' do
    Parent = Class.new(described_class) do
      prop :title

      def render
        tag :div, class: 'parent' do |c|
          c.tag :h1, props[:title]
          c.tag :p do |c|
            content
          end
        end
      end
    end

    output = Parent.render(title: 'Parent') do |c|
      'Content here'
    end

    expect(output).to eq(%(<div class="parent">\n<h1>Parent</h1>\n<p>\nContent here\n</p>\n</div>))
  end
end
