//loading-icon定位于浏览器中央 2017年6月20日17:41:39 load层的居中不再使用jquery来定位(使用最方便的css-display:flex,流式布局来定位)
// $(window).resize(function(){
	 // resizenow();
// });
// function resizenow() {
// 	var browserwidth = $(window).width();
// 	var browserheight = $(window).height();
// 	$('.bonfire-pageloader-icon').css('right', ((browserwidth - $(".bonfire-pageloader-icon").width())/2)).css('top', ((browserheight*0.65 - $(".bonfire-pageloader-icon").height())/2));
// };
// resizenow();
//$(window).scroll (function (){
//     $(this).scrollTop(0);
//});
//var top = $(document).scrollTop();
//$(document).on('scroll.unable',function (e) {
//    $(document).scrollTop(top);
//});
//页面完全加载好后
$(window).load(function(){
// 	使load层淡出
	setTimeout(function(){
		$('#bonfire-pageloader').addClass('bonfire-pageloader-hide');
	},500);
	//显示浏览器的滚动条
//	setTimeout(function(){
//		$(window).unbind ('scroll');
//	},750);
	//移除load层
	setTimeout(function(){
		$('#bonfire-pageloader').addClass('bonfire-pageloader-dis');
		$('body').css('overflow-y','scroll');
	},500);
});