const { environment } = require('@rails/webpacker')
const vue_bootstrap_config = require('./vue_bootstrap')
environment.config.merge(vue_bootstrap_config)

const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
module.exports = environment
