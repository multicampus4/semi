<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<link rel="stylesheet" type="text/css" href="css/gaugeChart.css">
<link rel="stylesheet" type="text/css" href="css/earthquakeGraph.css">
<script type="text/javascript" >
var obj=null;
// 현재 온도 값 차트 
function displayTempNow(temp){
	 var gaugeOptions = {
			    chart: {
			        type: 'solidgauge'
			    },
			    title: null,
			    pane: {
			        center: ['50%', '85%'],
			        size: '140%',
			        startAngle: -90,
			        endAngle: 90,
			        background: {
			            backgroundColor:
			                Highcharts.defaultOptions.legend.backgroundColor || '#EEE',
			            innerRadius: '60%',
			            outerRadius: '100%',
			            shape: 'arc'
			        }
			    },
			    exporting: {
			        enabled: false
			    },
			    tooltip: {
			        enabled: false
			    },
			    // the value axis
			    yAxis: {
			        stops: [
			            [1.5, '#DF5353'] //red
			            /* [0.5, ''], // yellow
			            [0.9, '#DF5353'] */ // red
			        ],
			        lineWidth: 0,
			        tickWidth: 0,
			        minorTickInterval: null,
			        tickAmount: 2,
			        title: {
			            y: -70
			        },
			        labels: {
			            y: 16
			        }
			    },
			    plotOptions: {
			        solidgauge: {
			            dataLabels: {
			                y: 5,
			                borderWidth: 0,
			                useHTML: true
			            }
			        }
			    }
			};
			var chartdust = Highcharts.chart('nowtemp', Highcharts.merge(gaugeOptions, {
			    yAxis: {
			        min: 0,
			        max: 200,
			        title: {
			            text: 'temperature'
			        }
			    },
			    credits: {
			        enabled: false
			    },
			    series: [{ 
			        name: 'temperature',
			        data:[temp],
			        dataLabels: {
			            format:
			                '<div style="text-align:center">' +
			                '<span style="font-size:25px">{y}</span><br/>' +
			                '<span style="font-size:12px;opacity:0.4">km/h</span>' +
			                '</div>'
			        },
			        tooltip: {
			            valueSuffix: ' km/h'
			        }
			    }]
			}
		)
	); 
} 
//하루 평균 습도 차트 
 function displayHumNow(hum){
	 var gaugeOptions = {
			    chart: {
			        type: 'solidgauge'
			    },
			    title: null,
			    pane: {
			        center: ['50%', '85%'],
			        size: '140%',
			        startAngle: -90,
			        endAngle: 90,
			        background: {
			            backgroundColor:
			                Highcharts.defaultOptions.legend.backgroundColor || '#EEE',
			            innerRadius: '60%',
			            outerRadius: '100%',
			            shape: 'arc'
			        }
			    },
			    exporting: {
			        enabled: false
			    },
			    tooltip: {
			        enabled: false
			    },
			    // the value axis
			    yAxis: {
			        stops: [
			            [1.5, '#DDDF0D'] //yellow
			            /* [0.5, ''], // yellow
			            [0.9, '#DF5353'] */ // red
			        ],
			        lineWidth: 0,
			        tickWidth: 0,
			        minorTickInterval: null,
			        tickAmount: 2,
			        title: {
			            y: -70
			        },
			        labels: {
			            y: 16
			        }
			    },
			    plotOptions: {
			        solidgauge: {
			            dataLabels: {
			                y: 5,
			                borderWidth: 0,
			                useHTML: true
			            }
			        }
			    }
			};
			var chartdust = Highcharts.chart('nowhumid', Highcharts.merge(gaugeOptions, {
			    yAxis: {
			        min: 0,
			        max: 200,
			        title: {
			            text: 'humidity'
			        }
			    },
			    credits: {
			        enabled: false
			    },
			    series: [{ 
			        name: 'humidity',
			        data:[hum],
			        dataLabels: {
			            format:
			                '<div style="text-align:center">' +
			                '<span style="font-size:25px">{y}</span><br/>' +
			                '<span style="font-size:12px;opacity:0.4">km/h</span>' +
			                '</div>'
			        },
			        tooltip: {
			            valueSuffix: ' km/h'
			        }
			    }]
			}
		)
	); 
} 
//하루 평균 미세먼지 농도 차트 
 function displayDustSatNow(dust){
	 var gaugeOptions = {
			    chart: {
			        type: 'solidgauge'
			    },
			    title: null,
			    pane: {
			        center: ['50%', '85%'],
			        size: '140%',
			        startAngle: -90,
			        endAngle: 90,
			        background: {
			            backgroundColor:
			                Highcharts.defaultOptions.legend.backgroundColor || '#EEE',
			            innerRadius: '60%',
			            outerRadius: '100%',
			            shape: 'arc'
			        }
			    },
			    exporting: {
			        enabled: false
			    },
			    tooltip: {
			        enabled: false
			    },
			    // the value axis
			    yAxis: {
			        stops: [
			            [1.5, '#8041D9'] // green
			            /* [0.5, '#DDDF0D'], // yellow
			            [0.9, '#DF5353'] */ // red
			        ],
			        lineWidth: 0,
			        tickWidth: 0,
			        minorTickInterval: null,
			        tickAmount: 2,
			        title: {
			            y: -70
			        },
			        labels: {
			            y: 16
			        }
			    },
			    plotOptions: {
			        solidgauge: {
			            dataLabels: {
			                y: 5,
			                borderWidth: 0,
			                useHTML: true
			            }
			        }
			    }
			};
			var chartdust = Highcharts.chart('nowdust', Highcharts.merge(gaugeOptions, {
			    yAxis: {
			        min: 0,
			        max: 200,
			        title: {
			            text: 'Fine dust'
			        }
			    },
			    credits: {
			        enabled: false
			    },
			    series: [{ 
			        name: 'Fine dust',
			        data:[dust],
			        dataLabels: {
			            format:
			                '<div style="text-align:center">' +
			                '<span style="font-size:25px">{y}</span><br/>' +
			                '<span style="font-size:12px;opacity:0.4">km/h</span>' +
			                '</div>'
			        },
			        tooltip: {
			            valueSuffix: ' km/h'
			        }
			    }]
			}
		)
	); 
 } //console.log(data);
 
//하루 평균 조도 차트 
 function displayLightNow(illm){
	 var gaugeOptions = {
			    chart: {
			        type: 'solidgauge'
			    },
			    title: null,
			    pane: {
			        center: ['50%', '85%'],
			        size: '140%',
			        startAngle: -90,
			        endAngle: 90,
			        background: {
			            backgroundColor:
			                Highcharts.defaultOptions.legend.backgroundColor || '#EEE',
			            innerRadius: '60%',
			            outerRadius: '100%',
			            shape: 'arc'
			        }
			    },
			    exporting: {
			        enabled: false
			    },
			    tooltip: {
			        enabled: false
			    },
			    // the value axis
			    yAxis: {
			        stops: [
			            [1.5, '#8041D9'] // green
			            /* [0.5, '#DDDF0D'], // yellow
			            [0.9, '#DF5353'] */ // red
			        ],
			        lineWidth: 0,
			        tickWidth: 0,
			        minorTickInterval: null,
			        tickAmount: 2,
			        title: {
			            y: -70
			        },
			        labels: {
			            y: 16
			        }
			    },
			    plotOptions: {
			        solidgauge: {
			            dataLabels: {
			                y: 5,
			                borderWidth: 0,
			                useHTML: true
			            }
			        }
			    }
			};
			var chartdust = Highcharts.chart('nowlight', Highcharts.merge(gaugeOptions, {
			    yAxis: {
			        min: 0,
			        max: 200,
			        title: {
			            text: 'Speed'
			        }
			    },
			    credits: {
			        enabled: false
			    },
			    series: [{ 
			        name: 'Speed',
			        data:[illm],
			        dataLabels: {
			            format:
			                '<div style="text-align:center">' +
			                '<span style="font-size:25px">{y}</span><br/>' +
			                '<span style="font-size:12px;opacity:0.4">km/h</span>' +
			                '</div>'
			        },
			        tooltip: {
			            valueSuffix: ' km/h'
			        }
			    }]
			}
		)
	); 
 } 

 
	function getData(){
		$.ajax({
			url:'getNow.mc',
			success:function(data){
				console.log(data)
				displayDustSatNow(data[0].finedust)
				displayTempNow(data[0].temperature)
				displayLightNow(data[0].illuminance)
				displayHumNow(data[0].humidity)
			}
		});
		}
	function wsOpen() {
		ws = new WebSocket("ws://" + location.host + "/chatting");
		chart = new Highcharts.chart('hcontainer1', {
			chart: {
		        type: 'spline',
		        animation: Highcharts.svg, // don't animate in old IE
		        marginRight: 10,
		        events: {
		            load: 
		            	function () {
		                // set up the updating of the chart each second
			                var series_X = this.series[0];
			                setInterval(function () {
			                    var x = (new Date()).getTime(), // current time
			                        y = parseFloat(obj.AcX);
			                    series_X.addPoint([x, y], true, true);
			                }, 1000);
		            }
		        }
		    },
			title: {
			   text: '실시간 가속도 그래프 - X'
			 },
			xAxis: {
				tickPixelInterval: 150,
				   type: 'datetime'
			 },
			yAxis: {
			      title: {
			          text: 'AcX'
			      },
			      plotLines: [{
			          value: 0,
			          width: 1,
			          color: '#808080'
			      }]
			  }, 
			accessibility: {
			      announceNewData: {
			          enabled: true,
			          minAnnounceInterval: 15000,
			          announcementFormatter: function (allSeries, newSeries, newPoint) {
			              if (newPoint) {
			                  return 'New point added. Value: ' + newPoint.y;
			              }
			              return false;
			          }
			      }
			  },
		    time: {
		        useUTC: false
		    },
			tooltip: {
			  headerFormat: '<b>{series.name}</b><br />',
			  pointFormat: 'x = {point.x}, y = {point.y}'
			},
			legend: {
			    layout: 'vertical',
			    align: 'right',
			    verticalAlign: 'middle'
			},
			series: [{
			      name: 'AcX',
			      data: (function () {
			          // generate an array of random data
			          var data = [],
			              time = (new Date()).getTime(),
			              i;
			
			          for (i = -19; i <= 0; i += 1) {
			              data.push({
			                  x: time + i * 1000,
			                  y: 0
			              });
			          }
			          return data;
			      }())
			  }]
			});
		chart = new Highcharts.chart('hcontainer2', {
			chart: {
		        type: 'spline',
		        animation: Highcharts.svg, // don't animate in old IE
		        marginRight: 10,
		        events: {
		            load: 
		            	function () {
		                // set up the updating of the chart each second
			                var series_X = this.series[0];
			                setInterval(function () {
			                    var x = (new Date()).getTime(), // current time
			                        y = parseFloat(obj.AcY);
			                    series_X.addPoint([x, y], true, true);
			                }, 1000);
		            }
		        }
		    },
			title: {
			   text: '실시간 가속도 그래프 - Y'
			 },
			xAxis: {
				tickPixelInterval: 150,
				   type: 'datetime'
			 },
			yAxis: {
			      title: {
			          text: 'AcY'
			      },
			      plotLines: [{
			          value: 0,
			          width: 1,
			          color: '#808080'
			      }]
			  }, 
			accessibility: {
			      announceNewData: {
			          enabled: true,
			          minAnnounceInterval: 15000,
			          announcementFormatter: function (allSeries, newSeries, newPoint) {
			              if (newPoint) {
			                  return 'New point added. Value: ' + newPoint.y;
			              }
			              return false;
			          }
			      }
			  },
		    time: {
		        useUTC: false
		    },
			tooltip: {
			  headerFormat: '<b>{series.name}</b><br />',
			  pointFormat: 'x = {point.x}, y = {point.y}'
			},
			legend: {
			    layout: 'vertical',
			    align: 'right',
			    verticalAlign: 'middle'
			},
			series: [{
			      name: 'AcY',
			      data: (function () {
			          // generate an array of random data
			          var data = [],
			              time = (new Date()).getTime(),
			              i;
			
			          for (i = -19; i <= 0; i += 1) {
			              data.push({
			                  x: time + i * 1000,
			                  y: 0
			              });
			          }
			          return data;
			      }())
			  }]
			});
		chart = new Highcharts.chart('hcontainer3', {
				chart: {
			        type: 'spline',
			        animation: Highcharts.svg, // don't animate in old IE
			        marginRight: 10,
			        events: {
			            load: 
			            	function () {
			                // set up the updating of the chart each second
				                var series_X = this.series[0];
				                setInterval(function () {
				                    var x = (new Date()).getTime(), // current time
				                        y = parseFloat(obj.AcZ);
				                    series_X.addPoint([x, y], true, true);
				                }, 1000);
			            }
			        }
			    },
				title: {
				   text: '실시간 가속도 그래프 - Z'
				 },
				xAxis: {
					tickPixelInterval: 150,
					   type: 'datetime'
				 },
				yAxis: {
				      title: {
				          text: 'AcZ'
				      },
				      plotLines: [{
				          value: 0,
				          width: 1,
				          color: '#808080'
				      }]
				  }, 
				accessibility: {
				      announceNewData: {
				          enabled: true,
				          minAnnounceInterval: 15000,
				          announcementFormatter: function (allSeries, newSeries, newPoint) {
				              if (newPoint) {
				                  return 'New point added. Value: ' + newPoint.y;
				              }
				              return false;
				          }
				      }
				  },
			    time: {
			        useUTC: false
			    },
				tooltip: {
				  headerFormat: '<b>{series.name}</b><br />',
				  pointFormat: 'x = {point.x}, y = {point.y}'
				},
				legend: {
				    layout: 'vertical',
				    align: 'right',
				    verticalAlign: 'middle'
				},
				series: [{
				      name: 'AcZ',
				      data: (function () {
				          // generate an array of random data
				          var data = [],
				              time = (new Date()).getTime(),
				              i;
				
				          for (i = -19; i <= 0; i += 1) {
				              data.push({
				                  x: time + i * 1000,
				                  y: 0
				              });
				          }
				          return data;
				      }())
				  }]
				});
		wsEvt();
	}
	function wsEvt() {
		// onopen: 웹 소켓이 열리면 호출
		ws.onopen = function(data) {
			//소켓이 열리면 초기화 세팅하기
		}
		// onmessage: 메시지가 도착하면 호출
		ws.onmessage = function(data) {
			var msg = data.data;
			obj = JSON.parse(msg);

			// ex: { "tmp":"28", "hum":"80" }
		}
	}
$(document).ready(function(){
	wsOpen();
	getData();
	
});

</script>

<div class="row">
	<div class="col-md-12 col-lg-6">
		<div class="main-card mb-3 card">
			<div class="card-header">
				현재 실내 온도 
			</div>
			 <div class="tab-content">
				<figure class="highcharts-figure">
    				<div id="nowtemp" class="chart-container"></div>
				</figure>
				<button type="button" id="PopoverCustomT-1"
				        class="btn btn-primary btn-sm" >Details</button>
			</div> 
		</div>
	</div>
	
	<div class="col-md-12 col-lg-6">
		<div class="main-card mb-3 card">
			<div class="card-header">
				현재 실내 습도 
			</div>
			 <div class="tab-content">
				<figure class="highcharts-figure">
    				<div id="nowhumid" class="chart-container"></div>
				</figure>
				<button type="button" id="PopoverCustomT-1"
									class="btn btn-primary btn-sm" >Details</button>
			</div> 
		</div>
	</div>
</div>
	
	
<div class="row"> 
	<div class="col-md-12 col-lg-6">
		<div class="main-card mb-3 card">
			<div class="card-header">
				현재 실내 미세먼지 농도  
			</div>
			 <div class="tab-content">
				<figure class="highcharts-figure">
			   		<div id="nowdust" class="chart-container"></div>
				</figure>
			</div> 
		</div>
	</div> 
	
    <div class="col-md-12 col-lg-6">
		<div class="main-card mb-3 card">
			<div class="card-header">
				현재 실내 조도
			</div>
			 <div class="tab-content">
				<figure class="highcharts-figure">
					<div id="nowlight" class="chart-container"></div>
				</figure>
			</div> 
		</div>
	</div>  
</div>
<div class="row">
	<div class="col-md-6 col-xl-4">
		<div class="card mb-3 widget-content bg-midnight-bloom">
			<div class="widget-content-wrapper text-white">
				<div class="widget-content-left">
					<div class="widget-heading">Total Orders</div>
					<div class="widget-subheading">Last year expenses</div>
				</div>
				<div class="widget-content-right">
					<div class="widget-numbers text-white">
						<span>1896</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="col-md-6 col-xl-4">
		<div class="card mb-3 widget-content bg-arielle-smile">
			<div class="widget-content-wrapper text-white">
				<div class="widget-content-left">
					<div class="widget-heading">Clients</div>
					<div class="widget-subheading">Total Clients Profit</div>
				</div>
				<div class="widget-content-right">
					<div class="widget-numbers text-white">
						<span>$ 568</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="col-md-6 col-xl-4">
		<div class="card mb-3 widget-content bg-grow-early">
			<div class="widget-content-wrapper text-white">
				<div class="widget-content-left">
					<div class="widget-heading">Followers</div>
					<div class="widget-subheading">People Interested</div>
				</div>
				<div class="widget-content-right">
					<div class="widget-numbers text-white">
						<span>46%</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="d-xl-none d-lg-block col-md-6 col-xl-4">
		<div class="card mb-3 widget-content bg-premium-dark">
			<div class="widget-content-wrapper text-white">
				<div class="widget-content-left">
					<div class="widget-heading">Products Sold</div>
					<div class="widget-subheading">Revenue streams</div>
				</div>
				<div class="widget-content-right">
					<div class="widget-numbers text-warning">
						<span>$14M</span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-md-12">
		<div class="main-card mb-3 card">
			<!-- 실시간 차트 영역 -->
			<div class="card-header">
				실시간차트 :: 지진 모니터링 
			</div>
			<div class="tab-content">
				<figure class="highcharts-figure">
					<div id="hcontainer1"></div>
				</figure>
			</div>
			<div class="tab-content">
				<figure class="highcharts-figure">
					<div id="hcontainer2"></div>
				</figure>
			</div>
			<div class="tab-content">
				<figure class="highcharts-figure">
					<div id="hcontainer3"></div>
				</figure>
			</div>
			<div class="tab-content">
				데모 데이터 전송 : <input id="chatting" value='{ "tmp":"28", "hum":"80" }'>
				<button onclick="send()" id="sendBtn">보내기</button>
			</div>
		</div>
	</div>
</div>

