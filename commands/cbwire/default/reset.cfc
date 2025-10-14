 /**
 * CBWire CLI Default Reset Command
 * This command allows you to set the default values for the various
 * options available when creating a new wire via the CLI.
 * .
 * {code:bash}
 * cbwire default reset 
 * cbwire default reset create.singleFileWire
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {
    
    property name="cliDefaults";
    property name="baseCliDefaults";

	/**
	 * @key String : The specific key to set (uses dot notation I.E. create.singleFileWire).
     * @value String|Boolean|numeric : The value to set the key value to.
	 **/
	function run( key="" ){
        variables.cliDefaults = getCLIDefaults();
        variables.baseCliDefaults = getBaseCLIDefaults();
        arguments.key = trim( arguments.key );

        if( len( arguments.key ) != 0 ){

            try {
                // get current and base values
                var baseKeyValue    = structGet( "variables.baseCliDefaults.#arguments.key#" );
                var keyValue        = structGet( "variables.cliDefaults.#arguments.key#" );
            } catch (any e) {
                printError( "No CLI defaults found for key: #arguments.key#. Please check your spelling and try again." );
                return;
            }

            if( isStruct( keyValue ) ){
                printError( "  #arguments.key# is a set of defaults and cannot be reset all at once!" );
                printError( "  Please specify a specific key to reset. Example: cbwire reset default create.jsWireRef" );
                return;
            }

            printInfo( "  Resetting default value for key: #arguments.key#" );
            printInfo( "  Current Value: #formatForCLI( structGet( "variables.cliDefaults.#arguments.key#" ) )#" );
            printInfo( "  Default Value: #formatForCLI( structGet( "variables.baseCliDefaults.#arguments.key#" ) )#" );
            
            setNestedStructValue( arguments.key, baseKeyValue );

            // write settings back to file
            try {
                fileWrite( '#variables.settings.modulePath#/cbwireDefaults.json', formatterUtil.formatJson( variables.cliDefaults ) );
            } catch (any e) {
                printError( "There was an error saving the default setting!" );
                printError( "Error: #e.message#" );
                printError( "Try again or re-install cbwire-cli" );
                return;
            }

            printSuccess( "  Success!" );
            printSuccess( "  Updated Value: #formatForCLI( structGet( "variables.cliDefaults.#arguments.key#" ) )#" );
            return;
        }

        // Reset all values
        var confirmResponse = confirm( "  Are you sure you want to reset all cbwire-cli defaults to original values?" );

        if( !confirmResponse ){
            printWarn( "  Reset cancelled." );
            return;
        }

        try {
            printInfo( "  Resetting all defaults for cbwire-cli!" );
            // write back to file
            fileWrite( '#variables.settings.modulePath#/cbwireDefaults.json', formatterUtil.formatJson( variables.baseCliDefaults ) );
            printSuccess( "  Success!" );
            printSuccess( "  All cbwire-cli defaults have been reset" );
        } catch (any e) {
            printError( "There was an error resetting all default values!" );
            printError( "Error: #e.message#" );
            printError( "Try again or re-install cbwire-cli" );
        }

	}

    /**
     * Updates or creates a nested key in a structure using dot notation.
     * @param keyPath - Dot notation string (e.g., "user.profile.name")
     * @param value - Value to set
     * @return void
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