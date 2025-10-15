<!DOCTYPE html>
<html lang="en">
<head>
<title>CSW Data Logger</title>
    <!-- Bootstrap core CSS -->
    <link href="dist/css/bootstrap3.min.css" rel="stylesheet">
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <link rel="stylesheet" href="dist/css/mystyles.css">
  </head>
  <body>
    <!-- these can't be in the footer as it leads to error -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js"></script>

    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
         <a class="navbar-brand" style="color:white" href="index.php">Home</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav" style="float: none">
	        <li class="dropdown">
                   <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
			Panel <span class="caret"></span></a>
                  <ul class="dropdown-menu">
                    <li><a href="http://192.168.100.4/" target="_blank">Monitor</a></li>
                    <li><a href="http://192.168.100.4/operation.htm" target="_blank">Operation</a></li>
                    <li><a href="http://192.168.100.4/config.htm" target="_blank">Configuration</a></li>
                 </ul>
                </li>
		<li <?php echo (($page == 'loads') ? 'class=active' : ''); ?> class="dropdown">
                   <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                        Loads <span class="caret"></span></a>
                  <ul class="dropdown-menu">
                    <li><a href="loads.php">Refresco</a></li>
                    <li><a href="loads_misc.php">Blends</a></li>
                 </ul>
                </li>
		<li <?php echo (($page == 'tankers') ? 'class=active' : ''); ?> ><a href="tankers.php">Tankers</a></li>
                <li <?php echo (($page == 'lab_results') ? 'class=active' : ''); ?>><a href="lab_results.php">Lab Results</a></li>
		<li <?php echo (($page == 'accounts') ? 'class=active' : ''); ?>> <a href="accounts.php">Accounts</a></li>
                <li <?php echo (($page == 'cctv') ? 'class=active' : ''); ?>><a href="cctv.php">CCTV</a></li>
		<li class="dropdown">
			<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
				Misc <span class="caret"></span></a>
			<ul class="dropdown-menu">
				<li class="dropdown-header"><strong>View log</strong></li>
				<li><button class="btn btn-link" value="orders">
					<span class="glyphicon glyphicon-file" aria-hidden="true"></span>
					Orders</button></li>
				<li><button class="btn btn-link" value="tank">
					<span class="glyphicon glyphicon-file" aria-hidden="true"></span>
					Tanks</button></li>
				<li><button class="btn btn-link" value="panel">
					<span class="glyphicon glyphicon-file" aria-hidden="true"></span>
					Panel</button></li>
				<li><button class="btn btn-link" value="ciptanks">
					<span class="glyphicon glyphicon-file" aria-hidden="true"></span>
					Tank CIP Dates</button></li>
				<li role="separator" class="divider"></li>
				<li class="dropdown-header"><strong>Misc</strong></li>
				<li><button class="btn btn-link" value="sysInfo">Sys Info</button></li>
				<li><button class="btn btn-link" value="openGate">Open Gate</button></li>
				<li><button class="btn btn-link" value="blends_load">Blends</button></li>
				<li><button class="btn btn-link" value="annualForecast">Annual Forecast</button></li>
				<li><button class="btn btn-link" value="missingLoads">Find Missing Loads</button></li>
				<li><button class="btn btn-link" value="reset">Reset Web Server</button></li>
				<li><button class="btn btn-link" value="solar">Solar</button></li>
				<li role="separator" class="divider"></li>
				<li class="dropdown-header"><strong>Print</strong></li>
				<li><button class="btn btn-link" value="printRefresco">Refresco Del Notes</button></li>
				<li><button class="btn btn-link" value="printWessex">Wessex Sample Sheets</button></li>
				<li><button class="btn btn-link" value="cups"><a href="http://192.168.100.35:631" target="_blank">CUPS (printer admin)</a></button></li>
				<li role="separator" class="divider"></li>
				<li class="dropdown-header"><strong>Release loads</strong></li>
				<li><button class="btn btn-link" value="releaseOne">Next</button></li>
				<li><button class="btn btn-link" value="releaseAll">All</button></li>
			</ul>
		</li>

          </ul>
        </div>
      </div>
    </div>
<script src="dist/js/menu.js"></script>
