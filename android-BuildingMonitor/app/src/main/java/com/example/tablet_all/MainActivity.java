package com.example.tablet_all;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import android.content.Context;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.msg.Msg;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

import static com.example.tablet_all.BuildConfig.tcpipIp;
import static com.example.tablet_all.BuildConfig.tcpipPort;

public class MainActivity extends AppCompatActivity {
    ActionBar actionBar;
    ConstraintLayout container1;
    SoundPool soundPool;
    SoundManager soundManager;
    MediaPlayer mediaPlayer;

    TextView serverstat;        // 서버의 ON, OFF 상태
    TextView areastat;          // 상태 표시할 구역
    String onColor = "#3ac47d",
            offColor = "#CCCCCC";   // ON, OFF 배경색
    String myArea;              // 1_A, 2_A 등의 구역

    // TCP/IP 연결 정보
    int port;
    String address;
    String id;
    Socket socket;

    Sender sender;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        container1 = findViewById(R.id.container1);
        actionBar = getSupportActionBar();
        actionBar.hide();

        // 롤리팝 이상 버전일 경우
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            AudioAttributes attributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build();
            soundPool = new SoundPool.Builder()
                    .setAudioAttributes(attributes)
                    .setMaxStreams(4).build();
        } else {    // 롤리팝 이하
            soundPool = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);
        }
        soundManager = new SoundManager(this, soundPool);
        soundManager.addSound(0, R.raw.turn_on_mp348);
        soundManager.addSound(1, R.raw.turn_off_mp348);
        soundManager.addSound(2, R.raw.disaster_earthquake_full);

        mediaPlayer = MediaPlayer.create(MainActivity.this, R.raw.disaster_earthquake_full);
        // soundManager : 효과음 (재생시간 짧음)
        // meidaPlayer : 미디어 재생 (재생시간 노상관 / 재생 중 여부 확인 가능)

    }

    public void bt(View v) {
        switch (v.getId()) {
            case R.id.button1:
                myArea = "1_A";
                break;
            case R.id.button2:
                myArea = "1_B";
                break;
            case R.id.button3:
                myArea = "2_A";
                break;
        }

        container1.removeAllViews();
        LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.device_status, container1, true);
        serverstat = findViewById(R.id.textView10); // inflater 화면을 그린 후 findView 호출
        areastat = findViewById(R.id.textView12);

        port = tcpipPort;
        address = tcpipIp;
        id = "tablet_" + myArea;
        new Thread(con).start();
    }

    Runnable con = new Runnable() {
        @Override
        public void run() {
            try {
                connect();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    };

    private void connect() throws IOException {
        try {
            socket = new Socket(address, port);
        } catch (Exception e) {
            while (true) {
                try {
                    Thread.sleep(2000);
                    socket = new Socket(address, port);
                    break;
                } catch (Exception e1) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            serverstat.setText("OFF");
                        }
                    });
                    System.out.println("Retry ...");
                }
            }
        }
        System.out.println("Connected Server: " + address);
        sender = new Sender(socket);
        new Receiver(socket).start();

        // 에러 수정 : Only the original thread that created a view hierarchy can touch its views
        // 문제 : 외부 Thread 에서 UI 변경 작업 시 에러 발생
        // 해결 : runOnUiThread로 UI Thread 호출하여 UI 변경
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                serverstat.setText("ON");
                areastat.setText(myArea);
            }
        });


        getInitial();
    }

    // 서버 접속 시, 접속했음을 클라이언트들에게 메시지 전송
    private void getInitial() {
        Msg msg = new Msg(id, "first", "First Conn. of Tablet_" + myArea);
        sender.setMsg(msg);                                                                             // sender 쓰레드에 메시지 내용 저장
        new Thread(sender).start();                                                                     // 메시지 내용에 대해 sender 쓰레드 실행.

    }

    class Receiver extends Thread {
        ObjectInputStream oi;

        public Receiver(Socket socket) throws IOException {
            oi = new ObjectInputStream(socket.getInputStream());
        }

        @Override
        public void run() {
            while (oi != null) {
                Msg msg = null;
                try {
                    msg = (Msg) oi.readObject();

                    Msg finalMsg = msg;


                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {

                            // 시설(디바이스) 상태 처리
                            if(myArea.equals(finalMsg.getMsg().trim().substring(0, 3))){
                                System.out.println("finalMsg : " + finalMsg);
                                if (finalMsg.getType().equals("command")) {

                                    // cmd : 들어오는 메세지(1_A_D_AIR_OFF,...), deviceId : (AIR, HUM, ...), deviceStat : ON or OFF
                                    String cmd = finalMsg.getMsg().trim();
                                    String deviceId = cmd.substring(6, cmd.lastIndexOf("_"));
                                    String deviceStat = cmd.substring(cmd.lastIndexOf("_") + 1);

                                    try {
                                        // id 이름 앞에는 문자로 시작해야 하기 때문에 id 앞에 T와 L로 구분
                                        // T_ : ON/OFF를 표시하는 TextView, L : 각 디바이스의 LinearLayout
                                        // DEVICE들의 상태를 표시하는 TextView에 deviceStat를 반영
                                        int dT = getResources().getIdentifier("T_D_" + deviceId, "id", getPackageName());
                                        ((TextView) findViewById(dT)).setText(deviceStat);

                                        // DEVICE들의 상태를 따른 배경색을 각각의 LinearLayout에 반영
                                        int dL = getResources().getIdentifier("L_D_" + deviceId, "id", getPackageName());
                                        if (deviceStat.equals("ON")) {
                                            ((LinearLayout) findViewById(dL)).setBackground(
                                                    ContextCompat.getDrawable(findViewById(dL).getContext(), R.drawable.custom_shape_on));
                                            soundManager.playSound(0);
                                        } else if (deviceStat.equals("OFF")) {
                                            ((LinearLayout) findViewById(dL)).setBackground(
                                                    ContextCompat.getDrawable(findViewById(dL).getContext(), R.drawable.custom_shape_off));
                                            soundManager.playSound(1);
                                        }
                                    } catch (Exception e) {
                                        // 다른 층이나 구역의 DEVICE 신호가 들어올 때 에러
                                        System.out.println("ERROR :: MainActivity.java :: Line: 212");
                                    }
                                }
                            } else if(finalMsg.getType().equalsIgnoreCase("disaster")){
                                // 방송 ON
                                int dLbrdcast = getResources().getIdentifier("L_D_BRDCAST", "id", getPackageName());
                                ((LinearLayout) findViewById(dLbrdcast)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLbrdcast).getContext(), R.drawable.custom_shape_disaster_on));
                                int dTbrdcast = getResources().getIdentifier("T_D_BRDCAST", "id", getPackageName());
                                ((TextView) findViewById(dTbrdcast)).setText("ON");

                                // 재난방송 play
                                if(!mediaPlayer.isPlaying()){
                                    mediaPlayer.start();
                                }

                                // 비상대피로 OPEN
                                int dLroute = getResources().getIdentifier("L_D_ROUTE", "id", getPackageName());
                                ((LinearLayout) findViewById(dLroute)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLroute).getContext(), R.drawable.custom_shape_disaster_on));
                                int dTroute = getResources().getIdentifier("T_D_ROUTE", "id", getPackageName());
                                ((TextView) findViewById(dTroute)).setText("OPEN");

                                // 전기 > 비상전력 ON
                                int dLelec = getResources().getIdentifier("L_D_ELEC", "id", getPackageName());
                                ((LinearLayout) findViewById(dLelec)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLelec).getContext(), R.drawable.custom_shape_disaster_on));
                                int dTelec = getResources().getIdentifier("T_D_ELEC", "id", getPackageName());
                                ((TextView) findViewById(dTelec)).setText("ON");
                                int dTelecName = getResources().getIdentifier("textView5", "id", getPackageName());
                                ((TextView) findViewById(dTelecName)).setText("비상전력");

                                // 수도 OFF
                                int dLwat = getResources().getIdentifier("L_D_WAT", "id", getPackageName());
                                ((LinearLayout) findViewById(dLwat)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLwat).getContext(), R.drawable.custom_shape_off));
                                int dTwat = getResources().getIdentifier("T_D_WAT", "id", getPackageName());
                                ((TextView) findViewById(dTwat)).setText("OFF");

                                // 가스 OFF
                                int dLgas = getResources().getIdentifier("L_D_GAS", "id", getPackageName());
                                ((LinearLayout) findViewById(dLgas)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLwat).getContext(), R.drawable.custom_shape_off));
                                int dTgas = getResources().getIdentifier("T_D_GAS", "id", getPackageName());
                                ((TextView) findViewById(dTgas)).setText("OFF");

                                // 대피 유도등 ON
                                int dLled = getResources().getIdentifier("L_D_LED", "id", getPackageName());
                                ((LinearLayout) findViewById(dLled)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLled).getContext(), R.drawable.custom_shape_disaster_on));
                                int dTled = getResources().getIdentifier("T_D_LED", "id", getPackageName());
                                ((TextView) findViewById(dTled)).setText("ON");
                                int dTledName = getResources().getIdentifier("textView4", "id", getPackageName());
                                ((TextView) findViewById(dTledName)).setText("비상조명");

                                // 냉난방 OFF
                                int dLair = getResources().getIdentifier("L_D_AIR", "id", getPackageName());
                                ((LinearLayout) findViewById(dLair)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLair).getContext(), R.drawable.custom_shape_off));
                                int dTair = getResources().getIdentifier("T_D_AIR", "id", getPackageName());
                                ((TextView) findViewById(dTair)).setText("OFF");

                                // 가습 OFF
                                int dLhum = getResources().getIdentifier("L_D_HUM", "id", getPackageName());
                                ((LinearLayout) findViewById(dLhum)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLhum).getContext(), R.drawable.custom_shape_off));
                                int dThum = getResources().getIdentifier("T_D_HUM", "id", getPackageName());
                                ((TextView) findViewById(dThum)).setText("OFF");

                                // 공청기 OFF
                                int dLaircl = getResources().getIdentifier("L_D_AIRCL", "id", getPackageName());
                                ((LinearLayout) findViewById(dLaircl)).setBackground(
                                        ContextCompat.getDrawable(findViewById(dLhum).getContext(), R.drawable.custom_shape_off));
                                int dTaircl = getResources().getIdentifier("T_D_AIRCL", "id", getPackageName());
                                ((TextView) findViewById(dTaircl)).setText("OFF");

                            }

                        }
                    });
                    System.out.println(msg.getId() + msg.getMsg());
                    System.out.println(msg);
                } catch (Exception e) {
                    //e.printStackTrace();
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

    class Sender implements Runnable {
        Socket socket;
        ObjectOutputStream oo;
        Msg msg;

        public Sender(Socket socket) throws IOException {
            this.socket = socket;
            oo = new ObjectOutputStream(socket.getOutputStream());
        }

        public void setMsg(Msg msg) {
            this.msg = msg;
        }

        @Override
        public void run() {
            if (oo != null) {
                try {
                    oo.writeObject(msg);
                } catch (IOException e) {
                    // 서버가 죽어 있을 때
                    // 더 이상의 메세지가 날라가지 않을 때 에러가 난다.
                    //e.printStackTrace();

                    try {
                        if (socket != null) {
                            socket.close();
                        }
                    } catch (Exception e1) {
                        e1.printStackTrace();
                    }

                    try {
                        // 다시 서버와 연결 시도
                        System.out.println("Retry ...");
                        Thread.sleep(2000);
                        connect();
                    } catch (Exception e1) {
                        e1.printStackTrace();
                    }
                } // end try
            }
        }
    }
}

