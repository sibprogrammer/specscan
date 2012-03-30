require 'ostruct'

config_defaults = {
  'maps' => {
    'yandex' => {
      'api_key' => '',
      'api_key_dev' => '',
      'url' => '',
    },
  },
  'host' => {
    'development' => '',
  },
  'support' => {
    'email' => 'support@example.com',
    'phone' => '',
  },
}

def hashes2ostruct(object)
  return case object
  when Hash
    object = object.clone
    object.each do |key, value|
      object[key] = hashes2ostruct(value)
    end
    OpenStruct.new(object)
  when Array
    object = object.clone
    object.map! { |i| hashes2ostruct(i) }
  else
    object
  end
end

config_file_name = "#{Rails.root}/config/config.yml"
config = File.exist?(config_file_name) ? (YAML.load_file(config_file_name) || {}) : {}
AppConfig = hashes2ostruct(config_defaults.deep_merge(config))