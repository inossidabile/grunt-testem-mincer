module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-testem'

  # Here we deal with slightly automated Mincer-based build
  grunt.initConfig
    testem:
      minced:
        src: [
          '**/*.*',                            # Include all the files basically...
          '!spec/minced/inclusion.coffee'      # Except this one cause it is already included from `spec.coffee`
        ]
        options:
          # Run 8 browsers at parallel
          parallel: 8
          # Run only Phantom in the dev mode by default
          launch_in_dev: ['PhantomJS'],
          # Run everything you can find in CI mode (FIRE IN A HOLE!)
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']