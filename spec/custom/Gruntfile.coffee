module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-testem'

  # In this sample we utilize Mincer to support custom building for the application part
  grunt.initConfig
    testem:
      custom:
        # We don't provide `src` option. Instead we will
        # manually set `watch_files` and `serve_files` for Testem

        assets:
          # Ensure we are running on 7358 even if default changes in future
          port: 7358
          # Setup Mincer to suit our needs
          setup: (environment, Mincer) ->
            Mincer.CoffeeEngine.configure bare: false      # Bare should be false
            environment.appendPath 'app'                   # Appliation should be built from this path
            environment
        options:
          watch_files: [
            '**/*.*'                                       # Rerun tests when ANYTHING changes
                                                           # Mincer handles caching so why not?
          ]
          # Manually map required paths to URL and pass to Testem
          serve_files: ['core.js', 'hidden.js'].concat(grunt.file.expand 'spec/custom/spec/**/*.*').map (x) ->
              "http://localhost:7358/#{x}"

          # Run 8 browsers at parallel
          parallel: 8
          # Run only Phantom in the dev mode by default
          launch_in_dev: ['PhantomJS'],
          # Run everything you can find in CI mode (FIRE IN A HOLE!)
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']