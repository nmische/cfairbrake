<!--- write result to file --->
<cfset cfairbrake = CreateObject("component","cfairbrake.cfairbrake").init(api_key="TESTING") />
<cfset args = {} />
<cfset args.error = error />
<cfset args.cgi = cgi />
<cfset args.params = {} />
<cfset args.include_schema = true />
<cfset StructAppend(args.params,url) />
<cfset StructAppend(args.params,form) />
<cfif IsDefined('session')><cfset args.session = session /></cfif>
<cfset output = cfairbrake.build_notice(argumentcollection=args) />
<cffile action="write" output="#output#" file="/vagrant/wwwroot/tests/mxunit/output.xml" />
