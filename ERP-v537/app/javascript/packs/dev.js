var ready = function() {
  $("#sidebarToggle").on("click", function(e) {
    e.preventDefault();
    $("body").toggleClass("sb-sidenav-toggled");
  });
};

$(document).on('turbolinks:load', ready); 

// remove user tag
$(document).on("click", ".user-list-remove", function() {
  $(this).parent().remove();
});

// switch tabs
$(document).on("click", ".switch-tab", function(e) {
  if ($(this).hasClass("prevent")) {
    e.stopPropagation();
  }

  var index = $(this).data("switch-index");
  var group = $(this).data("switch-group");

  $(".switch-tab[data-switch-group='" + group + "']").removeClass("active");
  $(".switch-tab[data-switch-group='" + group + "'][data-switch-index='" + index + "']").addClass("active");

  $(".switch-content[data-switch-group='" + group + "']").removeClass("active");
  $(".switch-content[data-switch-group='" + group + "'][data-switch-index='" + index + "']").addClass("active");
});

// link for triggering file upload
$(document).on("click", ".file-input", function() {
  $(this).parents(".file-input-container").find("input[type='file']").trigger("click");
});

// auto submit file after uploaded, unless input has class ".file-temp"
$(document).on("change", "input[type='file']:not('.file-temp')", function() {
  $(this).parents("form").submit();
});

// if file input has class ".file-temp", change container background color, add file name
$(document).on("change", "input[type='file'].file-temp", function() {
  if ($(this).val()) {
    var files = [];
    for (var i = 0; i < $(this)[0].files.length; i++) {
      files.push($(this)[0].files[i].name);
    }
    $(this).parents(".file-input-container").siblings(".file-name").html("<p>" + files.join("<br>") + "</p>");
  }
});

// trigger side panel
$(document).on("click", ".open-side-panel", function() {
  $(".side-panel").addClass("active");
});

$(document).on("click", ".close-side-panel", function() {
  $(".side-panel").removeClass("active");
});

$(document).on("click", ".backdrop", function() {
  $(".side-panel").removeClass("active");
});

// toggle view
$(document).on("click", ".toggle-view", function() {
  var toggle = $(this).data("toggle");
  $(".toggle-content[data-toggle='" + toggle + "']").toggleClass("active");
  $(this).children().toggleClass("dripicons-plus");
  $(this).children().toggleClass("dripicons-minus");
});

// remove search results when clicked away
$(document).on("click", function () {
  $(".search-results").html("");
});

// close alert after 3 seconds
$(document).on("turbolinks:load", function() {
  if ($(".alert").length > 0) {
    setTimeout(function() {
      $(".alert").alert("close");
    }, 3000);
  }
});

// check all checkboxes
$(document).on("click", "#check_all", function() {
  var check = this.checked;
  var cbxs = $("input:not(#check_all):not([data-switch])[type='checkbox']");
  cbxs.prop("checked", check);
});

// form validation
$(document).on("turbolinks:load", function () {
  "use strict"

  // Fetch all the forms we want to apply custom Bootstrap validation styles to
  var forms = document.querySelectorAll(".needs-validation");
  // Loop over them and prevent submission
  Array.prototype.slice.call(forms).forEach(function (form) {
    $(form).find(".invalid-feedback").remove();
    $(form).find("[required]:not([type='checkbox'],[type='radio'])").after("<div class='invalid-feedback'>Response invalid or missing.</div>");

    form.addEventListener("submit", function (event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
        }

      form.classList.add("was-validated");
    }, false);
  });

  // loader
  $("a").on("click", function() {
    if ($(this).attr("target") != "_blank" && $(this).attr("target") != undefined) {
      document.getElementById("loaderOverlay").style.display = "flex";
      document.getElementById("loaderOverlay").style.left = 0;

      setTimeout(function() {
        document.getElementById("loaderOverlay").style.display = "none";
      }, 10000);
    }
  });

  $(document).on("turbolinks:load", function() {
    document.getElementById("loaderOverlay").style.display = "none";
  });

  // prevent dropdown menu from disappearing after clicking its content
  $(".dropdown-menu-full").on("click", function(e) {
    if (!$(e.target).is("svg") && !$(e.target).is("a")) {
      e.stopPropagation();
    }
  });
});