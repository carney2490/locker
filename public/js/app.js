//// product image next to product drop down on the estimation page
//$('#school').change(function(){
//  var selectionImage = $('.selection img');
//  var itemType = $('#school').val();
//  
//  if (itemType === "casd") {
//    selectionImage.prop("src","img/school_logos/mightymikelogo.jpg");
//  } else if (itemType === "wcsd") {
//    selectionImage.prop("src","img/school_logos/waynesburg_sm.jpg");
//  } else if (itemType === "wgsd") {
//    selectionImage.prop("src","img/school_logos/pioneer.jpg");
//  } else if (itemType === "jmsd") {
//    selectionImage.prop("src","img/school_logos/jefferson_sm.jpg");
//  } else if (itemType === "sgsd") {
//    selectionImage.prop("src","img/school_logos/maple_leaf_sm.jpg");
//  } else if (itemType === "wu") {                  
//    selectionImage.prop("src","img/school_logos/WaynesburgJackets_sm.jpg");
//  } 
//});

// change product price when clicking on size
$('#productPage label').click(function(){
  var price = $('[name="size"]:checked').attr('data-price');
  $('#price').attr("value",price);
});

$('.fa-trash-o').click(function(){
  var index = $(this).attr("data-index");
  $('#deleteFromCart input').attr("value",index);
  if (window.confirm("Delete this item from your cart?")) {
    $('#deleteFromCart').submit();
  };
});

$(document).ready(function(){
     $(window).scroll(function () {
            if ($(this).scrollTop() > 50) {
                $('#back-to-top').fadeIn();
            } else {
                $('#back-to-top').fadeOut();
            }
        });
        // scroll body to 0px on click
        $('#back-to-top').click(function () {
            $('#back-to-top').tooltip('hide');
            $('body,html').animate({
                scrollTop: 0
            }, 800);
            return false;
        });
        
        $('#back-to-top').tooltip('show');

});
