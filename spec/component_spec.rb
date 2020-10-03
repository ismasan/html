# frozen_string_literal: true

RSpec.describe HTML::Component do
  specify do
    Input = Class.new(described_class) do
      def initialize(name, value)
        @name, @value = name, value
      end

      def render
        tag :div, class: 'input' do |c|
          c.tag :input, type: 'text', name: @name, value: @value
        end
      end
    end

    row = Class.new(described_class) do
      def render
        tag :div, class: 'row' do |c|
          c.tag Input.new('email', 'lol@ca.cl')
        end
      end
    end

    expect(Input.render('email', 'email@me.cl')).to eq(%(<div class="input">\n<input type="text" name="email" value="email@me.cl" />\n</div>))
    expect(row.render).to eq(%(<div class="row">\n<div class="input">\n<input type="text" name="email" value="lol@ca.cl" />\n</div>\n</div>))
  end
end
