require 'balance/mts'
require 'openssl'
require 'base64'

class SimCard < ActiveRecord::Base

  validates :phone, :uniqueness => true, :presence => true

  attr_accessible :phone, :helper_password, :mobile_operator_id, :description, :vehicle_id

  belongs_to :mobile_operator
  belongs_to :vehicle

  def update_balance
    begin
      self.balance = Balance::Mts.get(self) if 'mts' == mobile_operator.code
    rescue
      return false
    end

    save
  end

  def balance_check_support?
    %w{ mts }.include?(mobile_operator.code)
  end

  def helper_password=(password)
    write_attribute(:helper_password, password.blank? ? '' : encrypt(password))
  end

  def helper_password
    password = read_attribute(:helper_password)
    password.blank? ? '' : decrypt(password)
  end

  private

    def encrypt(string)
      cipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
      cipher.encrypt
      cipher.padding = 1
      cipher.key = Base64.decode64(AppConfig.encryption.key)
      iv = OpenSSL::Random.random_bytes(cipher.iv_len)
      cipher.iv = iv

      encrypted_string = cipher.update(string)
      encrypted_string << cipher.final
      result = Base64.encode64(iv).rstrip + '$' + Base64.encode64(encrypted_string).rstrip
    end

    def decrypt(string)
      iv, encrypted_string = string.split('$')
      decipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
      decipher.decrypt
      decipher.key = Base64.decode64(AppConfig.encryption.key)
      decipher.iv = Base64.decode64(iv)

      string = decipher.update(Base64.decode64(encrypted_string))
      string << decipher.final
    end

end
