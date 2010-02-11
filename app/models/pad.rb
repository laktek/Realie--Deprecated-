class Pad

  attr_accessor :id

  def save
    self.id = store.incr("pads") #increment the pad count
    self
  end

  def add_user(user_id)
    store.sadd "pads:#{id}:users", user_id
  end

  def remove_user(user_id)
    store.srem "pads:#{id}:users", user_id
  end

  def snapshot
    store.sort("pad:#{id}:snapshot_lines", :get => "pad:#{id}:snapshot:*").map {|l| store["line:#{l}"] }
  end

  def timeline
    store.lrange("pad:#{id}:timeline", 0, -1).map {|l| store["line:#{l}"] }
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
