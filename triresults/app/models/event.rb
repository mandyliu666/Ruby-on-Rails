class Event
  include Mongoid::Document
  field :o, as: :order, type: Integer
  field :n, as: :name, type: String
  field :d, as: :distance, type: Float
  field :u, as: :units, type: String
  embedded_in :parent, polymorphic: true, touch: true
  validates_presence_of :order
  validates_presence_of :name

  def meters
  	return nil if self.d.nil?
  	if self.u == "meters"
  		return self.d
  	elsif self.u == "miles"
  		return self.d * 1609.344
  	elsif self.u == "kilometers"
  		return self.d * 1000
  	elsif self.u == "yards"
  		return self.d * 0.9144
  	end
  end

  def miles
  	return nil if self.d.nil?
  	if self.u == "miles"
  		return self.d
  	elsif self.u == "meters"
  		return self.d * 0.000621371
  	elsif self.u == "kilometers"
  		return self.d * 0.621371
  	elsif self.u == "yards"
  		return self.d * 0.000568182
  	end
  end
end
