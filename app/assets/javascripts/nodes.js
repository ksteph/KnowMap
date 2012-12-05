$(document).ready(function() {
  console.log('hello1');
  $('#content-questions .navigation a').click(function() {
   console.log('hello');
   if(!$(this).hasClass('active')) {
     console.log('hello');
     $(this).addClass('active').siblings().removeClass('active');
   }
  });  
});
