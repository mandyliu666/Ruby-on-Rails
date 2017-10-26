class Place
  include Mongoid::Document
  include ActiveModel::Model

  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize(params) 
  	@id = params[:_id].to_s
  	@formatted_address = params[:formatted_address]
  	@location = Point.new(params[:geometry][:geolocation])

  	@address_components = []
  	if !params[:address_components].nil?
  		address_components = params[:address_components]
  		address_components.each { |a| @address_components << AddressComponent.new(a) }
  	end
  end

  def persisted?
  	!@id.nil?
  end

  def self.find_by_short_name(s)
  	Place.collection.find("address_components.short_name": s)
  end

  def self.mongo_client
  	Mongoid::Clients.default
  end

  def self.collection
  	self.mongo_client['places']
  end

  def self.load_all(f)
  	h = JSON.parse(f.read)
  	self.collection.insert_many(h)
  end

  def self.to_places(pl)
  	places = []
  	pl.each do |doc|
  		places << Place.new(doc)
  	end
  	return places
  end

  def self.find(id)
  	doc = Place.collection.find(_id: BSON::ObjectId.from_string(id)).first
  	if !doc.nil?
  		Place.new(doc)
  	else
  		nil
  	end
  end

  def self.all(offset=0, limit=nil)
  	coll = Place.collection.find.skip(offset)
  	coll = coll.limit(limit) if !limit.nil?
  	places = []
  	coll.each do |doc|
  		places << Place.new(doc)
  	end
  	return places
  end

  def destroy
  	self.class.collection.find(_id: BSON::ObjectId.from_string(@id)).delete_one
  end

  def self.get_address_components(sort=nil, offset=0, limit=nil)
  	if !sort.nil? and !limit.nil?
  		Place.collection.aggregate([
  			{:$unwind=>'$address_components'},
  			{:$project=>{address_components: 1, formatted_address: 1, geometry: {geolocation: 1}}},
  			{:$sort=>sort},
  			{:$skip=>offset},
  			{:$limit=>limit} ])
  	elsif !sort.nil?
  		Place.collection.aggregate([
  			{:$unwind=>'$address_components'},
  			{:$project=>{address_components: 1, formatted_address: 1, geometry: {geolocation: 1}}},
  			{:$sort=>sort},
  			{:$skip=>offset} ])
  	elsif !limit.nil?
  		Place.collection.aggregate([
  			{:$unwind=>'$address_components'},
  			{:$project=>{address_components: 1, formatted_address: 1, geometry: {geolocation: 1}}},
  			{:$skip=>offset},
  			{:$limit=>limit} ])
  	else
  		Place.collection.aggregate([
  			{:$unwind=>'$address_components'},
  			{:$project=>{address_components: 1, formatted_address: 1, geometry: {geolocation: 1}}},
  			{:$skip=>offset} ])
  	end
  end

  def self.get_country_names
  	Place.collection.aggregate([
  		{:$project=>{_id: 0, address_components: {long_name: 1, types: 1}}},
  		{:$unwind=>'$address_components'},
  		{:$match=>{'address_components.types': "country"}},
  		{:$group=>{_id: '$address_components.long_name', count: {:$sum=>1}}} ]).to_a.map { |h| h[:_id] }
  end

  def self.find_ids_by_country_code(code)
  	Place.collection.aggregate([ 
  		{:$unwind=>'$address_components'},
  		{:$match=>{'address_components.short_name': code}},
  		{:$project=>{_id: 1}} ]).map { |doc| doc[:_id].to_s }
  end

  def self.create_indexes
  	Place.collection.indexes.create_one({'geometry.geolocation': Mongo::Index::GEO2DSPHERE})
  end

  def self.remove_indexes
  	Place.collection.indexes.drop_one('geometry.geolocation_2dsphere')
  end

  def self.near(point, max=nil)
  	if !max.nil?
  		Place.collection.find(
  			{'geometry.geolocation': {'$near': point.to_hash, :$maxDistance=>max}})
  	else
  		Place.collection.find(
  			{'geometry.geolocation': {'$near': point.to_hash}})
  	end
  end

  def near(max=nil)
  	near_points = []
  	if !max.nil?
  		Place.collection.find(
  			{'geometry.geolocation': {'$near': @location.to_hash, :$maxDistance=>max}}).each do |pl|
  			near_points << Place.new(pl)
  		end
  	else
  		Place.collection.find(
  			{'geometry.geolocation': {'$near': @location.to_hash}}).each do |pl|
  			near_points << Place.new(pl)
  		end
  	end
  	return near_points
  end

  def photos(offset=0, limit=nil)
  	photo = Photo.find_photos_for_place(@id).skip(offset)
  	photo = photo.limit(limit) if !limit.nil?
  	if photo.count
  		photo.map { |ph| Photo.new(ph) }
  	else
  		[]
  	end
  end
end
