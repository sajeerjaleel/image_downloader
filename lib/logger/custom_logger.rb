require 'logger'

class CustomLogger

  attr_reader :stdout_logger, :file_logger

  def initialize(file_path)
    @stdout_logger = Logger.new(STDOUT)
    @file_logger = Logger.new(file_path, 'daily')
  end

  [:debug, :info, :warn, :error, :fatal, :unknown].each do |method_name|
    define_method(method_name) do |*args|
      stdout_logger.send(method_name, *args)
      file_logger.send(method_name, *args)
    end
  end
end
