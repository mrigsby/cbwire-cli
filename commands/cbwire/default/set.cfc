 /**
 * CBWire CLI Default Set Command
 * This command allows you to set the default values for the various
 * options available when creating a new wire via the CLI.
 * .
 * {code:bash}
 * cbwire default set create.boxlang true
 * cbwire default set create.singleFileWire false
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {
    
    property name="cliDefaults";

	/**
	 * @key String : The specific key to set (uses dot notation I.E. create.singleFileWire).
     * @value String|Boolean|numeric : The value to set the key value to.
	 **/
	function run( required key, required value ){
        variables.cliDefaults = getCLIDefaults();
        try {
            var keyValue = structGet( "variables.cliDefaults.#arguments.key#" );
            if( isStruct( keyValue ) ){
                printError( "  #arguments.key# is a set of defaults and cannot be set all at once!" );
                printError( "  Please specify a specific key to set. Example: cbwire set default create.jsWireRef true" );
                return;
            }
            printInfo( "  Setting default value for key: #arguments.key#" );
            printInfo( "  Current Value: #formatForCLI( keyValue )#" );
            setNestedStructValue( arguments.key, arguments.value );
            // write back to file
            fileWrite( '#variables.settings.modulePath#/cbwireDefaults.json', formatterUtil.formatJson( variables.cliDefaults ) );
            printSuccess( "  Success!" );
            printSuccess( "  Updated Value: #formatForCLI( structGet( "variables.cliDefaults.#arguments.key#" ) )#" );
        } catch (any e) {
            printError( "No CLI defaults found for key: #arguments.key#. Please check your spelling and try again." );
        }
	}

    /**
     * Updates or creates a nested key in a structure using dot notation.
     * @param keyPath - Dot notation string (e.g., "user.profile.name")
     * @param value - Value to set
     */
    function setNestedStructValue( keyPath, value ) {
        var keys = listToArray(keyPath, ".");
        var current = variables.cliDefaults;
        for (var i = 1; i <= arrayLen(keys); i++) {
            var key = keys[i];
            // If it's the last key, set the value
            if (i == arrayLen(keys)) {
                current[key] = value;
            } else {
                // If the key doesn't exist or isn't a struct, create it
                if (!structKeyExists(current, key) || !isStruct(current[key])) {
                    current[key] = {};
                }
                current = current[key];
            }
        }
    }

 }