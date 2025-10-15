<?php
 $page = "cctv";
 $page_title = "CSW - Data logger";
 include("header.php");

 shell_exec("bash /home/pi/bin/getCCTVweb.sh");
?>
<div class="container-fluid text-center">

	<div id="output"></div>

	<div class="row">
                <div class="col-md-6">
			<h3><a href="pointA.xspf">Point A</a></h3>
			<img class="img-responsive center-block" src="images/cctv/cctv3-502.jpeg" alt=""/>
		</div>
		<div class="col-md-6">
                        <h3><a href="pointB.xspf">Point B</a></h3>
			<img class="img-responsive center-block" src="images/cctv/cctv3-602.jpeg" alt=""/>
		</div>
        </div>

	<div class="row" style="margin-top:20px; margin-bottom:20px">
	    <div class="col-md-6 col-md-offset-3">
			<img class="img-responsive center-block" src="images/cctv/cctv3-402.jpeg" alt=""/>
	    </div>
        </div>
</div>
<script src="dist/js/bootstrap3.min.js"></script>
	</body>
</html>

