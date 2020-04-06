# Contentful Rails

A collection of useful things to help make it easier to integrate Contentful into your Rails app.
It includes view helpers, a Webhook handler, caching, and a Rails Engine to hook it all together.

This is a work in progress. It relies on the contentful_model gem (http://github.com/contentful/contentful_model)

## What is Contentful?

[Contentful](https://www.contentful.com) provides a content infrastructure for digital teams to power content in websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship digital products faster.

# Configuration
ContentfulRails accepts a block for configuration. Best done in a Rails initializer.

```ruby
ContentfulRails.configure do |config|
  config.authenticate_webhooks = true # false here would allow the webhooks to process without basic auth
  config.webhooks_username = "a basic auth username"
  config.webhooks_password = "a basic auth password"
  config.access_token = "your access token"
  config.preview_access_token = "your preview access token"
  config.management_token = "your management access token"
  config.space = "your space ID"
  config.environment = "your environment ID"
  config.contentful_options = "hash of options"
end
```

Note that you _don't_ have to separately configure ContentfulModel - adding the access tokens / space ID / options here will
pass to ContentfulModel in an initializer in the Rails engine.

The default is to authenticate the webhooks; probably a smart move to host on an HTTPS endpoint too.

### Entry Mapping

By default, ContentfulRails will try to define your `entry_mapping` configuration for you.  It does this by iterating through
 the descendents of the base class `ContentfulModel::Base` during initialization.  In order to ensure these classes are
 loaded by this time, it will call `eager_load!` for the entire application.  If this is not desired, you can set the
 `eager_load_entry_mapping` config to false set your entry mapping manually by setting the entry_mapping config
  as [described here](https://github.com/contentful/contentful.rb#custom-resource-classes).


```ruby
ContentfulRails.configure do |config|
  ...
  config.eager_load_entry_mapping = false
  config.contentful_options = {
    entry_mapping: {
      'article' => Article,
      ...
    }
  }
end
```

**Note:** If you do not define the entry mapping in your configuration, the webhook cache expiration will likely not work as expected

# Allowing 'Russian Doll' style caching on Entries
The issue with 'Russian Doll' caching in Rails is that it requires a hit on the database to check the `updated_at` timestamp of an object.

This is obviously expensive when the object is called over an API. So this gem wraps caches `updated_at` locally, and checks that first on subsequent calls.

```ruby
Foo.updated_at #returns a timestamp from cache, or from the API if no cache exists
```

# Webhooks Endpoint
If there's a new version of an entry we need to expire the timestamp from the cache.

This gem includes a controller endpoint for Contentful to POST back to.

To make use of this in your app:

## routes.rb
Mount the ContentfulRails engine at your preferred url:

```ruby
mount ContentfulRails::Engine => '/contentful' #feel free to choose a different endpoint name
```

This will give you 2 routes:

`/contentful/webhooks` - the URL for contentful to post back to.
`/contentful/webhooks/debug` - a development-only URL to check you have mounted the engine properly :-)

## What the webhook handler does
At the moment all this does is delete the timestamp cache entry, which means that a subsequent call to `updated_at` calls the API.

# View Helpers
Contentful has a [really nice url-based image manipulation API](https://www.contentful.com/blog/2014/08/14/do-more-with-images-on-contentful-platform/).

To take advantage of this, there's a custom Redcarpet renderer which allows you to pass the image parameters you want into the call to a `parse_markdown()` method.

In your application_controller.rb:

```ruby
helper ContentfulRails::MarkdownHelper
```

This allows you to call `parse_markdown(@your_markdown)` and get HTML. *Note* that out of the box, the `parse_markdown()` is really permissive and allows you to put HTML in the Contentful markdown fields. This might not be what you want.

## Manipulating images
To manipulate images which are referenced in your markdown, you can pass the following into the `parse_markdown()` call.

```ruby
parse_markdown(@your_markdown, image_options: { width: 1024, height: 1024 })
```

The `image_options` parameter takes the following options (some are mutually exclusive. Read the [instructions here](https://www.contentful.com/blog/2014/08/14/do-more-with-images-on-contentful-platform/)):

* `:width`
* `:height`
* `:fit`
* `:focus`
* `:corner_radius`
* `:quality`

## Subclassing the MarkdownRenderer class
Sometimes you might want to apply some specific class, markup or similar to an html entity when it's being processed. [With RedCarpet that's dead easy](https://github.com/vmg/redcarpet#and-you-can-even-cook-your-own).

Just subclass the `ContentfulRails::MarkdownRenderer` class, and call any methods you need.

```ruby
class MyRenderer < ContentfulRails::MarkdownRenderer
  # If you want to pass options into your renderer, you need to overload initialize()
  def initialize(opts)
    @options = opts
    super
  end

  # If you want to do something special with links:
  def link(link,title,content)
    # Add a class name to all links, for example
    class_name = "my-link-class-name"
    content_tag(:a, content, href: link, title: title, class: class_name)
  end
end
```

You can overload any methods exposed in RedCarpet.

# Preview API
ContenfulRails can be set up to use the [Contenful Preview API](https://www.contentful.com/developers/docs/references/content-preview-api/), and has the option of protecting that content behind basic authentication.
To enable the preview api, add the below settings to your configuration.

```
ContentfulRails.configure do |config|
  config.enable_preview_domain = true # use the preview domain
  config.preview_domain = "first portion of preview subdomain `sub.domain`"
  config.preview_access_token = "your preview access token"
  config.preview_username = "a basic auth username"
  config.preview_password = "a basic auth password"
end
```

If you site is already protected with another form of authentication, then leave `preview_username` and `preview_password` unset.
This will skip the authentication step when displaying preview content.

# To Do
Some things would be nice to do:

* Tests :-)
* Make caching the timestamp optional in the configuration
* Implement a method on ContentfulModel to simulate a parent-child relationship, so we can invalidate caches for parent items


# Licence
Licence is MIT. Please see MIT-LICENCE in this repo.

# Contributing
Please feel free to contribute!

* Fork this repo
* Make your changes
* Commit
* Create a PR
