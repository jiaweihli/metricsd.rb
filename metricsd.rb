class MetricsD
  attr_reader :host
  attr_reader :port

  # @param [String] host
  # @param [Integer] port
  def initialize(host = '127.0.0.1', port = 8125)
    @host = host
    @port = port
    socket = UDPSocket.new
    socket.connect(@host, @port)

    @socket = socket
  end

  # @param [String] name
  # @param [Integer] delta
  # @param [Numeric] sample_rate
  def counter(name, delta, sample_rate = nil)
    message(:counter, name, delta, sample_rate)
  end

  # @param [String] name
  # @param [Integer] value
  # @return [String]
  def gauge(name, value)
    message(:gauge, name, value)
  end

  # @param [String] name
  # @param [Integer] value
  # @return [String]
  def histogram(name, value)
    message(:histogram, name, value)
  end

  # @param [String] name
  # @return [String]
  def meter(name)
    message(:meter, name)
  end

  # @param [Symbol] type
  # @return [String]
  def message(type, name, value = nil, meta_value = nil)
    type_short_name = {
      :counter => 'c',
      :gauge => 'g',
      :histogram => 'h',
      :meter => 'm'
    }[type]

    "#{name}#{%Q!:#{value}|#{type_short_name}! if value.present?}#{%Q!|@#{meta_value}! if meta_value.present?}"
  end

  # ### Usage
  #
  #     publish {[
  #       histogram('random.histogram.name', 10),
  #       meter('random.meter.name')
  #     ]}
  #
  # @return [Integer]
  def publish(&block)
    payload = self.instance_eval(&block)

    if payload.is_a?(Array)
      payload = payload.join("\n")
    end

    @socket.send(payload, 0)
  end
end
