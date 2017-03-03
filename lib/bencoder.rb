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
			p = CountingEnumerator.new(obj.each_char)
			return parse(p)
		elsif (obj.instance_of?(Enumerator))
			p = CountingEnumerator.new(obj)
			return parse(p)
		end
		raise ArgumentError.new("Unsupported type: #{obj.class}")
	end

	private

	class CountingEnumerator # :nodoc:
		attr_accessor :pos
		def initialize(target)
			@t = target
			@pos = 0
		end

		def peek
			@t.peek
		end

		def next
			@pos += 1
			@t.next
		end

		def method_missing(method_name, *args)
			@t.send(method_name, *args)
		end
	end

	def self.parse(i)
		begin
			if (i.peek == Literal::INT)
				i.next
				num = parse_int(i)
				if (i.next == Literal::EEND)
					return num
				end
			elsif (i.peek.match(/[0-9]/))
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
		if (i.peek.match(/[0-9-]/))
			s += i.next
			while (i.peek.match(/[0-9]/))
				s+= i.next
			end
		end
		return s.to_i
	end
end
