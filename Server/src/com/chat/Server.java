package com.chat;

import java.io.FileReader;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;

import org.java_websocket.client.WebSocketClient;
import org.json.simple.JSONObject;

import com.msg.DeviceVO;
import com.msg.Msg;
import com.ws.WsClient;

public class Server {
	// 멤버 변수 선언
	int port;
	String address;
	String id;
	static String wsIp;
	static int wsPort;

	// 루트 로컬의 my.properties 저장할 변수
	static int tcpipPort;
	static String oracleHostname;
	static String oracleId;
	static String oraclePwd;

	ServerSocket serverSocket; // ServerSocket 객체
	static WebSocketClient WsClient; // WebSocket Client 객체 (대시보드에 데이터 전송)
	static AutoController autoController;

	// client들의 메세지를 받는다.
	HashMap<String, ObjectOutputStream> maps; // HashMap<IP주소, 해당 아웃풋스트림>
	HashMap<String, String> idipMaps; // HashMap<클라이언트id, 클라이언트ip> for sendTarget
										// ex) <latte_1_A, 192.168.1.11>
	static HashMap<String, DeviceVO> deviceStat;
	static boolean isConnectWebsocket = false; // WebSocket 연결여부 확인 FLAG

	// sendTarget 위한 ip주소 선언 >> hashMap 관리방식으로 변경하기!
	String targetIp = null;
	String targetIp2 = null;
	String targetIp3 = null; // Tablet ip

	// 기본 생성자
	public Server() {
	}

	// 포트를 담은 생성자
	public Server(int port) {
		this.port = port;
		maps = new HashMap<>();
		idipMaps = new HashMap<>();
		deviceStat = new HashMap<>();

	}

	// 서버를 시작하는 startServer() 함수
	public void startServer() throws Exception {
		serverSocket = new ServerSocket(port); // serverSocket에 포트를 입력하여 선언
		System.out.println("Strat Server ..."); // "서버를 시작합니다."

		// 네트워크는 스레드에서 동작시켜야 한다.
		Runnable r = new Runnable() {

			@Override
			public void run() {
				while (true) {
					try {
						Socket socket = null; // 소켓 초기화
						System.out.println("Ready Server ..."); // "서버를 준비합니다..."
						socket = serverSocket.accept(); // 클라이언트를 기다린다.

						// 접속한 client들의 ip 주소 확인
						System.out.println(socket.getInetAddress()); // IP 주소 출력
						makeOut(socket); // 각각의 client들의 outputstream을 hashmap에 저장

						// client가 들어올 때마다 새로운 스레드가 생성
						new Receiver(socket).start();

					} catch (Exception e) {
						e.printStackTrace();
					}
				} // end while
			}
		};

		new Thread(r).start();

	}

	// 각각의 client들의 outputstream을 hashmap에 저장한다.
	public void makeOut(Socket socket) throws IOException {
		ObjectOutputStream oo; // 아웃풋스트림 객체인 oo 선언
		oo = new ObjectOutputStream(socket.getOutputStream()); // 소켓으로부터 아웃풋 스트림을 가져와 대입
		maps.put(socket.getInetAddress().toString(), oo); // IP주소와 아웃풋스트림을 해쉬맵에 저장
		System.out.println("접속자수: " + maps.size()); // 해쉬맵의 크기로 접속자 수를 출력
	}

	// client들을 받는다.
	// sendMsg를 호출하여 메세지 객체를 받는다.
	// Receiver 쓰레드
	class Receiver extends Thread {
		Socket socket; // 소켓
		ObjectInputStream oi; // 인풋스트림

		// 소켓을 담은 Receiver 생성자
		public Receiver(Socket socket) throws IOException {
			this.socket = socket;
			oi = new ObjectInputStream(this.socket.getInputStream()); // 소켓으로부터 인풋스트림을 가져와 oi에 대입
		}

		@Override
		public void run() {
			while (oi != null) {
				if (!isConnectWebsocket) {
					// chat2 웹소켓 서버 연결여부 확인
					System.out.println("WebSocket Connection Start ...");
					connectWebsocketServer();
				}
				Msg msg = null;
				try {
					msg = (Msg) oi.readObject();
					System.out.println(msg);
					String[] split;
					String cmdTargetLatteId;
					String cmdTargetTabId;

					switch (msg.getType()) { // first :: ssRaw :: command
					case "first":
						System.out.println("First");
						idipMaps.put(msg.getId(), socket.getInetAddress().toString());
						sendTarget(idipMaps.get(msg.getId()), // 발송대상 IP
								"MAIN Server", // 발송 주체
								msg.getType(), // 메시지 유형
								"SUCCESS Connection (FROM Server)"); // 메시지
						// 해쉬맵 idipMaps 전체 출력
						for (String key : idipMaps.keySet()) {
							String value = idipMaps.get(key);
							System.out.println(key + " ::: " + value);
						}
						break;
					case "ssRaw":
						String autoControlCmd = autoController.whatToDo(msg.getMsg());

						if (autoControlCmd.equals("nothing")) { // 제어할 내용 없음
							System.out.println("Auto Controller : Fine! Nothing to control");
							break;
						} else {
							// 제어명령 반환받음
							// 반환값 예: 1_A_D_AIR_ON
							// 전송 대상 : 라떼, 태블릿, DB
							System.out.println("Auto Contoller : " + autoControlCmd);
							split = autoControlCmd.split("_");
							cmdTargetLatteId = "latte_" + split[0] + "_" + split[1];
							cmdTargetTabId = "tablet_" + split[0] + "_" + split[1];
							String cmdArea = split[0] + "_" + split[1];
							String cmdAction = split[3] + "_" + split[4];

							// Target : Latte
							if (idipMaps.get(cmdTargetLatteId) != null) {
								sendTarget(idipMaps.get(cmdTargetLatteId), "MAIN Server (Auto)", // 발송 주체
										"command", // 메시지 유형
										cmdAction); // 제어명령 ex) AIR_ON
							}

							// Target : Tablet
							if (idipMaps.get(cmdTargetTabId) != null) {
								sendTarget(idipMaps.get(cmdTargetTabId), "MAIN Server (Auto)", // 발송 주체
										"command", // 메시지 유형
										autoControlCmd); // 제어명령 ex) 1_A_D_AIR_ON
							}

							// Target : Web DashBoard
							// 웹소켓으로 전송 : can > Client.java에서 웹소켓으로 보내는거랑 똑같은 방식으로 보내야할듯
							// json으로 변환하여 전송
							if (isConnectWebsocket) {
								String cmdMsgForWeb = convertJson(cmdArea, cmdAction).toJSONString();
								WsClient.send(cmdMsgForWeb);
								System.out.println("웹소켓 전송 완료 : " + cmdMsgForWeb);
							}

						}

						// (라떼)에서 오는 센서데이터 > 안드로이드로 Send Target
						if (idipMaps.get("mobileApp") != null) {
							sendTarget(idipMaps.get("mobileApp"), msg.getId(), msg.getType(), msg.getMsg());
						}
						break;
					case "command": // (웹),(안드로이드)에서 오는 제어명령 > 라떼로 Send Target
						// 라떼 구분 ID : 1_A, 2_A, 2_B
						// 제어명령의 예: 1_A_D_AIR_OFF
						split = msg.getMsg().split("_");
						cmdTargetLatteId = "latte_" + split[0] + "_" + split[1];
						cmdTargetTabId = "tablet_" + split[0] + "_" + split[1];

						if (idipMaps.get(cmdTargetLatteId) != null) { // Target : Latte
							String cmdAction = split[2] + "_" + split[3] + "_" + split[4];
							sendTarget(idipMaps.get(cmdTargetLatteId), msg.getId(), msg.getType(), cmdAction);
						}

						if (idipMaps.get(cmdTargetTabId) != null) { // Target : Tablet
							sendTarget(idipMaps.get(cmdTargetTabId), msg.getId(), msg.getType(), msg.getMsg());
						}

						if (idipMaps.get("mobileApp") != null) { // Target : Mobile App
							sendTarget(idipMaps.get("mobileApp"), msg.getId(), msg.getType(), msg.getMsg());
						}
						break;
					case "etc":
						// 기타 메시지 처리
						System.out.println("기타메시지: " + msg);
						break;
					}

					// =========================== Legacy ==================================
					switch (msg.getMsg()) {
					case "q": // "q" 입력시
						throw new Exception(); // 강제로 exception을 내서 client를 삭제한다.
//					case "byeAndroid":
//						System.out.println("bye Android");
//						throw new Exception();
//					case "iamAndroid": 									// Hand Shake 메시지로 sendTarget 실행할 IP 저장
//						targetIp = socket.getInetAddress().toString();
//						System.out.println("ANDROID's IP" + targetIp);
//						sendTarget(targetIp, "Connected");
//						break;
//					case "iamLatte01":
//						targetIp2 = socket.getInetAddress().toString();
//						System.out.println("LATTE'S IP" + targetIp2);
//						break;
//					case "iamTablet":
//						targetIp3 = socket.getInetAddress().toString();
//						System.out.println("TABLET'S IP" + targetIp3);
//						break;

					}
//					sendMsg(msg);
					// ▲ 전체 클라이언트에 전송하면 중복 데이터 주고받고 난리나는 문제의 원인
					// sendTarget으로 특정 클라이언트에만 데이터 전송
					// 지금 여기선 모바일앱이 sendTarget 대상
					// 2020-11-18(재현)
					// To-do : 로직 설계 제대로 해서 Null Exception 해결
					// 원인 : 안드로이드 앱종료/재실행 액션 인지가 잘 안됨
					// 2020-12-02 (로직설계 개선)
					// 1. 새로운 Msg VO로 Msg Type 구분
					// 2. idipMaps 해시맵 <클라이언트id, IP주소>을 생성하여 각 클라이언트에 대한 IP 주소 관리
					// 3. 이를 활용하여 sendTarget 함으로써 메시지 전송 안정화
					if (targetIp != null) { // 센서데이터 > 안드로이드 전송
//						sendTarget(targetIp,msg.getMsg());
//						System.out.println("To 안드로이드: "+ msg.getMsg());
//					}
//					if(msg.getId().equals("[WEB]") && targetIp2 != null) {
//						sendTarget(targetIp2,msg.getMsg()); // to Latte
//						System.out.println("웹 > 라떼: "+ msg.getMsg());
//					}
//					else if(msg.getId().equals("[osh_switch]") && targetIp2 != null) {
//						sendTarget(targetIp2,msg.getMsg());	// to Latte
//						System.out.println("안드로이드 > 라떼: "+ msg.getMsg());
					} else if (msg.getId().equals("[WEB]") && targetIp3 != null) {
//						sendTarget(targetIp3,msg.getMsg());	// to Tablet
						System.out.println("웹 > 태블릿: " + msg.getMsg());
					}
				} catch (Exception e) { // client가 갑자기 접속 중단된 경우
					// 해쉬맵에서 연결된 IP주소 삭제
					e.printStackTrace();
					maps.remove(socket.getInetAddress().toString());

					// idipMaps는 IP주소가 Value값이므로 위의 방법처럼 삭제할 수 없음
					// 따라서 Value 값으로 Key값을 찾아 삭제한다.
					// ===================== 그런데 =====================
					// AWS에 올려서 돌릴 경우 같은 AP로 다중 기기를 접속하면
					// 똑같은 Public IP로 잡힐것 같음
					// 이 경우 확인해봐야 할듯
					// ================================================ (2020-12-02)
					String byeId = getKey(idipMaps, socket.getInetAddress().toString());
					idipMaps.remove(byeId);

					System.out.println(socket.getInetAddress() + ".. Exited");
					System.out.println("접속자수: " + maps.size());
					break;
				}
			} // end while

			try {
				if (oi != null) {
					oi.close();
				}
				if (socket != null) {
					socket.close();
				}
			} catch (Exception e) {

			}
		}

	}

	// 1_A +++ AIR_OFF
	public JSONObject convertJson(String cmdArea, String cmdAction) {
		JSONObject jsonObj = new JSONObject();
//		String area = split[0] + "_" + split[1];
//		String cmdMsg  = split[3] + "_" + split[4];

		jsonObj.put("from", "MAIN Server");
		jsonObj.put("area", cmdArea);
		jsonObj.put("msgType", "command");
		jsonObj.put("cmd", cmdAction);

		return jsonObj;
	}

	public static void connectWebsocketServer() {
		try {
			WsClient = new WsClient(new URI("ws://" + wsIp + ":" + wsPort + "/chatting"));
			WsClient.connect();
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
		isConnectWebsocket = true;
	}

	// HashMap에서 Value 값으로 Key값 찾기
	public static String getKey(HashMap<String, String> h, String value) {
		for (String k : h.keySet()) {
			if (h.get(k).equals(value)) {
				return k;
			}
		}
		return null;
	}

	// 객체에서 메세지로 가져와서 Sender를 호출한다.
	public void sendMsg(Msg msg) {
		Sender sender = new Sender();
		sender.setMsg(msg);
		sender.start();
	}

	// 특정 클라이언트에게만 메시지를 전송하는 sendTarget 함수
	public void sendTarget(String ip, String senderId, String type, String cmd) {
		try {
			Thread.sleep(100);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		ArrayList<String> ips = new ArrayList<String>(); // IP를 담을 문자열 ArrayList 선언
		ips.add(ip); // ArrayList에 IP저장
		Msg msg = new Msg(ips, senderId, type, cmd); // IP ArrayList, ID, 메시지 내용을 담는 Msg 생성자를 이용
		Sender sender = new Sender(); // Sender 객체 선언
		sender.setMsg(msg);
		new Thread(sender).start();
	}

	// client들에게 메세지 전송한다.
	class Sender extends Thread {
		Msg msg;

		public void setMsg(Msg msg) {

			this.msg = msg;
		}

		@Override
		public void run() {
			Collection<ObjectOutputStream> cols = maps.values();
			Iterator<ObjectOutputStream> it = cols.iterator();
			while (it.hasNext()) {
				try {
					System.out.println("SEND TARGET 할 메시지: " + msg);
					if (msg.getIps() != null) { // 만약 Msg 객체 변수 중 IP Arraylist 안이 null이 아니면
//						System.out.println("Sender class msg: "+msg);
						for (String ip : msg.getIps()) { // ips에 저장된 특정 클라이언트들만 대상으로 한다.
							maps.get(ip).writeObject(msg); // 해쉬맵에서 key가 "ip"인 메시지내용을 아웃풋스트림에 출력
						}
						break;
					}

					it.next().writeObject(msg); // 그게 아니면 전체를 대상으로 아웃풋스트림에 메시지 내용 출력
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}

	// 로컬 폴더의 my.properties 로드
	public static void getProp() {
		FileReader resources = null;
		Properties properties = new Properties();

		try {
			resources = new FileReader("../my.properties");
			properties.load(resources);
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		tcpipPort = Integer.parseInt(properties.getProperty("tcpipPort"));
		wsIp = properties.getProperty("websocketIp");
		wsPort = Integer.parseInt(properties.getProperty("websocketPort"));
		oracleHostname = properties.getProperty("oracleHostname");
		oracleId = properties.getProperty("oracleId");
		oraclePwd = properties.getProperty("oraclePwd");

	}

	// DB의 DEVICE 테이블에서 상태정보 로드하여 HashMap에 저장
	public static void getDeviceStat() throws SQLException {
		String url = "jdbc:oracle:thin:@" + oracleHostname + ":1521:ORCL";
		String dbid = oracleId;
		String dbpwd = oraclePwd;

		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rset = null;

		try {
			con = DriverManager.getConnection(url, dbid, dbpwd);
			pstmt = con.prepareStatement("SELECT * FROM DEVICE");
			rset = pstmt.executeQuery();
			while (rset.next()) {
				String device_id = rset.getString(1);
				String device_stat = rset.getString(8);
				DeviceVO dv = new DeviceVO(device_id, device_stat, null);
				deviceStat.put(device_id, dv);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			rset.close();
			pstmt.close();
			con.close();
		}
		System.out.println("Load deviceStat OK ... (FROM table `DEVICE`)");
	}

	public static void main(String[] args) {
		getProp();
		Server server = new Server(tcpipPort); // tcpipPort 번호로 Server 객체 선언
		autoController = new AutoController();

		try {
			getDeviceStat(); // DB의 디바이스 상태 받아옴
			server.startServer(); // 서버 실행
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}