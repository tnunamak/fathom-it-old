angular.module('app').factory 'localStorageWatcher', ['$log', '$rootScope', 'localStorage', ($log, $rootScope, localStorage) ->

  syncWithLocalStorage = (storageKey, optionalObjectTemplate) ->

    objectTemplate = if optionalObjectTemplate then optionalObjectTemplate else {}

    ### Initialize the sync by loading the object from local storage to be watched in the $rootScope ###

    storageObjectString = localStorage[storageKey]
    storageObject = (if storageObjectString then JSON.parse(storageObjectString) else objectTemplate)

    $rootScope.$watch (->
        ### If this object changes then the listener will be called to update local storage ###
        storageObject
      ), (->
          ### Save changes to local storage ###
          localStorage[storageKey] = JSON.stringify(storageObject)
      ### Compare object for equality rather than for reference ###
      ), true

    storageObject
  {syncWithLocalStorage}
]