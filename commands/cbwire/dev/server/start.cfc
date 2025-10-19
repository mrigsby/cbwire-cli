 /**
 * CBWire CLI Development Server Start Command
 * This command allows you to start a testing-harness server
 * It will provide a list of available testing-harness servers to start and allow
 * you to select one to start.
 * .
 * {code:bash}
 * cbwire dev server start
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {

	/**
	 * Run a test-harness server
	 * Runs a testing-harness server and optionaly opens the test suite in a browser
	 * 
     * @webRunner Boolean : If true, will open the TestBox Web Runner in the default browser after starting the server.
	 * @commandBoxRunner Boolean : If true, will run the TestBox CommandBox Runner after starting the server.
	 * @defaultServer String : The default server config file to select when starting a server.
	 * @stopRunningTestServers Boolean : If true, will stop any running test-harness servers before starting the selected server.
     * 
	 **/
	function run( webRunner, commandBoxRunner, defaultServer, stopRunningTestServers ){
		if( !verifyInTestHarnessDirectory() ){
			return;
		}

		shell.clearScreen();
		printCBWireCLIHeader();

		// load defaults into arguments
		arguments = utility.loadFunctionArgsFromDefaults( "dev.server.start", arguments );
		var defaultSelectedServer = lcase( arguments.defaultServer );

		var askOptions = [];
		variables.testHarnessServers.each( function( key, value ) { 
			askOptions.append( { 
				display : value.label, 
				value : key, 
				selected : ( value.file == defaultSelectedServer )
			} );
		}); 
		askOptions.append( { display : "Cancel and Return", value : "CANCEL", selected : false } );
		
		print.line();

		var serverToOpen =  multiselect( 'What #variables.testHarnessDirectoryName# server do you want to run? ' )
			.options( askOptions )
			.required()
			.ask();
		
		if( serverToOpen == "CANCEL"  ){
			print.line();
			printWarn( "⛔ Server Start Canceled!" );
			return;
		}

		shell.clearScreen();
		printCBWireCLIHeader( "🚀 Starting #variables.testHarnessDirectoryName# server: #variables.testHarnessServers[ serverToOpen ].name#" );
		print.line();

		if( arguments.stopRunningTestServers ){
			stopAllTestHarnessServers();
			print.line();
		}

        command( 'server start' )
			.params( serverConfigFile="#variables.workingDirectory##variables.testHarnessServers[ serverToOpen ].file#" )
			.run();

		print.line();
		printStyledMessage( "✅️ #variables.testHarnessDirectoryName# server: #variables.testHarnessServers[ serverToOpen ].name# is running!" );
		print.line();

		if( arguments.webRunner || arguments.commandBoxRunner ){
			var serverConfig = deserializeJSON( fileRead( '#variables.workingDirectory##variables.testHarnessServers[ serverToOpen ].file#' ) );
			var theURL = "http://127.0.0.1:#serverConfig.web.http.port#/tests/runner.cfm";
		}

        if( arguments.webRunner ){
			print.line();
			waitForKey( message='Press any key to open the TestBox Web Runner in your browser' );
			shell.clearScreen();
            print.printCBWireCLIHeader( "🚀 Opening #variables.testHarnessDirectoryName# server #variables.testHarnessServers[ serverToOpen ].name# TestBox Web Runner" );
			openURL( theURL );
			print.line();
        }

        if( arguments.commandBoxRunner ){
			print.line();
			waitForKey( message='Press any key to run the TestBox CommandBox Runner' );
			shell.clearScreen();
			printCBWireCLIHeader( "🚀 Running #variables.testHarnessDirectoryName# server #variables.testHarnessServers[ serverToOpen ].name# TestBox CommandBox Runner" );
			print.line();
			command( 'testbox run' )
				.params( runner=theURL )
				.run();
			print.line();
        }

	}

}