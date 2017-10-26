require 'exifr/jpeg'

class Photo
  include Mongoid::Document

  attr_accessor :id, :location, :place
  attr_writer :contents

  def self.mongo_client
  	Mongoid::Clients.default
  end

  def initialize(params={})
  	@id = params[:_id].to_s if !params.nil? and !params[:_id].nil?
  	@location =  Point.new(params[:metadata][:location]) if !params.nil? and !params[:metadata].nil?
  	@place = params[:metadata][:place] if !params.nil? and !params[:metadata].nil?
  end

  def place=(pl)
  	if pl.is_a? Place
  		@place = BSON::ObjectId.from_string(pl.id)
  	elsif pl.is_a? String
  		@place = BSON::ObjectId.from_string(pl)
  	else
  		@place = pl
  	end
  end

  def place
  	if !@place.nil?
  		Place.find(@place.to_s)
  	end
  end

  def persisted?
  	!@id.nil?
  end

  def save
  	if persisted?
  		doc = self.class.mongo_client.database.fs.find(_id: BSON::ObjectId.from_string(@id)).first
        doc[:metadata][:location] = @location.to_hash
        doc[:metadata][:place] = @place
        self.class.mongo_client.database.fs.find(_id: BSON::ObjectId.from_string(@id)).update_one(doc)
  	else 
  		if !@contents.nil?
  			gps = EXIFR::JPEG.new(@contents).gps
  			location = Point.new(lng: gps.longitude, lat: gps.latitude)
  			@contents.rewind

  			description = {}
  			description[:metadata] = {
        		location: location.to_hash,
        		place: @place
      		}
  			description[:content_type] = "image/jpeg"

			@location = Point.new(location.to_hash)
  			grid_file = Mongo::Grid::File.new(@contents.read, description)
        	@id = self.class.mongo_client.database.fs.insert_one(grid_file).to_s
        end
    end
  end

  def self.all(offset=0, limit=nil)
  	photos = []
  	coll = Photo.mongo_client.database.fs.find.skip(offset)
  	coll = coll.limit(limit) if !limit.nil?
  	coll.map { |doc| photos << Photo.new(doc) }
  	return photos
  end

  def self.find(id)
  	photo = Photo.mongo_client.database.fs.find(_id: BSON::ObjectId.from_string(id)).first
  	Photo.new(photo) if !photo.nil?
  end

  def contents
  	stored_file = self.class.mongo_client.database.fs.find_one(_id: BSON::ObjectId(@id))
  	if !stored_file.nil?
  		buffer = ""
  		stored_file.chunks.reduce([]) { |x, chunk| buffer << chunk.data.data }
  	end
  	return buffer
  end

  def destroy
  	self.class.mongo_client.database.fs.find(_id: BSON::ObjectId(@id)).delete_one
  end

  def find_nearest_place_id(max)
  	place = Place.near(@location, max).limit(1).projection(_id: 1).first
  	return nil if place.nil?
  	return place[:_id] if !place.nil?
  end

  def self.find_photos_for_place id
  	if id.is_a? String
  		doc = mongo_client.database.fs.find('metadata.place': BSON::ObjectId.from_string(id))
  	else
  		doc = mongo_client.database.fs.find('metadata.place': id)
  	end
  	return doc
  end
end
