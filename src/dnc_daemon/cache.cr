module DncDaemon
  # A `Cache` represents a list of candidate CAM files to be matched up
  # with master files from the master CAM file directory, to be later sorted
  # in a `Match`.
  class Cache
    # CAM file extension
    CAMFILE = /\.R\d+$/

    # List of matching filenames
    getter filenames = [] of String

    # The path that this `Cache` searched
    getter path : String

    def initialize(@path)
      read
    end

    # Reads the files in `path` into the `filenames` cache, if they
    # match `CAMFILE`.
    def read
      Dir.glob(@path) do |filename|
        @filenames << filename if filename =~ CAMFILE
      end
    end

    # Empties the filename cache
    def clear!
      @filenames = [] of String
    end

    def inspect
      "<Cache @path=#{path} files=#{filenames.size}>"
    end

    delegate each, to: filenames
  end
end
