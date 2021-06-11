  Dropzone.autoDiscover = false;
  Dropzone.createThumbNails = false;
  
var dropzoneOptions = {
    
  init: function() {
        this.on("addedfile", function(file){
        $('.progress' ).css({visibility:'visible'});   
        file.previewElement.innerHTML = document.getElementById('preview-template').innerHTML;
        var pro = document.getElementById('progressbar');
        pro.classList.remove('animated', 'fadeOut')
      });
    
      this.on("success", function(file){
          if(file.xhr) {
            //handleAjaxResponse("",file.xhr,{restxq:true});
            Influx.restxqSuccess("",file.xhr,{restxq:true})
          }
      });
      
      this.on("error", function(file, e){
        file.previewElement.childNodes[1].classList.add('btn-danger', 'animated', 'fadeIn');
        file.previewElement.childNodes[1].innerHTML = file.name.split(/-[0-9]+/)[0] + " upload failed: " + e;
      });
      
      this.on("complete", function(file, e){
        window.setTimeout(
                    ()=>{
                      var pro = document.getElementById('progressbar');
                      pro.classList.add('animated', 'fadeOut')
                      file.previewElement.childNodes[1].classList.add('animated', 'fadeOut');

                    },4000
                  );
                  
         window.setTimeout(
                    ()=>{
                      var progressbarinner = $('.progress .progress-bar' );
                      progressbarinner.css({width:0 + '%'});
                      this.removeFile(file);
                    },5000
                  );          
      });
  },

  acceptedFiles: '.csv'
 };
  
  var dropZone = new Dropzone('#uploadRegelungen', dropzoneOptions);

  dropZone.on("totaluploadprogress", function(uploadProgress, totalBytes, totalSentBytes) {
    var progressbar = $('.progress .progress-bar' );
    progressbar.css({width:uploadProgress + '%'});
  });
