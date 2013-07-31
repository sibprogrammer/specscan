class ActionLog

  include MongoMapper::Document

  key :date
  key :actor
  key :event_type
  key :params

  def self.log(user, event_type, params = {})
    login = user.is_a?(String) ? user : user.login
    self.create(:date => DateTime.now.to_i, :actor => login, :event_type => event_type.to_s, :params => params)
  end

end
