window.jQuery = $;
window.$ = $;

require('jquery')
require("popper.js")
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require('bootstrap')
require('bootstrap4-tagsinput/tagsinput.js')
require("@fortawesome/fontawesome-free/js/all")
require("@fortawesome/fontawesome-free/css/all")
require("packs/dev")
require("packs/pagy")

require("packs/jstree")

import('stylesheets/application.scss');
import "controllers"
import './pagy.js.erb'

import "chartkick/chart.js"