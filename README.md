# bencoder
Ruby gem that provides abilities to encode/decode [Bencoded strings](https://en.wikipedia.org/wiki/Bencode)

### How to use
1. Install
2. `require "bencoder"`
3. `Bencoder.decode("l3:foo3:bare") # => ["foo", "bar"]`
4. `Bencoder.encode({year: 1984}) # => "d4:yeari1984ee"`

### Installation
1. Download or clone
2. Run `gem build`. A new gem file will be created.
3. Install `gem install bencoder-0.1.0.gem`
