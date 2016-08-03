$(document).ready(function() {

var bar = $('.progress .determinate');
var status = $('.status');

$('form').ajaxForm({
	beforeSend: function() {
		status.html('Uploading ...');
		var percentVal = '0%';
		bar.width(percentVal);
	},
	uploadProgress: function(event, position, total, percentComplete) {
		var percentVal = percentComplete + '%';
		bar.width(percentVal);
	},
	success: function() {
		var percentVal = '100%';
		bar.width(percentVal);
	},
	complete: function(xhr) {
		status.html(xhr.responseText);
	}
}); 

});
