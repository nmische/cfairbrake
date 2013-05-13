<cfset users = EntityLoad('users') />
<cfloop array="#users#" index="user">
  <cfoutput>#user.getUserId()#</cfoutput>
</cfloop>