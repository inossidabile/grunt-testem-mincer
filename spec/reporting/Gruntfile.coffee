module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-testem'

  # This is used to demonstrate the use of output files in your runner config
  grunt.initConfig
    testem:
      reporting:
        src: [
          'spec/reporting/**/*.*'
        ]
        report_file: 'report.tap'
        options:
          launch_in_dev: ['PhantomJS'],
          launch_in_ci: ['PhantomJS'],
          reporter: "tap"
