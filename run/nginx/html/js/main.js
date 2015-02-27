$(document).ready(function () {

  $("#status-link").attr("href", "https://" + window.location.hostname + ":4242/docker");

  $.ajax({
    url: "/synchronizer/dashboards/changed",
    accept: "application/json"
  }).done(function (data) {
    if (data.repositoryChanged === true) {
      $("#update-notification").toggle();
      $("#update-notification button").click(function () {
        $.ajax({
          url: "/synchronizer/dashboards/update",
          accept: "application/json"
        }).done(function () {
          $("#update-notification").addClass("alert-success").html("Dashboards have been updated to the latest version.");
        });
      });
    }
  });

});