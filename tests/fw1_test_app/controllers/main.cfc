component {
	
	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}
	
	public void function default( rc ) {
		rc.when = now(); // set when for service argument
		// queue up a specific service (formatter.longdate) with named result (today)
		variables.fw.service( 'formatter.longdate', 'today' );
	}

	public void function bad_entity( rc ) {
		
	}

	public void function bad_include( rc ) {
		
	}

	public void function bad_property( rc ) {
		
	}

	public void function bad_sql( rc ) {
		
	}

	public void function bad_syntax( rc ) {
		
	}

	public void function divide_by_zero( rc ) {
		
	}

	public void function null_pointer( rc ) {
		
	}
	
}