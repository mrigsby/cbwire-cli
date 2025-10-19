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

	/**
	 * @key String : The specific key to set (uses dot notation I.E. create.singleFileWire).
     * @value String|Boolean|numeric : The value to set the key value to.
	 **/
	function run( key="" ){
        printCBWireCLIHeader();
        arguments.key = trim( arguments.key );
        if( len( arguments.key ) != 0 ){
            try {
                // get current and base values
                var baseKeyValue    = structGet( "utility.cliDefaults.#arguments.key#" );
                var keyValue        = structGet( "utility.cliDefaults.#arguments.key#" );
            } catch (any e) {
                printError( "⚠️ No CLI defaults found for key: #arguments.key#. Please check your spelling and try again." );
                return;
            }
            if( isStruct( keyValue ) ){
                printError( "⚠️ #arguments.key# is a set of defaults and cannot be reset all at once!" );
                printError( "Please specify a specific key to reset. Example: cbwire reset default create.jsWireRef" );
                return;
            }
            printStyledMessage([
                "Resetting default value for key: #arguments.key#",
                "Current Value: #formatForCLI( structGet( "utility.cliDefaults.#arguments.key#" ) )#",
                "Default Value: #formatForCLI( structGet( "utility.cliBaseDefaults.#arguments.key#" ) )#"
            ]);
            utility.resetKeyToBaseDefault( arguments.key );
            printStyledMessage( "✅️ Success!" );
            printStyledMessage( "Updated Value: #formatForCLI( structGet( "utility.cliDefaults.#arguments.key#" ) )#" );
            return;
        }
        
        // Reset all values
        var confirmResponse = confirm( "Are you sure you want to reset all cbwire-cli defaults to original values? [y/n]" );
        if( !confirmResponse ){
            printWarn( "Reset cancelled" );
            return;
        }
        try {
            utility.resetCliDefaultsToBaseDefaults();
            printStyledMessage( "✅️ Success!" );
            printStyledMessage( "All cbwire-cli defaults have been reset" );
        } catch (any e) {
            printError( "⚠️ There was an error resetting all default values!" );
            printStyledMessage([
                "Error: #e.message#",
                "Try again or re-install cbwire-cli"
            ]);
        }
	}

 }