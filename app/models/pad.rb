class Pad

  attr_accessor :id

  def save
    self.id = store.incr("pads") #increment the pad count
  end

  def add_user(user_id)
    store.sadd "pads:#{id}:users", user_id
  end

  def remove_user(user_id)
    store.srem "pads:#{id}:users", user_id
  end

  def self.count
    store["pads"]  
  end

  def store
    self.class.store
  end

  def self.store
    @@store ||= Redis.new
  end

end
