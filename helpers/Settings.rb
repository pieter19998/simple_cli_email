require "yaml"

class Settings

  def set_settings(host, port, ssl, username, password)
    File.write("config", [host, port, ssl, username, password].to_yaml)
  end

  def get_settings
    host, port, ssl, username, password = YAML.load_file("config")
    settings = {:host => host, :port => port.to_i, :ssl => ssl, :username => username, :password => password}
  end
end