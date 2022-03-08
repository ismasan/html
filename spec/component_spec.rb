# frozen_string_literal: true

RSpec.describe HTML::Component do
  specify do
    input = Class.new(described_class) do
      name :input
      prop :name, default: 'correo'
      prop :value
      prop :class do |cl| # prop transform block
        "mb:#{cl}"
      end

      def render
        builder.div class: ['input', props[:class]].compact do |c|
          c.tag :input, type: 'text', name: props[:name], value: props[:value]
        end
      end
    end

    row = Class.new(described_class) do
      def render
        builder.div class: 'row' do |c|
          c.input name: 'email', value: 'lol@ca.cl'
        end
      end
    end

    expect(input.render(name: 'email', value: 'email@me.cl', class: 'cl'))
      .to eq(%(<div class="input mb:cl"><input type="text" name="email" value="email@me.cl" /></div>))
    # Default prop values
    expect(input.render(value: 'email@me.cl'))
      .to eq(%(<div class="input"><input type="text" name="correo" value="email@me.cl" /></div>))
    expect(row.render).to eq(%(<div class="row"><div class="input"><input type="text" name="email" value="lol@ca.cl" /></div></div>))
  end

  specify 'nested content' do
    component = Class.new(described_class) do
      prop :title

      def render
        builder.div class: 'parent' do |c|
          c.tag :h1, props[:title]
          c.tag :p do |c|
            c << content
            c.tag(:small, 'smallprint')
          end
        end
      end
    end

    outer_var = 1
    output = component.render(title: 'Parent') do |c|
      c.tag :span, 'Content here'
      "last #{outer_var}"
    end

    expect(output).to eq(%(<div class="parent"><h1>Parent</h1><p><span>Content here</span>last 1<small>smallprint</small></p></div>))

    output = component.render(title: 'Parent') do
      tag :span, 'private block'
      "last #{outer_var}"
    end

    expect(output).to eq(%(<div class="parent"><h1>Parent</h1><p><span>private block</span>last 1<small>smallprint</small></p></div>))
  end

  specify 'listing arrays' do
    contact_list = Class.new(described_class) do
      prop :contacts
      def render
        builder.ul class: 'contacts' do |ul|
          props[:contacts].each do |contact|
            ul.li contact
          end
        end
      end
    end

    expect(contact_list.render(contacts: ['A', 'B'])).to eq(%(<ul class="contacts"><li>A</li><li>B</li></ul>))
  end

  specify 'a component with multiple content tags' do
    list = Class.new(described_class) do
      def render
        builder.p 'one'
        builder.p 'two'
        builder.p 'three'
        'trailing'
      end
    end

    expect(list.render).to eq(%(<p>one</p><p>two</p><p>three</p>trailing))
  end

  specify '.define' do
    HTML.define(:warning) do |c, props|
      c.span class: 'warning' do |t|
        t.strong props[:label]
      end
    end
    tag = HTML.define(:top) do |c, props|
      c.div do |t|
        t.warning props
      end
    end

    expect(tag.render(label: 'Achtung!')).to eq(%(<div><span class="warning"><strong>Achtung!</strong></span></div>))
  end

  describe 'slots' do
    let!(:component) do
      Class.new(described_class) do
        slot :s1
        slot :s2 do |t|
          t.span 'Default'
        end

        def render
          builder.div slots[:s1], class: 's1'
          builder.div(content, class: 'ctn') if content.any?
          builder.div(class: 's2') do |d|
            slots[:s2]
          end
        end
      end
    end

    specify 'trancludes slots' do
      out = component.render do |r|
        r.slot(:s1, 'Slot 1')
        r.tag(:span, 'Content here')
        r.slot(:s2) do |s2|
          s2.p 'Slot 2'
        end
        'last'
      end

      expect(out).to eq(%(<div class="s1">Slot 1</div><div class="ctn"><span>Content here</span>last</div><div class="s2"><p>Slot 2</p></div>))
    end

    specify 'fills in slot defaults' do
      out = component.render do |r|
        r.slot(:s1, 'Slot 1')
      end

      expect(out).to eq(%(<div class="s1">Slot 1</div><div class="s2"><span>Default</span></div>))
    end
  end

  specify 'components as props' do
    comp1 = described_class.build do |t, props|
      t.div do |d|
        d << props[:child]
      end
    end

    child_class = described_class.build { |t, props| t.span(props[:name]) }
    out = comp1.render(child: child_class.new(name: 'Joan'))
    expect(out).to eq(%(<div><span>Joan</span></div>))
  end

  context 'fragment caching' do
    around do |example|
      prev_store = HTML.cache_store
      HTML.cache_store = HTML::InMemCache.new
      example.run
      HTML.cache_store = prev_store
    end

    it 'caches fragments' do
      increment = Class.new do
        def initialize
          @count = 0
        end

        def run
          @count += 1
        end
      end

      user_class = Struct.new(:name, :cache_key)

      component = Class.new(described_class) do
        prop :user
        prop :increment

        def render
          builder.tag(:div, class: 'box') do |box|
            box.tag(:h1, props[:user].name)
            box.cache(props[:user].cache_key) do |c|
              c.tag :span, props[:increment].run
            end
          end
        end
      end

      incr = increment.new

      out1 = component.render(user: user_class.new('Ismael', 'aa'), increment: incr)
      expect(out1).to eq(%(<div class="box"><h1>Ismael</h1><span>1</span></div>))

      out2 = component.render(user: user_class.new('Joe', 'aa'), increment: incr)
      expect(out2).to eq(%(<div class="box"><h1>Joe</h1><span>1</span></div>))

      out3 = component.render(user: user_class.new('Ismael', 'bb'), increment: incr)
      expect(out3).to eq(%(<div class="box"><h1>Ismael</h1><span>2</span></div>))
    end
  end

  specify 'subclassing' do
    klass1 = Class.new(described_class) do
      prop :title, default: 'Hello'
    end
    klass2 = Class.new(klass1) do
      prop :desc
      def render
        builder.div do |d|
          d.h1 props[:title]
          d.p props[:desc]
        end
      end
    end
    out = klass2.render(desc: 'Desc')
    expect(out).to eq(%(<div><h1>Hello</h1><p>Desc</p></div>))
  end
end
