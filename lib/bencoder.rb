module Bencoder
	# Base class for all other Errors
	class Error < RuntimeError; end

	# Raised on syntax errors during the parsing
	class UnexpectedToken < Error; end

	# Raised on an unexpected end of the parsed string
	class UnexpectedEOS < Error; end

	# Returns a Bencoded representation of the given object _obj_.
	# Supported types are: *String*, *Symbol*, *Fixnum*, *Array*, *Hash*;
	# raises *ArgumentError* if called with an argument of other type.
	def self.encode(obj)
		if (obj.instance_of?(String) || obj.instance_of?(Symbol))
			return "#{obj.length}:#{obj}"
		elsif (obj.instance_of?(Fixnum))
			return "i#{obj}e"
		elsif (obj.instance_of?(Array))
			s = "l"
			obj.each { |x| s += encode(x) }
			return s + "e"
		elsif (obj.instance_of?(Hash))
			s = "d"
			obj.each { |k, v| s += "#{encode(k)}#{encode(v)}" }
			return s + "e"
		else
			raise ArgumentError.new("Unsupported type: #{obj.class}")
		end
	end

	# Decodes a Bencoded string or char enumerator and returns plain object.
	# Supported types are: *String*, *Enumerator*;
	# raises *ArgumentError* if called with an argument of other type.
	def self.decode(obj)
		if (obj.instance_of?(String))
			i = obj.each_char
			i.extend(CountingEnumerator)
			return parse(i)
		elsif (obj.instance_of?(Enumerator))
			obj.extend(CountingEnumerator)
			return parse(obj)
		end
		raise ArgumentError.new("Unsupported type: #{obj.class}")
	end

	# A module that holds monkey patches.
	# You can activate them locally by `using MonkeyPatches`.
	# Also contains method `apply` that extends only particular object.
	module MonkeyPatches
		# Adds method `to_bencode` to any given object.
		# Useful only for objects accepted by Bencoder.encode.
		# Example: `a = "hello"; Bencoder::MonkeyPatches.apply(a); a.to_bencode
		# # => "5:hello"`
		def self.apply(obj)
			obj.extend(Bencodable)
		end

		[String, Symbol, Fixnum, Array, Hash].each { |c|
			refine(c) {
				def to_bencode
					Bencoder::encode(self)
				end
			}
		}

		private

		module Bencodable # :nodoc:
			def to_bencode
				Bencoder::encode(self)
			end
		end
	end

	private

	module CountingEnumerator # :nodoc:
		def pos
			@pos
		end

		def next_
			@pos += 1
			old_next
		end

		def self.extended(to)
			to.instance_exec {
				alias :old_next :next
				alias :next :next_
				@pos = 0
			}
		end
	end

	def self.parse(i)
		begin
			if (i.peek == Literal::INT)
				i.next
				num = parse_int(i)
				if (i.peek == Literal::EEND)
					i.next
					return num
				end
				raise UnexpectedToken.new("'#{i.peek}' at "\
					"position #{i.pos}, expected /[0-9]/ or 'e'")
			elsif ((c = i.peek) >= '0' && c <= '9')
				sz = parse_int(i)
				if (i.peek == Literal::STRING_DELIM)
					i.next
					s = ""
					sz.times do
						s += i.next
					end
					return s
				end
				raise UnexpectedToken.new("'#{i.peek}' at "\
					"position #{i.pos}, expected ':'")
			end
			if (i.peek == Literal::LIST)
				i.next
				l = []
				while (i.peek != Literal::EEND)
					l << parse(i)
				end
				i.next
				return l
			end
			if (i.peek == Literal::DICTIONARY)
				i.next
				d = {}
				while (i.peek != Literal::EEND)
					d[parse(i)] = parse(i);
				end
				i.next
				return d
			end
			if (i.peek == Literal::EEND)
				raise UnexpectedToken.new("'#{i.peek}' at position #{i.pos}, "\
				"expected 'i', /[0-9]/, 'l' or 'd'")
			end
		rescue StopIteration
			raise UnexpectedEOS
		end

		raise UnexpectedToken.new("'#{i.peek}' at position #{i.pos}, "\
			"expected 'i', /[0-9]/, 'l', 'd', or 'e'")
	end

	module Literal # :nodoc:
		EEND = 'e'
		INT = 'i'
		STRING_DELIM = ':'
		LIST = 'l'
		DICTIONARY = 'd'
	end

	def self.parse_int(i)
		s = ""
		if ((c = i.peek) == '-' || c >= '0' && c <= '9')
			s += i.next
			while ((c = i.peek) >= '0' && c <= '9')
				s+= i.next
			end
		end
		return s.to_i
	end
end
