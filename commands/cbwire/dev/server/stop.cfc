 /**
 * CBWire CLI Development Server Stop Command
 * This command allows you to stop any running testing-harness server
 * .
 * {code:bash}
 * cbwire dev server stop
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {

	/**
	 * Stop any running test-harness server
     * 
	 **/
	function run(){
		if( !verifyInTestHarnessDirectory() ){ return; }
		if( !loadTestingServersConfig() ){ return; }
        
		shell.clearScreen();
		printCBWireCLIHeader( "⛔ Stopping ANY running #variables.settings.testHarnessDirectoryName# servers! ⛔" );
		print.line();
        if( !confirm( 'Are you sure you want to stop ANY running #variables.settings.testHarnessDirectoryName# servers? [y/n]' ) ) {
			print.line();
			printWarn( "⚠️ Command Canceled!" );
			return;
        }
        print.line();
        variables.testHarnessServers.each( function( key, value ) {
            job.start( "👀 Checking #value.label# server..." );
            command( 'server stop' )
                .params( serverConfigFile="#variables.workingDirectory##value.file#" )
                .run();
            job.complete();
            print.line();
        });
        printStyledMessage( "✅️ DONE: Any running #variables.settings.testHarnessDirectoryName# servers have been stopped!" );
        print.line();
	}

}