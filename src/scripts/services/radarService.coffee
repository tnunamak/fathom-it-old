angular.module('app').factory 'radarService', ['$log', '$timeout', 'localStorageWatcher',
($log, $timeout, localStorageWatcher) ->

  degToRads = Math.PI/180

  rectifyTheta = (thetaDeg) ->
    if isNaN(thetaDeg) then $log.error("thetaDeg is not a number"); throw Error("thetaDeg is NaN")
    if thetaDeg >= 0 then thetaDeg % 360 else rectifyTheta(thetaDeg + 360)

  getOuterRadiusForSameArea = (commonRadius, innerRadius, radiusSoftener) ->
        Math.pow(Math.sqrt(2*commonRadius*commonRadius - innerRadius*innerRadius), radiusSoftener)

  getRadii = (ringIndex, baseWidth, radiusSoftener) ->
    innerR = (if ringIndex==0 then 0 else getRadii(ringIndex-1, baseWidth, radiusSoftener).outer)
    outerR = (if ringIndex==0 then baseWidth else
      getOuterRadiusForSameArea(innerR, getRadii(ringIndex-1, baseWidth, radiusSoftener).inner, radiusSoftener))
    {inner: innerR, outer: outerR}

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

  randomArcPoint = (arc) ->
    point = {}
    point.r = Math.random() * (arc.outerRadius - arc.innerRadius) + arc.innerRadius
    point.theta = Math.random() * (arc.endAngle - arc.startAngle) + arc.startAngle
    cartesianCoordinates(point)

  arcTemplate = d3.svg.arc().innerRadius((d) -> d.innerRadius).outerRadius((d) -> d.outerRadius).startAngle((d) -> d.startAngle * degToRads).endAngle((d) -> d.endAngle * degToRads)

  # Resolves collisions between d and all other circles.
  collide = (alpha, nodes, radius, padding) ->
    quadtree = d3.geom.quadtree(nodes)
    (d) ->
      r = radius + padding
      nx1 = d.x - r
      nx2 = d.x + r
      ny1 = d.y - r
      ny2 = d.y + r
      quadtree.visit (quad, x1, y1, x2, y2) ->
        if quad.point and (quad.point isnt d)
          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)
          r = radius + quad.point.radius
          if l < r
            l = (l - r) / l * alpha
            d.x -= x *= l
            d.y -= y *= l
            quad.point.x += x
            quad.point.y += y
        ### Return true if the square defined by (x1, y1, x2, y2) doesn't intersect with  d. True -> don't visit
        children of quad ###
        x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1

  rectifyData = (data) ->
    ### Don't remember any saved positioning information ###
    _.each(data.technologies, (tech) ->
      delete tech.x
      delete tech.y
      delete tech.px
      delete tech.py
      delete tech.r
      delete tech.theta
    )

    ### TODO look for data categories and rings in technologies and add them ###
    data

  LOCAL_STORAGE_ID = 'fathomit.technologyRadarData'
  data = localStorageWatcher.syncWithLocalStorage(LOCAL_STORAGE_ID, {
    categories: ['Tools', 'Platforms', 'Languages & Frameworks', 'Techniques']
    rings:      ['Adopt', 'Trial', 'Assess', 'Hold']
    ###technologies: [
      {label: "Klingon",              category: "Languages & Frameworks",  ring: "Adopt"},
      {label: "Laser sharks",         category: "Tools",                   ring: "Trial"},
      {label: "Evil empires",         category: "Platforms",               ring: "Hold"},
      {label: "Nuclear laser sharks", category: "Tools",                   ring: "Assess"}
    ])###
    technologies: [
      {label: "Health check pages", category: "Techniques", ring: "Adopt"},
      {label: "Windows infrastructure automation", category: "Techniques", ring: "Adopt"},
      {label: "Guerrilla user testing", category: "Techniques", ring: "Adopt"},
      {label: "Work-in-Progress limits", category: "Techniques", ring: "Adopt"},
      {label: "Automated deployment pipeline", category: "Techniques", ring: "Adopt"},
      {label: "In process acceptance testing", category: "Techniques", ring: "Adopt"},
      {label: "Advanced analytics", category: "Techniques", ring: "Adopt"},
      {label: "Aggregates as documents", category: "Techniques", ring: "Adopt"},
      {label: "Polyglot Persistence", category: "Techniques", ring: "Trial"},
      {label: "Performance testing as a first-class citizen", category: "Techniques", ring: "Trial"},
      {label: "Out-of-container functional testing", category: "Techniques", ring: "Trial"},
      {label: "Micro-services", category: "Techniques", ring: "Trial"},
      {label: "Infrastructure auotmation of development workstations", category: "Techniques", ring: "Trial"},
      {label: "Agile analytics", category: "Techniques", ring: "Trial"},
      {label: "Logs as data", category: "Techniques", ring: "Trial"},
      {label: "Responsive web design", category: "Techniques", ring: "Trial"},
      {label: "Mobile first", category: "Techniques", ring: "Trial"},
      {label: "Declarative provisioning", category: "Techniques", ring: "Trial"},
      {label: "Remote usability testing", category: "Techniques", ring: "Trial"},
      {label: "Semantic monitoring", category: "Techniques", ring: "Trial"},
      {label: "Edge Side Includes for page composition", category: "Techniques", ring: "Trial"},
      {label: "Configuration in DNS", category: "Techniques", ring: "Trial"},
      {label: "Deployment and scripting test tools", category: "Techniques", ring: "Assess"},
      {label: "Database based integration", category: "Techniques", ring: "Hold"},
      {label: "Feature branching", category: "Techniques", ring: "Hold"},
      {label: "Test recorders", category: "Techniques", ring: "Hold"},
      {label: "Exhaustive browser-based testing", category: "Techniques", ring: "Hold"},
      {label: "Infrastructure as code", category: "Tools", ring: "Adopt"},
      {label: "Embedded servlet containers", category: "Tools", ring: "Adopt"},
      {label: "Silverback", category: "Tools", ring: "Adopt"},
      {label: "AppCode", category: "Tools", ring: "Adopt"},
      {label: "Jasmine paired with Node.js", category: "Tools", ring: "Adopt"},
      {label: "Immutable servers", category: "Tools", ring: "Adopt"},
      {label: "Graphite", category: "Tools", ring: "Adopt"},
      {label: "Vagrant", category: "Tools", ring: "Trial"},
      {label: "Gradle", category: "Tools", ring: "Trial"},
      {label: "PSake", category: "Tools", ring: "Trial"},
      {label: "Frank", category: "Tools", ring: "Trial"},
      {label: "JavaScript micro frameworks", category: "Tools", ring: "Trial"},
      {label: "Jade", category: "Tools", ring: "Trial"},
      {label: "NuGet", category: "Tools", ring: "Trial"},
      {label: "Highcharts", category: "Tools", ring: "Trial"},
      {label: "D3", category: "Tools", ring: "Trial"},
      {label: "Apache Pig", category: "Tools", ring: "Trial"},
      {label: "SaaS performance testing tools", category: "Tools", ring: "Trial"},
      {label: "Dependency Structure Matrices", category: "Tools", ring: "Trial"},
      {label: "Locust", category: "Tools", ring: "Trial"},
      {label: "Rake for Java & .Net", category: "Tools", ring: "Trial"},
      {label: "Logic-free markup", category: "Tools", ring: "Assess"},
      {label: "Crazy Egg", category: "Tools", ring: "Assess"},
      {label: "Zipkin", category: "Tools", ring: "Assess"},
      {label: "Zucchini", category: "Tools", ring: "Assess"},
      {label: "GemJars", category: "Tools", ring: "Assess"},
      {label: "Light Table", category: "Tools", ring: "Assess"},
      {label: "Riemann", category: "Tools", ring: "Assess"},
      {label: "Enterprise service bus", category: "Tools", ring: "Hold"},
      {label: "VCS with implicit workflow", category: "Tools", ring: "Hold"},
      {label: "Maven", category: "Tools", ring: "Hold"},
      {label: "Clojure", category: "Languages & Frameworks", ring: "Adopt"},
      {label: "Scala", category: "Languages & Frameworks", ring: "Adopt"},
      {label: "Care about languages", category: "Languages & Frameworks", ring: "Adopt"},
      {label: "SASS, SCSS, LESS, and Stylus", category: "Languages & Frameworks", ring: "Adopt"},
      {label: "Domain-Specific Languages", category: "Languages & Frameworks", ring: "Trial"},
      {label: "Scratch, Alice, and Kodu", category: "Languages & Frameworks", ring: "Trial"},
      {label: "Twitter Bootstrap", category: "Languages & Frameworks", ring: "Trial"},
      {label: "Sinatra", category: "Languages & Frameworks", ring: "Trial"},
      {label: "AngularJS and Knockout", category: "Languages & Frameworks", ring: "Trial"},
      {label: "Require.js", category: "Languages & Frameworks", ring: "Trial"},
      {label: "Dropwizard", category: "Languages & Frameworks", ring: "Trial"},
      {label: "Jekyll", category: "Languages & Frameworks", ring: "Trial"},
      {label: "HTML5 for offline applications", category: "Languages & Frameworks", ring: "Trial"},
      {label: "F#", category: "Languages & Frameworks", ring: "Assess"},
      {label: "ClojureScript", category: "Languages & Frameworks", ring: "Assess"},
      {label: "Lua", category: "Languages & Frameworks", ring: "Assess"},
      {label: "RubyMotion", category: "Languages & Frameworks", ring: "Assess"},
      {label: "Gremlin", category: "Languages & Frameworks", ring: "Assess"},
      {label: "JavaScript as a platform", category: "Languages & Frameworks", ring: "Assess"},
      {label: "Backbone.js", category: "Languages & Frameworks", ring: "Hold"},
      {label: "Logic in stored procedures", category: "Languages & Frameworks", ring: "Hold"},
      {label: "Google Dart", category: "Languages & Frameworks", ring: "Hold"},
      {label: "Component-based frameworks", category: "Languages & Frameworks", ring: "Hold"},
      {label: "ATOM", category: "Platforms", ring: "Adopt"},
      {label: "Care about hardware", category: "Platforms", ring: "Adopt"},
      {label: "Mobile payment systems", category: "Platforms", ring: "Adopt"},
      {label: "Neo4J", category: "Platforms", ring: "Adopt"},
      {label: "Node.js", category: "Platforms", ring: "Trial"},
      {label: "Riak", category: "Platforms", ring: "Trial"},
      {label: "Domain-specific PaaS", category: "Platforms", ring: "Trial"},
      {label: "Linux containers", category: "Platforms", ring: "Trial"},
      {label: "Private clouds", category: "Platforms", ring: "Trial"},
      {label: "Hybrid clouds", category: "Platforms", ring: "Trial"},
      {label: "MongoDB", category: "Platforms", ring: "Trial"},
      {label: "Continuous integration in the cloud", category: "Platforms", ring: "Trial"},
      {label: "Couchbase", category: "Platforms", ring: "Trial"},
      {label: "Single threaded servers with asynchronous I/O", category: "Platforms", ring: "Trial"},
      {label: "Calatrava", category: "Platforms", ring: "Assess"},
      {label: "Datomic", category: "Platforms", ring: "Assess"},
      {label: "Vert.x", category: "Platforms", ring: "Assess"},
      {label: "Azure", category: "Platforms", ring: "Assess"},
      {label: "Open source IaaS", category: "Platforms", ring: "Assess"},
      {label: "BigQuery", category: "Platforms", ring: "Assess"},
      {label: "Windows Phone", category: "Platforms", ring: "Assess"},
      {label: "WS-*", category: "Platforms", ring: "Hold"},
      {label: "Java portal servers", category: "Platforms", ring: "Hold"},
      {label: "Zero-code packages", category: "Platforms", ring: "Hold"},
      {label: "Singleton infrastructure", category: "Platforms", ring: "Hold"},
      {label: "Meteor.js", category: "Platforms", ring: "Hold"},
    ]})

  rectifyData(data)

  dataFunctions = {
    getArcs: () ->
      arcs = []
      arcs.push({category: category, ring: ring, categoryIndex: i_c, ringIndex: i_r}) for ring, i_r in this.rings for category, i_c in this.categories
      arcs
    getArcNodes: (arc) ->
      _.where(data.technologies, {category: arc.category, ring: arc.ring})
  }

  ### Enables data.getArcs(), etc. ###
  _.each(dataFunctions, (func) -> _.bind(func, data))
  _.extend(data, dataFunctions)

  {data, degToRads, getRadii, randomArcPoint, arcTemplate, collide, smallestAngleBetween, polarCoordinates, cartesianCoordinates}
]