<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<meta charset="UTF-8">
	<title>WebSocket Data</title>
	<style>
		.container{
			width: 800px;
			margin: 0 auto;
			padding: 25px
		}
		.container h2{
			text-align: left;
			padding: 5px 5px 5px 15px;
			color: #FFBB00;
			border-left: 3px solid #FFBB00;
			margin-bottom: 20px;
		}
		.containerBottom{
			width: 500px;
			height: 100px;
			margin: 0 auto;
			padding: 25px
		}
		.btn1{
			float: left;
		}
		.btn2{
			float: left;
		}
		.btn3{
			float:left;
		}
		.innerContainer0{
			width: 30%;
			float: left;
			margin: 0 auto;
			padding: 5px
		}
		.innerContainer1{
			width: 30%;
			float: left;
			margin: 0 auto;
			padding: 5px
		}
		.innerContainer2{
			width: 30%;
			float: left;
			margin: 0 auto;
			padding: 5px
		}
		.chatting{
			background-color: #000;
			width: 100%;
			height: 500px;
			overflow: auto;
		}
		.chatting p{
			color: #fff;
			text-align: left;
		}
		input{
			width: 330px;
			height: 25px;
		}
		#yourMsg{
			display: none;
		}
	</style>
</head>
<!-- 부트스트랩 toastr 라이브러리 -->
<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
<script type="text/javascript">
	var ws;
	
	$(document).ready(function(){
		wsOpen();
		$("#yourMsg").show();
	});

	function wsOpen(){
		ws = new WebSocket("ws://" + location.host + "/chatting");
		wsEvt();
	}
		
	function wsEvt() {
		// onopen: 웹 소켓이 열리면 호출
		ws.onopen = function(data){
			//소켓이 열리면 초기화 세팅하기
		}
		// onmessage: 메시지가 도착하면 호출
		ws.onmessage = function(data) {
			var msg = data.data;
			$("#chatting0").prepend("<p>" + msg + "</p>");
			// ex: { "latteId":"latte_1_A", "tmp":"28.00", "hum":"80.00" }
			// ex2:{"area":"1_A","msgType":"command","from":"MAIN Server","cmd":"AIR_ON"}

			
			if(msg != null && msg.trim() != ''){
				var obj = JSON.parse(msg);
				
				switch(obj.msgType){
				// 메시지 타입이 ssRaw(Sensor Raw)일 경우
				// 화면에 센서데이터 표시
				case "ssRaw":
					var area = obj.latteId.substring(6, 9);
					drawData(obj,area);
					break;
				// 메시지 타입이 command일 경우
				// 버튼의 on/off 상태 업데이트
				case "command":
					setButtonStateRealTime(obj);
					break;
				case "disaster":
					// 비상대피로
					// display:none -> block, delay 시간 설정
					// 비상대피로 위치 보이기
					$(".intro-banner-vdo-play-btn").css("display", "block");
				    $(".escape_road_container1").css("display","block");
				    $(".escape_road2").css("display","block");
				    setTimeout(function() {
				       $(".escape_road_container3").css("display","block");
				    }, 1000);
				    setTimeout(function() {
					   $(".escape_road4").css("display","block");
					}, 1800);
				    setTimeout(function() {
				       $(".escape_road_container5").css("display","block");
				    }, 2500);
				    setTimeout(function() {
					   $(".escape_road6").css("display","block");
					}, 3300);
				    setTimeout(function() {
					   $(".escape_road_container7").css("display","block");
					}, 3600);
				    setTimeout(function() {
					   $(".escape_road8").css("display","block");
					}, 4500);
				    setTimeout(function() {
					   $(".escape_road9").css("display","block");
					}, 2300);
				     
				    // 경보 알림 toast
				    // toastr(부트스트랩의 toast 라이브러리)의 option 설정
					toastr.options = {
				    	 "closeButton": true,
						 "debug": false,
						 "newstOnTop": false,
						 "positionClass": "toast-top-full-width",
						 "onclick": null,
						 "showDuration": 300,
						 "Hide Duration": 1000,
						 "showEasing": "swing",
						 "hideEasing" : "linear",
						 "fadeIn": 300,
						 "fadeOut": 1000,
						 "timeOut": 100000, // toastr가 보여지는 시간
						 "extendedTimeOut": 1000,
						 "showMethod": "slideDown",
						 "hideMethod": "fadeOut"
						 }
				    // toastr 띄우기(error 타입)
					toastr.error("<div class='text-center'>대피로 개방</div>", "<div class='text-center'>지진 경보</div>");
					break;
					
				} // end switch
				
				$("#chatting1").prepend("<p>" + obj.tmp + "</p>");
				$("#chatting2").prepend("<p>" + obj.hum + "</p>");
				
			} // end if
		} // end onMessage
		
		// 실시간 데이터 반영 및 상태에 따른 색상 표시
		function drawData(obj, area){
			var state = false;
			if(obj.tmp != "undefined"){
				$("#" + area + "_S_TEMP").text(obj.tmp);
				$("#P_" + area + "_S_TEMP span").text(obj.tmp);
				if(obj.tmp <= 18){
 					$("#" + area + "_S_TEMP").css("background-color", "#f7b924");
					$("#P_" + area + "_S_TEMP_bdg").removeClass();
					$("#P_" + area + "_S_TEMP_bdg").addClass("badge badge-pill badge-warning");
					$("#P_" + area + "_S_TEMP_bdg").text("warning");
					
				}else if(obj.tmp > 18 && obj.tmp <= 21){
					$("#" + area + "_S_TEMP").css("background-color", "transparent");
					$("#P_" + area + "_S_TEMP_bdg").removeClass();
					$("#P_" + area + "_S_TEMP_bdg").addClass("badge badge-pill badge-focus");
					$("#P_" + area + "_S_TEMP_bdg").text("normal");
					
				}else if(obj.tmp > 21){
 					$("#" + area + "_S_TEMP").css("background-color", "#f42a2f");
					$("#P_" + area + "_S_TEMP_bdg").removeClass();
					$("#P_" + area + "_S_TEMP_bdg").addClass("badge badge-pill badge-danger");
					$("#P_" + area + "_S_TEMP_bdg").text("danger");
				}
			}
			if(obj.hum != "undefined"){
				$("#" + area + "_S_HUM").text(obj.hum);
				$("#P_" + area + "_S_HUM span").text(obj.hum);
				if(obj.hum <= 40){
					$("#" + area + "_S_HUM").css("background-color", "#f7b924");
					$("#P_" + area + "_S_HUM_bdg").removeClass();
					$("#P_" + area + "_S_HUM_bdg").addClass("badge badge-pill badge-warning");
					$("#P_" + area + "_S_HUM_bdg").text("warning");
					
				}else if(obj.hum > 40 && obj.hum <= 40.99){
					$("#" + area + "_S_HUM").css("background-color", "transparent");
					$("#P_" + area + "_S_HUM_bdg").removeClass();
					$("#P_" + area + "_S_HUM_bdg").addClass("badge badge-pill badge-focus");
					$("#P_" + area + "_S_HUM_bdg").text("normal");
				
				}else if(obj.hum > 40.99){
					$("#" + area + "_S_HUM").css("background-color", "#f42a2f");
					$("#P_" + area + "_S_HUM_bdg").removeClass();
					$("#P_" + area + "_S_HUM_bdg").addClass("badge badge-pill badge-danger");
					$("#P_" + area + "_S_HUM_bdg").text("danger");
				}
			}
			if(obj.dst != "undefined"){
				$("#" + area + "_S_DUST").text(obj.dst);
				$("#P_" + area + "_S_DUST span").text(obj.dst);
				if(obj.dst <= 30){
					// 미세먼지가 상태가 매우 좋음일 경우 파란색으로 표시
					$("#" + area + "_S_DUST").css("background-color", "#00aeef");
					$("#P_" + area + "_S_DUST_bdg").removeClass();
					$("#P_" + area + "_S_DUST_bdg").addClass("badge badge-pill badge-info");
					$("#P_" + area + "_S_DUST_bdg").text("good");
					
				}else if(obj.dst > 30 && obj.dst <= 80){
					$("#" + area + "_S_DUST").css("background-color", "transparent");
					$("#P_" + area + "_S_DUST_bdg").removeClass();
					$("#P_" + area + "_S_DUST_bdg").addClass("badge badge-pill badge-focus");
					$("#P_" + area + "_S_DUST_bdg").text("normal");
					
				}else if(obj.dst > 80){
					$("#" + area + "_S_DUST").css("background-color", "#f42a2f");
					$("#P_" + area + "_S_DUST_bdg").removeClass();
					$("#P_" + area + "_S_DUST_bdg").addClass("badge badge-pill badge-danger");
					$("#P_" + area + "_S_DUST_bdg").text("danger");
				}
			}
			if(obj.lgt != "undefined"){
				$("#" + area + "_S_ILLM").text(obj.lgt);
				$("#P_" + area + "_S_ILLM span").text(obj.lgt);
				if(obj.lgt <= 300){
					$("#" + area + "_S_ILLM").css("background-color", "#f7b924");
					$("#P_" + area + "_S_ILLM_bdg").removeClass();
					$("#P_" + area + "_S_ILLM_bdg").addClass("badge badge-pill badge-warning");
					$("#P_" + area + "_S_ILLM_bdg").text("warning");
					
				}else if(obj.lgt > 300 && obj.lgt <= 600){
					$("#" + area + "_S_ILLM").css("background-color", "transparent");
					$("#P_" + area + "_S_ILLM_bdg").removeClass();
					$("#P_" + area + "_S_ILLM_bdg").addClass("badge badge-pill badge-focus");
					$("#P_" + area + "_S_ILLM_bdg").text("normal");
					
				}else if(obj.lgt > 600){
					$("#" + area + "_S_ILLM").css("background-color", "#f42a2f");
					$("#P_" + area + "_S_ILLM_bdg").removeClass();
					$("#P_" + area + "_S_ILLM_bdg").addClass("badge badge-pill badge-danger");
					$("#P_" + area + "_S_ILLM_bdg").text("danger");
				}
				
				if(obj.tmp > 18 && obj.tmp <= 21 && obj.hum > 40 && obj.hum <= 40.99 && obj.dst <= 80 && obj.lgt > 300 && obj.lgt <= 600){
					changeStateLightColor(area, false);
				}else{
					changeStateLightColor(area, true);
				}
			}
		}

		document.addEventListener("keypress", function(e){
			if(e.keyCode == 13){ //enter press
				send();
			}
		});
	}

	function send() {
		var msg = $("#chatting").val();
		ws.send(msg);
		$('#chatting').val("");
	}
	
	// 버튼 체크 상태 변경(DB 데이터 반영)
	// 버튼 id 예) 1_A_D_AIR
	function setButtonState(){
		<c:forEach var="d" items="${devicelist}">
			// on인 상태일 때 버튼 색상 유지
			<c:choose>
			    <c:when test="${d.DEVICE_STAT eq 'ON'}">
					// `.click()`은 제어명령 이벤트가 발생하는 문제 > 이벤트 없이 버튼 상태만 바뀌도록 수정 
	 				$("input[id='${d.DEVICE_ID}']").prop("checked", true);	
			    </c:when>
			    <c:otherwise>
			    	$("input[id='${d.DEVICE_ID}']").prop("checked", false);	
			    </c:otherwise>
			</c:choose>
			
			//$("#${d.DEVICE_ID}").text("${d.DEVICE_STAT}");
		</c:forEach>
	}
	
	// 버튼 체크 상태 변경(자동제어 실시간 데이터 반영)
	// {"area":"1_A","msgType":"command","from":"MAIN Server","cmd":"AIR_ON"}
	function setButtonStateRealTime(obj){
		var cmdSplit = obj.cmd.split('_');
		var deviceId = obj.area + "_D_" + cmdSplit[0];	// 1_A_D_AIR
		switch(cmdSplit[1]){
		case "ON":
			$("input[id=" + deviceId + "]").prop("checked", true);
			break;
		case "OFF":
			$("input[id=" + deviceId + "]").prop("checked", false);
			break;
		}
	}
		
	// 깜박임 색상 변경
	function changeStateLightColor(area, state){
		if(state){
			$("#tt_" + area).css("background", "#ff0000");
			$("#tt_" + area).css("animation","k2 1.75s 1s ease-out infinite");
		}else{
			$("#tt_" + area).css("background", "#1a8cff");
			$("#tt_" + area).css("animation","k1 1.75s 1s ease-out infinite");
		}
	}
	
	$(document).ready(function() {
		// 실시간 데이터 text 삽입 테스트, 배경색 변경 테스트 ------------------------
		//$("#1_A_S_TEMP span").text("12345");
		//$('#1_A_S_HUM span').css("color", "#e0201a");
		/*
		$("#tt_1_B").css("background", "#ff0000");
		$("#tt_1_B").css("animation","k2 1.75s 1s ease-out infinite");
		$("#1_B_S_HUM").css('background-color', '#f42a2F');
		$("#1_B_S_DUST").css('background-color', '#f42a2f');
		$("#1_B_S_ILLM").css('background-color', '#f7b924');
		$("#1_A_S_DUST").css('background-color', '#00aeef');

		$("#P_1_B_S_HUM").css('color', '#f42a2F');
		$("#P_1_B_S_DUST").css('color', '#f42a2f');
		$("#P_1_B_S_ILLM").css('color', '#f7b924');
		$("#P_1_A_S_DUST").css('color', '#00aeef');*/

		
		// ----- 테스트 끝 ------------------------------------------------
		
		setButtonState();
		
		$('#alert').click(function(){
			$.ajax({
				url:'alert',
				success:function(data){
					alert('Send Complete...');
				}
			});
		});
		
	});
	
</script>
<body>

	<!-- 층별 제어 화면 -->
	<div class="app-main__inner">
		<jsp:include page="controlFloors.jsp"></jsp:include>
	</div>

	<div id="container" class="container">
		<div class="innerContainer0">
			<h2>raw data</h2>
			<div id="chatting0" class="chatting"></div>
		</div>
		<div class="innerContainer1">
			<h2>센서1: 온도</h2>
			<div id="chatting1" class="chatting"></div>
		</div>
		<div class="innerContainer2">
			<h2>센서2: 습도</h2>
			<div id="chatting2" class="chatting"></div>
		</div>
	</div>



	<div id="container" class="containerBottom">
		<div class="btn3">
			<a class="btn" id= "alert" href = "#">Alert</a>
		</div>
		
		<div id="yourMsg">
			<table class="inputTable">
				<tr>
					<th>Data from Arduino</th>
					<th><input id="chatting" value='{ "tmp":"28", "hum":"80" }'></th>
					<th><button onclick="send()" id="sendBtn">보내기</button></th>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>