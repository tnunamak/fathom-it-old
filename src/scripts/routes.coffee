angular.module('app').config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .otherwise
      redirectTo: '/'
      templateUrl: '/views/radarWrapper.html'
]