angular.module('app').directive 'appRadar', ['$log', '$timeout', 'radarService',
($log, $timeout, radarService) ->
  restrict: 'E'
  templateUrl: '/views/directives/techRadar.html'
  transclude: true
  controller: ['$scope', '$element', '$attrs', '$location', ($scope, $element, $attrs, $location) ->
    $scope.devMode = true
  ]
  link: (scope, element) ->
    scope.controls = []

    defineControl = (name, initializationParameter, integerType, min, max, initialValue, updateCallback) ->
      if(initialValue < min || initialValue > max)
        throw new Error("Initial value must be between min and max")

      redraw = () ->
        ### clear the elements inside of the directive ###
        vis.selectAll('*').remove();
        masterForce.stop()
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

    data = radarService.data


    forces = []

    masterForce = {
      gravity: (g) -> _.each(forces, (force) -> force.gravity(g)); this
      alpha: (a) -> _.each(forces, (force) -> force.alpha(a)); this
      charge: (c) -> _.each(forces, (force) -> force.charge(c)); this
      friction: (f) -> _.each(forces, (force) -> force.friction(f)); this
      resume: () ->  _.each(forces, (force) -> force.resume()); this
      start: () ->  _.each(forces, (force) -> force.start()); this
      stop: () ->  _.each(forces, (force) -> force.stop()); this
      apply: (func) ->  _.each(forces, (force) -> func(force)); this
      applyFirst: (func) ->  func(forces[0]); this
    }


    slowMo = defineControl("Slow-mo", false, true, 0, 1000, 0)

    baseWidth = defineControl("Base ring width", true, false, 10, 500, 160)
    radiusSoftener = defineControl("Radius softener", true, false, 1, 1.01, 1.003)
    nodeRadius = defineControl("Node radius", false, true, 1, 30, 8)

    layoutWidth = defineControl("Layout width", true, true, 0, 960, 960)
    layoutHeight = defineControl("Layout height", true, true, 0, 1200, 700)
    padding = defineControl("Node padding", true, false, 0, 15, 6)

    forceGravity = defineControl("Gravity", false, false, 0, 1, 0, (g) -> masterForce.gravity(g))
    forceAlpha = defineControl("Alpha", false, false, 0, 3, 0.2, (a) -> masterForce.alpha(a))
    forceCharge = defineControl("Charge", false, false, -50, 50, -2, (c) -> masterForce.charge(c))
    forceFriction = defineControl("Friction", false, false, .8, 1, .89, (f) -> masterForce.friction(f))

    containerForce = defineControl("Container force", false, false, 0, 100, 50)
    minAlpha = defineControl("Minimum alpha", false, false, 0, 1, 0, (a) -> if forceAlpha() < a then forceAlpha(a))

    _.each(ring, (d) ->
        d.slice = i_s
        d.ring = i_r
      , slice
    ) for ring, i_r in slice for slice, i_s in data

    radii = []
    arcs = []

    defineArc = (arc) ->
      radialWidthDeg = 360/data.categories.length
      radii = radarService.getRadii(arc.ringIndex, baseWidth(), radiusSoftener())
      arc.innerRadius = radii.inner
      arc.outerRadius = radii.outer
      arc.startAngle = arc.categoryIndex * radialWidthDeg
      arc.endAngle = arc.startAngle + radialWidthDeg
      arc.data = data.getArcNodes(arc)

    getArc = (node) ->
      wrapper = _.where(arcs, {category: node.category, ring: node.ring})
      wrapper[0]

    getArcPosition = (node) ->
      radarService.arcTemplate.centroid(getArc(node))

    scheme = ["Reds", "Oranges", "Greens", "Blues", "Purples"]

    ### TODO modify design to remove these functions ###
    getSectionClass = (d) ->
      "q"+(d.ringIndex+1)+"-9"

    getTechnologyClass = (d) ->
      "q"+(getArc(d).ringIndex+1)+"-9"

    xOffset = 400
    yOffset = 350
    vis = d3.select(element[0]).append("svg").append("g").attr("transform", "translate("+[xOffset, yOffset]+")")

    force = undefined

    vis.on "click", ->
      data.technologies.forEach (o, i) ->
        o.x += (Math.random() - .5) * 5
        o.y += (Math.random() - .5) * 5
      masterForce.resume()

    drawRadar = ->
      radii = []
      arcs = []

      arcs = data.getArcs()

      defineArc(arc) for arc in arcs

      ### Fade in ###
      vis.attr("width", layoutWidth()).attr("height", layoutHeight()).style("opacity", 1e-6)
        .transition()
        .duration(1000)
        .style("opacity", 1)

      arcSelection = vis.selectAll("arc").data(arcs).enter().append("g")
        .attr("id", (d) -> d.category+"-"+d.ring)
        .attr("class", (d) -> scheme[d.categoryIndex % scheme.length])
        .append("path")
          .attr("d", radarService.arcTemplate)
          .attr("class", getSectionClass)

      ######arcSelection.exit().remove()

      translateText = (d) ->
        {x: d.x + 12, y: d.y + 4}

      ### Done with arcs, on to nodes ###
      arcSelection = vis.selectAll("arc").data(arcs)
      ###todo code duplication###
      arcSelection.enter().append("g").attr("class", (d) -> scheme[((d.categoryIndex + data.categories.length/2) % data.categories.length) % scheme.length])
      nodeEnterSelection = arcSelection.selectAll("circle.node").data((arc) -> arc.data)
        .enter().append('g')
      nodeEnterSelection.append("svg:circle").attr("class", "node").attr("cx", (d) ->
              location = radarService.randomArcPoint(getArc(d))
              [d.x, d.y] = [location.x, location.y]
              d.x
            ).attr("cy", (d) ->
              d.y
            ).attr("r", nodeRadius())
            .attr("class", getTechnologyClass)
            .style("stroke-width", 1.5)
            .style("stroke", "#000000").on('mouseover', (d) ->
              d.highlighted = true
            ).on('mouseout', (d) ->
              d.highlighted = false
            )

      nodeEnterSelection.append("text").text((d) -> d.label)
        .attr("x", (d) -> translateText(d).x )
        .attr("y", (d) -> translateText(d).y )

      ### TODO different force for each arc ###
      launchForces = (arc) ->
        forces.push(d3.layout.force()
          .nodes(data.getArcNodes(arc))
          .links([])
          .linkStrength(0)
          .size([layoutWidth(), layoutHeight()]))
      launchForces(arc) for arc in arcs

      masterForce
        .gravity(forceGravity())
        .alpha(forceAlpha())
        .charge(forceCharge())
        .friction(forceFriction())
        .start()

      masterForce.apply (force)->
        nodeEnterSelection.call(force.drag)

      ### Initialize directionality tracking vars ###
      nodes = data.technologies
      nodes.forEach (o) ->
        o.last_r_dir = if Math.random() > .05 then 1 else -1
        o.last_theta_dir = if Math.random() > .05 then 1 else -1

      scaleContainerForce = (alpha) ->
        containerForce() * alpha

      ### TODO this is called by every force... fix that ###
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

        nodeEnterSelection.each(radarService.collide(.5, nodes, nodeRadius(), padding()))
        nodeEnterSelection.select("circle").attr("cx", (d) -> d.x).attr("cy", (d) -> d.y)
        nodeEnterSelection.select("text").attr("x", (d) -> translateText(d).x).attr("y", (d) -> translateText(d).y).attr('style', (d) -> if d.highlighted then 'display:inherit' else 'display:none')

      lastAlpha = undefined
      masterForce.applyFirst (force)->
        force.on "tick",(e) ->
          lastAlpha = ->
            e.alpha
          force.stop()
          $timeout( ->
            masterForce.alpha(lastAlpha())
            runSimulationStep(e)
            ### TODO can you get the max of simulationSpeed() ? ###
          , slowMo())

    ### Kick it all off ###
    drawRadar()
]