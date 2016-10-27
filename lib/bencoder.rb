module Bencoder
	class Error < RuntimeError; end
	class UnexpectedToken < Error; end
	class UnexpectedEOS < Error; end
	class UnsupportedType < Error; end

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
			raise UnsupportedType.new(obj.class)
		end
	end

	def self.decode(str)
		raise UnsupportedType.new(str.class) unless (str.instance_of? String)
		parse(str.each_char)
	end

	private
	
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
				if (i.next == Literal::COLON)
					s = ""
					sz.times do
						s += i.next
					end
					return s
				end
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

		raise UnexpectedToken.
			new("'#{i.peek}', expected 'i', /[0-9]/, 'l', or 'd'")
	end

	module Literal
		EEND = 'e'
		INT = 'i'
		COLON = ':'
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