// product image next to product drop down on the estimation page
$('#school').change(function(){
  var selectionImage = $('.selection img');
  var itemType = $('#school').val();
  
  if (itemType === "casd") {
    selectionImage.prop("src","img/school_logos/mightymikelogo.jpg");
  } else if (itemType === "wcsd") {
    selectionImage.prop("src","img/school_logos/waynesburg_sm.jpg");
  } else if (itemType === "wgsd") {
    selectionImage.prop("src","img/school_logos/pioneer.jpg");
  } else if (itemType === "jmsd") {
    selectionImage.prop("src","img/school_logos/jefferson_sm.jpg");
  } else if (itemType === "sgsd") {
    selectionImage.prop("src","img/school_logos/maple_leaf_sm.jpg");
  } else if (itemType === "wu") {                  
    selectionImage.prop("src","img/school_logos/WaynesburgJackets_sm.jpg");
  } 
});

// change product price when clicking on size
$('#productPage label').click(function(){
  var price = $('[name="size"]:checked').attr('data-price');
  $('#price').attr("value",price);
});

// shopping cart
$('document').ready(function() {
  var subtotal = 0.00
  $('.itemTotals').each(function() {
    var price = parseFloat($(this).html());
    subtotal += price
  });

  $('.subtotal').html('$' + subtotal.toFixed(2));
  
  var sandh = parseFloat($('.sandh').html());
  var gtotal = subtotal + sandh
  
  $('#gtotal').html('$' + gtotal.toFixed(2));
});

$('.fa-trash-o').click(function(){
  var index = $(this).attr("data-index");
  $('#deleteFromCart input').attr("value",index);
  if (window.confirm("Delete this item from your cart?")) {
    $('#deleteFromCart').submit();
  };
});