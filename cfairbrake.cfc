<cfcomponent>
    
  <!--- configurable settings --->  
  <cfset variables.api_key = "" />
  <cfset variables.app_version = "0.0.0" />
  <cfset variables.environment_name = "Unspecified" />
  <cfset variables.project_root = GetDirectoryFromPath(GetBaseTemplatePath()) />
  <cfset variables.use_ssl = false />
  <cfset variables.collect_error_details = false />
  <cfset variables.log_root_cause = false />
  

  <cffunction name="init" access="public" returntype="any" output="no">
    <cfargument name="api_key" type="string" required="yes" hint="The Airbrake.io API key." />
    <cfargument name="app_version" type="string" required="no" default="0.0.0" hint="The application version to log to Airbrake." />
    <cfargument name="environment_name" type="string" required="no" default="Unspecified" hint="The application environment to log to Airbrake." />
    <cfargument name="project_root" type="string" required="no" default="#GetDirectoryFromPath(GetBaseTemplatePath())#" hint="The project root directory to log to Airbrake." />
    <cfargument name="use_ssl" type="string" required="no" default="false" hint="Use SSL when posting to Airbrake.io." />
    <cfargument name="collect_error_details" type="string" required="no" default="false" hint="Collect additional error details as CGI data." />
    <cfargument name="log_root_cause" type="string" required="no" default="false" hint="If the passed exception has a root cause defined log that instead of the passed exception." />
    <cfset variables.api_key = arguments.api_key />
    <cfset variables.app_version = arguments.app_version />
    <cfset variables.environment_name = arguments.environment_name />
    <cfset variables.project_root = arguments.project_root />
    <cfset variables.use_ssl = arguments.use_ssl />
    <cfset variables.collect_error_details = arguments.collect_error_details />
    <cfreturn this />
  </cffunction>


  <cffunction name="send" access="public" returntype="void" output="no">
    <cfargument name="error" type="any" required="yes" hint="The error structure to notify Airbrake about." />
    <cfargument name="cgi" type="struct" required="no" hint="Any cgi variables to report." />    
    <cfargument name="params" type="struct" required="no" hint="Any request parameters to report." />
    <cfargument name="session" type="struct" required="no" hint="Any session variables to report." />
    <cfargument name="component" type="string" required="no" default="" hint="The component in which the error occurred. In model-view-controller frameworks like FW/1, this should be set to the controller. Otherwise, this can be set to a route or other request category." />
    <cfargument name="action" type="string" required="no" default="" hint="The action in which the error occurred. If each request is routed to a controller action, this should be set here. Otherwise, this can be set to a method or other request subcategory." />
    <cfargument name="user" type="struct" required="no" hint="Current user details. This should be a structure with an 'id' key and optional 'name', 'email', and 'username' keys." />

    <cfset var api_endpoint = ( (variables.use_ssl) ? "https" : "http" ) & "://api.airbrake.io/notifier_api/v2/notices" />
    <cfset var http_result = "" />
    <cfset var http_result_xml = "" />
    <cfset var notice = build_notice(argumentCollection=arguments) />
    <cfset var notice_result = "" />  


    <cfhttp method="post" url="#api_endpoint#" timeout="120" result="http_result">
      <cfhttpparam type="header" name="Accept" value="text/xml, application/xml">
      <cfhttpparam type="header" name="Content-type" value="text/xml">
       <cfhttpparam type="body" value="#notice#">
    </cfhttp>

    <cfset notice_result = { status = http_result.statusCode, id = 0, url = "" } />

    <cfif IsXML(local.http.filecontent)>
      <cfset http_result_xml = XmlParse(http_result.filecontent) />
      <cfif StructKeyExists(http_result_xml, "notice")>
        <cfset notice_result.id = http_result_xml.notice.id.XmlText>
        <cfset notice_result.url = http_result_xml.notice.url.XmlText>
      </cfif>
    </cfif>

    <cfreturn notice_result />

  </cffunction>


  <cffunction name="build_notice" access="public" returntype="xml" output="no">
    <cfargument name="error" type="any" required="yes" hint="The error structure to notify Airbrake about." />
    <cfargument name="cgi" type="struct" required="no" default="#StructNew()#" hint="Any cgi variables to report." />    
    <cfargument name="params" type="struct" required="no" default="#StructNew()#" hint="Any request parameters to report." />
    <cfargument name="session" type="struct" required="no" default="#StructNew()#" hint="Any session variables to report." />
    <cfargument name="component" type="string" required="no" default="" hint="The component in which the error occurred. In model-view-controller frameworks like FW/1, this should be set to the controller. Otherwise, this can be set to a route or other request category." />
    <cfargument name="action" type="string" required="no" default="" hint="The action in which the error occurred. If each request is routed to a controller action, this should be set here. Otherwise, this can be set to a method or other request subcategory." />
    <cfargument name="user" type="struct" required="no" hint="Current user details. This should be a structure with an 'id' key and optional 'name', 'email', and 'username' keys." />
    <cfargument name="include_schema" required="no" default="false" hint="Include schema attributes in notice element. This is needed when building a notice to validate in unit tests but not necessary when building notice to send to Airbrake." />

    <cfset var notice = "" />
    <cfset var item = "" />
    <cfset var err = prep_error(arguments.error) />
    <cfset var backtrace = [] />
    <cfset var line = "" />
    <cfset var key = "" />
    <cfset var requested_url = "" />
    <cfset var requested_cmp = "" />
    <cfset var requested_act = "" />
    
    <cfif StructKeyExists(err, "tagcontext") and IsArray(err.tagcontext)>
      <cfset backtrace = build_backtrace(err.tagcontext)>
    </cfif>

    <cfset requested_url = get_url() />
    <cfset requested_cmp = get_component(arguments.component,backtrace) />
    <cfset requested_act = get_action(arguments.action,backtrace) />

    <cfoutput>
    <cfxml variable="notice">
      <notice version="2.3" <cfif arguments.include_schema>xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://airbrake.io/airbrake_2_3.xsd"</cfif>>
        <api-key>#variables.api_key#</api-key>
        <notifier>
          <name>ColdFusion Airbrake Notifier</name>
          <version>0.1.0</version>
          <url></url>
        </notifier>
        <error>
          <class>#XmlFormat(err.type)#</class>
          <message>#XmlFormat(err.message)#</message>         
          <backtrace>             
            <cfloop array="#backtrace#" index="line"><line<cfif Len(line.method)> method="#XmlFormat(line.method)#"</cfif> file="#XmlFormat(line.file)#" number="#XmlFormat(line.line)#" />       
            </cfloop>           
          </backtrace>
        </error>
        <request>
          <url>#XmlFormat(requested_url)#</url>
          <component>#XmlFormat(requested_cmp)#</component>
          <action>#XmlFormat(requested_act)#</action>
          <cfif ( StructKeyExists(arguments,"cgi") and not StructIsEmpty(arguments.cgi) ) or variables.collect_error_details>
          <cgi-data>
            <cfloop collection="#arguments.cgi#" item="key"><cfif Len(arguments.cgi[key])><var key="#XmlFormat(key)#">#XmlFormat(arguments.cgi[key])#</var>
            </cfif></cfloop>
            <cfif variables.collect_error_details>
              <cfloop collection="#err#" item="key"><cfif IsSimpleValue(err[key]) and Len(err[key])><var key="CF_ERROR_#XmlFormat(UCase(key))#">#XmlFormat(err[key])#</var>
              </cfif></cfloop>
            </cfif>            
          </cgi-data>
          </cfif>
          <cfif StructKeyExists(arguments,"params") and not StructIsEmpty(arguments.params)>
          <params>
            <cfloop collection="#arguments.params#" item="key"><var key="#XmlFormat(key)#"><cfif IsSimpleValue(arguments.params[key])>#XmlFormat(arguments.params[key])#<cfelse>COMPLEX VALUE</cfif></var>
            </cfloop>
          </params>
          </cfif>
          <cfif StructKeyExists(arguments,"session") and not StructIsEmpty(arguments.session)>
          <session>
            <cfloop collection="#arguments.session#" item="key"><var key="#XmlFormat(key)#"><cfif IsSimpleValue(arguments.session[key])>#XmlFormat(arguments.session[key])#<cfelse>COMPLEX VALUE</cfif></var>
            </cfloop>
          </session>
          </cfif>
        </request>
        <server-environment>
          <project-root>#XmlFormat(variables.project_root)#</project-root>
          <environment-name>#XmlFormat(variables.environment_name)#</environment-name>
          <app-version>#XmlFormat(variables.app_version)#</app-version>
        </server-environment>
        <cfif StructKeyExists(arguments,"user") and StructKeyExists(arguments.user,"id")>
        <current-user>
          <id>#arguments.user.id#</id>
          <cfif StructKeyExists(arguments.user,"name")><name>#arguments.user.name#</name>
          </cfif>
          <cfif StructKeyExists(arguments.user,"email")><email>#arguments.user.email#</email>
          </cfif>
          <cfif StructKeyExists(arguments.user,"username")><username>#arguments.user.username#</username>
          </cfif>
        </current-user>      
        </cfif>
      </notice>
    </cfxml>
    </cfoutput>

    <cfreturn notice />

  </cffunction>


  <cffunction name="build_backtrace" access="private" returntype="array" output="no">
    <cfargument name="context" type="array" required="yes">
    <cfset var lines = []>
    <cfset var line = {}>
    <cfset var item = {}>
    <cfloop array="#arguments.context#" index="item">
      <cfset line = { line = 0, file = "", method = "" }>
      <cfif structkeyexists(item, "line")><cfset line.line = item.line></cfif>
      <cfif structkeyexists(item, "template")><cfset line.file = item.template></cfif>
      <cfif structkeyexists(item, "raw_trace") AND refind("at cf.*?\$func([A-Z_-]+)\.runFunction", item.raw_trace)>
        <cfset line.method = lcase(trim(rereplace(item.raw_trace, "at cf.*?\$func([A-Z_-]+)\.runFunction.*", "\1")))>
      </cfif>
      <cfset arrayappend(lines, line)>
    </cfloop>
    <cfreturn lines>
  </cffunction>


  <cffunction name="get_url" access="private" returntype="string" output="no">
    <cfset var return_url = "" />
    <cfset var query_string = "" />
    <cftry> <cfset return_url = ToString(GetPageContext().getRequest().getRequestURL()) /> <cfcatch/> </cftry>
    <cftry> <cfset query_string = ToString(GetPageContext().getRequest().getQueryString()) /> <cfcatch/> </cftry>
    <cfif Len(query_string) gt 0>
      <cfset return_url = return_url & "?" & query_string />
    </cfif>
    <cfreturn return_url />  
  </cffunction>


  <cffunction name="prep_error" access="private" returntype="any" output="no">
    <cfargument name="error" type="any" requried="yes" />
    <cfset var e = {} />
    <cfset var key = "" />
    <cfif variables.log_root_cause and IsDefined("arguments.error.RootCause") >
      <cfset arguments.error = arguments.error.RootCause />
    </cfif>
    <cfif not IsStruct(arguments.error)>
      <cfloop collection="#arguments.error#" item="key">
        <cfset e[key] = arguments.error[key] />
      </cfloop>
    <cfelse>
      <cfset e = arguments.error />
    </cfif>
    <cfif not StructKeyExists(e, "type")><cfset e.type = "Unknown"></cfif>
    <cfif not StructKeyExists(e, "message")><cfset e.message = ""></cfif>
    <cfreturn e />
  </cffunction>


  <cffunction name="get_component" access="private" returntype="string" output="no">
    <cfargument name="component" type="string" requried="yes" />
    <cfargument name="backtrace" type="array" requried="yes" />
    <cfif Len(arguments.component)>
      <cfreturn arguments.component />
    </cfif>
    <cfif ArrayLen(backtrace) and ListLast(backtrace[1].file,".") eq "cfc">
      <cfreturn ListLast(backtrace[1].file,CreateObject("java","java.io.File").separator) />
    </cfif>
    <cfreturn "" />
  </cffunction>


  <cffunction name="get_action" access="private" returntype="string" output="no">
    <cfargument name="action" type="string" requried="yes" />
    <cfargument name="backtrace" type="array" requried="yes" />
    <cfif Len(arguments.action)>
      <cfreturn arguments.action />
    </cfif>
    <cfif ArrayLen(backtrace) and ListLast(backtrace[1].file,".") eq "cfc" and Len(backtrace[1].method)>
      <cfreturn backtrace[1].method />
    </cfif>
    <cfreturn "" />
  </cffunction>

  
</cfcomponent>
