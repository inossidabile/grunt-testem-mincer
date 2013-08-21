Sugar   = require 'sugar'
Testem  = require 'testem'
Mincer  = require 'mincer'
connect = require 'connect'

#
# Runs local server with mincer on the given port
#
# @param [Integer] port              Port to listen
# @param [Function] setup            Configurator to customize Mincer behavior
#
serveAssets = (port, warmup, setup) ->
  environment = new Mincer.Environment
  environment = setup(environment, Mincer) if setup?
  environment.appendPath process.cwd()
  mincer = new Mincer.Server(environment)

  Mincer.logger.use console

  # Warmup before we actually run stuff in browsers
  # to keep parallel loading settled
  warmup.each (path) ->
    try
      environment.findAsset path
    catch error

  server = connect()
  server.use '/', (req, res) ->
    try
      asset = environment.findAsset req.url.substring(1)

      unless asset
        res.end "console.error('Not found: #{req.url}')"
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
  @target = @args[0]

  # No target? Ppppfff.....
  return false unless @target

  done = @async()

  # We have target!
  grunt.config.requires "testem.#{@target}"
  @config = (path) => grunt.config("testem.#{@target}.#{path}")

  # General settings
  assets_port  = @config("assets.port") || 7358
  assets_setup = @config("assets.setup")
  files        = grunt.file.expand(@config("src") || [])
  options      = @config("options") || {}

  # Options defaults
  options['launch_in_ci']  = [grunt.option('launch')] if grunt.option('launch')
  options['launch_in_edv'] = [grunt.option('launch')] if grunt.option('launch')
  options['reporter']    ||= grunt.option('reporter')
  options['watch_files'] ||= files
  options['serve_files'] ||= files.map (p) -> "http://localhost:#{assets_port}/#{p}"

  # Run and setup testem and assets servers
  testem = new Testem
  assets = serveAssets assets_port, files, assets_setup

  testem[mode] options, (code) ->
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
    grunt.util.spawn {cmd: "node_modules/.bin/testem", args: ['launchers'], opts: {stdio: [0,1,2]}}, done

  grunt.registerTask 'testem:ci', 'Run some environments in CI mode', ->
    grunt.option('reporter', 'dot') unless grunt.option('reporter')

    unless task.call @, grunt, 'startCI'
      Object.each grunt.config.get('testem'), (key, value) ->
        grunt.task.run "testem:ci:#{key}"

  grunt.registerTask 'testem:run', 'Run one environment in dev mode', ->
    unless task.call @, grunt, 'startDev'
      grunt.fatal "Cannot run development testem without particular target"