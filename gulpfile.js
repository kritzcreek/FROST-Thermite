var gulp = require('gulp');
var purescript = require('gulp-purescript');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var autoprefixer = require('gulp-autoprefixer');
var runSequence = require('run-sequence');
var del = require('del');

var paths = {
    'psc': ['src/**/*.purs', 'src/**/*.js'],
    'static': 'assets/**/*',
    'deployFolder': '../FROST-Backend/static/'
};

var sources = [
    'src/**/*.purs',
    'bower_components/purescript-*/src/**/*.purs'
];

var foreigns = [
    'src/**/*.js',
    'bower_components/purescript-*/src/**/*.js'
];

gulp.task('clean', function(){
    return del([
        'dist/'
    ]);
});

gulp.task('copy-index-html', function() {
    return gulp.src('index.html')
        .pipe(gulp.dest('dist/'));
});

gulp.task('copy-css', function(){
    return gulp.src('assets/scss/app.scss')
		.pipe(sass())
		.on('error', function(err) {
			console.log(err.message);
			this.emit('end');
		})
		.pipe(autoprefixer({
			browsers: 'last 2 versions'
		}))
		.pipe(minifyCss())
		.pipe(gulp.dest('dist/css/'));
});

gulp.task('copy', function(cb){
    runSequence('copy-index-html', 'copy-css', cb);
});

gulp.task('make', function () {
    return purescript.psc({ src: sources, ffi: foreigns });
});

gulp.task('bundle', function(){
    return purescript.pscBundle({
      main: "Main",
      module: "Main",
      src: "output/**/*.js",
      output: "dist/js/app.js"
    });
});

gulp.task('watch', function() {
    gulp.watch(paths.psc, function(){
        runSequence('make', 'bundle');
    });
    gulp.watch(paths.static, ['copy', 'bundle']);
});

gulp.task('default', function(cb){
    runSequence('clean', ['copy', 'make'], 'bundle','watch', cb);
});
