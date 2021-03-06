/**
* A cool Role entity
*/
component persistent="true" entityName="cbRole" table="cb_role" cachename="cbRole" cacheuse="read-write"{

	// Primary Key
	property name="roleID" fieldtype="id" generator="native" setter="false";
	
	// Properties
	property name="role"  		ormtype="string" notnull="true" length="255" unique="true" default="";	property name="description" ormtype="string" notnull="false" default="" length="500";	
	// M2M -> Permissions
	property name="permissions" singularName="permission" fieldtype="many-to-many" type="array" lazy="extra" orderby="permission" cascade="all" cacheuse="read-write"  
			  cfc="contentbox.model.security.Permission" fkcolumn="FK_roleID" linktable="cb_rolePermissions" inversejoincolumn="FK_permissionID"; 
	
	// Calculated Fields
	property name="numberOfPermissions" formula="select count(*) from cb_rolePermissions rolePermissions where rolePermissions.FK_roleID=roleID";
	property name="numberOfAuthors" 	formula="select count(*) from cb_author author where author.FK_roleID=roleID";
	
	// Non-Persistable Fields
	property name="permissionList" 	persistent="false";
	
	// Constructor
	function init(){
		permissions 	= [];
		permissionList	= '';
		return this;
	}
	
	
	/**
	* Check for permission
	*/
	boolean function checkPermission(required slug){
		// cache list
		if( !len( permissionList ) AND hasPermission() ){
			var q = entityToQuery( getPermissions() );
			permissionList = valueList( q.permission );	
		}
		// checks
		if( listFindNoCase(permissionList, arguments.slug) ){
			return true;
		}
		
		return false;
	}
	
}
