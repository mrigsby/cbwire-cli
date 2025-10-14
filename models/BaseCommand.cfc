/**
 * CBWire Base Command Handler
 */
component accessors="true" {

	// DI
	property name="utility"        inject="utility@cbwire-cli";
	property name="settings"       inject="box:modulesettings:cbwire-cli";
	property name="config"         inject="box:moduleconfig:cbwire-cli";
	// property name="serverService"  inject="serverService";
	// property name="packageService" inject="PackageService";

	function init(){
		return this;
	}

	function printInfo( required message ){
		variables.print
			.green1onDodgerBlue2( " INFO  " )
			.line( " #arguments.message#" )
			.line();
	}

	function printError( required message ){
		variables.print
			.whiteOnRed2( " ERROR " )
			.line( " #arguments.message#" )
			.line();
	}

	function printWarn( required message ){
		variables.print
			.blackOnWheat1( " WARN  " )
			.line( " #arguments.message#" )
			.line();
	}

	function printSuccess( required message ){
		variables.print
			.blackOnSeaGreen2( " SUCCESS  " )
			.line( " #arguments.message#" )
			.line();
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
			result = "'" & value & "'";
		} else {
			result = "[Unknown Type]";
		}
		return result;
	}

	function getCLIDefaults(){
		// var rawJSON = fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' );
		return deserializeJSON( fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' ) );
	}

	function getBaseCLIDefaults(){
		// var rawJSON = fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' );
		return deserializeJSON( fileRead( '#variables.settings.modulePath#/default.cbwireDefaults.json' ) );
	}


}
