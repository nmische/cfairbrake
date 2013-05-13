<cfset users = EntityLoad('user') />
<cfloop array="#users#" index="user">
  <cfoutput>#user.getFoo()#</cfoutput>
</cfloop>