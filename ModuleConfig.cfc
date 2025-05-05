/**
 *********************************************************************************
 * Michael Rigsby | OIS Technologies | www.oistech.com | mrigsby@oistech.com
 ********************************************************************************
 *
 * @author Michael Rigsby
 */
component {

	this.name      = "CBWIRE CLI";
	this.version   = "@build.version@+@build.number@";
	this.cfmapping = "cbwire-cli";

	function configure(){
		settings = { templatesPath : modulePath & "/templates" }
	}

	function onLoad(){
		// log.info('Module loaded successfully.' );
	}

	function onUnLoad(){
		// log.info('Module unloaded successfully.' );
	}

}
