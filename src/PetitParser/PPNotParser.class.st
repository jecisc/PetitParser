"
The not-predicate, a parser that succeeds whenever its delegate does not, but consumes no input [Parr 1994, 1995].
"
Class {
	#name : #PPNotParser,
	#superclass : #PPDelegateParser,
	#category : #'PetitParser-Parsers'
}

{ #category : #parsing }
PPNotParser >> parseOn: aStream [
	| element position |
	position := aStream position.
	element := parser parseOn: aStream.
	aStream position: position.
	^ element isPetitFailure
		ifFalse: [ PPFailure message: '' at: aStream position ]
]