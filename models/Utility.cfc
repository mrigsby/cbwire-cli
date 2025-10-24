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

	/**
	 * Converts a string into basic ASCII art and centers each line to a specified line length.
	 * @param inputText The string to convert.
	 * @param lineLength The total width of each output line.
	 * @return Array of strings representing centered ASCII art lines.
	 */
	function generateAsciiArt(inputText, lineLength) {
		var asciiMap = {
			"A": ["  A  ", " A A ", "AAAAA", "A   A", "A   A"],
			"B": ["BBBB ", "B   B", "BBBB ", "B   B", "BBBB "],
			"C": [" CCCC", "C    ", "C    ", "C    ", " CCCC"],
			"D": ["DDDD ", "D   D", "D   D", "D   D", "DDDD "],
			"E": ["EEEEE", "E    ", "EEE  ", "E    ", "EEEEE"],
			"F": ["FFFFF", "F    ", "FFF  ", "F    ", "F    "],
			"G": [" GGG ", "G    ", "G GGG", "G   G", " GGG "],
			"H": ["H   H", "H   H", "HHHHH", "H   H", "H   H"],
			"I": ["IIIII", "  I  ", "  I  ", "  I  ", "IIIII"],
			"J": ["JJJJJ", "   J ", "   J ", "J  J ", " JJ  "],
			"K": ["K   K", "K  K ", "KKK  ", "K  K ", "K   K"],
			"L": ["L    ", "L    ", "L    ", "L    ", "LLLLL"],
			"M": ["M   M", "MM MM", "M M M", "M   M", "M   M"],
			"N": ["N   N", "NN  N", "N N N", "N  NN", "N   N"],
			"O": [" OOO ", "O   O", "O   O", "O   O", " OOO "],
			"P": ["PPPP ", "P   P", "PPPP ", "P    ", "P    "],
			"Q": [" QQQ ", "Q   Q", "Q Q Q", "Q  Q ", " QQ Q"],
			"R": ["RRRR ", "R   R", "RRRR ", "R R  ", "R  RR"],
			"S": [" SSS ", "S    ", " SSS ", "    S", " SSS "],
			"T": ["TTTTT", "  T  ", "  T  ", "  T  ", "  T  "],
			"U": ["U   U", "U   U", "U   U", "U   U", " UUU "],
			"V": ["V   V", "V   V", "V   V", " V V ", "  V  "],
			"W": ["W   W", "W   W", "W W W", "WW WW", "W   W"],
			"X": ["X   X", " X X ", "  X  ", " X X ", "X   X"],
			"Y": ["Y   Y", " Y Y ", "  Y  ", "  Y  ", "  Y  "],
			"Z": ["ZZZZZ", "   Z ", "  Z  ", " Z   ", "ZZZZZ"],
			"-": ["     ", "     ", " --- ", "     ", "     "],
			" ": ["     ", "     ", "     ", "     ", "     "],
			"1": ["  1  ", " 11  ", "  1  ", "  1  ", "11111"],
			"2": [" 222 ", "2   2", "   2 ", "  2  ", "22222"],
			"3": ["33333", "    3", " 333 ", "    3", "33333"],
			"4": ["4  4 ", "4  4 ", "44444", "   4 ", "   4 "],
			"5": ["55555", "5    ", "5555 ", "    5", "5555 "],
			"6": [" 666 ", "6    ", "6666 ", "6   6", " 666 "],
			"7": ["77777", "    7", "   7 ", "  7  ", " 7   "],
			"8": [" 888 ", "8   8", " 888 ", "8   8", " 888 "],
			"9": [" 999 ", "9   9", " 9999", "    9", " 999 "],
			"0": [" 000 ", "0   0", "0   0", "0   0", " 000 "]
		};
		var lines = ["", "", "", "", ""];
		inputText = uCase( inputText );
		// Build ASCII art lines
		for (var i = 1; i <= len( inputText ); i++) {
			var char = mid( inputText, i, 1 );
			if (!asciiMap.keyExists( char ) ) {
				char = " ";
			}
			for ( var j = 1; j <= 5; j++ ) {
				lines[ j ] &= asciiMap[ char ][ j ] & " ";
			}
		}
		// Center each line based on lineLength
		var centeredLines = [];
		for ( var line in lines ) {
			var padding = int( ( lineLength - len( line ) ) / 2 );
			if ( padding < 0 ) {
				padding = 0;
			}
			var centered = repeatString( " ", padding ) & line;
			centered = left( centered, lineLength ); // trim if too long
			// add extra spaces if still short
			if(  len( centered ) < lineLength ){
				centered &= repeatString( " ", lineLength - len( centered ) );
			}
			centeredLines.append( centered );
		}
		return centeredLines;
	}

}
