# HTML

Components-based HTML builder.

Compose HTML tags into components, unit test them.

Motivation:

* Easier to unit-test view components.
* Standalone, framework agnostic.
* Build components with semantics closer to your domain (ex. reusable `UserList` component instead of `<div class="user-list">...</div>`)
* More flexible Form objects to present and validate non-ActiveModel objects (API results, anything else).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'html'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install html

## Usage

### Tags

```ruby
h1 = HTML.tag(:h1, "A title", class: 'title')
h1.to_s # <h1 class="title">A title</h1>

nested = HTML.tag(:div, class: 'box') do |div|
  div.tag!(:p, 'Paragraph 1')
  div.tag!(:p) do |p|
    p.tag!('Click ')
    p.tag!(:a, 'here', href: 'https://google.com')
    '. Some trailing text'
  end
end

nested.to_s
# <div class="box">
#   <p>Paragraph 1</p>
#   <p>Click <a href="https://google.com">here</a>. Some trailing text</p>
# </div>
```

### Components

```ruby
class UserList < HTML::Component
  prop :title
  prop :users

  def render
    tag! :div, class: 'user-list' do |div|
      div.tag!(:h2, props[:title])
      div.tag!(:ul) do |ul|
        props[:users].each do |user|
          ul.tag!(:li) do |li|
            li.tag!(:span, user.name, class: 'user-name')
            li.tag!(:span, user.email, class: 'user-email')
          end
        end
      end
    end
  end
end

UserList.render(title: 'All users', users: [user1, user2, ...])
# Same as
UserList.new(title: '...', users: [...]).to_s
```

#### Registering components

Registering components with `HTML::Component.register` allows you to reuse components from within other components or even tags.

```ruby
HTML::Component.register(:user_list, UserList)

# Use it in tags
HTML.tag(:div, class: 'container') do |div|
  div.component!(:user_list, title: 'Title', users: [...])
end

# Use it in other components

class Page < HTML::Component
  def render
    tag!(:div, class: 'page') do |div|
      ...
      div.component!(:user_list, title: 'Users', users: [...])
      ...
    end
  end
end
```

#### Nested content

Use the special `content` variable within a component's `render` method.

```ruby
class Page < HTML::Component
  def render
    tag!(:div) do |div|
      div.tag!(:h1, 'Page title')
      div.tag! content
      div.component!(:user_list, title: 'Users', users: [...])
    end
  end
end

# Nest other content in the component
Page.render do
  tag!(:p, 'some variable content')
  # ... etc
end
```

#### Content slots

```ruby
class Page < HTML::Component
  slot :header
  slot :footer

  def render
    tag!(:div) do |div|
      div.tag!(:div, slots[:header], class: 'header')
      div.tag! content
      div.tag!(:div, slots[:footer], class: 'footer')
    end
  end
end

## Asign content to slots
Page.render do |page|
  page.slot!(:header) do |header|
    header.tag!(:nav, '...etc')
  end
  page.slot!(:footer) do |footer|
    footer.component!(:company_info)
    footer.tag!('... etc')
  end

  # Anything here is still assigned to `content`
  page.tag!(:h2, "Content here")
end
```

### Fragment caching

```ruby
class UserList < HTML::Component
  prop :users

  def render
    tag!(:h1, 'Users')
    # Russian doll-style caching
    cache!(props[:users].cache_key) do |users|
      users.tag!(:ul) do |ul|
        props[:users].each do |user|
          user.cache!(user.cache_key) do |c|
            c.component!(:user_row, user: user)
          end
        end
      end
    end
  end
end
```

To be continued...

### Custom renderers

Tags and components build an AST-like structure. Renderers use the Visitor pattern to render to some ouput format.
The default renderer outputs HTML, but it's also possible to write renderers for other formats. Example: Markdown or similarly formatted plain text. Could be useful for email `text/plain` views. Another example: PDF generation.

To be continued...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/html.

