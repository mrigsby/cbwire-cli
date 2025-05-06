/**
 *  Create a new wire in an existing ColdBox application.  Make sure you are running this command in the app root
 *  of your app for it to find the correct folder.  
 * .
 * {code:bash}
 * cbwire create wire myNewWire dataProp1,dataProp2,dataProp3 --open
 * {code}
 *
 **/
 component aliases="cbwire create cbwire" extends="cbwire-cli.models.BaseCommand" {

	static {
		HINTS = {
			index  : "Display a listing of the resource",
			new    : "Show the form for creating a new resource",
			create : "Store a newly created resource in storage",
			show   : "Display the specified resource",
			edit   : "Show the form for editing the specified resource",
			update : "Update the specified resource in storage",
			delete : "Remove the specified resource from storage"
		}
	}

	/**
	 * @name             String : Name of the wire to create without extensions. @module can be used to place in a module wires directory.
	 * @dataProps        String : A comma-delimited list of data property keys to add.
	 * @actions          String : A comma-delimited list of actions to generate
	 * @outerElement	 String : The outer element type to use for the wire. Defaults to "div"
	 * @jsWireRef		 Boolean : If true, the livewire:init & component.init hooks will be included and a reference to $wire will be created as window.wirename = $wire
	 * @lifeCycleEvents  String : A comma-delimited list of life cycle events to generate. If none provided, only onMount() will be generated.
	 * @onHydrateProps   String : A comma-delimited list of properties to create onHydrate() Property methods for in the wire.
	 * @onUpdateProps    String : A comma-delimited list of properties to create onUpdate() Property methods for in the wire.
	 * @wiresDirectory   String : The directory where your wires are stored. Defaults to standard `wires` directory.
	 * @appMapping       String : The root location of the application in the web root: ex: /MyApp or / if in the root
	 * @description      String : The wire component hint description
	 * @open             Boolean : If true open the wire component & template once generated
	 * @force            Boolean : If true force overwrite of existing wires
	 **/
	function run(
		required name,
		dataProps				= "",
		actions                 = "",
		outerElement			= "div",
		jsWireRef				= false,
		lifeCycleEvents			= "",
		onHydrateProps		 	= "",
		onUpdateProps			= "",
		wiresDirectory          = "wires",
		appMapping              = "/",
		description             = "Your wire description can go here!",
		boolean open            = false,
		boolean force           = false
	){
		// This will make each directory canonical and absolute
		arguments.wiresDirectory      = resolvePath( arguments.wiresDirectory );

		// TODO: Add a check to see if the directory is a module or not, verify module exists, and adjust the path accordingly

		// Validate wiresDirectory
		if ( !directoryExists( arguments.wiresDirectory ) ) {
			directoryCreate( arguments.wiresDirectory );
		}

		// Allow dot-delimited paths
		arguments.name = replace( arguments.name, ".", "/", "all" );

		/*******************************************************************
		 * Read in Templates
		 *******************************************************************/

		// primaries
		var wireComponent = fileRead( "#variables.settings.templatesPath#/wires/wireComponent.txt" );
		var wireTemplate = fileRead( "#variables.settings.templatesPath#/wires/wireTemplate.txt" );

		// Template Parts
		var jsInitCode = fileRead( "#variables.settings.templatesPath#/wires/template-parts/jsInit.txt" );

		// build wire template
		var wireTemplate = replaceNoCase(
			wireTemplate,
			"|outerElementType|",
			arguments.outerElement,
			"all"
		);

		if( arguments.jsWireRef ){
			jsInitCode = replaceNoCase(
				jsInitCode,
				"|wireName|",
				arguments.name,
				"all"
			);
			wireTemplate = replaceNoCase(
				wireTemplate,
				"|wireJSInit|",
				jsInitCode,
				"all"
			);
		}else{
			wireTemplate = replaceNoCase(
				wireTemplate,
				"|wireJSInit|",
				"",
				"all"
			);
		}

		// Build Component : |wireDescription|, |dataProperties|, |actions|, |lifeCycleMethods|
		wireComponent = replaceNoCase(
			wireComponent,
			"|wireDescription|",
			arguments.description,
			"all"
		);

		wireComponent = buildData( wireComponent, arguments.dataProps );
		wireComponent = buildActions( wireComponent, arguments.actions );
		wireComponent = buildLifeCycleMethods( wireComponent, arguments.lifeCycleEvents, arguments.onHydrateProps, arguments.onUpdateProps );


		// Create dir if it doesn't exist
		var wireComponentPath = resolvePath( "#arguments.wiresDirectory#/#arguments.name#.cfc" );
		var wireTemplatePath = resolvePath( "#arguments.wiresDirectory#/#arguments.name#.cfm" );

		directoryCreate(
			getDirectoryFromPath( wireComponentPath ),
			true,
			true
		);

		// Confirm it or Force it
		if (
			fileExists( wireComponentPath ) && !arguments.force && !confirm(
				"The file '#getFileFromPath( wireComponentPath )#' already exists, overwrite it (y/n)?"
			)
		) {
			printWarn( "Exiting..." );
			return;
		}
		if (
			fileExists( wireTemplatePath ) && !arguments.force && !confirm(
				"The file '#getFileFromPath( wireTemplatePath )#' already exists, overwrite it (y/n)?"
			)
		) {
			printWarn( "Exiting..." );
			return;
		}

		// Write out the files
		file action="write" file="#wireComponentPath#" mode="777" output="#wireComponent#";
		printInfo( "Created Wire Component [#wireComponentPath#]" );

		file action="write" file="#wireTemplatePath#" mode="777" output="#wireTemplate#";
		printInfo( "Created Wire Template [#wireTemplatePath#]" );

		// open file
		if ( arguments.open ) {
			openPath( wireComponentPath );
			openPath( wireTemplatePath );
		}
	}

	function buildData( wireComponent, dataProps ){	
		// Build data properties
		var dataProperties = fileRead( "#variables.settings.templatesPath#/wires/component-parts/dataProperties.txt" );
		var dataPropertyKeysContent = "";

		if( len( arguments.dataProps ) ){
			var dataPropertyKeys = listToArray( arguments.dataProps );
			for ( var i = 1; i <= dataPropertyKeys.len(); i++ ) {
				dataPropertyKeysContent &= '#utility.TAB##utility.TAB#"#dataPropertyKeys[i]#" : ""';
				if( i < dataPropertyKeys.len() ) dataPropertyKeysContent &= ",#utility.BREAK#";
			}
		}else{
			dataPropertyKeysContent = '#utility.TAB##utility.TAB#// "myDataPropKey" : "My Data Prop Value"';
		}
		dataProperties = replaceNoCase(
			dataProperties,
			"|dataPropertyKeys|",
			dataPropertyKeysContent,
			"all"
		);
		return replaceNoCase(
			wireComponent,
			"|dataProperties|",
			dataProperties,
			"all"
		);
	}

	function buildActions( wireComponent, actions ){
		var actionContent = fileRead( "#variables.settings.templatesPath#/wires/component-parts/actionContent.txt" );
		var generatedActions = "";
		if( len( arguments.actions ) ){
			var actionKeys = listToArray( arguments.actions );
			for ( var i = 1; i <= actionKeys.len(); i++ ) {
				generatedActions &= replaceNoCase(
					actionContent,
					"|action|",
					actionKeys[i],
					"all"
				);
			}
		}else{
			generatedActions = "#utility.TAB#// Define your actions here#utility.BREAK#";
		}
		return replaceNoCase(
			wireComponent,
			"|actions|",
			generatedActions,
			"all"
		);
	}

	function buildLifeCycleMethods( wireComponent, lifeCycleEvents, onHydrateProps, onUpdateProps ){
		// Lifecycle events
		var eventOnHydrate = fileRead( "#variables.settings.templatesPath#/wires/component-parts/lifecycle-methods/onHydrate.txt" );
		var eventOnMount = fileRead( "#variables.settings.templatesPath#/wires/component-parts/lifecycle-methods/onMount.txt" );
		var eventOnRender = fileRead( "#variables.settings.templatesPath#/wires/component-parts/lifecycle-methods/onRender.txt" );
		var eventOnUpdate = fileRead( "#variables.settings.templatesPath#/wires/component-parts/lifecycle-methods/onUpdate.txt" );

		var lifeCycleMethods = "";
		if( len( arguments.lifeCycleEvents ) ){
			var lifeCycleEvents = listToArray( arguments.lifeCycleEvents );
			for ( var i = 1; i <= lifeCycleEvents.len(); i++ ) {
				switch( lifeCycleEvents[i] ){
					case "onHydrate":
						lifeCycleMethods &= replaceNoCase(
							eventOnHydrate,
							"|dataProperty|",
							"",
							"all"
						);
						break;
					case "onMount":
						lifeCycleMethods &= eventOnMount;
						break;
					case "onRender":
						lifeCycleMethods &= eventOnRender;
						break;
					case "onUpdate":
						lifeCycleMethods &= replaceNoCase(
							eventOnUpdate,
							"|dataProperty|",
							"",
							"all"
						);
						break;
					default:
						printError( "Unknown lifecycle event: #lifeCycleEvents[i]#" );
				}
			}
		}else{
			lifeCycleMethods &= eventOnMount;
		}
		if( len( arguments.onHydrateProps ) ){
			var onHydrateProps = listToArray( arguments.onHydrateProps );
			for ( var i = 1; i <= onHydrateProps.len(); i++ ) {
				lifeCycleMethods &= replaceNoCase(
					eventOnHydrate,
					"|dataProperty|",
					utility.camelCaseUpper(onHydrateProps[i]),
					"all"
				);
			}
		}
		if( len( arguments.onUpdateProps ) ){
			var onUpdateProps = listToArray( arguments.onUpdateProps );
			for ( var i = 1; i <= onUpdateProps.len(); i++ ) {
				lifeCycleMethods &= replaceNoCase(
					eventOnUpdate,
					"|dataProperty|",
					utility.camelCaseUpper(onUpdateProps[i]),
					"all"
				);
			}
		}
		return replaceNoCase(
			wireComponent,
			"|lifeCycleMethods|",
			lifeCycleMethods,
			"all"
		);

	}

}
