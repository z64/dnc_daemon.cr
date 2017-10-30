module DncDaemon
  # A `Match` represents a CAM directory that has been paired with a collection
  # of files from the incoming and outgoing directories that belong in there.
  # It brings these matched files in to newly created folders, so that engineering
  # staff can take care of reviewing the programs before merging them.
  struct Match
    # The master CAM directory
    getter path : String

    # A list of matching files from Incoming
    getter files_in : Array(String)

    # A list of matching files from Outgoing
    getter files_out : Array(String)

    def initialize(@path, @files_in, @files_out)
    end

    # Creates a folder for the moved files of the form `daemon-#{name} #{date}`
    private def mkdir(name : String)
      date = Time.now.to_s("%Y-%m-%d")
      folder = "#{path}/daemon-#{name} #{date}"

      Dir.mkdir_p(folder)
      folder
    end

    # Moves the files from `files_in` and `files_out` into the master directory
    # into daemon folders.
    def move!
      cam_incoming = mkdir("incoming") if files_in.any?
      cam_outgoing = mkdir("outgoing") if files_out.any?

      files_in.each do |file|
        `mv "#{file}" "#{cam_incoming}"` unless ARGV[0]? == "no-move"
        LOGGER.info("Moved #{file} to #{cam_incoming}")
      end

      files_out.each do |file|
        `mv "#{file}" "#{cam_outgoing}"` unless ARGV[0]? == "no-move"
        LOGGER.info("Moved #{file} to #{cam_outgoing}")
      end
    end
  end
end
