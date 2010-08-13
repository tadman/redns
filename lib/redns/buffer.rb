class ReDNS::Buffer < String
  # == Constants ============================================================

  # == Properties ===========================================================
  
  alias_method :total_length, :length
  alias_method :total_size, :size

  attr_reader :offset
  attr_reader :size
  alias_method :length, :size

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
  
  # Create a buffer with arbitrary String contents. The offset parameter
  # indicates where to start reading, which defaults to character 0 at the
  # start of the string. The size parameter is used to limit how much of
  # the content is used

  def initialize(contents = nil, offset = nil, size = nil)
    if (contents.respond_to?(:serialize))
      super('')
      
      @offset = 0
      @size = total_length
      
      contents.serialize(self)
    else
      super(contents || '')

      @offset = offset ? offset.to_i : 0
      @size = size ? size.to_i : nil
    end
    
    advance(0)
  end
  
  def unpack(format)
    return [ ] if (@size <= 0)
    
    raise ReDNS::Exception::BufferUnderrun if (@offset > total_length)

    data = to_s.unpack(format)
    advance(data.pack(format).length)
    data
  end
  
  def pack(contents, format)
    append(contents.pack(format))
  end
  
  def read(chars = 1)
    raise ReDNS::Exception::BufferUnderrun if (@offset + chars > total_length)

    result = to_str[@offset, chars]
    advance(chars)
    result
  end
  
  def write(contents, length = nil)
    insertion = length ? contents[0, length] : contents
    
    self[@offset, 0] = insertion

    advance(insertion.length)
  end

  def append(contents, length = nil)
    insertion = length ? contents[0, length] : contents
    
    self << insertion
    
    @size += insertion.length
    
    self
  end
  
  def advance(chars = 1)
    if (chars < 0)
      rewind(-chars)
    else
      @offset += chars

      if (@offset > total_length)
        @offset = total_length
      end

      max_length = (total_length - @offset)

      if (!@size or @size > max_length)
        @size = max_length
      end
    end
    
    @size ||= total_length - @offset
    
    self
  end

  def rewind(chars = nil)
    if (chars)
      if (chars < 0)
        advance(-chars)
      else
        @offset -= chars
        @size += chars
      
        if (@offset < 0)
          @size += @offset
          @offset = 0
        end
      end
    else
      @size += @offset
      @offset = 0
    end
    
    self
  end
  
  def restore_state
    offset = @offset
    size = @size
    yield(self) if (block_given?)
    @offset = offset
    @size = size
  end
  
  def to_s
    to_str[@offset, @size]
  end
  
  def inspect
    "\#<#{self.class} #{to_s.inspect}>"
  end
end