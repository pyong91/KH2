<%@page import="home.beans.FilesDto"%>
<%@page import="home.beans.FilesDao"%>
<%@page import="java.util.List"%>
<%@page import="home.beans.ReplyDto"%>
<%@page import="home.beans.ReplyDao"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="home.beans.BoardDto"%>
<%@page import="home.beans.BoardDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
//	[1]번호 받기 [2]조회수 증가시키고 게시글 불러오기 [3]출력
	int no = Integer.parseInt(request.getParameter("no"));
	BoardDao bdao = new BoardDao();
	BoardDto bdto = bdao.getInfo(no);
	
	String userId = (String)session.getAttribute("id");
	String grade = (String)session.getAttribute("grade");
	
	boolean isMine = userId.equals(bdto.getWriter()); // 사용자ID == 작성자ID
	boolean isAdmin = grade.equals("관리자");
	
//	추가 : Set<Integer> 형태의 저장소를 이용하여 이미 읽은 글은 조회수 증가를 방지
//	[1] 세션에 있는 저장소를 꺼내고 없으면 생성한다
	Set<Integer> memory = (Set<Integer>)session.getAttribute("memory");
	// memory가 없는 경우에는 null 값을 가진다
	
	if(memory == null){
		memory = new HashSet<>();
	}
//	[2] 처리를 수행한다	
	boolean isFirst = memory.add(no);

//	처리를 마치고 저장소를 다시 세션에 저장한다	
	session.setAttribute("memory", memory); // 세션에 셋 저장
	
//	내글이아니면 ==!isMine	
//	처음읽는글이면 == isFirst
	if(!isMine && isFirst){
		bdto.setReadCount(bdto.getReadCount()+1);
		bdao.readCountPlus(no);
	}
	
// 	댓글
	ReplyDao dao = new ReplyDao();
	List<ReplyDto> list = dao.getList(no);
	
// 	파일
	FilesDao fdao = new FilesDao();
	List<FilesDto> flist = fdao.getList(no);
%>

<jsp:include page="/template/header.jsp"></jsp:include>

<div align="center" style="padding-top:10px">
	<table width="70%" border="1px">
		<tr>
			<td><%=bdto.getTitle() %></td>
		</tr>
		<tr>
			<td colspan="2"><%=bdto.getWriter() %></td>
		</tr>		
		<tr height="200">
			<td valign="top" colspan="2"><%=bdto.getContent() %></td>
		</tr>
			<!-- 첨부 파일 시작 -->
	<%if(flist.size()>0) {%>
	<tr>
		<td>
				 <ul>
				 	<%for(FilesDto fdto : flist){ %>
					 	<li>
					 		<!-- 미리보기 출력 -->
					 		<img src="download.do?no=<%=fdto.getFiles_no()%>" width="80" height="50">

					 		<%=fdto.getUploadName()%>
					 		(<%=fdto.getFileSize()%> bytes)

					 		<img src="../image/download.png" width="15" height="15">
					 		<a href="download.do?no=<%=fdto.getFiles_no()%>">
					 			<img src="../image/download.png" width="15" height="15">
					 		</a>
					 	</li>
				 	<%} %>
				 </ul>
		</td>
	</tr>
	<%} %>
	<!-- 첨부 파일 끝 -->
		<tr>
			<td>조회수 : <%=bdto.getReadCount() %>   댓글수 : <%=bdto.getReplyCount() %></td>
		</tr>
	</table>
		
		<!-- 댓글 시작 -->
	<table border="0" width="70%" style="background-color: #F9F9F9;">
		<tr>
			<td colspan="3">
				댓글 목록
			</td>
		</tr>
		<%for(ReplyDto rdto : list) {%>
				<tr>
					<td rowspan="2" width="50px" align="center" valign="middle">
						<img src="<%=request.getContextPath() %>/image/고양이.jpg" width="30px" height="30px">
					</td>
					<td width="100px"><%=rdto.getWriter() %>
						<%if(rdto.getWriter().equals(bdto.getWriter())) {%>
						<font color="red">[작성자]</font>
						<%} %>
					</td>
					<td><%=rdto.getWdateWithFormat() %></td>
					<%if(rdto.getWriter().equals(userId)) {%>
						<td align="right">
							<form action="reply_delete.do" method="post">
								<input type="submit" value="삭제">
								<input type="hidden" name="origin" value="<%=rdto.getOrigin() %>">
								<input type="hidden" name="reply_no" value="<%=rdto.getReply_no() %>">
							</form>
						</td>
					<%} %>
				</tr>
				<tr>
					<td colspan="2" style="border-bottom: 1px dotted;"><%=rdto.getContent() %></td>
				</tr>
			
		<%} %>
	</table>
	<table border="0" width="70%">
		<tr>
			<td>
				<form action="reply_insert.do" method="post">
					<textarea name="content" rows="4" cols="92" required></textarea>
					<input type="submit" value="등록">
					<input type="hidden" name="origin" value="<%=bdto.getNo()%>">
				</form>
			</td>
		</tr>
	</table>
		<!-- 댓글 끝 -->
</div>
<div style="padding: 10px 0px">
	<a href="write.jsp"><input type="button" value="글쓰기"></a>
	<a href="write.jsp?superno=<%= bdto.getNo() %>"><input type="button" value="답글쓰기"></a>
	<%if(isMine || isAdmin) {%>
		<a href="list.jsp"><input type="button" value="목록"></a>
		<a href="edit.jsp?no=<%=no%>"><input type="button" value="수정"></a>	
		<a href="delete.do?no=<%=no%>"><input type="button" value="삭제"></a>
	<%} %>
</div>

<jsp:include page="/template/footer.jsp"></jsp:include>