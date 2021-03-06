Extension { #name : #PPParser }

{ #category : #'*PetitGui' }
PPParser >> backgroundForDepth: anInteger [
	^ Color gray: 1.0 - (anInteger / 20.0)
]

{ #category : #'*PetitGui' }
PPParser >> debug: anObject [
	"Parse anObject with the receiving parser and answer the parse-result or an instance of PPFailure."
	
	^ self enableDebug parse: anObject asPetitStream
]

{ #category : #'*PetitGui' }
PPParser >> displayColor [
	^ self isTerminal
		ifTrue: [ Color r: 0.5 g: 0.0 b: 0.5 ]
		ifFalse: [ Color blue ]
]

{ #category : #'*PetitGui' }
PPParser >> example [
	^ String streamContents: [ :stream | self exampleOn: stream ] limitedTo: 1024
]

{ #category : #'*PetitGui' }
PPParser >> exampleOn: aStream [
]

{ #category : #'*petitgui' }
PPParser >> gtAllParsersIn: composite [
	<gtInspectorPresentationOrder: 50>

	composite roassal2
		title: 'Graph'; 
		initializeView: [ RTMondrian new ];
		painting: [ :view |
			self viewAllParsersOn: view.	
		].
]

{ #category : #'*petitgui' }
PPParser class >> gtExampleCharactersParser [
	<gtExample>
	<label: 'Characters parser'>
	
	^ ($a to: $z) asParser
]

{ #category : #'*petitgui' }
PPParser class >> gtExampleEmptyParser [
	<gtExample>
	<label: 'Empty parser'>
	
	^ self new
]

{ #category : #'*PetitGui' }
PPParser >> morphicProduction [
	^ self newRowMorph
		layoutInset: 4;
		addMorphBack: (self newRowMorph
			layoutInset: 4;
			addMorphBack: (StringMorph new
				contents: self displayName;
				emphasis: TextEmphasis bold emphasisCode;
				yourself);
			yourself);
		addMorphBack: (self morphicShapeSeen: IdentitySet new depth: 0);
		addMorphBack: (self newColumnMorph
			addMorphBack: (self newSpacerMorph);
			addMorphBack: (LineMorph from: 0 @ 0 to: 20 @ 0 color: Color black width: 1)	
				makeForwardArrow;
			yourself);
		yourself
]

{ #category : #'*PetitGui' }
PPParser >> morphicShapeDefault [
	^ self newRowMorph
		addMorphBack: (self newColumnMorph
			addMorphBack: (self newSpacerMorph);
			addMorphBack: (LineMorph from: 0 @ 0 to: 20 @ 0 color: Color black width: 1)	
				makeForwardArrow;
			yourself);
		addMorphBack: (self newRowMorph
			borderWidth: 1;
			layoutInset: 3;
			color: Color white;
			addMorphBack: (StringMorph new
				contents: self displayName;
				color: self displayColor;
				yourself);
			yourself);
		yourself
]

{ #category : #'*PetitGui' }
PPParser >> morphicShapeSeen: aSet depth: anInteger [
	^ self morphicShapeDefault
]

{ #category : #'*PetitGui' }
PPParser >> morphicShapeSeen: aSet depth: anInteger do: aBlock [
	" avoid recursion "
	(aSet includes: self)
		ifTrue: [ ^ self morphicShapeDefault ].
	" display nice name when possible "
	(anInteger > 0 and: [ self name notNil ]) 
		ifTrue: [ ^ self morphicShapeDefault ].
	" don't do it too deep "
	(anInteger > 10)
		ifTrue: [ ^ self morphicShapeDefault ].
	aSet add: self. 
	^ aBlock value: [ :parser |
		parser 
			morphicShapeSeen: aSet 
			depth: anInteger + 1 ]
]

{ #category : #'*PetitGui' }
PPParser >> namedParsers [
    | result |
    result := OrderedCollection new.
    self namedParsersDo: [ :parser | result addLast: parser ].
    ^ result
]

{ #category : #'*PetitGui' }
PPParser >> namedParsersDo: aBlock [
    self namedParsersDo: aBlock seen: IdentitySet new
]

{ #category : #'*PetitGui' }
PPParser >> namedParsersDo: aBlock seen: aSet [
    self children do: [ :each | 
        (aSet includes: each)
            ifFalse: [
		        aSet add: each.
		        each name isEmptyOrNil
		            ifFalse: [ aBlock value: each ]
		            ifTrue: [ each namedParsersDo: aBlock seen: aSet ] ] ]
]

{ #category : #'*PetitGui' }
PPParser >> newColumnMorph [
	^ AlignmentMorph newColumn
		cellPositioning: #topLeft;
		color: Color transparent;
		listCentering: #topLeft;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		layoutInset: 0;
		yourself
]

{ #category : #'*PetitGui' }
PPParser >> newRowMorph [
	^ AlignmentMorph newRow
		cellPositioning: #topLeft;
		color: Color transparent;
		listCentering: #topLeft;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		layoutInset: 0;
		yourself
]

{ #category : #'*PetitGui' }
PPParser >> newSpacerMorph [
	^ Morph new
		color: Color transparent;
		borderWidth: 0;
		extent: 7 @ 7;
		yourself
]

{ #category : #'*PetitGui' }
PPParser >> viewAllNamedParsers [
	"
	PPSmalltalkParser new viewAllNamedParsers
	"
	| view |
	view := RTMondrian new.
	self viewAllNamedParsersWithSelection: {} on: view.
	^ view openWithToolbarEntitled: 'All named parsers'
]

{ #category : #'*PetitGui' }
PPParser >> viewAllNamedParsersWithSelection: aCollectionOfNames on: view [
	self viewAllNamedParsersWithSelection: aCollectionOfNames previewing: [ :each | each name ] on: view
]

{ #category : #'*PetitGui' }
PPParser >> viewAllNamedParsersWithSelection: aCollectionOfNames previewing: aBlock on: view [
	| l |
	view shape label
		color: [ :each | 
					(aCollectionOfNames includes: each name)
						ifFalse: [ Color black ]
						ifTrue: [ Color red ] ];
		text: [ :each | each displayName ].
	view interaction popupText: aBlock.
	view interaction item: 'Explore' action: #explore.
	view nodes: (self allParsers reject: [ :each | each name isEmptyOrNil ]).
	view edges
		source: (self allParsers reject: [ :each | each name isEmptyOrNil ]) connectFrom: #yourself toAll: #namedParsers.
	l := view layout horizontalDominanceTree.
	l verticalGap: 10;
		layered
]

{ #category : #'*PetitGui' }
PPParser >> viewAllParsers [

	"
	PPSmalltalkParser new viewAllParsers
	"
	| view |
	view := RTMondrian new.
	self viewAllParsersOn: view.
	view openWithToolbarEntitled: 'All parsers'.
	^ view
]

{ #category : #'*PetitGui' }
PPParser >> viewAllParsersOn: view [

	view shape label 
		height: 10;
		text: [ :each | 
			| labels |
			labels := OrderedCollection new.
			each name notNil ifTrue: [ labels add: each name ].
			each visualizationGraphType notNil ifTrue: [ labels add: each visualizationGraphType ].
			labels asArray ];
		if: [ :p | p name isNil ] fillColor: Color lightGray.
	view nodes: self allParsers.
	view edges connectToAll: #children.	
	view treeLayout
]

{ #category : #'*PetitGui' }
PPParser >> visualizationGraphType [
	^ nil
]
