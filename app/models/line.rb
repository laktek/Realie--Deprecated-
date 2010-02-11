require 'digest/sha1'

class Line 

  attr_accessor :id, :pad, :user, :content, :position

  def save
    self.id = store.incr("lines") #increment the line count
    store_line
    add_line_to_pad
  end

  def store_line
    store[line_sha_value] = serialized_line_content
  end 

  def add_line_to_pad
    increment_pad_line_count
    add_line_to_pad_timeline
    add_line_to_pad_snapshot
  end

  def self.count
    store["lines"]  
  end

  def store
    self.class.store
  end

  def self.store
    @@store ||= Redis.new
  end

  def line_sha_value
    @line_sha_value ||= "line:#{digest_for_line_content}"
  end

  def serialized_line_content
    { :content => @content, :position => @position, :user => @user }.to_json #encode to JSON
  end

  def digest_for_line_content
    Digest::SHA1.hexdigest(serialized_line_content)
  end

  private
  def increment_pad_line_count
    store.incr("pad:#{@pad}:lines")
  end

  def add_line_to_pad_timeline
    store.rpush("pad:#{@pad}:timeline", digest_for_line_content)
  end

  def add_line_to_pad_snapshot
    store.sadd("pad:#{@pad}:snapshot_lines", @position)
    store["pad:#{@pad}:snapshot:#{@position}"] = digest_for_line_content
  end

end
