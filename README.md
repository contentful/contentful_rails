# Contentful Rails

A collection of useful things to help make it easier to integrate Contentful into your Rails app.
It includes view helpers, a Webhook handler, caching, and a Rails Engine to hook it all together.

This is a work in progress. It relies on the contentful_model gem (http://github.com/contentful/contentful_model)

## What is Contentful?

[Contentful](https://www.contentful.com) is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

# Configuration
ContentfulRails accepts a block for configuration. Best done in a Rails initializer.

```
ContentfulRails.configure do |config|
  config.authenticate_webhooks = true # false here would allow the webhooks to process without basic auth
  config.webhooks_username = "a basic auth username"
  config.webhooks_password = "a basic auth password"
  config.access_token = "your access token"
  config.preview_access_token = "your preview access token"
  config.management_token = "your management access token"
  config.space = "your space ID"
  config.options = "hash of options"
end
```

Note that you _don't_ have to separately configure ContentfulModel - adding the access tokens / space ID / options here will
pass to ContentfulModel in an initializer in the Rails engine.

The default is to authenticate the webhooks; probably a smart move to host on an HTTPS endpoint too.

# Allowing 'Russian Doll' style caching on Entries
The issue with 'Russian Doll' caching in Rails is that it requires a hit on the database to check the `updated_at` timestamp of an object.

This is obviously expensive when the object is called over an API. So this gem wraps caches `updated_at` locally, and checks that first on subsequent calls.

```
Foo.updated_at #returns a timestamp from cache, or from the API if no cache exists
```

# Webhooks Endpoint
If there's a new version of an entry we need to expire the timestamp from the cache.

This gem includes a controller endpoint for Contentful to POST back to.

To make use of this in your app:

## routes.rb
Mount the ContentfulRails engine at your preferred url:

```
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

```
helper ContentfulRails::MarkdownHelper
```

This allows you to call `parse_markdown(@your_markdown)` and get HTML. *Note* that out of the box, the `parse_markdown()` is really permissive and allows you to put HTML in the Contentful markdown fields. This might not be what you want.

## Manipulating images
To manipulate images which are referenced in your markdown, you can pass the following into the `parse_markdown()` call.

```
parse_markdown(@your_markdown, image_options: {width: 1024, height: 1024})
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

```
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
