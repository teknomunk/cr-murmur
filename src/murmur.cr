# TODO: Write documentation for `Murmur`
module Murmur
	VERSION = "0.1.0"

	class Hasher
		@seed : UInt32 = uninitialized UInt32
		def initialize( @seed )
		end

		private def compute( key : Pointer(UInt8), len : Int32 )
			h = @seed
			if len > 3
				key_x4 = key.unsafe_as(Pointer(UInt32))
				i = len >> 2
				loop do
					k = key_x4[0]; key_x4 += 1

					k *= 0xcc9e2d51
					k = ( k << 15 ) | ( k >> 17 )
					k *= 0x1b873593
					h ^= k
					h = (h << 13) | (h >> 19)
					h = (h * 5) + 0xe6546b64
					
					break if ( i -= 1 ) == 0
				end

				key = key_x4.unsafe_as(Pointer(UInt8))
			end
			if ( len & 3 ) != 0
				i = len & 3
				k = 0
				key += (i-1)
				loop do
					k <<= 8
					k |= key.value
					k -= 1

					break if ( i -= 1 ) == 0
				end
				k *= 0xcc9e2d51
				k = (k << 15) | (k >> 17)
				k *= 0x1b873593
				h ^= k
			end
			h ^= len
			h ^= h >> 16
			h *= 0x85ebca6b
			h ^= h >> 13
			h *= 0xc2b2ae35
			h ^= h >> 16
			@seed = h
		end
	end
end
