# TODO: Write documentation for `Murmur`
module Murmur
	VERSION = "0.1.0"

	struct Hasher
		@seed : UInt32
		def initialize( @seed : UInt32 )
		end

		def result()
			@seed
		end

		def nil()
			return self
		end
		def bool( v : Bool )
			compute( 1_u8 )
			compute( v )
			return self
		end
		def int( i )
			compute( 2_u8 )
			compute(i)
			return self
		end
		def float( f )
			compute( 3_u8 )
			compute( f )
			return self
		end
		def char( c )
			compute( 4_u8 )
			compute( c )
			return self
		end
		def enum( e )
			compute( 5_u8 )
			compute( e.value )
			return self
		end
		def symbol( s )
			compute( 6_u8 )
			compute( s.to_i )
			return self
		end
		def reference( r )
			compute( 7_u8 )
			compute( r.object_id)
			return self
		end
		def string( s )
			compute( 8_u8 )
			compute( s.to_slice ) 
			return self
		end
		def class( c )
			compute( 9_u8 )
			compute( c.crystal_type_id )
			return self
		end
		def bytes( b : Bytes )
			compute( 10_u8 )
			compute( b )
			return self
		end

		private def compute( v )
			return compute( pointerof(v).unsafe_as(Pointer(UInt8)), sizeof(typeof(v)) )
		end
		private def compute( slice : Slice(_) )
			return compute( slice.to_unsafe().unsafe_as(Pointer(UInt8)), slice.size * sizeof(typeof(slice[0])) )
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
