module.exports = (grunt) ->

  grunt.loadTasks 'tasks'
  grunt.loadNpmTasks 'grunt-release'

  grunt.initConfig
    release:
      options:
        bump: false
        add: false
        commit: false
        push: false

    testem:
      'tricky.basic':
        src: [
          'spec/basic/**/*.*'
        ]
        options:
          parallel: 8
          launch_in_dev: ['PhantomJS'],
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']
      basic:
        src: [
          'spec/basic/**/*.*'
        ]
        options:
          parallel: 8
          launch_in_dev: ['PhantomJS'],
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']
      minced:
        src: [
          'spec/minced/**/*.*',
          '!spec/minced/inclusion.coffee'
        ]
        options:
          parallel: 8
          launch_in_dev: ['PhantomJS'],
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']
      custom:
        assets:
          port: 7358
          setup: (environment, Mincer) ->
            Mincer.CoffeeEngine.configure bare: false
            environment.appendPath 'spec/custom/app'
            environment
        options:
          watch_files: [
            'spec/custom/**/*.*'
          ]
          serve_files: ['core.js', 'hidden.js'].concat(grunt.file.expand 'spec/custom/spec/**/*.*').map (x) ->
              "http://localhost:7358/#{x}"
          parallel: 8
          launch_in_dev: ['PhantomJS'],
          launch_in_ci: ['PhantomJS', 'Chrome', 'Firefox', 'Safari', 'IE7', 'IE8', 'IE9']

  grunt.registerTask 'default', ['testem']