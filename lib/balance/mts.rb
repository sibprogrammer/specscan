require 'net/https'

module Balance; end

class Balance::Mts

  def self.get(sim_card)
    http = Net::HTTP.new('ip.sib.mts.ru', '443')
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    resp, data = http.post('/SelfCarePda/Security.mvc/LogOn', "username=#{sim_card.phone}&password=#{sim_card.helper_password}")

    cookie = resp.get_fields('set-cookie').collect{ |cookie| cookie.split(';').first }.join('; ')
    headers = { 'Cookie' => cookie }

    resp, data = http.get('/SelfCarePda/Home.mvc', headers)

    balance = data.match('<strong>(\-?\d+,\d+) .*?</strong>')[1].sub(',', '.').to_f
  end

end
