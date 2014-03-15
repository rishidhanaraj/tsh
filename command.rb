class Command
  def self.run(from, command)
    if command.start_with?('fb post')
      user = User.get(phone_number: from)
      graph = Koala::Facebook::API.new(user.fb_access_token)
      post = command.gsub(/^fb post /, '')

      graph.put_wall_post(post)
      'Posted successfully.'
    elsif command == 'fb list notifs'
      user = User.get(phone_number: from)
      graph = Koala::Facebook::API.new(user.fb_access_token)
      notifs = graph.get_connections('me', 'notifications')

      notifs.each_with_object([]) do |n, a|
        a << n['title']
      end
    elsif command.start_with?('weather')
      location = command.gsub(/^weather /, '')
      barometer = Barometer.new(location)
      weather = barometer.measure

      "Today, the temperature is #{weather.current.temperature.f}."
    elsif command.start_with?('translate')
      to = command.split[1]
      text = command.gsub(/^translate /, '').gsub(/^#{to} /, '')
      translator = BingTranslator.new(ENV['BING_ID'], ENV['BING_SECRET'])

      translator.translate text, to: to.to_sym
    elsif command.start_with?('calc')
      calculator = Dentaku::Calculator.new
      equation = command.gsub(/^calc /, '')

      calculator.evaluate equation
    elsif command == 'btc update'
      coinbase = Coinbase::Client.new(ENV['CB_ID'], ENV['CB_SECRET'])
      "Bitcoin is #{coinbase.buy_price(1).format} today."
    else
      "Command unrecognized."
    end
  end
end
