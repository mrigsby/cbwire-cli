 /**
 * CBWire CLI Development Run TestBox tests Command
 * This command allows you to run TestBox tests against one or all testing-harness engines
 * .
 * {code:bash}
 * cbwire dev tests
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {
	
    property name="reportData"; 

	/**
	 * Run TestBox tests against one or all testing-harness engines
	 * 
     * @deletePreviousReports Boolean : If true, will delete previous test reports before running tests.
     * @defaultServer String : The default server to select when prompting for which server to run tests against. Use "ALL" to select all servers.
     * 
	 **/
	function run( deletePreviousReports, defaultServer ) {
		if( !verifyInTestHarnessDirectory() ){ return; }
		if( !loadTestingServersConfig() ){ return; }
	
		shell.clearScreen();
		printCBWireCLIHeader();

		// load defaults into arguments
		arguments = variables.utility.loadFunctionArgsFromDefaults( "dev.tests", arguments );
        
		var defaultSelectedServer = lcase( arguments.defaultServer );
		var askOptions = [{ display : "Run Tests for ALL engines", value : "ALL", selected : defaultSelectedServer == "all" ? true : false }];
		variables.testHarnessServers.each( function( key, value ) { 
			askOptions.append( { 
				display     : value.label, 
				value       : key, 
				selected    : ( value.file == defaultSelectedServer ),
                file        : value.file
			} );
		}); 
		askOptions.append( { display : "Cancel and Return", value : "CANCEL", selected : false } );

		print.line();

		var engineToTest =  multiselect( 'What #variables.settings.testHarnessDirectoryName# server do you want to run TestBox runner for? ' )
			.options( askOptions )
			.required()
			.ask();
		
		if( engineToTest == "CANCEL"  ){
			print.line();
			printWarn( "⛔ TestBox tests Canceled!" );
			return;
		}

        // delete previous reports if requested
        if( arguments.deletePreviousReports ){
            var testResultsDirFullPath = "#variables.workingDirectory#tests/results/cbwire-cli/";
            if( directoryExists( testResultsDirFullPath ) ){
                job.start( "🧹 Deleting previous TestBox reports..." );
                directoryDelete( testResultsDirFullPath, true );
                job.complete();
            }
        }

        // clear reports to open
        variables.reportData = {
            "openInBrowser" : [],
            "jsonResultFiles" : [],
            "summaryReportHeader" : [ "Engine", "Version", "Passed", "Failed", "Errored", "Skipped", "Bundles", "Suites", "Specs" ],
            "summaryReportData" : [],
            "reportsWithErrors" : []
        };

        // ALL OR ONE SERVER?
        if( engineToTest == "ALL" ){
            shell.clearScreen();
            printCBWireCLIHeader( "🚀 Running TestBox tests on ALL engines! 🚀" );
            print.line();
            // Run all servers one by one
            variables.testHarnessServers.each( function( key, value ) {
                try {
                    runSingleTestHarnessServer( key, value );
                } catch ( any e ) {
                    printWarn( "⛔️ An error occurred while running tests for #value.label#: #e.message#" );
                }
            });
        }else{
            shell.clearScreen();
            printCBWireCLIHeader( "🚀 Running TestBox tests for #variables.testHarnessServers[ engineToTest ].label#! 🚀" );
            print.line();
            try {
                runSingleTestHarnessServer( engineToTest, variables.testHarnessServers[ engineToTest ] );
            } catch ( any e ) {
                printWarn( "⛔️ An error occurred while running tests for #variables.testHarnessServers[ engineToTest ].label#: #e.message#" );
            }
            
        }
        
        // compile report results
        for ( var i = 1; i <= variables.reportData.jsonResultFiles.len(); i++) {
            var jsonData = deserializeJSON( fileRead( variables.reportData.jsonResultFiles[ i ] ) );
            variables.reportData.summaryReportData.append( [
                jsonData.CFMLEngine,
                jsonData.CFMLEngineVersion,
                jsonData.totalPass,
                jsonData.totalFail,
                jsonData.totalError,
                jsonData.totalSkipped,
                jsonData.totalBundles,
                jsonData.totalSuites,
                jsonData.totalSpecs
            ] );

            if( jsonData.totalFail > 0 || jsonData.totalError > 0 ){
                variables.reportData.reportsWithErrors.append( {
                    "url"       : variables.reportData.openInBrowser[ i ],
                    "failed" : jsonData.totalFail,
                    "errored" : jsonData.totalError,
                    "engine" : jsonData.CFMLEngine,
                    "version" : jsonData.CFMLEngineVersion
                } );
            }
        }

		shell.clearScreen();
		printCBWireCLIHeader( "📊 Report Results 📊" );

        print.table( headerNames = variables.reportData.summaryReportHeader, data = variables.reportData.summaryReportData );

        if( variables.reportData.reportsWithErrors.len() > 0 ){
            print.line();
            printStyledMessage( "⛔️ The following engine#variables.reportData.reportsWithErrors.len() > 1 ? "s" : ""# had failures or errors" );
            for ( var reportInfo in variables.reportData.reportsWithErrors ) {
                variables.print.boldColor178OnBlack( "⚠️ #reportInfo.engine# v#reportInfo.version# : " );
                if( reportInfo.errored > 0 ){
                    variables.print.blackOnWheat1( " #reportInfo.errored# Errored Tests " );
                }
                if( reportInfo.failed > 0 ){
                    if( reportInfo.errored > 0 ){
                        variables.print.boldColor178OnBlack( " and " );
                    }
                    variables.print.whiteOnRed2( " #reportInfo.failed# Failed Tests " );
                }
                variables.print.line();
            }

            if( confirm( 'Do you want to open these reports? [y/n]' ) ) {
                for ( var reportData in variables.reportData.reportsWithErrors ) {
                    printStyledMessage( "🚀 Opening report for #reportData.engine# v#reportData.version#" );
                    openURL( reportData.url );
                    print.line();
                    sleep( 1000 );
                } 
            }
        }
        return;
	}

    /**
     * Runs a single test-harness server based on the provided engine key and arguments.
     * 
     * @param engineKey String : The key of the engine to run the test-harness server for.
     * @param arguments Struct : The arguments struct containing options for running the server.
     **/
    private function runSingleTestHarnessServer( engineKey, engineConfig ){
        // Implementation for running a single test-harness server
        var serverConfig = deserializeJSON( fileRead( '#variables.workingDirectory##engineConfig.file#' ) );
        var runnerURL = "http://127.0.0.1:#serverConfig.web.http.port#/tests/runner.cfm";
        var testResultsBaseURL = "http://127.0.0.1:#serverConfig.web.http.port#/";

        // verify test results folder exists
        var testResultsDirFullPath = "#variables.workingDirectory#";
        var testResultsDirRelPath = "/";
        var testDirectoryPath = [ "tests", "results", "cbwire-cli" ];
        for ( currentValue in testDirectoryPath ) {
            testResultsDirFullPath &= "#currentValue#/";
            testResultsDirRelPath &= "#currentValue#/";
            testResultsBaseURL &= "#currentValue#/";
            if( !directoryExists( testResultsDirFullPath ) ){
                directoryCreate( testResultsDirFullPath );
            }
        }

        stopAllTestHarnessServers();
        print.line();

        command( 'server start' )
			.params( serverConfigFile="#variables.workingDirectory##engineConfig.file#" )
			.run();

        if( !waitForServerToStart( engineKey, engineConfig ) ){
            printWarn( "⛔️ Could not start #variables.settings.testHarnessDirectoryName# server: #engineConfig.name#. Skipping tests for this engine." );
            return;
        }

        print.line();

        // run tests using commandbox testbox run
        var uniqueOutputFileName = "#engineConfig.name#-#dateTimeFormat( now(), 'yyyyMMdd-HHmmss' )#";
        try {
            command( 'testbox run' )
                .params( 
                    runner=runnerURL,
                    outputFormats="json,simple",
                    outputFile="#testResultsDirRelPath##uniqueOutputFileName#" 
                )
                .run();
        } catch ( any e ) {
            printWarn( "⛔️ An error occurred while running TestBox tests for #engineConfig.name#: #e.message#. Continuing..." );
        }

        sleep( 750 ); // give it a moment to write the file
        
        printStyledMessage( "✅️ #variables.settings.testHarnessDirectoryName# server: #engineConfig.name# tests completed!" );
        printStyledMessage( "🪵 Logging results..." );
        print.line();

        if( fileExists( "#testResultsDirFullPath##uniqueOutputFileName#-simple.html" ) ){
            variables.reportData.openInBrowser.append( "#testResultsBaseURL##uniqueOutputFileName#-simple.html" );
        }

        if( fileExists( "#testResultsDirFullPath##uniqueOutputFileName#.json" ) ){
            variables.reportData.jsonResultFiles.append( "#testResultsDirFullPath##uniqueOutputFileName#.json" );
        }

    }

}