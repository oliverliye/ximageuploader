// Generated by CoffeeScript 1.12.1

/* 
ximageuploadr is image upload interface
support drag paste

https://github.com/oliverliye/ximageuploader
http://www.oliverliye.com/XImageUploader
 */
var Element, XImageUploader, createFormUpload, createHiddenEditable, createUploadIFrame, defaults, extend, loadImageFromClip, onDrop, onPaste, uploadFile;

defaults = {
  maxFile: 1,
  types: ['image/jpeg', 'image/png', 'image/jpg', 'image/gif'],
  onFileUploaded: function() {},
  onError: function() {}
};

extend = function(d, s) {
  var k, v;
  for (k in s) {
    v = s[k];
    d[k] = v;
  }
  return d;
};

createHiddenEditable = function() {
  var div;
  div = new Element(document.createElement('div'));
  div.attr('contenteditable', true);
  div.attr('tabindex', -1);
  div.css("width", "1px");
  div.css("height", "1px");
  div.css("position", "fixed");
  div.css("left", "-9999px");
  div.css("overflow", "hidden");
  return div;
};

createFormUpload = function(input, url, loader) {
  var change, file, form;
  form = new Element(document.createElement('form'));
  form.attr('method', 'POST');
  form.attr('action', url);
  form.attr('enctype', 'multipart/form-data');
  form.attr('target', loader.uid);
  file = new Element(input.clone());
  file.dom.onchange = change = function() {
    var iframe;
    iframe = createUploadIFrame(loader.uid);
    form.append(iframe);
    iframe.dom.onload = function() {
      loader.config.onFileUploaded(iframe.dom.contentWindow.document.body.innerHTML);
      iframe.dom.onload = null;
      form.remove(iframe);
      form.remove(file);
      file = new Element(input.clone());
      file.dom.onchange = change;
      return form.append(file);
    };
    return form.dom.submit();
  };
  form.append(file);
  return form;
};

createUploadIFrame = function(target) {
  var iframe;
  iframe = new Element(document.createElement('iframe'));
  iframe.attr("name", target);
  iframe.css("display", "none");
  return iframe;
};

Element = (function() {
  function Element(element) {
    this.dom = element;
  }

  Element.prototype.attr = function(name, value) {
    if (!value) {
      return this.dom.getAttribute(name);
    } else {
      return this.dom.setAttribute(name, value);
    }
  };

  Element.prototype.css = function(name, value) {
    return this.dom.style[name] = value;
  };

  Element.prototype.append = function(node) {
    return this.dom.appendChild(node.dom);
  };

  Element.prototype.remove = function(node) {
    return this.dom.removeChild(node.dom);
  };

  Element.prototype.clone = function() {
    return this.dom.cloneNode();
  };

  Element.prototype.focus = function() {
    return this.dom.focus();
  };

  Element.prototype.empty = function() {
    return this.dom.innerHTML = "";
  };

  Element.prototype.isDiv = function() {
    return this.dom.nodeName === 'DIV' || this.dom.nodeName === 'div';
  };

  Element.prototype.isImg = function() {
    return this.dom.nodeName === 'IMG' || this.dom.nodeName === 'img';
  };

  Element.prototype.isFileInput = function() {
    return this.dom.nodeName === 'INPUT' || this.dom.nodeName === 'input' && this.dom.getAttribute('type') === 'file';
  };

  return Element;

})();

XImageUploader = (function() {
  function XImageUploader(element, config) {
    var child, input, j, len, ref;
    this.uid = new Date().getTime();
    this.el = new Element(element);
    if (!this.el.isDiv()) {
      return null;
    }
    this.paste = createHiddenEditable();
    this.config = extend(defaults, config);
    this.el.append(this.paste);
    this.el.dom.onclick = (function(_this) {
      return function() {
        return _this.paste.focus();
      };
    })(this);
    this.el.dom.ondrop = (function(_this) {
      return function(e) {
        var event;
        if (event = e) {
          event.stopPropagation();
          event.preventDefault();
        } else if (event = window.event) {
          event.returnValue = false;
          event.cancelBubble = true;
        }
        return onDrop(_this, event);
      };
    })(this);
    this.el.dom.ondragenter = this.el.dom.ondragover = function(e) {
      var event;
      if (event = e) {
        event.stopPropagation();
        return event.preventDefault();
      } else if (event = window.event) {
        event.returnValue = false;
        return event.cancelBubble = true;
      }
    };
    this.paste.dom.onpaste = (function(_this) {
      return function(e) {
        return onPaste(_this, e);
      };
    })(this);
    ref = this.el.dom.childNodes;
    for (j = 0, len = ref.length; j < len; j++) {
      child = ref[j];
      input = new Element(child);
      if (input.isFileInput()) {
        this.file = createFormUpload(input, config.url, this);
        this.el.append(this.file);
        this.el.remove(input);
        break;
      }
    }
  }

  XImageUploader.prototype.isAllowed = function(type) {
    var j, len, ref, t;
    ref = this.config.types;
    for (j = 0, len = ref.length; j < len; j++) {
      t = ref[j];
      if (t.indexOf(type) >= 0) {
        return true;
      }
    }
    return false;
  };

  return XImageUploader;

})();

onDrop = function(loader, e) {
  var file, files, j, len, maxFile, ref;
  maxFile = loader.config.maxFile;
  if (!(files = e.dataTransfer.files)) {
    return;
  }
  ref = e.dataTransfer.files;
  for (j = 0, len = ref.length; j < len; j++) {
    file = ref[j];
    uploadFile(loader, file);
  }
};

onPaste = function(loader, e) {
  var file, i, item, items, j, l, len, len1, ref;
  if (e.clipboardData) {
    items = e.clipboardData.items;
    if (items) {
      for (i = j = 0, len = items.length; j < len; i = ++j) {
        item = items[i];
        if (!loader.isAllowed(item.type)) {
          continue;
        }
        uploadFile(loader, item.getAsFile());
      }
      return;
    } else {
      setTimeout((function(_this) {
        return function() {
          var child, l, len1, ref;
          ref = loader.paste.dom.childNodes;
          for (l = 0, len1 = ref.length; l < len1; l++) {
            child = ref[l];
            child = new Element(child);
            if (!child.isImg()) {
              continue;
            }
            loadImageFromClip(loader, child.attr('src'));
          }
          loader.paste.empty();
        };
      })(this), 1);
    }
  }
  if (window.clipboardData) {
    ref = window.clipboardData.files;
    for (l = 0, len1 = ref.length; l < len1; l++) {
      file = ref[l];
      loadImageFromClip(loader, URL.createObjectURL(file));
    }
    return setTimeout((function(_this) {
      return function() {
        return loader.paste.empty();
      };
    })(this), 1);
  }
};

loadImageFromClip = function(loader, src) {
  var img;
  if (src.match(/^webkit\-fake\-url\:\/\//)) {
    return loader.config.onError();
  }
  img = new Image();
  img.crossOrigin = "anonymous";
  img.onload = (function(_this) {
    return function() {
      var canvas, ctx, dataURL;
      canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
      dataURL = canvas.toDataURL('image/png');
      return uploadFile(loader, dataURL);
    };
  })(this);
  img.onerror = (function(_this) {
    return function() {
      return loader.config.onError();
    };
  })(this);
  return img.src = src;
};

uploadFile = function(loader, file) {
  var formData, xhr;
  formData = new FormData();
  xhr = new XMLHttpRequest();
  if (typeof file === 'object') {
    formData.append('file', file, file.name);
  } else {
    formData.append('file', file);
  }
  xhr.open('POST', loader.config.url);
  xhr.onload = function() {
    if (xhr.status === 200 || xhr.status === 201) {
      return loader.config.onFileUploaded(xhr.responseText);
    } else {
      return loader.config.onError();
    }
  };
  return xhr.send(formData);
};

window.XImageUploader = XImageUploader;
