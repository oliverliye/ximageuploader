ximageuploader 简介
--------------------
* 基于html javascript ajax 的图片上传组件，支持拖拽、粘贴

使用方法：
------------

* ximageuploader是用coffeescript写的，如果自己编译需安装nodejs和coffeescript;也可以直接引用编译好的ximageuploader.js。
```html
<!-- HTML5 -->
<script src="ximageuploader.js"></script>

<!-- For HTML4/IE -->
<script type="text/javascript" src="ximageuploader.js"></script>
```
* 需要有一个div来生成上传组件, 必须有contenteditable属性
```html
<div contenteditable="true"></div>
```
* javascript中调用方法，ximageuploader不对服务器返回结果进行任何处理，需要自己处理
```javascript
xloader = new XImageUploader(docuement.getElementById('loader'), {
    url: '上传url'，
    onFileUploaded： function(responseText) {}， //上传成功回调函数每个图片会调用一次，responseText为服务器相应信息
    onError： function(){} //上传失败回调函数
  });
```
* ximageloader在处理粘贴剪贴板图片时（firfox, ie），提交给服务器的是一个base64 url，服务端需要对数据进行处理
```javascript
"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZEAAAGRCAYAAACkIY5XAA"
```


* ximageuploader是以post表单的形式上传图片，服务端需要获取post数据的file字段进行处理，如果数据是以base64传输的需要判断




