# CFAirbrake

CFAirbrake is a Airbrake.io client that supports [version 2.3](http://help.airbrake.io/kb/api-2/notifier-api-version-23) of the Airbrake Notifier API.

## Use

The client is implemented as a single ColdFusion component that can be instantiated and called as needed. 

### Instantiation and Configuration

The component can be configured via the `init` method:

    cfairbrake = CreateObject("component","cfairbrake").init(api_key = "AIRBRAKE_API_KEY");

The component has several other configurable options. For available options view the `init` method's source or consult the method documentation via the ColdFusion component browser.

### Sending Error Notifications

To send notification to Airbrake.io call the `send` method:

    # Application.cfc
    component {
      ...
      onError( Exception, EventName ) {
        cfairbrake.send(error=arguments.Exception);
      }
      ...
    }
    

Additional details can be logged with the exception information. For available options view the `send` method's source or consult the method documentation via the ColdFusion component browser.



