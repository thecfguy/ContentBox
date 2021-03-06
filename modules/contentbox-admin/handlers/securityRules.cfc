﻿/**
* Manage Security Rules
*/
component extends="baseHandler"{

	// Dependencies
	property name="ruleService"		inject="id:securityRuleService@cb";
	
	// index
	function index(event,rc,prc){
		// Exit Handler
		prc.xehSaveRule 	= "#prc.cbAdminEntryPoint#.securityRules.save";
		prc.xehRemoveRule	= "#prc.cbAdminEntryPoint#.securityRules.remove";
		prc.xehEditorRule	= "#prc.cbAdminEntryPoint#.securityRules.editor";
		prc.xehRuleOrder	= "#prc.cbAdminEntryPoint#.securityRules.changeOrder";
		
		// get content pieces
		prc.rules = ruleService.getAll(sortOrder="order asc");
		
		// tab
		prc.tabSystem				= true;
		prc.tabSystem_securityRules	= true; 
		
		// view
		if( event.valueExists("ajax") ){
			event.setView(view="securityRules/rulesTable",noLayout=true);
		}
		else{
			event.setView("securityRules/index");
		}
	}
	
	// order change
	function changeOrder(event,rc,prc){
		var results = false;
		var rule = ruleService.get(rc.ruleID);
		if( !isNull( rule ) ){
			rule.setOrder( rc.order );
			ruleService.saveRule( rule );
			results = true;
		}		
		event.renderData(type="json",data=results);
	}
		
	// editor
	function editor(event,rc,prc){
		
		// tab
		prc.tabSystem				= true;
		prc.tabSystem_securityRules	= true; 
		
		// get new or persisted
		prc.rule  = ruleService.get( event.getValue("ruleID",0) );
		
		// exit handlers
		prc.xehRuleSave = "#prc.cbAdminEntryPoint#.securityRules.save";
		
		// view
		event.setView(view="securityRules/editor");
	}
	
	// save rule
	function save(event,rc,prc){
		
		// populate and get content
		var oRule = populateModel( ruleService.get(id=rc.ruleID) );
		// validate it
		var errors = oRule.validate();
		if( !arrayLen(errors) ){
			// announce event
			announceInterception("cbadmin_preSecurityRulesSave",{rule=oRule,ruleID=rc.ruleID});
			// save rule
			ruleService.saveRule( oRule );
			// announce event
			announceInterception("cbadmin_postSecurityRulesSave",{rule=oRule});
			// Message
			getPlugin("MessageBox").info("Security Rule saved! Isn't that awesome!");
		}
		else{
			getPlugin("MessageBox").warn(errorMessages=errors);
		}
		
		// relocate back to editor
		setNextEvent(prc.xehsecurityRules);
	}
	
	// remove
	function remove(event,rc,prc){
		event.paramValue("ruleID","");
		// check for length
		if( len(rc.ruleID) ){
			// announce event
			announceInterception("cbadmin_preSecurityRulesRemove",{ruleID=rc.ruleID});
			// remove using hibernate bulk
			ruleService.deleteByID( listToArray(rc.ruleID) );
			// announce event
			announceInterception("cbadmin_postSecurityRulesRemove",{ruleID=rc.ruleID});
			// message
			getPlugin("MessageBox").info("Security Rule Removed!");
		}
		else{
			getPlugin("MessageBox").warn("No ID selected!");
		}
		setNextEvent(event=prc.xehsecurityRules);
	}
	
}
