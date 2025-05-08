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

	function stripLeadingSlash( path ){
		return len( path ) &&  ( left( path, 1 ) == "/" ) ? right( path, len( path ) - 1 ) : path;
	}
	
	function addLeadingSlash( path ){
		return len( path ) &&  ( left( path, 1 ) != "/" ) ? "/" & path : path;
	}

	function stripTrailingSlash( path ){
		return len( path ) && ( right( path, 1 ) == "/" ) ? left( path, len( path ) - 1 ) : path;
	}

	function addTrailingSlash( path ){
		return len( path ) && ( right( path, 1 ) != "/" ) ? path & "/" : path;
	}

}
