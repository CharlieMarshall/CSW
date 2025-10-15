<?php
 $page = "edit";
 $page_title = "CSW - Data logger";
 include("header.php");

// https://stackoverflow.com/questions/8226958/simple-php-editor-of-text-files

// configuration
//$url = 'edit_lab_results.php';
$url = 'lab_results.php';
$file = '/home/pi/panel/lab_log.txt';

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
		<textarea name="text" rows="20" cols="120"><?php echo htmlspecialchars($text) ?></textarea>
		<br><input type="submit" class="btn btn-primary" value="Save"/>
	</form>
</div>

</body></html>
