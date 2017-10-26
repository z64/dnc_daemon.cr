require "logger"
require "./dnc_daemon/*"

module DncDaemon
  # Load configuration
  CONFIG = Config.load("config.yaml")

  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG
  LOGGER.info "Starting capture.."

  # Scan all directories in parallel
  results = parallel(
    Cache.new(CONFIG.cam),
    Cache.new(CONFIG.incoming),
    Cache.new(CONFIG.outgoing)
  )
  cam_files, incoming_files, outgoing_files = results

  # Display some before-running stats
  LOGGER.info "CAM files: #{cam_files.filenames.size}"
  LOGGER.info "Incoming files: #{incoming_files.filenames.size}"
  LOGGER.info "Outgoing files: #{outgoing_files.filenames.size}"

  # Proc to stip the extension off of the basename of a file
  strip_ext = ->(path : String) do
    basename = File.basename(path)
    dot_index = basename.rindex('.') || (basename.size - 1)
    basename[0, dot_index]
  end

  moved_files = 0

  # Process the cam_files `Cache` against the other two caches, and instance a
  # `Match` that will handle sorting that file into its proper directory.
  cam_files.each do |path|
    filename = strip_ext.call(path)

    files_in = incoming_files.filenames.select do |f|
      without_ext = strip_ext.call(f)
      filename == without_ext
    end

    files_out = outgoing_files.filenames.select do |f|
      without_ext = strip_ext.call(f)
      filename == without_ext
    end

    if files_in.any? || files_out.any?
      match = Match.new(
        File.dirname(path),
        files_in,
        files_out,
      )

      match.move!
      moved_files += (files_in.size + files_out.size)
    end
  end

  LOGGER.info "Relocated #{moved_files} files"
end
