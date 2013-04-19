angular.module('app').directive 'slider', ['$log', '$timeout', ($log, $timeout) ->
  restrict: 'A'
  scope: { control:'=radarControl' }
  link: (scope, element, attrs) ->
    step = if(scope.control.integerType) then 1 else (scope.control.max - scope.control.min)/1000
    lockUpdate = false
    element.slider({
      min: scope.control.min
      max: scope.control.max
      step: step
      value: scope.control.value
    }).on('slide', (e) ->
      if(!scope.control.initParam)
        scope.control.update(element.val())
        console.log(scope.control.name+" "+element.val())
    ).on('slideStart', (e) ->
      lockUpdate = true;
    ).on('slideStop', (e) ->
      scope.control.update(element.val())
      console.log(scope.control.name+" "+element.val())
      lockUpdate = false;
    )

    scope.$watch('control.value'
    , (newValue, oldValue) ->
      if(lockUpdate)
        return
      element.slider('setValue', newValue)
    )
]