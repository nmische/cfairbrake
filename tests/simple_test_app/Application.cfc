component {

  this.name = "CFAirbrakeSimpleTestApp";
  this.datasource = "cfairbrake";
  this.ormenabled = "true";
  this.ormsettings = {
    dbcreate = "dropcreate",
    sqlscript = "/vagrant/wwwroot/cfairbrake/tests/sql/cfairbrake.sql",
    cfclocation = "/vagrant/wwwroot/cfairbrake/tests/entities"
  };

  function onRequestStart() {
    if ( StructKeyExists(url,"reload") ) {
      onApplicationStart(); 
      ORMReload();
      ApplicationStop();
    }
  }

  function onApplicationStart() {
    application.cfairbrake = CreateObject("component","cfairbrake.cfairbrake").init(api_key="TESTKEY");
    if (!directoryExists("/vagrant/wwwroot/cfairbrake/tests/output")) {
        directoryCreate("/vagrant/wwwroot/cfairbrake/tests/output");
    }
  }

  function onError( e ) {
    var args = {};
    var output = "";
    args.error = e;
    args.cgi = cgi;
    args.params = {};
    args.include_schema = true;
    if ( IsDefined('url')  and IsStruct(url) ) StructAppend(args.params,url);
    if ( IsDefined('form') and IsStruct(form) ) StructAppend(args.params,form);    
    if ( IsDefined('session') and IsStruct(session) ) args.session = session; 

    output = application.cfairbrake.build_notice(argumentcollection=args);
    FileWrite("/vagrant/wwwroot/cfairbrake/tests/output/output.xml",output);
  }

  function onMissingTemplate( e ) {
    var args = {};
    var output = "";
    args.error = {type="Missing Template", message=e };
    args.cgi = cgi;
    args.params = {};
    args.include_schema = true;
    if ( IsDefined('url')  and IsStruct(url) ) StructAppend(args.params,url);
    if ( IsDefined('form') and IsStruct(form) ) StructAppend(args.params,form);
    
    if ( IsDefined('session') and IsStruct(session) ) args.session = session; 

    output = application.cfairbrake.build_notice(argumentcollection=args);
    FileWrite("/vagrant/wwwroot/cfairbrake/tests/output/output.xml",output);
  }

}