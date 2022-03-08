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
  div.p 'Paragraph 1'
  div.p do |p|
    p.tag('Click ')
    p.a 'here', href: 'https://google.com'
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
    builder.div class: 'user-list' do |div|
      div.h2 props[:title]
      div.ul do |ul|
        props[:users].each do |user|
          ul.li do |li|
            li.span user.name, class: 'user-name'
            li.span user.email, class: 'user-email'
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

Components are registered in `HTML.registry` by declaring their `.name`.
Registered components can be used as regular tags in other components or tags.

```ruby
class UserList < HTML::Component
  name :user_list
  # ...etc
end

# Use it in tags
HTML.tag(:div, class: 'container') do |div|
  div.user_list title: 'Title', users: [...]
end

# Use it in other components

class Page < HTML::Component
  def render
    builder.div class: 'page' do |div|
      ...
      div.user_list title: 'Users', users: [...]
      ...
    end
  end
end
```

This means that you can also override default tags:

```ruby
class Input < HTML::Component
  name :input
  prop :name
  prop :value
  prop :type, default: 'text'

  def render
    builder.span class: 'custom-input' do |span|
      span.input props
    end
  end
end

# Use it everywhere

HTML.tag(:form) do |form|
  form.input type: 'text', name: 'name', value: 'joe'
end
```

#### Functional components

Alternatively you can register procs as light-weight components.

```ruby
# The block gets yielded a tag builder and props Hash
HTML.define(:badge) do |t, props|
  t.label class: ['badge', "badge-#{props[:color]}"], id: props[:id] do |label|
    label.span props[:text]
  end
end

# Use it in other tags or components
HTML.define(:user_card) do |t, props|
  user = props[:user]

  t.div class: 'user-card' do |t|
    t.badge text: user.name, color: user.status, id: user.id
  end
end
```

#### Nested content

Use the special `content` variable within a component's `render` method.

```ruby
class Page < HTML::Component
  def render
    builder.div do |div|
      div.h1, 'Page title'
      div.tag content
      div.user_list, title: 'Users', users: [...]
    end
  end
end

# Nest other content in the component
Page.render do |c|
  c.p 'some variable content'
  # ... etc
end
```

#### Content slots

```ruby
class Page < HTML::Component
  slot :header
  slot :footer

  def render
    builder.div do |div|
      div.div slots[:header], class: 'header'
      div.tag content
      div.div slots[:footer], class: 'footer'
    end
  end
end

## Asign content to slots
Page.render do |page|
  page.slot(:header) do |header|
    header.nav '...etc'
  end
  page.slot(:footer) do |footer|
    footer.company_info
    footer.tag('... etc')
  end

  # Anything here is still assigned to `content`
  page.h2 "Content here"
end
```

### Fragment caching

```ruby
class UserList < HTML::Component
  prop :users

  def render
    builder.h1, 'Users'
    # Russian doll-style caching
    builder.cache(props[:users].cache_key) do |users|
      users.ul do |ul|
        props[:users].each do |user|
          user.cache(user.cache_key) do |c|
            c.user_row user: user
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

