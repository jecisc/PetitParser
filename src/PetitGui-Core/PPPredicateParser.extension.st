Extension { #name : #PPPredicateParser }

{ #category : #'*petitgui-mondrian' }
PPPredicateParser >> displayName [
	^ predicateMessage
]

{ #category : #'*petitgui-accessing' }
PPPredicateParser >> exampleOn: aStream [
	"Produce a random character that is valid. If there are characters in the alpha-numeric range prefer those over all others."

	| valid normal |
	valid := Character allCharacters
		select: [ :char | predicate value: char ].
	normal := valid
		select: [ :char | char asInteger < 127 and: [ char isAlphaNumeric ] ].
	aStream nextPut: (normal isEmpty
		ifTrue: [ valid atRandom ]
		ifFalse: [ normal atRandom ])
]