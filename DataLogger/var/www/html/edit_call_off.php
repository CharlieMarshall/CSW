<?php
 $page = "edit";
 $page_title = "CSW - Data logger";
 include("header.php");

// https://stackoverflow.com/questions/8226958/simple-php-editor-of-text-files

// configuration
$url = 'edit_call_off.php';
$file = '/home/pi/panel/orders.txt';

// check if form has been submitted
if (isset($_POST['text']))
{
    // save the text contents
    file_put_contents($file, $_POST['text']);

    // redirect to form again
    header(sprintf('Location: %s', $url));
    printf('<a href="%s">Moved</a>.', htmlspecialchars($url));
    exit();
}

// read the textfile
$text = file_get_contents($file);

?>

<!-- HTML form -->
<div class="container-fluid"></div>
	<form class="myform" style="text-align: center" action="" method="post">
		<textarea name="text" rows="35" cols="40"><?php echo htmlspecialchars($text) ?></textarea>
		<br><input type="submit" class="btn btn-primary" value="Save"/>
	</form>
</div>
<script src="dist/js/bootstrap3.min.js"></script>
	</body>
</html>

