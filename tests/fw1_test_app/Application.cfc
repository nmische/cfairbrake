component extends="org.corfield.framework" {

	this.name = "CFAirbrakeFW1TestApp";
  this.datasource = "cfairbrake";
  this.ormenabled = "true";
  this.sessionmanagement = "true";
  this.ormsettings = {
    dbcreate = "dropcreate",
    sqlscript = "/vagrant/wwwroot/cfairbrake/tests/sql/cfairbrake.sql",
    cfclocation = "/vagrant/wwwroot/cfairbrake/tests/entities"
  };
	
	function setupApplication() {
		application.cfairbrake = CreateObject("component","cfairbrake.cfairbrake").init(api_key="TESTKEY",app_version="0.1.0",environment_name="Testing",collect_error_details="true");
	}
	
	function setupRequest() {
		// use setupRequest to do initialization per request
		request.context.startTime = getTickCount();
	}

	function setupSession() {
		session.userid = "1";
		session.username = "test_user";
		session.email = "test_user@example.com";
	}

	function onError(any exception, string event) {
    var args = {};
    var output = "";
    args.error = StructKeyExists(arguments.exception,"cause") ? arguments.exception.cause : arguments.exception ;
    args.cgi = cgi;
    args.params = {};
    args.include_schema = true;
    if ( IsDefined('url')  and IsStruct(url) ) StructAppend(args.params,url);
    if ( IsDefined('form') and IsStruct(form) ) StructAppend(args.params,form);
    // collection session data    
    if ( IsDefined('session') and IsStruct(session) ) {
    	args.session = session; 
    	// and log the user to airbrake.io's current-user
    	if ( StructKeyExists(session,"userid") ) {
    		args.user = {};
    		args.user.id = session.userid;
    		if ( StructKeyExists(session,"username") ) args.user.username = session.username;
    		if ( StructKeyExists(session,"email") ) args.user.email = session.email;
    	}
    }
    // map fw1 section/item to airbrake.io component/action
    if ( StructKeyExists(request, "section") ) args.component = request.section;
    if ( StructKeyExists(request, "item") ) args.action = request.item;

    output = application.cfairbrake.build_notice(argumentcollection=args);
    FileWrite("/vagrant/wwwroot/cfairbrake/tests/output/output.xml",output);

    super.onError( exception, event );

  }

  function onMissingTemplate( string targetPage ) {
    var args = {};
    var output = "";
    args.cgi = cgi;
    args.params = {};
    args.include_schema = true;
    if ( IsDefined('url')  and IsStruct(url) ) StructAppend(args.params,url);
    if ( IsDefined('form') and IsStruct(form) ) StructAppend(args.params,form);    
    if ( IsDefined('session') and IsStruct(session) ) {
    	args.session = session; 
    	if ( StructKeyExists(session,"userid") ) {
    		args.user = {};
    		args.user.id = session.userid;
    		if ( StructKeyExists(session,"username") ) args.user.username = session.username;
    		if ( StructKeyExists(session,"email") ) args.user.email = session.email;
    	}
    }

    output = application.cfairbrake.build_notice(argumentcollection=args);
    FileWrite("/vagrant/wwwroot/cfairbrake/tests/output/output.xml",output);
  }
	
}