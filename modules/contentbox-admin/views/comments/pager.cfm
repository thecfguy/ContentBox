﻿<cfoutput>
<div id="pagerComments">
<!--- Loader --->
<div class="loaders floatRight" id="commentsPagerLoader">
	<img src="#prc.cbRoot#/includes/images/ajax-loader-blue.gif" alt="loader"/>
</div>
<!--- Paging --->
<cfif prc.commentPager_pagination>
	#prc.commentPager_pagingPlugin.renderit(prc.commentPager_commentsCount,prc.commentPager_pagingLink)#
</cfif>
#html.startForm(name="commentPagerForm")#
<!--- comments --->
<table name="comments_pager" id="comments_pager" class="tablesorter" width="100%">
	<thead>
		<tr>
			<th width="200">Author</th>
			<th>Comment</th>
			<th width="115" class="center">Date</th>			
			<th width="90" class="center">Actions</th>
		</tr>
	</thead>
	
	<tbody>
		<cfloop array="#prc.commentPager_comments#" index="comment">
		<tr <cfif !comment.getIsApproved()>class="unapproved"</cfif> data-commentID="#comment.getCommentID()#">
			<td>
				#getMyPlugin(plugin="Avatar",module="contentbox").renderAvatar(email=comment.getAuthorEmail(),size="30")#
				&nbsp;<a href="mailto:#comment.getAUthorEmail()#" title="#comment.getAUthorEmail()#">#comment.getAuthor()#</a>
				<br/>
				<cfif len(comment.getAuthorURL())>
					<img src="#prc.cbRoot#/includes/images/link.png" alt="link" /> 
					<a href="<cfif NOT findnocase("http",comment.getAuthorURL())>http://</cfif>#comment.getAuthorURL()#" title="Open URL" target="_blank">
						#comment.getAuthorURL()#
					</a>
					<br />
				</cfif>
				<img src="#prc.cbRoot#/includes/images/database_black.png" alt="server" /> 
				<a href="#prc.cbSettings.cb_comments_whoisURL#=#comment.getAuthorIP()#" title="Get IP Information" target="_blank">#comment.getauthorIP()#</a>
			</td>
			<td>
				<img src="#prc.cbRoot#/includes/images/page.png" alt="link"/> <strong>#comment.getParentTitle()#</strong> 
				<br/>
				#left(comment.getContent(),prc.cbSettings.cb_comments_maxDisplayChars)#
				<cfif len(comment.getContent()) gt prc.cbSettings.cb_comments_maxDisplayChars>....<strong>more</strong></cfif>
			</td>
			<td class="center">
				#comment.getDisplayCreatedDate()#
			</td>
			<td class="center">
				<cfif prc.oAuthor.checkPermission("COMMENTS_ADMIN")>
					<!--- Approve/Unapprove --->
					<cfif !comment.getIsApproved()>
						<a href="javascript:commentPagerChangeStatus('approve','#comment.getCommentID()#')" title="Approve Comment"><img id="status_#comment.getCommentID()#" src="#prc.cbroot#/includes/images/hand_pro.png" alt="approve" /></a>
					<cfelse>
						<a href="javascript:commentPagerChangeStatus('moderate','#comment.getCommentID()#')" title="Unapprove Comment"><img id="status_#comment.getCommentID()#" src="#prc.cbroot#/includes/images/hand_contra.png" alt="unapprove" /></a>
					</cfif>
					&nbsp;	
					<!--- Delete Command --->
					<a title="Delete Comment Permanently" href="javascript:commentPagerRemove('#comment.getCommentID()#')"><img id="delete_#comment.getCommentID()#" src="#prc.cbroot#/includes/images/delete.png" border="0" alt="delete"/></a>
					&nbsp;
				</cfif>
				<!--- View in Site --->
				<a href="#prc.CBHelper.linkComment(comment)#" title="View Comment In Site" target="_blank"><img src="#prc.cbroot#/includes/images/eye.png" alt="edit" border="0"/></a>
			</td>
		</tr>
		</cfloop>
	</tbody>
</table>
#html.endForm()#
</div>
<!--- Custom JS --->
<script type="text/javascript">
$(document).ready(function() {
	$("tr:even").addClass("even");
	// quick look
	$("##comments_pager").find("tr").bind("contextmenu",function(e) {
	    if (e.which === 3) {
			if( $(this).attr('data-commentID') != null ){
	    		openRemoteModal('#event.buildLink(prc.xehCommentPagerQuickLook)#', {commentID: $(this).attr('data-commentID')});
				e.preventDefault();
			}
	    }
	});
});
<cfif prc.oAuthor.checkPermission("COMMENTS_ADMIN")>
function commentPagerChangeStatus(status,recordID){
	// update icon
	$('##status_'+recordID).attr('src','#prc.cbRoot#/includes/images/ajax-spinner.gif');
	// ajax status change
	$.post("#event.buildlink(linkTo=prc.xehCommentPagerStatus)#",{commentStatus:status,commentID:recordID},function(data){
		hideAllTooltips();
		commentPagerLink(#rc.page#);
	});
}
function commentPagerRemove(recordID){
	if( !confirm("Really permanently delete comment?") ){ return; }
	$('##delete_'+recordID).attr('src','#prc.cbRoot#/includes/images/ajax-spinner.gif');
	// ajax remove change
	$.post("#event.buildlink(linkTo=prc.xehCommentPagerRemove)#",{commentID:recordID},function(data){
		hideAllTooltips();
		commentPagerLink(#rc.page#);
	});	
}
</cfif>
function commentPagerLink(page){
	$("##commentsPagerLoader").fadeIn("fast");
	$('##pagerComments')
		.load('#event.buildLink(prc.xehCommentPager)#',
			{commentPager_entryID:'#prc.commentPager_entryID#',commentPager_pageID:'#prc.commentPager_pageID#', page:page, commentPager_pagination: '#prc.commentPager_pagination#'},function() {
			hideAllTooltips();
			$("##commentsPagerLoader").fadeOut();
			activateTooltips();
	});
}
</script>
</cfoutput>