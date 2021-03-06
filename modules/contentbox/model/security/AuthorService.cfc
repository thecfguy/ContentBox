﻿/**
* Service to handle auhtor operations.
*/
component extends="coldbox.system.orm.hibernate.VirtualEntityService" accessors="true" singleton{
	
	// User hashing type
	property name="hashType";
	
	/**
	* Constructor
	*/
	AuthorService function init(){
		// init it
		super.init(entityName="cbAuthor");
	    setHashType( "SHA-256" );
	    
		return this;
	}
	
	/**
	* Save an author with extra pizazz!
	*/
	function saveAuthor(author,passwordChange=false){
		// hash password if new author
		if( !arguments.author.isLoaded() OR arguments.passwordChange ){
			arguments.author.setPassword( hash(arguments.author.getPassword(), getHashType()) );
		}
		// save the author
		save( author );
	}
	
	/**
	* Author search by name, email or username
	*/
	function search(criteria){
		var params = {criteria="%#arguments.criteria#%"};
		var r = executeQuery(query="from cbAuthor where firstName like :criteria OR lastName like :criteria OR email like :criteria",params=params,asQuery=false);
		return r;
	}
	
	/**
	* Username checks for authors
	*/
	boolean function usernameFound(required username){
		var args = {"username" = arguments.username};
		return ( countWhere(argumentCollection=args) GT 0 );
	}

}