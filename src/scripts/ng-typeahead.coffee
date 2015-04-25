# Typeahead directive

app = angular.module('ng-typeahead',[]) 
app.directive 'ngTypeahead', ($log, $timeout) ->
  {
    restrict: 'E'
    scope: {
      data: '='
      delay: "=?"
      forceSelection: "=?"
      limit: '=?'
      startFilter: "=?"
      threshold: '=?'
      onBlur: "=?"
      onSelect: '=?'
      onType: "=?"
    }

    require: "?ngModel"
    transclude: true
    link: (scope, elem, attrs, ngModel) ->
      KEY =
        UP: 38
        DOWN: 40
        ENTER: 13
        TAB: 9
        ESC: 27

      selectedLabel = scope.search
      selecting = undefined
      itemSelected = false
      scope.index = 0

      scope.delay = 0 if !scope.delay

      scope.placeholder = attrs.placeholder

      if scope.startFilter is undefined then scope.startFilter = true
      if scope.limit is undefined then scope.limit = Infinity
      if scope.threshold is undefined then scope.threshold = 0
      if scope.forceSelection is undefined then scope.forceSelection = false

      scope.$watch "search", (v) ->
        scope.index = 0
        ngModel.$setViewValue v
        return if v is selectedLabel
        itemSelected = false
        if v isnt undefined
          scope.onType(scope.search) if scope.onType # execute on-type function
          scope.showSuggestions = scope.suggestions.length && scope.search && scope.search.length > scope.threshold

      scope.$onBlur = ->
        if !itemSelected and scope.forceSelection then scope.search = selectedLabel
        scope.showSuggestions = false
        
      scope.$onSelect = (item) ->
        selecting = true
        selectedLabel = item.label
        scope.search = item.label
        itemSelected = true
        scope.onSelect(item) if scope.onSelect
        scope.showSuggestions = false
        $timeout ->
          selecting = false

      scope.$onKeyDown = (event) ->
        switch event.keyCode
          when KEY.UP
            if scope.index > 0 then scope.index-- else scope.index = (scope.suggestions.length - 1) 
          when KEY.DOWN
            if scope.index < (scope.suggestions.length - 1) then scope.index++ else scope.index = 0
          when KEY.ENTER
            scope.$onSelect scope.suggestions[scope.index]
          when KEY.TAB
            scope.$onSelect scope.suggestions[scope.index]
          when KEY.ESC
            scope.showSuggestions = false    
      
    template: """
                <input ng-model="search" placeholder="{{placeholder}}" ng-keydown="$onKeyDown($event)" ng-model-options="{ debounce: delay }" ng-blur="$onBlur()" class="ng-typeahead-input"/>
                <div class="ng-typeahead-wrapper">
                  <ul class="ng-typeahead-list" ng-show="showSuggestions">
                    <li class="ng-typeahead-list-item" ng-repeat="item in suggestions = (data | filter:search | startsWith:search:startFilter |limitTo: limit | highlight:search)" ng-mousedown="$onSelect(item)" ng-class="{'active': $index == index}" ng-bind-html="item.html"></li>
                    </ul>
                </div>
                <div ng-transclude>
              """
  }

#Filters
app.filter "startsWith", ($log) ->
    strStartsWith = (suggestion, search) ->
      if !!suggestion and !!search
        suggestion.toLowerCase().indexOf(search.toLowerCase()) is 0

    (suggestions, search, startFilter) ->
        if startFilter
          filtered = []
          angular.forEach suggestions, (suggestion) ->
            filtered.push suggestion  if strStartsWith(suggestion.label, search)
          filtered
        else
          suggestions

app.filter "highlight", ($sce) ->
    (item, search) ->
      angular.forEach item, (input) ->

        if search
          words = "(" + search.split(/\ /).join(" |") + "|" + search.split(/\ /).join("|") + ")"
          exp = new RegExp(words, "gi")
          normalInput = input.label.slice(search.length)
          highlightedInput = input.label.slice(0, search.length).replace(exp, "<span class=\"ng-typeahead-highlight\">$1</span>") if words.length
          input.html = $sce.trustAsHtml highlightedInput + normalInput
      item
