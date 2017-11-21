class Address
  include Mongoid::Document
  field :city, type: String
  field :state, type: String
  field :location, type: Point

  attr_accessor :city, :state, :location

  def initialize city=nil, state=nil, location=nil
  	@city = city
  	@state = state
  	if location.nil?
  		@location = Point.new(0, 0)
  	else
  		@location = Point.new(location[:coordinates][0], location[:coordinates][1])
  	end
  end

  def mongoize
  	{ city: @city, state: @state, 
  		loc: {
  			type: 'Point',
  			coordinates: [@location.longitude, @location.latitude]
  		}
  	}
  end

  def self.mongoize object
  	case object
  	when nil then nil
  	when Hash then Address.new(object[:city], object[:state], object[:loc]).mongoize
  	when Address then object.mongoize
  	end
  end

  def self.demongoize object
  	case object
  	when nil then object
  	when Hash then Address.new(object[:city], object[:state], object[:loc])
  	when Address then object
  	end
  end

  def self.evolve object
  	case object
  	when nil then nil
  	when Hash then Address.new(object[:city], object[:state], object[:loc]).mongoize
  	when Address then object.mongoize
  	end
  end
end
