require "yaml"

module DncDaemon
  # App configuration.
  class Config
    YAML.mapping(
      incoming: String,
      outgoing: String,
      cam: String
    )

    # Instances a new `Config` from a YAML text file
    def self.load(file : String)
      self.from_yaml(File.read(file))
    end
  end
end
