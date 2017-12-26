[gem]: https://badge.fury.io/rb/dry-dependency-injection
[travis]: https://travis-ci.org/mkristian/dry-dependency-injection
[gemnasium]: https://gemnasium.com/mkristian/dry-dependency-injection
[codeclimate]: https://codeclimate.com/github/mkristian/dry-dependency-injection
[coveralls]: https://coveralls.io/github/mkristian/dry-dependency-injection?branch=master
[codeissues]: https://codeclimate.com/github/mkristian/dry-dependency-injection

# dry-dependency-injection
more containers derived from dry-container

[![Gem Version](https://badge.fury.io/rb/dry-dependency-injection.svg)][gem]
[![Build Status](https://travis-ci.org/mkristian/dry-dependency-injection.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/badges/github.com/mkristian/dry-dependency-injection.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/mkristian/dry-dependency-injection/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/mkristian/dry-dependency-injection/badge.svg?branch=master)][coveralls]
[![Issue Count](https://codeclimate.com/github/mkristian/dry-dependency-injection/badges/issue_count.svg)][codeissues]

## Rubygems/Bundler

```
gem install dry-dependency-injection
```

or Gemfile:
```
gem 'dry-dependency-injection'
```

## Singleton Container with Dependency Injection

The idea is to have components or services which all are using dry-auto_inject to inject their dependencies. The `Dry::More::Container::Singleton` is dry-container with a special resovler. You need register the service/component class itself (not the an instance of it):

``` Ruby
class Singletons; extend Dry::DependencyInjection::Singletons; end
Import = Dry::AutoInject(Singletons)

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
Singletons['a']

```

Now the singleton container has an instance of all services/components.

On circular dependencies there will be an `Dry::Container::Error`.

See also [singletons_spec](spec/singletons_spec.rb).


## Finalize, Lazy vs. Eager

 The container is instantiating the components per default in a lazy way. The `finalize` method on the container does ensure all eager components get initialized. If you configure the container to be not-lazy then the `finalize` will instantiate **all** components. If the container is lazy then `finalize` only instantiate the components which are marks as **eager** by extending the component with `Dry::DependencyInjection::Eager`

```Ruby
class MyEagerComponent
  extend Dry::DependencyInjection::Eager
```

In case there are no eager component then `finalize` is noop. The eager loading must be first configured and then the `finalize` method needs to be called:

``` Ruby
container.config.lazy = false
container.finalize
```

## Plugin Example

Please see the simple plugin implementation in [example](example) provided.

## Contributing

Bug reports, comments and pull requests are welcome.

## Meta-Foo

be happy and enjoy.
