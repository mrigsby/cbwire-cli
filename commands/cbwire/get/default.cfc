 /**
 * CBWire CLI Get Default Command
 * This command allows you to lookup the default values for the various
 * options available when creating a new wire via the CLI.
 * .
 * {code:bash}
 * cbwire get defaults
 * cbwire get default create.boxlang
 * cbwire get default create.singleFileWire
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {

	/**
	 * @key String : The specific key to lookup (uses dot notation I.E. create.singleFileWire). If not provided, all keys and values will be listed.
	 **/
	function run( key ){
        var cliDefaults = getCLIDefaults();
        if( isNull( arguments.key ) || len( trim( arguments.key ) ) EQ 0 ){
            printSuccess( "CBWire CLI Default Values" );
            printInfo( "To lookup a specific default value provide the key name. Example: cbwire get default create.jsWireRef" );
            outputDefaultStruct( "", cliDefaults );
            return;
        }
        try {
            var keyValue = structGet( "cliDefaults.#arguments.key#" );
            if( isStruct( keyValue ) ){
                printSuccess( "CBWire CLI #arguments.key# Default Values" );
                printInfo( "To lookup a specific default value provide the key name. Example: cbwire get default create.jsWireRef" );
                outputDefaultStruct( "#arguments.key#.", keyValue );
            }else{
                printInfo( "#arguments.key# : #keyValue#" );
            }
        } catch (any e) {
            printError( "No CLI defaults found for key: #arguments.key#. Please check your spelling and try again." );
        }
	}





    
    private function outputDefaultStruct( prependKey="", structToOutput ){
        for( var k in structToOutput.keyArray() ){
            var currentValue = structGet( "structToOutput.#k#" );
            if( isStruct( currentValue ) ){
                outputDefaultStruct( "#prependKey##k#.", currentValue );
            } else {
                printInfo( "  #prependKey##k# : #currentValue#" );
            }
        }
    }

 }