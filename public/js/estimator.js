$(window).bind("pageshow", function() {
  "use strict";
  $('form').each(function() {
    this.reset();
  });
});

$('#cabinetFace, .cabinetFace, #cabinetMount, .cabinetMount, #cabinetBacking, #cabinetLighting, .cabinetLighting, #cabinetPaint, .cabinetPaint, #proceed').hide();

var priceSet;
var depth;
var depthPrice = 0.00;
var backingPrice = 0.00;

function totalPrice() {
  "use strict";
  var estimateTotal = depthPrice + backingPrice + facePrice + mountPrice + lightPrice + paintPrice;
  var estimatePrice = '$' + estimateTotal.toFixed(2);
  $('#totalPrice').attr("value", estimatePrice);
}

$('#itemType').change(function(){
  if ($(this).val() === "customSign" || $(this).val() === "channelLetterSet" || $(this).val() === "postAndPanel") {
    $('#cabinetSize, #cabinetDepth, #priceHeader, #total, #totalPrice, [for=cabinetSize], [for=cabinetDepth]').hide();
    $('#estimation').removeClass('grow');
    $('#estimation').addClass('shrink');
    $('#proceed').show();
  } else { $('#cabinetSize, #cabinetDepth, #priceHeader, #total, #totalPrice, [for=cabinetSize], [for=cabinetDepth]').show();
          $('#estimation').removeClass('shrink');
          $('#estimation').addClass('grow');
          $('#proceed').hide();
  }
});

$('#cabinetSize').change(function() {
  "use strict";
  if ($('#cabinetSize').val() === "23") {
    priceSet = cab23;
  } else if ($('#cabinetSize').val() === "24") {
    priceSet = cab24;
  } else if ($('#cabinetSize').val() === "25") {
    priceSet = cab25;
  } else if ($('#cabinetSize').val() === "26") {
    priceSet = cab26;
  } else if ($('#cabinetSize').val() === "27") {
    priceSet = cab27;
  } else if ($('#cabinetSize').val() === "28") {
    priceSet = cab28;
  } else if ($('#cabinetSize').val() === "210") {
    priceSet = cab210;
  } else if ($('#cabinetSize').val() === "33") {
    priceSet = cab33;
  } else if ($('#cabinetSize').val() === "34") {
    priceSet = cab34;
  } else if ($('#cabinetSize').val() === "35") {
    priceSet = cab35;
  } else if ($('#cabinetSize').val() === "36") {
    priceSet = cab36;
  } else if ($('#cabinetSize').val() === "37") {
    priceSet = cab37;
  } else if ($('#cabinetSize').val() === "38") {
    priceSet = cab38;
  } else if ($('#cabinetSize').val() === "310") {
    priceSet = cab310;
  } else if ($('#cabinetSize').val() === "44") {
    priceSet = cab44;
  } else if ($('#cabinetSize').val() === "45") {
    priceSet = cab45;
  } else if ($('#cabinetSize').val() === "46") {
    priceSet = cab46;
  } else if ($('#cabinetSize').val() === "47") {
    priceSet = cab47;
  } else if ($('#cabinetSize').val() === "48") {
    priceSet = cab48;
  } else if ($('#cabinetSize').val() === "410") {
    priceSet = cab410;
  } else if ($('#cabinetSize').val() === "55") {
    priceSet = cab55;
  } else if ($('#cabinetSize').val() === "56") {
    priceSet = cab56;
  } else if ($('#cabinetSize').val() === "57") {
    priceSet = cab57;
  } else if ($('#cabinetSize').val() === "58") {
    priceSet = cab58;
  } else if ($('#cabinetSize').val() === "510") {
    priceSet = cab510;
  } else if ($('#cabinetSize').val() === "choose") {
    priceSet = 0.00;
  }
});

$('#cabinetDepth').change(function() {
  "use strict";
  var size = $('#cabinetSize').val();
  if (size !== "choose") {
    $('#cabinetFace, .cabinetFace').show();
  }
});

$('#cabinetSize').change(function() {
  "use strict";
  if ($('#cabinetDepth').val() !== "choose") {
    $('#cabinetFace, .cabinetFace').show();
  }
});

$('#cabinetDepth, #cabinetSize').change(function() {

  "use strict";
  depth = $('#cabinetDepth').val();

  var mountSingle = '<option value="choose">Choose</option><option value="in">Internal</option><option value="ex">External</option><option value="none">None</option>';

  var mountDouble = '<option value="choose">Choose</option><option value="hang">Hanging</option><option value="bpole">Between Poles</option><option value="dspole">Double Sided Center Pole</option><option value="none">None</option>';

  var panOnly = '<option value="choose">Choose</option><option value="pan">Pan Face</option><option value="none">None</option></select>'

  var panAndFlat = '<option value="choose">Choose</option><option value="flat">Acrylic Face</option><option value="pan">Pan Face</option><option value="none">None</option></select>'

  var mountOptions;
  var faceOptions;

  if (depth === "ssPO65") {
    mountOptions = mountSingle;
    faceOptions = panOnly;
    depthPrice = priceSet.ssPO65;
  } else if (depth === "ss8") {
    mountOptions = mountSingle;
    faceOptions = panAndFlat;
    depthPrice = priceSet.ss8;
  } else if (depth === "dsPO5") {
    mountOptions = mountDouble;
    faceOptions = panOnly;
    depthPrice = priceSet.dsPO5;
  } else if (depth === "dsPO8") {
    mountOptions = mountDouble;
    faceOptions = panOnly;
    depthPrice = priceSet.dsPO8;
  } else if (depth === "ds9") {
    mountOptions = mountDouble;
    faceOptions = panAndFlat;
    depthPrice = priceSet.ds9;
  } else if (depth === "ds12") {
    mountOptions = mountDouble;
    faceOptions = panAndFlat;
    depthPrice = priceSet.ds12;
  } else { depthPrice = 0.00 };

  $('#depthPrice').text("");
  if (depth !== "choose") {
    $('#depthPrice').append('$' + depthPrice.toFixed(2));
  }
  totalPrice();

  $('#cabinetMount option').remove();
  $('#cabinetMount').append(mountOptions);
  $('#cabinetFace option').remove();
  $('#cabinetFace').append(faceOptions);

});

$('#cabinetFace').change(function() {
  "use strict";
  $('#cabinetMount, .cabinetMount').show();
});

$('#cabinetSize, #cabinetDepth').change(function() {
  if (depth === "ssPO65" || depth === "ss8") {
    backingPrice = priceSet.ssBack;
    $('#cabinetBacking').show();
    $('#backingPrice').text("");
    $('#backingPrice').append('$' + backingPrice.toFixed(2));
    $('#backingPrice').show();
  } else {
    backingPrice = 0.00;
    $('#cabinetBacking').hide();
    $('#backingPrice').hide();
  }
});

var face;
var facePrice = 0.00;

$('#cabinetFace, #cabinetSize, #cabinetDepth').change(function() {
  "use strict";
  face = $('#cabinetFace').val();

  if (face === "flat" && (depth === "ssPO65" || depth === "ss8")) {
    facePrice = priceSet.acrylicFace1;
  } else if (face === "flat" && (depth === "dsPO5" || depth === "dsPO8" || depth === "ds9" || depth === "ds12")) {
    facePrice = priceSet.acrylicFace2;
  } else if (face === "pan" && (depth === "ssPO65" || depth === "ss8")) {
    facePrice = priceSet.panFace1;
  } else if (face === "pan" && (depth === "dsPO5" || depth === "dsPO8" || depth === "ds9" || depth === "ds12")) {
    facePrice = priceSet.panFace2;
  } else if (face === "none") {
    facePrice = priceSet.none;
  } else { facePrice = 0.00 }

  $('#facePrice').text("");
  if (face !== "choose" && depth !== "choose") {
    $('#facePrice').append('$' + facePrice.toFixed(2));
  }
  totalPrice();
});

$('#cabinetMount').change(function() {
  "use strict";
  $('#cabinetLighting, .cabinetLighting').show();
});

var mount;
var mountPrice = 0.00;

$('#cabinetMount, #cabinetSize, #cabinetDepth').change(function() {
  "use strict";
  mount = $('#cabinetMount').val();

  if (mount === "in") {
    mountPrice = priceSet.ssInternal;
  } else if (mount === "ex") {
    mountPrice = priceSet.ssExternal;
  } else if (mount === "hang") {
    mountPrice = priceSet.dsHhanging;
  } else if (mount === "bpole") {
    mountPrice = priceSet.dsBetweenPole;
  } else if (mount === "dspole") {
    mountPrice = priceSet.dsCenterPole;
  } else if (mount === "none") {
    mountPrice = priceSet.none;
  } else { mountPrice = 0.00 }

  $('#mountPrice').text("");
  if (mount !== "choose" && depth !== "choose") {
    $('#mountPrice').append('$' + mountPrice.toFixed(2));
  }
  totalPrice();
});

$('#cabinetLighting').change(function() {
  "use strict";
  $('#cabinetPaint, .cabinetPaint').show();
});

var light;
var lightPrice = 0.00;

$('#cabinetLighting, #cabinetSize, #cabinetDepth, #cabinetMount').change(function() {
  "use strict";
  light = $('#cabinetLighting').val();

  if (light === "led" && (depth === "ssPO65" || depth === "ss8")) {
    lightPrice = priceSet.ssLED;
  } else if (light === "led" && (depth === "dsPO5" || depth === "dsPO8" || depth === "ds9" || depth === "ds12") && mount !== "dspole") {
    lightPrice = priceSet.dsLEDncp;
  } else if (light === "led" && (depth === "dsPO5" || depth === "dsPO8" || depth === "ds9" || depth === "ds12") && mount === "dspole") {
    lightPrice = priceSet.dsLEDcp;
  } else if (light === "none") {
    lightPrice = priceSet.none;
  } else if (light === "fl" && mount === "dspole") {
    lightPrice = priceSet.dsFluorescentcp;
  } else if (light === "fl") {
    lightPrice = priceSet.ssdsFluorescents;
  } else { lightPrice = 0.00 }

  $('#lightPrice').text("");
  if (light !== "choose" && depth !== "choose") {
    $('#lightPrice').append('$' + lightPrice.toFixed(2));
  }
  totalPrice();
});

var paint;
var paintPrice = 0.00;

$('#cabinetPaint, #cabinetSize, #cabinetDepth').change(function() {
  "use strict";
  paint = $('#cabinetPaint').val();

  if (paint === "yes") {
    paintPrice = priceSet.paint;
  } else if (paint === "no") {
    paintPrice = priceSet.none;
  } else { paintPrice = 0.00 }

  $('#paintPrice').text("");
  if (paint !== "choose" && depth !== "choose") {
    $('#paintPrice').append('$' + paintPrice.toFixed(2));
  }
  totalPrice();
});

/*Validate form and generate quote number*/

var submitting = '<span id="submission">Submitting Information...</span>'

$('#estimation').submit(function(event) {
  "use strict";
  
  if ($('#itemType').val() === "cabinet") {
  
    if ($('#cabinetSize').val() === "choose" || $('#cabinetDepth').val() === "choose" || $('#cabinetFace').val() === "choose" || $('#cabinetMount').val() === "choose" || $('#cabinetLighting').val() === "choose" || $('#cabinetPaint').val() === "choose") {
      event.preventDefault();
      alert('Please make sure that all options have been selected before submitting.');
    } else { $('#estimateSubmit').replaceWith(submitting); }

    $('select').each(function() {
      if ($(this).val() === "choose") {
        $(this).addClass('error');
      }
    });
  
    var now = new Date();
    var parts = [now.getFullYear(), (now.getMonth() + 1), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds(), now.getMilliseconds()];
    var quoteNumber = parts.join("");
    $('#estimateNumber').attr("value", quoteNumber);
    var number = quoteNumber;
  }
});

$('#cabinetSize, #cabinetDepth, #cabinetFace, #cabinetMount, #cabinetLighting, #cabinetPaint').change(function() {
  "use strict";
  $('select').each(function() {
    $(this).removeClass('error');
  });
});

/*Contact Form Validation*/

$('#estimateContact').submit(function(event) {
  "use strict";
  $('#error').replaceWith('<p id="error"></p>');
  if ($('#name').val() === "" || $('#business').val() === "" || $('#address').val() === "" || $('#phone').val() === "" || $('#mail').val() === "") {
    event.preventDefault();
    /*$('#error').replaceWith(contactMessage);*/
    alert('Some required fields have not been filled out.  Please check section 1 of the form and fill in any missing fields.');
  } else { $('#contactSubmit').replaceWith(submitting); }

  $('#contactInfo input').each(function() {
    if ($(this).val() === "" && $(this).prev().children().hasClass('required')) {
      $(this).addClass('error');
    }
  });

});

function ok() {
  "use strict";
  $('#contactInfo input').each(function() {
    if ($(this).val() !== "") {
      $(this).removeClass('error');
    }
  });
}

$('#name, #business, #address, #phone, #mail').keyup(ok).change(ok).select(ok);