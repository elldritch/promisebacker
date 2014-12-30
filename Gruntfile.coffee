module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        src: 'src/**/*.coffee',
        dest: '.grunt/',
        ext: '.js'
        expand: true,
        flatten: true

    uglify:
      dist:
        src: ['.grunt/**/*.js']
        dest: 'dist/promisebacker.min.js'

    clean:
      compile: ['.grunt', 'dist']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', ['deploy']
  grunt.registerTask 'deploy', ['coffee:compile', 'uglify']
