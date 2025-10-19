component singleton {

	property name="moduleService"	inject="ModuleService";
	property name="wirebox"			inject="wirebox";
	property name="print"			inject="PrintBuffer";
	property name="settings"		inject="box:modulesettings:cbwire-cli";
	property name="config"			inject="box:moduleconfig:cbwire-cli";
	property name="formatterUtil"	inject="commandbox.system.util.Formatter";

	this.BREAK = chr( 13 ) & chr( 10 );
	this.TAB   = chr( 9 );
	this.cliDefaults = {};
	this.cliBaseDefaults = {};

	function onDIComplete() {
		lock name="cbwireLoadCliDefaults" timeout="2" {
			this.cliDefaults = cliDefaultsFromFile();
			this.cliBaseDefaults = cliBaseDefaultsFromFile();
		}
	}

	function loadFunctionArgsFromDefaults( rootKey, functionArgsStruct ){
		try {
			var currentCLIDefaults = structGet( "this.cliDefaults.#rootKey#" );
			if( !isStruct( currentCLIDefaults ) ){
				printError( "⚠️ No CLI defaults found for key: #rootKey#. Please check your spelling and try again." );
				return arguments.functionArgsStruct;
			}
			for( var k in currentCLIDefaults.keyArray() ){
				var currentValue = structGet( "currentCLIDefaults." & k );
				if( !isStruct( currentValue ) ){
					if( !arguments.functionArgsStruct.keyExists( k ) ){
						arguments.functionArgsStruct[ k ] = currentValue;
					}
				}
			}
			return arguments.functionArgsStruct;
		} catch (any e) {
			printError( "⚠️ Error Loading cbwire-cli defaults!" );
			return arguments.functionArgsStruct;
		}
	}

	function cliDefaultsFromFile(){
		return deserializeJSON( fileRead( '#variables.settings.modulePath#/cbwireDefaults.json' ) );
	}

	function cliDefaultsToFile( cliDefaultsStruct ){
		fileWrite( '#variables.settings.modulePath#/cbwireDefaults.json', formatterUtil.formatJson( cliDefaultsStruct ) );
	}

	function cliBaseDefaultsFromFile(){
		return deserializeJSON( fileRead( '#variables.settings.modulePath#/default.cbwireDefaults.json' ) );
	}

	function setCliDefaultKey( key, value ){
		setCliDefaultsValue(  arguments.key, arguments.value );
		// write back to file
		lock name="cbwireWriteCliDefaults" timeout="2" {
			cliDefaultsToFile( this.cliDefaults );
		}
	}

	function resetKeyToBaseDefault( key ){
		var baseDefaultValue = structGet( "this.cliBaseDefaults." & arguments.key );
		// set key
		setCliDefaultsValue( arguments.key, baseDefaultValue );
		// write back to file
		lock name="cbwireWriteCliDefaults" timeout="2" {
			cliDefaultsToFile( this.cliDefaults );
		}
		return;
	}

	function resetCliDefaultsToBaseDefaults(){
		lock name="cbwireWriteCliBaseDefaults" timeout="2" {
			var baseDefaults = cliBaseDefaultsFromFile();
			this.cliDefaults = baseDefaults;
			cliDefaultsToFile( this.cliDefaults );
		}
	}

    /**
     * Updates or creates a nested key in a structure using dot notation.
     * @param keyPath - Dot notation string (e.g., "user.profile.name")
     * @param value - Value to set
     */
    function setCliDefaultsValue( keyPath, value ) {
        var keys = listToArray( keyPath, "." );
        var current = this.cliDefaults;
        for ( var i = 1; i <= arrayLen(keys); i++ ) {
            var key = keys[i];
            // If it's the last key, set the value
            if ( i == arrayLen( keys ) ) {
                current[ key ] = value;
            } else {
                // If the key doesn't exist or isn't a struct, create it
                if (!structKeyExists( current, key ) || !isStruct( current[ key ] )) {
                    current[ key ] = {};
                }
                current = current[key];
            }
        }
    }

	/**
	 * Camel case a string using lower case for the first letter
	 *
	 * @target      The string to camel case
	 * @capitalized Whether or not to capitalize the first letter, default is false
	 */
	function camelCase( required target, boolean capitalized = false ){
		var results = arguments.capitalized ? arguments.target.left( 1 ).ucase() : arguments.target.left( 1 ).lCase();
		if ( arguments.target.len() > 1 ) {
			results &= arguments.target.right( -1 );
		}
		return results;
	}

	/**
	 * Camel case a string using upper case for the first letter
	 */
	function camelCaseUpper( required target ){
		return camelCase( arguments.target, true );
	}

	function formatAppMappingPath( path ){
		if( arguments.path == "/" || arguments.path == "\") arguments.path = "";
		if( len( arguments.path ) ){
			// add trailing slash if path is not empty and does not end with a slash
			if( len( arguments.path ) && right( arguments.path, 1 ) != "/" ){
				arguments.path = arguments.path & "/";
			}
			// Remove leading slashes if path starts with a slash
			if( len( arguments.path ) && left( arguments.path, 1 ) == "/" ){
				arguments.path = right( arguments.path, len( arguments.path ) - 1 );
			}
		}
		return arguments.path;
	}

	function formatWiresDirectoryPath( path ){
		if( arguments.path == "/" || arguments.path == "\") arguments.path = "";
		if( len( arguments.path ) ){
			// strip trailing slashes if path ends with a slash
			if( len( arguments.path ) && right( arguments.path, 1 ) == "/" ){
				var leftCount = len( arguments.path );
				if( len( arguments.path ) > 1 ) leftCount -= 1;
				arguments.path = left( arguments.path, leftPos )
			}
			// strip leading slashes if path starts with a slash
			if( len( arguments.path ) && left( arguments.path, 1 ) == "/" ){
				var rightCount = len( arguments.path );
				if( len( arguments.path ) > 1 ) rightCount -= 1;
				arguments.path = right( arguments.path, len( arguments.path ) - 1 );
			}
		}

		return arguments.path;
	}

}
