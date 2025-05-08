component singleton {

	// DI
	property name="moduleService" inject="ModuleService";
	property name="wirebox"       inject="wirebox";
	property name="print"         inject="PrintBuffer";

	this.BREAK = chr( 13 ) & chr( 10 );
	this.TAB   = chr( 9 );

	/**
	 * Camel case a string using lower case for the first letter
	 *
	 * @target      The string to camel case
	 * @capitalized Whether or not to capitalize the first letter, default is false
	 */
	function camelCase(
		required target,
		boolean capitalized = false
	){
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
