# bencoder
Ruby gem for [Bencode](https://en.wikipedia.org/wiki/Bencode) data serialization.

## How to use
1. Install
2. `require "bencoder"`
3. `Bencoder.decode("l3:foo3:bare") # => ["foo", "bar"]`
4. `Bencoder.encode({year: 1984}) # => "d4:yeari1984ee"`
5. Also you can apply monkey patches and use method `to_bencode` on an object
6. You can parse torrent files with it; just don't forget to open them in a binary mode

## Installation
1. Download or clone
2. Run `rake install`, or install manually with `gem build`/`gem install`
3. Tests can be run with `rake test`
4. Documentations can be created with `rake docs` or `rdoc lib/*.rb`
