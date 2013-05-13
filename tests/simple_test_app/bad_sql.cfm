<cfquery datasource="cfairbrake" name="q">
  SELECT nickname FROM users
</cfquery>
<cfdump var="#q#" />