/**
 *  Create a new wire in an existing ColdBox application.  Make sure you are running this command in the app root
 *  of your app for it to find the correct folder.  
 * .
 * {code:bash}
 * cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething"
 * {code}
 *
 **/
 component aliases="create wire,wire create" extends="cbwire-cli.models.BaseCommand" {

	static {
		HINTS = { create : "Creates a new wire in the application" }
	}

	/**
	 * @name             String : Name of the wire to create without extensions. @module can be used to place in a module wires directory.
	 * @dataProps        String : A comma-delimited list of data property keys to add.
	 * @lockedDataProps	 String : A comma-delimited list of data property keys to lock.
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
	 * @singleFileWire	 Boolean : If true creates a single file wire
	 **/
	function run(
		required name,
		dataProps				= "",
		lockedDataProps			= "",
		actions                 = "",
		outerElement			= "div",
		jsWireRef				= false,
		lifeCycleEvents			= "",
		onHydrateProps		 	= "",
		onUpdateProps			= "",
		wiresDirectory          = "wires",
		appMapping              = "/",
		description             = "This wire was created by the cbwire CLI! Please update me!",
		boolean open            = false,
		boolean force           = false,
		boolean singleFileWire  = false
	){
		var moduleName = "";
		// check for module in name and handle finding module directory, path and setting name properly
		if( find( "@", arguments.name ) ){
			moduleName = listLast( arguments.name, "@" );
			arguments.wiresDirectory = getModuleWiresDirectory( moduleName, arguments.wiresDirectory, arguments.appMapping );
			if( arguments.wiresDirectory == "MODULE_PATH_NOT_FOUND" ) return;
			arguments.name = listFirst( arguments.name, "@" );
		}
		
		// Allow dot-delimited paths
		arguments.name = replace( arguments.name, ".", "/", "all" );
		
		// Build Template
		var wireTemplate = buildWireTemplate( arguments.name, arguments.outerElement, arguments.jsWireRef );

		// Build Component 
		var wireComponent	= fileRead( "#variables.settings.templatesPath#/wires/wireComponent.txt" );
		wireComponent 		= buildData( wireComponent, arguments.dataProps );
		wireComponent 		= buildLockedData( wireComponent, arguments.lockedDataProps );
		wireComponent 		= buildActions( wireComponent, arguments.actions );
		wireComponent 		= buildLifeCycleMethods( wireComponent, arguments.lifeCycleEvents, arguments.onHydrateProps, arguments.onUpdateProps );

		// set template path and create dir if it doesn't exist
		var wireTemplatePath = resolvePath( "#arguments.wiresDirectory#/#arguments.name#.cfm" );
		directoryCreate( getDirectoryFromPath( wireTemplatePath ), true, true );

		if ( fileExists( wireTemplatePath ) && !arguments.force && !confirm( "The file '#wireTemplatePath#' already exists, overwrite it (y/n)?" ) ) {
			printWarn( "Exiting..." );
			return;
		}

		if( arguments.singleFileWire ){
			// Build single file wire by updating the component to cfscript with @startWire and @endWire and inserting into the wire template			
			wireComponent = replaceNoCase( 
				fileRead( "#variables.settings.templatesPath#/wires/component-parts/singleFileWireScript.txt" ), 
				"|wireComponentContent|",
				wireComponent, 
				"all" 
			);
			// update description in singleFileWireScript.txt template
			wireComponent = replaceNoCase( wireComponent, "|wireDescription|", arguments.description, "all" );
			// insert into wire template
			wireTemplate = replaceNoCase( wireTemplate, "|singeFileWireComponent|", utility.BREAK & utility.BREAK & wireComponent, "all" );
		}else{
			wireComponent = replaceNoCase( 
				fileRead( "#variables.settings.templatesPath#/wires/component-parts/wireComponentWrapper.txt" ), 
				"|wireComponentContent|",
				wireComponent, 
				"all" 
			);
			// update description in wireComponentWrapper.txt template
			wireComponent = replaceNoCase( wireComponent, "|wireDescription|", arguments.description, "all" );
			// clear single file component placeholder in template
			wireTemplate = replaceNoCase( wireTemplate, "|singeFileWireComponent|", "", "all" );
			// set component and template paths and create dir if it doesn't exist
			var wireComponentPath = resolvePath( "#arguments.wiresDirectory#/#arguments.name#.cfc" );
		}

		// Confirm it or Force it
		if ( fileExists( wireTemplatePath ) && !arguments.force && !confirm( "The file '#wireTemplatePath#' already exists, overwrite it (y/n)?" ) ) {
			printWarn( "Exiting..." );
			return;
		}
		// Write out only the template file because the component was injected into the template
		file action="write" file="#wireTemplatePath#" mode="777" output="#wireTemplate#";
		printInfo( "Created Wire Template [#wireTemplatePath#]" );

		// if not single wire we need to write out the component file
		if( !arguments.singleFileWire ){
			// Confirm it or Force it
			if ( fileExists( wireComponentPath ) && !arguments.force && !confirm( "The file '#wireComponentPath#' already exists, overwrite it (y/n)?" ) ) {
				printWarn( "Exiting..." );
				return;
			}
			// Write out the component and template files
			file action="write" file="#wireComponentPath#" mode="777" output="#wireComponent#";
			printInfo( "Created Wire Component [#wireComponentPath#]" );
		}

		// open file(s) ?
		if ( arguments.open ) {
			if( !arguments.singleFileWire ){
				openPath( wireComponentPath );
			}
			openPath( wireTemplatePath );
		}

	}

	function buildData( wireComponent, dataProps ){	
		// Build data properties
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
		var dataProperties = replaceNoCase(
			fileRead( "#variables.settings.templatesPath#/wires/component-parts/dataProperties.txt" ),
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

	function buildLockedData( wireComponent, lockedDataProps ){
		if( len( arguments.lockedDataProps ) ){
			return replaceNoCase(
				wireComponent,
				"|lockedDataProperties|",
				"#utility.BREAK##utility.TAB#locked = " & serializeJSON( listToArray( arguments.lockedDataProps ) ) & ";#utility.BREAK#",
				"all"
			);
		}else{
			return replaceNoCase( wireComponent, "|lockedDataProperties|", "", "all" );
		}
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
				if( i < actionKeys.len() ) generatedActions &= utility.BREAK;
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
						lifeCycleMethods &= replaceNoCase( eventOnHydrate, "|dataProperty|", "", "all" );
						break;
					case "onMount":
						lifeCycleMethods &= eventOnMount;
						break;
					case "onRender":
						lifeCycleMethods &= eventOnRender;
						break;
					case "onUpdate":
						lifeCycleMethods &= replaceNoCase( eventOnUpdate, "|dataProperty|", "", "all" );
						break;
					default:
						printError( "Unknown lifecycle event: #lifeCycleEvents[i]#" );
				}
				if( i < lifeCycleEvents.len() || len( arguments.onHydrateProps ) ) lifeCycleMethods &= utility.BREAK;
			}
		}else{
			lifeCycleMethods &= "#utility.TAB#/*#utility.BREAK#" & eventOnMount & "#utility.TAB#*/#utility.BREAK#";
		}
		// add onHydrate specific data properties methods in the lifecycle events
		if( len( arguments.onHydrateProps ) ){
			var onHydrateProps = listToArray( arguments.onHydrateProps );
			for ( var i = 1; i <= onHydrateProps.len(); i++ ) {
				lifeCycleMethods &= replaceNoCase( eventOnHydrate, "|dataProperty|", utility.camelCaseUpper(onHydrateProps[i]), "all" );
				if( i < onHydrateProps.len()  || len( arguments.onUpdateProps ) ) lifeCycleMethods &= utility.BREAK;
			}
		}
		// add onUpdate specific data properties methods in the lifecycle events
		if( len( arguments.onUpdateProps ) ){
			var onUpdateProps = listToArray( arguments.onUpdateProps );
			for ( var i = 1; i <= onUpdateProps.len(); i++ ) {
				lifeCycleMethods &= replaceNoCase( eventOnUpdate, "|dataProperty|", utility.camelCaseUpper(onUpdateProps[i]), "all" );
				if( i < onUpdateProps.len() ) lifeCycleMethods &= utility.BREAK;
			}
		}
		return replaceNoCase( wireComponent, "|lifeCycleMethods|", lifeCycleMethods, "all" );
	}

	function buildWireTemplate( name, outerElement, jsWireRef ){
		// build wire template
		var wireTemplate = replaceNoCase(
			fileRead( "#variables.settings.templatesPath#/wires/wireTemplate.txt" ),
			"|outerElementType|",
			arguments.outerElement,
			"all"
		);
		if( arguments.jsWireRef ){
			var jsInitCode = replaceNoCase(
				fileRead( "#variables.settings.templatesPath#/wires/template-parts/jsInit.txt" ),
				"|wireName|",
				arguments.name,
				"all"
			);
			return replaceNoCase( wireTemplate, "|wireJSInit|", jsInitCode, "all" );
		}else{
			return replaceNoCase( wireTemplate, "|wireJSInit|", "", "all" );
		}
	}

	function getModuleWiresDirectory( moduleName, wiresDirectory, appMapping ){
		// add trailing slash if not present
		if( len( arguments.appMapping ) && right( arguments.appMapping, 1 ) != "/" )
			arguments.appMapping &= "/";

		if( directoryExists( resolvePath( "#arguments.appMapping#modules_app/#moduleName#" ) ) )
			return "#arguments.appMapping#modules_app/#moduleName#/#wiresDirectory#";
		
		if( directoryExists( resolvePath( "#arguments.appMapping#modules/#moduleName#" ) ) )
			return "#arguments.appMapping#modules/#moduleName#/#wiresDirectory#";

		printError( "Module '#moduleName#' not found! Exiting..." );
		return "MODULE_PATH_NOT_FOUND";
	}

}
