# SauceTunnel

This is a Ruby gem which makes it easy to establish a proxy tunnel to
SauceLabs, via their `sc` command line utility.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sauce_tunnel'
```

And then execute:

```
$ bundle
```

You'll also want to install the `sc` command line utility. On macOS you
can do this via homebrew casks, like this:

```
brew cask install sauce-connect
```

On other platforms, please see: <https://wiki.saucelabs.com/display/DOCS/Sauce+Connect+Proxy>.

## Usage

You can configure and start a global tunnel like this:

``` ruby
SauceTunnel.start
```

This will block and wait until the tunnel is established. It is safe to call
this method lazily even from multiple threads when you need the tunnel.

If you need to configure the Tunnel, call `config` before calling start like
this:

``` ruby
SauceTunnel.config(sc_args: ["-B", "all"])
SauceTunnel.start
```

Available options are:

*sc_path:* Location of the `sc` command line utility, defaults to assuming `sc` is in PATH
*sc_args:* Additional args to pass to `sc`
*quiet:* If `true` no output will be printed to `stdout`.
*timeout:* Timeout for establishing the connection to SauceLabs
*shutdown_timeout:* Timeout for shutting down the tunnel.

You can also instantiate and use a Tunnel manually, but this is not recommended.

``` ruby
tunnel = SauceTunnel::Tunnel.new(sc_args: ["-B", "all"])
tunnel.connect # establish connection in the background
tunnel.await # wait for tunnel to start
tunnel.terminate # wait for tunnel to shut down
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
