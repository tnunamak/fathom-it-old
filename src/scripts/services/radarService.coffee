angular.module('app').factory 'radarService', ['$log', '$timeout', ($log, $timeout) ->

  degToRads = Math.PI/180

  rectifyTheta = (thetaDeg) ->
    if isNaN(thetaDeg) then $log.error("thetaDeg is not a number"); thetaDeg
    if thetaDeg >= 0 then thetaDeg % 360 else rectifyTheta(thetaDeg + 360)

  getOuterRadiusForSameArea = (commonRadius, innerRadius, radiusSoftener) ->
        Math.pow(Math.sqrt(2*commonRadius*commonRadius - innerRadius*innerRadius), radiusSoftener)

  ### Theta in degrees ###
  ### The +90 is to rotate the cartesian plane so the polar calculations match it ###
  polarCoordinates = (o) ->
    {r: Math.sqrt(Math.pow(o.x, 2) + Math.pow(o.y, 2)), theta: rectifyTheta(Math.atan2(o.y, o.x)*(1/degToRads) + 90)}

  cartesianCoordinates = (o) ->
    {x: o.r * Math.cos((o.theta - 90) * degToRads), y: o.r * Math.sin((o.theta - 90) * degToRads)}


  smallestAngleBetween = (source, target) ->
    return smallestAngleBetween(target, source)  if target < source
    a = target - source
    a = (a + 180) % 360 - 180
    Math.abs(a)

  {degToRads, getOuterRadiusForSameArea, smallestAngleBetween, polarCoordinates, cartesianCoordinates}
]