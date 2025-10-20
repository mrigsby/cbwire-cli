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

	/**
	 * @key String : The specific key to set (uses dot notation I.E. create.singleFileWire).
     * @value String|Boolean|numeric : The value to set the key value to.
	 **/
	function run( required key, required value ){
        printCBWireCLIHeader();
        try {
            var keyValue = structGet( "utility.cliDefaults.#arguments.key#" );
            if( isStruct( keyValue ) ){
                printError( "⚠️ #arguments.key# is a set of defaults and cannot be set all at once!" );
                printStyledMessage( "Please specify a specific key to set. Example: cbwire set default create.jsWireRef true" );
                return;
            }
            printStyledMessage([
                "Setting default value for key: #arguments.key#",
                "Current Value: #formatForCLI( keyValue )#"
            ]);
            utility.setCliDefaultKey( arguments.key, arguments.value );
            printStyledMessage( "✅️ Success!" );
            printStyledMessage( "Updated Value: #formatForCLI( structGet( "utility.cliDefaults.#arguments.key#" ) )#" );
        } catch (any e) {
            printError( "⚠️ No CLI defaults found for key: #arguments.key#. Please check your spelling and try again." );
        }
	}

 }