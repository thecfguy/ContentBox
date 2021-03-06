﻿/**
* I am a cms page entity that totally rocks
*/
component persistent="true" entityname="cbPage" table="cb_page" batchsize="25" extends="BaseContent" cachename="cbPage" cacheuse="read-write"{
	
	// Properties
	property name="pageID" fieldtype="id" generator="native" setter="false";
	property name="layout"	notnull="false" length="200" default="";
	property name="order"	notnull="false" ormtype="integer" default="0" dbdefault="0";
	
	// O2M -> Comments
	property name="comments" singularName="comment" fieldtype="one-to-many" type="array" lazy="extra" batchsize="10" orderby="createdDate"
			  cfc="contentbox.model.comments.Comment" fkcolumn="FK_pageID" inverse="true" cascade="all-delete-orphan"; 
	
	// M20 -> Parent Page loaded as a proxy
	property name="parent" notnull="false" cfc="contentbox.model.content.Page" fieldtype="many-to-one" fkcolumn="FK_parentID" lazy="true";
	// O2M -> Sub Pages inverse
	property name="childPages" singularName="childPage" fieldtype="one-to-many" type="array" lazy="extra" batchsize="25" orderby="createdDate"
			  cfc="contentbox.model.content.Page" fkcolumn="FK_parentID" inverse="true" cascade="all"; 
	
	// Calculated Fields
	property name="numberOfChildren" 			formula="select count(*) from cb_page page where page.FK_parentID=pageID" default="0";
	property name="numberOfComments" 			formula="select count(*) from cb_comment comment where comment.FK_pageID=pageID" default="0";
	property name="numberOfApprovedComments" 	formula="select count(*) from cb_comment comment where comment.FK_pageID=pageID and comment.isApproved = 1" default="0";

	/* ----------------------------------------- ORM EVENTS -----------------------------------------  */
	
	/* ----------------------------------------- PUBLIC -----------------------------------------  */
	
	/**
	* constructor
	*/
	function init(){
		type 			= "page";
		renderedContent = "";
	}
	
	/**
	* Get content id based on implementation
	*/
	any function getContentID(){
		return getPageID();
	}
	
	/**
	* Get the layout or if empty the default convention of "pages"
	*/
	function getLayoutWithDefault(){
		if( len(getLayout()) ){ return getLayout(); }
		return "pages";
	}
	
	
	/*
	* Validate page, returns an array of error or no messages
	*/
	array function validate(){
		var errors = [];
		
		// limits
		HTMLKeyWords 		= left(HTMLKeywords,160);
		HTMLDescription 	= left(HTMLDescription,160); 
		passwordProtection 	= left(passwordProtection,100);
		title				= left(title,200);
		slug				= left(slug,200);
		
		// Required
		if( !len(title) ){ arrayAppend(errors, "Title is required"); }
		if( !len(content) ){ arrayAppend(errors, "Content is required"); }
		//if( !len(layout) ){ arrayAppend(errors, "Layout is required"); }
		
		return errors;
	}
	
	/**
	* is loaded?
	*/
	boolean function isLoaded(){
		return len( getPageID() );
	}
	
	/**
	* Get parent ID if set or empty if none
	*/
	function getParentID(){
		if( hasParent() ){ return getParent().getPageID(); }
		return "";
	}
	
	/**
	* Get parent name or empty if none
	*/
	function getParentName(){
		if( hasParent() ){ return getParent().getTitle(); }
		return "";
	}
	
	/**
	* Get recursive slug paths to get ancestry
	*/
	function getRecursiveSlug(separator="/"){
		var pPath = "";
		if( hasParent() ){ pPath = getParent().getRecursiveSlug(); }
		return pPath & arguments.separator & getSlug();
	}
	
}