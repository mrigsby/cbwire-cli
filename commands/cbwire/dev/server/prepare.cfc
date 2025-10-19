 /**
 * CBWire CLI Development Server Prepare Command
 * This command will prepare the test-harness servers for use
 * by installing dependencies and setting up necessary files.
 * It must be run from within the root of the CBWIRE module or the test-harness directory.
 * .
 * {code:bash}
 * cbwire dev server prepare
 * {code}
 *
 **/
 component extends="cbwire-cli.models.BaseCommand" {

	/**
	 * Prepares the test-harness servers by installing dependencies
	 **/
	function run(){
		if( !verifyInRootDirectory() ){
			return;
		}

		shell.clearScreen();
		printCBWireCLIHeader( "🚀 Prepare Server ➤ Install ColdBox Dependencies" );

        // Confirm prepare
        var confirmResponse = confirm( "Are you sure you want to install ColdBox dependencies to prepare #variables.testHarnessDirectoryName# servers for running? [y/n]" );
        if( !confirmResponse ){
            printStyledMessage( "⛔ Prepare cancelled" );
            return;
        }

		command( 'install' ).run();
        print.line();
        printStyledMessage( "✅️ ColdBox CBWIRE Root dependencies installed successfully!" );
        print.line();

        printStyledMessage( "Changing to #variables.testHarnessDirectoryName# directory" );
        print.line();
        command( 'cd' ).params( variables.testHarnessDirectoryName ).run();
        command( 'install' ).run();
        print.line();

        printStyledMessage([
            "✅️ ColdBox CBWIRE Root dependencies installed successfully!",
            "You can now run the #variables.testHarnessDirectoryName# servers",
            "Example: 'cbwire dev server start'"
        ]);
        print.line();
	}

}