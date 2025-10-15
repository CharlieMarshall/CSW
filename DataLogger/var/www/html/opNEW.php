<?php
 $page = "index";
 $page_title = "CSW - Data logger";
 $pgDesc = "";
 $pgKeywords="";
 include("header.php");

 $locale = 'en_GB.utf-8';
 setlocale(LC_ALL, $locale);
 putenv('LC_ALL='.$locale);

 $monthNum  = strftime('%m');
 $dateObj   = DateTime::createFromFormat('!m', $monthNum);
 // $monthName = $dateObj->format('F'); // March
 $startforecast = date('d/m/Y H:i');

 $output = shell_exec('./index.sh');
 // Using a ~ as a delimintor as , and | are in the data and ? threw errors
 $data = explode("~",$output);
 $lastLoads = $data[0];
 $gateAccess = $data[1];
 $calloff = $data[2];
 $tankerCIP = $data[3];
 $flowrate = $data[4];



?>
<!-- datePicker for forecast plotting this page only -->
<link rel="stylesheet" href="dist/css/jquery-ui-timepicker-addon.css">

<script deger src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.3/Chart.bundle.js"></script>
<script defer src="dist/js/indexDual.js"></script>
<script defer src="dist/js/op.js"></script>
<script defer src="https://www.gstatic.com/charts/loader.js"></script>
<script defer src="dist/js/jquery-ui-timepicker-addon.js"></script>
<script defer src="dist/js/bootstrap3.min.js"></script>

<div class="container-fluid" style="margin-top:10px">
	<div id="output"></div>

	<div id="accordion">
                <div id="fins">
                        <h3>PLC Data</h3>
                        <div>
                          <div class="row" style="margin:10px;">

<!--                		  <canvas id="myChart" width="300" height="100"></canvas> -->

                                  <button id="refreshPLCBtn" class="btn btn-primary">Refresh PLC Data</button>
                                  <button id="refreshAllBtn" class="btn btn-primary">Refresh All Data</button>
				  <button id="cipStatus" class="btn btn-primary" value="cipStatus">CIP Valve Status</button>

<!--                                  <button id="testBtn" class="btn btn-primary">Test</button> -->
                                  <img id="loading" src="/images/ajax-loader.gif" alt="spinner"/>

                                  <div id="time" class="pull-right"></div>
                          </div>

			<div class="row">
                               	<div class="col-sm-2 col-sm-offset-1">
                                	<div class="tankContainer">
						<p class="text-center"><b>Tank 1</b></p>
						<div id="underlay1" class="underlay tankImgs"></div>
						<canvas id="canvas1" class="tankImgs"></canvas>
						<img class="img-responsive tankImgs" src="images/waterTankTransXS.png" id="tankImg1" alt=""/>


<div id="arrowAnim1" class="arrowAnim">
  <div class="arrowSliding">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay1">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay2">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay3">
    <div class="arrow"></div>
  </div>
</div>


					</div>
                                </div>

                               	<div class="col-sm-2">
     			        	<div class="tankerContainer">
						<p id="pointB" class="text-center"></p>
						<div id="underlayB" class="underlay tankerImgs"></div>
						<canvas id="canvasB" class="tankerImgs"></canvas>
						<img class="img-responsive tankerImgs" src="images/BackTankerTransXS.png" id="tankerB" alt=""/>
					</div>
				</div>

                               	<div class="col-sm-2">
                                	<div class="tankContainer">
						<p class="text-center"><b>Tank 2</b></p>
						<div id="underlay2" class="underlay tankImgs"></div>
						<canvas id="canvas2" class="tankImgs"></canvas>
						<img class="img-responsive tankImgs" src="images/waterTankTransXS.png" id="tankImg2" alt=""/>
<div id="arrowAnim2" class="arrowAnim">
  <div class="arrowSliding">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay1">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay2">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay3">
    <div class="arrow"></div>
  </div>
</div>

					</div>
				</div>

	                        <div class="col-sm-2">
		                	<div class="tankerContainer">
						<p id="pointA" class="text-center"></p>
						<div id="underlayA" class="underlay tankerImgs"></div>
						<canvas id="canvasA" class="tankerImgs"></canvas>
						<img class="img-responsive tankerImgs" src="images/BackTankerTransXS.png" id="tankerA" alt=""/>
					</div>
				</div>

                               	<div class="col-sm-2">
                                	<div class="tankContainer">
						<p class="text-center"><b>Tank 3</b></p>
						<div id="underlay3" class="underlay tankImgs"></div>
						<canvas id="canvas3" class="tankImgs"></canvas>
						<img class="img-responsive tankImgs" src="images/waterTankTransXS.png" id="tankImg3" alt=""/>
<div id="arrowAnim3" class="arrowAnim">
  <div class="arrowSliding">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay1">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay2">
    <div class="arrow"></div>
  </div>
  <div class="arrowSliding delay3">
    <div class="arrow"></div>
  </div>
</div>

					</div>
				</div>

	                        <div class="col-sm-1"><div class="tankerContainer"></div></div>

			  </div>


			  <div class="row">
				  <div id="pointTable" class="table-responsive"></div>
				  <div id="tankTable"  class="table-responsive"></div>
				  <div id="miscTable"  class="table-responsive"></div>
				</div>
			  </div>
                </div>


		<div id="storage">
			<h3>Latest Storage Data</h3>
			<div class="row centered">


				<div class="col-md-12" style="margin-top:0.3em">
					<div class="row centered">
						<div class="col-xs-4 col-xs-offset-3" style="margin-top:0.7em">
							<div id="slider" class="center-block">
                		                        	<div id="custom-handle" class="ui-slider-handle"></div>
							</div>
						</div>
						<div class="col-xs-5">
							<fieldset>
								<label for="tanks">Tanks</label>
								<input type="radio" id="tanks" name="graphGroup" class="rbtn" value="tanks" checked="checked">
								<label for="total">Total</label>
								<input type="radio" id="total" name="graphGroup" class="rbtn" value="total">
							</fieldset>
						</div>
					</div>
					<img id="tankSummary" class="img-responsive center-block" src="/images/tank_summary.svg" alt/>
				</div>
			</div>
		</div>

                <div id="loads">
                        <h3>Last 15 Collected Loads</h3>
                        <div><pre id="preLoads"><?php echo "$lastLoads";?></pre></div>
                </div>


		<div id="gate">
			<h3>Last 15 Gate Caller IDs</h3>
			<div><pre id="preGate"><?php echo "$gateAccess";?></pre></div>
		</div>

		<div id="forecast">
                        <h3>Call-off & Forecast</h3>
			<div class="container-fluid myform">
				<div class="row">
					<div class="col-sm-6">
						<form id="forecastForm" class="form-horizontal">
        	        	                        <div class="form-group">
                	        	                	<label for="startforecast" class="col-sm-6 control-label">Start date &amp; time</label>
                          	        	              	<div class="col-sm-6">
                                                	        	<input type="text" class="form-control" name="startforecast" id="startforecast" value=<?php echo escapeshellarg($startforecast);?> placeholder="Date and time">
		                                                </div>
        		                                </div>
					                <div class="form-group">
                        					<label for="buffer" class="col-sm-6 control-label">Tank buffer (m<sup>3</sup>)</label>
			        		                <div class="col-sm-6"><input type="text" class="form-control" id="buffer" name="buffer"
                        					        value="" placeholder="Buffer (m3)">
			                        		</div>
					                </div>
					                <div class="form-group">
					                        <label for="maxbuffer" class="col-sm-6 control-label">Max tank buffer (m<sup>3</sup>)</label>
                        					<div class="col-sm-6"><input type="text" class="form-control" id="maxbuffer" name="maxbuffer"
			        		                        value="" placeholder="Max buffer">
                	        				</div>
				        	        </div>
					                <div class="form-group">
                		        			<label for="flowrate" class="col-sm-6 control-label">Hourly flow rate (m<sup>3</sup>)</label>
					                        <div class="col-sm-6">
                        					        <input type="text" class="form-control" id="flowrate" name="flowrate" value=<?php echo "$flowrate";?> placeholder="Flow rate">
			                		        </div>
					                </div>
					                <div class="form-group">
                		        			<label for="ecoFillOn" class="col-sm-6 control-label">Eco Fill Hours</label>
					                        <div class="col-sm-3">
                        					        <input type="text" class="form-control" id="ecoFillOn" name="ecoFillOn" value="" placeholder="On hour (24)">
								</div>
				                	        <div class="col-sm-3">
                        					        <input type="text" class="form-control" id="ecoFillOff" name="ecoFillOff" value="" placeholder="Off hour (24)">
				                	        </div>
					                </div>
<!--					                <div class="form-group">
								<label id="tankerTextLabel" for="tankerText" class="sr-only"><?php echo "$currenttankers"; ?></label>
                	        				<label for="incTankers" class="col-sm-6 control-label">Include tanker buffer</label>
				        	                <div class="col-sm-6"> <input type="checkbox" style="margin-top:11px" name="incTankers" id="incTankers"
                        					        value="yes"> <?php echo "$currenttankers"; ?> m<sup>3</sup>
				                	        </div>
					                </div>
-->
					        </form>
					</div>
					<div class="col-sm-5 col-sm-offset-1">
						<div style="height:17.5em;overflow:auto">
							Outstanding loads from call-off:
							<pre id="preCallOff"><?php echo "$calloff";?></pre>
							<!-- <div><a class="btn btn-primary" style="color: #fff; margin-left:10px" href="edit_call_off.php">Edit</a></div> -->
						</div>
					</div>
				</div>

				<div class="row">
					<img id="graph" class="img-responsive center-block" src="data:," alt loading="lazy"/>
				</div>
				<div class="row">
					<div class="col-sm-8 col-sm-offset-2" style="padding-top:20px">
						<div id="sliderFR" class="center-block">
							<div id="flowRate-handle" class="ui-slider-handle"></div>
						</div>
					</div>
				</div>
				<div class="row">
					<img id="frGraph" class="img-responsive center-block" src="images/fr.svg" alt loading="lazy"/>
				</div>

			</div>
		</div>

		<div id="volume">
                        <h3>Yearly Volumes</h3>
                        <div>
				<img id="waterImg" class="img-responsive center-block" src="/images/water.svg" alt loading="lazy"/>
				<img id="volImg" class="img-responsive center-block" src="/images/volumes.svg" alt loading="lazy"/>
			</div>
                </div>


		<div id="volumeDaily">
			<h3>Monthly Statistics</h3>
			<div>

                        <form id="monthlyStats" class="form-inline text-center" style="padding:4px">
                            <div class="form-group">
                                <select class="form-control" id="volMonth" name="volMonth">
<?php
$months = array(1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec');

// add to foreach:
// if you want to select a particular month
// $selected = ($month == 5) ? 'selected' : '';
foreach ($months as $num => $name)
	printf('<option value="%02d">%s</option>', $num, $name);
?>
                                </select>
                            </div>
                            <div class="form-group">
				<label class="sr-only" for="volYear">Year</label>
		                <select class="form-control" id="volYear" name="volYear">
<?php
        for($x=date("Y"); $x>2015; $x--)
                echo '<option value="'.$x.'">'.$x.'</option>';
?>
                		</select>
                            </div>
                        </form>

				<div class="col-md-12" style="padding-left:0px">
	       	        	        <img id="daily" class="img-responsive center-block" src="/images/volumesDaily.svg" alt loading="lazy"/>
		                </div>

				<div class="row centered">
					<div class="col-md-12" style="padding-left:0px">
						<img id="boreElec" class="img-responsive center-block" src="/images/boreholeElec.svg" alt loading="lazy"/>
					</div>
				</div>
				<div class="row centered">
					<div class="col-md-12" style="padding-left:0px">
						<img id="fillmode" class="img-responsive center-block" src="/images/elec.svg" alt loading="lazy"/>
					</div>
				</div>
			</div>
		</div>

                <div id="cip">
                        <h3>Latest CIP Data</h3>
                        <div><pre id="preCIP"><?php echo "$tankerCIP";?></pre></div>
                </div>
		<div id="traffic">
			<h3>Live Traffic</h3>
			<div class="row"><p><a target="_blank" href="https://one.network/">One Network - Traffic Monitoring</a></p>
			<div class="row" style="padding-left:0px">
                		<iframe class="col-lg-6 col-md-6 col-sm-6" style="height:500px; border:0;" loading="lazy"
src="https://www.google.com/maps/embed?pb=!1m28!1m12!1m3!1d318972.0535368131!2d-2.951536515846161!3d51.34847756478593!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!4m13!3e6!4m5!1s0x48719cd01044613b%3A0x900c68e3561cbb51!2sCotswold+Spring+Water%2C+Dodington+Spring+Dodington+Ash+Codrington%2C+Chipping+Sodbury%2C+Bristol%2C+South+Gloucestershire+BS37+6RX%2C+United+Kingdom!3m2!1d51.501135!2d-2.3671018999999998!4m5!1s0x48720625bfae9637%3A0x832e17a44fac2949!2sRefresco+Gerber+UK+Limited%2C+Bristol+Road%2C+Bridgwater!3m2!1d51.1502784!2d-2.9928538!5e0!3m2!1sen!2suk!4v1467511930689" allowfullscreen></iframe>
	                	<iframe class="col-lg-6 col-md-6 col-sm-6" style="height:500px; border:0;" loading="lazy"
src="https://www.google.com/maps/embed?pb=!1m28!1m12!1m3!1d318966.0455142318!2d-2.955997817038334!3d51.34934066290459!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!4m13!3e6!4m5!1s0x48720625bfae9637%3A0x832e17a44fac2949!2sRefresco+Gerber+UK+Limited%2C+Bristol+Road%2C+Bridgwater!3m2!1d51.1502784!2d-2.9928538!4m5!1s0x48719ccff212c359%3A0xba5e73c9b871654a!2sCodrington%2C+Chipping+Sodbury%2C+Bristol+BS37+6RX%2C+UK!3m2!1d51.501135!2d-2.3671018999999998!5e0!3m2!1sen!2suk!4v1469886683585" allowfullscreen></iframe>
			</div></div>
		</div>
		<div id="spring">
			<h3>Flow Monitoring</h3>
			<div class="container-fluid myform" style="text-align: center;">
				<div class="row">
					<div class="col-md-6">

						<table style="margin-left:auto; margin-right:auto;"><tr>
							<td><a href="http://www.timeview2.net/" target="_blank" title="Username: 'Cotswold Springs'">Spring:&nbsp;</a></td>
							<td><input type="radio" name="channel" value="2.png" checked="checked"> Flow</td>
							<td><input type="radio" name="channel" value="1.png"> Stage</td></tr>
						</table>
						<table style="margin-left:auto; margin-right:auto;"><tr>
							<td><input type="radio" name="flow" value="1_day_large_channel_" checked="checked"/> 1 Day</td>
							<td><input type="radio" name="flow" value="5_days_large_channel_"/> 5 Days</td>
							<td><input type="radio" name="flow" value="7_days_large_channel_"/> 7 Days</td>
							<td><input type="radio" name="flow" value="4_weeks_large_channel_"/> 4 Weeks</td>
							<td><input type="radio" name="flow" value="3_months_large_channel_"/> 3 Months</td>
							<td><input type="radio" name="flow" value="6_months_large_channel_"/> 6 Months</td>
							<td><input type="radio" name="flow" value="1_year_large_channel_"/> 1 Year</td></tr>
						</table>
						<a href="http://www.timeview2.net/xdq/Cotswold%20Springs/COTSWOLDS%20SPRING/DODINGTON%20SPRING/IMAGES/1_day_large_channel_2.png" id="flowlink" target="_blank">
							<img class="center-block" id="flowIMG" style="margin-top:10px; width:520px; height:320px;" alt="" loading="lazy"
							src="http://www.timeview2.net/xdq/Cotswold%20Springs/COTSWOLDS%20SPRING/DODINGTON%20SPRING/IMAGES/1_day_large_channel_2.png">
						</a>
					</div>
					<div class="col-md-6">
						<div><p>River Boyd at Bitton</p></div>
	       					<div id="chart_div" style="display: inline-block; margin: 0 auto; "></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

	</body>
</html>
