$(function() {
  // cipStatus is the ID for the button cipStatus, the class btn-link are all the links in the Misc dropdown menu
  $("#cipStatus, .btn-link:not(#calloff)").click(function() {
    var data = $(this).val();
    $.ajax({url:"getMisc.php", type:"POST", data:{data:data}, success:function(response) {
      $("html, body").animate({ scrollTop: 0 }, 200);
      $("#output").html("<pre>" + response + "</pre>");
    }});
  });
});
