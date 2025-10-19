/**
 * CBWire Base Command Handler
 */
component accessors="true" {

	property name="utility"        inject="utility@cbwire-cli";
	property name="settings"       inject="box:modulesettings:cbwire-cli";
	property name="config"         inject="box:moduleconfig:cbwire-cli";
    
	property name="cliDefaults";
	property name="baseCliDefaults";
	property name="testHarnessServers";
	property name="testHarnessDirectoryName";
	property name="workingDirectory";
	property name="osType";
	property name="osPathSeperator";
	property name="cliDefaultLength" default="120";

	function init(){
		return this;
	}

	function onDIComplete() {
		variables.workingDirectory = getCWD();
		variables.osType = fileSystemUtil.isWindows() ? "windows" : "unix";
		variables.osPathSeperator = fileSystemUtil.isWindows() ? "\" : "/";
	}
 
	/***** UTILITY FUNCTIONS *****/

	function printInfo( required message ){
		variables.print
			.green1onDodgerBlue2( " INFO  " )
			.line( " #arguments.message#" );
	}

	function printError( required message ){
		variables.print.whiteOnRed2( " ERROR " ).line( " #arguments.message#" );
	}

	function printWarn( required message ){
		variables.print.blackOnWheat1( " WARN  " ).line( " #arguments.message#" );
	}

	function printSuccess( required message ){
		variables.print.blackOnSeaGreen2( " SUCCESS  " ).line( " #arguments.message#" );
	}

	function formatForCLI( value ) {
		var result = "";
		if ( isNull( value ) ) {
			result = "null";
		} else if ( isBoolean( value ) ) {
			result = value ? "true" : "false";
		} else if ( isNumeric( value ) || isDate( value ) ) {
			result = value;
		} else if ( isArray( value ) || isStruct( value ) ) {
			result = serializeJSON( value );
		} else if ( isSimpleValue( value ) ) {
			return len( value ) > 0 ? value : "[Empty String]";
		} else {
			result = "[Unknown Data Type]";
		}
		return result;
	}

	function cliDefaultsFromFile(){
		return deserializeJSON( fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' ) );
	}

	function cliDefaultsToFile( cliDefaultsStruct ){
		fileWrite( '#variables.settings.modulePath#/cbwireDefaults.json', formatterUtil.formatJson( cliDefaultsStruct ) );
	}

	function loadCLIDefaults(){
		// var rawJSON = fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' );
		print.line( "READING: #variables.settings.modulePath#/cbwireDefaults.json" );
		var theDefaults = deserializeJSON( fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' ) );
		print.tree( theDefaults );
		setCliDefaults( theDefaults );
		return getCliDefaults();
	}

	function loadBaseCLIDefaults(){
		// var rawJSON = fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' );
		print.line( "READING: #variables.settings.modulePath#/default.cbwireDefaults.json" );
		var baseDefaults = deserializeJSON( fileRead( '#variables.settings.modulePath#/default.cbwireDefaults.json' ) );
		setbaseCliDefaults( baseDefaults );
		return getbaseCliDefaults();
	}

	function verifyInTestHarnessDirectory(){
		var osPathSeperator = fileSystemUtil.isWindows() ? "\" : "/";
		variables.workingDirectory = getCWD();
		var testHarnessDirectory = variables.workingDirectory & variables.settings.testHarnessDirectoryName & variables.osPathSeperator;
		// verify in test harness directory, or change to it if it exists or error out
		if( listLast( variables.workingDirectory , variables.osPathSeperator, false ) == variables.settings.testHarnessDirectoryName ){
			print.line( "listLast: " & listLast( variables.workingDirectory , variables.osPathSeperator, false ) );
			printStyledMessage( "✅️ You are in the #variables.settings.testHarnessDirectoryName# directory!" );
			return true;
		}else if( directoryExists( testHarnessDirectory ) ){
			printStyledMessage(  "⚠️ You are not in the #variables.settings.testHarnessDirectoryName# directory, changing to it now..." );
			command( 'cd' ).params( testHarnessDirectory ).run();
			variables.workingDirectory = getCWD();
			if( getCWD() != testHarnessDirectory ){
					printStyledMessage( "❌ Failed to change directory to #variables.settings.testHarnessDirectoryName# directory" );
					return false;
			}
			printStyledMessage( "✅️ Successfully changed to #variables.settings.testHarnessDirectoryName# directory" );
			return true;
		}
		printStyledMessage([
			"❌ You are not in the #variables.settings.testHarnessDirectoryName# directory",
			"and could not find #variables.settings.testHarnessDirectoryName# directory in current working directory: #workingDirectory#"
		]);
		return false;
	}

	function verifyInRootDirectory(){
		var osPathSeperator = fileSystemUtil.isWindows() ? "\" : "/";
		variables.workingDirectory = getCWD();
		// are you in the test-harness directory?
		if( listLast( variables.workingDirectory , variables.osPathSeperator, false ) == variables.settings.testHarnessDirectoryName ){
			printStyledMessage(  "⚠️ You are not in the CBWIRE module root directory, attempting to change to it now..." );
			// move up one directory
			command( 'cd' ).params( ".." ).run();
			variables.workingDirectory = getCWD();
		}
		// read box.json file if exists to get module name and slug to verify in root
		if( fileExists( variables.workingDirectory & "box.json" ) ){
			var boxJson = deserializeJSON( fileRead( variables.workingDirectory & "box.json" ) );
			if( boxJson.keyExists( "slug" ) && boxJson.keyExists( "name" ) ){
				if( boxJson.slug == "cbwire" && boxJson.name == "CBWIRE" ){
					printStyledMessage( "✅️ You are in the CBWIRE module root directory!" );
					return true;
				}
			}
		}
		// not in root directory, print error
		printStyledMessage([
			"❌ You are not in the CBWIRE module root directory",
			"Please navigate to the root of the CBWIRE module and try again."
		]);
		return false;
	}

	function printCBWireCLIHeader( functionTitle="" ){
		print.boldColor178OnBlackLine( repeatString( "*", variables.cliDefaultLength ) ).toConsole();
		print.boldColor178OnBlackLine( centerStringWithStars() ).toConsole();
		print.boldColor178OnBlackLine( centerStringWithStars( "⚡️ CBWIRE-CLI ⚡️" ) ).toConsole();
		print.boldColor178OnBlackLine( centerStringWithStars( "An UN-Official CLI for CBWIRE" ) ).toConsole();
		if( len( arguments.functionTitle ) ){
			print.boldColor178OnBlackLine( centerStringWithStars() ).toConsole();
			print.boldColor178OnBlackLine( centerStringWithStars( arguments.functionTitle ) ).toConsole();
			print.boldColor178OnBlackLine( centerStringWithStars() ).toConsole();
		}
		print.boldColor178OnBlackLine( centerStringWithStars() ).toConsole();
		print.boldColor178OnBlackLine( repeatString( "*", variables.cliDefaultLength ) ).toConsole();
		print.line();
	}

	function printStyledMessage( message=[ "" ], justification="left", includeBlankLineTop=false, includeBlankLineBottom=false ){
		if( !isArray( arguments.message ) )
			arguments.message = [ arguments.message ];
		
		if( arguments.includeBlankLineTop )
			print.boldColor178OnBlackLine( repeatString( " ", variables.cliDefaultLength ) ).toConsole();

		for( var msg in arguments.message ){
			if( len( msg ) == 0 ){
				print.boldColor178OnBlackLine( repeatString( " ", variables.cliDefaultLength ) ).toConsole();
			}else if( arguments.justification == "center" ) {
				print.boldColor178OnBlackLine( centerString( msg ) ).toConsole();
			}else{
				print.boldColor178OnBlackLine( leftString( msg ) ).toConsole();
			}
		}

		if( arguments.includeBlankLineBottom )
			print.boldColor178OnBlackLine( repeatString( " ", variables.cliDefaultLength ) ).toConsole();

	}

	function centerStringWithStars( inputStr="" ) {
		var totalPadding = ( variables.cliDefaultLength - 2 ) - len( inputStr );
		// Ensure padding is non-negative
		if ( totalPadding < 0 ) return "*" &  left( inputStr, ( variables.cliDefaultLength - 5 ) ) & "...*";
		var leftPadding = repeatString(" ", floor(totalPadding / 2));
		var rightPadding = repeatString(" ", ceiling(totalPadding / 2));
		return "*" & leftPadding & inputStr & rightPadding & "*";
	}

	function centerString( inputStr="" ) {
		var totalPadding = variables.cliDefaultLength - len( inputStr );
		// Ensure padding is non-negative
		if ( totalPadding < 0 ) return left( inputStr, ( variables.cliDefaultLength - 3 ) ) & "...";
		var leftPadding = repeatString(" ", floor(totalPadding / 2));
		var rightPadding = repeatString(" ", ceiling(totalPadding / 2));
		return leftPadding & inputStr & rightPadding;
	}

	function leftString( str="" ) {
		var ellipsis = "...";
		if ( len( str ) > variables.cliDefaultLength ) {
			return left( str, variables.cliDefaultLength - len( ellipsis ) ) & ellipsis;
		} else {
			return str & repeatString( " ", variables.cliDefaultLength - len( str ) );
		}
	}

	function stopAllTestHarnessServers(){
		print.line();
		printStyledMessage( "⛔ Stopping any running #variables.settings.testHarnessDirectoryName# servers" );
		variables.testHarnessServers.each( function( key, value ) {
			command( 'server stop' )
				.params( serverConfigFile="#variables.workingDirectory##value.file#" )
				.run( returnOutput=true );
		});
		printStyledMessage( "✅️ Done Stopping any running #variables.settings.testHarnessDirectoryName# servers." );
		print.line();
	}

	function stopTestHarnessServer( serverKey ){
		print.line();
		printStyledMessage( "⛔ Stopping #variables.settings.testHarnessDirectoryName# server #variables.testHarnessServers[ serverKey ].name# if running" );
		command( 'server stop' )
			.params( serverConfigFile="#variables.workingDirectory##variables.testHarnessServers[ serverKey ].file#" )
			.run( returnOutput=true );
		printStyledMessage( "✅️ Done Stopping #variables.settings.testHarnessDirectoryName# server #variables.testHarnessServers[ serverKey ].name#." );
		print.line();
	}

	function getTestingServersConfig(){
		// determing if we are in the root cbwire module directory
		var osPathSeperator = fileSystemUtil.isWindows() ? "\" : "/";
		var workingDirectory = getCWD();
		var testHarnessDirPath = "";

		// are you in the cbwire module root directory?
		// read box.json file if exists to get module name and slug to verify in root
		if( fileExists( variables.workingDirectory & "box.json" ) ){
			var boxJson = deserializeJSON( fileRead( variables.workingDirectory & "box.json" ) );
			if( boxJson.keyExists( "slug" ) && boxJson.keyExists( "name" ) ){
				if( boxJson.slug == "cbwire" && boxJson.name == "CBWIRE" ){
					testHarnessDirPath = variables.workingDirectory & variables.osPathSeperator & variables.settings.testHarnessDirectoryName;
				}
			}
		}
		// are you in the test-harness directory?
		if( 
			len( testHarnessDirPath ) == 0 &&
			listLast( variables.workingDirectory , variables.osPathSeperator, false ) == variables.settings.testHarnessDirectoryName 
		){
			var testHarnessDirPath = getCWD();
		}
		if( len( testHarnessDirPath ) == 0 ){
			return {};
		}
		// get server-*.json files in test-harness directory
		var serverFiles = directoryList( testHarnessDirPath, false, "Name", "server-*.json", "asc", "file" );
		var serversConfig = {};
		for( var configFile in serverFiles ){
			var serverConfig = deserializeJSON( fileRead( testHarnessDirPath & variables.osPathSeperator & configFile ) );
			serversConfig[ serverConfig.app.cfengine ] = {
				"name" : serverConfig.name,
				"file" : configFile,
				"label" : "#getPrettyCFEngineName( serverConfig.app.cfengine )# ( #configFile# )"
			};
		}
		return serversConfig;
	}

	function getPrettyCFEngineName( cfEngine ){
		var prettyName = cfEngine;
		prettyName = replace( prettyName, "@", " ", "one" );
		prettyName = replace( prettyName, "adobe", "Adobe ColdFusion", "one" );
		prettyName = replace( prettyName, "lucee", "Lucee", "one" );
		prettyName = replace( prettyName, "boxlang", "BoxLang", "one" );
		return prettyName;
	}

	function loadTestingServersConfig(){
		variables.testHarnessServers = getTestingServersConfig();
		if( variables.testHarnessServers.keyArray().len() == 0 ){
			print.line();
			printWarn( "⚠️ No #variables.settings.testHarnessDirectoryName# servers found!" );
			printStyledMessage( "Please ensure you are in the cbwire module root directory or the #variables.settings.testHarnessDirectoryName# directory." );
			print.line();
			return false;
		}
		return true;
	}

}