# ng-typeahead
   A typeahead directive for AngularJS 1.3

# Requirements
   AngularJS 1.3

   Include the styles :) (feel free to edit those to your needs)

# Installation

  * clone/download this git repository and include ng-typeahead.js or ng-typeahead.min.js and the css file located in the dist folder.

  * or use npm to install this module

   `npm install ng-typeahead`  

# Demo and Documentation
[Demo page](http://raymondmuller.github.io/ng-typeahead)

# Simple usage
include the directive and its styles to your project and in your html

`<ng-typeahead ng-model="countries" data="countryData">`

at least include an ng-model and a data object with the following structure

`{
	"label": "one", 
	"value": 1
}`

The label is what is shown to the user.

The value object is where you can add other data that you might want to save later. You get the whole object back onSelect