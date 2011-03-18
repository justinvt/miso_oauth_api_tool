function form_values(){

   var format   = $("#format").val()
   var relative = $("#relative").val()
   var prefix   = $("#prefix").val()
   var method   = $("#method").val()

   var url      = [ prefix, relative ].join("/") + "." + format
   var data = {}

  $(".keypairs .field").each(function(i,j){
    var key = $(j).find(".name").val()
    var val = $(j).find(".value").val()
    if(key != null && key != "")
      data[$(j).find(".name").val()] = $(j).find(".value").val()
  })

  data["_method"] = method

    console.log(data)

  return {
    format: format,
    method: data["method"],
    url:  url,
    real_url: url.replace(/api/,'proxy'),
    data: data
  }

}

function update_form(){
    var form_data = form_values()
    $("#hidden_method").val(form_data["_method"])
    $("form#tool").attr("method", form_data["_method"])
    $("form#tool").attr("action", form_data["url"])
}



$(document).ready(function(){

  $("#prefix, #relative, #format, #method").change(function(){ update_form() }).ready(function(){ update_form() })

  $("#submit").click(function(){
    var form_data = form_values()
    $.ajax({
      url: form_data.real_url,
      type: "GET",
      data: form_data["data"],
      success: function(data){ $("#response").val(data) }
    })
  })



})