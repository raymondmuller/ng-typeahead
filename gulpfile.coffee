# Utilities
gulp = require("gulp")
streamqueue = require("streamqueue")
gutil = require("gulp-util")
rimraf = require("gulp-rimraf")
concat = require("gulp-concat")
gulpif = require('gulp-if')
rename = require('gulp-rename')

# Pre-Processors
coffee = require("gulp-coffee")
sass = require("gulp-sass")

# Minification
uglify = require("gulp-uglify")
minifyCSS = require("gulp-minify-css")

# Angular Helpers
ngAnnotate = require("gulp-ng-annotate")

# PATH VARIABLES
# =================================================

paths =
  scripts: ["src/scripts/*.{coffee,js}"] # scripts
  styles: "src/styles/*.{scss,sass,css}" # css and scss files
  dist: "dist"

# SCRIPT-RELATED TASKS
# =================================================
# Compile, concatenate, and (optionally) minify scripts

# Gather and compile App Scripts from coffeescript to JS
compileScripts = ->
  coffeestream = coffee({bare:true})
  coffeestream.on('error', gutil.log)
  appscripts = gulp.src(paths.scripts)
    .pipe(gulpif(/[.]coffee$/, coffeestream))
    .pipe(ngAnnotate())

# Concatenate all JS into a single file
# Streamqueue lets us merge these 3 JS sources while maintaining order
concatenateScripts = ->
  streamqueue({objectMode: true},  compileScripts())
    .pipe(concat("*.js"))

concatenateStyles = ->
  streamqueue({objectMode: true}, compileStyles())
    .pipe(concat("ng-typeahead.css"))

# Compile Directive
gulp.task "scripts",   ->
  gulp.start("minified", "normal")
  
gulp.task "normal", ->
  gulp.src(paths.scripts)
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest(paths.dist))

gulp.task "minified", ->
  gulp.src(paths.scripts)
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(uglify())
    .pipe(rename('ng-typeahead.min.js'))
    .pipe(gulp.dest(paths.dist))


# =================================================


# STYLESHEETS
# =================================================
# Compile, concatenate, and (optionally) minify stylesheets
# =================================================
# Gather CSS files and convert scss to css


compileStyles = ->
  gulp.src(paths.styles)
    .pipe(gulpif(/[.]scss|sass$/,
      sass({
        sourcemap: true,
        unixNewlines: true,
        style: 'nested',
        debugInfo: false,
        quiet: false,
        lineNumbers: true
      })
      .on('error', gutil.log)
    ))

# Compile and concatenate css and then write to disk
buildStyles = (buildPath=paths.dist, minify=false) ->
  styles = concatenateStyles()

  if minify
    styles = styles
      .pipe(minifyCSS())

  styles
    .pipe(gulp.dest(paths.dist))

gulp.task "styles", -> buildStyles()


# =================================================

# CLEAN
# =================================================
# Delete contents of the build folder
# =================================================

gulp.task "clean", ->
  return gulp.src(["dist"], {read: false})
    .pipe(rimraf({force: true}))

# =================================================


# WATCH
# =================================================
# Watch for file changes and recompile as needed
# =================================================
gulp.task 'watch', ->
  gulp.watch [paths.scripts, paths.styles]

gulp.task "compile", ["clean"], ->
  gulp.start("scripts", "styles")

gulp.task "default", -> gulp.start("compile")
