Object subclass: GtkNamespaceModel [
    | model sorted |

    initialize [
	<category: 'initialize-release'>

	sorted := false.
	self registerNotifier
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(SystemChangeNotifier uniqueInstance)
	    notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addEvent:';
	    notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeEvent:'
    ]

    isSorted [
	<category: 'testing'>

	^ sorted
    ]

    sorted: aBoolean [
	<category: 'accessing'>
	
	sorted := aBoolean
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString}.
	    self appendNamespace: Smalltalk to: nil.
	    model ]
    ]

    refresh [
	<category: 'model'>

	self gtkModel clear.
	self appendNamespace: Smalltalk to: nil
    ]

    appendNamespace: aNamespace to: parentGtkIter [
	<category: 'model builder'>

	
	| iter |
	iter := self gtkModel append: parentGtkIter item: {aNamespace displayString}.	

	aNamespace subspacesDo: [ :each |
	    self appendNamespace: each to: iter ]
    ]

    buildNamespaceArray: aNamespace [
	<category: 'item selection'>

	| result namespace |
        result := OrderedCollection new.
        namespace := aNamespace.
        [ namespace isNil ] whileFalse: [
            result add: namespace displayString.
            namespace := namespace superspace ].

	^ result
    ]

    buildNamespaceArray: aNamespace [
        <category: 'item selection'>

        | result namespace |
        result := OrderedCollection new.
        namespace := aNamespace.
        [ namespace isNil ] whileFalse: [
            result addFirst: namespace displayString.
            namespace := namespace superspace ].

        ^ result
    ]

    findIterInANamespace: aNamespace [
        <category: 'item selection'>

        | iter stack parent path |
        aNamespace = Smalltalk ifTrue: [ ^ self gtkModel getIterFirst ].

        stack := self buildNamespaceArray: aNamespace.
        iter := GTK.GtkTreeIter new.
	path := GTK.GtkTreePath newFirst.
        1 to: stack size do: [ :i | | each |
            each := stack at: i.
	    self gtkModel getIter: iter path: path.
            [each = (self gtkModel getOop: iter column: 0)] whileFalse: [
		path next.
		(self gtkModel getIter: iter path: path) ifFalse: [ self error: 'Namespace ', each , ' not found' ] ].
	    path down ].
        ^ iter
    ]

    at: aGtkIter column: aSmallInteger value: anObject [
	<category: 'item accessing'>

	self gtkModel setOop: aGtkIter column: aSmallInteger value: anObject
    ]

    append: aParentIter column: aSmallInteger value: anObject [
	<category: 'item accessing'>

	| iter |
	iter := GTK.GtkTreeIter new.
	(self gtkModel)
            append: iter parent: aParentIter;
            setOop: iter column: aSmallInteger value: anObject
    ]

    remove: aNamespace [
	<category: 'item removing'>

	 | iter |
        iter := self findIterInANamespace: aNamespace.
        self gtkModel remove: iter
    ]

    addEvent: anEvent [
	<category: 'model event'>

	self
	    append: (self findIterInANamespace: anEvent item superspace)
	    column: 0
	    value: anEvent item displayString
    ]

    removeEvent: anEvent [
	<category: 'model event'>

	self remove: anEvent item
    ]
]
