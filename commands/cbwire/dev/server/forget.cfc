 /**
 * CBWire CLI Development Forget Server Command
 * This command allows you to forget a testing-harness server from commandbox
 * It will provide a list of available testing-harness servers to forget and allow
 * you to select one or all to forget.
 * .
 * {code:bash}
 * cbwire dev server forget 
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {

	/**
	 * Run the Forget Command
	 * Forgets a testing-harness server from commandbox
	 * 
	 **/
	function run(){
		if( !verifyInTestHarnessDirectory() ){
			return;
		}
		
		shell.clearScreen();
		printCBWireCLIHeader();

		var askOptions = [];
		variables.testHarnessServers.each( function( key, value ) { 
			askOptions.append( { display : value.label, value : key } );
		}); 
		askOptions.append( { display : "All Testing Servers", value : "ALL", selected : true } );
		askOptions.append( { display : "Cancel and Return", value : "CANCEL" } );

		var serverToReset =  multiselect( 'What testing-harness server do you want to forget? ' )
			.options( askOptions )
			.required()
			.ask();
		
		if( serverToReset == "CANCEL"  ){
			print.line();
			printWarn( "server-forget Canceled!" );
			return;
		}

		if( serverToReset == "ALL" ){
			shell.clearScreen();
			printCBWireCLIHeader( "⛔ Forgetting ALL #variables.testHarnessDirectoryName# servers ⛔" );

			stopAllTestHarnessServers();
			print.line();

			variables.testHarnessServers.each( function( key, value ) {
				printStyledMessage( "⛔ Forgetting #variables.testHarnessDirectoryName# server: #value.name#" );
				print.line();
				command( 'server forget' )
					.params( serverConfigFile="#variables.workingDirectory##value.file#", force=true )
					.run();
				print.line();
			});
			print.line();
			
			printStyledMessage( "✅️ Done Forgetting all #variables.testHarnessDirectoryName# servers." );
			print.line();
			
			return;
		}

		shell.clearScreen();
		printCBWireCLIHeader( "⛔ Forgetting #variables.testHarnessDirectoryName# server: #variables.testHarnessServers[ serverToReset ].name#" );
		print.line();
		
		stopTestHarnessServer( serverToReset );
		print.line();

		command( 'server forget' )
			.params( serverConfigFile="#variables.workingDirectory##variables.testHarnessServers[ serverToReset ].file#", force=true )
			.run();

		print.line();
		printStyledMessage( "✅️ Done Forgetting #variables.testHarnessDirectoryName# #variables.testHarnessServers[ serverToReset ].name# server." );
		print.line();
		
	}


}