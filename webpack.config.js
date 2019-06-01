const path = require('path')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const webpack = require('webpack')

module.exports = {
  entry: './src/main.js',

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            plugins: ['transform-object-rest-spread'],
            presets: [
              ['env', { "targets": { "browsers": [">0.25%", "not ie 11", "not op_mini all"] } }]
            ]
          }
        }
      },
      { test: /\.css$/, use: ['style-loader', 'css-loader'] },
      { test: /\.vue$/, loader: 'vue-loader' },
    ],
  },

  optimization: {
    minimize: true
  },

  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, 'dist'),
  },

  plugins: [
    new VueLoaderPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('production')
      }
    }),
  ],

  resolve: {
    extensions: ['.webpack.js', '.web.js', '.js'],
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
}
