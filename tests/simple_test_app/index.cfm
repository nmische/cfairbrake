<cfswitch expression="#url.action#">

  <cfcase value="bad_entity">
    <cfinclude template="bad_entity.cfm" />
  </cfcase>

  <cfcase value="bad_include">
    <cfinclude template="bad_include.cfm" />
  </cfcase>

  <cfcase value="bad_property">
    <cfinclude template="bad_property.cfm" />
  </cfcase>

  <cfcase value="bad_sql">
    <cfinclude template="bad_sql.cfm" />
  </cfcase>

  <cfcase value="bad_syntax">
    <cfinclude template="bad_syntax.cfm" />
  </cfcase>

  <cfcase value="divide_by_zero">
    <cfinclude template="divide_by_zero.cfm" />
  </cfcase>

  <cfcase value="null_pointer">
    <cfinclude template="null_pointer.cfm" />
  </cfcase>


    
</cfswitch>