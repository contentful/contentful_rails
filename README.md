# Contentful Rails
A collection of useful things to help make it easier to integrate Contentful into your Rails app.

This is a work in progress. It relies on the contentful_model gem (http://github.com/errorstudio/contentful_model)

# Configuration
ContentfulRails accepts a block for configuration. Best done in a Rails initializer.

```
ContentfulRails.configure do |config|
  config.authenticate_webhooks = true # false here would allow the webhooks to process without basic auth
  config.webhooks_username = "a basic auth username"
  config.webhooks_password = "a basic auth password"
end
```

The default is to authenticate the webhooks. Probably a smart move to host on an HTTPS endpoint too.

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
There's a view helper you can include in your application, to render the markdown from the Contentful API text fields.

In your application_controller.rb:

```
helper ContentfulRails::MarkdownHelper
```

This allows you to call `parse_markdown(@your_markdown)` and get HTML.

# To Do
Some things would be nice to do:

* Tests :-)
* Make caching the timestamp optional in the configuration
* Implement a method on ContentfulModel to simulate a parent-child relationship, so we can invalidate caches for parent items


# Contributing
Please feel free to contribute!

* Fork this repo
* Make your changes
* Commit
* Create a PR