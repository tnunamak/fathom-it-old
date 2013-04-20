angular.module('app').directive 'appRadar', ['$log', '$timeout', 'radarService', ($log, $timeout, radarService) ->
  restrict: 'E'
  templateUrl: '/views/directives/techRadar.html'
  transclude: true
  controller: ['$scope', '$element', '$attrs', '$location', ($scope, $element, $attrs, $location) ->
    $scope.hello = "hello world"
  ]
  link: (scope, element) ->
    scope.controls = []

    defineControl = (name, initializationParameter, integerType, min, max, initialValue, updateCallback) ->
      if(initialValue < min || initialValue > max)
        throw new Error("Initial value must be between min and max")

      redraw = () ->
        ### clear the elements inside of the directive ###
        vis.selectAll('*').remove();
        force.stop()
        drawRadar()

      position = scope.controls.push({name: name, initParam: initializationParameter, min: min, max: max, value: initialValue, integerType: integerType}) - 1
      boundControl = _.bind((newValue)->
        if newValue
          this.value = newValue
          if updateCallback
            updateCallback(newValue)
          if this.initParam
            redraw()
          scope.$apply()
        this.value
      , scope.controls[position])
      scope.controls[position].update = boundControl

      boundControl

    data = [
      # Slices
      [
        # Rings
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
      ]
      [
        # Rings
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
      ]
      [
        # Rings
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
      ]
      [
        # Rings
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
        [
          {label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'something'},{label: 'last'}
        ]
      ]
    ]

    initialNumSlices = data.length
    initialNumRings = Math.max(_.keys(_.countBy(data, (slice) -> return slice.length )))

    numSlices = defineControl("Number of slices", true, true, initialNumSlices, 4, initialNumSlices)
    numRings = defineControl("Number of rings", true, true, initialNumRings, 5, initialNumRings)
    slowMo = defineControl("Slow-mo", false, true, 0, 1000, 0)

    _.each(ring, (d) ->
        d.slice = i_s
        d.ring = i_r
      , slice
    ) for ring, i_r in slice for slice, i_s in data

    nodes = _.flatten(data)
    radii = []
    arcs = []

    baseWidth = defineControl("Base ring width", true, false, 10, 500, 180)
    radiusSoftener = defineControl("Radius softener", true, false, 1, 1.01, 1.003)
    nodeRadius = defineControl("Node radius", false, true, 1, 30, 8)

    defineRing = (ring) ->
      innerR = (if ring==0 then 0 else radii[ring-1].outer)
      outerR = (if ring==0 then baseWidth() else radarService.getOuterRadiusForSameArea(innerR, radii[ring-1].inner, radiusSoftener()))
      radii.push({inner: innerR, outer: outerR})

    defineArc = (slice, ring) ->
      radialWidthDeg = 360/numSlices()
      startAngleDeg = slice * radialWidthDeg
      endAngleDeg = startAngleDeg + radialWidthDeg
      arcs.push({slice: slice, ring: ring, innerRadius: radii[ring].inner, outerRadius: radii[ring].outer, startAngle: startAngleDeg, endAngle: endAngleDeg, data: data[slice][ring]})

    getArc = (node) ->
      index = node.ring + node.slice * numRings()
      arcs[index]


    arcTemplate = d3.svg.arc().innerRadius((d) -> d.innerRadius).outerRadius((d) -> d.outerRadius).startAngle((d) -> d.startAngle * radarService.degToRads).endAngle((d) -> d.endAngle * radarService.degToRads)

    getArcPosition = (node) ->
      arcTemplate.centroid(getArc(node))

    layoutWidth = defineControl("Layout width", true, true, 0, 960, 960)
    layoutHeight = defineControl("Layout height", true, true, 0, 1200, 700)
    padding = defineControl("Node padding", true, false, 0, 15, 6)

    forceGravity = defineControl("Gravity", false, false, 0, 1, 0, (g) -> masterForce.gravity(g))
    forceAlpha = defineControl("Alpha", false, false, 0, 3, 0.2, (a) -> masterForce.alpha(a))
    forceCharge = defineControl("Charge", false, false, -50, 50, -2, (c) -> masterForce.charge(c))
    forceFriction = defineControl("Friction", false, false, .8, 1, .89, (f) -> masterForce.friction(f))

    forces = []

    masterForce = {
      gravity: (g) -> _.each(forces, (force) -> force.gravity(g)); this
      alpha: (a) -> _.each(forces, (force) -> force.alpha(a)); this
      charge: (c) -> _.each(forces, (force) -> force.charge(c)); this
      friction: (f) -> _.each(forces, (force) -> force.friction(f)); this
      resume: () ->  _.each(forces, (force) -> force.resume()); this
      start: () ->  _.each(forces, (force) -> force.start()); this
      apply: (func) ->  _.each(forces, (force) -> func(force)); this
    }


    containerForce = defineControl("Container force", false, false, 0, 100, 50)
    minAlpha = defineControl("Minimum alpha", false, false, 0, 1, 0, (a) -> if forceAlpha() < a then forceAlpha(a))

    scheme = ["Reds", "Oranges", "Greens", "Blues", "Purples"]

    getClassForNode = (d) ->
      "q"+(d.ring+1)+"-9"

    xOffset = 400
    yOffset = 350
    vis = d3.select(element[0]).append("svg").append("g").attr("transform", "translate("+[xOffset, yOffset]+")")

    force = undefined

    vis.on "click", ->
      nodes.forEach (o, i) ->
        o.x += (Math.random() - .5) * 5
        o.y += (Math.random() - .5) * 5
      masterForce.resume()

    drawRadar = ->
      radii = []
      arcs = []

      nodes.forEach (o) ->
        o.radius = nodeRadius()

      defineRing(ring) for ring in [0..(numRings()-1)]
      defineArc(slice, ring) for ring in [0..(numRings()-1)] for slice in [0..(numSlices()-1)]

      ### Fade in ###
      vis.attr("width", layoutWidth()).attr("height", layoutHeight()).style("opacity", 1e-6)
        .transition()
        .duration(1000)
        .style("opacity", 1)

      arcSelection = vis.selectAll("arc").data(arcs).enter().append("g")
        .attr("id", (d) -> "ring-"+d.ring+"-slice-"+d.slice)
        .attr("class", (d) -> scheme[d.slice % scheme.length])
        .append("path")
          .attr("d", arcTemplate)
          .attr("class", getClassForNode)

      ######arcSelection.exit().remove()

      randomArcPoint = (arc) ->
        point = {}
        point.r = Math.random() * (arc.outerRadius - arc.innerRadius) + arc.innerRadius
        point.theta = Math.random() * (arc.endAngle - arc.startAngle) + arc.startAngle
        radarService.cartesianCoordinates(point)

      ### Done with arcs, on to nodes ###
      arcSelection = vis.selectAll("arc").data(arcs)
      ###todo code duplication###
      arcSelection.enter().append("g").attr("class", (d) -> scheme[((d.slice + numSlices()/2) % numSlices()) % scheme.length])
      nodeEnterSelection = arcSelection.selectAll("circle.node").data((arc) -> arc.data)
        .enter().append("svg:circle").attr("class", "node").attr("cx", (d) ->
              location = randomArcPoint(getArc(d))
              [d.x, d.y] = [location.x, location.y]
              d.x
            ).attr("cy", (d) ->
              d.y
            ).attr("r", nodeRadius())
            .attr("class", getClassForNode)
            .style("stroke-width", 1.5)
            .style("stroke", "#000000")

      nodeEnterSelection.append("text", (d) ->
        d.label
      )

      # Resolves collisions between d and all other circles.
      collide = (alpha) ->
        quadtree = d3.geom.quadtree(nodes)
        (d) ->
          r = d.radius + padding()
          nx1 = d.x - r
          nx2 = d.x + r
          ny1 = d.y - r
          ny2 = d.y + r
          quadtree.visit (quad, x1, y1, x2, y2) ->
            if quad.point and (quad.point isnt d)
              x = d.x - quad.point.x
              y = d.y - quad.point.y
              l = Math.sqrt(x * x + y * y)
              r = d.radius + quad.point.radius
              if l < r
                l = (l - r) / l * alpha
                d.x -= x *= l
                d.y -= y *= l
                quad.point.x += x
                quad.point.y += y
            ### Return true if the square defined by (x1, y1, x2, y2) doesn't intersect with  d. True -> don't visit
            children of quad ###
            x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1

      ### TODO different force for each arc ###
      launchForces = (arc) ->
        forces.push(d3.layout.force()
          .nodes(arc)
          .links([])
          .linkStrength(0)
          .size([layoutWidth(), layoutHeight()]))
      launchForces(ring) for ring, i_r in slice for slice, i_s in data

      masterForce
        .gravity(forceGravity())
        .alpha(forceAlpha())
        .charge(forceCharge())
        .friction(forceFriction())
        .start()

      masterForce.apply (force)->
        nodeEnterSelection.call(force.drag)

      ### Initialize directionality tracking vars ###
      nodes.forEach (o) ->
        o.last_r_dir = if Math.random() > .05 then 1 else -1
        o.last_theta_dir = if Math.random() > .05 then 1 else -1

      scaleContainerForce = (alpha) ->
        containerForce() * alpha

      runSimulationStep = (e) ->
        forceAlpha(Math.max(minAlpha(), e.alpha))
        k = scaleContainerForce(e.alpha)

        min_k_r = .2
        min_k_theta = .1

        k_r = min_k_r*k
        k_theta = min_k_theta*k

        containerPadding = nodeRadius() + padding()

        nodes.forEach (o, i) ->
          nodeArc = getArc(o)

          q = 10
          containerAngularPadding = containerPadding * q * radarService.degToRads
          polar = radarService.polarCoordinates(o)
          [o.r, o.theta] = [polar.r, polar.theta]

          d_r =
            if o.r < (nodeArc.innerRadius + containerPadding) then Math.max(k_r, min_k_r)
            else if (nodeArc.outerRadius - containerPadding) < o.r then -Math.max(k_r, min_k_r)
            else if (o.r - (0.5 * (nodeArc.innerRadius + nodeArc.outerRadius)) > 0) then 0 else 0

          d_thetaDirection = 0

          differenceWithStart = radarService.smallestAngleBetween(nodeArc.startAngle, o.theta)
          differenceWithEnd = radarService.smallestAngleBetween(nodeArc.endAngle, o.theta)

          if nodeArc.startAngle + containerAngularPadding <= o.theta && o.theta + containerAngularPadding <= nodeArc.endAngle
            d_thetaDirection = 0
          else if(differenceWithStart < differenceWithEnd)
            d_thetaDirection = 1
          else d_thetaDirection = -1

          d_theta = d_thetaDirection * Math.max(k_theta, min_k_theta)

          o.r += d_r
          o.theta += d_theta

          cartesian = radarService.cartesianCoordinates(o)
          [o.x, o.y] = [cartesian.x, cartesian.y]

        nodeEnterSelection
        .each(collide(.5))
        .attr("cx", (d) ->
          d.x
        ).attr "cy", (d) ->
          d.y
      lastAlpha = undefined
      masterForce.apply (force)->
        force.on "tick",(e) ->
          lastAlpha = ->
            e.alpha
          force.stop()
          $timeout( ->
            force.alpha(lastAlpha())
            runSimulationStep(e)
            ### TODO can you get the max of simulationSpeed() ? ###
          , slowMo())

    ### Kick it all off ###
    drawRadar()
]