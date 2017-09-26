[gem]: https://rubygems.org/gems/dry-more-container
[travis]: https://travis-ci.org/mkristian/dry-more-container
[gemnasium]: https://gemnasium.com/mkristian/dry-more-container
[codeclimate]: https://codeclimate.com/github/mkristian/dry-more-container
[coveralls]: https://coveralls.io/r/mkristian/dry-more-container
[codeissues]: https://codeclimate.com/github/mkristian/dry-more-container

# dry-more-container
more containers derived from dry-container

[![Gem Version](https://badge.fury.io/rb/dry-more-container.svg)][gem]
[![Build Status](https://travis-ci.org/mkristian/dry-more-container.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/badges/github.com/mkristian/dry-more-container.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/mkristian/dry-more-container/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/mkristian/dry-more-container/badge.svg?branch=master)][coveralls]
[![Issue Count](https://codeclimate.com/github/mkristian/dry-more-container/badges/issue_count.svg)][codeissues]

## Rubygems/Bundler

```
gem install dry-more-container
```

or Gemfile:
```
gem 'dry-more-container'
```

## Singleton Container with Dependency Injection

The idea is to have components or services which all are using dry-auto_inject to inject their dependencies. The `Dry::More::Container::Singleton` is dry-container with a special resovler. You need register the service/component class itself (not the an instance of it):

``` Ruby
singletons = Dry::More::Container::Singleton
Import = Dry::AutoInject(singletons)

class A; include Import['b']; end
class B; include Import['c']; end
class C; include Import['d']; end
class D; end

singletons.register('a', A)
singletons.register('b', B)
singletons.register('c', C)
singletons.register('d', D)
```

On retrieve the singleton container will create a single instance of the class under the given key and also resolves the dependencies as well in the same manner:

``` Ruby
singleton['a']

```

Now the singleton container has an instance of all services/components.

On circular dependencies there will be an `Dry::Container::Error`.

See also [singleton_spec](spec/singleton_spec.rb).

## Directory Container

All components are located on a given directory on the filesystem and they need to register themself when the ruby file gets required. This can be achieved via a builder object or any static factory/builder method:

``` Ruby
directory = singleton.register(:container, Dry::More::Container::Directory)
class Builder < Dry::More::Container::Directory::Builder
  include Import['container']
  def do_build(&block)
    Proc.new { block.call(@key) }
  end
end

```

File `lib/components/some_key.rb`

``` Ruby
Builder.build(:some_key) { |key| "do something with the #{key}" } 
```

File `lib/components/file_as_key.rb`

``` Ruby
Builder.build(__FILE__) { |key| "do something with the #{key}" } 
```

With this setup you can retrieve retrieve two components from your directory container:

``` Ruby
container['some_key']
container['file_as_key']
```

## Lazy vs. Eager

Both containers are instantiating the components in a lzay way. The Singleton-Container instantiate the class on first retrieval and the Directory-Container requires the file from the configured directory on first retrieval.

The eager loading must be first configured and then triggered by the `finalize` method:

``` Ruby
container.config.lazy = false
container.finalize
```

For the Singleton-Container this will instantiate all register class and for the Directory-Container this will require all files from the configured directory.

## Contributing

Bug reports, comments and pull requests are welcome.

## Meta-Foo

be happy and enjoy.



