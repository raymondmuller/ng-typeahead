var app;

app = angular.module('ng-typeahead', []);

app.directive('ngTypeahead', function($log, $timeout) {
  return {
    restrict: 'E',
    scope: {
      data: '=',
      delay: "=?",
      forceSelection: "=?",
      limit: '=?',
      startFilter: "=?",
      threshold: '=?',
      onBlur: "=?",
      onSelect: '=?',
      onType: "=?"
    },
    require: "?ngModel",
    transclude: true,
    link: function(scope, elem, attrs, ngModel) {
      var KEY, itemSelected, selectedLabel, selecting;
      KEY = {
        UP: 38,
        DOWN: 40,
        ENTER: 13,
        TAB: 9,
        ESC: 27
      };
      selectedLabel = scope.search;
      selecting = void 0;
      itemSelected = false;
      scope.index = 0;
      if (!scope.delay) {
        scope.delay = 0;
      }
      scope.placeholder = attrs.placeholder;
      if (scope.startFilter === void 0) {
        scope.startFilter = true;
      }
      if (scope.limit === void 0) {
        scope.limit = Infinity;
      }
      if (scope.threshold === void 0) {
        scope.threshold = 0;
      }
      if (scope.forceSelection === void 0) {
        scope.forceSelection = false;
      }
      scope.$watch("search", function(v) {
        scope.index = 0;
        ngModel.$setViewValue(v);
        if (v === selectedLabel) {
          return;
        }
        itemSelected = false;
        if (v !== void 0) {
          if (scope.onType) {
            scope.onType(scope.search);
          }
          return scope.showSuggestions = scope.suggestions.length && scope.search && scope.search.length > scope.threshold;
        }
      });
      scope.$onBlur = function() {
        if (!itemSelected && scope.forceSelection) {
          scope.search = selectedLabel;
        }
        return scope.showSuggestions = false;
      };
      scope.$onSelect = function(item) {
        selecting = true;
        selectedLabel = item.label;
        scope.search = item.label;
        itemSelected = true;
        if (scope.onSelect) {
          scope.onSelect(item);
        }
        scope.showSuggestions = false;
        return $timeout(function() {
          return selecting = false;
        });
      };
      return scope.$onKeyDown = function(event) {
        switch (event.keyCode) {
          case KEY.UP:
            if (scope.index > 0) {
              return scope.index--;
            } else {
              return scope.index = scope.suggestions.length - 1;
            }
            break;
          case KEY.DOWN:
            if (scope.index < (scope.suggestions.length - 1)) {
              return scope.index++;
            } else {
              return scope.index = 0;
            }
            break;
          case KEY.ENTER:
            return scope.$onSelect(scope.suggestions[scope.index]);
          case KEY.TAB:
            return scope.$onSelect(scope.suggestions[scope.index]);
          case KEY.ESC:
            return scope.showSuggestions = false;
        }
      };
    },
    template: "<input ng-model=\"search\" placeholder=\"{{placeholder}}\" ng-keydown=\"$onKeyDown($event)\" ng-model-options=\"{ debounce: delay }\" ng-blur=\"$onBlur()\" class=\"ng-typeahead-input\"/>\n<div class=\"ng-typeahead-wrapper\">\n  <ul class=\"ng-typeahead-list\" ng-show=\"showSuggestions\">\n    <li class=\"ng-typeahead-list-item\" ng-repeat=\"item in suggestions = (data | filter:search | startsWith:search:startFilter |limitTo: limit | highlight:search)\" ng-mousedown=\"$onSelect(item)\" ng-class=\"{'active': $index == index}\" ng-bind-html=\"item.html\"></li>\n    </ul>\n</div>\n<div ng-transclude>"
  };
});

app.filter("startsWith", function($log) {
  var strStartsWith;
  strStartsWith = function(suggestion, search) {
    if (!!suggestion && !!search) {
      return suggestion.toLowerCase().indexOf(search.toLowerCase()) === 0;
    }
  };
  return function(suggestions, search, startFilter) {
    var filtered;
    if (startFilter) {
      filtered = [];
      angular.forEach(suggestions, function(suggestion) {
        if (strStartsWith(suggestion.label, search)) {
          return filtered.push(suggestion);
        }
      });
      return filtered;
    } else {
      return suggestions;
    }
  };
});

app.filter("highlight", function($sce) {
  return function(item, search) {
    angular.forEach(item, function(input) {
      var exp, highlightedInput, normalInput, words;
      if (search) {
        words = "(" + search.split(/\ /).join(" |") + "|" + search.split(/\ /).join("|") + ")";
        exp = new RegExp(words, "gi");
        normalInput = input.label.slice(search.length);
        if (words.length) {
          highlightedInput = input.label.slice(0, search.length).replace(exp, "<span class=\"ng-typeahead-highlight\">$1</span>");
        }
        return input.html = $sce.trustAsHtml(highlightedInput + normalInput);
      }
    });
    return item;
  };
});
