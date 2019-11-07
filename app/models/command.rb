class Command
  attr_accessor :message, :name, :cooldown, :count, :userlevel
  def initialize(command)
    @name ||= command["name"]
    @message ||= command["message"]
    @cooldown ||= command["coolDown"]
    @count ||= command["count"]
    @userlevel ||= command["userLevel"]
  end

  def self.collection(commands)
    commands.map { |command| self.new(command) }
  end

  def self.to_csv
    @_attributes ||= ["name","message","cooldown","count","userlevel"]

    CSV.generate(headers: true) do |csv|
      csv << @_attributes

      all.each do |user|
        csv << @_attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def to_hash
    _properties = Hash.new
    self.instance_variables.each {|x| _properties[x[1..-1]] = self.instance_variable_get(x) }
    _properties
  end
end
