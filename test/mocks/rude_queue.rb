class RudeQueue
  @@store = Hash.new(){ |hash, key| hash[key]=[] }
  def self.get(queue_name)
    @@store[queue_name.to_s].shift
  end
  def self.set(queue_name, value)
    @@store[queue_name.to_s] << value
  end
end