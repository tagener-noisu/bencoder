require_relative '../lib/bencoder.rb'
require 'minitest/autorun'

using Bencoder::MonkeyPatches

class TestBencoder < MiniTest::Test
	def test_parsing_integer
		assert_equal(42, Bencoder::decode("i42e"))
		assert_equal(-42, Bencoder::decode("i-42e"))
		assert_equal(1234567890, Bencoder::decode("i1234567890e"))
	end

	def test_parsing_string
		assert_equal("spam", Bencoder::decode("4:spam"))
	end

	def test_parsing_list
		assert_equal(["spam", 42], Bencoder::decode("l4:spami42ee"))
	end

	def test_parsing_empty_list
		assert_equal([], Bencoder::decode("le"))
	end

	def test_parsing_dictionary
		assert_equal({"spam" => 42}, Bencoder::decode("d4:spami42ee"))
	end

	def test_parsing_epmty_dictionary
		assert_equal({}, Bencoder::decode("de"));
	end

	def test_parsing_nested_lists
		assert_equal(["foo", ["bar", "baz"]],
					 Bencoder::decode("l3:fool3:bar3:bazee"))
	end

    def test_parsing_nested_dicts
        assert_equal({"obj" => {"foo" => 42}},
					 Bencoder::decode("d3:objd3:fooi42eee"))
    end

	def test_decoding
		assert_equal({
			"object" => "counter",
			"items" => [{"peach" => 4}, {"pear" => 3}, {"apple" => 12}]},
		Bencoder::decode("d6:object7:counter5:itemsld5:peachi4eed4:peari3eed5:applei12eeee"))
	end

	def test_encoding_int
		assert_equal("i1337e", Bencoder.encode(1337))
	end

	def test_encoding_string
		assert_equal("5:Hello", Bencoder.encode("Hello"))
	end

	def test_encoding_array
		assert_equal("l3:foo3:bare", Bencoder.encode([:foo, "bar"]))
	end

	def test_encoding_hash
		assert_equal("d6:answeri42ee", Bencoder.encode({answer: 42}))
	end

	def test_encoding_nested_arrays
		assert_equal("l3:fool3:bar3:bazee",
			Bencoder::encode(["foo", ["bar", "baz"]]))
	end

	def test_encoding
		assert_equal("d6:object7:counter5:itemsld5:peachi4eed4:peari3eed5:applei12eeee",
			Bencoder::encode({
				"object" => "counter",
				"items" => [{"peach" => 4}, {"pear" => 3}, {"apple" => 12}]}))
	end

	def test_decode_accepts_enumerator
		assert_equal(42, Bencoder::decode("i42e".each_char))
	end

	def test_raises_argument_error_in_decode
		assert_raises ArgumentError do
			Bencoder.decode(/Freedom is slavery/)
		end
	end

	def test_raises_argument_error_in_encode
		assert_raises ArgumentError do
			Bencoder.encode(/Ignorance is strength/)
		end
	end

	def test_raises_on_short_string
		assert_raises Bencoder::UnexpectedEOS do
			Bencoder::decode("16:not_long_enough")
		end
	end

	def test_raises_on_unclosed_int
		assert_raises Bencoder::UnexpectedEOS do
			Bencoder::decode("i41")
		end

		e = assert_raises Bencoder::UnexpectedToken do
			Bencoder::decode("i1337ae")
		end
		assert(e.message.match(/at position 5/))
		assert(e.message.match(/expected \/\[0-9\]\/ or 'e'/))
	end

	def test_raises_on_unclosed_list
		assert_raises Bencoder::UnexpectedEOS do
			Bencoder::decode("li14e3:foo")
		end
	end

	def test_raises_on_unclosed_dict
		assert_raises Bencoder::UnexpectedEOS do
			Bencoder::decode("d3:foo3:bar")
		end
	end

	def test_raises_on_unexpected_end_token
		e = assert_raises Bencoder::UnexpectedToken do
			Bencoder::decode("e")
		end
		assert(e.message.match(/at position 0/))
		assert(e.message.match(/expected 'i', \/\[0-9\]\/, 'l' or 'd'/))
	end

	def test_monkey_patches
		assert_equal(1337.to_bencode, "i1337e")
		assert_equal("Atlas".to_bencode, "5:Atlas")
		assert_equal(Array.new.to_bencode, "le")
		assert_equal(Hash.new.to_bencode, "de")
	end
end
