MongoMapper.connection = Mongo::Connection.new(AppConfig.mongo.host, AppConfig.mongo.port)
MongoMapper.database = AppConfig.mongo.db_name

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect if forked
   end
end
