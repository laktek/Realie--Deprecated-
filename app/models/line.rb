require 'digest/sha1'

class Line 

  attr_accessor :id, :pad, :user, :content, :position

  def save
    self.id = store.incr("lines") #increment the line count
    store_line
  end

  def store_line
    store[line_sha_value] = "{content: hello, position: 2}" #encode to JSON
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

  private
  def line_sha_value
    "line:line_sha"
  end

end
