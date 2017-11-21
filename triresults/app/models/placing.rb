class Placing
  include Mongoid::Document
  field :name, type: String
  field :place, type: Integer

  attr_accessor :name, :place

  def initialize nname, place
  	@name = nname
  	@place = place
  end

  def mongoize
  	{ name: @name, place: @place }
  end

  def self.mongoize object
  	case object
  	when nil then nil 
  	when Hash then Placing.new(object[:name], object[:place]).mongoize
  	when Placing then object.mongoize
  	end
  end

  def self.demongoize object
  	case object
  	when nil then nil
  	when Hash then Placing.new(object[:name], object[:place])
  	when Placing then object
  	end
  end

  def self.evolve object
  	case object
  	when nil then nil
  	when Placing then object.mongoize
  	else object
  	end
  end
end
