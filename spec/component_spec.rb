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

    outer_var = 1
    output = Parent.render(title: 'Parent') do |c|
      c.tag :span, 'Content here'
      "last #{outer_var}"
    end

    expect(output).to eq(%(<div class="parent"><h1>Parent</h1><p><span>Content here</span>last 1</p></div>))
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

  specify 'functional components' do
    list = described_class.build do |c|
      tag(:p, 'one')
      tag(:p, 'two')
      tag(:p, 'three')
      content
    end

    out = list.render do
      'trailing'
    end
    expect(out).to eq(%(<p>one</p><p>two</p><p>three</p>trailing))
  end

  describe 'slots' do
    specify 'trancludes slots' do
      list = Class.new(described_class) do
        slot :s1
        slot :s2

        def render
          tag(:div, slots[:s1], class: 's1')
          tag(:div, content, class: 'ctn')
          tag(:div, class: 's2') do |d|
            slots[:s2]
          end
        end
      end

      out = list.render do |r|
        r.slot(:s1, 'Slot 1')
        r.tag(:span, 'Content here')
        r.slot(:s2) do |s2|
          s2.tag(:p, 'Slot 2')
        end
        'last'
      end

      expect(out).to eq(%(<div class="s1">Slot 1</div><div class="ctn"><span>Content here</span>last</div><div class="s2"><p>Slot 2</p></div>))
    end
  end
end
