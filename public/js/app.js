

// change product price when clicking on size

$('#productPage label').click(function(){
  var price = $document.querySelector('input:radio[name = "size"]:checked== true').data('price');
  $('#price').setAttribute('value', price);
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
