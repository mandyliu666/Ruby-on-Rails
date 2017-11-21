class Point
  include Mongoid::Document

  attr_accessor :longitude, :latitude

  def initialize lng, lat
  	@longitude = lng
  	@latitude = lat
  end

  def mongoize
  	{ type: 'Point', coordinates: [@longitude, @latitude] }
  end

  def self.mongoize object
  	case object
  	when Point then object.mongoize
  	when Hash then 
  		if object[:type]
  			Point.new(object[:coordinates][0], object[:coordinates][1]).mongoize
  		else
  			Point.new(object[:lng], object[:lat]).mongoize
  		end
  	else object
  	end
  end

  def self.demongoize object
  	case object
  	when nil then nil
  	when Hash then Point.new(object[:coordinates][0], object[:coordinates][1])
  	else object
  	end
  end

  def self.evolve object
  	case object
  	when Point then object.mongoize
  	else object
  	end
  end

end
