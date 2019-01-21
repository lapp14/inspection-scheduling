var gulp = require('gulp'),
connect = require('gulp-connect');

gulp.task('connectDev', function () {
connect.server({
  name: 'Dev App',
  root: 'src',
  port: 8000,
  livereload: true
});
});

gulp.task('connectDist', function () {
connect.server({
  name: 'Dist App',
  root: 'dist',
  port: 8001,
  livereload: true
});
});

gulp.task('html', function () {
gulp.src('./src/*.html')
  .pipe(gulp.dest('./app'))
  .pipe(connect.reload());
});