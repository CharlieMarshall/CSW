$(function() { // document.ready()
  loadChart();
});

$("#testBtn").click(function(){
  loadChart();
});

function loadChart(){
    $.ajax({
      url: 'vol.php',
      type: 'get',
      datatype: 'json',
      success: function(data){

        /* AMEND HERE FOR THE CHART WE WANT */
        var received = $.parseJSON(data);
	var chartJson = received.Volumes;

        var backgroundColor = [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(153, 102, 255, 0.2)',
                'rgba(255, 159, 64, 0.2)',
		'rgba(204, 208, 204,0.2)'
            ];
	var borderColor = [
                'rgba(255, 99, 132, 1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(153, 102, 255, 1)',
                'rgba(255, 159, 64, 1)',
		'rgba(204, 208, 204,1)'
            ];

        var mydatasets = [];

for (var j = 0; j < chartJson.datasets.length; j++) {
    mydatasets.push({
      label: chartJson.datasets[j].label,
      data: chartJson.datasets[j].data.split(','),
      backgroundColor: backgroundColor[j],
      borderColor: borderColor[j],
      borderWidth: 2,
      spanGraphs: true
    });
}

var chartData = {
  labels: chartJson.labels.split(','),
  datasets: mydatasets
}

var options = {
  tooltips: {
//       enabled: false
  },
  scales: { 
   yAxes: [{
      ticks: {
             beginAtZero: true,
           },
      scaleLabel: {
             display: true,
             labelString: 'Number of Loads',
             fontSize: 14
           }
  }],
  xAxes:[{
    ticks:{
        display: true,
        autoSkip: true,
        maxTicksLimit: 20
    }
  }]
 }
};

	var ctx = document.getElementById('myChart').getContext('2d');
        ctx.clearRect(0, 0, ctx.width, ctx.height); // not sure if needed
	var myChart = new Chart(ctx, {
	  type: 'bar',
	  data: chartData,
	  options: options
	});

      }, // success
    }); // ajax

}
