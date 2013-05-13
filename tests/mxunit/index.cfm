<cfsetting showdebugoutput="false" requesttimeout="300" />

<cfinvoke component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#ExpandPath('./suite')#"
          componentPath="cfairbrake.tests.mxunit.suite"
          recurse="true"
          returnvariable="results" />
 
<cfoutput> #results.getResultsOutput('extjs')# </cfoutput>