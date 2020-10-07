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

    HTML::Component.register(:input, Input)

    row = Class.new(described_class) do
      def render
        tag :div, class: 'row' do |c|
          # c.tag Input.new(name: 'email', value: 'lol@ca.cl')
          c.component :input, name: 'email', value: 'lol@ca.cl'
        end
      end
    end

    expect(Input.render(name: 'email', value: 'email@me.cl')).to eq(%(<div class="input"><input type="text" name="email" value="email@me.cl" /></div>))
    expect(row.render).to eq(%(<div class="row"><div class="input"><input type="text" name="email" value="lol@ca.cl" /></div></div>))
  end

  specify 'missing arguments' do
    component = Class.new(described_class) do
      prop :foo
    end

    expect {
      component.render
    }.to raise_error(ArgumentError)

    expect {
      component.render(bar: 1)
    }.to raise_error(ArgumentError)

    # expect {
    #   component.render(foo:2, bar: 1)
    # }.to raise_error(ArgumentError)
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

    expect(output).to eq(%(<div class="parent"><h1>Parent</h1><p>Content here</p></div>))
  end

  specify 'listing arrays' do
    contact_list = Class.new(described_class) do
      prop :contacts
      def render
        tag(:ul, class: 'contacts') do |ul|
          props[:contacts].each do |contact|
            ul.tag(:li, contact)
          end
        end
      end
    end

    expect(contact_list.render(contacts: ['A', 'B'])).to eq(%(<ul class="contacts"><li>A</li><li>B</li></ul>))
  end

  specify 'a component with multiple content tags' do
    list = Class.new(described_class) do
      def render
        tag(:p, 'one')
        tag(:p, 'two')
        tag(:p, 'three')
        'trailing'
      end
    end

    expect(list.render).to eq(%(<p>one</p><p>two</p><p>three</p>trailing))
  end
end
