module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-testem'

  # This is mostly a basic sample of what you can get using grunt-contrib-testem
  grunt.initConfig
    testem:
      basic:
        src: [
          '**/*.*' # load all the files including coffee
        ]
        options:
          # Run 8 browsers at parallel
          parallel: 8
          # Run only Phantom in the dev mode by default
          launch_in_dev: ['PhantomJS'],
          # Run everything you can find in CI mode (FIRE IN A HOLE!)
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']