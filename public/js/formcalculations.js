
function inscriptionPrice()
var inscriptionPrice = 0;
var theForm = document.forms["personalize"];
var includeName = theForm.elements["includeName"];
var includeNumber = theForms.elements["includeNumber"];

if (includeName.checked == true){
  inscriptionPrice = 3;
}
 elsif (includeNumber.checked == true){
   inscriptionPrice = 2;
 }
 else (includeName.checked == true && includeNumber.checked == true){
   inscriptionPrice = 5;
 }
return inscriptionPrice;

function calculateTotal()
var persPrice = inscriptionPrice();
var divobj = document.getElementById('totalPrice');
divobj.style.display = 'block';
divobj.innerHTML = "Total Personalization charge$" + persPrice;
