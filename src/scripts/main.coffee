require
  paths:
    'bootstrap-slider'  : 'libs/bootstrap-slider'
    'underscore'        : 'libs/underscore'
    'jquery'            : 'libs/jquery'
    'd3'                : 'libs/d3.v3'
    'twitter-bootstrap' : 'libs/bootstrap'
    'angular-resource'  : 'libs/angular-resource'
    'angular'           : 'libs/angular'
  shim:
    'angular-resource'                   : deps: ['angular']
    'twitter-bootstrap'                  : deps: ['jquery']
    'bootstrap-slider'                   : deps: ['jquery']
    'directives/ngController'            : deps: ['app']
    'directives/radar'                   : deps: ['app', 'underscore', 'd3']
    'directives/slider'                  : deps: ['app', 'bootstrap-slider']
    'filters/twitterfy'                  : deps: ['app']
    'responseInterceptors/dispatcher'    : deps: ['app']
    'bootstrap'                          : deps: ['app']
    'routes'                             : deps: ['app']
    'run'                                : deps: ['app']
    'views'                              : deps: ['app']
    'app'                                : deps: ['angular', 'angular-resource']
  [
    'require'
    'directives/radar'
    'directives/slider'
    'directives/ngController'
    'responseInterceptors/dispatcher'
    'routes'
    'run'
    'views'
  ], (require) ->
    angular.element(document).ready ->
      require ['bootstrap']