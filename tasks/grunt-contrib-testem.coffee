Testem  = require 'testem'
Mincer  = require 'mincer'
connect = require 'connect'
Path    = require 'path'

buildEnvironment = (setup) ->
  environment = new Mincer.Environment
  environment = setup(environment, Mincer) if setup?
  environment.appendPath process.cwd()

  Mincer.logger.use console

  environment

#
# Runs local server with mincer on the given port
#
# @param [Integer] port              Port to listen
# @param [Function] setup            Configurator to customize Mincer behavior
#
serveAssets = (port, warmup, environment) ->
  mincer = new Mincer.Server

  # Warmup before we actually run stuff in browsers
  # to keep parallel loading settled
  warmup.forEach (path) ->
    try
      environment.findAsset path
    catch error

  server = connect()
  server.use '/', (req, res) ->
    try
      url   = unescape req.url
      asset = environment.findAsset url.substring(1)

      unless asset
        res.end "console.error('Not found: #{url}')"
      else
        res.setHeader 'Content-Type', asset.contentType
        res.end asset.buffer
    catch error
      res.end "console.error(#{JSON.stringify error.message})"

  instance = server.listen port

  instance.addListener 'connection', (stream) ->
    stream.setTimeout 500

  instance

#
# Output stream wrapper to pipe the output of Testem into a reporting output file
#    * Overrides the function process.stdout.write
#
# @param [String] reportFile     File path for the output reporting file
# 
# @return [Function] Returns a function to call that reinstates the process.stdout.write
#
wrapOutputStreamForReporting = (reportFile) ->
  fs = require('fs')
  original_std_out_write = process.stdout.write

  #Truncate the file if exists
  fs.writeFileSync reportFile, "", { flags: "w", encoding: "utf-8" }

  process.stdout.write = (chunk, encoding, callback) ->
    #Write to both the stout and report file
    fs.appendFileSync reportFile, chunk, { flags: "w", encoding: "utf-8" }
    original_std_out_write.call process.stdout, chunk, encoding, callback

  ()->
    process.stdout.write = original_std_out_write

#
# To make magic work we are doing the following:
#
#   * Start connect() on localhost:<port> serving Mincer (with project basedir as load path)
#   * Expand given globs and map them to http://localhost:<port>/<path>
#   * Run Testem making him serve URIs and watch expanded paths
#
# Ta-Dam!
#
# @param [Grunt] grunt               Instance of Grunt
# @param [String] mode               Method of Testem to run (startCI or startDev)
#
# @note  This task is designed to run for a single config target and returns false if no
#        particular target given (so you can iterate through all of them or raise an error)
#
task = (grunt, mode) ->
  grunt.config.requires 'testem'
  @target = @args[0]?.replace '.', '\\.'

  # No target? Ppppfff.....
  return false unless @target

  done = @async()

  # We have target!
  grunt.config.requires "testem.#{@target}"
  @config = (path) => grunt.config("testem.#{@target}.#{path}")

  # General settings
  assets_port = @config("assets.port") || 7358
  files       = {}
  options     = @config("options") || {}
  environment = buildEnvironment @config("assets.setup")
  report_file = @config("report_file")

  # We don't need to seek for files if they won't be used anyway
  if !options['watch_files'] || !['serve_files']

    # Traverse every Mincer path saving priority and emulating paths exclusions
    if environment.paths.length > 1
      src = @config("src") || []
      src = [src] unless Array.isArray src

      src.forEach (mask) =>
        environment.paths.forEach (path) =>
          if mask[0] != '!'
            grunt.file.expand({cwd: path}, mask).forEach (match) ->
              files[match] ||= Path.join(path, match)
          else
            grunt.file.expand({cwd: path}, mask.substring(1)).forEach (match) ->
              delete files[match]
    else
      cwd = environment.paths[0]
      grunt.file.expand({cwd: cwd}, @config("src") || []).forEach (match) ->
        files[match] = Path.join(cwd, match)

  # Options defaults
  options['launch_in_ci']  = [grunt.option('launch')] if grunt.option('launch')
  options['launch_in_dev'] = [grunt.option('launch')] if grunt.option('launch')
  options['reporter']    ||= grunt.option('reporter')
  options['watch_files'] ||= Object.keys(files).map (p) -> files[p]
  options['serve_files'] ||= Object.keys(files).map (p) -> "http://localhost:#{assets_port}/#{p}"

  grunt.log.debug "Serving #{options['serve_files'].length} files..."
  grunt.log.debug "Watching #{options['watch_files'].length} files..."

  # Run and setup testem and assets servers
  testem = new Testem
  assets = serveAssets assets_port, Object.keys(files), environment

  #Wrap the output stream if the a report file is configured
  reporterCallback = wrapOutputStreamForReporting report_file if report_file

  testem[mode] options, (code) ->
    if grunt.option('debug')
      grunt.log.debug "Assets are on http://localhost:#{assets_port}/ – press ctr+c to finalize session"
      grunt.log.debug " - #{file}" for file in options['serve_files']
      grunt.log.debug ""
      grunt.log.debug "The following files are watched:"
      grunt.log.debug " - #{file}" for file in options['watch_files']
    else
      #Reinstate the output stream
      reporterCallback() if report_file

      # When testem is down – shutdown assets server,
      # free the port and finish the task
      assets.close ->
        done(!code? || code == 0)

  true

#
# Actual tasks
#
module.exports = (grunt) ->

  grunt.registerTask 'testem', 'Run all environments in CI mode', ->
    grunt.task.run 'testem:ci'

  grunt.registerTask 'testem:launchers', 'List available launchers', ->
    done = @async()

    testemPath = __dirname + "/../node_modules/.bin/testem"
    grunt.util.spawn {cmd: testemPath, args: ['launchers'], opts: {stdio: [0,1,2]}}, done

  grunt.registerTask 'testem:ci', 'Run some environments in CI mode', ->
    grunt.option('reporter', 'dot') unless grunt.option('reporter')

    unless task.call @, grunt, 'startCI'
      for key, value of grunt.config.get('testem')
        do (key, value) ->
          grunt.task.run "testem:ci:#{key}"

  grunt.registerTask 'testem:run', 'Run one environment in dev mode', ->
    unless task.call @, grunt, 'startDev'
      grunt.fatal "Cannot run development testem without particular target"
