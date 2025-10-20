 /**
 * CBWire CLI Default Get Command
 * This command allows you to lookup the default values for the various
 * options available when creating a new wire via the CLI.
 * .
 * {code:bash}
 * cbwire default get
 * cbwire default get create.wire.boxlang
 * cbwire default get create.wire.singleFileWire
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {

	/**
	 * @key String : The specific key to lookup (uses dot notation I.E. create.singleFileWire). If not provided, all keys and values will be listed.
	 **/
	function run( key ){
        shell.clearScreen();
        printCBWireCLIHeader();
        if( isNull( arguments.key ) || len( trim( arguments.key ) ) EQ 0 ){
            printStyledMessage([
                "CBWire CLI Default Values",
                "To lookup a specific default value provide the key name. Example: cbwire get default create.jsWireRef"
            ]);
            outputDefaultStruct( "", utility.cliDefaults );
            return;
        }
        try {
            var keyValue = structGet( "utility.cliDefaults.#arguments.key#" );
            if( isStruct( keyValue ) ){
                printStyledMessage([
                    "CBWire CLI #arguments.key# Default Values",
                    "To lookup a specific default value provide the key name. Example: cbwire get default create.jsWireRef",
                ]);
                outputDefaultStruct( arguments.key & ".", keyValue );
            }else{
                outputDefaultStruct( arguments.key, keyValue );
            }
        } catch (any e) {
            printError( "⚠️ No CLI defaults found for key: #arguments.key#. Please check your spelling and try again." );
        }
	}

    private function outputDefaultStruct( prependKey="", structToOutput ){
        var headerCols = [ 'Key Name', 'Value' ];
        var dataRows = isStruct( arguments.structToOutput ) 
            ? getNestedKey( prependKey, structToOutput ) 
            : [ [ prependKey, formatForCLI( structToOutput ) ] ];
        print.table(
            headerNames = headerCols,
            data = dataRows
        );
    }

    private array function getNestedKey( prependKey="", structToOutput, accululator=[] ){
        for( var k in structToOutput.keyArray() ){
            var currentValue = structGet( "structToOutput.#k#" );
            if( isStruct( currentValue ) ){
                arguments.accululator.append( getNestedKey( "#prependKey##k#.", currentValue ), true );
            } else {
                arguments.accululator.append( [ "#prependKey##k#", formatForCLI( currentValue ) ] );
            }
        }
        return arguments.accululator;
    }

 }