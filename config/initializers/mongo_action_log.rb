ActionLog.database.create_collection(ActionLog.collection_name, :capped => true, :size => 2000, :max => 1000)
