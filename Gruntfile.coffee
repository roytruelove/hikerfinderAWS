module.exports = (grunt)->

	###############################################################
	# Constants
	###############################################################

	PROFILE = grunt.option('profile') || 'dev'

	#### Client (eg AngularJS) directories

	SRC_DIR =                    'src/client'
	SRC_TEST_DIR =               "#{SRC_DIR}/test"
	SRC_PROFILES_DIR =           "#{SRC_DIR}/profiles"
	CURRENT_PROFILE_DIR =        "#{SRC_PROFILES_DIR}/#{PROFILE}"

	TARGET_DIR =                 'target'
	BUILD_DIR =                  "#{TARGET_DIR}/build"
	BUILD_MAIN_DIR =             "#{BUILD_DIR}/public"

	STAGE_DIR =                  "#{TARGET_DIR}/clientStage"
	STAGE_APP_DIR =              "#{STAGE_DIR}/app"
	STAGE_TEST_DIR =             "#{STAGE_DIR}/test"

	BUILD_TEST_DIR =             "#{BUILD_DIR}/test/client" 

	# index.html is special, since it should be moved out of the index view and into the root
	SRC_INDEX_HTML =             "#{STAGE_APP_DIR}/index/index.html"
	DEST_INDEX_HTML =            "#{BUILD_MAIN_DIR}/index.html"

	#### Server directories

	SVR_SRC_DIR =                'src/server'
	SVR_TARGET_DIR =             BUILD_DIR

	###############################################################
	# Config
	###############################################################

	grunt.initConfig

		clean:
			main:
				src: TARGET_DIR 

		copy:
			stage:
				files: [
					# Copy all non-profile to the stage dir.  Stage dir allows us to override
					# non-profile-specific code w/ the profile defined on the cmd line (or 'dev' by default)
					{
						expand:        true
						cwd:           "#{SRC_DIR}/main"
						src:           '**'
						dest:          STAGE_DIR
					}
				]
			profiles:
				files: [
					# override staging dir w/ profile-specific files
					{
						expand:        true
						cwd:           CURRENT_PROFILE_DIR  
						src:           '**'
						dest:          STAGE_DIR
					}
				]
			# copies all files from staging to the build dir that do not need any further processing
			index:
				files: [
					{
						src:           SRC_INDEX_HTML
						dest:          DEST_INDEX_HTML
					}
				]
			static:
				files: [
					{
						expand:        true
						cwd:           STAGE_APP_DIR
						src:           ['**/*.{html,jpg,png,gif}', "!{SRC_INDEX_HTML}"]
						dest:          BUILD_MAIN_DIR
					}
				]
			# Facebook apps need this channel file in the root
			fbChannel:
				files: [
					{
						src:           "#{STAGE_APP_DIR}/index/channel.html"
						dest:          "#{BUILD_MAIN_DIR}/channel.html"
					}
				]
			# Test files
			test:
				files: [
					{
						expand:        true
						cwd:           SRC_TEST_DIR
						src:           ['{lib,config}/**']
						dest:          BUILD_TEST_DIR
					}
				]
			server:
				# copy everything except coffeescript to the server dir
				files: [
					{
						expand:        true
						cwd:           SVR_SRC_DIR
						src:           ['!**/*.coffeee']
						dest:          SVR_TARGET_DIR
					}
				]

		concat:
			app_css:
				src: "#{STAGE_APP_DIR}/**/*.css"
				dest: "#{BUILD_MAIN_DIR}/style/app.css"
			lib_css: 
				src: "#{STAGE_DIR}/lib/**/*.css"
				dest: "#{BUILD_MAIN_DIR}/style/lib.css"
			lib_js: 
				src: "#{STAGE_DIR}/lib/**/*.js"
				dest: "#{BUILD_MAIN_DIR}/js/lib.js"

		coffee:
			client:
				files: [
					{
						src: "#{STAGE_APP_DIR}/**/*.coffee"
						dest: "#{BUILD_MAIN_DIR}/js/app.js"
					}
					{
						src: "#{SRC_TEST_DIR}/**/*.coffee"
						dest: "#{BUILD_TEST_DIR}/js/lib.js"
					}
				]

			server:
				expand: true
				cwd: SVR_SRC_DIR
				src: "**/*.coffee"
				dest: "#{SVR_TARGET_DIR}/"
				ext: '.js'

		uglify:
			lib_js:
				src: "#{BUILD_MAIN_DIR}/js/lib.js"
				dest: "#{BUILD_MAIN_DIR}/js/lib.js"
			app_js:
				src: "#{BUILD_MAIN_DIR}/js/app.js"
				dest: "#{BUILD_MAIN_DIR}/js/app.js"

		cssmin:
			lib_css:
				src: "#{BUILD_MAIN_DIR}/style/lib.css"
				dest: "#{BUILD_MAIN_DIR}/style/lib.css"
			app_css:
				src: "#{BUILD_MAIN_DIR}/style/app.css"
				dest: "#{BUILD_MAIN_DIR}/style/app.css"

		bgShell:
			startServer:
				cmd: "node #{SVR_TARGET_DIR}/server.js"
				bg: true
				stdout: true

			stopServer:
				cmd: "wget --tries=1 http://localhost:8111"
				bg: false
				stdout: true

		regarde:
			client:
				options:
					base: BUILD_MAIN_DIR
				files: [
					"#{SRC_DIR}/**/*.{css,coffee,js,html}"
				]
				tasks: ['clientRefresh'] 
			server:
				options:
					base: BUILD_MAIN_DIR
				files: [
					"#{SVR_SRC_DIR}/**/*.coffee"
				]
				tasks: ['serverRefresh'] 


	##############################################################
	# Dependencies
	###############################################################
	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-contrib-copy')
	grunt.loadNpmTasks('grunt-contrib-clean')
	grunt.loadNpmTasks('grunt-contrib-concat')
	grunt.loadNpmTasks('grunt-contrib-uglify')
	grunt.loadNpmTasks('grunt-contrib-cssmin')
	grunt.loadNpmTasks('grunt-contrib-connect')
	grunt.loadNpmTasks('grunt-contrib-livereload')
	grunt.loadNpmTasks('grunt-regarde')
	grunt.loadNpmTasks('grunt-bg-shell')

	###############################################################
	# Alias tasks
	###############################################################

	grunt.registerTask('copyBuild', [
		'copy:stage'
		'copy:profiles'
		'copy:index'
		'copy:static'
		'copy:fbChannel'
		'copy:test'
		'copy:server'
	])

	grunt.registerTask('build', ['copyBuild','concat','coffee'])
	grunt.registerTask('dist', ['build','uglify','cssmin'])

	grunt.registerTask('serverRefresh', ['bgShell:stopServer', 'build', 'bgShell:startServer'])
	grunt.registerTask('clientRefresh', ['build'])

	grunt.registerTask('deploy', ['dist', 'copy:deploy'])

	grunt.registerTask('default', ['clean','serverRefresh', 'regarde'])