# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'HTML::InheritableClassSettings' do
  specify do
    Parent = Class.new do
      extend HTML::InheritableClassSettings

      def_settings :props, setter: :prop
    end

    Unrelated = Class.new do
      extend HTML::InheritableClassSettings
    end

    expect(Parent.props).to eq({})
    Parent.prop(:foo, 'bar')
    Parent.prop(:with_default, 'bar')
    expect(Parent.props[:foo]).to eq('bar')

    Child = Class.new(Parent)
    expect(Child.props[:foo]).to eq('bar')
    Child.prop(:foo, 'lol')
    expect(Parent.props[:foo]).to eq('bar')
    expect(Child.props[:foo]).to eq('lol')
    expect(Unrelated.respond_to?(:props)).to be(false)
  end
end
